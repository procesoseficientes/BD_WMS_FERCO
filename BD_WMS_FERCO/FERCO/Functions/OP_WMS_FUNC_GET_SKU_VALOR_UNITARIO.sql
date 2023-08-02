﻿
CREATE FUNCTION [FERCO].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO
(	
	@pCODIGO_POLIZA		varchar(25),
	@pSKU				varchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
    CASE ISNULL(SUM(ISNULL(B.BULTOS,1)),1)
      WHEN 0 THEN 1
      ELSE
      (SUM(B.CUSTOMS_AMOUNT)+ 
		    SUM(B.DAI)           +
		    SUM(ISNULL(B.IVA,1))) / ISNULL(SUM(ISNULL(B.BULTOS,1)),1)
     END AS VALOR_UNITARIO	    
	FROM 
		[FERCO].OP_WMS_POLIZA_HEADER A,
		[FERCO].OP_WMS_POLIZA_DETAIL B
	WHERE
		A.CODIGO_POLIZA		= @pCODIGO_POLIZA	AND
		B.DOC_ID			= A.DOC_ID			AND
		B.SKU_DESCRIPTION	LIKE @pSKU + '%'	AND
		B.BULTOS IS NOT NULL	AND B.BULTOS <> 0
)