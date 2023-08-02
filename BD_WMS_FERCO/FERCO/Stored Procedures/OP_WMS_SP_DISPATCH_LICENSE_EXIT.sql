-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	06-Sep-2018 G-Force@Jaguarundi
-- Description:	        Sp que rebaja las licencias y las ordenes

-- Autor:				marvin.solares
-- Fecha de Creacion: 	01-Agosto-2019 GForce@Estambul
--Product Backlog Item 30564: Certificación de manifiesto con entrega de licencias de despacho
-- Description:			pongo como certificado el manifiesto si todas las olas asociadas ya estan despachadas

-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_DISPATCH_LICENSE_EXIT] (
		@XML XML
		,@LOGIN VARCHAR(50)
		,@WAVE_PICKING_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN;

    -- ------------------------------------------------------------------------------------
    -- Declaramos tablas a utilizar
    -- ------------------------------------------------------------------------------------
		DECLARE
			@ErrorCode INT = 0
			,@DISPATCH_LICENSE_EXIT_HEADER INT
			,@PROCESS_DOCUMENTS INT = 0;

		DECLARE	@POLIZA_HEADER TABLE (
				[PICKING_DEMAND_HEADER_ID] INT
				,[DOC_NUM_POLIZA] INT
				,[CODIGO_POLIZA] VARCHAR(25)
				,[NUMERO_ORDEN_POLIZA] VARCHAR(25)
			);

		DECLARE	@LICENSE_ORIGIN AS TABLE (
				[LICENSE_ID] INT
				,[MATERIAL_ID] VARCHAR(50)
				,[QTY] DECIMAL(18, 4)
				,[QTY_ORIGIN] DECIMAL(14, 4)
			);

		DECLARE	@LICENSE_PICKING_DEMAND AS TABLE (
				[MATERIAL_ID] VARCHAR(50)
				,[QTY] DECIMAL(18, 4)
			);

		DECLARE	@PICKING_DEMAND_HEADER AS TABLE (
				[PICKING_DEMAND_HEADER_ID] INT
			);

		DECLARE	@PICKING_DEMAND_DETAIL AS TABLE (
				[PICKING_DEMAND_HEADER_ID] INT
				,[PICKING_DEMAND_DETAIL_ID] INT
				,[MATERIAL_ID] VARCHAR(50)
				,[QTY] DECIMAL(18, 4)
				,[QTY_ORIGIN] DECIMAL(18, 4)
				,[LINE_NUM] INT
				,[COMPLETED] INT
				,[QTY_INSERT] DECIMAL(18, 4)
				,[INSERT_LINE] INT
			);

    -- ------------------------------------------------------------------------------------
    -- Obtenemos las licencias a rebajar
    -- ------------------------------------------------------------------------------------

		INSERT	INTO @LICENSE_ORIGIN
				(
					[LICENSE_ID]
					,[MATERIAL_ID]
					,[QTY]
					,[QTY_ORIGIN]
				 )
		SELECT
			[x].[Rec].[query]('./LICENSE_ID').[value]('.',
											'int')
			,[x].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'VARCHAR(50)')
			,[x].[Rec].[query]('./QTY').[value]('.',
											'DECIMAL(18,4)')
			,[x].[Rec].[query]('./QTY_ORIGIN').[value]('.',
											'DECIMAL(18,4)')
		FROM
			@XML.[nodes]('/OP_WMS_SP_GET_LICENSE_DISPATCH_FOR_PICKING')
			AS [x] ([Rec]);

    -- ------------------------------------------------------------------------------------
    -- Obtenemos las demandas de despacho
    -- ------------------------------------------------------------------------------------
		INSERT	INTO @PICKING_DEMAND_HEADER
				(
					[PICKING_DEMAND_HEADER_ID]
				 )
		SELECT
			[PDH].[PICKING_DEMAND_HEADER_ID]
		FROM
			[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
		WHERE
			[PDH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [PDH].[DISPATCH_LICENSE_EXIT_BY] IS NULL
		ORDER BY
			[PDH].[PRIORITY] DESC;

    -- ------------------------------------------------------------------------------------
    -- Creamos el encabezado del despacho.
    -- ------------------------------------------------------------------------------------      

		INSERT	[FERCO].[OP_WMS_DISPATCH_LICENSE_EXIT_HEADER]
				([CREATE_BY])
		VALUES
				(@LOGIN);

		SET @DISPATCH_LICENSE_EXIT_HEADER = SCOPE_IDENTITY();

    -- ------------------------------------------------------------------------------------
    -- Validamos si hay demandas de despacho
    -- ------------------------------------------------------------------------------------
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						@PICKING_DEMAND_HEADER )
		BEGIN

			SET @PROCESS_DOCUMENTS = 1;
      -- ------------------------------------------------------------------------------------
      -- Insertamos en una tabla las licencias a rebajar
      -- ------------------------------------------------------------------------------------
			INSERT	INTO @LICENSE_PICKING_DEMAND
					(
						[MATERIAL_ID]
						,[QTY]
					 )
			SELECT
				[MATERIAL_ID]
				,SUM([QTY])
			FROM
				@LICENSE_ORIGIN
			GROUP BY
				[MATERIAL_ID];
		END;

    -- ------------------------------------------------------------------------------------
    -- Recorremos los picking de despacho
    -- ------------------------------------------------------------------------------------

		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@PICKING_DEMAND_HEADER )
		BEGIN

      -- ------------------------------------------------------------------------------------
      -- Declaramos las variables a utilizar
      -- ------------------------------------------------------------------------------------
			DECLARE	@PICKING_DEMAND_HEADER_ID INT;

      -- ------------------------------------------------------------------------------------
      -- Obtenemos la primera demanda de despacho
      -- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@PICKING_DEMAND_HEADER_ID = [PICKING_DEMAND_HEADER_ID]
			FROM
				@PICKING_DEMAND_HEADER;

      -- ------------------------------------------------------------------------------------
      -- Limpiamos la tabla de detalle temporal
      -- ------------------------------------------------------------------------------------
			DELETE
				@PICKING_DEMAND_DETAIL;

      -- ------------------------------------------------------------------------------------
      -- Obtenemos los detalles de la demanda de despacho
      -- ------------------------------------------------------------------------------------
			INSERT	INTO @PICKING_DEMAND_DETAIL
					(
						[PICKING_DEMAND_HEADER_ID]
						,[PICKING_DEMAND_DETAIL_ID]
						,[MATERIAL_ID]
						,[QTY]
						,[QTY_ORIGIN]
						,[LINE_NUM]
						,[COMPLETED]
						,[QTY_INSERT]
						,[INSERT_LINE]
					 )
			SELECT
				@PICKING_DEMAND_HEADER_ID
				,[PDD].[PICKING_DEMAND_DETAIL_ID]
				,ISNULL([MP].[COMPONENT_MATERIAL],
						[PDD].[MATERIAL_ID]) [MATERIAL_ID]
				,[PDD].[QTY] * ISNULL([MP].[QTY], 1)
				,[PDD].[QTY] * ISNULL([MP].[QTY], 1)
				,[PDD].[LINE_NUM]
				,0
				,0
				,1
			FROM
				[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
			LEFT JOIN [FERCO].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [MP] ON [PDD].[MATERIAL_ID] = [MP].[MASTER_PACK_CODE]
											AND [PDD].[WAS_IMPLODED] = 1
			WHERE
				[PDD].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;


			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								@PICKING_DEMAND_DETAIL [PDT]
							WHERE
								[PDT].[COMPLETED] = 0 )
			BEGIN
				DECLARE	@PICKING_DEMAND_DETAIL_ID INT = (SELECT TOP 1
											[PDT].[PICKING_DEMAND_DETAIL_ID]
											FROM
											@PICKING_DEMAND_DETAIL [PDT]
											WHERE
											[PDT].[COMPLETED] = 0
											ORDER BY
											[PDT].[LINE_NUM]);

        -- ------------------------------------------------------------------------------------
        -- Actualizamos las cantidades del detalle de la tabla temporal
        -- ------------------------------------------------------------------------------------
				UPDATE
					[PDD]
				SET	
					[QTY] = CASE	WHEN [PDD].[QTY] <= [LPD].[QTY]
									THEN [PDD].[QTY]
									ELSE [LPD].[QTY]
							END
					,[INSERT_LINE] = CASE	WHEN [PDD].[QTY] <= [LPD].[QTY]
											THEN 0
											ELSE 1
										END
				FROM
					@PICKING_DEMAND_DETAIL [PDD]
				INNER JOIN @LICENSE_PICKING_DEMAND [LPD] ON ([PDD].[MATERIAL_ID] = [LPD].[MATERIAL_ID])
				WHERE
					[PDD].[PICKING_DEMAND_DETAIL_ID] = @PICKING_DEMAND_DETAIL_ID
					AND [LPD].[QTY] > 0;


        -- ------------------------------------------------------------------------------------
        -- Actualizamos las cantidades del detalle de la verdadera tabla
        -- ------------------------------------------------------------------------------------

				UPDATE
					[PDD]
				SET	
					[QTY] = [PDDT].[QTY]
				FROM
					[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
				INNER JOIN @PICKING_DEMAND_DETAIL [PDDT] ON (
											[PDD].[MATERIAL_ID] = [PDDT].[MATERIAL_ID]
											AND [PDD].[LINE_NUM] = [PDDT].[LINE_NUM]
											)
											AND [PDD].[PICKING_DEMAND_DETAIL_ID] = @PICKING_DEMAND_DETAIL_ID;

        -- ------------------------------------------------------------------------------------
        -- Actualizamos las cantidades de la licencia
        -- ------------------------------------------------------------------------------------
				UPDATE
					[LPD]
				SET	
					[QTY] = [LPD].[QTY] - [PDD].[QTY]
				FROM
					@LICENSE_PICKING_DEMAND [LPD]
				INNER JOIN @PICKING_DEMAND_DETAIL [PDD] ON ([LPD].[MATERIAL_ID] = [PDD].[MATERIAL_ID])
				WHERE
					[PDD].[PICKING_DEMAND_DETAIL_ID] = @PICKING_DEMAND_DETAIL_ID
					AND [LPD].[QTY] > 0;

				UPDATE
					[PDD]
				SET	
					[COMPLETED] = 1
					,[QTY_INSERT] = CASE	WHEN [PDD].[QTY_ORIGIN] <> [PDD].[QTY]
											THEN ([PDD].[QTY_ORIGIN]
											- [PDD].[QTY])
											ELSE [PDD].[QTY_ORIGIN]
									END
				FROM
					@PICKING_DEMAND_DETAIL [PDD]
				WHERE
					[PDD].[PICKING_DEMAND_DETAIL_ID] = @PICKING_DEMAND_DETAIL_ID;

			END;

		-- ------------------------------------------------------------------------------------
		-- obtenemos el parametro que nos indica si debemos autorizar en automatico para enviar a erp
		-- ------------------------------------------------------------------------------------
			DECLARE	@AUTORIZE INT= 0;
			SELECT TOP 1
				@AUTORIZE = CAST(ISNULL([NUMERIC_VALUE], 0) AS INT)
			FROM
				[FERCO].[OP_WMS_CONFIGURATIONS]
			WHERE
				[PARAM_TYPE] = 'SISTEMA'
				AND [PARAM_GROUP] = 'RECEPCION'
				AND [PARAM_NAME] = 'AUTORIZACION_AUTOMATICA_DESPACHO_LICENCIA';
      -- ------------------------------------------------------------------------------------
      -- Actualizamos la el campo de si es completado
      -- ------------------------------------------------------------------------------------

			UPDATE
				[PDH]
			SET	
				[PDH].[IS_COMPLETED] = 0
				,[LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = @LOGIN
				,[IS_AUTHORIZED] = @AUTORIZE
				,[DISPATCH_LICENSE_EXIT_DATETIME] = GETDATE()
				,[DISPATCH_LICENSE_EXIT_BY] = @LOGIN
			FROM
				[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
			WHERE
				[PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

      -- ------------------------------------------------------------------------------------
      -- Obtenemos el codigo de poliza.
      -- ------------------------------------------------------------------------------------

			DELETE FROM
				@POLIZA_HEADER;

			INSERT	INTO @POLIZA_HEADER
					(
						[PICKING_DEMAND_HEADER_ID]
						,[DOC_NUM_POLIZA]
						,[CODIGO_POLIZA]
						,[NUMERO_ORDEN_POLIZA]
					 )
			SELECT DISTINCT
				[PDH].[PICKING_DEMAND_HEADER_ID]
				,[PH].[DOC_ID]
				,[PH].[CODIGO_POLIZA]
				,[PH].[NUMERO_ORDEN]
			FROM
				[FERCO].[OP_WMS_POLIZA_HEADER] [PH]
			INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [TL] ON ([PH].[CODIGO_POLIZA] = [TL].[CODIGO_POLIZA_TARGET])
			INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON ([TL].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID])
			INNER JOIN @PICKING_DEMAND_DETAIL [PDDT] ON ([PDH].[PICKING_DEMAND_HEADER_ID] = [PDDT].[PICKING_DEMAND_HEADER_ID]);
      -- ------------------------------------------------------------------------------------
      -- Insertamos en la tabla de detalle
      -- ------------------------------------------------------------------------------------      

			INSERT	[FERCO].[OP_WMS_DISPATCH_LICENSE_EXIT_DETAIL]
					(
						[DISPATCH_LICENSE_EXIT_HEADER_ID]
						,[CLIENT_CODE]
						,[CLIENT_NAME]
						,[PICKING_DEMAND_HEADER_ID]
						,[DOC_NUM]
						,[MATERIAL_ID]
						,[MATERIAL_NAME]
						,[QTY]
						,[DOC_NUM_POLIZA]
						,[CODIGO_POLIZA]
						,[NUMERO_ORDEN_POLIZA]
						,[WAVE_PICKING_ID]
						,[CREATED_DATE]
						,[CODE_WAREHOUSE]
						,[TYPE_DEMAND_CODE]
						,[TYPE_DEMAND_NAME]
						,[LINE_NUM]
					 )
			SELECT
				@DISPATCH_LICENSE_EXIT_HEADER
				,[PDH].[CLIENT_CODE]
				,[PDH].[CLIENT_NAME]
				,[PDH].[PICKING_DEMAND_HEADER_ID]
				,[PDH].[DOC_NUM]
				,[PDD].[MATERIAL_ID]
				,[M].[MATERIAL_NAME]
				,[PDD].[QTY]
				,[PH].[DOC_NUM_POLIZA]
				,[PH].[CODIGO_POLIZA]
				,[PH].[NUMERO_ORDEN_POLIZA]
				,[PDH].[WAVE_PICKING_ID]
				,GETDATE()
				,[PDH].[CODE_WAREHOUSE]
				,[PDH].[TYPE_DEMAND_CODE]
				,[PDH].[TYPE_DEMAND_NAME]
				,[PDD].[LINE_NUM]
			FROM
				[FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
			INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD] ON ([PDH].[PICKING_DEMAND_HEADER_ID] = [PDD].[PICKING_DEMAND_HEADER_ID])
			INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M] ON ([PDD].[MATERIAL_ID] = [M].[MATERIAL_ID])
			INNER JOIN @POLIZA_HEADER [PH] ON ([PDH].[PICKING_DEMAND_HEADER_ID] = [PH].[PICKING_DEMAND_HEADER_ID])
			WHERE
				[PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

      -- ------------------------------------------------------------------------------------
      -- Eliminamos la demanda ya procesada
      -- ------------------------------------------------------------------------------------
			DELETE
				@PICKING_DEMAND_HEADER
			WHERE
				[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

      -- ------------------------------------------------------------------------------------
      -- Eliminamos las licencias que ya no tengan inventario
      -- ------------------------------------------------------------------------------------
			DELETE
				@LICENSE_PICKING_DEMAND
			WHERE
				[QTY] <= 0;

		END;



    -- ------------------------------------------------------------------------------------
    -- Validamos si existen licencias.
    -- ------------------------------------------------------------------------------------
		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							@LICENSE_PICKING_DEMAND )
		BEGIN

			IF (@PROCESS_DOCUMENTS = 0)
			BEGIN

				DECLARE
					@CODIGO_POLIZA VARCHAR(25)
					,@DOC_NUM_POLIZA INT
					,@NUMERO_ORDEN_POLIZA VARCHAR(25);

				SELECT TOP 1
					@DOC_NUM_POLIZA = [PH].[DOC_ID]
					,@CODIGO_POLIZA = [PH].[CODIGO_POLIZA]
					,@NUMERO_ORDEN_POLIZA = [PH].[NUMERO_ORDEN]
				FROM
					[FERCO].[OP_WMS_TASK_LIST] [TL]
				INNER JOIN [FERCO].[OP_WMS_POLIZA_HEADER] [PH] ON ([TL].[CODIGO_POLIZA_TARGET] = [PH].[CODIGO_POLIZA])
				WHERE
					[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;

				INSERT	[FERCO].[OP_WMS_DISPATCH_LICENSE_EXIT_DETAIL]
						(
							[DISPATCH_LICENSE_EXIT_HEADER_ID]
							,[CLIENT_CODE]
							,[CLIENT_NAME]
							,[PICKING_DEMAND_HEADER_ID]
							,[DOC_NUM]
							,[MATERIAL_ID]
							,[MATERIAL_NAME]
							,[QTY]
							,[DOC_NUM_POLIZA]
							,[CODIGO_POLIZA]
							,[NUMERO_ORDEN_POLIZA]
							,[WAVE_PICKING_ID]
							,[CREATED_DATE]
							,[CODE_WAREHOUSE]
						 )
				SELECT
					@DISPATCH_LICENSE_EXIT_HEADER
					,[L].[CLIENT_OWNER]
					,[VC].[CLIENT_NAME]
					,0
					,0
					,[IL].[MATERIAL_ID]
					,[IL].[MATERIAL_NAME]
					,[LO].[QTY_ORIGIN]
					,@DOC_NUM_POLIZA
					,@CODIGO_POLIZA
					,@NUMERO_ORDEN_POLIZA
					,[L].[WAVE_PICKING_ID]
					,GETDATE()
					,[L].[CURRENT_WAREHOUSE]
				FROM
					@LICENSE_ORIGIN [LO]
				INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[LO].[LICENSE_ID] = [IL].[LICENSE_ID]
											AND [LO].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											)
				INNER JOIN [FERCO].[OP_WMS_LICENSES] [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
				INNER JOIN [FERCO].[OP_WMS_VIEW_CLIENTS] [VC] ON ([L].[CLIENT_OWNER] = [VC].[CLIENT_CODE]);

			END;
      -- ------------------------------------------------------------------------------------
      -- Rebajamos y actualizamos las licencias 
      -- ------------------------------------------------------------------------------------

			UPDATE
				[IL]
			SET	
				[IL].[QTY] = ([IL].[QTY] - [LO].[QTY])
				,[LAST_UPDATED] = GETDATE()
				,[LAST_UPDATED_BY] = @LOGIN
			FROM
				[FERCO].[OP_WMS_INV_X_LICENSE] [IL]
			INNER JOIN @LICENSE_ORIGIN [LO] ON (
											[IL].[LICENSE_ID] = [LO].[LICENSE_ID]
											AND [IL].[MATERIAL_ID] = [LO].[MATERIAL_ID]
											);
		END;
		ELSE
		BEGIN
      -- ------------------------------------------------------------------------------------
      -- Hay un desface en el inventario ya que no deberian de quedar licencias.
      -- ------------------------------------------------------------------------------------

			SELECT
				@ErrorCode = 4001;
			RAISERROR ('No se puedo rebajar todo el inventario.', 16, 1);
			RETURN;
		END;

    -- ------------------------------------------------------------------------------------
    -- Actualizamos la tarea
    -- ------------------------------------------------------------------------------------
		UPDATE
			[TL]
		SET	
			[TL].[DISPATCH_LICENSE_EXIT_BY] = @LOGIN
			,[TL].[DISPATCH_LICENSE_EXIT_DATETIME] = GETDATE()
		FROM
			[FERCO].[OP_WMS_TASK_LIST] [TL]
		WHERE
			[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;


    -- ------------------------------------------------------------------------------------
    -- Validamos si hay todavia inventario para completar la tarea
    -- ------------------------------------------------------------------------------------
		IF 0 = (SELECT
					SUM([IL].[QTY])
				FROM
					[FERCO].[OP_WMS_LICENSES] [L]
				INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
				WHERE
					[L].[WAVE_PICKING_ID] = @WAVE_PICKING_ID)
		BEGIN
      -- ------------------------------------------------------------------------------------
      -- Actualizamos la tarea como entraga completa
      -- ------------------------------------------------------------------------------------
			UPDATE
				[TL]
			SET	
				[TL].[DISPATCH_LICENSE_EXIT_COMPLETED] = 1
			FROM
				[FERCO].[OP_WMS_TASK_LIST] [TL]
			WHERE
				[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
		END;

			-- ------------------------------------------------------------------------------------
			-- si la ola pertenece a un manifiesto busco el id y busco las olas asociadas
			-- y si todas fueron despachadas se marca como certificado el manifiesto
			-- 
			-- ------------------------------------------------------------------------------------

		DECLARE	@WAVES_BY_MANIFEST TABLE (
				[WAVE_PICKING_ID] INT
			);
		DECLARE	@MANIFEST_HEADER_ID INT= -1;

		SELECT TOP 1
			@MANIFEST_HEADER_ID = [MD].[MANIFEST_HEADER_ID]
		FROM
			[FERCO].[OP_WMS_MANIFEST_DETAIL] [MD]
		INNER JOIN [FERCO].[OP_WMS_MANIFEST_HEADER] [MH] ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
		WHERE
			[MH].[STATUS] NOT IN ('CANCELED', 'CERTIFIED')
			AND [WAVE_PICKING_ID] = @WAVE_PICKING_ID;

		INSERT	INTO @WAVES_BY_MANIFEST
				(
					[WAVE_PICKING_ID]
				)
		SELECT
			[WAVE_PICKING_ID]
		FROM
			[FERCO].[OP_WMS_MANIFEST_DETAIL]
		WHERE
			[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
		GROUP BY
			[WAVE_PICKING_ID];

		IF NOT EXISTS ( SELECT TOP 1
							1 --[TL].[WAVE_PICKING_ID] 
						FROM
							[FERCO].[OP_WMS_TASK_LIST] [TL]
						INNER JOIN [FERCO].[OP_WMS_LICENSES] [L] ON (
											[L].[LICENSE_ID] > 0
											AND [TL].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID]
											)
						INNER JOIN @WAVES_BY_MANIFEST [WM] ON [WM].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
											AND [TL].[IS_COMPLETED] = 1
											AND [TL].[DISPATCH_LICENSE_EXIT_COMPLETED] = 0
						GROUP BY
							[TL].[WAVE_PICKING_ID] )
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- si todas las olas ya fueron despachadas marcamos el manifiesto como CERTIFICADO
			-- ------------------------------------------------------------------------------------
			UPDATE
				[FERCO].[OP_WMS_MANIFEST_HEADER]
			SET	
				[STATUS] = 'CERTIFIED'
			WHERE
				[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;
		END;

		COMMIT;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso1' AS [Mensaje]
			,0 [Codigo]
			,CAST(@DISPATCH_LICENSE_EXIT_HEADER AS VARCHAR(20)) AS [DbData];

	END TRY
	BEGIN CATCH
		ROLLBACK;
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@ErrorCode [Codigo];
	END CATCH;
END;