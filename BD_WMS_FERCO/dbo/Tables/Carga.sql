CREATE TABLE [dbo].[Carga] (
    [Regimen]               VARCHAR (30)    NULL,
    [Bodega]                VARCHAR (25)    NULL,
    [Zona]                  VARCHAR (10)    NULL,
    [Licencia]              VARCHAR (15)    NULL,
    [Ubicacion]             VARCHAR (30)    NULL,
    [Codigo_Material_old]   VARCHAR (35)    NULL,
    [codigo_Materia_new]    VARCHAR (35)    NULL,
    [Código_Material]       VARCHAR (10)    NULL,
    [Codigo_Barras]         VARCHAR (30)    NULL,
    [Descripcion]           VARCHAR (100)   NULL,
    [Fecha_Documento]       DATE            NULL,
    [Inv_Licencia_baja]     INT             NULL,
    [Inv_Licencia_ingresar] INT             NULL,
    [Inv_Disp]              INT             NULL,
    [Valor_Unitario]        DECIMAL (10, 2) NULL,
    [Valor_Total]           DECIMAL (10, 2) NULL
);

