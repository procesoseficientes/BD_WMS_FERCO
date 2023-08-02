﻿



CREATE FUNCTION [FERCO].[OP_WMS_FUNC_GET_PASS_DETAIL_BY_POLIZA]
(	
	@pPASS_ID VARCHAR(25)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		MAX(GETDATE())	FECHA,
		SUM(b.QTY)		CANTIDAD,
		b.BARCODE_ID	CODIGO,
		b.MATERIAL_NAME DESCRIPCION,
		(SELECT SUM(QTY) 
			FROM FERCO.OP_WMS_VIEW_PASS_BY_POLIZA P
			WHERE P.CODIGO_POLIZA IN (SELECT Z.CODE_POLIZA 
									FROM FERCO.OP_WMS3PL_POLIZA_X_PASS Z 
									WHERE Z.PASS_ID = @pPASS_ID)) AS GT_QTY
	FROM 
		FERCO.OP_WMS_VIEW_PASS_BY_POLIZA b
	WHERE 
		b.CODIGO_POLIZA IN (SELECT Z.CODE_POLIZA FROM FERCO.OP_WMS3PL_POLIZA_X_PASS Z WHERE Z.PASS_ID = @pPASS_ID) 
	GROUP BY
		b.BARCODE_ID, 
		b.MATERIAL_NAME
)









