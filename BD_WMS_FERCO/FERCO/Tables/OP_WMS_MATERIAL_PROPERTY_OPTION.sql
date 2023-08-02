﻿CREATE TABLE [FERCO].[OP_WMS_MATERIAL_PROPERTY_OPTION] (
    [MATERIAL_PROPERTY_ID] INT           NOT NULL,
    [VALUE]                VARCHAR (250) NOT NULL,
    [TEXT]                 VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_OP_WMS_MATERIAL_PROPERTY_OPTION] PRIMARY KEY CLUSTERED ([MATERIAL_PROPERTY_ID] ASC, [VALUE] ASC),
    CONSTRAINT [FK_OP_WMS_MATERIAL_PROPERTY_OPTION_MATERIAL_PROPERTY_ID] FOREIGN KEY ([MATERIAL_PROPERTY_ID]) REFERENCES [FERCO].[OP_WMS_MATERIAL_PROPERTY] ([MATERIAL_PROPERTY_ID])
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_MATERIAL_PROPERTY_OPTION_MATERIAL_PROPERTY_ID]
    ON [FERCO].[OP_WMS_MATERIAL_PROPERTY_OPTION]([MATERIAL_PROPERTY_ID] ASC)
    INCLUDE([VALUE], [TEXT]);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_MATERIAL_PROPERTY_OPTION_TEXT]
    ON [FERCO].[OP_WMS_MATERIAL_PROPERTY_OPTION]([TEXT] ASC)
    INCLUDE([VALUE], [MATERIAL_PROPERTY_ID]);

