﻿CREATE TABLE [FERCO].[OP_WMS_SELLER_INTERCOMPANY] (
    [MASTER_ID] VARCHAR (50) NOT NULL,
    [SLP_CODE]  VARCHAR (50) NOT NULL,
    [SOURCE]    VARCHAR (50) NOT NULL,
    [SERIE]     INT          DEFAULT ((-1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([MASTER_ID] ASC, [SLP_CODE] ASC, [SOURCE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_SELLER_INTERCOMPANY_SOURCE_MASTER_ID]
    ON [FERCO].[OP_WMS_SELLER_INTERCOMPANY]([SOURCE] ASC, [MASTER_ID] ASC)
    INCLUDE([SLP_CODE]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_SELLER_INTERCOMPANY_SOURCE_SLP_CODE]
    ON [FERCO].[OP_WMS_SELLER_INTERCOMPANY]([SLP_CODE] ASC, [SOURCE] ASC)
    INCLUDE([MASTER_ID], [SERIE]);

