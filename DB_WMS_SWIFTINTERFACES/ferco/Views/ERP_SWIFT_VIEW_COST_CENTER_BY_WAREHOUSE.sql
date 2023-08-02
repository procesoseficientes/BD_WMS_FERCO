


-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	11-05-2016
-- Description:			Obtiene los centros de costo por bodega de ERP

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [ferco].[ERP_SWIFT_VIEW_COST_CENTER_BY_WAREHOUSE]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_SWIFT_VIEW_COST_CENTER_BY_WAREHOUSE]
AS
SELECT  [Descr], [WhsCode] FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_COST_CENTER_BY_WAREHOUSE]