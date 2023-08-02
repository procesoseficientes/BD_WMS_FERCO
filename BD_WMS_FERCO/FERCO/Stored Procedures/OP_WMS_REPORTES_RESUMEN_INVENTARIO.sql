
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_REPORTES_RESUMEN_INVENTARIO
-- Add the parameters for the stored procedure here
@CLASIFICACION VARCHAR(250),
@DATE VARCHAR(250),
@REGIMEN VARCHAR(250)

AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

  -- Insert statements for procedure here

  IF @CLASIFICACION = 'BODEGA'
  BEGIN
    SELECT
      BODEGA
     ,REGIMEN
     ,SUM(TOTAL_VALOR) AS 'TOTAL_VALOR'
    FROM [FERCO].OP_WMS_INV_HISTORY
    WHERE (SNAPSHOT_DATE BETWEEN CAST(@DATE + ' 00:00AM' AS DATETIME) AND CAST(@DATE + ' 23:59PM' AS DATETIME))
    AND REGIMEN = @REGIMEN
    AND QTY > 0
    GROUP BY BODEGA
            ,REGIMEN
  END
  ELSE
  IF @CLASIFICACION = 'CLIENTE'
  BEGIN
    SELECT
      CLIENT_NAME
     ,regimen
     ,SUM(TOTAL_VALOR) AS 'TOTAL_VALOR'
    FROM [FERCO].OP_WMS_INV_HISTORY
    WHERE (SNAPSHOT_DATE BETWEEN CAST(@DATE + ' 00:00AM' AS DATETIME) AND CAST(@DATE + ' 23:59PM' AS DATETIME))
    AND REGIMEN = @REGIMEN
    AND QTY > 0
    GROUP BY CLIENT_NAME
            ,REGIMEN

  END
END
