﻿CREATE TABLE [FERCO].[OP_WMS3PL_AUDITS_X_PASS] (
    [PASS_ID]         NUMERIC (18) NOT NULL,
    [AUDIT_ID]        NUMERIC (18) NOT NULL,
    [LAST_UPDATED_BY] VARCHAR (25) NULL,
    [LAST_UPDATED]    DATETIME     NULL,
    CONSTRAINT [PK_OP_WMS3PL_AUDITS_X_PASS] PRIMARY KEY CLUSTERED ([PASS_ID] ASC, [AUDIT_ID] ASC)
);

