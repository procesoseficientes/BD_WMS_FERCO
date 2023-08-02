﻿
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		10-Jan-17 @ A-Team Sprint BALDER 
-- Description:			    Funcion que obtiene el primer dia del mes

/*
-- Ejemplo de Ejecucion:
        SELECT [FERCO].[OP_WMS_GET_FIRST_DAY_OF_MONTH_TO_BILL]('20160115 00:00:00.000')
		--
		SELECT [FERCO].[OP_WMS_GET_FIRST_DAY_OF_MONTH_TO_BILL]('20160215 00:00:00.000')
		--
		SELECT [FERCO].[OP_WMS_GET_FIRST_DAY_OF_MONTH_TO_BILL]('20160415 00:00:00.000')
*/
-- =============================================
CREATE FUNCTION [FERCO].[OP_WMS_GET_FIRST_DAY_OF_MONTH_TO_BILL]
(
	@DATE DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @FIRST_DAY DATETIME
	--
	SELECT @FIRST_DAY = DATEADD(mm, DATEDIFF(mm,0,@DATE), 1)
	--
	RETURN @FIRST_DAY
END



