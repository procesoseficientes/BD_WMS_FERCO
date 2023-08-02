-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		5/9/2017 @ A-Team Sprint Issa
-- Description:			    Vista que lee todos los campos de la tabla OCQG del ERP

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [ferco].[ERP_VIEW_CUSTOMER_PROPERTIES]
*/
-- =============================================
CREATE VIEW FERCO.ERP_VIEW_CUSTOMER_PROPERTIES
AS

	SELECT 
		GROUP_CODE
		,GROUP_NAME
		,USER_SIGN
		,FILLER
	 FROM OPENQUERY(SAPSERVER, 'SELECT
	 [GroupCode] AS GROUP_CODE
		, [GroupName] AS GROUP_NAME
		, [UserSign] AS USER_SIGN
		, [Filler] AS FILLER
	FROM [SBOFERCO].[dbo].OCQG
	')