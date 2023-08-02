﻿-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-03-01 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que trae las transacciones por filtros

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-03-15 Team ERGON - Sprint ERGON V
-- Description:	 Se agrego el campo codigo y nombre del proveedor

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	27-03-2017 Team Ergon SPRINT Hyper
-- Description:			    Se agrego bodegas de usuario logueado

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-16 ErgonTeam@BreathOfTheWild
-- Description:	 Se agrega el campo de serie en la consulta 

-- Modificacion 02-Sep-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se agrega columna TRANSFER_REQUEST_ID

-- Modificacion 09-Abr-18 @ GForce Team Sprint Buho
-- marvin.solares
-- Se modifica campo [QUANTITY_UNITS] para que retorne negativo cuando el estado es 'CANCEL'

/*
-- Ejemplo de Ejecucion:
		EXEC [FERCO].[OP_WMS_SP_GET_TRANS_BASIC_VIEW] 
			@START_DATE = '2017-02-27 00:00:00'
            ,@END_DATE = '2017-03-27 23:59:00'
            ,@LOGIN = 'ACAMACHO|BCORADO|EDGARC|AREYES|OPER3'
            ,@TRANS_TYPE = 'CONTEO_FISICO|REUBICACION_COMPLETA|REUBICACION_PARCIAL|INICIALIZACION_GENERAL|TRASLADO_GENERAL|INICIALIZACION_FISCAL|INGRESO_FISCAL|INGRESO_GENERAL|EXPLODE_IN'
            ,@USER_LOGGED  = 'ADMIN'
  
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_GET_TRANS_BASIC_VIEW] (
		@START_DATE DATETIME
		,@END_DATE DATETIME
		,@LOGIN VARCHAR(MAX) = NULL
		,@TRANS_TYPE VARCHAR(MAX) = NULL
		,@USER_LOGGED VARCHAR(25) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@STATUS_ACCEPTED VARCHAR(15) = 'ACCEPTED'
		,@STATUS_COMPLETED VARCHAR(15) = 'COMPLETED';
  --
	DECLARE	@WAREHOUSE TABLE (
			[WAREHOUSE_ID] VARCHAR(25)
			,[NAME] VARCHAR(50)
			,[COMMENTS] VARCHAR(150)
			,[ERP_WAREHOUSE] VARCHAR(50)
			,[ALLOW_PICKING] NUMERIC
			,[DEFAULT_RECEPTION_LOCATION] VARCHAR(25)
			,[SHUNT_NAME] VARCHAR(25)
			,[WAREHOUSE_WEATHER] VARCHAR(50)
			,[WAREHOUSE_STATUS] INT
			,[IS_3PL_WAREHUESE] INT
			,[WAHREHOUSE_ADDRESS] VARCHAR(250)
			,[GPS_URL] VARCHAR(100)
			,[WAREHOUSE_BY_USER_ID] INT
		);
  --
	DECLARE	@TYPE TABLE (
			[TYPE] VARCHAR(100)
			,PRIMARY KEY ([TYPE])
		);
  --
	DECLARE	@USER TABLE (
			[LOGIN] VARCHAR(100)
			,PRIMARY KEY ([LOGIN])
		);

  -- ------------------------------------------------------------------------------------
  -- Obtiene tipos y usuarios
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @TYPE
	SELECT
		[T].[VALUE]
	FROM
		[FERCO].[OP_WMS_FN_SPLIT](@TRANS_TYPE, '|') [T];
  --
	INSERT	INTO @USER
	SELECT
		[T].[VALUE]
	FROM
		[FERCO].[OP_WMS_FN_SPLIT](@LOGIN, '|') [T];

  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
	SELECT DISTINCT
		[A].[SERIAL_NUMBER] AS [TRANS_ID]
		,[A].[TRANS_WEIGTH] AS [TRANS_WEIGTH]
		,[A].[TERMS_OF_TRADE] AS [TERMS_OF_TRADE]
		,[A].[LOGIN_ID] AS [LOGIN_ID]
		,[A].[LOGIN_NAME] AS [LOGIN_NAME]
		,[A].[TRANS_TYPE] AS [TRANS_TYPE]
		,[A].[TRANS_DESCRIPTION] + ' No. '
		+ CAST([A].[TASK_ID] AS VARCHAR) AS [TRANS_DESCRIPTION]
		,[A].[MATERIAL_BARCODE]
		,[A].[MATERIAL_CODE] AS [MATERIAL_CODE]
		,[A].[MATERIAL_DESCRIPTION] AS [MATERIAL_DESCRIPTION]
		,[A].[SOURCE_LICENSE] AS [SOURCE_LICENSE]
		,[A].[TARGET_LICENSE]
		,[A].[SOURCE_LOCATION] AS [SOURCE_LOCATION]
		,[A].[TARGET_LOCATION] AS [TARGET_LOCATION]
		,[A].[CLIENT_OWNER] AS [CLIENT_OWNER]
		,[A].[CLIENT_NAME] AS [CLIENT_NAME]
		,(CASE [A].[STATUS]
			WHEN 'CANCEL' THEN -1 * [A].[QUANTITY_UNITS]
			ELSE [A].[QUANTITY_UNITS]
			END) AS [QUANTITY_UNITS]
		,[A].[SOURCE_WAREHOUSE] AS [SOURCE_WAREHOUSE]
		,[A].[TARGET_WAREHOUSE] AS [TARGET_WAREHOUSE]
		,[A].[CODIGO_POLIZA]
		,[A].[LICENSE_ID] AS [LICENSE_ID]
		,[A].[STATUS] AS [STATUS]
		,[A].[WAVE_PICKING_ID] AS [WAVE_PICKING_ID]
		,[B].[NUMERO_ORDEN] AS [NUMERO_ORDEN]
		,[A].[TRANS_DATE] AS [TRANS_DATE]
		,(CASE [TRANS_TYPE]
			WHEN 'CONTEO_FISICO' THEN 'CONTEO FISICO'
			WHEN 'EXPLODE_IN' THEN 'EXPLOSION ENTRADA'
			WHEN 'EXPLODE_OUT' THEN 'EXPLOSION SALIDA'
			WHEN 'DESPACHO_FISCAL' THEN 'FISCAL'
			WHEN 'TRASLADO_GENERAL' THEN 'FISCAL'
			WHEN 'INGRESO_FISCAL' THEN 'FISCAL'
			WHEN 'DESPACHO_GENERAL' THEN 'GENERAL'
			WHEN 'INGRESO_GENERAL' THEN 'GENERAL'
			WHEN 'RECEP_GENERAL_X_TRASLADO' THEN 'GENERAL'
			WHEN 'INICIALIZACION_GENERAL' THEN 'GENERAL'
			WHEN 'INICIALIZACION_FISCAL' THEN 'FISCAL'
			WHEN 'REUBICACION_PARCIAL'
			THEN (SELECT
						[REGIMEN]
					FROM
						[FERCO].[OP_WMS_LICENSES]
					WHERE
						[LICENSE_ID] = [A].[SOURCE_LICENSE])
			END) AS [REGIMEN]
		,(CASE [TRANS_TYPE]
			WHEN 'CONTEO_FISICO' THEN 'NA'
			WHEN 'EXPLODE_IN' THEN '+'
			WHEN 'EXPLODE_OUT' THEN '-'
			WHEN 'DESPACHO_FISCAL' THEN '+'
			WHEN 'TRASLADO_GENERAL' THEN '-'
			WHEN 'INGRESO_FISCAL' THEN '+'
			WHEN 'DESPACHO_GENERAL' THEN '-'
			WHEN 'INGRESO_GENERAL' THEN '+'
			WHEN 'RECEP_GENERAL_X_TRASLADO' THEN '+'
			WHEN 'INICIALIZACION_GENERAL' THEN 'NA'
			WHEN 'INICIALIZACION_FISCAL' THEN 'NA'
			WHEN 'REUBICACION_PARCIAL' THEN 'NA'
			END) AS [ACTION]
		,[A].[POSTED_TO_ERP_STAMP]
		,[A].[VIN]
		,[A].[TASK_ID] AS [TASK_ID]
		,[A].[TRANS_SUBTYPE]
		,[A].[BATCH]
		,CASE [A].[DATE_EXPIRATION]
			WHEN CONVERT(DATE, '01-01-0001') THEN NULL
			ELSE [A].[DATE_EXPIRATION]
			END [DATE_EXPIRATION]
		,[A].[CODE_SUPPLIER]
		,[A].[NAME_SUPPLIER]
		,[A].[SERIAL]
		,[A].[TRANSFER_REQUEST_ID]
		,[A].[ENTERED_MEASUREMENT_UNIT]
		,[A].[ENTERED_MEASUREMENT_UNIT_QTY]
		,[A].[ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR]
	FROM
		[FERCO].[OP_WMS_TRANS] AS [A]
	LEFT JOIN [FERCO].[OP_WMS_POLIZA_HEADER] AS [B] ON ([A].[CODIGO_POLIZA] = [B].[CODIGO_POLIZA])
	LEFT JOIN @USER [U] ON [U].[LOGIN] = [A].[LOGIN_ID]
	LEFT JOIN @TYPE [T] ON [A].[TRANS_TYPE] = [T].[TYPE]
	WHERE
		[A].[TRANS_DATE] BETWEEN @START_DATE
							AND		@END_DATE
		AND (
				@TRANS_TYPE IS NULL
				OR [T].[TYPE] IS NOT NULL
			)
		AND (
				@LOGIN IS NULL
				OR [U].[LOGIN] IS NOT NULL
			)
		AND [A].[STATUS] NOT IN (@STATUS_ACCEPTED,
									@STATUS_COMPLETED);
END;