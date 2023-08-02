



-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-31 @ Team ERGON - Sprint ERGON 1
-- Description:	 NA
/*
-- Ejemplo de Ejecucion:
			SELECT * FROM FERCO.[VIEW_SKU_MASTER_PACK_ERP_DETAIL]
*/
-- =============================================
CREATE VIEW [FERCO].[VIEW_SKU_MASTER_PACK_ERP_DETAIL]
AS
--SKU de FERCO
SELECT [H].[Code] AS [MATERIAL_ID_FATHER],
       'ferco' AS 'CLIENT_OWNER',
       [O].[ItemCode] AS 'MATERIAL_ID',
       [O].[ItemCode] + '0' + ISNULL(SUBSTRING([O].[SalUnitMsr], 1, 2), '') AS 'BARCODE_ID',
       [O].[ItemCode] + '0' AS 'ALTERNATE_BARCODE',
       [O].[ItemName] AS 'MATERIAL_NAME',
       [O].[ItemName] AS 'SHORT_NAME',
       0 AS 'VOLUME_FACTOR',
       '2' AS 'MATERIAL_CLASS',
       [O].[SHeight1] AS 'HIGH',
       [O].[SLength1] AS 'LENGTH',
       [O].[SWidth1] AS 'WIDTH',
       100 AS 'MAX_X_BIN',
       0 AS 'SCAN_BY_ONE',
       0 AS 'REQUIRES_LOGISTICS_INFO',
       [SWeight1] AS 'WEIGTH',
       CAST(NULL AS IMAGE) AS 'IMAGE_1',
       CAST(NULL AS IMAGE) AS 'IMAGE_2',
       CAST(NULL AS IMAGE) AS 'IMAGE_3',
       CURRENT_TIMESTAMP AS 'LAST_UPDATED',
       'BULL_DATA' AS 'LAST_UPDATED_BY',
       0 AS 'IS_CAR',
       NULL AS 'MT3',
       CASE
           WHEN [O].[U_UtilizaLote] = 'Y' THEN
               1
           ELSE
               '0'
       END AS 'BATCH_REQUESTED',
       --, '0' 'BATCH_REQUESTED'
       CASE [O].[ManSerNum]
           WHEN 'Y' THEN
               CONVERT(VARCHAR(2), 1) COLLATE SQL_Latin1_General_CP1_CI_AS
           WHEN 'N' THEN
               CONVERT(VARCHAR(2), 0) COLLATE SQL_Latin1_General_CP1_CI_AS
       END AS 'SERIAL_NUMBER_REQUESTS',
       [w].[AvgPrice] AS 'ERP_AVERAGE_PRICE',
       [O].[InvntItem] AS 'INVT',
       [D].[Quantity] AS 'QUANTITY',
       [O].[ItemCode]
FROM [SAPSERVER].[SBOFERCO].[dbo].[ITT1] [D]
    INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[OITT] [H]
        ON ([D].[Father] = [H].[Code])
    INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[OITM] [O]
        ON ([D].[Code] = [O].[ItemCode])
    LEFT JOIN [SAPSERVER].[SBOFERCO].[dbo].[OITW] [w]
        ON [w].[ItemCode] = [O].[ItemCode]
           AND [w].[WhsCode] = '01'
WHERE [O].[InvntItem] = 'Y'
     -- AND [O].[frozenFor] = 'N'
