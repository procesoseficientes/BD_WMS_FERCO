﻿CREATE TABLE [FERCO].[OP_WMS_MANIFEST_DETAIL] (
    [MANIFEST_DETAIL_ID]       INT             IDENTITY (1, 1) NOT NULL,
    [MANIFEST_HEADER_ID]       INT             NULL,
    [CODE_ROUTE]               VARCHAR (50)    NULL,
    [CLIENT_CODE]              VARCHAR (50)    NULL,
    [WAVE_PICKING_ID]          INT             NULL,
    [MATERIAL_ID]              VARCHAR (50)    NOT NULL,
    [QTY]                      DECIMAL (18, 4) NULL,
    [STATUS]                   VARCHAR (50)    DEFAULT ('ON_WAREHOUSE') NOT NULL,
    [LAST_UPDATE]              DATETIME        NOT NULL,
    [LAST_UPDATE_BY]           VARCHAR (50)    NOT NULL,
    [ADDRESS_CUSTOMER]         VARCHAR (500)   NULL,
    [CLIENT_NAME]              VARCHAR (150)   NULL,
    [LINE_NUM]                 INT             NULL,
    [PICKING_DEMAND_HEADER_ID] INT             NULL,
    [STATE_CODE]               INT             NULL,
    [CERTIFICATION_TYPE]       VARCHAR (20)    NULL,
    [TYPE_DEMAND_CODE]         INT             NULL,
    [TYPE_DEMAND_NAME]         VARCHAR (50)    NULL,
    [PRICE]                    NUMERIC (18, 6) CONSTRAINT [DF__OP_WMS_MA__PRICE__6849492E] DEFAULT ((0)) NOT NULL,
    [LINE_DISCOUNT]            NUMERIC (18, 6) CONSTRAINT [DF__OP_WMS_MA__LINE___693D6D67] DEFAULT ((0)) NOT NULL,
    [LINE_TOTAL]               NUMERIC (18, 6) CONSTRAINT [DF__OP_WMS_MA__LINE___6A3191A0] DEFAULT ((0)) NOT NULL,
    [HEADER_DISCOUNT]          NUMERIC (18, 6) CONSTRAINT [DF__OP_WMS_MA__HEADE__6B25B5D9] DEFAULT ((0)) NOT NULL,
    [QTY_PENDING_DELIVERY]     DECIMAL (18, 4) NULL,
    [QTY_DELIVERED]            DECIMAL (18, 4) NULL,
    [VOLUME_FACTOR_X_UNIT]     DECIMAL (18, 4) NULL,
    [VOLUME_FACTOR_X_LINE]     DECIMAL (18, 4) NULL,
    [WEIGHT_MEASUREMENT]       VARCHAR (50)    NULL,
    [WEIGHT_X_UNIT]            DECIMAL (18, 6) NULL,
    [WEIGHT_X_LINE]            DECIMAL (18, 6) NULL,
    [COST_BY_MATERIAL]         NUMERIC (18, 6) DEFAULT ((0.00)) NULL,
    PRIMARY KEY CLUSTERED ([MANIFEST_DETAIL_ID] ASC),
    CONSTRAINT [FK_MANIFEST_HEADER_ID] FOREIGN KEY ([MANIFEST_HEADER_ID]) REFERENCES [FERCO].[OP_WMS_MANIFEST_HEADER] ([MANIFEST_HEADER_ID])
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_MANIFEST_DETAIL]
    ON [FERCO].[OP_WMS_MANIFEST_DETAIL]([MANIFEST_HEADER_ID] ASC)
    INCLUDE([MANIFEST_DETAIL_ID], [QTY]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_MANIFEST_DETAIL_PICKING_DEMAND_HEADER_ID]
    ON [FERCO].[OP_WMS_MANIFEST_DETAIL]([PICKING_DEMAND_HEADER_ID] ASC)
    INCLUDE([MANIFEST_HEADER_ID]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_MANIFEST_DETAIL_MANIFEST_HEADER_ID]
    ON [FERCO].[OP_WMS_MANIFEST_DETAIL]([MANIFEST_HEADER_ID] ASC)
    INCLUDE([WAVE_PICKING_ID]);


GO
CREATE NONCLUSTERED INDEX [IDX_MANIFEST_DETAIL]
    ON [FERCO].[OP_WMS_MANIFEST_DETAIL]([CODE_ROUTE] ASC, [MANIFEST_HEADER_ID] ASC, [CLIENT_CODE] ASC, [WAVE_PICKING_ID] ASC, [MATERIAL_ID] ASC, [QTY] ASC, [STATUS] ASC, [LAST_UPDATE] ASC, [LAST_UPDATE_BY] ASC, [ADDRESS_CUSTOMER] ASC, [CLIENT_NAME] ASC, [LINE_NUM] ASC, [PICKING_DEMAND_HEADER_ID] ASC, [STATE_CODE] ASC, [CERTIFICATION_TYPE] ASC)
    INCLUDE([MANIFEST_DETAIL_ID]);


GO
CREATE NONCLUSTERED INDEX [IDX_MANIFEST_DETAIL_CLIENT_CODE_CLIENT_NAME_ADDRESS]
    ON [FERCO].[OP_WMS_MANIFEST_DETAIL]([MANIFEST_HEADER_ID] ASC)
    INCLUDE([CLIENT_CODE], [CLIENT_NAME], [ADDRESS_CUSTOMER]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_MANIFEST_DETAIL_PICKING_DEMAND_HEADER_ID_MANIFEST_HEADER_ID]
    ON [FERCO].[OP_WMS_MANIFEST_DETAIL]([PICKING_DEMAND_HEADER_ID] ASC, [MANIFEST_HEADER_ID] ASC)
    INCLUDE([MANIFEST_DETAIL_ID]);

