
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2016-08-16
-- Description:			    Vista que obtiene los vendedores 

-- MODIFICADO 18-08-2016
--		diego.as
--		Se agregaron los campos SELLER_TYPE, SELLER_TYPE_DESCRIPTION, CODE_ROUTE, NAME_ROUTE, CODE_WAREHOUSE, NAME_WAREHOUSE a la vista

-- Modificacion 25-Apr-17 @ A-Team Sprint Hondo
-- alberto.ruiz
-- Se agrega la columna de GPS

-- Modificacion 08-Jun-17 @ A-Team Sprint Jibade
-- alberto.ruiz
-- Se agrega campo de source

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [ferco].[ERP_VIEW_SELLER]
*/
-- =============================================
CREATE VIEW ferco.ERP_VIEW_SELLER
AS
SELECT
  *
FROM OPENQUERY(SAPSERVER, 'SELECT     
	CONVERT(VARCHAR(50), BO.SlpCode) collate SQL_Latin1_General_CP1_CI_AS AS SELLER_CODE 
	,BO.SlpName COLLATE SQL_Latin1_General_CP1_CI_AS  AS SELLER_NAME
    ,MAX('') COLLATE SQL_Latin1_General_CP1_CI_AS AS SELLER_TYPE
    ,MAX('') COLLATE SQL_Latin1_General_CP1_CI_AS AS SELLER_TYPE_DESCRIPTION
    ,MAX('') COLLATE SQL_Latin1_General_CP1_CI_AS AS CODE_ROUTE
    ,MAX('') COLLATE SQL_Latin1_General_CP1_CI_AS AS NAME_ROUTE
    ,MAX('') COLLATE SQL_Latin1_General_CP1_CI_AS AS CODE_WAREHOUSE
    ,MAX('') COLLATE SQL_Latin1_General_CP1_CI_AS AS NAME_WAREHOUSE	
	,CAST(''ferco'' AS VARCHAR(50)) [OWNER]
	,CAST(''ferco'' AS VARCHAR(50)) [OWNER_ID]
	,CAST(''0,0'' AS VARCHAR(50)) [GPS]
	,CAST(''ferco'' AS VARCHAR(50))[SOURCE]
FROM         [SBOFERCO].dbo.OSLP AS BO 
WHERE     (BO.SlpCode > 0)
GROUP BY CONVERT(VARCHAR(50), slpcode) COLLATE SQL_Latin1_General_CP1_CI_AS
        ,[SlpName] COLLATE SQL_Latin1_General_CP1_CI_AS ')