--and O.Sellitem='Y'
--UNION ALL
--SELECT [H].[Code] AS [MATERIAL_ID_FATHER],
--       'DETALLES' AS 'CLIENT_OWNER',
--       [O].[ItemCode] AS 'MATERIAL_ID',
--       [O].[ItemCode] + '0' + ISNULL(SUBSTRING([O].[SalUnitMsr], 1, 2), '') AS 'BARCODE_ID',
--       [O].[ItemCode] + '0' AS 'ALTERNATE_BARCODE',
--       [O].[ItemName] AS 'MATERIAL_NAME',
--       [O].[ItemName] AS 'SHORT_NAME',
--       0 AS 'VOLUME_FACTOR',
--       '2' AS 'MATERIAL_CLASS',
--       [O].[SHeight1] AS 'HIGH',
--       [O].[SLength1] AS 'LENGTH',
--       [O].[SWidth1] AS 'WIDTH',
--       100 AS 'MAX_X_BIN',
--       0 AS 'SCAN_BY_ONE',
--       0 AS 'REQUIRES_LOGISTICS_INFO',
--       [SWeight1] AS 'WEIGTH',
--       CAST(NULL AS IMAGE) AS 'IMAGE_1',
--       CAST(NULL AS IMAGE) AS 'IMAGE_2',
--       CAST(NULL AS IMAGE) AS 'IMAGE_3',
--       CURRENT_TIMESTAMP AS 'LAST_UPDATED',
--       'BULL_DATA' AS 'LAST_UPDATED_BY',
--       0 AS 'IS_CAR',
--       NULL AS 'MT3',
--       --CASE
--       --    WHEN [O].[U_UtilizaLote] = 'Y' THEN
--       --        1
--       --    ELSE
--       --        '0'
--       --END AS 'BATCH_REQUESTED',
--       '0' [BATCH_REQUESTED],
--       CASE [O].[ManSerNum]
--           WHEN 'Y' THEN
--               CONVERT(VARCHAR(2), 1) COLLATE SQL_Latin1_General_CP1_CI_AS
--           WHEN 'N' THEN
--               CONVERT(VARCHAR(2), 0) COLLATE SQL_Latin1_General_CP1_CI_AS
--       END AS 'SERIAL_NUMBER_REQUESTS',
--       [w].[AvgPrice] AS 'ERP_AVERAGE_PRICE',
--       [O].[InvntItem] AS 'INVT',
--       [D].[Quantity] AS 'QUANTITY',
--       [O].[ItemCode]
--FROM [SAPSERVER].[Detalles].[dbo].[ITT1] [D]
--    INNER JOIN [SAPSERVER].[Detalles].[dbo].[OITT] [H]
--        ON ([D].[Father] = [H].[Code])
--    INNER JOIN [SAPSERVER].[Detalles].[dbo].[OITM] [O]
--        ON ([D].[Code] = [O].[ItemCode])
--    LEFT JOIN [SAPSERVER].[Detalles].[dbo].[OITW] [w]
--        ON [w].[ItemCode] = [O].[ItemCode]
--           AND [w].[WhsCode] = '01'
--WHERE [O].[InvntItem] = 'Y'
--      AND [O].[frozenFor] = 'N'
--and O.Sellitem='Y'
--UNION ALL
--SELECT [H].[Code] AS [MATERIAL_ID_FATHER],
--       'VOI7' AS 'CLIENT_OWNER',
--       [O].[ItemCode] AS 'MATERIAL_ID',
--       [O].[ItemCode] + '0' + ISNULL(SUBSTRING([O].[SalUnitMsr], 1, 2), '') AS 'BARCODE_ID',
--       [O].[ItemCode] + '0' AS 'ALTERNATE_BARCODE',
--       [O].[ItemName] AS 'MATERIAL_NAME',
--       [O].[ItemName] AS 'SHORT_NAME',
--       0 AS 'VOLUME_FACTOR',
--       '2' AS 'MATERIAL_CLASS',
--       [O].[SHeight1] AS 'HIGH',
--       [O].[SLength1] AS 'LENGTH',
--       [O].[SWidth1] AS 'WIDTH',
--       100 AS 'MAX_X_BIN',
--       0 AS 'SCAN_BY_ONE',
--       0 AS 'REQUIRES_LOGISTICS_INFO',
--       [SWeight1] AS 'WEIGTH',
--       CAST(NULL AS IMAGE) AS 'IMAGE_1',
--       CAST(NULL AS IMAGE) AS 'IMAGE_2',
--       CAST(NULL AS IMAGE) AS 'IMAGE_3',
--       CURRENT_TIMESTAMP AS 'LAST_UPDATED',
--       'BULL_DATA' AS 'LAST_UPDATED_BY',
--       0 AS 'IS_CAR',
--       NULL AS 'MT3',
--       --CASE
--       --    WHEN [O].[U_UtilizaLote] = 'Y' THEN
--       --        1
--       --    ELSE
--       --        '0'
--       --END AS 'BATCH_REQUESTED',
--       '0' [BATCH_REQUESTED],
--       CASE [O].[ManSerNum]
--           WHEN 'Y' THEN
--               CONVERT(VARCHAR(2), 1) COLLATE SQL_Latin1_General_CP1_CI_AS
--           WHEN 'N' THEN
--               CONVERT(VARCHAR(2), 0) COLLATE SQL_Latin1_General_CP1_CI_AS
--       END AS 'SERIAL_NUMBER_REQUESTS',
--       [w].[AvgPrice] AS 'ERP_AVERAGE_PRICE',
--       [O].[InvntItem] AS 'INVT',
--       [D].[Quantity] AS 'QUANTITY',
--       [O].[ItemCode]
--FROM [SAPSERVER].[CASA_OAKLAND].[dbo].[ITT1] [D]
--    INNER JOIN [SAPSERVER].[CASA_OAKLAND].[dbo].[OITT] [H]
--        ON ([D].[Father] = [H].[Code])
--    INNER JOIN [SAPSERVER].[CASA_OAKLAND].[dbo].[OITM] [O]
--        ON ([D].[Code] = [O].[ItemCode])
--    LEFT JOIN [SAPSERVER].[CASA_OAKLAND].[dbo].[OITW] [w]
--        ON [w].[ItemCode] = [O].[ItemCode]
--           AND [w].[WhsCode] = '01'
--WHERE [O].[InvntItem] = 'Y'
--      AND [O].[frozenFor] = 'N'
	 --and O.Sellitem='Y'
