-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/31/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Marca una recepcion de solicitud de traslado como enviada a ERP

-- Modificacion 10/4/2017 @ NEXUS-Team Sprint eFERCO
					-- rodrigo.gomez
					-- Se agrega el cambio para la lectura de external_source desde erp

-- Modificacion 10/9/2017 @ NEXUS-Team Sprint eFERCO
					-- rodrigo.gomez
					-- Se actualiza el valor de LOCKED_BY_INTERFACES cuando se marca como 0

-- Modificacion 11/29/2017 @ NEXUS-Team Sprint GTA
					-- rodrigo.gomez
					-- Se valida el parametro de explosion por bodegas de los materiales

-- Modificacion 04/06/2022 Sprint 42
					-- Elder Lucas
					-- Se agrega un segundo inner join con la tabla OP_WMS_NEXT_PICKING_DEMAND_HEADER
					--usando el wave_picking como union para evitar que queden documentos sin actualizar
/*
-- Ejemplo de Ejecucion:
 EXEC [FERCO].[OP_WMS_SP_MARK_TRANSFER_REQUEST_AS_SEND_TO_ERP] 
	@RECEPTION_DOCUMENT_ID = 32682, -- int
	@POSTED_RESPONSE = 'Proceso Exitoso', -- varchar(500)
	@ERP_REFERENCE = '39728', -- varchar(50)
	@OWNER = 'Ferco' -- varchar(50)
*/
-- =============================================

