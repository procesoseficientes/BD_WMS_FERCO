
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			SP que agrega detalle a la solicitud de traslado

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_ADD_TRANSFER_REQUEST_DETAIL]
					@TRANSFER_REQUEST_ID = 2
					,@MATERIAL_ID = 'prueba'
					,@MATERIAL_NAME = 'prueba'
					,@IS_MASTERPACK = 0
					,@QTY = 10
					,@STATUS = 'prueba'
				-- 
				SELECT * FROM [FERCO].[OP_WMS_TRANSFER_REQUEST_DETAIL]
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_ADD_TRANSFER_REQUEST_DETAIL (@TRANSFER_REQUEST_ID INT
, @MATERIAL_ID VARCHAR(50)
, @MATERIAL_NAME VARCHAR(200)
, @IS_MASTERPACK INT
, @QTY NUMERIC(18, 6)
, @STATUS VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    INSERT INTO [FERCO].[OP_WMS_TRANSFER_REQUEST_DETAIL] ([TRANSFER_REQUEST_ID]
    , [MATERIAL_ID]
    , [MATERIAL_NAME]
    , [IS_MASTERPACK]
    , [QTY]
    , [STATUS])
      VALUES (@TRANSFER_REQUEST_ID  -- TRANSFER_REQUEST_ID - int
      , @MATERIAL_ID  -- MATERIAL_ID - varchar(50)
      , @MATERIAL_NAME  -- MATERIAL_NAME - varchar(200)
      , @IS_MASTERPACK  -- IS_MASTERPACK - int
      , @QTY  -- QTY - numeric
      , @STATUS  -- STATUS - varchar(25)
      )
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@ERROR AS VARCHAR)
        WHEN '547' THEN 'No existe el código de solicitud de transferencia'
        WHEN '2627' THEN 'La solicitud de transferencia ya tiene el material ' + @MATERIAL_ID + ' - ' + @MATERIAL_NAME
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@ERROR Codigo
  END CATCH
END
