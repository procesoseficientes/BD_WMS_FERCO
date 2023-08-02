CREATE TYPE [DataSync].[SWIFT_ERP_ORDER_DETAIL_dss_BulkType_2e0cdad2-f0d7-461c-b2b2-37ffb6d7edf4] AS TABLE (
    [DOC_ENTRY]                  INT           NOT NULL,
    [ITEM_CODE]                  NVARCHAR (20) NULL,
    [OBJ_TYPE]                   NVARCHAR (20) NULL,
    [LINE_NUM]                   INT           NOT NULL,
    [sync_update_peer_timestamp] BIGINT        NULL,
    [sync_update_peer_key]       INT           NULL,
    [sync_create_peer_timestamp] BIGINT        NULL,
    [sync_create_peer_key]       INT           NULL,
    PRIMARY KEY CLUSTERED ([DOC_ENTRY] ASC, [LINE_NUM] ASC));

