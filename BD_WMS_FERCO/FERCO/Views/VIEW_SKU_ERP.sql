
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-31 @ Team ERGON - Sprint ERGON 1
-- Description:	 NA




/*
-- Ejemplo de Ejecucion:
			SELECT * FROM FERCO.VIEW_SKU_ERP where  material_id_sap = '5000165'
*/
-- =============================================
CREATE VIEW [FERCO].[VIEW_SKU_ERP]
AS
--SKU de FERCO
SELECT 'ferco' AS 'CLIENT_OWNER',
       'ferco' + '/' + [O].[ItemCode] AS 'MATERIAL_ID',
       [O].[ItemCode] AS 'MATERIAL_ID_SAP',
       [O].[ItemCode] + '0' + ISNULL(SUBSTRING([O].[SalUnitMsr], 1, 2), '') AS 'BARCODE_ID',
       [O].[ItemCode] + '0' AS 'ALTERNATE_BARCODE',
       [O].[ItemName] AS 'MATERIAL_NAME',
       [O].[ItemName] AS 'SHORT_NAME',
       0 AS 'VOLUME_FACTOR',
       '2' AS 'MATERIAL_CLASS',
       [O].[SHeight1] AS 'HIGH',
       [O].[SLength1] AS 'LENGTH',
       [O].[SWidth1] AS 'WIDTH',
       0 AS 'MAX_X_BIN',
       0 AS 'SCAN_BY_ONE',
       0 AS 'REQUIRES_LOGISTICS_INFO',
       [SWeight1] AS 'WEIGTH',
       CAST(NULL AS IMAGE) AS 'IMAGE_1',
       CAST(NULL AS IMAGE) 'IMAGE_2',
       CAST(NULL AS IMAGE) AS 'IMAGE_3',
       CURRENT_TIMESTAMP AS 'LAST_UPDATED',
       NULL AS 'LAST_UPDATED_BY',
       0 AS 'IS_CAR',
       NULL AS 'MT3',
       --,CASE
       --   WHEN O.U_UtilizaLote = 'S' THEN 1
       --   ELSE '0'
       -- END AS 'BATCH_REQUESTED'
       '0' 'BATCH_REQUESTED',
       0 AS 'SERIAL_NUMBER_REQUESTS',
       [w].[AvgPrice] AS 'ERP_AVERAGE_PRICE',
       [O].[InvntItem] AS 'INVT',
       CASE
           WHEN CAST([O].[U_UtilizaTono] AS VARCHAR) = 'S' THEN
               1
           ELSE
               0
       END AS 'HANDLE_TONE',
       --, '0' 'HANDLE_TONE'
       CASE
           WHEN CAST([O].[U_UtilizaCalibre] AS VARCHAR) = 'S' THEN
               1
           ELSE
               0
       END AS 'HANDLE_CALIBER',
       DATEDIFF(MONTH, [O].[CreateDate], GETDATE()) [Antiguedad]
--, '0' 'HANDLE_CALIBER'
FROM [SAPSERVER].[SBOFERCO].[dbo].[OITM] [O]
    LEFT JOIN [SAPSERVER].[SBOFERCO].[dbo].[OITW] [w]
        ON [w].[ItemCode] = [O].[ItemCode]
           AND [w].[WhsCode] = '01'
