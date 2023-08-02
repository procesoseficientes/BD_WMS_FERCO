
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-26 @ Team ERGON - Sprint ERGON II
-- Description:	 Insersión de un masterpack en una recepción para guardar el estado actual de ese master pack. 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	 Insertar  @QTY en [OP_WMS_MASTER_PACK_HEADER]


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-07 Nexus@AgeOfEmpires
-- Description:	 Valida el tipo de explosión en recepción para almacenar el detalle completo en el detalle de masterpack para poder hacer una explosión directa posteriormente. 

-- Modificacion 9/8/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se corrige longitud de parametro @pMATERIAL_CODE para que coincida con el de la tabla [OP_WMS_MATERIALS]

-- Modificacion 06-Oct-17 @ Nexus Team Sprint eFERCO
-- pablo.aguilar
-- Se modifica para que guarde en directo unicamente si explota en recepción, tambien se modifica update sin where de master_pack_detail 

/*
-- Ejemplo de Ejecucion:
		EXEC [FERCO].[OP_WMS_SP_INSERT_MASTER_PACK] @MASTER_PACK_CODE = 'FERCO/PT0001'
                                                          ,@LICENSE_ID = '177672'
                                                          ,@QTY = 30 
      SELECT * FROM [FERCO].[OP_WMS_MASTER_PACK_HEADER] [H]
      SELECT * FROM [FERCO].[OP_WMS_MASTER_PACK_DETAIL] [D]
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_INSERT_MASTER_PACK] (
		@MATERIAL_ID_MASTER_PACK VARCHAR(50)
		,@LICENSE_ID INT
		,@LAST_UPDATE_BY VARCHAR(50)
		,@QTY INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@BATCH VARCHAR(50)
		,@DATE_EXPIRATION DATETIME
		,@POLICY_HEADER_ID INT
		,@MASTER_PACK_HEADER_ID INT
		,@EXPLOSION_TYPE VARCHAR(50)
		,@EXPLOSION_IN_RECEPTION INT = 0; 
  --
	SELECT TOP 1
		@BATCH = [I].[BATCH]
		,@DATE_EXPIRATION = [I].[DATE_EXPIRATION]
	FROM
		[FERCO].[OP_WMS_INV_X_LICENSE] [I]
	WHERE
		[I].[LICENSE_ID] = @LICENSE_ID
		 AND [I].[MATERIAL_ID] = @MATERIAL_ID_MASTER_PACK;


	SELECT TOP 1
		@EXPLOSION_TYPE = [C].[TEXT_VALUE]
	FROM
		[FERCO].[OP_WMS_CONFIGURATIONS] [C]
	WHERE
		[C].[PARAM_TYPE] = 'SISTEMA'
		AND [C].[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
		AND [C].[PARAM_NAME] = 'TIPO_EXPLOSION_RECEPCION';

	SELECT TOP 1
		@EXPLOSION_IN_RECEPTION = [EXPLODE_IN_RECEPTION]
	FROM
		[FERCO].[OP_WMS_MATERIALS]
	WHERE
		[MATERIAL_ID] = @MATERIAL_ID_MASTER_PACK;

	IF NOT EXISTS ( SELECT TOP 1
						1
					FROM
						[FERCO].[OP_WMS_MASTER_PACK_HEADER] [H]
					WHERE
						[H].[LICENSE_ID] = @LICENSE_ID
						AND [H].[MATERIAL_ID] = @MATERIAL_ID_MASTER_PACK )
	BEGIN
		SELECT TOP 1
			@POLICY_HEADER_ID = [P].[DOC_ID]
		FROM
			[FERCO].[OP_WMS_LICENSES] [L]
		INNER JOIN [FERCO].[OP_WMS_POLIZA_HEADER] [P] ON [L].[CODIGO_POLIZA] = [P].[CODIGO_POLIZA]
		WHERE
			[L].[LICENSE_ID] = @LICENSE_ID;
    -- Insertar Header
		INSERT	INTO [FERCO].[OP_WMS_MASTER_PACK_HEADER]
				(
					[LICENSE_ID]
					,[MATERIAL_ID]
					,[POLICY_HEADER_ID]
					,[LAST_UPDATED]
					,[LAST_UPDATE_BY]
					,[EXPLODED]
					,[EXPLODED_DATE]
					,[RECEPTION_DATE]
					,[QTY]
				)
		VALUES
				(
					@LICENSE_ID
					,@MATERIAL_ID_MASTER_PACK
					,@POLICY_HEADER_ID
					,GETDATE()
					,@LAST_UPDATE_BY
					,0
					,NULL
					,GETDATE()
					,@QTY
				);

		SET @MASTER_PACK_HEADER_ID = SCOPE_IDENTITY();


    ---------------------------------------------------------------------------------
    -- Explosion directa, obtiene todo el detalle hasta llegar a la ultima unidad. 
    ---------------------------------------------------------------------------------  
		IF @EXPLOSION_TYPE = 'EXPLOSION_DIRECTA'
			AND @EXPLOSION_IN_RECEPTION = 1
		BEGIN
			INSERT	INTO [FERCO].[OP_WMS_MASTER_PACK_DETAIL]
					(
						[MASTER_PACK_HEADER_ID]
						,[MATERIAL_ID]
						,[QTY]
						,[BATCH]
						,[DATE_EXPIRATION]
					)
			SELECT
				@MASTER_PACK_HEADER_ID [MASTER_PACK_HEADER_ID]
				,[C].[MATERIAL_ID] [MATERIAL_ID]
				,[C].[QTY] [QTY]
				,@BATCH [BATCH]
				,@DATE_EXPIRATION [DATE_EXPIRATION]
			FROM
				[FERCO].[OP_WMS_FN_GET_MASTER_PACK_ALL_LEVEL_COMPONENTS](@MATERIAL_ID_MASTER_PACK) [C]
			WHERE
				[C].[IS_MASTER_PACK] = 0;

		END;
		ELSE
		BEGIN
      ---------------------------------------------------------------------------------
      -- Explosion en cascada guarda unicamente el primer nivel 
      ---------------------------------------------------------------------------------  
      -- Insertar Detalle
			INSERT	INTO [FERCO].[OP_WMS_MASTER_PACK_DETAIL]
					(
						[MASTER_PACK_HEADER_ID]
						,[MATERIAL_ID]
						,[QTY]
						,[BATCH]
						,[DATE_EXPIRATION]
					)
			SELECT
				@MASTER_PACK_HEADER_ID [MASTER_PACK_HEADER_ID]
				,[C].[COMPONENT_MATERIAL] [MATERIAL_ID]
				,[C].[QTY] [QTY]
				,@BATCH [BATCH]
				,@DATE_EXPIRATION [DATE_EXPIRATION]
			FROM
				[FERCO].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
			WHERE
				[C].[MASTER_PACK_CODE] = @MATERIAL_ID_MASTER_PACK;
		END;
	END;
	ELSE
	BEGIN
		UPDATE
			[FERCO].[OP_WMS_MASTER_PACK_HEADER]
		SET	
			[QTY] = [QTY] + @QTY
		WHERE
			[LICENSE_ID] = @LICENSE_ID
			AND [MATERIAL_ID] = @MATERIAL_ID_MASTER_PACK;

		UPDATE
			[D]
		SET	
			[D].[BATCH] = @BATCH
			,[D].[DATE_EXPIRATION] = @DATE_EXPIRATION
		FROM
			[FERCO].[OP_WMS_MASTER_PACK_DETAIL] [D]
		INNER JOIN [FERCO].[OP_WMS_MASTER_PACK_HEADER] [H] ON [H].[MASTER_PACK_HEADER_ID] = [D].[MASTER_PACK_HEADER_ID]
		WHERE
			[H].[LICENSE_ID] = @LICENSE_ID
			AND [H].[MATERIAL_ID] = @MATERIAL_ID_MASTER_PACK;  

	END;

END;