﻿CREATE TABLE [ferco].[SWIFT_ERP_ORDER_DETAIL] (
    [DOC_ENTRY] INT           NOT NULL,
    [ITEM_CODE] NVARCHAR (20) NULL,
    [OBJ_TYPE]  NVARCHAR (20) NULL,
    [LINE_NUM]  INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([DOC_ENTRY] ASC, [LINE_NUM] ASC)
);

