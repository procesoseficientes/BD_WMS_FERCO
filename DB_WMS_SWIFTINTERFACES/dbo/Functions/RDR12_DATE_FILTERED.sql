
-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- Description:			    Se crea una funcion de tabla para 

-- Modificacion 9/21/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agregan filtros de fecha

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [RDR12_DATE_FILTERED](getdate()-30,getdate())
*/
-- =============================================
CREATE FUNCTION dbo.RDR12_DATE_FILTERED (@START_DATE DATETIME,
@END_DATE DATETIME)
RETURNS @RDR12 TABLE (
  [DocEntry] INT
 ,[AddrTypeS] NVARCHAR(100)
 ,[StreetS] NVARCHAR(100)
 ,[StateS] NVARCHAR(3)
 ,[CountyS] NVARCHAR(100)
 ,[CountryS] NVARCHAR(3)
 ,[U_Owner] NVARCHAR(30)
)
AS
BEGIN
  INSERT INTO @RDR12 ([DocEntry]
  , [AddrTypeS]
  , [StreetS]
  , [StateS]
  , [CountyS]
  , [CountryS]
  , [U_Owner])
    SELECT
      [SO].[DocEntry]
     ,[SO].[AddrTypeS]
     ,[SO].[StreetS]
     ,[SO].[StateS]
     ,[SO].[CountyS]
     ,[SO].[CountryS]
     ,'Ferco' [U_Owner]
    FROM [SAPSERVER].SBOPYM.[dbo].[RDR12] [SO]
    INNER JOIN [SAPSERVER].SBOPYM.[dbo].[ORDR] [RDR]
      ON [RDR].[DocEntry] = [SO].[DocEntry]
    WHERE [RDR].[DocDueDate] >= CAST(@START_DATE AS DATE)
    AND [RDR].[DocDueDate] <= CAST(@END_DATE AS DATE)

  RETURN;
END



