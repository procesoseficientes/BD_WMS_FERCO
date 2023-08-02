﻿CREATE TABLE [FERCO].[OP_WMS_MANIFEST_HEADER] (
    [MANIFEST_HEADER_ID]  INT          IDENTITY (1, 1) NOT NULL,
    [DRIVER]              INT          NOT NULL,
    [VEHICLE]             INT          NOT NULL,
    [DISTRIBUTION_CENTER] VARCHAR (50) NOT NULL,
    [CREATED_DATE]        DATETIME     NOT NULL,
    [STATUS]              VARCHAR (50) DEFAULT ('CREATED') NOT NULL,
    [LAST_UPDATE]         DATETIME     NOT NULL,
    [LAST_UPDATE_BY]      VARCHAR (50) NOT NULL,
    [MANIFEST_TYPE]       VARCHAR (50) NULL,
    [TRANSFER_REQUEST_ID] INT          NULL,
    [PLATE_NUMBER]        VARCHAR (10) NULL,
    [SOURCE]              VARCHAR (50) DEFAULT ('MANIFESTO_DE_CARGA') NOT NULL,
    PRIMARY KEY CLUSTERED ([MANIFEST_HEADER_ID] ASC),
    FOREIGN KEY ([DRIVER]) REFERENCES [FERCO].[OP_WMS_PILOT] ([PILOT_CODE]),
    FOREIGN KEY ([VEHICLE]) REFERENCES [FERCO].[OP_WMS_VEHICLE] ([VEHICLE_CODE])
);


GO
CREATE NONCLUSTERED INDEX [IDX_MANIFES_HEADER_ID_STATUS]
    ON [FERCO].[OP_WMS_MANIFEST_HEADER]([MANIFEST_HEADER_ID] ASC)
    INCLUDE([STATUS]);


GO
CREATE NONCLUSTERED INDEX [IDX_MANIFES_HEADER_VEHICLE]
    ON [FERCO].[OP_WMS_MANIFEST_HEADER]([VEHICLE] ASC)
    INCLUDE([CREATED_DATE], [DISTRIBUTION_CENTER], [DRIVER], [LAST_UPDATE], [LAST_UPDATE_BY], [MANIFEST_HEADER_ID], [MANIFEST_TYPE], [PLATE_NUMBER], [STATUS], [TRANSFER_REQUEST_ID]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_MANIFEST_HEADER_MANIFEST_HEADER_ID_TRANSFER_REQUEST_ID]
    ON [FERCO].[OP_WMS_MANIFEST_HEADER]([MANIFEST_HEADER_ID] ASC, [TRANSFER_REQUEST_ID] ASC)
    INCLUDE([CREATED_DATE], [DRIVER], [VEHICLE]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_MANIFEST_HEADER_TRANSFER_REQUEST_ID_MANIFEST_HEADER_ID]
    ON [FERCO].[OP_WMS_MANIFEST_HEADER]([TRANSFER_REQUEST_ID] ASC, [MANIFEST_HEADER_ID] ASC)
    INCLUDE([CREATED_DATE], [DRIVER], [VEHICLE]);

