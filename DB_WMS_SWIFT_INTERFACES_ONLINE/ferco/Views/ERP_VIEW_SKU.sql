-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	18-12-2015
-- Description:			Vista que obtiene detalles de SKU 

-- modificacion 26-01-2016
				-- alberto.ruiz
				-- Se corrigio la columna de CODE_PROVIDER

-- modificacion 23-05-2016
				-- alberto.ruiz
				-- Se agrego la columna de USE_LINE_PICKING

-- Modificacion 27-05-2016
					-- alberto.ruiz
					-- Se agrego que tomara los campos de volumen, peso y medidas

-- Modificacion 8/31/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se agregan columnas 
/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [ferco].[ERP_VIEW_SKU]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_SKU]
AS
	SELECT
		SKU
		,CODE_SKU
		,DESCRIPTION_SKU
		,BARCODE_SKU
		,NAME_PROVIDER
		,COST
		,LIST_PRICE
		,MEASURE
		,NAME_CLASSIFICATION
		,UNIT_MEASURE_SKU
		,WEIGHT_SKU
		,VOLUME_SKU		
		,LONG_SKU
		,WIDTH_SKU
		,HIGH_SKU
		,VALUE_TEXT_CLASSIFICATION
		,HANDLE_SERIAL_NUMBER
		,HANDLE_BATCH
		,FROM_ERP
		,PRICE
		,LIST_NUM
		,CODE_PROVIDER
		,LAST_UPDATE
		,LAST_UPDATE_BY
		,CODE_FAMILY_SKU
		,USE_LINE_PICKING
		,VOLUME_CODE_UNIT
		,VOLUME_NAME_UNIT		
		,OWNER
		,OWNER_ID
		,ART_CODE
		,VAT_CODE
	FROM OPENQUERY(SAPSERVER, '
	  SELECT
		- 1 AS SKU
		,CONVERT(VARCHAR(50),sku.ItemCode) COLLATE SQL_Latin1_General_CP1_CI_AS AS CODE_SKU
		,CONVERT(VARCHAR(MAX),REPLACE(sku.ItemName, ''Ñ'', ''N'')) COLLATE SQL_Latin1_General_CP1_CI_AS AS DESCRIPTION_SKU
		,SuppCatNum COLLATE SQL_Latin1_General_CP1_CI_AS AS BARCODE_SKU
		,CAST(NULL AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CI_AS AS NAME_PROVIDER
		,CONVERT(FLOAT, ISNULL(sku.AvgPrice, 0)) AS ''COST''
		,CONVERT(NUMERIC(18, 2), ISNULL(price.Price, 0)) AS ''LIST_PRICE''
		,CONVERT(VARCHAR(50),'''') COLLATE SQL_Latin1_General_CP1_CI_AS AS MEASURE
		,CONVERT(VARCHAR(150),'''') COLLATE SQL_Latin1_General_CP1_CI_AS AS NAME_CLASSIFICATION
		,CONVERT(INT, ISNULL(0, 0)) AS ''UNIT_MEASURE_SKU''
		,CONVERT([numeric](18, 2), ISNULL(sku.SWeight1, 0)) AS ''WEIGHT_SKU''
		,CONVERT([numeric](18, 2), ISNULL(sku.SVolume, 0)) AS ''VOLUME_SKU''		
		,CONVERT([numeric](18, 2), ISNULL(sku.SLength1, 0)) AS ''LONG_SKU''
		,CONVERT([numeric](18, 2), ISNULL(sku.SWidth1, 0)) AS ''WIDTH_SKU''
		,CONVERT([numeric](18, 2), ISNULL(sku.SHeight1, 0)) AS ''HIGH_SKU''
		,lprice.ListName COLLATE SQL_Latin1_General_CP1_CI_AS AS VALUE_TEXT_CLASSIFICATION
		,CASE SKU.ManSerNum 
		  WHEN ''Y'' THEN CONVERT(VARCHAR(2),1)  COLLATE SQL_Latin1_General_CP1_CI_AS
  			WHEN ''N'' THEN CONVERT(VARCHAR(2),0)  COLLATE SQL_Latin1_General_CP1_CI_AS
  		 END AS HANDLE_SERIAL_NUMBER
		,''1'' COLLATE SQL_Latin1_General_CP1_CI_AS AS HANDLE_BATCH
		,CONVERT(VARCHAR(2),1) COLLATE SQL_Latin1_General_CP1_CI_AS AS FROM_ERP
		,price.Price AS PRICE
		,lprice.ListNum AS LIST_NUM
		,sku.CardCode COLLATE SQL_Latin1_General_CP1_CI_AS AS CODE_PROVIDER
		,CAST(NULL AS DATETIME) LAST_UPDATE
		,CAST(NULL AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CI_AS AS LAST_UPDATE_BY
		,CAST(sku.ItmsGrpCod as Varchar(50)) AS CODE_FAMILY_SKU
		,0 USE_LINE_PICKING
		,CONVERT(VARCHAR, ISNULL(OL.UnitDisply, ''Sin Medida'')) AS ''VOLUME_CODE_UNIT''
		,CONVERT(VARCHAR, ISNULL(OL.UnitName, ''Sin Medida'')) AS ''VOLUME_NAME_UNIT''		
		,CAST(NULL AS VARCHAR) AS OWNER
		,CONVERT(VARCHAR(50),sku.ItemCode) COLLATE SQL_Latin1_General_CP1_CI_AS AS OWNER_ID
		,CONVERT(VARCHAR(20),sku.SWW) COLLATE SQL_Latin1_General_CP1_CI_AS AS ART_CODE
		,CONVERT(VARCHAR(20),''E'') COLLATE SQL_Latin1_General_CP1_CI_AS AS VAT_CODE
	  FROM [SBOFERCO].dbo.OITM AS sku 
	  INNER JOIN [SBOFERCO].dbo.ITM1 AS price ON price.ItemCode = sku.ItemCode
	  INNER JOIN [SBOFERCO].dbo.OPLN AS lprice ON price.PriceList = lprice.ListNum 
	  INNER JOIN [SBOFERCO].dbo.OLGT AS OL ON sku.SVolUnit = OL.UnitCode
	  WHERE price.Price > 0'
	)