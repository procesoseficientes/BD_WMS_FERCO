﻿CREATE TABLE [FERCO].[OP_WMS_TASK_LIST_HISTORY] (
    [SERIAL_NUMBER]         NUMERIC (18)  NOT NULL,
    [ASSIGNED_DATE]         DATETIME      NOT NULL,
    [TASK_TYPE]             VARCHAR (25)  NOT NULL,
    [TASK_SUBTYPE]          VARCHAR (25)  NOT NULL,
    [TASK_OWNER]            VARCHAR (25)  NOT NULL,
    [TASK_ASSIGNEDTO]       VARCHAR (25)  NOT NULL,
    [IS_COMPLETED]          NUMERIC (18)  NULL,
    [IS_DISCRETIONAL]       INT           NOT NULL,
    [MATERIAL_CODE]         VARCHAR (25)  NOT NULL,
    [MATERIAL_BARCODE]      VARCHAR (50)  NOT NULL,
    [MATERIAL_DESCRIPTION]  VARCHAR (200) NOT NULL,
    [WAREHOUSE_SOURCE]      VARCHAR (25)  NULL,
    [WAREHOUSE_TARGET]      VARCHAR (25)  NULL,
    [LOCATION_SPOT_SOURCE]  VARCHAR (25)  NULL,
    [LOCATION_SPOT_TARGET]  VARCHAR (25)  NULL,
    [ERP_LEGACY_ID]         VARCHAR (25)  NULL,
    [ERP_DATE]              DATETIME      NULL,
    [ERP_QTY]               NUMERIC (18)  NULL,
    [QUANTITY_PENDING]      NUMERIC (18)  NOT NULL,
    [QUANTITY_ASSIGNED]     NUMERIC (18)  NOT NULL,
    [CLIENT_OWNER]          VARCHAR (25)  NULL,
    [CLIENT_NAME]           VARCHAR (150) NULL,
    [PICKING_STARTED_DATE]  DATETIME      NULL,
    [PICKING_FINISHED_DATE] DATETIME      NULL,
    [TASK_COMMENTS]         VARCHAR (150) NULL,
    [TRANS_OWNER]           NUMERIC (18)  NULL,
    [IS_PAUSED]             NUMERIC (18)  NULL,
    [IS_CANCELED]           NUMERIC (18)  NULL,
    [CANCELED_DATETIME]     DATETIME      NULL,
    [CANCELED_BY]           VARCHAR (25)  NULL,
    [BIN_SOURCE]            NUMERIC (18)  NULL,
    [BIN_TARGET]            NUMERIC (18)  NULL,
    [IS_COMPLETED2]         NUMERIC (18)  NULL
);
