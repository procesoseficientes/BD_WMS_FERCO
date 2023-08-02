
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-25 @ Team ERGON - Sprint ERGON 1
-- Description:	 


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	 Se elimina la unidad de medidad 





/*
-- Ejemplo de Ejecucion:
			  EXEC [FERCO].OP_WMS_SP_INSERT_MASTER_PACK_COMPONENT @MASTER_PACK_CODE = 'C00015/AMERQUIM'
                                                                   ,@COMPONENT_MATERIAL = 'C00015/BATIDORA'
                                                                   ,@QTY = 5

  SELECT * FROM [FERCO].[OP_WMS_COMPONENTS_BY_MASTER_PACK]
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_INSERT_MASTER_PACK_COMPONENT (@MASTER_PACK_CODE VARCHAR(50)
, @COMPONENT_MATERIAL VARCHAR(50)
, @QTY INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  INSERT INTO [FERCO].[OP_WMS_COMPONENTS_BY_MASTER_PACK] ([MASTER_PACK_CODE], [COMPONENT_MATERIAL], [QTY])
    VALUES (@MASTER_PACK_CODE, @COMPONENT_MATERIAL, @QTY);

END
