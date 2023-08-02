﻿CREATE TABLE [FERCO].[OP_WMS_TERMS_OF_TRADE] (
    [CLIENT_CODE]       VARCHAR (25)  NOT NULL,
    [ACUERDO_COMERCIAL] VARCHAR (15)  NOT NULL,
    [DESCRIPCION]       VARCHAR (250) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_TERMS_OF_TRADE]
    ON [FERCO].[OP_WMS_TERMS_OF_TRADE]([CLIENT_CODE] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_TERMS_OF_TRADE_1]
    ON [FERCO].[OP_WMS_TERMS_OF_TRADE]([CLIENT_CODE] ASC, [ACUERDO_COMERCIAL] ASC);

