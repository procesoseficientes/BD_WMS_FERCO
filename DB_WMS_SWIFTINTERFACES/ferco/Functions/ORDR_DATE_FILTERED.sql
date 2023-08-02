
-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- Description:			    Se crea una funcion de tabla para 

-- Modificacion 9/21/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agregan filtros de fecha

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ORDR_DATE_FILTERED](getdate()-30,getdate())
*/
-- =============================================
CREATE FUNCTION ferco.ORDR_DATE_FILTERED (@START_DATE DATETIME,
@END_DATE DATETIME)
RETURNS @ORDR TABLE (
  [DocEntry] INT
 ,[DocNum] INT
 ,[DocTotal] NUMERIC(18, 6)
 ,[DocDueDate] DATETIME
 ,[CardCode] NVARCHAR(15)
 ,[U_MasterIDCustomer] NVARCHAR(50)
 ,[U_OwnerCustomer] NVARCHAR(30)
 ,[DocDate] DATETIME
 ,[DocStatus] CHAR(1)
 ,[U_Serie] NVARCHAR(20)
 ,[U_NoDocto] NVARCHAR(20)
 ,[CardName] NVARCHAR(100)
 ,[U_OPER] NVARCHAR(40)
 ,[DiscPrcnt] NUMERIC(18, 6)
 ,[CANCELED] CHAR(1)
 ,[Comments] NVARCHAR(254)
 ,[Address] NVARCHAR(254)
 ,[Address2] NVARCHAR(254)
 ,[DocCur] NVARCHAR(3)
 ,[DocRate] NUMERIC(18, 6)
 ,[SlpCode] INT
 ,[U_Owner] NVARCHAR(30)
)
AS
BEGIN
  INSERT INTO @ORDR ([DocEntry]
  , [DocNum]
  , [DocTotal]
  , [DocDueDate]
  , [CardCode]
  , [U_MasterIDCustomer]
  , [U_OwnerCustomer]
  , [DocDate]
  , [DocStatus]
  , [U_Serie]
  , [U_NoDocto]
  , [CardName]
  , [U_OPER]
  , [DiscPrcnt]
  , [CANCELED]
  , [Comments]
  , [Address]
  , [Address2]
  , [DocCur]
  , [DocRate]
  , [SlpCode]
  , [U_Owner])
    SELECT
      [SO].[DocEntry]
     ,[SO].[DocNum]
     ,[SO].[DocTotal]
     ,[SO].[DocDueDate]
     ,[SO].[CardCode]
     ,[CRD].[CardCode] [U_MasterIDCustomer]
     ,'Ferco' [U_OwnerCustomer]
     ,[SO].[DocDate]
     ,[SO].[DocStatus]
     ,[SO].[U_FacSerie] [U_Serie]
     ,[SO].[U_FacNum] [U_NoDocto]
     ,[CRD].[CardName]
     ,NULL AS [U_OPER]
     ,[SO].[DiscPrcnt]
     ,[SO].[CANCELED]
     ,[SO].[Comments]
     ,[SO].[Address]
     ,[SO].[Address2]
     ,[SO].[DocCur]
     ,[SO].[DocRate]
     ,[SO].[SlpCode]
     ,'Ferco' [U_Owner]
    FROM [SAPSERVER].SBOPYM.dbo.ORDR [SO]
    INNER JOIN [SAPSERVER].SBOPYM.dbo.[OCRD] [CRD]
      ON [SO].[CardCode] = [CRD].[CardCode]
    WHERE [SO].[DocDueDate] >= CAST(@START_DATE AS DATE)
    AND [SO].[DocDueDate] <= CAST(@END_DATE AS DATE)
  RETURN;
END