--	 UNION ALL
--	 --- ALMASA---
--	 SELECT [H].[Code] AS [MATERIAL_ID_FATHER],
--       'ALMASA' AS 'CLIENT_OWNER',
--       [O].[ItemCode] AS 'MATERIAL_ID',
--       [O].[ItemCode] + '0' + ISNULL(SUBSTRING([O].[SalUnitMsr], 1, 2), '') AS 'BARCODE_ID',
--       [O].[ItemCode] + '0' AS 'ALTERNATE_BARCODE',
--       [O].[ItemName] AS 'MATERIAL_NAME',
--       [O].[ItemName] AS 'SHORT_NAME',
--       0 AS 'VOLUME_FACTOR',
--       '2' AS 'MATERIAL_CLASS',
--       [O].[SHeight1] AS 'HIGH',
--       [O].[SLength1] AS 'LENGTH',
--       [O].[SWidth1] AS 'WIDTH',
--       100 AS 'MAX_X_BIN',
--       0 AS 'SCAN_BY_ONE',
--       0 AS 'REQUIRES_LOGISTICS_INFO',
--       [SWeight1] AS 'WEIGTH',
--       CAST(NULL AS IMAGE) AS 'IMAGE_1',
--       CAST(NULL AS IMAGE) AS 'IMAGE_2',
--       CAST(NULL AS IMAGE) AS 'IMAGE_3',
--       CURRENT_TIMESTAMP AS 'LAST_UPDATED',
--       'BULL_DATA' AS 'LAST_UPDATED_BY',
--       0 AS 'IS_CAR',
--       NULL AS 'MT3',
--       CASE
--           WHEN [O].[U_UtilizaLote] = 'Y' THEN
--               1
--           ELSE
--               '0'
--       END AS 'BATCH_REQUESTED',
--       --, '0' 'BATCH_REQUESTED'
--       CASE [O].[ManSerNum]
--           WHEN 'Y' THEN
--               CONVERT(VARCHAR(2), 1) COLLATE SQL_Latin1_General_CP1_CI_AS
--           WHEN 'N' THEN
--               CONVERT(VARCHAR(2), 0) COLLATE SQL_Latin1_General_CP1_CI_AS
--       END AS 'SERIAL_NUMBER_REQUESTS',
--       [w].[AvgPrice] AS 'ERP_AVERAGE_PRICE',
--       [O].[InvntItem] AS 'INVT',
--       [D].[Quantity] AS 'QUANTITY',
--       [O].[ItemCode]
--FROM [SAPSERVER].[SBO_ALMASA].[dbo].[ITT1] [D]
--    INNER JOIN [SAPSERVER].[SBO_ALMASA].[dbo].[OITT] [H]
--        ON ([D].[Father] = [H].[Code])
--    INNER JOIN [SAPSERVER].[SBO_ALMASA].[dbo].[OITM] [O]
--        ON ([D].[Code] = [O].[ItemCode])
--    LEFT JOIN [SAPSERVER].[SBO_ALMASA].[dbo].[OITW] [w]
--        ON [w].[ItemCode] = [O].[ItemCode]
--           AND [w].[WhsCode] = '01'
--WHERE [O].[InvntItem] = 'Y'
--      AND [O].[frozenFor] = 'N';

