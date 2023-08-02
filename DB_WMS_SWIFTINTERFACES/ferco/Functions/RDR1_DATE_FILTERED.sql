
-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- Description:			    Se crea una funcion de tabla para 

-- Modificacion 9/21/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agregan filtros de fecha

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [RDR1_DATE_FILTERED](getdate()-30,getdate())
*/
-- =============================================
CREATE FUNCTION ferco.RDR1_DATE_FILTERED (@START_DATE DATETIME,
@END_DATE DATETIME)
RETURNS @RDR1 TABLE (
  [DocEntry] INT
 ,[LineNum] INT
 ,[ItemCode] NVARCHAR(20)
 ,[U_MasterIdSKU] NVARCHAR(50)
 ,[U_OwnerSKU] NVARCHAR(30)
 ,[Dscription] NVARCHAR(100)
 ,[Quantity] NUMERIC
 ,[LineTotal] NUMERIC(18, 6)
 ,[Price] NUMERIC(18, 6)
 ,[PriceAfVAT] NUMERIC(18, 6)
 ,[WhsCode] NVARCHAR(8)
 ,[U_Owner] NVARCHAR(30)
)
AS
BEGIN
  INSERT INTO @RDR1 ([DocEntry]
  , [LineNum]
  , [ItemCode]
  , [U_MasterIdSKU]
  , [U_OwnerSKU]
  , [Dscription]
  , [Quantity]
  , [LineTotal]
  , [Price]
  , [PriceAfVAT]
  , [WhsCode]
  , [U_Owner])
    SELECT DISTINCT
      [RDR1].[DocEntry]
     ,[RDR1].[LineNum]
     ,[RDR1].[ItemCode]
     ,[RDR1].[ItemCode] [U_MasterIdSKU]
     ,'Ferco' [U_OwnerSKU]
     ,[RDR1].[Dscription]
     ,[RDR1].[Quantity]
     ,[RDR1].[LineTotal]
     ,[RDR1].[Price]
     ,[RDR1].[PriceAfVAT]
     ,[RDR1].[WhsCode]
     ,'Ferco' [U_Owner]
    FROM [SAPSERVER].SBOPYM.[dbo].[RDR1]
    INNER JOIN [SAPSERVER].SBOPYM.[dbo].[ORDR] [RDR]
      ON [RDR1].[DocEntry] = [RDR].[DocEntry]
    INNER JOIN [SAPSERVER].SBOPYM.[dbo].[OITM] [ITM]
      ON [ITM].[ItemCode] = [RDR1].[ItemCode]
    WHERE [RDR].[DocDueDate] >= CAST(@START_DATE AS DATE)
    AND [RDR].[DocDueDate] <= CAST(@END_DATE AS DATE)
  RETURN;
END



