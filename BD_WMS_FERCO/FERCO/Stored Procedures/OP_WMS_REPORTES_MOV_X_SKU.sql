﻿
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_REPORTES_MOV_X_SKU
-- Add the parameters for the stored procedure here

@FECFIN VARCHAR(250),
@FECINI VARCHAR(250),

@MATERIAL_NAME AS VARCHAR(250) = NULL,
@MATERIAL_ID AS VARCHAR(250) = NULL,
@CLIENT_NAME AS VARCHAR(250) = NULL,

@REGIMEN AS VARCHAR(15)
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

  -- Insert statements for procedure here

  SELECT
    A.SERIAL_NUMBER
   ,A.TRANS_DATE
   ,A.TRANS_DESCRIPTION
   ,A.CODIGO_POLIZA
   ,C.NUMERO_ORDEN
   ,A.CLIENT_NAME
   ,C.REGIMEN
   ,A.MATERIAL_BARCODE
   ,A.MATERIAL_DESCRIPTION
   ,A.QUANTITY_UNITS AS ENTRADA
   ,'0 ' AS SALIDA
  FROM [FERCO].OP_WMS_TRANS A
  LEFT JOIN [FERCO].OP_WMS_LICENSES B
    ON A.LICENSE_ID = B.LICENSE_ID
  LEFT JOIN [FERCO].OP_WMS_POLIZA_HEADER C
    ON B.CODIGO_POLIZA = C.CODIGO_POLIZA
      AND B.REGIMEN = C.WAREHOUSE_REGIMEN
  LEFT JOIN [FERCO].OP_WMS_MATERIALS D
    ON A.MATERIAL_BARCODE = D.ALTERNATE_BARCODE
  WHERE MATERIAL_NAME = ISNULL(@MATERIAL_NAME, MATERIAL_NAME)
  AND MATERIAL_ID = ISNULL(@MATERIAL_ID, MATERIAL_ID)
  AND CLIENT_NAME = ISNULL(@CLIENT_NAME, CLIENT_NAME)
  AND B.REGIMEN = @REGIMEN
  AND/**/ A.TRANS_DESCRIPTION LIKE 'IN%'
  AND TRANS_DATE BETWEEN CAST(@FECINI + ' 00:00:00.000' AS DATE) AND CAST(@FECFIN + ' 23:59:59.999' AS DATE)
  UNION
  SELECT
    A.SERIAL_NUMBER
   ,A.TRANS_DATE
   ,A.TRANS_DESCRIPTION
   ,A.CODIGO_POLIZA
   ,C.NUMERO_ORDEN
   ,A.CLIENT_NAME
   ,C.REGIMEN
   ,A.MATERIAL_BARCODE
   ,A.MATERIAL_DESCRIPTION
   ,'0'
   ,A.QUANTITY_UNITS AS SALIDA
  FROM [FERCO].OP_WMS_TRANS A
  LEFT JOIN [FERCO].OP_WMS_LICENSES B
    ON A.LICENSE_ID = B.LICENSE_ID
  LEFT JOIN [FERCO].OP_WMS_POLIZA_HEADER C
    ON A.CODIGO_POLIZA = C.CODIGO_POLIZA
      AND B.REGIMEN = C.WAREHOUSE_REGIMEN
  LEFT JOIN [FERCO].OP_WMS_MATERIALS D
    ON A.MATERIAL_BARCODE = D.ALTERNATE_BARCODE
  WHERE MATERIAL_NAME = ISNULL(@MATERIAL_NAME, MATERIAL_NAME)
  AND MATERIAL_ID = ISNULL(@MATERIAL_ID, MATERIAL_ID)
  AND CLIENT_NAME = ISNULL(@CLIENT_NAME, CLIENT_NAME)
  AND B.REGIMEN = @REGIMEN/*    */ AND/**/ (A.TRANS_DESCRIPTION LIKE 'TRA%'
  OR A.TRANS_DESCRIPTION LIKE 'DES%')
  AND TRANS_DATE BETWEEN CAST(@FECINI + ' 00:00:00.000' AS DATE) AND CAST(@FECFIN + ' 23:59:59.999' AS DATE)

END