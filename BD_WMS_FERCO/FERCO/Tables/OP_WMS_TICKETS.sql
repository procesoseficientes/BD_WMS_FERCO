﻿CREATE TABLE [FERCO].[OP_WMS_TICKETS] (
    [TICKET_NUMBER] BIGINT       IDENTITY (1, 1) NOT NULL,
    [POLIZA_DOC_ID] NUMERIC (18) NULL,
    [CREATED_DATE]  DATETIME     NULL,
    [STATUS]        VARCHAR (20) NULL,
    CONSTRAINT [PK_TICKET_ID] PRIMARY KEY CLUSTERED ([TICKET_NUMBER] ASC)
);

