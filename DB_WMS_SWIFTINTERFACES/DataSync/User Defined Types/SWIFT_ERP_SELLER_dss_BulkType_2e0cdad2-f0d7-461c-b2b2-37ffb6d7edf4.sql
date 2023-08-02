CREATE TYPE [DataSync].[SWIFT_ERP_SELLER_dss_BulkType_2e0cdad2-f0d7-461c-b2b2-37ffb6d7edf4] AS TABLE (
    [SELLER_CODE]                SMALLINT      NOT NULL,
    [SELLER_NAME]                VARCHAR (155) NULL,
    [sync_update_peer_timestamp] BIGINT        NULL,
    [sync_update_peer_key]       INT           NULL,
    [sync_create_peer_timestamp] BIGINT        NULL,
    [sync_create_peer_key]       INT           NULL,
    PRIMARY KEY CLUSTERED ([SELLER_CODE] ASC));

