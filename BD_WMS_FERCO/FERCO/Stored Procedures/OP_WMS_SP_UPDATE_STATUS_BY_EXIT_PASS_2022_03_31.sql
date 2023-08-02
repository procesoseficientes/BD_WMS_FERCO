-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	22-Nov-2017 @ Reborn-Team Sprint Nach
-- Description:			Sp que actualiza el estado del pase de salida.

/*
-- Ejemplo de Ejecucion:
				
				EXEC [FERCO].[OP_WMS_SP_UPDATE_STATUS_BY_EXIT_PASS] @PASS_ID = 11
                                                      ,@STATUS = 'CREATED'
                                                      ,@LOGIN = 'ADMIN'
				
				
*/
-- =============================================  
create PROCEDURE [FERCO].[OP_WMS_SP_UPDATE_STATUS_BY_EXIT_PASS_2022_03_31]
(
    @PASS_ID INT,
    @STATUS VARCHAR(25),
    @LOGIN VARCHAR(25),
	@ERP_REF INT = 0,
	@ATTEMPED_WHIT_ERROR INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
    --
    BEGIN TRY

        DECLARE @TB_WAVE_PICKING TABLE
        (
            [WAVE_PICKING_ID] INT
        );

        DECLARE @STATUS_OLD VARCHAR(25);

        SELECT @STATUS_OLD = [STATUS]
        FROM [FERCO].[OP_WMS3PL_PASSES]
        WHERE [PASS_ID] = @PASS_ID;



        UPDATE [FERCO].[OP_WMS3PL_PASSES]
        SET [STATUS] = @STATUS,
            [LAST_UPDATED_BY] = @LOGIN,
            [LAST_UPDATED] = GETDATE()
        WHERE [PASS_ID] = @PASS_ID;
        --


        IF EXISTS
        (
            SELECT TOP 1
                   1
            FROM [FERCO].[OP_WMS_PARAMETER] [P]
            WHERE [P].[GROUP_ID] = 'PICKING'
                  AND [P].[PARAMETER_ID] = 'CREATE_LICENSE_IN_PICKING'
                  AND [P].[VALUE] = '1'
        )
        --   AND EXISTS
        --(
        --    SELECT TOP 1
        --           1
        --    FROM [FERCO].[OP_WMS_PARAMETER] [P]
        --    WHERE [P].[GROUP_ID] = 'SYSTEM'
        --          AND [P].[PARAMETER_ID] = 'CLIENT_MOBILE_IS_ANDROID'
        --          AND [P].[VALUE] = '0'
        --)
        BEGIN
            IF @STATUS = 'FINALIZED'
            BEGIN

                INSERT @TB_WAVE_PICKING
                (
                    [WAVE_PICKING_ID]
                )
                SELECT [PD].[WAVE_PICKING_ID]
                FROM [FERCO].[OP_WMS_PASS_DETAIL] [PD]
                WHERE [PD].[PASS_HEADER_ID] = @PASS_ID;


                --UPDATE [IL]
                --SET [IL].[QTY] = [IL].[QTY] - [PD].[QTY]
                --FROM [FERCO].[OP_WMS_PASS_DETAIL] [PD]
                --    INNER JOIN [FERCO].[OP_WMS_LICENSES] [L]
                --        ON ([PD].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID])
                --    INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL]
                --        ON (
                --               [L].[LICENSE_ID] = [IL].[LICENSE_ID]
                --               AND [PD].[MATERIAL_ID] = [IL].[MATERIAL_ID]
                --           )
                --    INNER JOIN @TB_WAVE_PICKING [WP]
                --        ON ([PD].[WAVE_PICKING_ID] = [WP].[WAVE_PICKING_ID]);


                --UPDATE [t]
                --SET [DISPATCH_LICENSE_EXIT_BY] = @LOGIN,
                --    [DISPATCH_LICENSE_EXIT_DATETIME] = GETDATE(),
                --    [DISPATCH_LICENSE_EXIT_COMPLETED] = 1
                --FROM [FERCO].[OP_WMS_TASK_LIST] [t]
                --    INNER JOIN @TB_WAVE_PICKING [tb]
                --        ON [tb].[WAVE_PICKING_ID] = [t].[WAVE_PICKING_ID];


                --
                -- ------------------------------------------------------------------------------------
                -- obtenemos el parametro que nos indica si debemos autorizar en automatico para enviar a erp
                -- ------------------------------------------------------------------------------------
                DECLARE @AUTORIZE INT = 0;
                SELECT TOP 1
                       @AUTORIZE = CAST(ISNULL([NUMERIC_VALUE], 0) AS INT)
                FROM [FERCO].[OP_WMS_CONFIGURATIONS]
                WHERE [PARAM_TYPE] = 'SISTEMA'
                      AND [PARAM_GROUP] = 'DESPACHO'
                      AND [PARAM_NAME] = 'AUTORIZACION_AUTOMATICA_DESPACHO_LICENCIA';

					
                IF (@AUTORIZE = 1)
                BEGIN
                    UPDATE [PH]
                    SET [PH].[IS_AUTHORIZED] = 1
                    FROM [FERCO].[OP_WMS_PASS_DETAIL] [PD]
                        INNER JOIN @TB_WAVE_PICKING [WP]
                            ON ([PD].[WAVE_PICKING_ID] = [WP].[WAVE_PICKING_ID])
                        INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PH]
                            ON [PH].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID]
                    WHERE [PH].[IS_POSTED_ERP] <= 0
                          AND [PH].[IS_AUTHORIZED] = 0;
                END;

            END;
            ELSE IF @STATUS_OLD = 'FINALIZED'
                    AND @STATUS = 'CANCELED'
            BEGIN


                INSERT @TB_WAVE_PICKING
                (
                    [WAVE_PICKING_ID]
                )
                SELECT [PD].[WAVE_PICKING_ID]
                FROM [FERCO].[OP_WMS_PASS_DETAIL] [PD]
                WHERE [PD].[PASS_HEADER_ID] = @PASS_ID;


                --UPDATE [IL]
                --SET [IL].[QTY] = [IL].[QTY] + [PD].[QTY]
                --FROM [FERCO].[OP_WMS_PASS_DETAIL] [PD]
                --    INNER JOIN [FERCO].[OP_WMS_LICENSES] [L]
                --        ON ([PD].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID])
                --    INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL]
                --        ON (
                --               [L].[LICENSE_ID] = [IL].[LICENSE_ID]
                --               AND [PD].[MATERIAL_ID] = [IL].[MATERIAL_ID]
                --           )
                --    INNER JOIN @TB_WAVE_PICKING [WP]
                --        ON ([PD].[WAVE_PICKING_ID] = [WP].[WAVE_PICKING_ID]);
            END;
        END;

        SELECT 1 AS [Resultado],
               'Proceso Exitoso' [Mensaje],
               0 [Codigo],
               CAST(@PASS_ID AS VARCHAR) [DbData];


    END TRY
    BEGIN CATCH
        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() [Mensaje],
               @@ERROR [Codigo];
    END CATCH;

END;


