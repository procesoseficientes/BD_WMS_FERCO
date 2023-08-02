﻿CREATE TABLE [FERCO].[OP_WMS_TERMINALS] (
    [TERMINAL_IP] VARCHAR (50) NOT NULL,
    [LOGIN_ID]    VARCHAR (25) NOT NULL,
    [LAST_LOGON]  DATETIME     NULL,
    CONSTRAINT [PK_OP_WMS_TERMINALS] PRIMARY KEY CLUSTERED ([TERMINAL_IP] ASC)
);

