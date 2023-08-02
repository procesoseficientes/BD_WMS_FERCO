-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		08-Jun-17 @ A-Team Sprint Jibade 
-- Description:			    Vista para el codigo de vendedor por cada base de datos de la multiempresa

-- Modificacion 6/23/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se comento la parte de intercompany para las que se obtengan los datos cuando este no es intercompany

-- Modificacion 8/22/2017 @ NEXUS-Team Sprint CommandAndConquer	
					-- rodrigo.gomez
					-- Se agrega columna serie para intercompany

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_SELLER_SOURCE]
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_SELLER_SOURCE]
AS (
	/*
	SELECT
		[U_MasterID] [MASTER_ID]
		,[SlpCode] [SLP_CODE]
		,[SOURCE] [SOURCE]
	FROM [SAP_INTERCOMPANY].[dbo].[OSLP]
	WHERE [U_MasterID] IS NOT NULL
	*/
	select *from openquery (SAPSERVER,'
	SELECT     
		BO.SlpCode AS MASTER_ID 
		,BO.SlpCode AS SLP_CODE	
		,CAST(''ferco'' AS VARCHAR(50))[SOURCE]
		, -1 SERIE
	FROM         [SBOFERCO].dbo.OSLP AS BO 
	WHERE     (BO.SlpCode > 0) ')

)