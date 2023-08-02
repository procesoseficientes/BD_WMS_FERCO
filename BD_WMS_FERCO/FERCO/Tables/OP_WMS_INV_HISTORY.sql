﻿CREATE TABLE [FERCO].[OP_WMS_INV_HISTORY] (
    [REGIMEN]          VARCHAR (25)    NULL,
    [CLIENT_NAME]      VARCHAR (250)   NULL,
    [CLIENT_OWNER]     VARCHAR (50)    NULL,
    [NUMERO_ORDEN]     VARCHAR (50)    NULL,
    [LICENSE_ID]       NUMERIC (18)    NULL,
    [BARCODE_ID]       NVARCHAR (50)   NULL,
    [MATERIAL_ID]      VARCHAR (50)    NULL,
    [MATERIAL_NAME]    VARCHAR (250)   NULL,
    [QTY]              NUMERIC (18, 4) NULL,
    [CURRENT_LOCATION] NVARCHAR (50)   NULL,
    [BODEGA]           NVARCHAR (50)   NULL,
    [VALOR_UNITARIO]   DECIMAL (18, 4) NULL,
    [TOTAL_VALOR]      DECIMAL (18, 4) NULL,
    [VOLUMEN]          DECIMAL (18, 4) NULL,
    [TOTAL_VOLUMEN]    DECIMAL (18, 4) NULL,
    [TERMS_OF_TRADE]   NVARCHAR (50)   NULL,
    [SNAPSHOT_DATE]    DATETIME        NULL,
    [PROCESSED_BY_ERP] DATETIME        NULL,
    [ERP_REFERENCE]    INT             NULL,
    [BATCH]            VARCHAR (50)    NULL,
    [DATE_EXPIRATION]  DATE            NULL,
    [VIN]              VARCHAR (40)    NULL
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_INV_HISTORY_SNAPSHOT_DATE]
    ON [FERCO].[OP_WMS_INV_HISTORY]([CURRENT_LOCATION] ASC, [SNAPSHOT_DATE] ASC)
    INCLUDE([MATERIAL_ID], [QTY]);
