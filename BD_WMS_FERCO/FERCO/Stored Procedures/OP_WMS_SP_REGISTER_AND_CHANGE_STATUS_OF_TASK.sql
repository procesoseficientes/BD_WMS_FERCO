﻿-- =============================================
-- Autor:             rudi.garcia
-- Fecha de Creacion: 20-Aug-2018 G-Force@Humano
-- Description:       Se crea SP para registrar y cambiar el estado de tareas de recepción

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181010 GForce@Langosta
-- Description:			Se modifica para que filtre las licencias de despacho por operador

-- Autor:				denis.villagran
-- Fecha de Creacion: 	2020-Jan-26 GForce@Oklahoma-Swift
-- Description:			Se modifica para que cree la licencia con régimen general cuando se 
--                      realiza traslado general. Se agrega campo CREATED_DATE a la licencia
--						de despacho

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	08-Abril-2020 GForce@Paris
-- Description:			Se agrega validacion al momento de insertar el registro en la tabla trans para 
--						el traslado general

-- Autor:				Brandon Sicay
-- Fecha de Creacion: 	20-Enero-2022 
-- Description:			Se cambió condición de SERIAL_NUMBER por MATERIAL_ID para corregir campo vacio 
--						en ASSIGNED_DATE al cambiar de licencia. 

--exec sp_executesql @statement=N'ferco.OP_WMS_SP_REGISTER_AND_CHANGE_STATUS_OF_TASK @pTRANS_TYPE = N''DESPACHO_ALMGEN'', @pLOGIN_ID = N''2010'', @pCODIGO_POLIZA = N''1057360'', @pTASK_ID =5171998,@pSTATUS = N''ACCEPTED'', @pCOMPLETE_TASK = 0'


