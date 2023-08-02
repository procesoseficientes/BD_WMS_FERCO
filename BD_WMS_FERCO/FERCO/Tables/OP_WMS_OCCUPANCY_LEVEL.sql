﻿CREATE TABLE [FERCO].[OP_WMS_OCCUPANCY_LEVEL] (
    [INPUT_DATE]       DATE            NOT NULL,
    [LOCATION_SPOT]    VARCHAR (25)    NOT NULL,
    [WAREHOUSE_PARENT] VARCHAR (25)    NULL,
    [SPOT_TYPE]        VARCHAR (25)    NULL,
    [OCCUPANCY_LEVEL]  NUMERIC (18, 2) NULL,
    [LAST_UPDATED]     DATETIME        NULL,
    [LAST_UPDATED_BY]  VARCHAR (25)    NULL,
    CONSTRAINT [PK_OP_WMS_OCCUPANCY_LEVEL] PRIMARY KEY CLUSTERED ([INPUT_DATE] ASC, [LOCATION_SPOT] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_OCCUPANCY_LEVEL]
    ON [FERCO].[OP_WMS_OCCUPANCY_LEVEL]([INPUT_DATE] ASC);
