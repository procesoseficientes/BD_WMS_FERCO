﻿-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 22-08-2016
-- Description:			Se agregaron los parametros de numero de polizas.

/*
  -- Ejemplo de Ejecucion:
				-- 
				EXEC sp_INSERT_TASKS
            	@TASK_TYPE = ''
            	,@TASK_SUBTYPE = ''
            	,@TASK_OWNER = ''
            	,@TASK_ASSIGNEDTO	= ''
            	,@QUANTITY_ASSIGNED	= 0
            	,@QUANTITY_PENDING = 0
            	,@CODIGO_POLIZA_SOURCE = ''
            	,@CODIGO_POLIZA_TARGET = ''
            	,@REGIMEN = ''
            	,@MATERIAL_ID = ''
            	,@BARCODE_ID = ''
            	,@ALTERNATE_BARCODE = ''
            	,@MATERIAL_NAME = ''
            	,@CLIENT_OWNER = ''
            	,@CLIENT_NAME = ''
            	,@PRESULT = ''
            	,@WAVE_PICKING_ID = ''
            	,@TRAMSLATION = ''
              ,@LINE_NUMBER_SOURCE = 0
              ,@LINE_NUMBER_TARGET = 0
        
*/
-- =============================================

CREATE PROCEDURE [FERCO].[sp_INSERT_TASKS]
	@TASK_TYPE VARCHAR(25)
	,@TASK_SUBTYPE VARCHAR(25)
	,@TASK_OWNER VARCHAR(25)
	,@TASK_ASSIGNEDTO VARCHAR(25)
	,@QUANTITY_ASSIGNED NUMERIC(18, 3)
	,@QUANTITY_PENDING NUMERIC(18, 3)
	,@CODIGO_POLIZA_SOURCE VARCHAR(25)
	,@CODIGO_POLIZA_TARGET VARCHAR(25)
	,@REGIMEN VARCHAR(50)
	,@MATERIAL_ID VARCHAR(25)
	,@BARCODE_ID VARCHAR(50)
	,@ALTERNATE_BARCODE VARCHAR(50)
	,@MATERIAL_NAME VARCHAR(200)
	,@CLIENT_OWNER VARCHAR(25)
	,@CLIENT_NAME VARCHAR(150)
	,@PRESULT VARCHAR(4000) OUTPUT
	,@WAVE_PICKING_ID NUMERIC(18, 0) OUTPUT
	,@TRAMSLATION VARCHAR(10)
	,@LINE_NUMBER_POLIZA_SOURCE INT = 0
	,@LINE_NUMBER_POLIZA_TARGET INT = 0
