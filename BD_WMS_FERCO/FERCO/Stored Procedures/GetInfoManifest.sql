-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	09-Septiembre-2019 G-Force@Gumarcaj
-- Description:			Sp que obtiene el resumen de un manifiesto

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	26-Noviembre-2019 G-Force@Kioto
-- Description:			Se agrega correccion en mostrar la cantidad de paradas
/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[GetInfoManifest] @MANIFEST_HEADER_ID = 1108
				
*/
-- =============================================  
CREATE PROCEDURE [FERCO].[GetInfoManifest] (
		@MANIFEST_HEADER_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE
		@TOTAL_MATERIALS INT = 0
		,@STATUS_MANIFEST [VARCHAR](50)
		,@STOPS INT = 0;
	
	SELECT DISTINCT
		[MATERIAL_ID]
	INTO
		[#MATERIALS]
	FROM
		[FERCO].[OP_WMS_MANIFEST_DETAIL]
	WHERE
		[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;

	SELECT DISTINCT
		[ADDRESS_CUSTOMER], [CLIENT_CODE]
	INTO
		[#ADDRESSES]
	FROM
		[FERCO].[OP_WMS_MANIFEST_DETAIL]
	WHERE
		[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
		GROUP BY [ADDRESS_CUSTOMER], [CLIENT_CODE];

	SELECT
		@TOTAL_MATERIALS = COUNT(1)
	FROM
		[#MATERIALS];
		
	SELECT
		@STOPS = COUNT(1)
	FROM
		[#ADDRESSES];

	DECLARE	@PILOT INT;

	SELECT TOP 1
		@STATUS_MANIFEST = [STATUS]
		,@PILOT = [DRIVER]
	FROM
		[FERCO].[OP_WMS_MANIFEST_HEADER]
	WHERE
		[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;

	DECLARE	@ASSIGNED VARCHAR(25);

	IF @STATUS_MANIFEST = 'ASSIGNED'
	BEGIN
		SELECT TOP 1
			@ASSIGNED = [USER_CODE]
		FROM
			[FERCO].[OP_WMS_USER_X_PILOT]
		WHERE
			[PILOT_CODE] = @PILOT;
	END;
		
	SELECT
		@TOTAL_MATERIALS [TotalMaterials]
		,ISNULL(@STATUS_MANIFEST, 'NOT FOUND') [Status]
		,@STOPS [Stops]
		,ISNULL(@ASSIGNED, 'PENDING') [AssignedTo];

END;
