-- =============================================
-- Autor:				Gustavo.Garcia
-- Fecha de Creacion: 	10/05/20201

-- =============================================
CREATE VIEW [FERCO].[ViEW_INVENTORY_ONLINE_GRUPED]
AS
	SELECT * 
	FROM OPENQUERY(WMSSERVER, 'EXEC  OP_WMS_FERCO.[FERCO].[OP_WMS_SP_GET_INVENTORY_ONLINE_INVENTORY] @LOGIN = ''ADMIN''')