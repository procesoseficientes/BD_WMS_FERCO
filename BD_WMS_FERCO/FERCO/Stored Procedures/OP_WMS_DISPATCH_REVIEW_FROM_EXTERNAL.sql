﻿
-- =============================================
-- Autor:				JOSE.GARCIA
-- Fecha de Creacion: 	17-ENERO-17 
-- Description:			GENERA LOS MATERIALES A INSERTAR 
--						EN EL INVENTARIO EXTERNO

/*
-- Ejemplo de Ejecucion:
				--
				

		EXEC [FERCO].[OP_WMS_DISPATCH_REVIEW_FROM_EXTERNAL]
						@CLIENTE ='C00330',
						@SKU = '1768',
						@SKU_NAME = 'TOMATES',
						@QTY_REQUESTED = 0,
						@LOGIN = 'FRM'
				
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_DISPATCH_REVIEW_FROM_EXTERNAL (@CLIENTE VARCHAR(50),
@SKU VARCHAR(50),
@SKU_NAME VARCHAR(150),
@QTY_REQUESTED NUMERIC(18, 2),
@LOGIN VARCHAR(25))
AS
  DECLARE @ERROR VARCHAR(250) = 'Error: '
  DECLARE @TRANS VARCHAR(250) = ''
  DECLARE @RESUMEN VARCHAR(250) = ':'
  BEGIN
    BEGIN TRY

      IF (@QTY_REQUESTED <= 0)
        RETURN -1

      DELETE FROM [FERCO].[OP_WMS_DISPATCH_FROM_EXTERNAL]
      WHERE LOGIN_ID = UPPER(@LOGIN)
        AND [MATERIAL_ID] = (@CLIENTE + '/' + @SKU)

      -----------------------------------------------------------------
      --VALIDA SI EXISTE EL ITEM
      -----------------------------------------------------------------	
      DECLARE @RESULTADO_MATERIALES VARCHAR(150);
      DECLARE @QTY_ON_HAND NUMERIC(18, 2);

      IF NOT EXISTS (SELECT
            1
          FROM [FERCO].OP_WMS_INV_X_LICENSE
          WHERE MATERIAL_ID = (@CLIENTE + '/' + @SKU))
      BEGIN

        INSERT INTO [FERCO].[OP_WMS_DISPATCH_FROM_EXTERNAL] ([LOGIN_ID]
        , [MATERIAL_ID]
        , [MATERIAL_NAME]
        , [QTY_REQUESTED]
        , [QTY_ONHAND]
        , [PROCESS_RESULT]
        , [PROCESS_STAMP], [READY_TO_GO])
          VALUES (@LOGIN, @CLIENTE + '/' + @SKU, @SKU_NAME, @QTY_REQUESTED, 0, 'SKU NO EXISTE EN INVETARIO', GETDATE(), 0)
        RETURN 0
      END

      SET @QTY_ON_HAND = ISNULL((SELECT
          SUM(QTY)
        FROM [FERCO].OP_WMS_INV_X_LICENSE
        WHERE MATERIAL_ID = (@CLIENTE + '/' + @SKU))
      , 0)

      IF (@QTY_ON_HAND < @QTY_REQUESTED)
      BEGIN
        INSERT INTO [FERCO].[OP_WMS_DISPATCH_FROM_EXTERNAL] ([LOGIN_ID]
        , [MATERIAL_ID]
        , [MATERIAL_NAME]
        , [QTY_REQUESTED]
        , [QTY_ONHAND]
        , [PROCESS_RESULT]
        , [PROCESS_STAMP], [READY_TO_GO])
          VALUES (@LOGIN, @CLIENTE + '/' + @SKU, @SKU_NAME, @QTY_REQUESTED, @QTY_ON_HAND, 'INVENTARIO INSUFICIENTE', GETDATE(), 0)
        RETURN 0
      END
      ELSE
      BEGIN
        INSERT INTO [FERCO].[OP_WMS_DISPATCH_FROM_EXTERNAL] ([LOGIN_ID]
        , [MATERIAL_ID]
        , [MATERIAL_NAME]
        , [QTY_REQUESTED]
        , [QTY_ONHAND]
        , [PROCESS_RESULT]
        , [PROCESS_STAMP], [READY_TO_GO])
          VALUES (@LOGIN, @CLIENTE + '/' + @SKU, @SKU_NAME, @QTY_REQUESTED, @QTY_ON_HAND, 'OK', GETDATE(), 1)
        RETURN 0

      END


      IF @@error = 0
      BEGIN
        SELECT
          1 AS Resultado
         ,'OK'
      --SELECT @TRANS + @RESUMEN RESULTADO
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
  END
