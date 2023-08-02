-- =============================================
-- Autor:				Elder Lucas
-- Fecha de Creacion: 	2021.07.09
-- Description:	        SP que en teoría debería crear una tarea de reubicación parcial en base a las licencias de despacho del material
--						sobrante del kit
/*
-- Ejemplo de Ejecucion:
        
*/
CREATE PROCEDURE [FERCO].[OP_WMS_SP_CREATE_MP_RECTIFICATION_TASK] (
		@TASK_ID INT
		,@WAVE_PICKING_ID INT
		,@LOGIN VARCHAR(100)
	)
AS
BEGIN

DECLARE @MESSAGE VARCHAR (200),
		@ERROR_CODE INT

CREATE TABLE #DISPACH_LICENSES_INFO (
	LICENSE_ID INT,
	MATERIAL_ID VARCHAR(50),
	BARCODE_ID VARCHAR(50),
	QUANTITY_PENDING INT,
	QUENTITY_ASSSIGNED INT,
	CODIGO_POLIZA VARCHAR(100),
	CODIGO_POLIZA_SOURCE VARCHAR(100),
	CODIGO_POLIZA_TARGET VARCHAR(100)
);
	--
	PRINT ''

	BEGIN TRY

		


		
		SELECT @MESSAGE = 'Proceso Exitoso',
				   @ERROR_CODE = 1
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
