-- =============================================
-- Autor:               rudi.garcia 
-- Fecha de Creacion:   22-Jan-2019 G-Force@Quetal
-- Description:         SP que inserta el pase de salida desde el movil

-- Autor:               Gildardo Alvarado
-- Fecha de Creacion:   17-Diciembre-2020 G-Force@Quetal
-- Description:         Se agrega el estado "DISPATCH" a las licencias que crea
--						la Hand Held cuando esta se opera en esta 
/*
                                                    
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_INSERT_INSERT_EXIT_PASS_FROM_DISPATCH_LICENCE] (
		@DISPATCH_LICENSE_EXIT_HEADER INT
		,@VEHICLE_CODE INT
		,@PILOT_CODE INT
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY;
		BEGIN TRAN;

    -- ------------------------------------------------------------------------------------
    -- Declaramos las variables necesarias.
    -- ------------------------------------------------------------------------------------

		DECLARE
			@PASS_ID INT
			,@WAVE_PICKING_ID INT
			,@CLIENT_CODE VARCHAR(25)
			,@CLIENT_NAME VARCHAR(200)
			,@VEHICLE_PLATE VARCHAR(25)
			,@VEHICLE_DRIVER VARCHAR(200)
			,@AUTORIZED_BY VARCHAR(200)
			,@STATUS VARCHAR (20)
			,@LICENSE_ID INT ;

    -- ------------------------------------------------------------------------------------
    -- Obtenemos los registros necesarios
    -- ------------------------------------------------------------------------------------

		SELECT TOP 1
			@WAVE_PICKING_ID = [DLED].[WAVE_PICKING_ID]
		FROM
			[FERCO].[OP_WMS_DISPATCH_LICENSE_EXIT_HEADER] [DLEH]
		INNER JOIN [FERCO].[OP_WMS_DISPATCH_LICENSE_EXIT_DETAIL] [DLED] ON ([DLEH].[DISPATCH_LICENSE_EXIT_HEADER_ID] = [DLED].[DISPATCH_LICENSE_EXIT_HEADER_ID])
		WHERE
			[DLEH].[DISPATCH_LICENSE_EXIT_HEADER_ID] = @DISPATCH_LICENSE_EXIT_HEADER;


		SELECT TOP 1
			@CLIENT_CODE = [TL].[CLIENT_OWNER]
			,@CLIENT_NAME = [TL].[CLIENT_NAME]
			,@AUTORIZED_BY = [TL].[TASK_ASSIGNEDTO]
		FROM
			[FERCO].[OP_WMS_TASK_LIST] [TL]
		WHERE
			[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;

		SELECT TOP 1
			@VEHICLE_PLATE = [V].[PLATE_NUMBER]
		FROM
			[FERCO].[OP_WMS_VEHICLE] [V]
		WHERE
			[V].[VEHICLE_CODE] = @VEHICLE_CODE;

		SELECT TOP 1
			@VEHICLE_DRIVER = [P].[NAME]
		FROM
			[FERCO].[OP_WMS_PILOT] [P]
		WHERE
			[P].[PILOT_CODE] = @PILOT_CODE;



		INSERT	[FERCO].[OP_WMS3PL_PASSES]
				(
					[CLIENT_CODE]
					,[CLIENT_NAME]
					,[LAST_UPDATED_BY]
					,[LAST_UPDATED]
					,[ISEMPTY]
					,[VEHICLE_PLATE]
					,[VEHICLE_DRIVER]
					,[VEHICLE_ID]
					,[DRIVER_ID]
					,[AUTORIZED_BY]
					,[HANDLER]
					,[LOADUNLOAD]
					,[CREATED_DATE]
					,[CREATED_BY]
					,[STATUS]
					,[TYPE]
				)
		VALUES
				(
					@CLIENT_CODE
					,@CLIENT_NAME
					,@LOGIN
					,GETDATE()
					,'Y'
					,@VEHICLE_PLATE
					,@VEHICLE_DRIVER
					,@VEHICLE_CODE
					,@PILOT_CODE
					,@AUTORIZED_BY
					,@LOGIN
					,'C'
					,GETDATE()
					,@LOGIN
					,'CREATED'
					,'SALES_ORDER'
				);

		SET @PASS_ID = SCOPE_IDENTITY();

		INSERT	INTO [FERCO].[OP_WMS_PASS_DETAIL]
				(
					[PASS_HEADER_ID]
					,[CLIENT_CODE]
					,[CLIENT_NAME]
					,[PICKING_DEMAND_HEADER_ID]
					,[DOC_NUM]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY]
					,[DOC_NUM_POLIZA]
					,[CODIGO_POLIZA]
					,[NUMERO_ORDEN_POLIZA]
					,[WAVE_PICKING_ID]
					,[CREATED_DATE]
					,[CODE_WAREHOUSE]
					,[TYPE_DEMAND_CODE]
					,[TYPE_DEMAND_NAME]
          ,[LINE_NUM]
				)
		SELECT
			@PASS_ID
			,[DLED].[CLIENT_CODE]
			,[DLED].[CLIENT_NAME]
			,[DLED].[PICKING_DEMAND_HEADER_ID]
			,[DLED].[DOC_NUM]
			,[DLED].[MATERIAL_ID]
			,[DLED].[MATERIAL_NAME]
			,[DLED].[QTY]
			,[DLED].[DOC_NUM_POLIZA]
			,[DLED].[CODIGO_POLIZA]
			,[DLED].[NUMERO_ORDEN_POLIZA]
			,[DLED].[WAVE_PICKING_ID]
			,[DLED].[CREATED_DATE]
			,[DLED].[CODE_WAREHOUSE]
			,[DLED].[TYPE_DEMAND_CODE]
			,[DLED].[TYPE_DEMAND_NAME]
      ,[DLED].[LINE_NUM]
		FROM
			[FERCO].[OP_WMS_DISPATCH_LICENSE_EXIT_DETAIL] [DLED]
		WHERE
			[DLED].[DISPATCH_LICENSE_EXIT_HEADER_ID] = @DISPATCH_LICENSE_EXIT_HEADER;

		UPDATE
			[DLEH]
		SET	
			[DLEH].[PASS_EXIT_ID] = @PASS_ID
		FROM
			[FERCO].[OP_WMS_DISPATCH_LICENSE_EXIT_HEADER] [DLEH]
		WHERE
			[DLEH].[DISPATCH_LICENSE_EXIT_HEADER_ID] = @DISPATCH_LICENSE_EXIT_HEADER;

		COMMIT;

    -- ------------------------------------------------------------------------------------
    -- Actualizamos el estado de las licensias que crea el despacho, en el Inventario en linea (OP_WMS_INV_X_LICENSE)
    -- ------------------------------------------------------------------------------------
	
		SELECT 
			[IL].LICENSE_ID 
		INTO	
			#TEMP
		FROM
			[FERCO].[OP_WMS_PASS_DETAIL] [PD] 
			INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [TL] ON ([TL].[WAVE_PICKING_ID] = [PD].[WAVE_PICKING_ID])
			LEFT JOIN [FERCO].[OP_WMS_LICENSES] [L] ON ([L].[CODIGO_POLIZA] = [TL].[CODIGO_POLIZA_TARGET])
			INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
		WHERE 
			PD.PASS_HEADER_ID = @PASS_ID 
		GROUP BY
			[IL].[LICENSE_ID],
			[IL].[MATERIAL_NAME]
		
		
		UPDATE [IL]
	    SET
		    IL.STATUS = 'DISPATCH'
	    FROM
			[FERCO].[OP_WMS_INV_X_LICENSE] [IL] 
			INNER JOIN #TEMP #T ON (#T.LICENSE_ID = IL.LICENSE_ID)
		WHERE
			IL.STATUS <> 'DISPATCH' 
		
		
		--SELECT
		--	[IL].LICENSE_ID, [IL].[MATERIAL_NAME]

		--UPDATE 
		--	[IL]
		--SET
		--	[IL].[STATUS] = 'DISPATCH'
		--FROM
		--	[FERCO].[OP_WMS_INV_X_LICENSE] [IL] --ON ()
		--	LEFT JOIN [FERCO].[OP_WMS_LICENSES] [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
		--	INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [TL] ON ([L].[CODIGO_POLIZA] = [TL].[CODIGO_POLIZA_TARGET])
		--	INNER JOIN [FERCO].[OP_WMS_PASS_DETAIL] [PD] ON ([TL].[WAVE_PICKING_ID] = [PD].[WAVE_PICKING_ID])

		--GROUP BY
		--	[IL].[LICENSE_ID],
		--	[IL].[MATERIAL_NAME]



		--ORDER BY 
		--	[IL].[LAST_UPDATED]
		--DESC

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@PASS_ID AS VARCHAR(20)) [DbData];


	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE	@message VARCHAR(1000) = @@ERROR;
		PRINT @message;
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];

		RAISERROR (@message, 16, 1);

	END CATCH;
END;