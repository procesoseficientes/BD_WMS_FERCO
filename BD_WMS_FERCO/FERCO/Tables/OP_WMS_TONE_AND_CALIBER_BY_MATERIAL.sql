﻿CREATE TABLE [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] (
    [TONE_AND_CALIBER_ID] INT          IDENTITY (1, 1) NOT NULL,
    [MATERIAL_ID]         VARCHAR (50) NOT NULL,
    [TONE]                VARCHAR (20) DEFAULT (NULL) NULL,
    [CALIBER]             VARCHAR (20) DEFAULT (NULL) NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_TONE_AND_CALIBER_MATERIAL_ID]
    ON [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL]([MATERIAL_ID] ASC, [TONE] ASC, [CALIBER] ASC)
    INCLUDE([TONE_AND_CALIBER_ID]);


GO
CREATE NONCLUSTERED INDEX [IDX_TONE_AND_CALIBER_ID]
    ON [FERCO].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL]([TONE_AND_CALIBER_ID] ASC)
    INCLUDE([TONE], [CALIBER]);

