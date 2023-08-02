-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	22-Nov-2017 @ Reborn-Team Sprint Nach
-- Description:			Sp que actualiza el estado del pase de salida.

/*
-- Ejemplo de Ejecucion:
				
				EXEC [ferco].[OP_WMS_SP_UPDATE_STATUS_BY_EXIT_PASS] @PASS_ID = 11
                                                      ,@STATUS = 'CREATED'
                                                      ,@LOGIN = 'ADMIN'
				
				
*/
-- =============================================  
CREATE PROCEDURE [FERCO].[OP_WMS_SP_UPDATE_STATUS_BY_EXIT_PASS_1] (
		@PASS_ID INT
		,@STATUS VARCHAR(25)
		,@LOGIN VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	BEGIN TRY
	
		DECLARE	@TB_WAVE_PICKING TABLE ([WAVE_PICKING_ID] INT);

		DECLARE	@STATUS_OLD VARCHAR(25);

		SELECT
			@STATUS_OLD = [STATUS]
		FROM
			[ferco].[OP_WMS3PL_PASSES]
		WHERE
			[PASS_ID] = @PASS_ID;


		UPDATE
			[ferco].[OP_WMS3PL_PASSES]
		SET	
			[STATUS] = @STATUS
			,[LAST_UPDATED_BY] = @LOGIN
			,[LAST_UPDATED] = GETDATE()
		WHERE
			[PASS_ID] = @PASS_ID;
    --


		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[ferco].[OP_WMS_PARAMETER] [P]
					WHERE
						[P].[GROUP_ID] = 'PICKING'
						AND [P].[PARAMETER_ID] = 'CREATE_LICENSE_IN_PICKING'
						AND [P].[VALUE] = '1' )
		BEGIN
			IF @STATUS = 'FINALIZED'
			BEGIN

				INSERT	@TB_WAVE_PICKING
						(
							[WAVE_PICKING_ID]
						)
				SELECT
					[PD].[WAVE_PICKING_ID]
				FROM
					[ferco].[OP_WMS_PASS_DETAIL] [PD]
				WHERE
					[PD].[PASS_HEADER_ID] = @PASS_ID;


				UPDATE
					[IL]
				SET	
					[IL].[QTY] = 0
				FROM
					[ferco].[OP_WMS_LICENSES] [L]
				INNER JOIN [ferco].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[L].[LICENSE_ID] = [IL].[LICENSE_ID]											
											)
				INNER JOIN @TB_WAVE_PICKING [WP] ON ([L].[WAVE_PICKING_ID] = [WP].[WAVE_PICKING_ID]);
			END;
			ELSE
				IF @STATUS_OLD = 'FINALIZED'
					AND @STATUS = 'CANCELED'
				BEGIN


					INSERT	@TB_WAVE_PICKING
							(
								[WAVE_PICKING_ID]
							)
					SELECT
						[PD].[WAVE_PICKING_ID]
					FROM
						[ferco].[OP_WMS_PASS_DETAIL] [PD]
					WHERE
						[PD].[PASS_HEADER_ID] = @PASS_ID;


					UPDATE
						[IL]
					SET	
						[IL].[QTY] = 0
					FROM
						[ferco].[OP_WMS_LICENSES] [L]
					INNER JOIN [ferco].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[L].[LICENSE_ID] = [IL].[LICENSE_ID]
											)
					INNER JOIN @TB_WAVE_PICKING [WP] ON ([L].[WAVE_PICKING_ID] = [WP].[WAVE_PICKING_ID]);
				END;
		END;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@PASS_ID AS VARCHAR) [DbData];


	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;

END;

  