-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_REGISTER_AND_CHANGE_STATUS_OF_TASK]
(
    @pTRANS_TYPE VARCHAR(25),
    @pLOGIN_ID VARCHAR(25),
    @pCODIGO_POLIZA VARCHAR(25),
    @pTASK_ID NUMERIC(18, 0),
    @pSTATUS VARCHAR(25),
    @pCOMPLETE_TASK BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MATERIAL TABLE
    (
        [TRANSFER_REQUEST_ID] INT NOT NULL,
        [MATERIAL_ID] VARCHAR(50) NOT NULL,
        [QTY] NUMERIC(18, 6) NOT NULL,
        PRIMARY KEY (
                        [TRANSFER_REQUEST_ID],
                        [MATERIAL_ID]
                    )
    );

    DECLARE @WAVE_PICKING_ID INT,
            @DOC_ID INT,
            @AUTOMATIC_AUTHORIZATION INT = 0,
            @TRANSFER_REQUEST_ID INT,
            @TRANSFER_REQUEST_OPEN_STATUS VARCHAR(25) = 'OPEN',
            @TRANSFER_REQUEST_CLOSED_STATUS VARCHAR(25) = 'CLOSED',
            @TASK_SUB_TYPE VARCHAR(25),
			@MATERIAL_ID AS VARCHAR(50),
            @LICESE_ID INT = NULL;
			

    BEGIN TRAN;
    BEGIN TRY
        -- ---------------------------------------------------
        -- Obtiene valores iniciales
        -- ---------------------------------------------------
        SELECT TOP 1
               @AUTOMATIC_AUTHORIZATION = 1
        FROM [FERCO].[OP_WMS_CONFIGURATIONS] [C]
        WHERE [C].[PARAM_TYPE] = 'SISTEMA'
              AND [C].[PARAM_GROUP] = 'RECEPCION'
              AND [C].[PARAM_NAME] = 'AUTORIZACION_AUTOMATICA_RECEPCION'
              AND [C].[NUMERIC_VALUE] = 1;

			  
        SELECT @WAVE_PICKING_ID = [T].[WAVE_PICKING_ID],
				@MATERIAL_ID = [T].[MATERIAL_ID],
               @TRANSFER_REQUEST_ID = [T].[TRANSFER_REQUEST_ID],
               @TASK_SUB_TYPE = [T].[TASK_SUBTYPE]
        FROM [FERCO].[OP_WMS_TASK_LIST] [T]
        WHERE [T].[SERIAL_NUMBER] = @pTASK_ID;

        -- ------------------------------------------------------------------------------------
        -- Valida si la tarea no ha sido reasignada
        -- ------------------------------------------------------------------------------------
        IF @pSTATUS = 'COMPLETED'
           AND NOT EXISTS
        (
            SELECT TOP 1
                   1
            FROM [FERCO].[OP_WMS_TASK_LIST] [TL]
            WHERE [TL].[SERIAL_NUMBER] = @pTASK_ID
                  AND @pLOGIN_ID = [TL].[TASK_ASSIGNEDTO]
        )
        BEGIN
            RAISERROR('Tarea ya fue asignada a otro operador.', 16, 1);
        END;
        ELSE
        BEGIN
            -- ------------------------------------------------------------------------------------
            -- Valida si la tarea fue completada
            -- ------------------------------------------------------------------------------------
            IF @pSTATUS = 'COMPLETED'
               OR NOT EXISTS
            (
                SELECT TOP 1
                       1
                FROM [FERCO].[OP_WMS_TASK_LIST]
                WHERE [SERIAL_NUMBER] = @pTASK_ID
                      AND [IS_ACCEPTED] = 1
            )
            BEGIN
                -- ------------------------------------------------------------------------------------
                -- Genera la transaccion de completado
                -- ------------------------------------------------------------------------------------
                INSERT INTO [FERCO].[OP_WMS_TRANS]
                (
                    [TRANS_DATE],
                    [LOGIN_ID],
                    [LOGIN_NAME],
                    [TRANS_TYPE],
                    [TRANS_DESCRIPTION],
                    [TRANS_EXTRA_COMMENTS],
                    [CLIENT_OWNER],
                    [CLIENT_NAME],
                    [CODIGO_POLIZA],
                    [STATUS],
                    [TASK_ID],
                    [MATERIAL_BARCODE],
                    [MATERIAL_CODE],
                    [QUANTITY_UNITS],
                    [SOURCE_LOCATION],
                    [TARGET_LOCATION]
                )
                SELECT GETDATE() AS [TRANS_DATE],
                       @pLOGIN_ID AS [LOGIN_ID],
                       (
                           SELECT TOP 1
                                  [LOGIN_NAME]
                           FROM [FERCO].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID)
                       ) AS [LOGIN_NAME],
                       CASE
                           WHEN @WAVE_PICKING_ID IS NULL THEN
                               @pTRANS_TYPE
                           WHEN @WAVE_PICKING_ID IS NOT NULL
                                AND @pTRANS_TYPE = 'INGRESO_FISCAL' THEN
                               'DESPACHO_FISCAL'
                           WHEN @WAVE_PICKING_ID IS NOT NULL
                                AND @pTRANS_TYPE = 'INGRESO_GENERAL' THEN
                               'DESPACHO_GENERAL'
                           WHEN @WAVE_PICKING_ID IS NULL
                                AND @pTRANS_TYPE = 'TRASLADO_GENERAL' THEN
                               'INGRESO_GENERAL'
                           ELSE
                               @pTRANS_TYPE
                       END AS [TRANS_TYPE],
                       [owtl].[TASK_COMMENTS] [TRANS_DESCRIPTION],
                       'N/A' AS [TRANS_EXTRA_COMMENTS],
                       [owtl].[CLIENT_OWNER],
                       [owtl].[CLIENT_NAME],
                       @pCODIGO_POLIZA AS [CODIGO_POLIZA],
                       @pSTATUS AS [STATUS],
                       [owtl].[SERIAL_NUMBER],
                       '' AS [MATERIAL_BARCODE],
                       '' AS [MATERIAL_CODE],
                       0 AS [QUANTITY_UNITS],
                       '' AS [SOURCE_LOCATION],
                       '' AS [TARGET_LOCATION]
                FROM [FERCO].[OP_WMS_TASK_LIST] [owtl]
                WHERE [owtl].[SERIAL_NUMBER] = @pTASK_ID;

                -- ------------------------------------------------------------------------------------
                -- Si es aceptada la tarea
                -- ------------------------------------------------------------------------------------
                IF @pSTATUS = 'ACCEPTED'
                BEGIN
                    PRINT @WAVE_PICKING_ID;
                    --
                    IF NOT @WAVE_PICKING_ID IS NULL
                    BEGIN
                        -- ------------------------------------------------------------------------------------
                        -- Actualizamos las tareas de la ola asignadas al operador en cuestion
                        -- ------------------------------------------------------------------------------------
                        PRINT 'entro a crear licencia despacho';
                        UPDATE [FERCO].[OP_WMS_TASK_LIST]
                        SET [IS_ACCEPTED] = 1,
                            [ACCEPTED_DATE] = GETDATE()
                        WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
                              AND [TASK_ASSIGNEDTO] = @pLOGIN_ID 
							  AND [MATERIAL_ID] = @MATERIAL_ID 

                    END;
                    ELSE
                    BEGIN
                        UPDATE [FERCO].[OP_WMS_TASK_LIST]
                        SET [IS_ACCEPTED] = 1,
                            [ACCEPTED_DATE] = GETDATE()
						WHERE [MATERIAL_ID] = @MATERIAL_ID;
                        --WHERE [SERIAL_NUMBER] = @pTASK_ID; 
                    END;
                END;

                -- ------------------------------------------------------------------------------------
                -- Si es completada la tarea
                -- ------------------------------------------------------------------------------------
                IF @pSTATUS = 'COMPLETED'
                BEGIN
                    UPDATE [FERCO].[OP_WMS_TASK_LIST]
                    SET [IS_COMPLETED] = 1,
                        [COMPLETED_DATE] = GETDATE()
                    WHERE [SERIAL_NUMBER] = @pTASK_ID;
                    --
                    UPDATE [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
                    SET [IS_AUTHORIZED] = CASE
                                              WHEN @TASK_SUB_TYPE = 'DEVOLUCION_FACTURA' THEN
                                                  0
                                              ELSE
                                                  @AUTOMATIC_AUTHORIZATION
                                          END
                    WHERE [TASK_ID] = @pTASK_ID;

                    -- ------------------------------------------------------------------------------------
                    -- Valida si completo su tarea de recepción de ERP
                    -- ------------------------------------------------------------------------------------
                    SELECT TOP 1
                           @DOC_ID = [H].[DOC_ID]
                    FROM [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
                        INNER JOIN [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D]
                            ON [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
                        INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [T]
                            ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
                        LEFT JOIN [FERCO].[OP_WMS_LICENSES] [L]
                            ON [L].[CODIGO_POLIZA] = [T].[CODIGO_POLIZA_SOURCE]
                        LEFT JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL]
                            ON (
                                   [IL].[LICENSE_ID] = [L].[LICENSE_ID]
                                   AND [D].[MATERIAL_ID] = [IL].[MATERIAL_ID]
                               )
                    WHERE [H].[TASK_ID] = @pTASK_ID
                          AND [D].[ERP_RECEPTION_DOCUMENT_DETAIL_ID] > 0
                    GROUP BY [H].[DOC_ID],
                             [D].[MATERIAL_ID]
                    HAVING ISNULL(SUM([IL].[ENTERED_QTY]), 0) <> MAX([D].[QTY]);

                    -- ------------------------------------------------------------------------------------
                    -- Obtiene el total de cada material recepcionado
                    -- ------------------------------------------------------------------------------------
                    INSERT INTO @MATERIAL
                    (
                        [TRANSFER_REQUEST_ID],
                        [MATERIAL_ID],
                        [QTY]
                    )
                    SELECT [T].[TRANSFER_REQUEST_ID],
                           [IL].[MATERIAL_ID],
                           SUM([IL].[ENTERED_QTY])
                    FROM [FERCO].[OP_WMS_INV_X_LICENSE] [IL]
                        INNER JOIN [FERCO].[OP_WMS_LICENSES] [L]
                            ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
                        INNER JOIN [FERCO].[OP_WMS_POLIZA_HEADER] [PH]
                            ON ([PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA])
                        LEFT JOIN [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
                            ON [H].[DOC_ID_POLIZA] = [PH].[DOC_ID]
                        LEFT JOIN [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D]
                            ON (
                                   [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
                                   AND [D].[MATERIAL_ID] = [IL].[MATERIAL_ID]
                               )
                        INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [T]
                            ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
                    WHERE [H].[TASK_ID] = @pTASK_ID
                          AND [T].[TRANSFER_REQUEST_ID] IS NOT NULL
                    GROUP BY [T].[TRANSFER_REQUEST_ID],
                             [IL].[MATERIAL_ID];

                    -- ------------------------------------------------------------------------------------
                    -- Actualiza el detalle de la solicitud de transferencia
                    -- ------------------------------------------------------------------------------------
                    UPDATE [TD]
                    SET [TD].[QTY_PROCESSED] = ([TD].[QTY_PROCESSED] + [M].[QTY]),
                        [TD].[STATUS] = CASE
                                            WHEN ([TD].[QTY_PROCESSED] + [M].[QTY]) >= [TD].[QTY] THEN
                                                @TRANSFER_REQUEST_CLOSED_STATUS
                                            ELSE
                                                @TRANSFER_REQUEST_OPEN_STATUS
                                        END
                    FROM [FERCO].[OP_WMS_TRANSFER_REQUEST_DETAIL] [TD]
                        INNER JOIN @MATERIAL [M]
                            ON (
                                   [M].[TRANSFER_REQUEST_ID] = [TD].[TRANSFER_REQUEST_ID]
                                   AND [M].[MATERIAL_ID] = [TD].[MATERIAL_ID]
                               )
                    WHERE [TD].[MATERIAL_ID] = [M].[MATERIAL_ID];
                    --
                    IF NOT EXISTS
                    (
                        SELECT TOP 1
                               1
                        FROM [FERCO].[OP_WMS_TRANSFER_REQUEST_DETAIL]
                        WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
                              AND [STATUS] = @TRANSFER_REQUEST_OPEN_STATUS
                    )
                    BEGIN
                        UPDATE [FERCO].[OP_WMS_TRANSFER_REQUEST_HEADER]
                        SET [STATUS] = @TRANSFER_REQUEST_CLOSED_STATUS
                        WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID;
                    END;

                    -- ------------------------------------------------------------------------------------
                    -- Abre la recepcion cuando es parcial
                    -- ------------------------------------------------------------------------------------
                    IF @DOC_ID IS NOT NULL
                       AND @WAVE_PICKING_ID IS NULL
                    BEGIN
                        UPDATE [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
                        SET [IS_COMPLETE] = 0
                        WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] > 0
                              AND [DOC_ID] = @DOC_ID;
                    END;
                END;
            END;
        END;

        IF @TASK_SUB_TYPE = 'TRASLADO_GENERAL'
           OR EXISTS
        (
            SELECT TOP 1
                   1
            FROM [FERCO].[OP_WMS_PARAMETER] [P]
            WHERE [P].[GROUP_ID] = 'PICKING'
                  AND [P].[PARAMETER_ID] = 'CREATE_LICENSE_IN_PICKING'
                  AND [P].[VALUE] = '1'
        )
        BEGIN
            -- ------------------------------------------------------------------------------------
            -- Se declaran las variables a utilizar
            -- ------------------------------------------------------------------------------------
            PRINT 'esta habilitado para crear licencia de despacho';
            DECLARE @LOCATION_SPOT_TARGET VARCHAR(25),
                    @CODIGO_POLIZA_TARGET VARCHAR(25),
                    @CLIENT_OWNER VARCHAR(25),
                    @REGIMEN VARCHAR(50),
                    @WAREHOUSE_TARGET VARCHAR(25);

            -- ------------------------------------------------------------------------------------
            -- Obtenemos la data necesaria para crear la licencia
            -- ------------------------------------------------------------------------------------

            SELECT TOP 1
                   @LOCATION_SPOT_TARGET = [TL].[LOCATION_SPOT_TARGET],
                   @CODIGO_POLIZA_TARGET = [TL].[CODIGO_POLIZA_TARGET],
                   @CLIENT_OWNER = [TL].[CLIENT_OWNER],
                   @REGIMEN = [TL].[REGIMEN]
            FROM [FERCO].[OP_WMS_TASK_LIST] [TL]
            WHERE [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;



            SELECT TOP 1
                   @WAREHOUSE_TARGET = [SS].[WAREHOUSE_PARENT]
            FROM [FERCO].[OP_WMS_SHELF_SPOTS] [SS]
            WHERE [SS].[LOCATION_SPOT] = @LOCATION_SPOT_TARGET;

            -- ------------------------------------------------------------------------------------
            -- Validamos si la ola de picking tiene una ubicacion destino y si la licencia no ha sido creada
            -- ------------------------------------------------------------------------------------

            IF NOT EXISTS
            (
                SELECT TOP 1
                       1
                FROM [FERCO].[OP_WMS_LICENSES] [L]
                WHERE [L].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
                      AND [L].[CURRENT_LOCATION] = @pLOGIN_ID
					  AND [L].[CODIGO_POLIZA] = @CODIGO_POLIZA_TARGET
            )
               AND @pCOMPLETE_TASK = 0
            BEGIN
                -- ------------------------------------------------------------------------------------
                -- Insertamos la licencia de la ola de picking
                -- ------------------------------------------------------------------------------------
                PRINT 'procede a crear licencia de despacho';
                INSERT INTO [FERCO].[OP_WMS_LICENSES]
                (
                    [CODIGO_POLIZA],
                    [CLIENT_OWNER],
                    [CURRENT_WAREHOUSE],
                    [CURRENT_LOCATION],
                    [LAST_LOCATION],
                    [LAST_UPDATED],
                    [LAST_UPDATED_BY],
                    [REGIMEN],
                    [WAVE_PICKING_ID],
                    [CREATED_DATE]
                )
                VALUES
                (@CODIGO_POLIZA_TARGET, @CLIENT_OWNER, @pLOGIN_ID, @pLOGIN_ID, NULL, GETDATE(), @pLOGIN_ID,
                 IIF(@TASK_SUB_TYPE = 'TRASLADO_GENERAL', 'GENERAL', @REGIMEN), @WAVE_PICKING_ID, GETDATE());

                SET @LICESE_ID = SCOPE_IDENTITY();
            END;
        END;

        IF @pCOMPLETE_TASK = 1
        BEGIN

            UPDATE [FERCO].[OP_WMS_TASK_LIST]
            SET [IS_COMPLETED] = 1
            WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
                  AND [TASK_ASSIGNEDTO] = @pLOGIN_ID;

            UPDATE [FERCO].[OP_WMS_LICENSES]
            SET 
			--[WAVE_PICKING_ID] = NULL,
                [STATUS] = 'ALLOCATED',
                [LAST_UPDATED] = GETDATE()
            WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
                  AND [REGIMEN] = 'GENERAL';
        END;

        IF @LICESE_ID IS NULL
        BEGIN
            SELECT TOP 1
                   @LICESE_ID = MAX([L].[LICENSE_ID])
            FROM [FERCO].[OP_WMS_LICENSES] [L]
            WHERE [L].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
                  AND [L].[CURRENT_LOCATION] = @pLOGIN_ID;
        END;

        COMMIT;
        SELECT 1 AS [Resultado],
               'Proceso Exitoso' [Mensaje],
               0 [Codigo],
               CAST(@LICESE_ID AS VARCHAR(18)) [DbData];
    END TRY
    BEGIN CATCH
        ROLLBACK;
        DECLARE @message VARCHAR(1000) = @@ERROR;
        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() [Mensaje],
               @@ERROR [Codigo];

        RAISERROR(@message, 16, 1);
    END CATCH;
END;
