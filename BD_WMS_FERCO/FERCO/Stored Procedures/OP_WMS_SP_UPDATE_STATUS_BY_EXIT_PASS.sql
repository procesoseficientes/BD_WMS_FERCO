-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	22-Nov-2017 @ Reborn-Team Sprint Nach
-- Description:			Sp que actualiza el estado del pase de salida.

-- Autor:				fabrizio.delcompare
-- Fecha de Creacion: 	10-Jun-2020
-- Description:			Agrega opción de cerrar ordenes de entrega en SAP ERP

-- Autor:				Gildardo.Alvarado
-- Fecha de Creacion: 	05-Ene-2021
-- Description:			Agrega SP para tomar en cuenta las ordenes que vienen del consolidado 
--						[OP_WMS_SP_MARK_DELIVERY_ORDER_AS_SEND_TO_ERP] y corregir la mala 
--						inserción de datos para las entregas preliminares o Delivery Order

-- Modificación:		Elder Lucas
-- Fecha de Creacion: 	06-Jun-2021
-- Description:			Agrega campo ATTEMPED_WHIT_ERROR al SP [OP_WMS_SP_MARK_DELIVERY_ORDER_AS_SEND_TO_ERP]
--						para registrar error en las olas de picking en caso estas no se hayan enviado

-- Modificación:		Elder Lucas
-- Fecha de Creacion: 	01-Jun-2022
-- Description:			Se completan automaticamente las tareas de traslado donde la bodega de destino no ha implementado wms

-- Modificación:		Elder Lucas
-- Fecha de Creacion: 	08-Jun-2022
-- Description:			Se cambia la manera de actualizar las licencias de despacho para que sea por wave picking

