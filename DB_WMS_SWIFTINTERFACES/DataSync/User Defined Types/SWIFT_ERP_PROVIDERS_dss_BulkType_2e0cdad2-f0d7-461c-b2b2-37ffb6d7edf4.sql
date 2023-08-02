CREATE TYPE [DataSync].[SWIFT_ERP_PROVIDERS_dss_BulkType_2e0cdad2-f0d7-461c-b2b2-37ffb6d7edf4] AS TABLE (
    [PROVIDER]                   NVARCHAR (15)  NULL,
    [CODE_PROVIDER]              NVARCHAR (15)  NOT NULL,
    [NAME_PROVIDER]              NVARCHAR (100) NULL,
    [CLASSIFICATION_PROVIDER]    VARCHAR (30)   NULL,
    [CONTACT_PROVIDER]           NVARCHAR (90)  NULL,
    [FROM_ERP]                   INT            NULL,
    [NAME_CLASSIFICATION]        VARCHAR (30)   NULL,
    [sync_update_peer_timestamp] BIGINT         NULL,
    [sync_update_peer_key]       INT            NULL,
    [sync_create_peer_timestamp] BIGINT         NULL,
    [sync_create_peer_key]       INT            NULL,
    PRIMARY KEY CLUSTERED ([CODE_PROVIDER] ASC));

