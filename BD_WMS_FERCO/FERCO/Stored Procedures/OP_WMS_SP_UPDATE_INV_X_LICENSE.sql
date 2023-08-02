
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			Resta el inventario de la tabla inv_x_licencia
/*
-- Ejemplo de Ejecucion:				
				--
				exec [FERCO].[OP_WMS_SP_UPDATE_INV_X_LICENSE] 
							@QTY ='75'
							,@Code_sku ='110017' 
							,@CUSTOMER ='C00330'
							,@RESULTADO =''
				--				
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_UPDATE_INV_X_LICENSE @QTY AS INT
, @Code_sku AS VARCHAR(100)
, @CUSTOMER AS VARCHAR(100)
, @RESULTADO AS VARCHAR(150) OUTPUT
AS

  DECLARE @ACTUAL AS INT
         ,@ERROR AS VARCHAR(150)
         ,@Disponible INT
         ,@TOTAL AS INT
         ,@LICENCIA AS INT
         ,@Registro INT = 0
         ,@codigo AS VARCHAR(100) = @CUSTOMER + '/' + @Code_sku

  SELECT
    @TOTAL = SUM(QTY)
  FROM [FERCO].[OP_WMS_INV_X_LICENSE]
  WHERE MATERIAL_ID = @Codigo
  --SELECT @TOTAL TOTAL

  SELECT TOP 1
    @Registro = 1
  FROM [FERCO].[OP_WMS_INV_X_LICENSE]
  WHERE MATERIAL_ID = @Codigo

  IF (@Registro = 0)
  BEGIN
    SET @RESULTADO = 'EL CODIGO -> ' + @Codigo + ' <- NO EXISTE '
    SELECT
      @RESULTADO AS RESULTADO
  END
  ELSE
  BEGIN

    IF (@TOTAL >= @QTY)
    BEGIN
      -- SET @RESULTADO = 'SI CUBRE' SELECT @RESULTADO AS RESULTADO

      WHILE @QTY > 0
      BEGIN
      --OBTIENE EL VALOR TOTAL DE LA LICENCIA
      SELECT TOP 1
        @ACTUAL = (QTY)
      FROM [FERCO].[OP_WMS_INV_X_LICENSE]
      WHERE MATERIAL_ID = @Codigo
      AND QTY > 0
      --SELECT @ACTUAL LICENCIA_A_RESTAR

      --OBTIENE LA LICENCIA A RESTAR
      SELECT TOP 1
        @LICENCIA = LICENSE_ID
      FROM [FERCO].[OP_WMS_INV_X_LICENSE]
      WHERE MATERIAL_ID = @Codigo
      AND QTY > 0

      --SELECT @LICENCIA AS LICENCIA_NUMERO
      --RESTA TODA LA LICENCIA, SI ES MAYOR LA SALIDA
      IF (@ACTUAL < @QTY)
      BEGIN

        SET @QTY = @QTY - @ACTUAL
        -- SELECT @QTY RESTANTE_RESTANTE_RESTANTE

        UPDATE [FERCO].[OP_WMS_INV_X_LICENSE]
        SET QTY = 0
           ,ENTERED_QTY = @QTY
        WHERE MATERIAL_ID = @Codigo
        AND LICENSE_ID = @LICENCIA
      END
      ELSE
      --SELECT @QTY EEEEEEEE
      BEGIN
        UPDATE [FERCO].[OP_WMS_INV_X_LICENSE]
        SET QTY = QTY - @QTY
        WHERE MATERIAL_ID = @Codigo
        AND LICENSE_ID = @LICENCIA
        SET @RESULTADO = 'EL CODIGO -> ' + @Codigo + ' <- Actualizado correctamente'
        SELECT
          @RESULTADO AS RESULTADO
        RETURN
      END
      END
    END
    ELSE
    BEGIN
      SET @RESULTADO = 'EL CODIGO -> ' + @Codigo + ' <- NO CUBRE LA CANTIDAD A RESTAR'
      SELECT
        @RESULTADO AS RESULTADO
    END

  END
