


-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	11-05-2016
-- Description:			Obtiene los centros de costo por bodega

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [ferco].[ERP_VIEW_COST_CENTER_BY_WAREHOUSE]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_COST_CENTER_BY_WAREHOUSE]
AS
--select * from openquery (SAPSERVER,'SELECT  T1.Descr, T0.WhsCode
--										  FROM [FERCO].[dbo].OWHS T0
--										  INNER JOIN [FERCO].[dbo].UFD1 T1 ON (T0.U_CBAlmacen = T1.IndexID)
--										  WHERE  T1.TableID = ''OWHS'' ')

select  [Descr], [WhsCode] from openquery (SAPSERVER,'SELECT  T0.WhsName Descr,T0.WhsCode WhsCode
										  FROM [SBOFERCO].[dbo].OWHS T0')