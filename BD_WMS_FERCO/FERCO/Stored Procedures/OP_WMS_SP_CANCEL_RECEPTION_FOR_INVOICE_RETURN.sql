-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/11/2017 @ NEXUS-Team Sprint eFERCO 
-- Description:			Cancela la recepcion y elimina el inventario ingresado

-- Modificacion 15-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrega que elimine los master packs de la recepcion

-- Modificacion 26-Jun-18 @ Nexus Team Sprint Elefante
					-- marvin.garcia
					-- Se llamada a [FERCO].[OP_WMS_SP_DELETE_ERP_DOCUMENTS_FROM_TASK_ID] para eliminar documentos ERP

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_CANCEL_RECEPTION_FOR_INVOICE_RETURN]
					@TASK_ID = 0
					,@LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_CANCEL_RECEPTION_FOR_INVOICE_RETURN](
	@TASK_ID INT
	,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @LICENSE TABLE(
		[LICENSE_ID] INT NOT NULL PRIMARY KEY
	)
	--
	DECLARE @CODIGO_POLIZA VARCHAR(25)
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Cancela la tarea
		-- ------------------------------------------------------------------------------------
		UPDATE [FERCO].[OP_WMS_TASK_LIST]
		SET [IS_CANCELED] = 1, [CANCELED_BY] = @LOGIN, [CANCELED_DATETIME] = GETDATE()
		WHERE [SERIAL_NUMBER] = @TASK_ID
		
		-- ------------------------------------------------------------------------------------
		-- Cancela la recepcion
		-- ------------------------------------------------------------------------------------
		UPDATE [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
		SET [IS_VOID] = 1, [LAST_UPDATE] = GETDATE(), [LAST_UPDATE_BY] = @LOGIN
		WHERE [TASK_ID] = @TASK_ID
	    
		-- ------------------------------------------------------------------------------------
		-- Obtiene el codigo de poliza de la tarea
		-- ------------------------------------------------------------------------------------
		SELECT @CODIGO_POLIZA = [CODIGO_POLIZA_SOURCE] 
		FROM [FERCO].[OP_WMS_TASK_LIST] 
		WHERE [SERIAL_NUMBER] = @TASK_ID

		-- ------------------------------------------------------------------------------------
		-- Obtiene el ID de la licencia
		-- ------------------------------------------------------------------------------------
		INSERT INTO @LICENSE
				([LICENSE_ID])
		SELECT DISTINCT [LICENSE_ID]
		FROM [FERCO].[OP_WMS_LICENSES] 
		WHERE [CODIGO_POLIZA] = @CODIGO_POLIZA

		-- ------------------------------------------------------------------------------------
		-- Elimina los masterpacks recepcionados
		-- ------------------------------------------------------------------------------------
		DELETE [MD]
		FROM [FERCO].[OP_WMS_MASTER_PACK_DETAIL] [MD]
		INNER JOIN [FERCO].[OP_WMS_MASTER_PACK_HEADER] [MH] ON ([MH].[MASTER_PACK_HEADER_ID] = [MD].[MASTER_PACK_HEADER_ID])
		INNER JOIN @LICENSE [L] ON ([L].[LICENSE_ID] = [MH].[LICENSE_ID])
		--
		DELETE [MH]
		FROM [FERCO].[OP_WMS_MASTER_PACK_HEADER] [MH]
		INNER JOIN @LICENSE [L] ON ([L].[LICENSE_ID] = [MH].[LICENSE_ID])

		-- ------------------------------------------------------------------------------------
		-- Elimina las trans
		-- ------------------------------------------------------------------------------------
		DELETE FROM [FERCO].[OP_WMS_TRANS]
		WHERE [CODIGO_POLIZA] = @CODIGO_POLIZA
		
		-- ------------------------------------------------------------------------------------
		-- Elimina el inventario por licencia
		-- ------------------------------------------------------------------------------------
		DELETE [IXL]
		FROM [FERCO].[OP_WMS_INV_X_LICENSE] [IXL]
			INNER JOIN @LICENSE [L] ON [L].[LICENSE_ID] = [IXL].[LICENSE_ID]
		WHERE [IXL].[PK_LINE] > 0
		
		-- ------------------------------------------------------------------------------------
		-- Elimina las licencias
		-- ------------------------------------------------------------------------------------
		DELETE [L]
		FROM [FERCO].[OP_WMS_LICENSES] [L]
			INNER JOIN @LICENSE [LR] ON [LR].[LICENSE_ID] = [L].[LICENSE_ID]
		WHERE [L].[LICENSE_ID] > 0

		-- ------------------------------------------------------------------------------------
		-- Elimina los documentos erp
		-- ------------------------------------------------------------------------------------
	
		EXECUTE [FERCO].[OP_WMS_SP_DELETE_ERP_DOCUMENTS_FROM_TASK_ID]
		@TASK_ID = @TASK_ID --NUMERIC(18,0)

		-- ------------------------------------------------------------------------------------
		-- Muestra resultado
		-- ------------------------------------------------------------------------------------
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY	
	BEGIN CATCH
	    SELECT  -1 as Resultado
		,ERROR_MESSAGE()  Mensaje 
		,@@ERROR Codigo 
	END CATCH
END