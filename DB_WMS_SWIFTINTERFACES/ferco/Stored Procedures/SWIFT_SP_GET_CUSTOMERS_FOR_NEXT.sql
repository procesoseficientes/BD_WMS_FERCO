-- =============================================
-- Autor:					henry.rodriguez
-- Fecha: 					09-SEPTIEMBRE-2019 GForce@GUMARCAJ
-- Description:			    devuelve la informacion del catalogo de clientes

/*
-- Ejemplo de Ejecucion:
	
	EXEC [ferco].[SWIFT_SP_GET_CUSTOMERS_FOR_NEXT] @DATABASE='[SBOFERCO]',@OWNER = 'FERCO'
*/
-- =============================================
CREATE PROCEDURE [ferco].[SWIFT_SP_GET_CUSTOMERS_FOR_NEXT] (
		@DATABASE VARCHAR(35)
		,@OWNER VARCHAR(30)
	)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE	@QUERYERP VARCHAR(2000)= N'SELECT C.CardCode CardCode,C.CardName CardName, C.Phone1 Phone1, C.Phone2 Phone2, 
		C.Cellular Cellular, null LATITUDE, null LONGITUDE, null IMG_FACADE, C.E_Mail E_Mail FROM '
		+ @DATABASE + '.[dbo].OCRD C WHERE C.CardType = ''''C'''' ';
		
	--
	DECLARE	@QUERY NVARCHAR(2000);
	--
	SELECT
		@QUERY = N'
		SELECT
		[CardCode]
		,[CardName]
		,[Phone1]
		,[Phone2]
		,[Cellular]
		,[LATITUDE]
		,[LONGITUDE]
		,[IMG_FACADE]
		,[E_Mail]
		,''' + @OWNER + ''' [OWNER] 
	FROM
		OPENQUERY([SAPSERVER],''' + @QUERYERP + ''');  ';
	
	EXEC [sp_executesql] @QUERY;
END;






