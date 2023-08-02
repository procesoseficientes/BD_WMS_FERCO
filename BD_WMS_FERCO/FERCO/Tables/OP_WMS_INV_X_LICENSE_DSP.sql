﻿CREATE TABLE [FERCO].[OP_WMS_INV_X_LICENSE_DSP] (
    [PK_LINE]                                    NUMERIC (18)     IDENTITY (1, 1) NOT NULL,
    [LICENSE_ID]                                 NUMERIC (18)     NOT NULL,
    [MATERIAL_ID]                                VARCHAR (50)     NOT NULL,
    [MATERIAL_NAME]                              VARCHAR (150)    NULL,
    [QTY]                                        NUMERIC (18, 4)  NOT NULL,
    [VOLUME_FACTOR]                              NUMERIC (18)     NULL,
    [WEIGTH]                                     NUMERIC (18, 2)  NULL,
    [SERIAL_NUMBER]                              VARCHAR (50)     NULL,
    [COMMENTS]                                   VARCHAR (250)    NULL,
    [LAST_UPDATED]                               DATETIME         NULL,
    [LAST_UPDATED_BY]                            VARCHAR (25)     NULL,
    [BARCODE_ID]                                 VARCHAR (25)     NULL,
    [TERMS_OF_TRADE]                             VARCHAR (50)     NULL,
    [STATUS]                                     VARCHAR (25)     NULL,
    [CREATED_DATE]                               DATETIME         NULL,
    [DATE_EXPIRATION]                            DATE             NULL,
    [BATCH]                                      VARCHAR (50)     NULL,
    [ENTERED_QTY]                                NUMERIC (18, 4)  NULL,
    [VIN]                                        VARCHAR (40)     NULL,
    [HANDLE_SERIAL]                              NUMERIC (18)     NULL,
    [IS_EXTERNAL_INVENTORY]                      INT              NOT NULL,
    [IS_BLOCKED]                                 INT              NOT NULL,
    [BLOCKED_STATUS]                             VARCHAR (250)    NULL,
    [STATUS_ID]                                  INT              NULL,
    [TONE_AND_CALIBER_ID]                        INT              NULL,
    [LOCKED_BY_INTERFACES]                       INT              NULL,
    [ENTERED_MEASUREMENT_UNIT]                   VARCHAR (50)     NULL,
    [ENTERED_MEASUREMENT_UNIT_QTY]               NUMERIC (18, 4)  NULL,
    [ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR] NUMERIC (18, 4)  NULL,
    [CODE_SUPPLIER]                              VARCHAR (50)     NULL,
    [NAME_SUPPLIER]                              VARCHAR (100)    NULL,
    [IDLE]                                       INT              NOT NULL,
    [NUMBER_OF_COMPLETE_RELOCATIONS]             INT              NOT NULL,
    [NUMBER_OF_PARTIAL_RELOCATIONS]              INT              NOT NULL,
    [NUMBER_OF_PHYSICAL_COUNTS]                  INT              NOT NULL,
    [PROJECT_ID]                                 UNIQUEIDENTIFIER NULL,
    [TOTAL_POSITION]                             INT              NULL
);

