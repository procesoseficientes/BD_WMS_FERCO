



-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	16-12-2015
-- Description:			Vista que obtiene detalles de bodegas 

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [ferco].[ERP_VIEW_WAREHOUSE]
*/
-- =============================================

CREATE VIEW [ferco].[ERP_VIEW_WAREHOUSE]
as 
SELECT CODE_WAREHOUSE COLLATE database_default AS CODE_WAREHOUSE 
	,[DESCRIPTION] COLLATE database_default AS [DESCRIPTION]
	,[WEATHER_WAREHOUSE]   COLLATE database_default    AS [WEATHER_WAREHOUSE]
	,[STATUS_WAREHOUSE] COLLATE database_default  AS [STATUS_WAREHOUSE]
	,GETDATE()  AS [LAST_UPDATE]  
	,[LAST_UPDATE_BY] COLLATE database_default AS [LAST_UPDATE_BY]
	,[IS_EXTERNAL]		   AS [IS_EXTERNAL]
 from openquery (SAPSERVER,'SELECT  
	[WhsCode]  AS [CODE_WAREHOUSE]  
   ,[WhsName]  AS [DESCRIPTION]  
   ,''N/A''      AS [WEATHER_WAREHOUSE]
   ,''ACTIVA''   AS [STATUS_WAREHOUSE]
   ,GETDATE()  AS [LAST_UPDATE]  
   ,''BULKDATA'' AS [LAST_UPDATE_BY]
   ,NULL	   AS [IS_EXTERNAL]	
	FROM [SBOFERCO].[dbo].[OWHS] ')
	WHERE [STATUS_WAREHOUSE] = 'ACTIVA'