CREATE TABLE [ferco].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] (
    [Sequence]                 INT             NOT NULL,
    [DocDate]                  DATETIME        NULL,
    [DocNum]                   INT             NOT NULL,
    [U_Serie]                  VARCHAR (50)    NULL,
    [U_NoDocto]                VARCHAR (50)    NULL,
    [CardCode]                 VARCHAR (50)    NULL,
    [CardName]                 VARCHAR (200)   NULL,
    [U_MasterIDCustomer]       VARCHAR (50)    NULL,
    [U_OwnerCustomer]          VARCHAR (50)    NULL,
    [SlpName]                  VARCHAR (100)   NULL,
    [U_oper]                   VARCHAR (40)    NULL,
    [DESCUENTO_FACTURA]        NUMERIC (18, 6) NULL,
    [STATUS]                   VARCHAR (25)    NULL,
    [Comments]                 VARCHAR (300)   NULL,
    [DiscPrcnt]                NUMERIC (18)    NULL,
    [Address]                  VARCHAR (MAX)   NULL,
    [Address2]                 VARCHAR (300)   NULL,
    [ShipToAddressType]        VARCHAR (300)   NULL,
    [ShipToStreet]             VARCHAR (300)   NULL,
    [ShipToState]              VARCHAR (15)    NULL,
    [ShipToCountry]            VARCHAR (15)    NULL,
    [DocEntry]                 INT             NULL,
    [SlpCode]                  INT             NULL,
    [DocCur]                   VARCHAR (15)    NULL,
    [DocRate]                  NUMERIC (18)    NULL,
    [DocDueDate]               DATETIME        NULL,
    [Owner]                    VARCHAR (50)    NOT NULL,
    [OwnerSlp]                 VARCHAR (50)    NULL,
    [MasterIdSlp]              VARCHAR (50)    NULL,
    [WhsCode]                  VARCHAR (50)    NULL,
    [DocStatus]                VARCHAR (10)    NULL,
    [DocTotal]                 NUMERIC (18, 6) NULL,
    [TYPE_DEMAND_CODE]         INT             NULL,
    [TYPE_DEMAND_NAME]         VARCHAR (50)    NULL,
    [PROJECT]                  VARCHAR (50)    NULL,
    [MIN_DAYS_EXPIRATION_DATE] INT             DEFAULT ((0)) NOT NULL,
    [U_estado2]                VARCHAR (50)    NULL,
    [Descr]                    VARCHAR (100)   NULL,
    [U_Sucursal]               VARCHAR (50)    NULL,
    CONSTRAINT [PK_ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] PRIMARY KEY CLUSTERED ([Sequence] ASC, [DocNum] ASC, [Owner] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IN_ERP_SALES_ORDER_HEADER_CHANNEL_MODERN_SEQUENCE_MASTERIDCUSTOMER]
    ON [ferco].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]([Sequence] ASC, [U_MasterIDCustomer] ASC)
    INCLUDE([DocDate], [DocNum], [U_Serie], [CardName], [U_OwnerCustomer], [SlpName], [U_oper], [DESCUENTO_FACTURA], [DocEntry], [Owner], [OwnerSlp], [MasterIdSlp]);

