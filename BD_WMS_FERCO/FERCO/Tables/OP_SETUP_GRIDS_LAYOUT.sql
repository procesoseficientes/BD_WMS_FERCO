﻿CREATE TABLE [FERCO].[OP_SETUP_GRIDS_LAYOUT] (
    [GRID_ID]              VARCHAR (50)  NOT NULL,
    [LOGIN_ID]             VARCHAR (25)  NOT NULL,
    [LAYOUT_XML]           XML           NULL,
    [LAYOUT_XML_APPERANCE] XML           NULL,
    [GRID_CRITERIA_FILTER] VARCHAR (250) NULL
);

