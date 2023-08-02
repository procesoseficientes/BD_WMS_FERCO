﻿CREATE TABLE [FERCO].[OP_WMS_WAREHOUSE_BY_USER] (
    [WAREHOUSE_BY_USER_ID] INT          IDENTITY (1, 1) NOT NULL,
    [LOGIN_ID]             VARCHAR (25) NOT NULL,
    [WAREHOUSE_ID]         VARCHAR (25) NOT NULL,
    PRIMARY KEY CLUSTERED ([WAREHOUSE_BY_USER_ID] ASC),
    CONSTRAINT [FK_WAREHOUSE_BY_USER_USER] FOREIGN KEY ([LOGIN_ID]) REFERENCES [FERCO].[OP_WMS_LOGINS] ([LOGIN_ID]),
    CONSTRAINT [FK_WAREHOUSE_BY_USER_WAREHOUSE] FOREIGN KEY ([WAREHOUSE_ID]) REFERENCES [FERCO].[OP_WMS_WAREHOUSES] ([WAREHOUSE_ID]),
    CONSTRAINT [U_WAREHOUSE_BY_USER] UNIQUE NONCLUSTERED ([LOGIN_ID] ASC, [WAREHOUSE_ID] ASC)
);