WHERE [O].[InvntItem] = 'Y'
--AND O.Sellitem = 'Y'
--OR ItemCode = '013956'
--UNION ALL
--SELECT 'DETALLES' AS 'CLIENT_OWNER',
--       'DETALLES' + '/' + [O].[ItemCode] AS 'MATERIAL_ID',
--       [O].[ItemCode] AS 'MATERIAL_ID_SAP',
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
--       CAST(NULL AS IMAGE) 'IMAGE_2',
--       CAST(NULL AS IMAGE) AS 'IMAGE_3',
--       CURRENT_TIMESTAMP AS 'LAST_UPDATED',
--       NULL AS 'LAST_UPDATED_BY',
--       0 AS 'IS_CAR',
--       NULL AS 'MT3',
--       '0' 'BATCH_REQUESTED',
--       0 AS 'SERIAL_NUMBER_REQUESTS',
--       [w].[AvgPrice] AS 'ERP_AVERAGE_PRICE',
--       [O].[InvntItem] AS 'INVT',
--       '0' 'HANDLE_TONE',
--       '0' 'HANDLE_CALIBER',
--       DATEDIFF(MONTH, [O].[CreateDate], GETDATE()) [Antiguedad]
--FROM [SAPSERVER].[Detalles].[dbo].[OITM] [O]
--    LEFT JOIN [SAPSERVER].[Detalles].[dbo].[OITW] [w]
--        ON [w].[ItemCode] = [O].[ItemCode]
--           AND [w].[WhsCode] = '01'
--WHERE [O].[InvntItem] = 'Y'
--      AND
--      (
--          [O].[ItemCode] IN
--          (
--              SELECT [AA].[ItemCode]
--              FROM [SAPSERVER].[Detalles].[dbo].[INV1] [AA]
--              WHERE [AA].[DocDate] >= '01-01-2013'
--          )
--          OR [O].[OnHand] > 0
--          OR DATEDIFF(year, [O].[CreateDate], GETDATE()) < 10
--      )
--UNION ALL
--SELECT 'VOI7' AS 'CLIENT_OWNER',
--       'VOI7' + '/' + [O].[ItemCode] AS 'MATERIAL_ID',
--       [O].[ItemCode] AS 'MATERIAL_ID_SAP',
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
--       CAST(NULL AS IMAGE) 'IMAGE_2',
--       CAST(NULL AS IMAGE) AS 'IMAGE_3',
--       CURRENT_TIMESTAMP AS 'LAST_UPDATED',
--       NULL AS 'LAST_UPDATED_BY',
--       0 AS 'IS_CAR',
--       NULL AS 'MT3',
--       '0' 'BATCH_REQUESTED',
--       0 AS 'SERIAL_NUMBER_REQUESTS',
--       [w].[AvgPrice] AS 'ERP_AVERAGE_PRICE',
--       [O].[InvntItem] AS 'INVT',
--       '0' 'HANDLE_TONE',
--       '0' 'HANDLE_CALIBER',
--       DATEDIFF(MONTH, [O].[CreateDate], GETDATE()) [Antiguedad]
--FROM [SAPSERVER].[CASA_OAKLAND].[dbo].[OITM] [O]
--    LEFT JOIN [SAPSERVER].[CASA_OAKLAND].[dbo].[OITW] [w]
--        ON [w].[ItemCode] = [O].[ItemCode]
--           AND [w].[WhsCode] = '01'
--WHERE [O].[InvntItem] = 'Y'
--      AND
--      (
--          [O].[ItemCode] IN
--          (
--              SELECT [AA].[ItemCode]
--              FROM [SAPSERVER].[CASA_OAKLAND].[dbo].[INV1] [AA]
--              WHERE [AA].[DocDate] >= '01-01-2015'
--          )
--          OR [O].[OnHand] > 0
--		  OR DATEDIFF(MONTH, [O].[CreateDate], GETDATE()) < 6
--      )
--	  UNION ALL
	  
--	  ----------INVENTARIO ALMASA----- 
--	  SELECT 'ALMASA' AS 'CLIENT_OWNER',
--       'ALMASA' + '/' + [O].[ItemCode] AS 'MATERIAL_ID',
--       [O].[ItemCode] AS 'MATERIAL_ID_SAP',
--       [O].[ItemCode] + '0' + ISNULL(SUBSTRING([O].[SalUnitMsr], 1, 2), '') AS 'BARCODE_ID',
--       [O].[ItemCode] + '0' AS 'ALTERNATE_BARCODE',
--       [O].[ItemName] AS 'MATERIAL_NAME',
--       [O].[ItemName] AS 'SHORT_NAME',
--       0 AS 'VOLUME_FACTOR',
--       '2' AS 'MATERIAL_CLASS',
--       [O].[SHeight1] AS 'HIGH',
--       [O].[SLength1] AS 'LENGTH',
--       [O].[SWidth1] AS 'WIDTH',
--       0 AS 'MAX_X_BIN',
--       0 AS 'SCAN_BY_ONE',
--       0 AS 'REQUIRES_LOGISTICS_INFO',
--       [SWeight1] AS 'WEIGTH',
--       CAST(NULL AS IMAGE) AS 'IMAGE_1',
--       CAST(NULL AS IMAGE) 'IMAGE_2',
--       CAST(NULL AS IMAGE) AS 'IMAGE_3',
--       CURRENT_TIMESTAMP AS 'LAST_UPDATED',
--       NULL AS 'LAST_UPDATED_BY',
--       0 AS 'IS_CAR',
--       NULL AS 'MT3',
--       --,CASE
--       --   WHEN O.U_UtilizaLote = 'S' THEN 1
--       --   ELSE '0'
--       -- END AS 'BATCH_REQUESTED'
--       '0' 'BATCH_REQUESTED',
--       0 AS 'SERIAL_NUMBER_REQUESTS',
--       [w].[AvgPrice] AS 'ERP_AVERAGE_PRICE',
--       [O].[InvntItem] AS 'INVT',
--       CASE
--           WHEN CAST([O].[U_UtilizaTono] AS VARCHAR) = 'S' THEN
--               1
--           ELSE
--               0
--       END AS 'HANDLE_TONE',
--       --, '0' 'HANDLE_TONE'
--       CASE
--           WHEN CAST([O].[U_UtilizaCalibre] AS VARCHAR) = 'S' THEN
--               1
--           ELSE
--               0
--       END AS 'HANDLE_CALIBER',
--       DATEDIFF(MONTH, [O].[CreateDate], GETDATE()) [Antiguedad]
----, '0' 'HANDLE_CALIBER'
--FROM [SAPSERVER].[SBO_ALMASA].[dbo].[OITM] [O]
--    LEFT JOIN [SAPSERVER].[SBO_ALMASA].[dbo].[OITW] [w]
--        ON [w].[ItemCode] = [O].[ItemCode]
--           AND [w].[WhsCode] = '01'
--WHERE [O].[InvntItem] = 'Y';

