
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/30/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Valida el codigo del documento ingresado y la bodega asociada al login del usuario y devuelve el tipo de este conjunto a su ID. 

-- Modificacion 14-Dec-17 @ Nexus Team Sprint HeYouPikachu!
					-- pablo.aguilar
					-- Se realiza la validación de bodegas unicamente en solicitud de transferencia. 
/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_VALIDATE_SCANNED_DOCUMENT_FOR_RECEPTION] 
					@DOCUMENT = 'MC-1044', -- varchar(100)
					@LOGIN = 'ACAMACHO' -- varchar(25)
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_VALIDATE_SCANNED_DOCUMENT_FOR_RECEPTION](
	@DOCUMENT VARCHAR(100)
	,@LOGIN  VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@DOCUMENT_TYPE VARCHAR(50)
		,@DOCUMENT_ID VARCHAR(50)
		,@WAREHOUSE_TO VARCHAR(50)
		,@MANIFEST_TYPE VARCHAR(50)
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene todos los parametros de prefijo de documentos.
		-- ------------------------------------------------------------------------------------
		SELECT [PARAMETER_ID] [DOCUMENT]
				,[VALUE] [PREFIX]
		INTO [#PREFIX]
		FROM [FERCO].[OP_WMS_PARAMETER] 
		WHERE [GROUP_ID] = 'PREFIX'
		-- ------------------------------------------------------------------------------------
		-- Verifica que, al documento ingresado, su prefijo exista en los parametros, si no existe envia un error.
		-- ------------------------------------------------------------------------------------
		IF NOT EXISTS (SELECT TOP 1 1 
			FROM  [FERCO].[OP_WMS_FN_SPLIT](@DOCUMENT,'-') [SPL]
				INNER JOIN [#PREFIX] [P] ON [P].[PREFIX] = [SPL].[VALUE])
		BEGIN
			SELECT -1 [Resultado]
				,'Id de documento invalido.' [Mensaje]
				,1501 [Codigo]
			RETURN
		END
		-- ------------------------------------------------------------------------------------
		-- Llena las variables de @DOCUMENT_TYPE y @DOCUMENT_ID
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @DOCUMENT_TYPE = [P].[DOCUMENT]
		FROM  [FERCO].[OP_WMS_FN_SPLIT](@DOCUMENT,'-') [SPL]
			INNER JOIN [#PREFIX] [P] ON [P].[PREFIX] = [SPL].[VALUE]
		--
		SELECT TOP 1 @DOCUMENT_ID = [VALUE]
		FROM [FERCO].[OP_WMS_FN_SPLIT](@DOCUMENT,'-') 
		ORDER BY [ID] DESC	
		--
		IF @DOCUMENT_TYPE = 'CARGO_MANIFEST'
		BEGIN

			
			-- ------------------------------------------------------------------------------------
			-- Verifica que el manifiesto de carga exista
			-- ------------------------------------------------------------------------------------
			IF NOT EXISTS (SELECT TOP 1 1 FROM [FERCO].[OP_WMS_MANIFEST_HEADER] WHERE [MANIFEST_HEADER_ID] = @DOCUMENT_ID)
			BEGIN
				SELECT -1 [Resultado]
					,'El documento no existe.' [Mensaje]
					,1502 [Codigo]
				RETURN
			END
			IF  EXISTS (SELECT TOP 1 1 FROM [ferco].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] 
			WHERE DOC_ID = @DOCUMENT_ID)
			BEGIN
				SELECT -1 [Resultado]
					,'Ya fue utilizado.' [Mensaje]
					,1503 [Codigo]
				RETURN
			END

			SELECT @MANIFEST_TYPE = [MANIFEST_TYPE] FROM [FERCO].[OP_WMS_MANIFEST_HEADER] WHERE [MANIFEST_HEADER_ID] = @DOCUMENT_ID
			-- ------------------------------------------------------------------------------------
			-- Si es un documento de manifiesto de carga, verifica que la bodega destino de la solicitud de traslado este asignada al usuario, de lo contrario devuelve un error.
			-- ------------------------------------------------------------------------------------
			IF @MANIFEST_TYPE = 'TRANSFER_REQUEST' AND  NOT EXISTS (SELECT TOP 1 1
				FROM [FERCO].[OP_WMS_MANIFEST_HEADER] [MH]
					INNER JOIN [FERCO].[OP_WMS_TRANSFER_REQUEST_HEADER] [TH] ON [TH].[TRANSFER_REQUEST_ID] = [MH].[TRANSFER_REQUEST_ID]
					INNER JOIN [FERCO].[OP_WMS_WAREHOUSE_BY_USER] [WBU] ON [TH].[WAREHOUSE_TO] = [WBU].[WAREHOUSE_ID]
				WHERE [WBU].[LOGIN_ID] = @LOGIN AND [MH].[MANIFEST_HEADER_ID] = @DOCUMENT_ID )
			BEGIN
				SELECT -1 [Resultado]
					,'La bodega destino de la solicitud de traslado no esta asociada al operador.' [Mensaje]
					,1503 [Codigo]
				RETURN
			END
		END
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT  
			1 as Resultado , 
			'Proceso Exitoso' Mensaje ,  
			@DOCUMENT_ID Codigo, 
			@DOCUMENT_TYPE + '|' + CAST(@DOCUMENT_ID AS VARCHAR) DbData
		--
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
