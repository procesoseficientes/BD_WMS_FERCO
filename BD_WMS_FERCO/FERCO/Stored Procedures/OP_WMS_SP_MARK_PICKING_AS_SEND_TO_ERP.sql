-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-16 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que marca un picking wms como mandada a ERP 


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint ERGON IV
-- Description:	 SE modifica para que consulte DocNum en base al docEntry obtenido y lo guarde en la tabla 

-- Modificacion 14-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se agrego el parametro @POSTED_STATUS

-- Modificacion 8/10/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- rodrigo.gomez
-- Se marca como enviado a ERP el detalle.

-- Modificacion 10/4/2017 @ NEXUS-Team Sprint eFERCO
-- rodrigo.gomez
-- Se agrega el cambio para la lectura de external_source desde erp

-- Autor:               Gildardo Alvarado
-- Fecha de Creacion:   17-Diciembre-2020 @ProcesosEficientes
-- Description:         Se agrega el estado "DISPATCH" a las licencias que crea
--						la Hand Held cuando se opera en esta 
/*
-- Ejemplo de Ejecucion:
		EXEC  [FERCO].[OP_WMS_SP_MARK_PICKING_AS_SEND_TO_ERP]
			@PICKING_DEMAND_HEADER_ID = 92051
			,@POSTED_RESPONSE = 
			,@ERP_REFERENCE = '16'Exito al guardar en sap 1 '1797'
			,@POSTED_STATUS = 1
			,@OWNER = 'ferco'
		--
		select * from [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] WHERE PICKING_DEMAND_HEADER_ID = 5215
		select * from [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_detail] WHERE PICKING_DEMAND_HEADER_ID = 5215
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_MARK_PICKING_AS_SEND_TO_ERP]
    (
     @PICKING_DEMAND_HEADER_ID INT
    ,@POSTED_RESPONSE VARCHAR(500)
    ,@ERP_REFERENCE VARCHAR(500)
    ,@POSTED_STATUS INT
    ,@OWNER VARCHAR(50)
    ,@IS_INVOICE INT = 0
    )
AS
BEGIN
    SET NOCOUNT ON;
  --
    BEGIN TRY
        DECLARE
            @DOC_NUM INT
           ,@QUERY NVARCHAR(MAX)
           ,@TABLE VARCHAR(50)
           ,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
           ,@ERP_DATABASE VARCHAR(50)
           ,@SCHEMA_NAME VARCHAR(50)
           ,@INTERNAL_SALE_COMPANIES VARCHAR(50)
		   ,@LICENSE_ID INT;

    -- ------------------------------------------------------------------------------------
    -- Obtiene las compañias compraventa y crea la tabla temporal [#PEROFRMS_INTERNAL_SALE]
    -- ------------------------------------------------------------------------------------

        SELECT
            @INTERNAL_SALE_COMPANIES = [TEXT_VALUE]
        FROM
            [FERCO].[OP_WMS_CONFIGURATIONS]
        WHERE
            [PARAM_GROUP] = 'INTERCOMPANY'
            AND [PARAM_NAME] = 'INTERNAL_SALE';
    --
        SELECT TOP 5
            CASE WHEN [ISC].[VALUE] IS NULL THEN 0
                 ELSE 1
            END [PERFORMS_INTERNAL_SALE]
           ,[PDH].[PICKING_DEMAND_HEADER_ID]
        INTO
            [#PERFORMS_INTERNAL_SALE]
        FROM
            [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
        LEFT JOIN [FERCO].[OP_WMS_FUNC_SPLIT](@INTERNAL_SALE_COMPANIES, '|') [ISC] ON ([ISC].[VALUE] = (CASE [PDH].[OWNER]
                                                              WHEN NULL
                                                              THEN CASE [PDH].[SELLER_OWNER]
                                                              WHEN NULL
                                                              THEN [PDH].[CLIENT_OWNER]
                                                              ELSE [PDH].[SELLER_OWNER]
                                                              END
                                                              ELSE [PDH].[OWNER]
                                                              END))
        WHERE
            [PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

    -- ------------------------------------------------------------------------------------
    -- Obtiene la fuente del dueño del picking
    -- ------------------------------------------------------------------------------------
        SELECT
            @INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
           ,@ERP_DATABASE = [C].[ERP_DATABASE]
           ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
           ,@TABLE = CASE WHEN @IS_INVOICE = 1 THEN 'OINV'
                          ELSE 'ODLN'
                     END
        FROM
            [FERCO].[OP_SETUP_EXTERNAL_SOURCE] [ES]
        INNER JOIN [FERCO].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
        WHERE
            [C].[CLIENT_CODE] = @OWNER
            AND [ES].[READ_ERP] = 1;

    -- ------------------------------------------------------------------------------------
    -- Obtiene el doc num del ERP
    -- ------------------------------------------------------------------------------------
        SELECT
            @QUERY = N'EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME
            + '.[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY]
					@DATABASE =' + @ERP_DATABASE + '
					,@TABLE = ''' + @TABLE + '''
					,@DOC_ENTRY = ' + @ERP_REFERENCE + '
					,@DOC_NUM = @DOC_NUM OUTPUT';
        PRINT @QUERY;
    --
        EXEC [sp_executesql] @QUERY, N'@DOC_NUM INT =-1 OUTPUT',
            @DOC_NUM = @DOC_NUM OUTPUT;

    -- ------------------------------------------------------------------------------------
    -- Actualiza el detalle correspondiente
    -- ------------------------------------------------------------------------------------
        UPDATE
            [DD]
        SET
            [DD].[POSTED_STATUS] = @POSTED_STATUS
           ,[DD].[POSTED_ERP] = GETDATE()
           ,[DD].[POSTED_RESPONSE] = REPLACE(@POSTED_RESPONSE, @ERP_REFERENCE,
                                             @DOC_NUM)
           ,[DD].[ERP_REFERENCE] = @DOC_NUM
           ,[DD].[IS_POSTED_ERP] = 1
        FROM
            [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
        INNER JOIN [#PERFORMS_INTERNAL_SALE] [PIS] ON [PIS].[PICKING_DEMAND_HEADER_ID] = [DD].[PICKING_DEMAND_HEADER_ID]
        WHERE
            [DD].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
            AND (
                 [PIS].[PERFORMS_INTERNAL_SALE] = 1
                 OR [DD].[MATERIAL_OWNER] = @OWNER
                );
	
    -- ------------------------------------------------------------------------------------
    -- Actualiza el Header con IS_SENDING 0
    -- ------------------------------------------------------------------------------------
        UPDATE
            [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
        SET
            [IS_SENDING] = 0
        WHERE
            [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

    -- ------------------------------------------------------------------------------------
    -- Valida si ya se enviaron todos los detalles
    -- ------------------------------------------------------------------------------------
        IF NOT EXISTS ( SELECT TOP 1
                            1
                        FROM
                            [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
                        WHERE
                            [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
                            AND [IS_POSTED_ERP] != 1 )
        BEGIN
            UPDATE
                [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
            SET
                [LAST_UPDATE] = GETDATE()
               ,[LAST_UPDATE_BY] = 'INTERFACE'
               ,[POSTED_STATUS] = @POSTED_STATUS
               ,[POSTED_ERP] = GETDATE()
               ,[POSTED_RESPONSE] = REPLACE(ISNULL(@POSTED_RESPONSE, ''),
                                            @ERP_REFERENCE, @DOC_NUM)
               ,[ERP_REFERENCE] = @ERP_REFERENCE
               ,[ERP_REFERENCE_DOC_NUM] = @DOC_NUM
               ,[IS_POSTED_ERP] = 1
            WHERE
                [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
        END;
    -- ------------------------------------------------------------------------------------
    -- Actualizamos el estado de las licencias que crea el despacho, en el Inventario en linea (OP_WMS_INV_X_LICENSE)
    -- ------------------------------------------------------------------------------------

	SELECT
			@LICENSE_ID = [IL].LICENSE_ID
		FROM
			[FERCO].[OP_WMS_PASS_DETAIL] [PD] 
			INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [TL] ON ([TL].[WAVE_PICKING_ID] = [PD].[WAVE_PICKING_ID])
			LEFT JOIN [FERCO].[OP_WMS_LICENSES] [L] ON ([L].[CODIGO_POLIZA] = [TL].[CODIGO_POLIZA_TARGET])
			INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
		WHERE 
			PD.PICKING_DEMAND_HEADER_ID = @PICKING_DEMAND_HEADER_ID  
		GROUP BY
			[IL].[LICENSE_ID],
			[IL].[MATERIAL_NAME]
		
		IF @POSTED_STATUS >= 0
		UPDATE
			[FERCO].[OP_WMS_INV_X_LICENSE]
	    SET
		    STATUS = 'DISPATCH'
	    WHERE
			STATUS <> 'DISPATCH' AND
			LICENSE_ID = @LICENSE_ID 
		
			
    -- ------------------------------------------------------------------------------------
    -- Muestra resultado final
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
    END CATCH;
END;