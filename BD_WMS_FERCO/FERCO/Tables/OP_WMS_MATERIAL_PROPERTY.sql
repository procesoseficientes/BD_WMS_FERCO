﻿CREATE TABLE [FERCO].[OP_WMS_MATERIAL_PROPERTY] (
    [MATERIAL_PROPERTY_ID] INT           IDENTITY (1, 1) NOT NULL,
    [NAME]                 VARCHAR (50)  NOT NULL,
    [DATA_TYPE]            VARCHAR (50)  NOT NULL,
    [DESCRIPTION]          VARCHAR (250) NULL,
    CONSTRAINT [PK_OP_WMS_MATERIAL_PROPERTY] PRIMARY KEY CLUSTERED ([MATERIAL_PROPERTY_ID] ASC),
    CONSTRAINT [UC_OP_WMS_MATERIAL_PROPERTY_NAME] UNIQUE NONCLUSTERED ([NAME] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_MATERIAL_PROPERTY_NAME]
    ON [FERCO].[OP_WMS_MATERIAL_PROPERTY]([NAME] ASC)
    INCLUDE([MATERIAL_PROPERTY_ID], [DATA_TYPE], [DESCRIPTION]);

