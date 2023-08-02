-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
-- Description:			SP que genera la tarea de recepcion desde el documento de manifiesto de carga por solicitud de traslado

-- Autor:				Gildardo.Alvarado
-- Fecha de Creacion: 	25-Marzo-2021 @ProcesosEficientes
-- Description:			Se agregan las columnas SOURCE y ERP_WAREHOUSE_CODE a la solicitud de traslado para que valide el material 
--						en la Hand Held

-- Autor:				Elder Lucas
-- Fecha de Creacion: 	24 de febrero de 2022
-- Description:			Se modifica el query para el cálculo de los detalles de la recepción para que aplique también con los consolidados

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_GENERATE_RECEPTION_DOCUMENT_FROM_CARGO_MANIFEST_BY_TRANSFER_REQUEST]
					@MANIFEST_ID = 1318
					,@LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GENERATE_RECEPTION_DOCUMENT_FROM_CARGO_MANIFEST_BY_TRANSFER_REQUEST]
    (
     @MANIFEST_ID INT
    ,@LOGIN VARCHAR(50)
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    DECLARE @RESULT TABLE
        (
         [Resultado] INT
        ,[Mensaje] VARCHAR(1000)
        ,[Codigo] INT
        ,[DbData] VARCHAR(50)
        );
	--
    BEGIN TRY
        DECLARE
            @ID INT
           ,@CLIENT_CODE VARCHAR(50)
           ,@CLIENT_NAME VARCHAR(150)
           ,@TRANSFER_REQUEST_ID INT
           ,@FECHA_POLIZA DATETIME = GETDATE()
           ,@CODIGO_POLIZA VARCHAR(50)
           ,@TASK_ID INT
           ,@NUMERO_ORDEN VARCHAR(50)
           ,@ACUERDO_COMERCIAL VARCHAR(50)
           ,@Resultado INT = -1
           ,@Mensaje VARCHAR(1000)
           ,@Codigo INT = 0;

		-- ------------------------------------------------------------------------------------
		-- Se obtiene el ID de Solicitud de traslado, nombre de cliente y codigo de cliente desde la demanda despacho
		-- ------------------------------------------------------------------------------------
        SELECT
            @TRANSFER_REQUEST_ID = [TRANSFER_REQUEST_ID]
        FROM
            [FERCO].[OP_WMS_MANIFEST_HEADER]
        WHERE
            [MANIFEST_HEADER_ID] = @MANIFEST_ID;
		--
        SELECT
            @CLIENT_CODE = [CLIENT_CODE]
           ,@CLIENT_NAME = [CLIENT_NAME]
           ,@NUMERO_ORDEN = CAST(@TRANSFER_REQUEST_ID AS VARCHAR) + '-WT'
           ,@ACUERDO_COMERCIAL = ISNULL(CAST([OWAXC].[ACUERDO_COMERCIAL] AS VARCHAR),
                                        '')
        FROM
            [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
        LEFT JOIN [FERCO].[OP_WMS_ACUERDOS_X_CLIENTE] [OWAXC] ON [OWAXC].[CLIENT_ID] = @CLIENT_CODE
        WHERE
            [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
            AND [DEMAND_TYPE] = 'TRANSFER_REQUEST';
		
		-- ------------------------------------------------------------------------------------
		-- Se inserta la poliza de recepcion general
		---- ------------------------------------------------------------------------------------
        INSERT  INTO @RESULT
                (
                 [Resultado]
                ,[Mensaje]
                ,[Codigo]
                ,[DbData]
				)
                EXEC [FERCO].[OP_WMS_SP_INSERT_RECEPTION_GENERAL_POLICY] @ORDER_NUM = @NUMERO_ORDEN, -- varchar(50)
                    @DOC_DATE = @FECHA_POLIZA, -- datetime
                    @LAST_UPDATED_BY = @LOGIN, -- varchar(50)
                    @CLIENT_CODE = @CLIENT_CODE, -- varchar(50)
                    @TRADE_AGREEMENT = @ACUERDO_COMERCIAL, -- varchar(50)
                    @INSURANCE_POLICY = NULL, -- varchar(50)
                    @ASSIGNED_TO = @LOGIN; -- varchar(50)

		-- ------------------------------------------------------------------------------------
		-- Obtiene codigo de poliza y elimina los registros de la tabla temporal
		-- ------------------------------------------------------------------------------------
        SELECT TOP 1
            @CODIGO_POLIZA = [DbData]
           ,@Resultado = [Resultado]
           ,@Mensaje = [Mensaje]
        FROM
            @RESULT;
				
		-- ------------------------------------------------------------------------------------
		-- Valida el resultado
		-- ------------------------------------------------------------------------------------
        IF @Resultado = -1
        BEGIN
            SET @Codigo = 1504;
            RAISERROR(@Mensaje,16,1);
            RETURN;
        END;
        ELSE
        BEGIN
            DELETE FROM
                @RESULT;
        END;
    

		-- ------------------------------------------------------------------------------------
		-- Vallida si el traslado es de ERP
		-- ------------------------------------------------------------------------------------
		IF EXISTS (SELECT MANIFEST_HEADER_ID FROM [FERCO].[OP_WMS_MANIFEST_HEADER] [MH]
						INNER JOIN [FERCO].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH] ON [MH].[TRANSFER_REQUEST_ID] = [TRH].[TRANSFER_REQUEST_ID]
					WHERE 
						[MH].[MANIFEST_HEADER_ID] = @MANIFEST_ID
						AND [TRH].[IS_FROM_ERP] = 1)
		-- ------------------------------------------------------------------------------------
		-- Inserta la tarea de recepcion por traslado
		-- ------------------------------------------------------------------------------------
		BEGIN
			INSERT  INTO @RESULT
                (
                 [Resultado]
                ,[Mensaje]
                ,[Codigo]
                ,[DbData]
				)
                EXEC [FERCO].[OP_WMS_SP_INSERT_TASK_RECEPTION_ERP] @TASK_SUBTYPE = 'RECEPCION_TRASLADO', -- varchar(25)
                    @TASK_OWNER = @LOGIN, -- varchar(25)
                    @TASK_ASSIGNEDTO = @LOGIN, -- varchar(25)
                    @TASK_COMMENTS = '', -- varchar(150)
                    @REGIMEN = 'GENERAL', -- varchar(50)
                    @CLIENT_OWNER = @CLIENT_CODE, -- varchar(25)
                    @CLIENT_NAME = @CLIENT_NAME, -- varchar(150)
                    @CODIGO_POLIZA_SOURCE = @CODIGO_POLIZA, -- varchar(25)
                    @DOC_ID_SOURCE = @CODIGO_POLIZA, -- numeric
                    @PRIORITY = 2, -- int
                    @IS_FROM_ERP = 1, -- int
                    @LOCATION_SPOT_TARGET = '', -- varchar(25)
                    @OWNER = '', -- varchar(50)
                    @TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID;
		END
		ELSE BEGIN
			INSERT  INTO @RESULT
					(
					 [Resultado]
					,[Mensaje]
					,[Codigo]
					,[DbData]
					)
					EXEC [FERCO].[OP_WMS_SP_INSERT_TASK_RECEPTION_ERP] @TASK_SUBTYPE = 'RECEPCION_TRASLADO', -- varchar(25)
						@TASK_OWNER = @LOGIN, -- varchar(25)
						@TASK_ASSIGNEDTO = @LOGIN, -- varchar(25)
						@TASK_COMMENTS = '', -- varchar(150)
						@REGIMEN = 'GENERAL', -- varchar(50)
						@CLIENT_OWNER = @CLIENT_CODE, -- varchar(25)
						@CLIENT_NAME = @CLIENT_NAME, -- varchar(150)
						@CODIGO_POLIZA_SOURCE = @CODIGO_POLIZA, -- varchar(25)
						@DOC_ID_SOURCE = @CODIGO_POLIZA, -- numeric
						@PRIORITY = 2, -- int
						@IS_FROM_ERP = 0, -- int
						@LOCATION_SPOT_TARGET = '', -- varchar(25)
						@OWNER = '', -- varchar(50)
						@TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID;
		END
		-- ------------------------------------------------------------------------------------
		-- Obtiene el ID de la tarea
		-- ------------------------------------------------------------------------------------
        SELECT TOP 1
            @TASK_ID = [DbData]
           ,@Resultado = [Resultado]
           ,@Mensaje = [Mensaje]
        FROM
            @RESULT;
				
		-- ------------------------------------------------------------------------------------
		-- Valida el resultado
		-- ------------------------------------------------------------------------------------
        IF @Resultado = -1
        BEGIN
            SET @Codigo = 1505;
            RAISERROR(@Mensaje,16,1);
            RETURN;
        END;
		
		-- ------------------------------------------------------------------------------------
		-- Inserta el encabezado del documento de recepcion
		-- ------------------------------------------------------------------------------------
        INSERT  INTO [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
                (
                 [DOC_ID]
                ,[TYPE]
                ,[CODE_SUPPLIER]
                ,[CODE_CLIENT]
                ,[ERP_DATE]
                ,[LAST_UPDATE]
                ,[LAST_UPDATE_BY]
                ,[ATTEMPTED_WITH_ERROR]
                ,[IS_POSTED_ERP]
                ,[POSTED_ERP]
                ,[POSTED_RESPONSE]
                ,[ERP_REFERENCE]
                ,[IS_AUTHORIZED]
                ,[IS_COMPLETE]
                ,[TASK_ID]
                ,[EXTERNAL_SOURCE_ID]
                ,[ERP_REFERENCE_DOC_NUM]
                ,[DOC_NUM]
                ,[NAME_SUPPLIER]
                ,[OWNER]
                ,[IS_FROM_WAREHOUSE_TRANSFER]
                ,[IS_FROM_ERP]
                ,[DOC_ID_POLIZA]
				,[ERP_WAREHOUSE_CODE]
				,[SOURCE]
				)
        SELECT
            [MANIFEST_HEADER_ID]
           ,'RECEPCION_TRASLADO'
           ,NULL
           ,NULL
           ,NULL
           ,GETDATE()
           ,@LOGIN
           ,0
           ,0
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,0
           ,@TASK_ID
           ,NULL
           ,NULL
           ,@MANIFEST_ID
           ,NULL
           ,[DH].[OWNER]
           ,1
           ,[DH].[IS_FROM_ERP]
           ,CAST(@CODIGO_POLIZA AS NUMERIC)
		   ,ISNULL([W].[ERP_WAREHOUSE], NULL)
		   ,'ERP_TRANSFER'
        FROM
            [FERCO].[OP_WMS_MANIFEST_HEADER] [MH]
        INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[TRANSFER_REQUEST_ID] = [MH].[TRANSFER_REQUEST_ID]
                                                              AND [DH].[DEMAND_TYPE] = 'TRANSFER_REQUEST'
		INNER JOIN [FERCO].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH] ON [TRH].[TRANSFER_REQUEST_ID] = [MH].[TRANSFER_REQUEST_ID]
		INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] [W] ON [W].[WAREHOUSE_ID] = [TRH].[WAREHOUSE_TO] 
        WHERE
            [MANIFEST_HEADER_ID] = @MANIFEST_ID;
		--
        SET @ID = SCOPE_IDENTITY();
		
		-- ------------------------------------------------------------------------------------
		-- Inserta el detalle del documento de recepcion
		-- ------------------------------------------------------------------------------------
        INSERT  INTO [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL]
                (
                 [ERP_RECEPTION_DOCUMENT_HEADER_ID]
                ,[MATERIAL_ID]
                ,[QTY]
                ,[LINE_NUM]
				,[WAREHOUSE_CODE]
				)
        SELECT
            @ID
           ,[MD].[MATERIAL_ID]
           ,[MD].[QTY]
           ,[DD].[LINE_NUM]
		   ,ISNULL([W].[ERP_WAREHOUSE], NULL)
        FROM
            [FERCO].[OP_WMS_MANIFEST_DETAIL] [MD]
        INNER JOIN [FERCO].[OP_WMS_MANIFEST_HEADER] [MH] ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
        INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON MD.WAVE_PICKING_ID = DH.WAVE_PICKING_ID
                                                              AND [DH].[DEMAND_TYPE] = 'TRANSFER_REQUEST'
        INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD] ON [DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID]
                                                              AND [DD].[MATERIAL_ID] = [MD].[MATERIAL_ID] 
															  AND [MD].[LINE_NUM] = [DD].[LINE_NUM]
        INNER JOIN [FERCO].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH] ON [TRH].[TRANSFER_REQUEST_ID] = [MH].[TRANSFER_REQUEST_ID]
		INNER JOIN [FERCO].[OP_WMS_WAREHOUSES] [W] ON [W].[WAREHOUSE_ID] = [TRH].[WAREHOUSE_TO] 
		WHERE
            [MD].[MANIFEST_HEADER_ID] = @MANIFEST_ID;
		--
        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,CAST('TRANSFER_REQUEST|' + ISNULL(@CODIGO_POLIZA, ' ') + '|'
            + ISNULL(@NUMERO_ORDEN, ' ') + '|'
            + CAST(ISNULL(@TASK_ID, 0) AS VARCHAR(20)) AS VARCHAR(100)) [DbData];
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,@Codigo [Codigo];
    END CATCH;
END;
