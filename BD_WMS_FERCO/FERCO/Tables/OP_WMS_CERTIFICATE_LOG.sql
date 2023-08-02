﻿CREATE TABLE [FERCO].[OP_WMS_CERTIFICATE_LOG] (
    [CERTIFICATE_LOG] INT           IDENTITY (1, 1) NOT NULL,
    [CERTIFICATE_ID]  INT           NULL,
    [UPDATED]         DATETIME      NULL,
    [UPDATED_BY]      VARCHAR (20)  NULL,
    [OLD_VALIN_FROM]  DATE          NULL,
    [OLD_VALIN_TO]    DATE          NULL,
    [NEW_VALID_FROM]  DATE          NULL,
    [NEW_VALID_TO]    DATE          NULL,
    [COMMENT]         VARCHAR (250) NULL,
    [AUTHORIZED_BY]   VARCHAR (25)  NULL,
    CONSTRAINT [PK_OP_WMS_CERTIFICATE_LOG] PRIMARY KEY CLUSTERED ([CERTIFICATE_LOG] ASC)
);

