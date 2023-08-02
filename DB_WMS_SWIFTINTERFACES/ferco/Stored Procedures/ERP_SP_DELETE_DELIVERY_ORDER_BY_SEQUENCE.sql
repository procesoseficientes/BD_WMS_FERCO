
-- =============================================
-- Autor:				gustavo.garcia
-- Fecha de Creacion: 	2020/06/23 @  Sprint Junio3 
-- Description:			Elimina de las 3 tablas filtrando por secuencia.

/*
-- Ejemplo de Ejecucion:
				EXEC [ferco].[ERP_SP_DELETE_DELIVERY_ORDER_BY_SEQUENCE] @Sequence = 1
*/
-- =============================================
CREATE PROCEDURE [ferco].[ERP_SP_DELETE_DELIVERY_ORDER_BY_SEQUENCE] (@Sequence INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
 -- DELETE FROM [ferco].[ERP_DELIVERY_ORDER_DETAIL]
  --WHERE [Sequence] = @Sequence
  --
  DELETE FROM [ferco].[ERP_DELIVERY_ORDER_HEADER]
  WHERE [Sequence] = @Sequence
  --
  DELETE FROM [ferco].[ERP_DELIVERY_ORDER_SEQUENCE]
  WHERE [Sequence] = @Sequence
--
END
