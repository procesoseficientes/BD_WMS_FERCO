﻿CREATE TABLE [ferco].[SWIFT_ERP_PROVIDERS] (
    [PROVIDER]                NVARCHAR (15)  NOT NULL,
    [CODE_PROVIDER]           NVARCHAR (15)  NOT NULL,
    [NAME_PROVIDER]           NVARCHAR (100) NULL,
    [CLASSIFICATION_PROVIDER] VARCHAR (30)   NULL,
    [CONTACT_PROVIDER]        NVARCHAR (90)  NULL,
    [FROM_ERP]                INT            NOT NULL,
    [NAME_CLASSIFICATION]     VARCHAR (30)   NULL,
    PRIMARY KEY CLUSTERED ([CODE_PROVIDER] ASC)
);

