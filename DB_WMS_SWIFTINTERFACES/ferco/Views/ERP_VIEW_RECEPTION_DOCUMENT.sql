
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-13 Team ERGON - Sprint ERGON 1
-- Description:	 Consultar documentos de recepción de ERP 

-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 Team ERGON - Sprint ERGON 1
-- Description:	        Se agrego DocCur y DocRate


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint ERGON IV
-- Description:	 Se agrega para que retorne a su vez DocNum de SAP

-- Modificacion 09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- alberto.ruiz
-- Ajuste por SAPSERVER

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-11 @ Team REBORN - Sprint Drado-Collin
-- Description:	   Se agrega NumAtCard

/*
-- Ejemplo de Ejecucion:
			select * from [ferco].ERP_VIEW_RECEPTION_DOCUMENT 
*/
-- =============================================
CREATE VIEW [ferco].[ERP_VIEW_RECEPTION_DOCUMENT]
AS

SELECT
  *
FROM OPENQUERY([SAPSERVER], '
		SELECT
			P.DocEntry SAP_REFERENCE
			,''PO'' DOC_TYPE
			,''Pusher Order'' DESCRIPTION_TYPE
			,P.CardCode CUSTOMER_ID
			--,NULL COD_WAREHOUSE
			,P.CardName CUSTOMER_NAME
		  --,NULL WAREHOUSE_NAME
        ,P.DocDueDate DOC_DATE
      ,P.DocCur DOC_CUR
      ,P.DocRate DOC_RATE
      ,P.Comments COMMENTS
      ,P.DocNum 
		,P.CardCode [MASTER_ID_PROVIDER]
		,''ferco'' [OWNER_PROVIDER]
		,''ferco'' [OWNER]
    ,CASE P.NumAtCard
		 WHEN '''' THEN ''N/A''
		 ELSE ISNULL(P.NumAtCard, ''N/A'') 
	 END AS NumAtCard
    ,ISNULL(P.U_facSerie, ''N/A'') COLLATE DATABASE_DEFAULT  AS UFacserie
    ,ISNULL(P.U_facNum, ''N/A'') COLLATE DATABASE_DEFAULT  AS UFacnum   
    ,ISNULL(P.Series, ''-1'') AS Series
		FROM SBOFERCO.dbo.OPOR P
		WHERE P.DocStatus = ''O''
	')
--	UNION ALL
--		SELECT
--  *
--FROM OPENQUERY([SAPSERVER], '
--			SELECT
--			P.DocEntry SAP_REFERENCE
--			,''PO'' DOC_TYPE
--			,''Pusher Order'' DESCRIPTION_TYPE
--			,P.CardCode CUSTOMER_ID
--		--	,NULL COD_WAREHOUSE
--			,P.CardName CUSTOMER_NAME
--		--  ,NULL WAREHOUSE_NAME
--        ,P.DocDueDate DOC_DATE
--      ,P.DocCur DOC_CUR
--      ,P.DocRate DOC_RATE
--      ,P.Comments COMMENTS
--      ,P.DocNum 
--		,P.CardCode [MASTER_ID_PROVIDER]
--		,''ALMASA'' [OWNER_PROVIDER]
--		,''ALMASA'' [OWNER]
--    ,CASE P.NumAtCard
--		 WHEN '''' THEN ''N/A''
--		 ELSE ISNULL(P.NumAtCard, ''N/A'') 
--	 END AS NumAtCard
--    ,''N/A'' COLLATE DATABASE_DEFAULT  AS UFacserie
--    ,''N/A'' COLLATE DATABASE_DEFAULT  AS UFacnum   
--    ,ISNULL(P.Series, ''-1'') AS Series
--		FROM SBO_ALMASA.dbo.OPOR P
--		WHERE P.DocStatus = ''O''
--	')/*
--	UNION ALL	
--	SELECT
--  *
--FROM OPENQUERY([SAPSERVER], '
--		SELECT
--			P.DocEntry SAP_REFERENCE
--			,''PO'' DOC_TYPE
--			,''Pusher Order'' DESCRIPTION_TYPE
--			,P.CardCode CUSTOMER_ID
--		--	,NULL COD_WAREHOUSE
--			,P.CardName CUSTOMER_NAME
--		--  ,NULL WAREHOUSE_NAME
--        ,P.DocDueDate DOC_DATE
--      ,P.DocCur DOC_CUR
--      ,P.DocRate DOC_RATE
--      ,P.Comments COMMENTS
--      ,P.DocNum 
--		,P.CardCode [MASTER_ID_PROVIDER]
--		,''DETALLES'' [OWNER_PROVIDER]
--		,''DETALLES'' [OWNER]
--    ,CASE P.NumAtCard
--		 WHEN '''' THEN ''N/A''
--		 ELSE ISNULL(P.NumAtCard, ''N/A'') 
--	 END AS NumAtCard
--    ,''N/A'' COLLATE DATABASE_DEFAULT  AS UFacserie
--    ,''N/A'' COLLATE DATABASE_DEFAULT  AS UFacnum   
--    ,ISNULL(P.Series, ''-1'') AS Series
--		FROM DETALLES.dbo.OPOR P
--		WHERE P.DocStatus = ''O''
--	')*/
--	UNION ALL 
--		SELECT
--  *
--FROM OPENQUERY([SAPSERVER], '
--		SELECT
--			P.DocEntry SAP_REFERENCE
--			,''PO'' DOC_TYPE
--			,''Pusher Order'' DESCRIPTION_TYPE
--			,P.CardCode CUSTOMER_ID
--		--	,NULL COD_WAREHOUSE
--			,P.CardName CUSTOMER_NAME
--		--  ,NULL WAREHOUSE_NAME
--        ,P.DocDueDate DOC_DATE
--      ,P.DocCur DOC_CUR
--      ,P.DocRate DOC_RATE
--      ,P.Comments COMMENTS
--      ,P.DocNum 
--		,P.CardCode [MASTER_ID_PROVIDER]
--		,''VOI7'' [OWNER_PROVIDER]
--		,''VOI7'' [OWNER]
--    ,CASE P.NumAtCard
--		 WHEN '''' THEN ''N/A''
--		 ELSE ISNULL(P.NumAtCard, ''N/A'') 
--	 END AS NumAtCard
--    ,''N/A'' COLLATE DATABASE_DEFAULT  AS UFacserie
--    ,''N/A'' COLLATE DATABASE_DEFAULT  AS UFacnum   
--    ,ISNULL(P.Series, ''-1'') AS Series
--		FROM CASA_OAKLAND.dbo.OPOR P
--		WHERE P.DocStatus = ''O''
--	')
		
