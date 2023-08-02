
-- =============================================
-- Autor:                hector.gonzalez
-- Fecha de Creacion:   2017-04-04 TeamErgon Sprint hyper
-- Description:          Vista que trae el los clientes y vendedores de el canal moderno

-- Modificacion 8/8/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- rodrigo.gomez
-- Se agregan las columnas SAPSERVER

-- Modificacion 9/24/2017 @ NEXUS-Team Sprint Duckhunt
-- rodrigo.gomez
-- Se agrega campo de direccion y departamento
/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].ERP_VIEW_CLIENTS_OF_CHANNEL_MODERN
          
*/
-- =============================================
CREATE VIEW ferco.ERP_VIEW_CLIENTS_OF_CHANNEL_MODERN
AS


SELECT
  *
FROM OPENQUERY([SAPSERVER], '

SELECT DISTINCT
  T0.CardCode AS CLIENT_ID
  ,T0.CardName AS CLIENT_NAME
  ,''ferco'' AS MASTER_ID
  ,''ferco'' AS OWNER
  ,T0.[Address2] AS ADDRESS_CUSTOMER
  ,T1.[StateS] AS STATE_CODE
  ,T0.DocDueDate as DOC_DATE
FROM [SBOFERCO].dbo.ORDR T0 
	INNER JOIN [SBOFERCO].dbo.RDR12 T1 ON T0.DocEntry = T1.DocEntry
WHERE T0.[DocStatus] <> ''C''
AND T0.CardCode  NOT LIKE ''SO%''

ORDER BY 1 DESC')
