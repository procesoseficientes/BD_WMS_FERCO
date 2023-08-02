﻿CREATE TABLE [dbo].[OP_WMS_DOMAINS] (
    [ID]         INT                IDENTITY (1, 1) NOT NULL,
    [DOMAIN]     NVARCHAR (64)      NOT NULL,
    [USER]       NVARCHAR (32)      NOT NULL,
    [PASSWORD]   NVARCHAR (256)     NOT NULL,
    [SERVER]     NVARCHAR (32)      NOT NULL,
    [PORT]       INT                NOT NULL,
    [CREATED_AT] DATETIMEOFFSET (7) NOT NULL,
    [UPDATED_AT] DATETIMEOFFSET (7) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [UN_OP_WMS_DOMAINS_DOMAIN] UNIQUE NONCLUSTERED ([DOMAIN] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);
