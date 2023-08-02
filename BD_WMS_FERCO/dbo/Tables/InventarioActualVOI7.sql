CREATE TABLE [dbo].[InventarioActualVOI7] (
    [LOCATION]            VARCHAR (50)  NULL,
    [COD_PRODUCT]         VARCHAR (50)  NULL,
    [LOTNUMBER]           INT           NULL,
    [STATUS]              INT           NULL,
    [QUANTITY]            INT           NULL,
    [DATETIME_ARRIVAL]    DATETIME2 (7) NULL,
    [DATETIME_DUE]        VARCHAR (255) NULL,
    [DATETIME_LAST_TRANS] DATETIME2 (7) NULL,
    [COD_COMPANY]         INT           NULL,
    [UNIT]                VARCHAR (50)  NULL,
    [CONVERSION]          INT           NULL
);

