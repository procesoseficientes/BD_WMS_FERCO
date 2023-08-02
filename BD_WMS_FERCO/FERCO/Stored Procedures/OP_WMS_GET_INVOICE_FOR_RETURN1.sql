-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/11/2017 @ NEXUS-Team Sprint enave 
-- Description:			Obtiene una factura para devolucion

-- Modificacion 15-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrego el campo de MATERIAL_OWNER a la tabla [#INVOICE]

-- Modificacion 1/29/2018 @ Reborn-Team Sprint Trotzdem
					-- diego.as
					-- Se agrega envio de parametro @USE_SUBSIDIARY

-- Modificacion 06-Apr-18 @ Nexus Team Sprint Búho
					-- pablo.aguilar
					-- Se agrega el manejo de centro de costo y manejo de devoluciones parciales. 

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_GET_INVOICE_FOR_RETURN] @OWNER = 'ferco', -- varchar(50)
	@DOC_NUM = 15172350, -- int
	@EXTERNAL_SOURCE_ID = 1 -- int

*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_GET_INVOICE_FOR_RETURN1] (
		@OWNER VARCHAR(50)
		,@DOC_NUM INT
		,@EXTERNAL_SOURCE_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@RECEPTION_DOCUMENTS TABLE (
			[DOC_ID] INT
			,[MATERIAL_ID] VARCHAR(50)
			,[RECEPTION_QTY] NUMERIC(18, 6)
			,[DOCUMENT_QTY] NUMERIC(18, 6)
			,[IS_AUTHORIZED] INT
			, [LINE_NUM] INT 
		);
--
	CREATE TABLE [#INVOICE] (
		[DOC_ENTRY] INT
		,[DOC_NUM] INT
		,[CLIENT_CODE] VARCHAR(50)
		,[CLIENT_NAME] VARCHAR(150)
		,[COMMENTS] VARCHAR(300)
		,[DOC_DATE] DATETIME
		,[DELIVERY_DATE] DATETIME
		,[STATUS] CHAR(2)
		,[CODE_SELLER] INT
		,[TOTAL_AMOUNT] DECIMAL(18, 6)
		,[LINE_NUM] INT
		,[MATERIAL_ID] VARCHAR(50)
		,[MATERIAL_NAME] VARCHAR(150)
		,[QTY] DECIMAL(18, 6)
		,[OPENQTY] DECIMAL(18, 6)
		,[PRICE] DECIMAL(18, 6)
		,[DISCOUNT_PERCENT] DECIMAL(18, 6)
		,[TOTAL_LINE] DECIMAL(18, 6)
		,[ERP_WAREHOUSE_CODE] VARCHAR(50)
		,[MATERIAL_OWNER] VARCHAR(50)
		,[ADDRESS] VARCHAR(250)
		,[DOC_CURRENCY] NVARCHAR(3)
		,[DOC_RATE] DECIMAL(18, 6)
		,[SUBSIDIARY] VARCHAR(25)
		,[DET_CURRENCY] NVARCHAR(3)
		,[DET_RATE] DECIMAL(18, 6)
		,[DET_TAX_CODE] NVARCHAR(8)
		,[DET_VAT_PERCENT] DECIMAL(18, 6)
		,[COST_CENTER] VARCHAR(25) NULL
	);
	--
	DECLARE
		@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
		,@ERP_DATA_BASE_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX)
		,@DELIMITER CHAR(1) = '|'
		,@COMPANY_NAME VARCHAR(50)
		,@USE_SUBSIDIARY VARCHAR(MAX);

	BEGIN TRY
			
		-- ------------------------------------------------------------------------------------
		-- Obtiene la fuente externa
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@SOURCE_NAME = [ES].[SOURCE_NAME]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
			,@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
			,@COMPANY_NAME = [C].[COMPANY_NAME]
			,@ERP_DATA_BASE_NAME = [C].[ERP_DATABASE]
		FROM
			[FERCO].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		INNER JOIN [FERCO].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
		WHERE
			[ES].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
			AND [C].[CLIENT_CODE] = @OWNER
			AND [C].[COMPANY_ID] > 0;
		--
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @INTERFACE_DATA_BASE_NAME: '
			+ @INTERFACE_DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;
		PRINT '----> @ERP_DATA_BASE_NAME: '
			+ @ERP_DATA_BASE_NAME;
		PRINT '----> @COMPANY_NAME: ' + @COMPANY_NAME;
		-- ------------------------------------------------------------------------------------
		-- Obtiene las recepciones abiertas para las facturas
		-- ------------------------------------------------------------------------------------
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
		INNER JOIN [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H] ON [H].[TASK_ID] = [TR].[TASK_ID]
											AND [H].[IS_VOID] = 0
											AND [H].[SOURCE] = 'INVOICE'
		WHERE
			[H].[DOC_NUM] = @DOC_NUM
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
			,[RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
			,[RDD].[LINE_NUM]
			,0 [USED]
			,[RDD].[ERP_OBJECT_TYPE]
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
			[H].[DOC_NUM] = @DOC_NUM
			AND [H].[IS_VOID] = 0
			AND [H].[SOURCE] = 'INVOICE'
		GROUP BY
			[M].[MATERIAL_ID]
			,[RDD].[LINE_NUM]
			,[M].[MATERIAL_NAME]
			,[M].[BARCODE_ID]
			,[RDD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID]
			,[RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
			,[RDD].[ERP_OBJECT_TYPE];

		
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
			PRINT '@TRANS_ID: '
				+ +CAST(@TRANS_ID AS VARCHAR);
		
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
				AND @QTY_RECEPTION > 0
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
			
				PRINT '@MATERIAL' + @MATERIAL_ID;
				PRINT '@RECEPTION_DOCUMENT_DETAIL: '
					+ CAST(@RECEPTION_DOCUMENT_DETAIL AS VARCHAR);
				PRINT '@QTY_DOC: '
					+ CAST(@QTY_DOC AS VARCHAR);
			
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

				SELECT
					@QTY_RECEPTION = @QTY_RECEPTION
					- @QTY_TO_ASSIGN;
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

	
	INSERT	INTO @RECEPTION_DOCUMENTS
				(
					[DOC_ID]
					,[MATERIAL_ID]
					,[RECEPTION_QTY]
					,[DOCUMENT_QTY]
					,[IS_AUTHORIZED]
					,[LINE_NUM]
            	)
		SELECT
			[H].[DOC_ID]
			,[D].[MATERIAL_ID]
			,SUM([D].[QTY]) [RECEPTION_QTY]
			,MAX([D].[QTY_DOC]) [DOCUMENT_QTY]			
			,MIN([T].[IS_COMPLETED]) [IS_AUTHORIZED]
			, [D].[LINE_NUM]
		FROM
			[#DOCUMENTS] [D]
		INNER JOIN [FERCO].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H] ON [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
		INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
		WHERE
			[H].[DOC_NUM] = @DOC_NUM
			GROUP BY [H].[DOC_ID]
					,[D].[MATERIAL_ID]
					, [D].[LINE_NUM]

					SELECT * FROM @RECEPTION_DOCUMENTS
		-- ------------------------------------------------------------------------------------
		-- Se verifica el valor del parametro USE_SUBSIDIARY de la recepcion ERP
		-- ------------------------------------------------------------------------------------ 
		SELECT
			@USE_SUBSIDIARY = ISNULL([T].[VALUE], '0')
		FROM
			[FERCO].[OP_WMS_FN_GET_PARAMETER_BY_GROUP]('ERP_RECEPTION')
			AS [T]
		WHERE
			[T].[PARAMETER_ID] = 'USE_SUBSIDIARY'
			AND [T].[IDENTITY] > 0;
			
		-- ------------------------------------------------------------------------------------
		-- Ejecuta el SP SWIFT_SP_GET_ERP_INVOICE_BY_DOC_NUM_FOR_RETURN_IN_WMS para obtener la factura
		-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = '
				INSERT INTO #INVOICE
				EXEC ' + @INTERFACE_DATA_BASE_NAME + '.'
			+ @SCHEMA_NAME
			+ '.[SWIFT_SP_GET_ERP_INVOICE_BY_DOC_NUM_FOR_RETURN_IN_WMS]
						@DATABASE = '''
			+ CAST(@ERP_DATA_BASE_NAME AS VARCHAR) + '''
						,@DOC_NUM = '
			+ CAST(@DOC_NUM AS VARCHAR) + '
						,@USE_SUBSIDIARY = '
			+ @USE_SUBSIDIARY + '
			';
		PRINT '@QUERY -> ' + @QUERY;
		--
		EXEC (@QUERY);
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT
			CAST([I].[DOC_NUM] AS VARCHAR) [SAP_RECEPTION_ID]
			,[I].[DOC_NUM] [ERP_DOC]
			,[I].[CLIENT_CODE] [PROVIDER_ID]
			,[I].[CLIENT_NAME] [PROVIDER_NAME]
			,CAST([I].[MATERIAL_OWNER] + '/'
			+ [I].[MATERIAL_ID] AS VARCHAR(50)) [SKU]
			,[I].[MATERIAL_NAME] [SKU_DESCRIPTION]
			,CAST(ISNULL([R].[DOCUMENT_QTY], [I].[OPENQTY]) AS NUMERIC(18,
											6)) [TOTAL_QUANTITY]
			,CAST(CASE	WHEN [R].[DOCUMENT_QTY] IS NULL
						THEN [I].[QTY]
						ELSE [R].[DOCUMENT_QTY]
								- [R].[RECEPTION_QTY]
					END AS NUMERIC(18, 6)) [QTY]
			,[I].[OPENQTY] [OPEN_QUANTITY]
			,CAST(ISNULL([R].[RECEPTION_QTY], 0) AS NUMERIC(18,
											6)) [RECEPTION_QUANTITY]
			,[I].[LINE_NUM]
			,[I].[COMMENTS]
			,CAST(13 AS INT) [OBJECT_TYPE]
			,[M].[BARCODE_ID]
			,[M].[ALTERNATE_BARCODE]
			,CAST(@EXTERNAL_SOURCE_ID AS INT) [EXTERNAL_SOURCE_ID]
			,CAST(@SOURCE_NAME AS VARCHAR(50)) [SOURCE_NAME]
			,CAST(CASE	WHEN [R].[DOCUMENT_QTY] IS NULL
						THEN 0
						WHEN [IS_AUTHORIZED] = 0 THEN 1
						WHEN ISNULL([R].[RECEPTION_QTY], 0) >= 0
								AND [R].[RECEPTION_QTY] < ISNULL([R].[DOCUMENT_QTY],
											[I].[OPENQTY])
						THEN 0
						ELSE 1
					END AS INT) [IS_ASSIGNED]
			,CAST(CASE	WHEN [IS_AUTHORIZED] = 0 THEN 0
						WHEN [R].[RECEPTION_QTY] IS NOT NULL
								AND ISNULL([R].[RECEPTION_QTY],
											0) < ISNULL([R].[DOCUMENT_QTY],
											[I].[OPENQTY])
						THEN 1
						ELSE 0
					END AS INT) [IS_MISSING]
			,[I].[MATERIAL_ID] [MASTER_ID_SKU]
			,CAST(@OWNER AS VARCHAR(50)) [OWNER_SKU]
			,CAST(@OWNER AS VARCHAR(50)) [OWNER]
			,CAST('INVOICE' AS VARCHAR(50)) [SOURCE]
			,[I].[ERP_WAREHOUSE_CODE]
			,[I].[DOC_ENTRY]
			,[I].[ADDRESS]
			,[I].[DOC_CURRENCY]
			,[I].[DOC_RATE]
			,[I].[SUBSIDIARY]
			,[I].[DET_CURRENCY]
			,[I].[DET_RATE]
			,[I].[DET_TAX_CODE]
			,[I].[DET_VAT_PERCENT]
			,[I].[DISCOUNT_PERCENT]
			,[I].[PRICE]
			,[I].[COST_CENTER]
		FROM
			[#INVOICE] [I]
		INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON ([I].[MATERIAL_OWNER]
											+ '/'
											+ [I].[MATERIAL_ID] = [M].[MATERIAL_ID])
		LEFT JOIN @RECEPTION_DOCUMENTS [R] ON (
											[R].[DOC_ID] = [I].[DOC_NUM]
											AND [M].[MATERIAL_ID] = [R].[MATERIAL_ID] AND [I].[LINE_NUM] = [R].[LINE_NUM]
											);

									
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;	
END;