AS
BEGIN
	DECLARE	@ASSIGNED_DATE DATETIME;
	DECLARE	@CURRENT_LOCATION VARCHAR(25);
	DECLARE	@CURRENT_WAREHOUSE VARCHAR(25);
	DECLARE	@LICENSE_ID NUMERIC(18, 0);
	DECLARE	@TASK_COMMENTS VARCHAR(150);
	DECLARE	@SHORT_DESC VARCHAR(50);
	DECLARE	@POLIZA_REGIME VARCHAR(25);
	
	DECLARE	@HAVBATCH NUMERIC(18);
	
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRAN;
			SELECT
				@ASSIGNED_DATE = GETDATE();
			IF @WAVE_PICKING_ID = 0
			BEGIN
				SELECT
					@WAVE_PICKING_ID = NEXT VALUE FOR [FERCO].[OP_WMS_SEQ_WAVE_PICKING_ID]; 
			END;
		
			IF @WAVE_PICKING_ID = NULL
			BEGIN
				SET @WAVE_PICKING_ID = 1;
			END;
		
			SELECT
				@POLIZA_REGIME = [REGIMEN]
			FROM
				[FERCO].[OP_WMS_POLIZA_HEADER]
			WHERE
				[CODIGO_POLIZA] = @CODIGO_POLIZA_TARGET;		

			IF @TRAMSLATION = 'SI'
			BEGIN
				IF EXISTS ( SELECT
								1
							FROM
								[FERCO].[OP_WMS_CONFIGURATIONS]
							WHERE
								[PARAM_NAME] = @POLIZA_REGIME
								AND [PARAM_TYPE] = 'ALMACENAMIENTO'
								AND [PARAM_GROUP] = 'TIPOS_ALMACENAJE' )
				BEGIN
					SET @TASK_SUBTYPE = 'TRASLADO_GENERAL';
				END;
			END;
		--IF UPPER(@POLIZA_REGIME) = '23DI0' OR UPPER(@POLIZA_REGIME) = '23DI'
		--	BEGIN
		--		SET @TASK_SUBTYPE = 'TRASLADO_GENERAL';
		--	END
		
			SELECT
				@HAVBATCH = COUNT(*)
			FROM
				[FERCO].[OP_WMS_MATERIALS]
			WHERE
				[CLIENT_OWNER] = @CLIENT_OWNER
				AND [MATERIAL_ID] = @MATERIAL_ID
				AND [BATCH_REQUESTED] = 1;		
		
			SELECT
				@TASK_COMMENTS = 'OLA DE PICKING #'
				+ CAST(@WAVE_PICKING_ID AS VARCHAR);
				
			SELECT
				@SHORT_DESC = SUBSTRING([SHORT_NAME], 1, 50)
			FROM
				[FERCO].[OP_WMS_MATERIALS]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID
				AND [BARCODE_ID] = @BARCODE_ID;
		
			IF @HAVBATCH = 0
			BEGIN	
				DECLARE [TASK_CURSOR] CURSOR
				FOR
				SELECT
					[CURRENT_LOCATION]
					,[CURRENT_WAREHOUSE]
					,[LICENSE_ID]
				FROM
					[FERCO].[OP_WMS3PL_VIEW_INVENTORY_FOR_PICKING]
				WHERE
					[CLIENT_OWNER] = @CLIENT_OWNER
					AND [REGIMEN] = @REGIMEN
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [CODIGO_POLIZA] = @CODIGO_POLIZA_SOURCE
					AND [QTY] > 0;
			END;		
			ELSE
			BEGIN 
				DECLARE [TASK_CURSOR] CURSOR
				FOR
				SELECT
					[CURRENT_LOCATION]
					,[CURRENT_WAREHOUSE]
					,[LICENSE_ID]
				FROM
					[FERCO].[OP_WMS3PL_VIEW_INVENTORY_FOR_PICKING_BATCH]
				WHERE
					[CLIENT_OWNER] = @CLIENT_OWNER
					AND [REGIMEN] = @REGIMEN
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [CODIGO_POLIZA] = @CODIGO_POLIZA_SOURCE
					AND [QTY] > 0
				ORDER BY
					[DATE_EXPIRATION] ASC;
			END;			
			
			OPEN [TASK_CURSOR];
			
			FETCH NEXT FROM [TASK_CURSOR] INTO @CURRENT_LOCATION,
				@CURRENT_WAREHOUSE, @LICENSE_ID;
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				IF EXISTS ( SELECT
								1
							FROM
								[FERCO].[OP_WMS_TASK_LIST]
							WHERE
								[WAVE_PICKING_ID] = @WAVE_PICKING_ID
								AND [CODIGO_POLIZA_SOURCE] = @CODIGO_POLIZA_SOURCE
								AND [CODIGO_POLIZA_TARGET] = @CODIGO_POLIZA_TARGET
								AND [LICENSE_ID_SOURCE] = @LICENSE_ID
								AND [MATERIAL_ID] = @MATERIAL_ID )
				BEGIN
					UPDATE
						[FERCO].[OP_WMS_TASK_LIST]
					SET	
						[QUANTITY_PENDING] = [QUANTITY_PENDING]
						+ @QUANTITY_PENDING
						,[QUANTITY_ASSIGNED] = [QUANTITY_ASSIGNED]
						+ @QUANTITY_ASSIGNED
					WHERE
						[WAVE_PICKING_ID] = @WAVE_PICKING_ID
						AND [CODIGO_POLIZA_SOURCE] = @CODIGO_POLIZA_SOURCE
						AND [CODIGO_POLIZA_TARGET] = @CODIGO_POLIZA_TARGET
						AND [LICENSE_ID_SOURCE] = @LICENSE_ID
						AND [MATERIAL_ID] = @MATERIAL_ID;
				END;
				ELSE
				BEGIN
					INSERT	INTO [FERCO].[OP_WMS_TASK_LIST]
							(
								[WAVE_PICKING_ID]
								,[TASK_TYPE]
								,[TASK_SUBTYPE]
								,[TASK_OWNER]
								,[TASK_ASSIGNEDTO]
								,[ASSIGNED_DATE]
								,[QUANTITY_PENDING]
								,[QUANTITY_ASSIGNED]
								,[CODIGO_POLIZA_SOURCE]
								,[CODIGO_POLIZA_TARGET]
								,[LICENSE_ID_SOURCE]
								,[REGIMEN]
								,[IS_DISCRETIONAL]
								,[MATERIAL_ID]
								,[BARCODE_ID]
								,[ALTERNATE_BARCODE]
								,[MATERIAL_NAME]
								,[WAREHOUSE_SOURCE]
								,[LOCATION_SPOT_SOURCE]
								,[CLIENT_OWNER]
								,[CLIENT_NAME]
								,[TASK_COMMENTS]
								,[TRANS_OWNER]
								,[IS_COMPLETED]
								,[MATERIAL_SHORT_NAME]
								,[LINE_NUMBER_POLIZA_SOURCE]
								,[LINE_NUMBER_POLIZA_TARGET]
							)
					VALUES
							(
								@WAVE_PICKING_ID
								,@TASK_TYPE
								,@TASK_SUBTYPE
								,@TASK_OWNER
								,@TASK_ASSIGNEDTO
								,@ASSIGNED_DATE
								,@QUANTITY_PENDING
								,@QUANTITY_ASSIGNED
								,@CODIGO_POLIZA_SOURCE
								,@CODIGO_POLIZA_TARGET
								,@LICENSE_ID
								,@REGIMEN
								,1
								,@MATERIAL_ID
								,@BARCODE_ID
								,@ALTERNATE_BARCODE
								,@MATERIAL_NAME
								,@CURRENT_WAREHOUSE
								,@CURRENT_LOCATION
								,@CLIENT_OWNER
								,@CLIENT_NAME
								,@TASK_COMMENTS
								,0
								,0
								,@SHORT_DESC
								,@LINE_NUMBER_POLIZA_SOURCE
								,@LINE_NUMBER_POLIZA_TARGET
							);
					
					INSERT	INTO [FERCO].[OP_LOG]
							(
								[ERR_DATETIME]
								,[ERR_TEXT]
								,[ERR_SQL]
							)
					VALUES
							(
								GETDATE()
								,'INSERTED'
								,'@MATERIAL_ID: '
								+ @MATERIAL_ID
								+ ' @CODIGO_POLIZA_SOURCE: '
								+ @CODIGO_POLIZA_SOURCE
								+ ' @CODIGO_POLIZA_TARGET: '
								+ @CODIGO_POLIZA_TARGET
								+ ' @LICENSE_ID: '
								+ CONVERT(VARCHAR(20), @LICENSE_ID)
							);					
				END;				
				FETCH NEXT 
				FROM [TASK_CURSOR] 
				INTO @CURRENT_LOCATION, @CURRENT_WAREHOUSE,
					@LICENSE_ID;
			END;
						
			CLOSE [TASK_CURSOR];
			DEALLOCATE [TASK_CURSOR];
						
			SELECT
				@PRESULT = 'OK';
						
			COMMIT TRAN;
		END TRY

		BEGIN CATCH
			ROLLBACK TRAN;
			SELECT
				@PRESULT = ERROR_MESSAGE();
			SELECT
				@WAVE_PICKING_ID = 0;
		END CATCH;
	
	END;