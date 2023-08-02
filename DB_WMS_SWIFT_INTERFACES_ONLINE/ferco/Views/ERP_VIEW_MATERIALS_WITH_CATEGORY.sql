
-- =============================================
-- Autor:				 hector.gonzalez
-- Fecha de Creacion: 2017-10-11
-- Description:			Vista que obtiene los materiales con sus respectivas familias (categorias)

/*
-- Ejemplo de Ejecucion:
				-- 
				SELECT * FROM [ferco].[ERP_VIEW_MATERIALS_WITH_CATEGORY]
*/
-- =============================================  
CREATE VIEW ferco.ERP_VIEW_MATERIALS_WITH_CATEGORY
AS


SELECT
  CAST('ferco/' AS VARCHAR(6)) + CAST(O.ItemCode AS VARCHAR(50)) AS ITEM_CODE
 ,O.ItemCode AS ITEM_CODE_ERP
 ,O.ItemName AS ITEM_NAME
 ,C.Code AS CATEGORY_CODE
 ,C.NAME AS CATEGORY_NAME
FROM SAPSERVER.SBOFERCO.dbo.OITM AS O
INNER JOIN SAPSERVER.SBOFERCO.dbo.[@CATEGORIA] AS C
  ON (
    O.U_Categoria = C.Code
    )
