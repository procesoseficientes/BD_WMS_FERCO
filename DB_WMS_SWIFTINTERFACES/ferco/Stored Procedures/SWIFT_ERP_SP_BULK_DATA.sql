﻿
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	23-01-2016
-- Description:			Obtiene Los datos del ERP

--Modificacion 19-02-2016
--rudi.garcia
--Se modifico la la funcion que trae inventory, se agrego las condiciones de lotacion y warehouse

/*
-- Ejemplo de Ejecucion:
				EXEC [ferco].[SWIFT_ERP_SP_BULK_DATA]
*/
-- =============================================
CREATE PROCEDURE ferco.SWIFT_ERP_SP_BULK_DATA
AS
  PRINT 'INSERTA EN SKUs'
  MERGE ferco.SWIFT_ERP_SKU TRG
  USING (SELECT
      *
    FROM SWIFT_INTERFACES_ONLINE.ferco.ERP_VIEW_SKU) AS SRC
  ON TRG.CODE_SKU = SRC.CODE_SKU
    AND TRG.LIST_NUM = SRC.LIST_NUM
  WHEN MATCHED
    THEN UPDATE
      SET TRG.[SKU] = SRC.[SKU]
         ,TRG.[CODE_SKU] = SRC.[CODE_SKU]
         ,TRG.[DESCRIPTION_SKU] = SRC.[DESCRIPTION_SKU]
         ,TRG.[BARCODE_SKU] = SRC.[BARCODE_SKU]
         ,TRG.[NAME_PROVIDER] = SRC.[NAME_PROVIDER]
         ,TRG.[COST] = SRC.[COST]
         ,TRG.[LIST_PRICE] = SRC.[LIST_PRICE]
         ,TRG.[MEASURE] = SRC.[MEASURE]
         ,TRG.[NAME_CLASSIFICATION] = SRC.[NAME_CLASSIFICATION]
         ,TRG.[VALUE_TEXT_CLASSIFICATION] = SRC.[VALUE_TEXT_CLASSIFICATION]
         ,TRG.[HANDLE_SERIAL_NUMBER] = SRC.[HANDLE_SERIAL_NUMBER]
         ,TRG.[HANDLE_BATCH] = SRC.[HANDLE_BATCH]
         ,TRG.[FROM_ERP] = SRC.[FROM_ERP]
         ,TRG.[PRICE] = SRC.[PRICE]
         ,TRG.[LIST_NUM] = SRC.[LIST_NUM]
         ,TRG.[CODE_PROVIDER] = SRC.[CODE_PROVIDER]
         ,TRG.[LAST_UPDATE] = SRC.[LAST_UPDATE]
         ,TRG.[LAST_UPDATE_BY] = SRC.[LAST_UPDATE_BY]
  WHEN NOT MATCHED
    THEN INSERT ([SKU]
      , [CODE_SKU]
      , [DESCRIPTION_SKU]
      , [BARCODE_SKU]
      , [NAME_PROVIDER]
      , [COST]
      , [LIST_PRICE]
      , [MEASURE]
      , [NAME_CLASSIFICATION]
      , [VALUE_TEXT_CLASSIFICATION]
      , [HANDLE_SERIAL_NUMBER]
      , [HANDLE_BATCH]
      , [FROM_ERP]
      , [PRICE]
      , [LIST_NUM]
      , [CODE_PROVIDER]
      , [LAST_UPDATE]
      , [LAST_UPDATE_BY])
        VALUES (SRC.[SKU], SRC.[CODE_SKU], SRC.[DESCRIPTION_SKU], SRC.[BARCODE_SKU], SRC.[NAME_PROVIDER], SRC.[COST], SRC.[LIST_PRICE], SRC.[MEASURE], SRC.[NAME_CLASSIFICATION], SRC.[VALUE_TEXT_CLASSIFICATION], SRC.[HANDLE_SERIAL_NUMBER], SRC.[HANDLE_BATCH], SRC.[FROM_ERP], SRC.[PRICE], SRC.[LIST_NUM], SRC.[CODE_PROVIDER], SRC.[LAST_UPDATE], SRC.[LAST_UPDATE_BY]);

  PRINT 'INSERTA EN SELLERS'
  MERGE ferco.SWIFT_ERP_SELLER TRG
  USING (SELECT
      *
    FROM SWIFT_INTERFACES_ONLINE.ferco.ERP_VIEW_SELLER) AS SRC
  ON TRG.SELLER_CODE = SRC.SELLER_CODE
  WHEN MATCHED
    THEN UPDATE
      SET TRG.[SELLER_CODE] = SRC.[SELLER_CODE]
         ,TRG.[SELLER_NAME] = SRC.[SELLER_NAME]
  WHEN NOT MATCHED
    THEN INSERT ([SELLER_CODE]
      , [SELLER_NAME])
        VALUES (SRC.[SELLER_CODE], SRC.[SELLER_NAME]);

  PRINT 'INSERTA EN PROVIDERS'
  MERGE ferco.SWIFT_ERP_PROVIDERS TRG
  USING (SELECT
      *
    FROM SWIFT_INTERFACES_ONLINE.ferco.ERP_VIEW_PROVIDERS) AS SRC
  ON TRG.CODE_PROVIDER = SRC.CODE_PROVIDER
  WHEN MATCHED
    THEN UPDATE
      SET TRG.[PROVIDER] = SRC.[PROVIDER]
         ,TRG.[CODE_PROVIDER] = SRC.[CODE_PROVIDER]
         ,TRG.[NAME_PROVIDER] = SRC.[NAME_PROVIDER]
         ,TRG.[CLASSIFICATION_PROVIDER] = SRC.[CLASSIFICATION_PROVIDER]
         ,TRG.[CONTACT_PROVIDER] = SRC.[CONTACT_PROVIDER]
         ,TRG.[FROM_ERP] = SRC.[FROM_ERP]
         ,TRG.[NAME_CLASSIFICATION] = SRC.[NAME_CLASSIFICATION]
  WHEN NOT MATCHED
    THEN INSERT ([PROVIDER]
      , [CODE_PROVIDER]
      , [NAME_PROVIDER]
      , [CLASSIFICATION_PROVIDER]
      , [CONTACT_PROVIDER]
      , [FROM_ERP]
      , [NAME_CLASSIFICATION])
        VALUES (SRC.[PROVIDER], SRC.[CODE_PROVIDER], SRC.[NAME_PROVIDER], SRC.[CLASSIFICATION_PROVIDER], SRC.[CONTACT_PROVIDER], SRC.[FROM_ERP], SRC.[NAME_CLASSIFICATION]);

  PRINT ' INSERTA EN CUSTOMERS'
  MERGE ferco.SWIFT_ERP_CUSTOMERS TRG
  USING (SELECT
      *
    FROM SWIFT_INTERFACES_ONLINE.ferco.ERP_VIEW_COSTUMER) AS SRC
  ON TRG.CODE_CUSTOMER = SRC.CODE_CUSTOMER
  WHEN MATCHED
    THEN UPDATE
      SET TRG.[CODE_CUSTOMER] = SRC.[CODE_CUSTOMER]
         ,TRG.[NAME_CUSTOMER] = SRC.[NAME_CUSTOMER]
         ,TRG.[PHONE_CUSTOMER] = SRC.[PHONE_CUSTOMER]
         ,TRG.[ADRESS_CUSTOMER] = SRC.[ADRESS_CUSTOMER]
         ,TRG.[CLASSIFICATION_CUSTOMER] = SRC.[CLASSIFICATION_CUSTOMER]
         ,TRG.[CONTACT_CUSTOMER] = SRC.[CONTACT_CUSTOMER]
         ,TRG.[CODE_ROUTE] = SRC.[CODE_ROUTE]
         ,TRG.[LAST_UPDATE] = SRC.[LAST_UPDATE]
         ,TRG.[LAST_UPDATE_BY] = SRC.[LAST_UPDATE_BY]
         ,TRG.[SELLER_DEFAULT_CODE] = SRC.[SELLER_DEFAULT_CODE]
         ,TRG.[CREDIT_LIMIT] = SRC.[CREDIT_LIMIT]
         ,TRG.[FROM_ERP] = SRC.[FROM_ERP]
         ,TRG.[NAME_ROUTE] = SRC.[NAME_ROUTE]
         ,TRG.[NAME_CLASSIFICATION] = SRC.[NAME_CLASSIFICATION]
         ,TRG.[GPS] = ISNULL(SRC.[LATITUDE] + ',' + SRC.[LONGITUDE], '0,0')
         ,TRG.[LATITUDE] = ISNULL(SRC.[LATITUDE], '0')
         ,TRG.[LONGITUDE] = ISNULL(SRC.[LONGITUDE], '0')
         ,TRG.[FREQUENCY] = ISNULL(SRC.[FREQUENCY], '1')
         ,TRG.[SUNDAY] = ISNULL(SRC.[SUNDAY], '0')
         ,TRG.[MONDAY] = ISNULL(SRC.[MONDAY], '0')
         ,TRG.[TUESDAY] = ISNULL(SRC.[TUESDAY], '0')
         ,TRG.[WEDNESDAY] = ISNULL(SRC.[WEDNESDAY], '0')
         ,TRG.[THURSDAY] = ISNULL(SRC.[THURSDAY], '0')
         ,TRG.[FRIDAY] = ISNULL(SRC.[FRIDAY], '0')
         ,TRG.[SATURDAY] = ISNULL(SRC.[SATURDAY], '0')
         ,TRG.[SCOUTING_ROUTE] = SRC.[SCOUTING_ROUTE]
  WHEN NOT MATCHED
    THEN INSERT ([CODE_CUSTOMER]
      , [NAME_CUSTOMER]
      , [PHONE_CUSTOMER]
      , [ADRESS_CUSTOMER]
      , [CLASSIFICATION_CUSTOMER]
      , [CONTACT_CUSTOMER]
      , [CODE_ROUTE]
      , [LAST_UPDATE]
      , [LAST_UPDATE_BY]
      , [SELLER_DEFAULT_CODE]
      , [CREDIT_LIMIT]
      , [FROM_ERP]
      , [NAME_ROUTE]
      , [NAME_CLASSIFICATION]
      , [GPS]
      , [LATITUDE]
      , [LONGITUDE]
      , [FREQUENCY]
      , [SUNDAY]
      , [MONDAY]
      , [TUESDAY]
      , [WEDNESDAY]
      , [THURSDAY]
      , [FRIDAY]
      , [SATURDAY]
      , [SCOUTING_ROUTE])
        VALUES (SRC.[CODE_CUSTOMER], SRC.[NAME_CUSTOMER], SRC.[PHONE_CUSTOMER], SRC.[ADRESS_CUSTOMER], SRC.[CLASSIFICATION_CUSTOMER], SRC.[CONTACT_CUSTOMER], SRC.[CODE_ROUTE], SRC.[LAST_UPDATE], SRC.[LAST_UPDATE_BY], SRC.[SELLER_DEFAULT_CODE], SRC.[CREDIT_LIMIT], SRC.[FROM_ERP], SRC.[NAME_ROUTE], SRC.[NAME_CLASSIFICATION], ISNULL(SRC.[LATITUDE] + ',' + SRC.[LONGITUDE], '0,0'), ISNULL(SRC.[LATITUDE], '0'), ISNULL(SRC.[LONGITUDE], '0'), ISNULL(SRC.[FREQUENCY], '1'), ISNULL(SRC.[SUNDAY], '0'), ISNULL(SRC.[MONDAY], '0'), ISNULL(SRC.[TUESDAY], '0'), ISNULL(SRC.[WEDNESDAY], '0'), ISNULL(SRC.[THURSDAY], '0'), ISNULL(SRC.[FRIDAY], '0'), ISNULL(SRC.[SATURDAY], '0'), SRC.[SCOUTING_ROUTE]);

  PRINT 'INSERTA EN ORDER_DETAIL'
  DELETE FROM [ferco].[SWIFT_ERP_ORDER_DETAIL]
  INSERT INTO [ferco].[SWIFT_ERP_ORDER_DETAIL]
    SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_ORDER_DETAIL]

  PRINT 'INSERTA EN ORDER_HEADER'
  --Se comenta porque hay que cambiar por un merge
  --DELETE FROM [ferco].[SWIFT_ERP_ORDER_HEADER]
  --INSERT INTO [ferco].[SWIFT_ERP_ORDER_HEADER]
  --SELECT * FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_ORDER_HEADER]

  PRINT 'INSERTA EN ORDER_SERIE_DETAIL'
  DELETE FROM [ferco].[SWIFT_ERP_ORDER_SERIE_DETAIL]
  INSERT INTO [ferco].[SWIFT_ERP_ORDER_SERIE_DETAIL]
    SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_ORDER_SERIE_DETAIL]

  PRINT 'INSERTA EN PICKING'
  DELETE FROM [ferco].[SWIFT_ERP_PICKING]
  INSERT INTO [ferco].[SWIFT_ERP_PICKING]
    SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_PICKING]

  PRINT 'INSERTA EN PURCHASE_ORDER_DETAIL'
  DELETE FROM [ferco].[SWIFT_ERP_PURCHASE_ORDER_DETAIL]
  INSERT INTO [ferco].[SWIFT_ERP_PURCHASE_ORDER_DETAIL]
    SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_PURCHASE_ORDER_DETAIL]

  PRINT 'INSERTA EN PURCHASE_ORDER_HEADER'
  DELETE FROM [ferco].[SWIFT_ERP_PURCHASE_ORDER_HEADER]
  INSERT INTO [ferco].[SWIFT_ERP_PURCHASE_ORDER_HEADER]
    SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_PURCHASE_ORDER_HEADER]

  PRINT 'INSERTA EN PURCHASE_SERIE_DETAIL'
  DELETE FROM [ferco].[SWIFT_ERP_PURCHASE_SERIE_DETAIL]
  INSERT INTO [ferco].[SWIFT_ERP_PURCHASE_SERIE_DETAIL]
    SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_PURCHASE_SERIE_DETAIL]

  PRINT 'INSERTA EN RECEPTION'
  DELETE FROM [ferco].[SWIFT_ERP_RECEPTION]
  INSERT INTO [ferco].[SWIFT_ERP_RECEPTION]
    SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_RECEPTION]



  --LISTAS DE PRECIOS PARA SONDA CORE MIGRADAS DE SBO 
  PRINT 'INSERTA EN  PRICE_LIST'
  MERGE [SWIFT_EXPRESS].[ferco].[SWIFT_PRICE_LIST] AS TGR
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_PRICE_LIST]) AS SRC
  ON TGR.CODE_PRICE_LIST = SRC.CODE_PRICE_LIST
  WHEN MATCHED
    THEN UPDATE
      SET TGR.CODE_PRICE_LIST = SRC.CODE_PRICE_LIST
         ,TGR.NAME_PRICE_LIST = SRC.NAME_PRICE_LIST
         ,TGR.COMMENT = SRC.COMMENT
         ,TGR.LAST_UPDATE = SRC.LAST_UPDATE
         ,TGR.LAST_UPDATE_BY = SRC.LAST_UPDATE_BY
  WHEN NOT MATCHED
    THEN INSERT (CODE_PRICE_LIST
      , NAME_PRICE_LIST
      , COMMENT
      , LAST_UPDATE
      , LAST_UPDATE_BY)
        VALUES (SRC.CODE_PRICE_LIST, SRC.NAME_PRICE_LIST, SRC.COMMENT, SRC.LAST_UPDATE, SRC.LAST_UPDATE_BY);


  --LISTAS DE PRECIOS POR SKU PARA SONDA CORE MIGRADAS DE SBO 
  PRINT 'INSERTA EN  PRICE_LIST_BY_SKU'
  MERGE [SWIFT_EXPRESS].[ferco].[SWIFT_PRICE_LIST_BY_SKU] TGR
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_PRICE_LIST_BY_SKU]) SRC
  ON TGR.CODE_PRICE_LIST = SRC.CODE_PRICE_LIST
    AND TGR.CODE_SKU = SRC.CODE_SKU
  WHEN MATCHED
    THEN UPDATE
      SET TGR.COST = SRC.COST
  WHEN NOT MATCHED
    THEN INSERT (CODE_PRICE_LIST
      , CODE_SKU
      , COST)
        VALUES (SRC.CODE_PRICE_LIST, SRC.CODE_SKU, SRC.COST);

  --LISTAS DE PRECIOS POR SKU PARA SONDA CORE MIGRADAS DE SBO 
  PRINT 'INSERTA EN  PRICE_LIST_BY_CUSTOMER'
  MERGE [SWIFT_EXPRESS].[ferco].SWIFT_PRICE_LIST_BY_CUSTOMER TGR
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_PRICE_LIST_BY_CUSTOMER]) SRC
  ON TGR.CODE_CUSTOMER = SRC.CODE_CUSTOMER
  WHEN MATCHED
    THEN UPDATE
      SET TGR.CODE_PRICE_LIST = SRC.CODE_PRICE_LIST
  WHEN NOT MATCHED
    THEN INSERT (CODE_PRICE_LIST
      , CODE_CUSTOMER)
        VALUES (SRC.CODE_PRICE_LIST, SRC.CODE_CUSTOMER);



  --LISTAS DE BODEGAS  
  PRINT 'INSERTA EN SWIFT_WAREHOUSES'
  MERGE [SWIFT_INTERFACES].[ferco].[SWIFT_ERP_WAREHOUSE] SWI
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_WAREHOUSE]) WVH
  ON SWI.[CODE_WAREHOUSE] = WVH.[CODE_WAREHOUSE]
  WHEN MATCHED
    THEN UPDATE
      SET SWI.[DESCRIPTION_WAREHOUSE] = WVH.[DESCRIPTION]
         ,SWI.[WEATHER_WAREHOUSE] = WVH.[WEATHER_WAREHOUSE]
         ,SWI.[STATUS_WAREHOUSE] = WVH.[STATUS_WAREHOUSE]
         ,SWI.[LAST_UPDATE] = WVH.[LAST_UPDATE]
         ,SWI.[LAST_UPDATE_BY] = WVH.[LAST_UPDATE_BY]
         ,SWI.[IS_EXTERNAL] = WVH.[IS_EXTERNAL]
  WHEN NOT MATCHED
    THEN INSERT ([CODE_WAREHOUSE]
      , [DESCRIPTION_WAREHOUSE]
      , [WEATHER_WAREHOUSE]
      , [STATUS_WAREHOUSE]
      , [LAST_UPDATE]
      , [LAST_UPDATE_BY]
      , [IS_EXTERNAL])
        VALUES (WVH.[CODE_WAREHOUSE], WVH.[DESCRIPTION], WVH.[WEATHER_WAREHOUSE], WVH.[STATUS_WAREHOUSE], WVH.[LAST_UPDATE], WVH.[LAST_UPDATE_BY], WVH.[IS_EXTERNAL]);



  --LISTAS DE DETALLES DE INVENTARIO
  PRINT 'INSERTA EN  SWIFT_INVENTORY'
  MERGE [SWIFT_EXPRESS].[ferco].[SWIFT_INVENTORY] SIV
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_INVENTORY]) EVI
  ON (ISNULL(SIV.[SERIAL_NUMBER], '--') = ISNULL(EVI.[SERIAL_NUMBER], '--')
    AND SIV.[SKU] = EVI.[SKU]
    AND EVI.LOCATION = SIV.LOCATION
    AND EVI.WAREHOUSE = SIV.WAREHOUSE)
  WHEN MATCHED
    THEN UPDATE
      SET
      --SIV.[WAREHOUSE] = EVI.[WAREHOUSE]
      --,SIV.[LOCATION]			= EVI.[LOCATION]
      SIV.[SKU_DESCRIPTION] = EVI.[SKU_DESCRIPTION]
     ,SIV.[ON_HAND] = EVI.[ON_HAND]
     ,SIV.[BATCH_ID] = EVI.[BATCH_ID]
     ,SIV.[LAST_UPDATE] = EVI.[LAST_UPDATE]
     ,SIV.[LAST_UPDATE_BY] = EVI.[LAST_UPDATE_BY]
  --,SIV.[TXN_ID]				= EVI.[TXN_ID]
  --,SIV.[IS_SCANNED]			= EVI.[IS_SCANNED]
  --,SIV.[RELOCATED_DATE]		= EVI.[RELOCATED_DATE]

  WHEN NOT MATCHED
    THEN INSERT ([SERIAL_NUMBER]
      , [WAREHOUSE]
      , [LOCATION]
      , [SKU]
      , [SKU_DESCRIPTION]
      , [ON_HAND]
      , [BATCH_ID]
      , [LAST_UPDATE]
      , [LAST_UPDATE_BY]
      , [TXN_ID]
      , [IS_SCANNED]
      , [RELOCATED_DATE])
        VALUES (EVI.[SERIAL_NUMBER], EVI.[WAREHOUSE], EVI.[LOCATION], EVI.[SKU], EVI.[SKU_DESCRIPTION], EVI.[ON_HAND], EVI.[BATCH_ID], EVI.[LAST_UPDATE], EVI.[LAST_UPDATE_BY], EVI.[TXN_ID], EVI.[IS_SCANNED], EVI.[RELOCATED_DATE]);



  --LISTAS DE DETALLES DE BODEGAS
  PRINT 'INSERTA EN  SONDA_IS_COMITED_BY_WAREHOUSE'
  MERGE [SWIFT_EXPRESS].[ferco].[SONDA_IS_COMITED_BY_WAREHOUSE] SIW
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[ferco].[ERP_VIEW_COMMITED_BY_WAREHOUSE]) EVW
  ON (SIW.[CODE_WAREHOUSE] = EVW.[CODE_WAREHOUSE]
    AND SIW.[CODE_SKU] = EVW.[CODE_SKU])
  WHEN MATCHED
    THEN UPDATE
      SET SIW.[IS_COMITED] = EVW.[IS_COMMITED]
  WHEN NOT MATCHED
    THEN INSERT ([CODE_WAREHOUSE]
      , [CODE_SKU]
      , [IS_COMITED])
        VALUES (EVW.[CODE_WAREHOUSE], EVW.[CODE_SKU], EVW.[IS_COMMITED]);
