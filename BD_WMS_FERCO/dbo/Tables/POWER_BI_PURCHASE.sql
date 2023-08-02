﻿CREATE TABLE [dbo].[POWER_BI_PURCHASE] (
    [ID_FACTURA]    VARCHAR (MAX)   NULL,
    [CODIGO_PV]     VARCHAR (MAX)   NULL,
    [NOMBRE_PV]     VARCHAR (MAX)   NULL,
    [DIRECCION_PV]  VARCHAR (MAX)   NULL,
    [FECHA_FAC]     DATE            NULL,
    [DIVISA]        VARCHAR (MAX)   NULL,
    [BODEGA]        VARCHAR (MAX)   NULL,
    [TEMR_PAGO]     VARCHAR (MAX)   NULL,
    [METOD_PAGO]    VARCHAR (MAX)   NULL,
    [GRUPO_PROV]    VARCHAR (MAX)   NULL,
    [NIT]           VARCHAR (MAX)   NULL,
    [ID_PRODUCTO]   VARCHAR (MAX)   NULL,
    [DESCRIPCION]   VARCHAR (MAX)   NULL,
    [UNIDAD_MEDIDA] VARCHAR (MAX)   NULL,
    [CANTIDAD]      DECIMAL (18, 2) NULL,
    [PRECIO_UNI]    DECIMAL (18, 2) NULL,
    [PC_IMPUESTO]   DECIMAL (18, 2) NULL,
    [PC_DESCUENTO]  DECIMAL (18, 2) NULL,
    [DESCUENTO]     DECIMAL (18, 2) NULL,
    [SUB_TOTAL]     DECIMAL (18, 2) NULL,
    [GRUPO_SKU]     VARCHAR (MAX)   NULL,
    [TIPO]          VARCHAR (MAX)   NULL
);
