-- =============================================
-- Autor:				Elder Lucas
-- Fecha de Creacion: 	2021.06.03
-- Description:	        Libera transacción por operación manual en ERP

/*
-- Ejemplo de Ejecucion:
         exec ferco.OP_WMS_SP_UNLOCK_TRANSACTION @TASK_ID=50505050,@REFERENCE=N' ',@REASON=N'EJECUCION_MANUAL',@LOGIN=N'ADMIN'
*/
CREATE PROCEDURE [FERCO].[OP_WMS_SP_UNLOCK_TRANSACTION] (
		@TASK_ID INT
		,@REFERENCE VARCHAR(30)
		,@REASON VARCHAR(200)
		,@LOGIN VARCHAR(100)
	)
AS
BEGIN

DECLARE @MESSAGE VARCHAR (200),
		@ERROR_CODE INT
	--
	PRINT ''

	BEGIN TRY
		
		IF EXISTS (SELECT TOP 1 1 FROM FERCO.OP_WMS_TASK_LIST TL INNER JOIN FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER PDH ON TL.WAVE_PICKING_ID = PDH.WAVE_PICKING_ID WHERE TL.SERIAL_NUMBER = @TASK_ID)
		BEGIN
			UPDATE FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER SET 
				IS_POSTED_ERP = 1,
				LAST_UPDATE_BY = @LOGIN,
				LAST_UPDATE = GETDATE(),
				POSTED_RESPONSE = 'Ejecución manual en ERP'
			WHERE WAVE_PICKING_ID IN 
			(
				SELECT WAVE_PICKING_ID FROM FERCO.OP_WMS_TASK_LIST WHERE SERIAL_NUMBER = @TASK_ID
			)

			SELECT @MESSAGE = 'Proceso Exitoso',
				   @ERROR_CODE = 1
		END
		ELSE
			
		BEGIN
		
			SELECT @MESSAGE = 'La tarea no existe o no está asociada a una tarea de picking',
				   @ERROR_CODE = -1

		END
		SELECT
			@ERROR_CODE AS [Resultado]
			,@MESSAGE AS [Mensaje]
			,1 AS [Codigo]
			,'' AS [DbData];
	END TRY
	BEGIN CATCH
	ROLLBACK;
		--
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH
END;
