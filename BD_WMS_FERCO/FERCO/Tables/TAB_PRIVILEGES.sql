﻿CREATE TABLE [FERCO].[TAB_PRIVILEGES] (
    [PRIVILEGE_ID]          NCHAR (10) NOT NULL,
    [PRIVILEGE_NAME]        NCHAR (10) NULL,
    [PRIVILEGE_DESCRIPTION] NCHAR (10) NULL,
    CONSTRAINT [PK_TAB_PRIVILEGES] PRIMARY KEY CLUSTERED ([PRIVILEGE_ID] ASC)
);

