CREATE TABLE [dbo].[Dimension_tiempo] (
    [FECHAKEY]   INT          NULL,
    [Fecha]      DATE         NULL,
    [Año]        SMALLINT     NULL,
    [Semestre]   SMALLINT     NULL,
    [Trimestre]  SMALLINT     NULL,
    [Mes]        SMALLINT     NULL,
    [Semana]     SMALLINT     NULL,
    [dia]        SMALLINT     NULL,
    [DiaSemana]  SMALLINT     NULL,
    [NSemestre]  VARCHAR (15) NULL,
    [NTrimestre] VARCHAR (15) NULL,
    [NMes]       VARCHAR (15) NULL,
    [NMes3L]     VARCHAR (15) NULL,
    [NSemana]    VARCHAR (15) NULL,
    [NDia]       VARCHAR (15) NULL,
    [NDiaSemana] VARCHAR (15) NULL
);

