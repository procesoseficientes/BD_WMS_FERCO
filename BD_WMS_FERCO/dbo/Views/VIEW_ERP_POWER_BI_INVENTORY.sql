



-- =============================================
-- Autor:				Carlos.calel
-- Fecha de Creacion: 	17-05-2019
-- Description:			Vista que obtiene inventario con unidades, costo y precio 
/*
-- Ejemplo de Ejecucion:
		--
        dbo.VIEW_ERP_POWER_BI_INVENTORY
*/
--===============================
CREATE VIEW [dbo].[VIEW_ERP_POWER_BI_INVENTORY]
AS
    SELECT  OITW.ItemCode COLLATE DATABASE_DEFAULT COD_PRODUCTO ,
        SUM(OITW.OnHand) DISPONIBLE ,
        [OITM].[ItemName] DESCRIPCION ,
        MAX([OITW].[AvgPrice]) COSTO ,
        MAX([ITM1].[Price]) PRECIO
FROM    [SAPSERVER].[SBOFERCO].[dbo].[OITW] OITW
        INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[OITM] OITM ON OITW.ItemCode = OITM.ItemCode
        INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[UGP1] UGP1 ON UGP1.UgpEntry = OITM.UgpEntry
        INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[OUOM] OUOM ON OUOM.UomEntry = UGP1.UomEntry
        INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[ITM1] ITM1 ON OITW.ItemCode = ITM1.ItemCode
WHERE   [OITW].[OnHand] > 0
GROUP BY OITW.ItemCode ,
        [OITM].[ItemName];


