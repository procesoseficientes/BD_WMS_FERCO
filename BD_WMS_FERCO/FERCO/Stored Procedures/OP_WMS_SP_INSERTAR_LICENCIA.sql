
-- =============================================
-- Autor:				jose.garcia	
-- Fecha de Creacion: 	04-04-2016
-- Description:			Agregra una nueva licencia para la carga del inventario
--						por archivos externos

/*
-- Ejemplo de Ejecucion:
				exec [FERCO].[OP_WMS_SP_INSERTAR_LICENCIA]
				    @CUSTOMER= 'C00277'
				   ,@WAREHOUSE= 'BODEGA_04'
				   ,@LOCATION ='B04-TA-C04-NU'
				   ,@USER= 'Oper1'
				   ,@IDENTITY=''
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_INSERTAR_LICENCIA @CUSTOMER VARCHAR(25)
, @WAREHOUSE VARCHAR(25) = ''
, @LOCATION VARCHAR(25) = ''
, @USER VARCHAR(15)
, @IDENTITY VARCHAR(250) OUTPUT
, @fecha DATE

AS

  DECLARE @NumeroPoliza VARCHAR(20)
  --,@fecha date= getdate() select
  SET @NumeroPoliza = (SELECT
      FORMAT(@fecha, 'ddMMyyyy') AS NumeroPoliza);

  BEGIN TRY

    INSERT INTO [FERCO].[OP_WMS_LICENSES] ([CLIENT_OWNER]
    , [CODIGO_POLIZA]
    , [CURRENT_WAREHOUSE]
    , [CURRENT_LOCATION]
    , [LAST_LOCATION]
    , [LAST_UPDATED]
    , [LAST_UPDATED_BY]
    , [STATUS]
    , [REGIMEN]
    , [CREATED_DATE]
    , [USED_MT2])
      VALUES (@CUSTOMER, @NumeroPoliza, @WAREHOUSE, @LOCATION, NULL, GETDATE(), @USER, 'ALLOCATED', 'GENERAL', GETDATE(), 0)

    SELECT
      @IDENTITY = (SELECT
          SCOPE_IDENTITY() AS [SCOPE_IDENTITY]);

    IF @@error = 0
    BEGIN
      RETURN @IDENTITY --[LICENCIA_CODIGO]-- Resultado
    END
    ELSE
    BEGIN

      SELECT
        -1 AS Resultado
       ,ERROR_MESSAGE() Mensaje
       ,@@ERROR Codigo
    END

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH
