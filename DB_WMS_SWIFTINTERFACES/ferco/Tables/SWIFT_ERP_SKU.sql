﻿CREATE TABLE [ferco].[SWIFT_ERP_SKU] (
    [SKU]                       INT             NULL,
    [CODE_SKU]                  VARCHAR (50)    NOT NULL,
    [DESCRIPTION_SKU]           VARCHAR (MAX)   NULL,
    [BARCODE_SKU]               VARCHAR (30)    NULL,
    [NAME_PROVIDER]             VARCHAR (100)   NULL,
    [COST]                      FLOAT (53)      NULL,
    [LIST_PRICE]                NUMERIC (18)    NULL,
    [MEASURE]                   VARCHAR (50)    NULL,
    [NAME_CLASSIFICATION]       VARCHAR (150)   NULL,
    [VALUE_TEXT_CLASSIFICATION] VARCHAR (32)    NOT NULL,
    [HANDLE_SERIAL_NUMBER]      VARCHAR (2)     NULL,
    [HANDLE_BATCH]              VARCHAR (2)     NULL,
    [FROM_ERP]                  VARCHAR (2)     NULL,
    [PRICE]                     NUMERIC (19, 6) NULL,
    [LIST_NUM]                  SMALLINT        NOT NULL,
    [CODE_PROVIDER]             VARCHAR (30)    NULL,
    [LAST_UPDATE]               DATETIME        NULL,
    [LAST_UPDATE_BY]            VARCHAR (50)    NULL,
    [UNIT_MEASURE_SKU]          INT             NULL,
    [WEIGHT_SKU]                NUMERIC (18, 2) NULL,
    [VOLUME_SKU]                NUMERIC (18, 2) NULL,
    [LONG_SKU]                  NUMERIC (18, 2) NULL,
    [WIDTH_SKU]                 NUMERIC (18, 2) NULL,
    [HIGH_SKU]                  NUMERIC (18, 2) NULL,
    [CODE_FAMILY_SKU]           VARCHAR (50)    NULL,
    [USE_LINE_PICKING]          NUMERIC (18)    NULL,
    [VOLUME_CODE_UNIT]          VARCHAR (250)   NULL,
    [VOLUME_NAME_UNIT]          VARCHAR (250)   NULL,
    [OWNER]                     VARCHAR (50)    NULL,
    [OWNER_ID]                  VARCHAR (50)    NULL,
    [ART_CODE]                  VARCHAR (20)    NULL,
    [VAT_CODE]                  VARCHAR (20)    NULL,
    CONSTRAINT [PK_SWIFT_INFERFACES_ERP_SKU] PRIMARY KEY CLUSTERED ([CODE_SKU] ASC, [LIST_NUM] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SWIFT_ERP_SKU_CODE_SKU]
    ON [ferco].[SWIFT_ERP_SKU]([CODE_SKU] ASC)
    INCLUDE([DESCRIPTION_SKU], [BARCODE_SKU], [LIST_PRICE], [OWNER], [OWNER_ID]);
