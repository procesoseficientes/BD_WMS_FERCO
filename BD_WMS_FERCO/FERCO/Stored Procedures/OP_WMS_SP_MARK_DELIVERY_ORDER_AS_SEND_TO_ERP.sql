-- =============================================

-- Procedimiento que actualiza los estados del ERP en WMS a travez del pase de salida que viene de la tabla OP_WMS_SP_UPDATE_STATUS_BY_EXIT_PASS

-- Autor:               Gildardo Alvarado
-- Fecha de Creacion:   03-Febrero-2021 @ProcesosEficientes
-- Description:         SP para las Delivery Order (Entregas preliminares) 
--						Permite actualizar los estados del ERP a travez del pase de salida 

-- Modificación:        Elder Lcas
-- Fecha de Creacion:   06-Junio-2021 @ProcesosEficientes
-- Description:         Permite cambiar el estado de error en las lineas de picking en casi
--						en caso de que haya algún error en el cierre del documento en sap						

/*
-- Ejemplo de Ejecucion:
		EXEC  [FERCO].[OP_WMS_SP_MARK_DELIVERY_ORDER_AS_SEND_TO_ERP]
			 @PASS_ID INT = 695049
		--
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_SP_MARK_DELIVERY_ORDER_AS_SEND_TO_ERP]
    (
     @PASS_ID INT,
	 @ATTEMPED_WHIT_ERROR INT
    )
AS
BEGIN
    SET NOCOUNT ON;
  --
    BEGIN TRY
   
    DECLARE @TYPE VARCHAR(50)
	,@ERP_DATABASE VARCHAR(50)
	,@SCHEMA_NAME VARCHAR(50)
	,@TABLE VARCHAR(50)
	,@OWNER VARCHAR(50)
	,@IS_INVOICE INT = 0
	,@DOC_NUM VARCHAR(50) 
	,@DOC_ENTRY VARCHAR(50)
	,@COUNT INT
	,@COUNTER INT;
				

	DECLARE @TB_WAVE_PICKING TABLE
			(
				[WAVE_PICKING_ID] INT
				,[DOC_NUM] INT
			);

	DECLARE @TB_DOC_NUM TABLE
			(
				[ID] INT NOT NULL  IDENTITY(1,1)
				,[DOC_NUM] INT
				,[DOC_ENTRY] INT
				,[WAVE_PICKING_ID] INT
				PRIMARY KEY (ID)
			);

	DECLARE @DOC TABLE
			(
				DOC_ENTRY INT
			);
	
	-- ------------------------------------------------------------------------------------
	-- Tabla temporal que obtiene los datos que harán Match con el ERP a través del @PASS_ID
	-- ------------------------------------------------------------------------------------
	INSERT @TB_WAVE_PICKING
		(
			[WAVE_PICKING_ID]
			,[DOC_NUM]
		)
	SELECT
		[PD].[WAVE_PICKING_ID]
		,[PD].[DOC_NUM]
	FROM
		FERCO.OP_WMS_PASS_DETAIL [PD]
	WHERE 
		[PD].[PASS_HEADER_ID] = @PASS_ID;

	-- ------------------------------------------------------------------------------------
	-- Tabla temporal que obtiene los datos del ERP
	-- ------------------------------------------------------------------------------------
	INSERT @TB_DOC_NUM
			(
				[DOC_NUM]
				,[DOC_ENTRY]
				,[WAVE_PICKING_ID]
			)
	SELECT
		ERP.DocNum
		,ERP.draftKey
		,ERP.[WAVE_PICKING_ID]
	FROM
		(
		SELECT  DISTINCT
			[ODRF].DocNum,
			[ODRF].draftKey,
			TB.WAVE_PICKING_ID
		FROM @TB_WAVE_PICKING [TB]
			INNER JOIN FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER NP ON (TB.WAVE_PICKING_ID = NP.WAVE_PICKING_ID)
			INNER JOIN SAPSERVER.SBOPruebas.dbo.ODLN [ODRF] ON ([ODRF].draftKey = [TB].DOC_NUM)
		where NP.SOURCE_TYPE = 'DO - ERP'
		
		) AS ERP


	-- ------------------------------------------------------------------------------------
	-- Obtiene la cantidad de vueltas para el ciclo 
	-- ------------------------------------------------------------------------------------
	SELECT @COUNT = COUNT(DOC_NUM) FROM @TB_WAVE_PICKING
	SET @COUNTER = 1
	PRINT CAST(@COUNT AS VARCHAR)
	-- ------------------------------------------------------------------------------------
	-- Comienza a actualizar hasta que se acabe el ciclo
	-- ------------------------------------------------------------------------------------ 
	
	WHILE ( @COUNTER <= @COUNT)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Trae los datos del ERP conforme el ciclo
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 
			@DOC_NUM = DOC_NUM,
			@DOC_ENTRY = DOC_ENTRY
		FROM @TB_DOC_NUM
		-- ------------------------------------------------------------------------------------
		-- Actualiza conforme al avanza el ciclo
		-- ------------------------------------------------------------------------------------
		UPDATE 
				[PH]
			SET 
				[PH].[IS_AUTHORIZED] = 1,
				[PH].[IS_POSTED_ERP] = 1,
				[PH].[POSTED_ERP] = GETDATE(),
				[PH].[POSTED_RESPONSE] = 'Nota preliminar de entrega cerrada exitosamente, Ref: ' + cast(@DOC_NUM AS VARCHAR),
				[PH].[ERP_REFERENCE] = @DOC_ENTRY,
				[PH].[ERP_REFERENCE_DOC_NUM] = @DOC_NUM
			FROM FERCO.OP_WMS_PASS_DETAIL [PD]
				INNER JOIN @TB_DOC_NUM [WP]
					ON ([PD].[WAVE_PICKING_ID] = [WP].[WAVE_PICKING_ID])
				INNER JOIN FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER [PH]
					ON [PH].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID]
			WHERE [PH].[IS_POSTED_ERP] <= 0
				  AND [PH].[IS_AUTHORIZED] = 0
				  AND [PH].SOURCE_TYPE = 'DO - ERP'
				  AND [PH].DOC_NUM = @DOC_ENTRY;
		-- ------------------------------------------------------------------------------------
		-- Elimina en el ciclo las que ya fueron actualizadas
		-- ------------------------------------------------------------------------------------							
							
		DELETE FROM @TB_DOC_NUM
		WHERE ID = @COUNTER
							
							
		SET @COUNTER  = @COUNTER  + 1
	END
	-- Marca todo el grupo de picking como fallido cuando una o varias de sus ordenes de venta no se enviaron correctamente
	IF (@ATTEMPED_WHIT_ERROR = -1)
	BEGIN
		INSERT INTO @DOC
		EXEC FERCO.GETDRAFTDOCENTRY_BY_PASS_ID @PASS_ID = @PASS_ID

			UPDATE PH
			SET PH.ATTEMPTED_WITH_ERROR = -1
			FROM @DOC D INNER JOIN 
			FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER PH ON PH.DOC_ENTRY = D.DOC_ENTRY 
	END

			
    -- ------------------------------------------------------------------------------------
    -- Muestra resultado final
    -- ------------------------------------------------------------------------------------
        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,'0' [DbData];
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,@@ERROR [Codigo];
    END CATCH;
END;
