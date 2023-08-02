
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-20 @ Team ERGON - Sprint ERGON III
-- Description:	 Insertar en encabezado de conteo.




/*
-- Ejemplo de Ejecucion:

EXEC [FERCO].[OP_WMS_SP_INSERT_PHYSICAL_COUNTS_HEADER] @TASK_ID = 2
                                                         ,@REGIMEN = 'GENERAL'
                                                         ,@DISTRIBUTION_CENTER = '454'
  SELECT * FROM [FERCO].[OP_WMS_PHYSICAL_COUNTS_HEADER] 
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_INSERT_PHYSICAL_COUNTS_HEADER (@TASK_ID INT
, @REGIMEN VARCHAR(50)
, @DISTRIBUTION_CENTER VARCHAR(200))
AS
BEGIN
  SET NOCOUNT ON;
  --
  INSERT INTO [FERCO].[OP_WMS_PHYSICAL_COUNTS_HEADER] ([TASK_ID], [REGIMEN], [DISTRIBUTION_CENTER], [STATUS])
    VALUES (@TASK_ID, @REGIMEN, @DISTRIBUTION_CENTER, 'CREATED');

  DECLARE @DOC_ID INT = SCOPE_IDENTITY()
  IF @@ERROR <> 0
  BEGIN

    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
     ,'0' DbData

  END
  ELSE
  BEGIN
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@DOC_ID AS VARCHAR) DbData
  END

END
