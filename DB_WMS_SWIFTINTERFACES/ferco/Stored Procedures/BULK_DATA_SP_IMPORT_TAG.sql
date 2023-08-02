﻿-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		5/10/2017 @ A-Team Sprint Issa
-- Description:			    SP que actualiza el campo QRY_GROUP de las etiquetas con su valor correspondiente al campo GROUP_CODE del ERP

/*
-- Ejemplo de Ejecucion:
        EXEC [ferco].[BULK_DATA_SP_IMPORT_TAG]
		--
		SELECT * FROM [SWIFT_INTERFACES_ONLINE].[ferco].ERP_VIEW_CUSTOMER_PROPERTIES
		--
		SELECT * FROM SWIFT_EXPRESS.[ferco].[SWIFT_TAGS]
*/
-- =============================================
CREATE PROCEDURE [ferco].[BULK_DATA_SP_IMPORT_TAG]
AS
BEGIN
	SET NOCOUNT ON;
	--
	UPDATE SWIFT_EXPRESS.[ferco].[SWIFT_TAGS] SET QRY_GROUP = NULL
	--
	UPDATE ST 
	SET ST.QRY_GROUP = CP.GROUP_CODE
	FROM SWIFT_EXPRESS.[ferco].[SWIFT_TAGS] AS ST
	INNER JOIN [SWIFT_INTERFACES_ONLINE].[ferco].ERP_VIEW_CUSTOMER_PROPERTIES AS CP ON (
		ST.[TAG_VALUE_TEXT] COLLATE DATABASE_DEFAULT = CP.GROUP_NAME COLLATE DATABASE_DEFAULT
	)
	WHERE [ST].[TYPE] = 'CUSTOMER'
END