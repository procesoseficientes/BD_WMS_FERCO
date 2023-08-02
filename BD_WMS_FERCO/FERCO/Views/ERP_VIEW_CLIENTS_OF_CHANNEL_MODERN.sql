
-- =============================================
-- Autor:                hector.gonzalez
-- Fecha de Creacion:   2017-04-04 TeamErgon Sprint hyper
-- Description:          Vista que trae el los clientes y vendedores de el canal moderno


/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [FERCO].ERP_VIEW_CLIENTS_OF_CHANNEL_MODERN
          
*/
-- =============================================
CREATE VIEW FERCO.ERP_VIEW_CLIENTS_OF_CHANNEL_MODERN
AS

SELECT
  *
FROM OPENQUERY([SAPSERVER], '
SELECT DISTINCT
T0.CardCode AS CLIENT_ID,
T0.CardName AS CLIENT_NAME

FROM [SBOFERCO].[dbo].ORDR T0 
  WHERE T0.CANCELED <> ''C''
AND T0.CardCode  NOT LIKE ''SO%''

')
