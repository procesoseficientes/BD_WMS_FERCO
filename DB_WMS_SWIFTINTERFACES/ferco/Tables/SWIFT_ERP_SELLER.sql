﻿CREATE TABLE [ferco].[SWIFT_ERP_SELLER] (
    [SELLER_CODE] VARCHAR (250) NOT NULL,
    [SELLER_NAME] VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_SWIFT_ERP_SELLER] PRIMARY KEY CLUSTERED ([SELLER_CODE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_ERP_SELLER_SELLER_CODE]
    ON [ferco].[SWIFT_ERP_SELLER]([SELLER_CODE] ASC)
    INCLUDE([SELLER_NAME]);

