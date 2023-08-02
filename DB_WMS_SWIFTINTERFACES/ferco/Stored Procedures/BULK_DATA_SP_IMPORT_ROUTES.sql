﻿
-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	18-08-2016
-- Description:			SP que importa las Rutas

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [ferco].[BULK_DATA_SP_IMPORT_ROUTES]
*/
-- =============================================
CREATE PROCEDURE [ferco].[BULK_DATA_SP_IMPORT_ROUTES]
AS
BEGIN
  SET NOCOUNT ON;
  --
  MERGE SWIFT_EXPRESS.[ferco].[SWIFT_ROUTES] AS TRG
  USING (SELECT
     [EVR].[CODE_ROUTE]
	 ,[EVR].[NAME_ROUTE]
	 ,[EVR].[GEOREFERENCE_ROUTE]
	 ,[EVR].[COMMENT_ROUTE]
	 ,[EVR].[LAST_UPDATE]
	 ,[EVR].[LAST_UPDATE_BY]
	 ,[EVR].[CODE_COUNTRY]
	 ,[EVR].[NAME_COUNTRY]
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_ROUTE] EVR ) AS SRC
  ON TRG.[CODE_ROUTE] COLLATE database_default = SRC.[CODE_ROUTE]
  WHEN MATCHED
    THEN UPDATE
      SET [NAME_ROUTE] = [SRC].[NAME_ROUTE]
         ,[GEOREFERENCE_ROUTE] = [SRC].[GEOREFERENCE_ROUTE]
         ,[COMMENT_ROUTE] = [SRC].[COMMENT_ROUTE]
         ,[LAST_UPDATE] = [SRC].[LAST_UPDATE]
		 ,[LAST_UPDATE_BY] = [SRC].[LAST_UPDATE_BY]
		 ,[CODE_COUNTRY] = [SRC].[CODE_COUNTRY]
		 ,[NAME_COUNTRY] = [SRC].[NAME_COUNTRY]
  WHEN NOT MATCHED
    THEN INSERT (
				[CODE_ROUTE]
				 ,[NAME_ROUTE]
				 ,[GEOREFERENCE_ROUTE]
				 ,[COMMENT_ROUTE]
				 ,[LAST_UPDATE]
				 ,[LAST_UPDATE_BY]
				 ,[CODE_COUNTRY] 
				 ,[NAME_COUNTRY]
				)
        VALUES (
				[SRC].[CODE_ROUTE]
				, [SRC].[NAME_ROUTE]
				, [SRC].[GEOREFERENCE_ROUTE]
				, [SRC].[COMMENT_ROUTE]
				, [SRC].[LAST_UPDATE]
				, [SRC].[LAST_UPDATE_BY]
				, [SRC].[CODE_COUNTRY]
				, [SRC].[NAME_COUNTRY]
		);
END