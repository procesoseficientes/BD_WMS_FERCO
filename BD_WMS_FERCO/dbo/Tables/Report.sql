﻿CREATE TABLE [dbo].[Report] (
    [ID_REPORT]          INT           IDENTITY (1, 1) NOT NULL,
    [NAME_REPORT]        VARCHAR (250) NOT NULL,
    [DESCRIPTION_REPORT] VARCHAR (250) NULL,
    [REPORT]             VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED ([ID_REPORT] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

