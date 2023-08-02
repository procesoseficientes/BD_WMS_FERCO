-- =============================================
-- Autor:                 rudi.garcia
-- Fecha de Creacion:   2017-01-13 @ TeamErgon Sprint Ergon III
-- Description:          SP que obtiene el detalle de las recepciones desde una tarea.
-- Autor:                hector.gonzalez
-- Fecha de Creacion:   2017-03-13 @ TeamErgon Sprint Ergon V
-- Description:          Se agrego case cuando QTY_DOC viene NULL 
-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-17 ErgonTeam@Sheik
-- Description:     Se estandariza los nombres de los campos del resultado.
/*
-- Ejemplo de Ejecucion:
        EXEC [FERCO].[OP_WMS_SP_GET_TASK_DETAIL_FOR_RECEPTION_1]
          @SERIAL_NUMBER = 47373
		EXEC [FERCO].[OP_WMS_SP_GET_TASK_DETAIL_FOR_RECEPTION]
          @SERIAL_NUMBER = 47373
	SELECT [TASK_ID]	,* FROM [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] 
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_TASK_DETAIL_FOR_RECEPTION_1] (@SERIAL_NUMBER INT)
AS
IF NOT EXISTS ( SELECT TOP 1
					1
				FROM
					[FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
				WHERE
					[TASK_ID] = @SERIAL_NUMBER )
BEGIN
	SELECT
		[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,SUM([IL].[ENTERED_QTY]) AS [QTY]
		,0 AS [QTY_DOC]
		,0 AS [QTY_DIFFERENCE]
		,MAX([T].[TASK_COMMENTS]) AS [TASK_COMMENTS]
		,[IL].[BARCODE_ID]
		,MAX([T].[SERIAL_NUMBER]) AS [SERIAL_NUMBER]
		,MAX([T].[CODIGO_POLIZA_TARGET]) AS [CODIGO_POLIZA_TARGET]
		,MAX([T].[CODIGO_POLIZA_SOURCE]) AS [CODIGO_POLIZA_SOURCE]
	FROM
		[FERCO].[OP_WMS_TASK_LIST] [T]
	INNER JOIN [FERCO].[OP_WMS_LICENSES] [L] ON ([L].[CODIGO_POLIZA] = [T].[CODIGO_POLIZA_SOURCE])
	INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
	WHERE
		[T].[SERIAL_NUMBER] = @SERIAL_NUMBER
	GROUP BY
		[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,[IL].[BARCODE_ID];
END;
ELSE
BEGIN

BEGIN
    	DECLARE
    		@RECEPTION_DOCUMENT_DETAIL INT
    		,@MATERIAL_ID VARCHAR(50)
    		,@QTY_DOC INT
    		,@QTY_RECEPTION INT
    		,@QTY_TO_ASSIGN INT
    		,@TRANS_ID INT; 
    	
    	SELECT
    		[TR].[MATERIAL_CODE] [MATERIAL_ID]
    		,SUM([TR].[QUANTITY_UNITS]) [QUANTITY_UNITS]
    		,0 [USED]
    		,[TR].[SERIAL_NUMBER] [TRANS_ID]
    	INTO
    		[#RECEPTIONS]
    	FROM
    		[FERCO].[OP_WMS_TRANS] [TR]
    	WHERE
    		[TR].[TASK_ID] = @SERIAL_NUMBER
    		AND [TR].[TRANS_TYPE] = 'INGRESO_GENERAL'
    		AND [TR].[STATUS] = 'PROCESSED'
    	GROUP BY
    		[TR].[MATERIAL_CODE]
    		,[TR].[SERIAL_NUMBER];
    
    	SELECT
    		[M].[MATERIAL_ID] AS [MATERIAL_ID]
    		,[M].[MATERIAL_NAME] AS [MATERIAL_NAME]
    		,0 AS [QTY]
    		,MAX([RDD].[QTY]) AS [QTY_DOC]
    		,0 [QTY_DIFFERENCE]
    		,MAX(CAST([H].[TASK_ID] AS VARCHAR)) AS [TASK_COMMENTS]
    		,[M].[BARCODE_ID] AS [BARCODE_ID]
    		,MAX([H].[TASK_ID]) AS [SERIAL_NUMBER]
    		,CAST(MAX([H].[DOC_ID_POLIZA]) AS VARCHAR(25)) AS [CODIGO_POLIZA_TARGET]
    		,CAST(MAX([H].[DOC_ID_POLIZA]) AS VARCHAR(25)) AS [CODIGO_POLIZA_SOURCE]
    		,[RDD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID]
    		,[RDD].[LINE_NUM]
    		,0 [USED]
    	INTO
    		[#DOCUMENTS]
    	FROM
    		[FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD]
    	INNER JOIN [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H] ON [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
    	LEFT JOIN [FERCO].[OP_WMS_TRANS] [TR] ON [TR].[MATERIAL_CODE] = [RDD].[MATERIAL_ID]
    											AND [TR].[TASK_ID] = [H].[TASK_ID]
    											AND [TR].[TRANS_TYPE] = 'INGRESO_GENERAL'
    											AND [TR].[STATUS] = 'PROCESSED'
    	INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RDD].[MATERIAL_ID]
    	WHERE
    		[H].[TASK_ID] = @SERIAL_NUMBER
    	GROUP BY
    		[M].[MATERIAL_ID]
    		,[RDD].[LINE_NUM]
    		,[M].[MATERIAL_NAME]
    		,[M].[BARCODE_ID]
    		,[RDD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID];
    
    		
    	-- ------------------------------------------------------------------------------------
    	-- Se recorre los documentos
    	-- ------------------------------------------------------------------------------------
    	WHILE EXISTS ( SELECT TOP 1
    						1
    					FROM
    						[#RECEPTIONS]
    					WHERE
    						[USED] = 0 )
    	BEGIN 
    
    	-- ------------------------------------------------------------------------------------
    	-- se selecciona la primera recepción  
    	-- ------------------------------------------------------------------------------------
    		SELECT TOP 1
    			@MATERIAL_ID = [MATERIAL_ID]
    			,@QTY_RECEPTION = [QUANTITY_UNITS]
    			,@TRANS_ID = [TRANS_ID]
    		FROM
    			[#RECEPTIONS]
    		WHERE
    			[USED] = 0;
    
    		PRINT '@MATERIAL_ID: ' + @MATERIAL_ID;
    		PRINT '@QTY_RECEPTION: '
    			+ CAST(@QTY_RECEPTION AS VARCHAR);
    		PRINT '@TRANS_ID: ' + +CAST(@TRANS_ID AS VARCHAR);
    		
    			-- ------------------------------------------------------------------------------------
    			--  Se recorren los documentos para asignarlos a una recepción
    			-- ------------------------------------------------------------------------------------
    		WHILE EXISTS ( SELECT TOP 1
    							1
    						FROM
    							[#DOCUMENTS]
    						WHERE
    							[MATERIAL_ID] = @MATERIAL_ID
    							AND [QTY_DOC] > [QTY]
    							AND [USED] = 0 )
    		BEGIN 
    
    			SELECT TOP 1
    				@RECEPTION_DOCUMENT_DETAIL = [ERP_RECEPTION_DOCUMENT_DETAIL_ID]
    				,@QTY_DOC = [QTY_DOC] - [QTY]
    			FROM
    				[#DOCUMENTS]
    			WHERE
    				[MATERIAL_ID] = @MATERIAL_ID
    				AND [QTY_DOC] > [QTY]
    			ORDER BY
    				[LINE_NUM];
    			
    			PRINT '@MATERIAL' + @MATERIAL_ID
    			PRINT '@RECEPTION_DOCUMENT_DETAIL: '
    				+ CAST(@RECEPTION_DOCUMENT_DETAIL AS VARCHAR);
    			PRINT '@QTY_DOC: ' + CAST(@QTY_DOC AS VARCHAR);
    			
    			SELECT
    				@QTY_TO_ASSIGN = CASE	WHEN @QTY_RECEPTION <= @QTY_DOC
    										THEN @QTY_RECEPTION
    										ELSE @QTY_DOC
    									END; 
    
    			PRINT '@QTY_TO_ASSIGN: '
    				+ CAST(@QTY_TO_ASSIGN AS VARCHAR);
    
    			UPDATE
    				[#DOCUMENTS]
    			SET	
    				[QTY] = [QTY] + @QTY_TO_ASSIGN
    				,[USED] = 1
    			WHERE
    				[ERP_RECEPTION_DOCUMENT_DETAIL_ID] = @RECEPTION_DOCUMENT_DETAIL;
    			
    			UPDATE
    				[#RECEPTIONS]
    			SET	
    				[QUANTITY_UNITS] = [QUANTITY_UNITS]
    				- @QTY_TO_ASSIGN
    			WHERE
    				[TRANS_ID] = @TRANS_ID;
    
    				SELECT @QTY_RECEPTION = @QTY_RECEPTION - @QTY_TO_ASSIGN
    		END;
    
    		UPDATE
    			[#DOCUMENTS]
    		SET	
    			[USED] = 0; 
    		UPDATE
    			[#RECEPTIONS]
    		SET	
    			[USED] = 1
    		WHERE
    			@TRANS_ID = [TRANS_ID]; 	
    	END;
END
	SELECT
		[M].[MATERIAL_ID] AS [MATERIAL_ID]
		,[M].[MATERIAL_NAME] AS [MATERIAL_NAME]
		,[D].[QTY]
		,[D].[QTY_DOC]
		,[D].[QTY] - [D].[QTY_DOC] [QTY_DIFFERENCE]
		,[D].[TASK_COMMENTS]
		,[M].[BARCODE_ID] AS [BARCODE_ID]
		,[D].[SERIAL_NUMBER]
		,[D].[CODIGO_POLIZA_TARGET]
		,[D].[CODIGO_POLIZA_SOURCE]
	FROM
		[#DOCUMENTS] [D]
	INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [D].[MATERIAL_ID] = [M].[MATERIAL_ID]
	UNION
	SELECT
		[M].[MATERIAL_ID] AS [MATERIAL_ID]
		,MAX([M].[MATERIAL_NAME]) AS [MATERIAL_NAME]
		,SUM([QUANTITY_UNITS] )[QTY]
		,0 [QTY_DOC]
		, SUM([QUANTITY_UNITS])  [QTY_DIFFERENCE]
		,CAST (@SERIAL_NUMBER AS VARCHAR) AS [TASK_COMMENTS]
		,MAX([M].[BARCODE_ID]) AS [BARCODE_ID]
		,@SERIAL_NUMBER AS [SERIAL_NUMBER]
		,max([T].[CODIGO_POLIZA_SOURCE]) AS [CODIGO_POLIZA_TARGET]
		,max([T].[CODIGO_POLIZA_SOURCE]) AS [CODIGO_POLIZA_SOURCE]
	FROM
		[#RECEPTIONS] [R]
	INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [R].[MATERIAL_ID]
	INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [T] ON [T].[SERIAL_NUMBER] = @SERIAL_NUMBER
	WHERE
		[QUANTITY_UNITS] > 0

		GROUP BY [M].[MATERIAL_ID]

END;
  
