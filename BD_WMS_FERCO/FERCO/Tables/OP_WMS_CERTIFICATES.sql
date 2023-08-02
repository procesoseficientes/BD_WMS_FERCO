﻿CREATE TABLE [FERCO].[OP_WMS_CERTIFICATES] (
    [CERTIFICATE_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [CREATION_DATE]      DATETIME     NULL,
    [CREATION_BY]        VARCHAR (25) NULL,
    [LAST_UPDATED]       DATETIME     NULL,
    [LAST_UPDATED_BY]    VARCHAR (25) NULL,
    [SUPERVISION_ID]     INT          NULL,
    [3PL_WAREHOUSE]      VARCHAR (25) NULL,
    [CERTIFICATE_STATUS] VARCHAR (20) NULL,
    [VALID_FROM]         DATE         NULL,
    [VALID_TO]           DATE         NULL,
    [CLIENT_CODE]        VARCHAR (25) NULL,
    [HAS_BOND]           INT          NULL,
    CONSTRAINT [PK_OP_WMS_CERTIFICATES] PRIMARY KEY CLUSTERED ([CERTIFICATE_ID] ASC)
);

