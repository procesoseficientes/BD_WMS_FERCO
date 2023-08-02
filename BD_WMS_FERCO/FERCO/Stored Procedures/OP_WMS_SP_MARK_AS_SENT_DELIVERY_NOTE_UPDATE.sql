﻿
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/20/2017 @ NEXUS-Team Sprint GTA 
-- Description:			SP que marca como enviado una actualizacion en las notas de entrega

/*
-- Ejemplo de Ejecucion:
				EXEC [FERCO].[OP_WMS_SP_MARK_AS_SENT_DELIVERY_NOTE_UPDATE]
					@PICKING_DEMAND_HEADER_ID = 1
					,@POSTED_RESPONSE = 'Proceso Exitoso'
				-- 
				SELECT * FROM [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
				WHERE PICKING_DEMAND_HEADER_ID = 1
*/
-- =============================================
CREATE PROCEDURE FERCO.OP_WMS_SP_MARK_AS_SENT_DELIVERY_NOTE_UPDATE (@PICKING_DEMAND_HEADER_ID INT
, @POSTED_RESPONSE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    UPDATE [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
    SET [UPDATED_VEHICLE] = 1
       ,[UPDATED_VEHICLE_RESPONSE] = @POSTED_RESPONSE
    WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@ERROR AS VARCHAR)
        WHEN '2627' THEN ''
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@ERROR Codigo
  END CATCH
END
