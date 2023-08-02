﻿CREATE TABLE [FERCO].[OP_WMS_TRANS] (
    [SERIAL_NUMBER]                              NUMERIC (18)     IDENTITY (1, 1) NOT NULL,
    [TERMS_OF_TRADE]                             VARCHAR (50)     NULL,
    [TRANS_DATE]                                 DATETIME         NOT NULL,
    [LOGIN_ID]                                   VARCHAR (25)     NOT NULL,
    [LOGIN_NAME]                                 VARCHAR (50)     NULL,
    [TRANS_TYPE]                                 VARCHAR (25)     NOT NULL,
    [TRANS_DESCRIPTION]                          VARCHAR (50)     NOT NULL,
    [TRANS_EXTRA_COMMENTS]                       VARCHAR (250)    NULL,
    [MATERIAL_BARCODE]                           VARCHAR (25)     NOT NULL,
    [MATERIAL_CODE]                              VARCHAR (50)     NOT NULL,
    [MATERIAL_DESCRIPTION]                       VARCHAR (200)    NULL,
    [MATERIAL_TYPE]                              VARCHAR (25)     NULL,
    [MATERIAL_COST]                              NUMERIC (18)     NULL,
    [SOURCE_LICENSE]                             NUMERIC (18)     NULL,
    [TARGET_LICENSE]                             NUMERIC (18)     NULL,
    [SOURCE_LOCATION]                            VARCHAR (25)     NULL,
    [TARGET_LOCATION]                            VARCHAR (25)     NOT NULL,
    [CLIENT_OWNER]                               VARCHAR (25)     NULL,
    [CLIENT_NAME]                                VARCHAR (150)    NULL,
    [QUANTITY_UNITS]                             NUMERIC (18, 4)  NOT NULL,
    [SOURCE_WAREHOUSE]                           VARCHAR (25)     NULL,
    [TARGET_WAREHOUSE]                           VARCHAR (25)     NULL,
    [TRANS_SUBTYPE]                              VARCHAR (25)     NULL,
    [CODIGO_POLIZA]                              VARCHAR (25)     NULL,
    [LICENSE_ID]                                 NUMERIC (18)     NULL,
    [STATUS]                                     VARCHAR (15)     CONSTRAINT [DF_OP_WMS_TRANS_STATUS] DEFAULT ('PROCESSED') NULL,
    [WAVE_PICKING_ID]                            NUMERIC (18)     NULL,
    [DAYS_IDLE]                                  NUMERIC (18)     NULL,
    [POSTED_TO_ERP_STAMP]                        DATETIME         NULL,
    [RELATED_SERVICES]                           VARCHAR (100)    NULL,
    [MESSAGE_FROM_ERP]                           VARCHAR (200)    NULL,
    [TRANS_WEIGTH]                               NUMERIC (18, 2)  NULL,
    [INVOICE_REFERENCE]                          VARCHAR (30)     NULL,
    [TRANS_MT2]                                  NUMERIC (18, 2)  NULL,
    [VIN]                                        VARCHAR (40)     NULL,
    [TASK_ID]                                    NUMERIC (18)     NULL,
    [IS_FROM_SONDA]                              INT              CONSTRAINT [DF__tmp_ms_xx__IS_FR__60683044] DEFAULT ((0)) NULL,
    [SERIAL]                                     VARCHAR (50)     NULL,
    [BATCH]                                      VARCHAR (50)     NULL,
    [DATE_EXPIRATION]                            DATE             NULL,
    [CODE_SUPPLIER]                              VARCHAR (25)     NULL,
    [NAME_SUPPLIER]                              VARCHAR (100)    NULL,
    [SOURCE_TYPE]                                VARCHAR (50)     NULL,
    [TRANSFER_REQUEST_ID]                        INT              NULL,
    [TONE]                                       VARCHAR (20)     CONSTRAINT [DF__tmp_ms_xx___TONE__615C547D] DEFAULT (NULL) NULL,
    [CALIBER]                                    VARCHAR (20)     CONSTRAINT [DF__tmp_ms_xx__CALIB__625078B6] DEFAULT (NULL) NULL,
    [ORIGINAL_LICENSE]                           INT              NULL,
    [ENTERED_MEASUREMENT_UNIT]                   VARCHAR (50)     NULL,
    [ENTERED_MEASUREMENT_UNIT_QTY]               NUMERIC (18, 4)  NULL,
    [ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR] NUMERIC (18, 4)  NULL,
    [STATUS_CODE]                                VARCHAR (50)     NULL,
    [PROJECT_ID]                                 UNIQUEIDENTIFIER NULL,
    [PROJECT_CODE]                               VARCHAR (50)     NULL,
    [PROJECT_NAME]                               VARCHAR (150)    NULL,
    [PROJECT_SHORT_NAME]                         VARCHAR (25)     NULL,
    CONSTRAINT [PK_OP_WMS_TRANS] PRIMARY KEY CLUSTERED ([SERIAL_NUMBER] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_TRANS_X_OWNER]
    ON [FERCO].[OP_WMS_TRANS]([CLIENT_OWNER] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_TRANS_X_DATE]
    ON [FERCO].[OP_WMS_TRANS]([TRANS_DATE] ASC)
    INCLUDE([BATCH], [CLIENT_NAME], [CLIENT_OWNER], [CODE_SUPPLIER], [CODIGO_POLIZA], [VIN], [WAVE_PICKING_ID], [TRANS_EXTRA_COMMENTS], [TRANS_MT2], [TRANS_SUBTYPE], [TRANS_TYPE], [TRANS_WEIGTH], [TRANSFER_REQUEST_ID], [TARGET_LICENSE], [TARGET_LOCATION], [TARGET_WAREHOUSE], [TASK_ID], [TERMS_OF_TRADE], [TRANS_DESCRIPTION], [SERIAL_NUMBER], [SOURCE_LICENSE], [SOURCE_LOCATION], [SOURCE_TYPE], [SOURCE_WAREHOUSE], [STATUS], [MESSAGE_FROM_ERP], [NAME_SUPPLIER], [POSTED_TO_ERP_STAMP], [QUANTITY_UNITS], [RELATED_SERVICES], [SERIAL], [LOGIN_NAME], [MATERIAL_BARCODE], [MATERIAL_CODE], [MATERIAL_COST], [MATERIAL_DESCRIPTION], [MATERIAL_TYPE], [DATE_EXPIRATION], [DAYS_IDLE], [INVOICE_REFERENCE], [IS_FROM_SONDA], [LICENSE_ID], [LOGIN_ID]);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_TRANS]
    ON [FERCO].[OP_WMS_TRANS]([MATERIAL_CODE] ASC, [TRANS_DATE] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_TRANS_LICENSE_ID]
    ON [FERCO].[OP_WMS_TRANS]([LICENSE_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_TRANS_TRANS_TYPE]
    ON [FERCO].[OP_WMS_TRANS]([TRANS_TYPE] ASC)
    INCLUDE([CLIENT_NAME], [CLIENT_OWNER], [CODIGO_POLIZA], [LICENSE_ID], [MATERIAL_CODE], [MATERIAL_DESCRIPTION], [QUANTITY_UNITS], [SOURCE_WAREHOUSE], [STATUS], [TARGET_WAREHOUSE], [TRANSFER_REQUEST_ID]);


GO
CREATE NONCLUSTERED INDEX [I_TRANS_TYPE_STATUS_TASK_TRANS_DATE]
    ON [FERCO].[OP_WMS_TRANS]([TRANS_TYPE] ASC, [STATUS] ASC, [TASK_ID] ASC, [TRANS_DATE] ASC);


GO
	CREATE TRIGGER [FERCO].[DUP_TRANS] ON [FERCO].[OP_WMS_TRANS]
AFTER INSERT
AS

if exists ( select top 1 1 from FERCO.[OP_WMS_TRANS] t 
    inner join inserted i on i.LICENSE_ID=t.LICENSE_ID AND i.LOGIN_ID = t.LOGIN_ID ) 
begin
    rollback
    RAISERROR ('Duplicate Data', 16, 1);
end
ELSE
BEGIN
PRINT '1'
END
GO
DISABLE TRIGGER [FERCO].[DUP_TRANS]
    ON [FERCO].[OP_WMS_TRANS];

