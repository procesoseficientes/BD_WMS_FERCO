﻿CREATE TABLE [FERCO].[OP_BASC_FORMS] (
    [FORM_CODE]         VARCHAR (50)  NOT NULL,
    [FORM_NAME]         VARCHAR (150) NOT NULL,
    [QUESTION_GROUP]    VARCHAR (50)  NULL,
    [QUESTION_ID]       NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [QUESTION_NAME]     VARCHAR (25)  NULL,
    [QUESTION_PROMPT]   VARCHAR (150) NOT NULL,
    [QUESTION_DATATYPE] VARCHAR (50)  NULL,
    CONSTRAINT [PK_OP_BASC_FORMS] PRIMARY KEY CLUSTERED ([FORM_CODE] ASC, [QUESTION_ID] ASC)
);

