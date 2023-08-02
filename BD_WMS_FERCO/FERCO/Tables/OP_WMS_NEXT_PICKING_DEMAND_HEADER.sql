﻿CREATE TABLE [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] (
    [PICKING_DEMAND_HEADER_ID]             INT              IDENTITY (1, 1) NOT NULL,
    [DOC_NUM]                              VARCHAR (50)     NULL,
    [CLIENT_CODE]                          VARCHAR (50)     NOT NULL,
    [CODE_ROUTE]                           VARCHAR (50)     NULL,
    [CODE_SELLER]                          VARCHAR (50)     NULL,
    [TOTAL_AMOUNT]                         DECIMAL (18, 6)  NULL,
    [SERIAL_NUMBER]                        VARCHAR (100)    NULL,
    [DOC_NUM_SEQUENCE]                     VARCHAR (50)     NULL,
    [EXTERNAL_SOURCE_ID]                   INT              NOT NULL,
    [IS_FROM_ERP]                          INT              NOT NULL,
    [IS_FROM_SONDA]                        INT              NOT NULL,
    [LAST_UPDATE]                          DATETIME         NOT NULL,
    [LAST_UPDATE_BY]                       VARCHAR (50)     NOT NULL,
    [IS_COMPLETED]                         INT              DEFAULT ((0)) NOT NULL,
    [WAVE_PICKING_ID]                      INT              NOT NULL,
    [CODE_WAREHOUSE]                       VARCHAR (25)     NOT NULL,
    [IS_AUTHORIZED]                        INT              DEFAULT ((0)) NOT NULL,
    [ATTEMPTED_WITH_ERROR]                 INT              DEFAULT ((0)) NOT NULL,
    [IS_POSTED_ERP]                        INT              DEFAULT ((0)) NOT NULL,
    [POSTED_ERP]                           DATETIME         NULL,
    [POSTED_RESPONSE]                      VARCHAR (500)    NULL,
    [ERP_REFERENCE]                        VARCHAR (50)     NULL,
    [CLIENT_NAME]                          VARCHAR (100)    NULL,
    [CREATED_DATE]                         DATETIME         NULL,
    [ERP_REFERENCE_DOC_NUM]                VARCHAR (200)    NULL,
    [DOC_ENTRY]                            VARCHAR (50)     NULL,
    [IS_CONSOLIDATED]                      INT              CONSTRAINT [D_PICKING_DEMAND_IS_CONSOLIDATED] DEFAULT ((0)) NOT NULL,
    [PRIORITY]                             INT              NULL,
    [HAS_MASTERPACK]                       INT              DEFAULT ((0)) NOT NULL,
    [POSTED_STATUS]                        INT              DEFAULT ((0)) NOT NULL,
    [OWNER]                                VARCHAR (50)     NULL,
    [CLIENT_OWNER]                         VARCHAR (50)     NULL,
    [MASTER_ID_SELLER]                     VARCHAR (50)     NULL,
    [SELLER_OWNER]                         VARCHAR (50)     NULL,
    [SOURCE_TYPE]                          VARCHAR (50)     NULL,
    [INNER_SALE_STATUS]                    VARCHAR (50)     NULL,
    [INNER_SALE_RESPONSE]                  VARCHAR (1000)   NULL,
    [DEMAND_TYPE]                          VARCHAR (50)     NULL,
    [TRANSFER_REQUEST_ID]                  INT              NULL,
    [ADDRESS_CUSTOMER]                     VARCHAR (500)    NULL,
    [STATE_CODE]                           INT              NULL,
    [DISCOUNT]                             DECIMAL (18, 6)  DEFAULT ((0)) NOT NULL,
    [UPDATED_VEHICLE]                      INT              DEFAULT ((0)) NOT NULL,
    [UPDATED_VEHICLE_RESPONSE]             VARCHAR (500)    NULL,
    [UPDATED_VEHICLE_ATTEMPTED_WITH_ERROR] INT              DEFAULT ((0)) NOT NULL,
    [DELIVERY_NOTE_INVOICE]                VARCHAR (50)     NULL,
    [DEMAND_SEQUENCE]                      INT              NULL,
    [IS_CANCELED_FROM_SONDA_SD]            INT              DEFAULT ((0)) NOT NULL,
    [TYPE_DEMAND_CODE]                     INT              NULL,
    [TYPE_DEMAND_NAME]                     VARCHAR (50)     NULL,
    [IS_FOR_DELIVERY_IMMEDIATE]            INT              DEFAULT ((1)) NOT NULL,
    [DEMAND_DELIVERY_DATE]                 DATETIME         NULL,
    [IS_SENDING]                           INT              DEFAULT ((0)) NULL,
    [LAST_UPDATE_IS_SENDING]               DATETIME         NULL,
    [PROJECT]                              VARCHAR (50)     NULL,
    [DISPATCH_LICENSE_EXIT_DATETIME]       DATETIME         NULL,
    [DISPATCH_LICENSE_EXIT_BY]             VARCHAR (25)     NULL,
    [COMMENT_REFERENCE]                    VARCHAR (300)    NULL,
    [PROJECT_ID]                           UNIQUEIDENTIFIER NULL,
    [PROJECT_CODE]                         VARCHAR (50)     NULL,
    [PROJECT_NAME]                         VARCHAR (150)    NULL,
    [PROJECT_SHORT_NAME]                   VARCHAR (25)     NULL,
    [MIN_DAYS_EXPIRATION_DATE]             INT              NULL,
    [BASE_REF]                             VARCHAR (50)     NULL,
    [BASE_ENTRY]                           VARCHAR (50)     NULL,
    [SERIES]                               INT              NULL,
    PRIMARY KEY CLUSTERED ([PICKING_DEMAND_HEADER_ID] ASC),
    CONSTRAINT [CHK_IS_FOR_DELIVERY_IMMEDIATE] CHECK ([IS_FOR_DELIVERY_IMMEDIATE]=(0) OR [IS_FOR_DELIVERY_IMMEDIATE]=(1)),
    CONSTRAINT [OP_WMS_NEXT_PICKING_DEMAND_HEADER_POSTED_STATUS_RANGE_VALUE] CHECK ([POSTED_STATUS]>=(-4) AND [POSTED_STATUS]<=(4)),
    CONSTRAINT [FK_NEXT_PICKING_DEMAND_HEADER_WAREHOUSE] FOREIGN KEY ([CODE_WAREHOUSE]) REFERENCES [FERCO].[OP_WMS_WAREHOUSES] ([WAREHOUSE_ID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_PICKING_DEMAND_HEADER_IS_FOR_DELIVERY_IMMEDIATE]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([WAVE_PICKING_ID] ASC)
    INCLUDE([IS_FOR_DELIVERY_IMMEDIATE]);


GO
CREATE NONCLUSTERED INDEX [IDX_PICKING_DEMAND_HEADER_IS_POSTED_ERP]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([WAVE_PICKING_ID] ASC)
    INCLUDE([ATTEMPTED_WITH_ERROR], [IS_AUTHORIZED], [IS_POSTED_ERP], [LAST_UPDATE], [LAST_UPDATE_BY], [PICKING_DEMAND_HEADER_ID], [POSTED_STATUS]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_NEXT_PICKING_DEMAND_HEADER_DOC_NUM_HEADER_ID]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([DOC_NUM] ASC, [PICKING_DEMAND_HEADER_ID] ASC, [EXTERNAL_SOURCE_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_NEXT_PICKING_DEMAND_HEADER_DOC_ENTRY_EXTERNAL_SOURCE_ID_IS_COMPLETED]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([DOC_ENTRY] ASC, [IS_COMPLETED] ASC, [EXTERNAL_SOURCE_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_NEXT_PICKING_DEMAND_HEADER_DOC_NUM_EXTERNAL_SOURCE_ID_FROM_ERP]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([DOC_NUM] ASC, [IS_FROM_ERP] ASC, [EXTERNAL_SOURCE_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_NEXT_PICKING_DEMAND_HEADER_DOC_NUM_EXTERNAL_SOURCE_ID]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([DOC_NUM] ASC, [EXTERNAL_SOURCE_ID] ASC)
    INCLUDE([IS_COMPLETED]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_NEXT_PICKING_DEMAND_HEADER_DEMAND_TYPE_CODE_ROUTE_PICKING_DEMAND_HEADER_ID]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([DEMAND_TYPE] ASC, [CODE_ROUTE] ASC)
    INCLUDE([CLIENT_CODE], [CLIENT_NAME], [WAVE_PICKING_ID]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_NEXT_PICKING_DEMAND_HEADER_WAVE_PICKING_ID_TRANSFER_REQUEST_ID]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([WAVE_PICKING_ID] ASC, [TRANSFER_REQUEST_ID] ASC)
    INCLUDE([CREATED_DATE], [STATE_CODE]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_NEXT_PICKING_DEMAND_HEADER_TRANSFER_REQUEST_ID]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([TRANSFER_REQUEST_ID] ASC)
    INCLUDE([CREATED_DATE], [WAVE_PICKING_ID]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_NEXT_PICKING_DEMAND_HEADER_DOC_NUM]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([DOC_NUM] ASC)
    INCLUDE([IS_FROM_SONDA], [SOURCE_TYPE]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_NEXT_PICKING_DEMAND_HEADER_WAVE_PICKING_ID]
    ON [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]([WAVE_PICKING_ID] ASC)
    INCLUDE([CLIENT_CODE], [CLIENT_NAME], [CODE_ROUTE]);
