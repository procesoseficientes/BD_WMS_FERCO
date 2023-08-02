﻿
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-03 @ Team REBORN - Sprint 
-- Description:	        SP que devuelve los materiales con el lote que mas se saco en una demanda de despacho

/*
-- Ejemplo de Ejecucion:
			EXEC  
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_GET_MATERIALS_WITH_BATCH_FROM_DEMAND_DISPATCH (@PICKING_DEMAND_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @MATERIAL_ID VARCHAR(50)
         ,@BATCH VARCHAR(50)

  DECLARE @MATERIALS_DEMAND TABLE (
    [WAVE_PICKING_ID] INT
   ,[MATERIAL_ID] VARCHAR(50)
  )

  INSERT INTO @MATERIALS_DEMAND ([WAVE_PICKING_ID], [MATERIAL_ID])
    SELECT
      [PDH].[WAVE_PICKING_ID]
     ,[PDD].[MATERIAL_ID]
    FROM [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
    INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
      ON (
        [PDH].[PICKING_DEMAND_HEADER_ID] = [PDD].[PICKING_DEMAND_HEADER_ID]
        )
    WHERE [PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
    GROUP BY [PDH].[WAVE_PICKING_ID]
            ,[PDD].[MATERIAL_ID]


  DECLARE @MATERIALS_WITH_BATCH TABLE (
    [MATERIAL_ID] VARCHAR(50)
   ,[NEXT_QTY] NUMERIC(18, 4)
   ,[BATCH] VARCHAR(50)
  )
  INSERT INTO @MATERIALS_WITH_BATCH
    SELECT
      [TL].[MATERIAL_ID]
     ,[TL].[QUANTITY_ASSIGNED] - [TL].[QUANTITY_PENDING] AS NEXT_QTY
     ,[IL].[BATCH]
    FROM @MATERIALS_DEMAND [MD]
    INNER JOIN [FERCO].[OP_WMS_TASK_LIST] [TL]
      ON (
          [TL].[MATERIAL_ID] = [MD].[MATERIAL_ID]
          AND [MD].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
        )
    INNER JOIN [FERCO].[OP_WMS_MATERIALS] [M]
      ON (
        [M].[MATERIAL_ID] = [MD].[MATERIAL_ID]
        )
    INNER JOIN [FERCO].[OP_WMS_INV_X_LICENSE] [IL]
      ON (
          [IL].[LICENSE_ID] = [TL].[LICENSE_ID_SOURCE]
          AND [IL].[MATERIAL_ID] = [TL].[MATERIAL_ID]
        )
    WHERE [M].[BATCH_REQUESTED] = 1
    ORDER BY [TL].[MATERIAL_ID], NEXT_QTY DESC

  DECLARE @MATERIALS_WITH_BATCH_FINAL TABLE (
    [MATERIAL_ID] VARCHAR(50)
   ,[BATCH] VARCHAR(50)
  )

  WHILE EXISTS (SELECT TOP 1
      1
    FROM @MATERIALS_WITH_BATCH)
  BEGIN
  SELECT TOP 1
    @MATERIAL_ID = [M].[MATERIAL_ID]
   ,@BATCH = [M].[BATCH]
  FROM @MATERIALS_WITH_BATCH M

  INSERT INTO @MATERIALS_WITH_BATCH_FINAL ([MATERIAL_ID],
  [BATCH])
    VALUES (@MATERIAL_ID, @BATCH);

  DELETE @MATERIALS_WITH_BATCH
  WHERE [MATERIAL_ID] = @MATERIAL_ID

  END


  SELECT
    *
  FROM @MATERIALS_WITH_BATCH_FINAL


END
