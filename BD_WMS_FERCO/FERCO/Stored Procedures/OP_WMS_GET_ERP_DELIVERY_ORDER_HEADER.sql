﻿-- =============================================
-- Autor:	        gustavo.garcia
-- Fecha de Creacion: 	2020-06-23  - Sprint Junio3
-- Description:	        Sp que trae las ordenes de entrega

/*
-- Ejemplo de Ejecucion:
			EXEC  [FERCO].[OP_WMS_GET_ERP_DELIVERY_ORDER_HEADER] @START_DATE = '2017-09-24 05:25:02.337'
                                                                     ,@END_DATE = '2017-09-25 17:25:02.337' 
																	 ,@CLIENTS = ''
																	 ,@WAREHOUSE_CODE = 'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_GET_ERP_DELIVERY_ORDER_HEADER] (
		@START_DATE DATETIME
		,@END_DATE DATETIME
		,@CLIENTS VARCHAR(MAX) 
		,@WAREHOUSE_CODE VARCHAR(50)
		,@DOC_NUM INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@EXTERNAL_SOURCE_ID INT
		,@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX)
		,@DELIMITER CHAR(1) = '|'
		,@ERP_WAREHOUSE VARCHAR(50);
  --
	CREATE TABLE [#SALES_ORDER_HEADER] (
		[SALES_ORDER_ID] VARCHAR(50) NOT NULL
		,[POSTED_DATETIME] [DATETIME] NULL
		,[CLIENT_ID] [VARCHAR](50) NULL
		,[CUSTOMER_NAME] VARCHAR(100) NULL
		,[TOTAL_AMOUNT] [MONEY] NULL
		,[CODE_ROUTE] [VARCHAR](25) NULL
		,[LOGIN] [VARCHAR](25) NULL
		,[DOC_SERIE] [VARCHAR](100) NULL
		,[DOC_NUM] VARCHAR(50) NULL
		,[DOC_ENTRY] VARCHAR(50) NOT NULL
		,[COMMENT] [VARCHAR](250) NULL
		,[EXTERNAL_SOURCE_ID] INT NOT NULL
		,[SOURCE_NAME] VARCHAR(50) NOT NULL
		,[SLPNAME] VARCHAR(150) NULL
		,[CODE_SELLER] VARCHAR(50) NULL
		,[DISCOUNT] NUMERIC(24, 6)
		,[CODE_WAREHOUSE] VARCHAR(50)
		,[CLIENT_OWNER] VARCHAR(50)
		,[MASTER_ID_SELLER] VARCHAR(50)
		,[SELLER_OWNER] VARCHAR(50)
		,[OWNER] VARCHAR(50)
		,[DELIVERY_DATE] DATETIME
		,[ADDRESS_CUSTOMER] VARCHAR(254)
		,[STATE_CODE] INT
		,[TYPE_DEMAND_CODE] INT
		,[TYPE_DEMAND_NAME] VARCHAR(50)
		,[PROJECT] VARCHAR(50)
		,[MIN_DAYS_EXPIRATION_DATE] INT
		,[ASESOR] VARCHAR(100)
		,[CODIGO_ASESOR] INT
		,[NOMBRE_SUCURSAL] VARCHAR(30)
		,PRIMARY KEY
			([DOC_ENTRY], [EXTERNAL_SOURCE_ID], [CODE_WAREHOUSE], [CLIENT_OWNER])
	);

  --  CREATE INDEX [IN_TEMP_SALES_ORDER_HEADER] ON [#SALES_ORDER_HEADER] ([DOC_ENTRY],[EXTERNAL_SOURCE_ID])
  --
  --  CREATE TABLE [#SALES_ORDER_HEADER]
  --  ADD CONSTRAINT PK_TEMP_SALES_ORDER PRIMARY KEY ([SALES_ORDER_ID])
  -- ------------------------------------------------------------------------------------
  -- Obtiene las fuentes externas
  -- ------------------------------------------------------------------------------------
	SELECT
		[ES].[EXTERNAL_SOURCE_ID]
		,[ES].[SOURCE_NAME]
		,[ES].[DATA_BASE_NAME]
		,[ES].[SCHEMA_NAME]
		,[ES].[INTERFACE_DATA_BASE_NAME]
	INTO
		[#EXTERNAL_SOURCE]
	FROM
		[FERCO].[OP_SETUP_EXTERNAL_SOURCE] [ES]
	WHERE
		[ES].[EXTERNAL_SOURCE_ID] > 0
		AND [ES].[READ_ERP] = 1;

  --CREATE TABLE [#EXTERNAL_SOURCE]
  --ADD CONSTRAINT PK_TEMP_EXTERNAL_SOURCE PRIMARY KEY ([EXTERNAL_SOURCE_ID])

	SELECT
		@ERP_WAREHOUSE = [ERP_WAREHOUSE]
	FROM
		[FERCO].[OP_WMS_WAREHOUSES]
	WHERE
		[WAREHOUSE_ID] = @WAREHOUSE_CODE;
  -- ------------------------------------------------------------------------------------
  -- Ciclo para obtener las ordenes de venta de todas las fuentes externas
  -- ------------------------------------------------------------------------------------
	PRINT '--> Inicia el ciclo';
  --
	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						[#EXTERNAL_SOURCE]
					WHERE
						[EXTERNAL_SOURCE_ID] > 0 )
	BEGIN
    -- ------------------------------------------------------------------------------------
    -- Se toma la primera fuente extermna
    -- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
			,@SOURCE_NAME = [ES].[SOURCE_NAME]
			,@DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
			,@QUERY = N''
		FROM
			[#EXTERNAL_SOURCE] [ES]
		WHERE
			[ES].[EXTERNAL_SOURCE_ID] > 0
		ORDER BY
			[ES].[EXTERNAL_SOURCE_ID];
    --
		PRINT '----> @EXTERNAL_SOURCE_ID: '
			+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

    -- ------------------------------------------------------------------------------------
    -- Obtiene las ordenes de venta de la fuente externa
    -- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'DECLARE @SEQUENCE INT
			EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[ERP_SP_INSERT_DELIVERY_ORDER_HEADER]
					@START_DATE = '''
			+ CAST(@START_DATE AS VARCHAR) + '''
					,@END_DATE = '''
			+ CAST(@END_DATE AS VARCHAR) + '''
					,@WAREHOUSE = ''' + @ERP_WAREHOUSE
			+ '''
					,@SEQUENCE = @SEQUENCE OUTPUT

					INSERT INTO [#SALES_ORDER_HEADER]
					SELECT DISTINCT
						[SO].[DOCNUM] AS [SALES_ORDER_ID]
						,[SO].[DocDate] AS [POSTED_DATETIME]
						,[SO].[U_MasterIDCustomer] AS [CLIENT_ID]
						,[SO].[CardName] AS [CUSTOMER_NAME]
						,[SO].DOCTOTAL [TOTAL_AMOUNT]
						,null [CODE_ROUTE]
						,null [LOGIN]     
						,[SO].[U_Serie] [DOC_SERIE]
						,[SO].[DOCNUM] [DOC_NUM]   
						,[SO].DOCENTRY [DOC_ENTRY]
						,[SO].[Comments] [COMMENT]
						,'
			+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
			+ ' [EXTERNAL_SOURCE_ID]
						,''' + @SOURCE_NAME
			+ ''' [SOURCE_NAME]
						,[SO].[SLPNAME]
						,[SO].[SlpCode] AS CODE_SELLER
						,[SO].[DiscPrcnt] AS DISCOUNT
						,[SO].[WhsCode] AS CODE_WAREHOUSE     
						,[SO].[U_OwnerCustomer] as CLIENT_OWNER
						,[SO].[MasterIdSlp] as MASTER_ID_SELLER
						,[SO].[OwnerSlp] as SELLER_OWNER
						,[SO].[Owner] [OWNER]
						,[SO].[DocDueDate] [DELIVERY_DATE]
						,[SO].[Address2]
						,[SO].[ShipToState] [STATE_CODE]
						,[SO].[TYPE_DEMAND_CODE]
						,[SO].[TYPE_DEMAND_NAME] 
						,[SO].[PROJECT]
						,[SO].[MIN_DAYS_EXPIRATION_DATE]
						,[SO].[SlpName]
						,[SO].[SlpCode]
						,[SO].[Descr]
					FROM ' + @DATA_BASE_NAME + '.'
			+ @SCHEMA_NAME
			+ '.[ERP_DELIVERY_ORDER_HEADER] [SO] WITH(NOLOCK)';

		IF (
			@CLIENTS IS NOT NULL
			AND @CLIENTS != ''
			)
		BEGIN
			SELECT
				@QUERY = @QUERY
				+ 'INNER JOIN [FERCO].[OP_WMS_FN_SPLIT]('''
				+ @CLIENTS + ''', ''' + @DELIMITER
				+ ''') [C] ON (
						[C].VALUE = [SO].[U_MasterIDCustomer] COLLATE DATABASE_DEFAULT 
					)';
		END;

		SELECT
			@QUERY = @QUERY
			+ 'WHERE [SO].[Sequence] = @SEQUENCE 
					AND [SO].[WhsCode] = '''
			+ @ERP_WAREHOUSE + '''';

		IF (@DOC_NUM > 0)
		BEGIN
			SELECT
				@QUERY = @QUERY + ' AND [SO].[DOCNUM] = '''
				+ CAST(@DOC_NUM AS VARCHAR(50)) + '''';
		END;

		SELECT
			@QUERY = @QUERY + 'EXEC ' + @DATA_BASE_NAME
			+ '.' + @SCHEMA_NAME
			+ '.[ERP_SP_DELETE_DELIVERY_ORDER_BY_SEQUENCE]
						@SEQUENCE = @SEQUENCE  -- int
			';
    --
		PRINT '--> @QUERY: \n' + @QUERY;
    --
		EXEC (@QUERY);
    -- ------------------------------------------------------------------------------------
    -- Eleminamos la fuente externa
    -- ------------------------------------------------------------------------------------
		DELETE FROM
			[#EXTERNAL_SOURCE]
		WHERE
			[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
  --
	END;

	SELECT DISTINCT
		[SOH].[SALES_ORDER_ID]
		,[SOH].[POSTED_DATETIME]
		,[SOH].[CLIENT_ID]
		,[SOH].[CUSTOMER_NAME]
		,[SOH].[TOTAL_AMOUNT]
		,[SOH].[CODE_ROUTE]
		,[SOH].[LOGIN]
		,[SOH].[DOC_SERIE]
		,[SOH].[DOC_NUM]
		,[SOH].[DOC_ENTRY]
		,[SOH].[COMMENT]
		,[SOH].[EXTERNAL_SOURCE_ID]
		,[SOH].[SOURCE_NAME]
		,[SOH].[SLPNAME]
		,[SOH].[CODE_SELLER]
		,[SOH].[DISCOUNT]
		,[SOH].[CODE_WAREHOUSE]
		,[SOH].[CLIENT_OWNER]
		,[SOH].[MASTER_ID_SELLER]
		,[SOH].[SELLER_OWNER]
		,[SOH].[OWNER]
		,1 [IS_FROM_ERP]
		,[SOH].[DELIVERY_DATE]
		,'SO - ERP' [SOURCE]
		,[SOH].[ADDRESS_CUSTOMER]
		,[SOH].[STATE_CODE]
		,[SOH].[TYPE_DEMAND_CODE]
		,[SOH].[TYPE_DEMAND_NAME]
		,[SOH].[PROJECT]
		,[SOH].[MIN_DAYS_EXPIRATION_DATE]
		,[SOH].[ASESOR]
		,[SOH].[CODIGO_ASESOR]
		,[SOH].[NOMBRE_SUCURSAL] AS [CENTRO_COSTO]
	FROM
		[#SALES_ORDER_HEADER] [SOH]
	LEFT JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [P] ON (
											[SOH].[DOC_ENTRY] collate database_default= [P].[DOC_ENTRY]
											AND [P].[SOURCE_TYPE]='DO - ERP'
											AND [SOH].[EXTERNAL_SOURCE_ID] = [P].[EXTERNAL_SOURCE_ID]
											AND [P].[EXTERNAL_SOURCE_ID] = [SOH].[EXTERNAL_SOURCE_ID]
											AND [P].[TYPE_DEMAND_CODE] = [SOH].[TYPE_DEMAND_CODE]
											)
	WHERE
		[SOH].[SALES_ORDER_ID] > 0
	GROUP BY
		[SOH].[SALES_ORDER_ID]
		,[SOH].[POSTED_DATETIME]
		,[SOH].[CLIENT_ID]
		,[SOH].[CUSTOMER_NAME]
		,[SOH].[TOTAL_AMOUNT]
		,[SOH].[CODE_ROUTE]
		,[SOH].[LOGIN]
		,[SOH].[DOC_SERIE]
		,[SOH].[DOC_NUM]
		,[SOH].[DOC_ENTRY]
		,[SOH].[COMMENT]
		,[SOH].[EXTERNAL_SOURCE_ID]
		,[SOH].[SOURCE_NAME]
		,[SOH].[SLPNAME]
		,[SOH].[CODE_SELLER]
		,[SOH].[DISCOUNT]
		,[SOH].[CODE_WAREHOUSE]
		,[SOH].[CLIENT_OWNER]
		,[SOH].[MASTER_ID_SELLER]
		,[SOH].[SELLER_OWNER]
		,[SOH].[OWNER]
		,[SOH].[DELIVERY_DATE]
		,[SOH].[ADDRESS_CUSTOMER]
		,[SOH].[STATE_CODE]
		,[SOH].[TYPE_DEMAND_CODE]
		,[SOH].[TYPE_DEMAND_NAME]
		,[SOH].[PROJECT]
		,[SOH].[MIN_DAYS_EXPIRATION_DATE]
		,[SOH].[ASESOR]
		,[SOH].[CODIGO_ASESOR]
		,[SOH].[NOMBRE_SUCURSAL]
	HAVING
		ISNULL(MAX([P].[IS_COMPLETED]), 0) = 0;
END;