CREATE PROCEDURE [FERCO].[OP_WMS_SP_MARK_TRANSFER_REQUEST_AS_SEND_TO_ERP](
	@RECEPTION_DOCUMENT_ID INT,
	@POSTED_RESPONSE VARCHAR(500),
	@ERP_REFERENCE VARCHAR(50),
	@OWNER VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@DOC_NUM INT
		,@QUERY NVARCHAR(MAX)
		,@LICENSE_ID DECIMAL
		,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
		,@ERP_DATABASE VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@TABLE VARCHAR(10)
		,@TASK_ID INT
		,@CODIGO_POLIZA VARCHAR(50)
		,@IS_FROM_ERP INT = 0
		,@MATERIAL_ID VARCHAR(50)
		,@LOGIN VARCHAR(50)
		,@EXPLOSION_TYPE VARCHAR(200);
	BEGIN TRY
		SELECT TOP 1 @EXPLOSION_TYPE = [C].[TEXT_VALUE]
		FROM [FERCO].[OP_WMS_CONFIGURATIONS] [C]
		WHERE [C].[PARAM_TYPE] = 'SISTEMA'
			AND [C].[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
			AND [C].[PARAM_NAME] = 'TIPO_EXPLOSION_RECEPCION'
		-- ------------------------------------------------------------------------------------
		-- Obtiene el dueño de la recepcion
		-- ------------------------------------------------------------------------------------
		SELECT @IS_FROM_ERP = [RDH].[IS_FROM_ERP]
		FROM [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
		WHERE [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID

		-- ------------------------------------------------------------------------------------
		-- Obtiene la fuente del dueño de la recepcion
		-- ------------------------------------------------------------------------------------
		SELECT 
			@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
			,@ERP_DATABASE = [C].[ERP_DATABASE]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
			,@TABLE = 'OWTR'
		FROM [FERCO].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		INNER JOIN [FERCO].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
		WHERE [C].[COMPANY_NAME] LIKE ('%' + @OWNER + '%')
			AND [ES].[READ_ERP] = 1

		-- ------------------------------------------------------------------------------------
		-- Obtiene el doc num del ERP
		-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME 
			+'.[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY]
					@DATABASE ='+ @ERP_DATABASE + '
					,@TABLE = ''' + @TABLE + '''
					,@DOC_ENTRY = ' + @ERP_REFERENCE + '
					,@DOC_NUM = @DOC_NUM OUTPUT';
		PRINT @QUERY;
		--
		EXEC sp_executesql @QUERY,N'@DOC_NUM INT =-1 OUTPUT',@DOC_NUM = @DOC_NUM OUTPUT;

		-- ------------------------------------------------------------------------------------
		-- Actualiza el detalle de la recepcion
		-- ------------------------------------------------------------------------------------
		UPDATE [RDD]
		SET	
			[RDD].[IS_POSTED_ERP] = 1
			,[RDD].[POSTED_ERP] = GETDATE()
			,[RDD].[POSTED_RESPONSE] = REPLACE(@POSTED_RESPONSE, @ERP_REFERENCE, @DOC_NUM)
			,[RDD].[ERP_REFERENCE] = @ERP_REFERENCE
			,[RDD].[ERP_REFERENCE_DOC_NUM] = @DOC_NUM
		FROM [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD]
			INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RDD].[MATERIAL_ID]
		WHERE [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID AND
			([M].[CLIENT_OWNER] = @OWNER OR @IS_FROM_ERP = 1)
			AND [RDD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID] > 0;
		-- ------------------------------------------------------------------------------------
		-- Actualiza el detalle de las olas de picking procedentes de la recepción por traslado
		-- ------------------------------------------------------------------------------------
			UPDATE [PDD]
			SET
				 [PDD].[POSTED_STATUS] = 2
				,[PDD].[IS_POSTED_ERP] = 1
				,[PDD].[POSTED_ERP] = GETDATE()
				,[PDD].[POSTED_RESPONSE] = REPLACE(@POSTED_RESPONSE + ' de picking por traslado No.' + '' + @ERP_REFERENCE+'', @ERP_REFERENCE, @DOC_NUM)
				,[PDD].[ERP_REFERENCE] = @ERP_REFERENCE
			FROM FERCO.OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER [RDH] 
				INNER JOIN FERCO.OP_WMS_TASK_LIST TL ON ([RDH].[TASK_ID] = [TL].[SERIAL_NUMBER])
				INNER JOIN FERCO.OP_WMS_TRANSFER_REQUEST_HEADER [TRH] ON ([TRH].[TRANSFER_REQUEST_ID] = [TL].[TRANSFER_REQUEST_ID])
				INNER JOIN FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER [PDH] ON ([PDH].[DOC_NUM] = [TRH].[DOC_ENTRY])
				INNER JOIN FERCO.OP_WMS_NEXT_PICKING_DEMAND_DETAIL [PDD] ON ([PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID])
			WHERE 
				[RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID

		-- ------------------------------------------------------------------------------------
		-- Verifica que todo el detalle este marcado como 1 y marca el encabezado como posteado
		-- ------------------------------------------------------------------------------------
		IF NOT EXISTS (SELECT * FROM [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] WHERE [IS_POSTED_ERP] <> 1 AND [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID)
		BEGIN
			
			UPDATE [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			SET	
				[LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = 'INTERFACE'
				,[IS_POSTED_ERP] = 1
				,[POSTED_ERP] = GETDATE()
				,[POSTED_RESPONSE] = REPLACE(@POSTED_RESPONSE, @ERP_REFERENCE, @DOC_NUM)
				,[ERP_REFERENCE] = @ERP_REFERENCE
				,[ERP_REFERENCE_DOC_NUM] = @DOC_NUM
			WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID;

		-- ------------------------------------------------------------------------------------
		-- Actualiza el encabezado de las olas de picking procedentes de la recepción por traslado
		-- ------------------------------------------------------------------------------------
			UPDATE [PDH2]
			SET
				 [PDH2].[LAST_UPDATE] = GETDATE()
				,[PDH2].[LAST_UPDATE_BY] = 'INTERFACE'
				,[PDH2].[IS_POSTED_ERP] = 1
				,[PDH2].[POSTED_ERP] = GETDATE()
				,[PDH2].[POSTED_RESPONSE] = REPLACE(@POSTED_RESPONSE + ' de picking por traslado No.' + ''+@ERP_REFERENCE+'', @ERP_REFERENCE, @DOC_NUM)
				,[PDH2].[ERP_REFERENCE] = @ERP_REFERENCE
				,[PDH2].[ERP_REFERENCE_DOC_NUM] = @DOC_NUM
			FROM FERCO.OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER [RDH] 
				INNER JOIN FERCO.OP_WMS_TASK_LIST TL ON ([RDH].[TASK_ID] = [TL].[SERIAL_NUMBER])
				INNER JOIN FERCO.OP_WMS_TRANSFER_REQUEST_HEADER [TRH] ON ([TRH].[TRANSFER_REQUEST_ID] = [TL].[TRANSFER_REQUEST_ID])
				INNER JOIN FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER [PDH] ON ([PDH].[DOC_NUM] = [TRH].[DOC_ENTRY])
				INNER JOIN FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER [PDH2] ON ([PDH2].[DOC_NUM] = [TRH].[DOC_ENTRY])
			WHERE 
				[RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID
			---- ------------------------------------------------------------------------------------
			---- Obtiene la tarea para desbloquear el inventario
			---- ------------------------------------------------------------------------------------
			--SELECT @TASK_ID = [TASK_ID]
			--FROM [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			--WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID;
			---- ------------------------------------------------------------------------------------
			---- Obtiene el codigo de poliza de la tarea
			---- ------------------------------------------------------------------------------------
			--SELECT @CODIGO_POLIZA = [CODIGO_POLIZA_SOURCE] 
			--FROM [FERCO].[OP_WMS_TASK_LIST] 
			--WHERE [SERIAL_NUMBER] = @TASK_ID
			---- ------------------------------------------------------------------------------------
			---- Obtiene el ID de la licencia
			---- ------------------------------------------------------------------------------------
			--SELECT [LICENSE_ID]
			--INTO [#LICENSES]
			--FROM [FERCO].[OP_WMS_LICENSES] 
			--WHERE [CODIGO_POLIZA] = @CODIGO_POLIZA
			---- ------------------------------------------------------------------------------------
			---- Desbloquea el inventario por licencia
			---- ------------------------------------------------------------------------------------
			--UPDATE [IXL]
			--SET [IS_BLOCKED] = 0
			--	,[IXL].[LOCKED_BY_INTERFACES] = 0 
			--FROM [FERCO].[OP_WMS_INV_X_LICENSE] [IXL]
			--	INNER JOIN [#LICENSES] [L] ON [L].[LICENSE_ID] = [IXL].[LICENSE_ID]
			--WHERE [IXL].[PK_LINE] > 0

	-- ------------------------------------------------------------------------------------
    -- Desbloquea el inventario
    -- ------------------------------------------------------------------------------------
        EXEC [FERCO].[OP_WMS_UNLOCK_INVENTORY_LOCKED_BY_INTERFACES] @RECEPTION_DOCUMENT_ID = @RECEPTION_DOCUMENT_ID;
    -- ------------------------------------------------------------------------------------

		END

		-- ------------------------------------------------------------------------------------
		-- Obtiene los master packs que explotan en recepcion
		-- ------------------------------------------------------------------------------------
		SELECT DISTINCT
			[MPH].[MATERIAL_ID]
			,[MPH].[LICENSE_ID]
			,[T].[TASK_ASSIGNEDTO]
		INTO [#MASTERPACK_TO_EXPLODE]
		FROM [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
		INNER JOIN [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D] ON [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
		INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
		INNER JOIN [FERCO].[OP_WMS_MASTER_PACK_HEADER] [MPH] ON [MPH].[POLICY_HEADER_ID] = [T].[DOC_ID_SOURCE]
		INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [MPH].[MATERIAL_ID] = [M].[MATERIAL_ID]
		LEFT JOIN [FERCO].[OP_WMS_WAREHOUSES] [W] ON [H].[ERP_WAREHOUSE_CODE] = [W].[ERP_WAREHOUSE]
		LEFT JOIN [FERCO].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE] [MW] ON [M].[MATERIAL_ID] = [MW].[MATERIAL_ID] AND [MW].[WAREHOUSE_ID] = (ISNULL([D].[WAREHOUSE_CODE], [W].[WAREHOUSE_ID]))
		LEFT JOIN [FERCO].[OP_WMS_MATERIAL_PROPERTY] [MP] ON [MP].[MATERIAL_PROPERTY_ID] = [MW].[MATERIAL_PROPERTY_ID] AND [MP].[NAME] = 'EXPLODE_IN_RECEPTION'
		WHERE [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID
			AND [M].[EXPLODE_IN_RECEPTION] = 1
			 AND [M].[IS_MASTER_PACK] = 1
            AND (
                 (
                  [MW].[VALUE] IS NULL
                  AND [M].[EXPLODE_IN_RECEPTION] = 1
                 )
                 OR [MW].[VALUE] = '1'
                );

		-- ------------------------------------------------------------------------------------
		-- Ciclo para explotar cada master pack
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1 1 FROM [#MASTERPACK_TO_EXPLODE] )
		BEGIN
			SELECT TOP 1
				@MATERIAL_ID = [M].[MATERIAL_ID]
				,@LICENSE_ID = [M].[LICENSE_ID]
				,@LOGIN = [M].[TASK_ASSIGNEDTO]
			FROM [#MASTERPACK_TO_EXPLODE] [M];

			-- ---------------------------------------------------------------------------------
			-- validar si explotara en cascada o directo al ultimo nivel 
			-- ---------------------------------------------------------------------------------  
			IF @EXPLOSION_TYPE = 'EXPLOSION_CASCADA'
			BEGIN
				EXEC [FERCO].[OP_WMS_SP_EXPLODE_CASCADE_IN_RECEPTION] @LICENSE_ID = @LICENSE_ID,
					@LOGIN_ID = @LOGIN,
					@MATERIAL_ID = @MATERIAL_ID;
			END;
			ELSE
			BEGIN
				EXEC [FERCO].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @LICENSE_ID,
					@MATERIAL_ID = @MATERIAL_ID,
					@LAST_UPDATE_BY = @LOGIN,
					@MANUAL_EXPLOTION = 0;
			END;
			--
			DELETE [#MASTERPACK_TO_EXPLODE]
			WHERE [MATERIAL_ID] = @MATERIAL_ID
				AND [LICENSE_ID] = @LICENSE_ID
				AND [TASK_ASSIGNEDTO] = @LOGIN;
		END;


		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH
END