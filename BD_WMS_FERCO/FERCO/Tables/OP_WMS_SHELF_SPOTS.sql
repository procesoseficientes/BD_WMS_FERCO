﻿CREATE TABLE [FERCO].[OP_WMS_SHELF_SPOTS] (
    [WAREHOUSE_PARENT]    VARCHAR (25)    NOT NULL,
    [ZONE]                VARCHAR (25)    NOT NULL,
    [LOCATION_SPOT]       VARCHAR (25)    NOT NULL,
    [SPOT_TYPE]           VARCHAR (25)    NOT NULL,
    [SPOT_ORDERBY]        DECIMAL (18)    NOT NULL,
    [SPOT_AISLE]          DECIMAL (18)    NOT NULL,
    [SPOT_COLUMN]         VARCHAR (25)    NOT NULL,
    [SPOT_LEVEL]          VARCHAR (25)    NOT NULL,
    [SPOT_PARTITION]      VARCHAR (50)    NOT NULL,
    [SPOT_LABEL]          VARCHAR (25)    NULL,
    [ALLOW_PICKING]       INT             NULL,
    [ALLOW_STORAGE]       INT             NOT NULL,
    [ALLOW_REALLOC]       INT             NULL,
    [AVAILABLE]           INT             NULL,
    [LINE_ID]             VARCHAR (16)    NULL,
    [SPOT_LINE]           VARCHAR (15)    NULL,
    [LOCATION_OVERLOADED] INT             NULL,
    [MAX_MT2_OCCUPANCY]   INT             NULL,
    [MAX_WEIGHT]          DECIMAL (18, 2) NULL,
    [SECTION]             VARCHAR (50)    NULL,
    [VOLUME]              NUMERIC (18, 4) DEFAULT ((0)) NOT NULL,
    [IS_WASTE]            INT             DEFAULT ((0)) NOT NULL,
    [ALLOW_FAST_PICKING]  INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_OP_WMS_SHELF_SPOTS] PRIMARY KEY CLUSTERED ([LOCATION_SPOT] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_SHELF_SPOTS_LOCATION_SPOT]
    ON [FERCO].[OP_WMS_SHELF_SPOTS]([LOCATION_SPOT] ASC)
    INCLUDE([ZONE]);


GO
CREATE NONCLUSTERED INDEX [IDX_OP_WMS_SHELF_SPOTS_ALLOW_PICKING]
    ON [FERCO].[OP_WMS_SHELF_SPOTS]([ALLOW_PICKING] ASC)
    INCLUDE([LOCATION_SPOT]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_SHELF_SPOTS_LINE_ID]
    ON [FERCO].[OP_WMS_SHELF_SPOTS]([LINE_ID] ASC)
    INCLUDE([LOCATION_SPOT]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_SHELF_SPOTS_LOCATION_SPOT_ALLOW_PICKING]
    ON [FERCO].[OP_WMS_SHELF_SPOTS]([LOCATION_SPOT] ASC, [ALLOW_PICKING] ASC)
    INCLUDE([ZONE]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_SHELF_SPOTS_WAREHOUSE_PARENT]
    ON [FERCO].[OP_WMS_SHELF_SPOTS]([WAREHOUSE_PARENT] ASC)
    INCLUDE([LINE_ID]);
