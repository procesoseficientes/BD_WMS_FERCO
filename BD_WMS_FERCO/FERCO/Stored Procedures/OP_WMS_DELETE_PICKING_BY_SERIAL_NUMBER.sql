﻿-- =============================================
-- Autor:				      hector.gonzalez
-- Fecha de Creacion: 04-10-2016
-- Description:			  Se elimina un picking por su Serial Number

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-25 ErgonTeam@Sheik
-- Description:	 Se agrega que devuelva objeto operación por cambio de arquitectura

-- Modificacion 9/22/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agrega la ejecucion de OP_WMS_SP_REGISTER_RECEPTION_STATUS

-- Modificación: marvin.garcia
-- Fecha de Modificación: 2018-06-26 A-Team@Elefante
-- Description:  Se agrega llamada a [FERCO].[OP_WMS_SP_DELETE_ERP_DOCUMENTS_FROM_TASK_ID] para eliminar documentos ERP

/*
  -- Ejemplo de Ejecucion:
				-- 
				EXEC [FERCO].OP_WMS_DELETE_PICKING_BY_SERIAL_NUMBER
            @SERIAL_NUMBER = 11454
            ,@USER_ID = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_DELETE_PICKING_BY_SERIAL_NUMBER] @SERIAL_NUMBER NUMERIC
, @USER_ID VARCHAR(25)
AS
  BEGIN TRAN
  BEGIN TRY

    IF EXISTS (SELECT
          1
        FROM [FERCO].[OP_WMS_TASK_LIST] [TL]
        WHERE [TL].[SERIAL_NUMBER] = @SERIAL_NUMBER
        AND [TL].[TASK_TYPE] = 'TAREA_RECEPCION'
        AND [TL].[ACCEPTED_DATE] IS NULL
        AND [TL].[COMPLETED_DATE] IS NULL
        AND [TL].[CANCELED_DATETIME] IS NULL)
    BEGIN
      DECLARE @CODIGO_POLIZA VARCHAR(25)
             ,@TASK_ASSIGNED_TO VARCHAR(50)
      --      ,@LINE_NUMBER INT

      SELECT
        @CODIGO_POLIZA = [CODIGO_POLIZA_SOURCE]
       ,@TASK_ASSIGNED_TO = [TASK_ASSIGNEDTO]
      FROM [FERCO].[OP_WMS_TASK_LIST]
      WHERE [SERIAL_NUMBER] = @SERIAL_NUMBER

      EXEC [FERCO].[OP_WMS_SP_REGISTER_RECEPTION_STATUS] @pTRANS_TYPE = 'INGRESO_GENERAL'
                                                          , -- varchar(25)
                                                           @pLOGIN_ID = @TASK_ASSIGNED_TO
                                                          , -- varchar(25)
                                                           @pCODIGO_POLIZA = @CODIGO_POLIZA
                                                          , -- varchar(25)
                                                           @pTASK_ID = @SERIAL_NUMBER
                                                          , -- numeric
                                                           @pSTATUS = 'COMPLETED' -- varchar(25)


      SELECT
        TL.SERIAL_NUMBER
       ,TL.CODIGO_POLIZA_TARGET
       ,TL.LINE_NUMBER_POLIZA_TARGET INTO #TASK
      FROM [FERCO].OP_WMS_TASK_LIST TL
      WHERE TL.[SERIAL_NUMBER] = @SERIAL_NUMBER

      UPDATE TL
      SET TL.IS_PAUSED = 3
         ,TL.IS_COMPLETED = 1
         ,TL.IS_CANCELED = 1
         ,TL.CANCELED_DATETIME = current_timestamp
         ,TL.CANCELED_BY = @USER_ID
      FROM [FERCO].OP_WMS_TASK_LIST TL
      INNER JOIN #TASK T
        ON (TL.SERIAL_NUMBER = T.SERIAL_NUMBER)
      --WHERE SERIAL_NUMBER = @SERIAL_NUMBER

      --    UPDATE [FERCO].OP_WMS_TASK_LIST
      --    SET IS_PAUSED = 3
      --       ,IS_COMPLETED = 1
      --       ,IS_CANCELED = 1
      --       ,CANCELED_DATETIME = CURRENT_TIMESTAMP
      --       ,CANCELED_BY = @USER_ID
      --    WHERE SERIAL_NUMBER = @SERIAL_NUMBER

      --    SELECT TOP 1
      --      @CODIGO_POLIZA = TL.CODIGO_POLIZA_TARGET
      --      ,@LINE_NUMBER = TL.LINE_NUMBER_POLIZA_TARGET
      --    FROM [FERCO].OP_WMS_TASK_LIST TL
      --    WHERE TL.SERIAL_NUMBER = @SERIAL_NUMBER    

      UPDATE PD
      SET PD.PICKING_STATUS = 'PENDING'
         ,PD.LAST_UPDATED_BY = @USER_ID
         ,PD.LAST_UPDATED = GETDATE()
      FROM [FERCO].OP_WMS_POLIZA_DETAIL PD
      INNER JOIN [FERCO].OP_WMS_POLIZA_HEADER PH
        ON (
        PD.DOC_ID = PH.DOC_ID
        )
      INNER JOIN #TASK T
        ON (PH.CODIGO_POLIZA = T.CODIGO_POLIZA_TARGET
        AND PD.LINE_NUMBER = T.LINE_NUMBER_POLIZA_TARGET)
      --    WHERE PH.CODIGO_POLIZA = @CODIGO_POLIZA
      --    AND PD.LINE_NUMBER = @LINE_NUMBER    
      --

      -- ELIMINANDO DOCUMENTOS DE ERP
      EXECUTE [FERCO].[OP_WMS_SP_DELETE_ERP_DOCUMENTS_FROM_TASK_ID] @TASK_ID = @SERIAL_NUMBER --NUMERIC(18,0)

      SELECT
        1 AS Resultado
       ,'Proceso Exitoso' Mensaje
       ,0 Codigo
       ,CONVERT(VARCHAR(16), 1) DbData
    END
    ELSE BEGIN
      SELECT
        -1 AS Resultado
       ,'No se puede cancelar una tarea de recepción cuando ya se esta operando.' Mensaje
       ,0 Codigo       
    END
    COMMIT TRAN
  END TRY
  BEGIN CATCH
    ROLLBACK
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH
