CREATE TABLE [dbo].[OP_WMS_CHECKPOINTS2] (
    [CHECK_ID]        VARCHAR (50)   NOT NULL,
    [CATEGORY]        VARCHAR (25)   NOT NULL,
    [DESCRIPTION]     VARCHAR (150)  NOT NULL,
    [PARENT]          VARCHAR (50)   NULL,
    [ACCESS]          VARCHAR (25)   NOT NULL,
    [MPC_1]           NUMERIC (18)   NULL,
    [MPC_2]           NUMERIC (18)   NULL,
    [MPC_3]           VARCHAR (50)   NULL,
    [MPC_4]           NUMERIC (18)   NULL,
    [MPC_5]           VARCHAR (50)   NULL,
    [TARGET_LOCATION] VARCHAR (126)  NULL,
    [ORDER]           INT            NULL,
    [TYPE]            VARCHAR (26)   NULL,
    [PATH_IMAGE]      VARCHAR (1000) NULL
);