/*
-- Ejemplo de Ejecucion:
				
				EXEC [FERCO].[OP_WMS_SP_UPDATE_STATUS_BY_EXIT_PASS] @PASS_ID = 11
                                                      ,@STATUS = 'CREATED'
                                                      ,@LOGIN = 'ADMIN'
				
				
*/
-- =============================================  
CREATE PROCEDURE [FERCO].[OP_WMS_SP_UPDATE_STATUS_BY_EXIT_PASS]
(
    @PASS_ID INT,
    @STATUS VARCHAR(25),
    @LOGIN VARCHAR(25),
	@ERP_REF INT,
	@ATTEMPED_WHIT_ERROR INT
)
AS
BEGIN
    SET NOCOUNT ON;
    --
    BEGIN TRY

        DECLARE @TB_WAVE_PICKING TABLE
        (
            [WAVE_PICKING_ID] INT
			,[DOC_NUM] INT
        );
		DECLARE @WAVE_PICKING TABLE 
		(
			ID INT IDENTITY(1,1),
			WAVE_PICKING INT
		);

        DECLARE @STATUS_OLD VARCHAR(25),
				@counter int  = 0,
				@CURRENT_WAVE_PICKING INT = 0;

        SELECT @STATUS_OLD = [STATUS]
        FROM [FERCO].[OP_WMS3PL_PASSES]
        WHERE [PASS_ID] = @PASS_ID;

		PRINT @STATUS_OLD;
		PRINT @STATUS;

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

        BEGIN
			PRINT 'ENTERED!';
            IF @STATUS = 'FINALIZED'
            BEGIN
				PRINT 'ENTERED 2!';
                INSERT @TB_WAVE_PICKING
				(
					[WAVE_PICKING_ID]
					,[DOC_NUM]
				)
				SELECT
					[PD].[WAVE_PICKING_ID]
					,[PD].[DOC_NUM]
				FROM
					[FERCO].[OP_WMS_PASS_DETAIL] [PD]
				WHERE 
					[PD].[PASS_HEADER_ID] = @PASS_ID;

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
					PRINT 'ENTERED! 3';
					-- ------------------------------------------------------------------------------------
					-- ACTUALIZAR PARA DO - ERP la parte del ERP
					-- ------------------------------------------------------------------------------------
	
					-- EXEC [FERCO].[OP_WMS_SP_MARK_DELIVERY_ORDER_AS_SEND_TO_ERP] @PASS_ID = @PASS_ID;--, @ATTEMPED_WHIT_ERROR = @ATTEMPED_WHIT_ERROR;

					-- ------------------------------------------------------------------------------------
					-- ACTUALIZAR PARA EL RESTO DE ORDENES
					-- ------------------------------------------------------------------------------------
                    UPDATE [PH]
                    SET [PH].[IS_AUTHORIZED] = 1
                    FROM [FERCO].[OP_WMS_PASS_DETAIL] [PD]
                        INNER JOIN @TB_WAVE_PICKING [WP]
                            ON ([PD].[WAVE_PICKING_ID] = [WP].[WAVE_PICKING_ID])
                        INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PH]
                            ON [PH].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID]
                    WHERE [PH].[IS_POSTED_ERP] <= 0
                          AND [PH].[IS_AUTHORIZED] = 0;

					--IF (@TYPE = 'DO - ERP')
					--BEGIN					
					--	EXEC FERCO.OP_WMS_UPDATE_DELIVERY_ERP @DOC = @DOC_ENTRY, @PASS = @PASS_ID;
					--END;
			-- ------------------------------------------------------------------------------------
			-- Actualizamos el estado de las licensias que crea el despacho, en el Inventario en linea (OP_WMS_INV_X_LICENSE)
			-- ------------------------------------------------------------------------------------
					--SELECT 
					--	[IL].LICENSE_ID 
					--INTO 
					--	#TEMP
					--FROM
					--	[FERCO].[OP_WMS_PASS_DETAIL] [PD] 
					--	INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [TL] ON ([TL].[WAVE_PICKING_ID] = [PD].[WAVE_PICKING_ID])
					--	LEFT JOIN [FERCO].[OP_WMS_LICENSES] [L] ON ([L].[CODIGO_POLIZA] = [TL].[CODIGO_POLIZA_TARGET])
					--	INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
					--WHERE 
					--	PD.PASS_HEADER_ID = @PASS_ID 
					--GROUP BY
					--	[IL].[LICENSE_ID],
					--	[IL].[MATERIAL_NAME]


					--			--  SE INDENTIFICAN LAS TAREAS DE PICKING QUE APLICAN PARA TAREA DE RECTIFICACIÓN Y SE CREAN SI ES NECESARIO
					IF(@STATUS='FINALIZED')
					BEGIN
						INSERT INTO @WAVE_PICKING
						SELECT DISTINCT [PD].[WAVE_PICKING_ID]
						FROM [FERCO].[OP_WMS_PASS_DETAIL] [PD]
						WHERE [PD].[PASS_HEADER_ID] = @PASS_ID;


					--Inicia ciclo por wave picking
					while (@counter < (select COUNT(*) from @WAVE_PICKING) +1)
						begin
						SET @CURRENT_WAVE_PICKING = (SELECT WAVE_PICKING FROM  @WAVE_PICKING WHERE ID = @counter)--Se escoge el wave picking a trabajar
						PRINT @CURRENT_WAVE_PICKING
						--Se marcan como enviadas todas las tareas de picking por traslado cuyas bodegas de origen no usen wms
						IF EXISTS(SELECT TOP 1 1 FROM FERCO.OP_WMS_WAREHOUSES W
												INNER JOIN FERCO.OP_WMS_TRANSFER_REQUEST_HEADER TRH ON TRH.WAREHOUSE_TO = W.WAREHOUSE_ID
												INNER JOIN FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER PDH ON PDH.TRANSFER_REQUEST_ID = TRH.TRANSFER_REQUEST_ID
												WHERE PDH.WAVE_PICKING_ID = @CURRENT_WAVE_PICKING AND W.IMPLEMENTS_WMS = 0
												)
									 BEGIN
													UPDATE FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER SET
													IS_POSTED_ERP = 1,
													IS_COMPLETED = 1,
													IS_FROM_ERP = 1,
													IS_AUTHORIZED = 0,
													POSTED_RESPONSE = 'Completación automática, bodega de destino no usa wms, usuario:' + @LOGIN
													WHERE WAVE_PICKING_ID = @CURRENT_WAVE_PICKING
									 END
									 --Se valida si la tarea requiere rectificación y se crea su tarea de rectificación
							 --IF EXISTS (SELECT top 1 1 FROM FERCO.OP_WMS_TASK_LIST A WHERE WAVE_PICKING_ID = @CURRENT_WAVE_PICKING and FROM_MASTERPACK = 1 and QUANTITY_ASSIGNED > 0 
							 --AND SOURCE_TYPE in ('SO - ERP', 'WT - ERP') group by WAVE_PICKING_ID, MATERIAL_ID, BARCODE_ID, MATERIAL_NAME, CODIGO_POLIZA_TARGET HAVING SUM(QUANTITY_PENDING) != 0)
								--  BEGIN TRY
								--	PRINT 'SE CREARÁ TAREA DE RECTIFICACIÓN'
								--	 exec ferco.OP_WMS_SP_CREATE_MP_RECTIFICATION_TASK @WAVE_PICKING_ID=@CURRENT_WAVE_PICKING ,@LOGIN= @LOGIN
								--  END TRY
								--	BEGIN CATCH
								--		SELECT -1 AS [Resultado],
								--			   ERROR_MESSAGE() [Mensaje],
								--			   @@ERROR [Codigo];
								--	END CATCH;

							--Escogemos las licencias que se marcarán como despachadas por cada wave picking
							--SELECT DISTINCT CODIGO_POLIZA_TARGET INTO #POLIZAS FROM FERCO.OP_WMS_TASK_LIST WHERE WAVE_PICKING_ID = @CURRENT_WAVE_PICKING
									
							--SELECT distinct L.LICENSE_ID into #LICENSES_TO_DISPATCH
							--FROM FERCO.OP_WMS_LICENSES L 
							--INNER JOIN FERCO.OP_WMS_INV_X_LICENSE IXL ON L.LICENSE_ID = IXL.LICENSE_ID 
							--INNER JOIN #POLIZAS P ON L.CODIGO_POLIZA = P.CODIGO_POLIZA_TARGET
							----INNER JOIN FERCO.OP_WMS_COMPONENTS_BY_MASTER_PACK CMP ON IXL.MATERIAL_ID = CMP.COMPONENT_MATERIAL 
							--WHERE IXL.STATUS <> 'DISPATCH'

							----actualizamos las licencias

							UPDATE IXL SET
							IXL.STATUS = 'DISPATCH'
							from ferco.OP_WMS_INV_X_LICENSE IXL
							INNER JOIN FERCO.OP_WMS_LICENSES L
								ON L.LICENSE_ID = IXL.LICENSE_ID
							WHERE L.WAVE_PICKING_ID = @CURRENT_WAVE_PICKING

							--UPDATE [IL]
							--SET
							--	IL.STATUS = 'DISPATCH'
							--FROM
							--	[FERCO].[OP_WMS_INV_X_LICENSE] [IL] 
							--	INNER JOIN #LICENSES_TO_DISPATCH LTD ON LTD.LICENSE_ID = IL.LICENSE_ID
							--WHERE
							--	IL.STATUS <> 'DISPATCH' 

							----Borramos las tablas para no redundar en el update
							--DROP TABLE #LICENSES_TO_DISPATCH
							--DROP TABLE #POLIZAS
							SELECT  @counter = @counter + 1 --aumentamos el índice
						end
					END
		
					--UPDATE [IL]
					--SET
					--	IL.STATUS = 'DISPATCH'
					--FROM
					--	[FERCO].[OP_WMS_INV_X_LICENSE] [IL] 
					--	INNER JOIN #TEMP #T ON (#T.LICENSE_ID = IL.LICENSE_ID)
					--WHERE
					--	IL.STATUS <> 'DISPATCH' 

					
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