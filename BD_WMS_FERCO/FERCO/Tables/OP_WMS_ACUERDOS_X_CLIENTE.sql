﻿CREATE TABLE [FERCO].[OP_WMS_ACUERDOS_X_CLIENTE] (
    [CLIENT_ID]         VARCHAR (20) NOT NULL,
    [ACUERDO_COMERCIAL] INT          NOT NULL,
    CONSTRAINT [PK_OP_WMS_ACUERDOS_X_CLIENTE] PRIMARY KEY CLUSTERED ([CLIENT_ID] ASC, [ACUERDO_COMERCIAL] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_ACUERDOS_X_CLIENTE_ACUERDO_COMERCIAL]
    ON [FERCO].[OP_WMS_ACUERDOS_X_CLIENTE]([ACUERDO_COMERCIAL] ASC)
    INCLUDE([CLIENT_ID]);

