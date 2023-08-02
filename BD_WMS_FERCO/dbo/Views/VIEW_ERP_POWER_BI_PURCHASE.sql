


-- =============================================
-- Autor:				Carlos.calel
-- Fecha de Creacion: 	17-05-2019
-- Description:			Vista que obtiene las ORDENES DE VENTA y los clientes de sap
/*
-- Ejemplo de Ejecucion:
		--
        dbo.VIEW_ERP_POWER_BI_PURCHASE
*/
--===============================
CREATE VIEW [dbo].[VIEW_ERP_POWER_BI_PURCHASE]
AS
    SELECT  TC.[DocNum] ID_FACTURA ,
            TC.[CardCode] [CODIGO_PV] ,
            TC.[CardName] [NOMBRE_PV] ,
            TC.[Address] [DIRECCION_PV] ,
            TC.[DocDate] FECHA_FAC ,
            TC.[DocCur] DIVISA ,
            TU.[WhsCode] BODEGA ,
            TC.[ExtraDays] [TERM_PAGO] ,
            TC.[ReqType] [METOD_PAGO] ,
            TC.[ReqType] [GRUPO_PROV] ,
            TC.[NumAtCard] [NIT] ,
            TU.[ItemCode] ID_PROD ,
            TU.[Dscription] DESCRIPCION ,
            TU.[unitMsr] [UNIDAD_MEDIDA] ,
            TU.[Quantity] CANTIDAD ,
            TU.[Price] PRECIO_UNI ,
            TU.[VatPrcnt] [PC_IMPUESTO] ,
            TU.[DiscPrcnt] [PC_DESCUENTO] ,
            (CASE WHEN TU.[DiscPrcnt]>0 THEN TU.DiscPrcnt ELSE 0 end*TU.[LineTotal])/100 [DESCUENTO] ,
            TU.[LineTotal] SUB_TOTAL ,
            TU.[ItemType] [GRUPO_SKU] ,
            TU.[TranType] [TIPO]
    FROM    [SAPSERVER].[SBOFERCO].dbo.OPOR TC
            INNER JOIN [SAPSERVER].[SBOFERCO].dbo.POR1 TU ON TC.DocEntry = TU.DocEntry
            LEFT OUTER JOIN [SAPSERVER].[SBOFERCO].dbo.PCH1 T2 ON T2.BaseEntry = TU.DocEntry
                                                              AND T2.BaseType = TU.ObjType
                                                              AND T2.BaseLine = TU.LineNum
            LEFT OUTER JOIN [SAPSERVER].[SBOFERCO].dbo.OPCH T3 ON T2.DocEntry = T3.DocEntry
            LEFT OUTER JOIN [SAPSERVER].[SBOFERCO].dbo.PDN1 T4 ON T4.BaseEntry = TU.DocEntry
                                                              AND T4.BaseType = TU.ObjType
                                                              AND T4.BaseLine = TU.LineNum
            LEFT OUTER JOIN [SAPSERVER].[SBOFERCO].dbo.OPDN T5 ON T4.DocEntry = T5.DocEntry
            INNER JOIN [SAPSERVER].[SBOFERCO].dbo.[OCRD] CL ON CL.CardCode = TC.[CardCode]
    WHERE   TC.[CANCELED] = 'N'
            AND TU.LineStatus = 'C'
			AND TU.[Quantity]>0
            AND TC.[DocDate] BETWEEN GETDATE() - 90 AND GETDATE();
			
   -- ORDER BY [TC].[DocDate] asc
   -- SELECT  OC.[DocEntry] [ID_FACTURA] ,
   --         OC.[SlpCode] [CODIGO_CL] ,
   --         OC.[CardName] [NOMBRE_CL] ,
   --         OC.[Address] [DIRECCION_CL] ,
   --         OC.[DocDate] [FECHA_FAC] ,
   --         OC.[DocCur] [DIVISA] ,
   --         OCD.[WhsCode] BODEGA ,
   --         [OC].[ExtraDays] [TERM_PAGO] ,
   --         OC.[ReqType] [METOD_PAGO] ,
   --         OC.[ReqType] [GRUPO_PROV] ,
   --         OC.[NumAtCard] [NIT] ,
   --         OCD.[ItemCode] [ID_PRODUCTO] ,
   --         OCD.[Dscription] [DESCRIPCION] ,
   --         OCD.[unitMsr2] [UNIDAD_MEDIDA] ,
   --         OCD.[Quantity] [CANTIDAD] ,
   --         OCD.[Price] [COSTO_UNI] ,
   --         OCD.[PriceAfVAT] [PRECIO_UNI] ,
   --         OCD.[VatPrcnt] [PC_IMPUESTO] ,
   --         OCD.[DiscPrcnt] [PC_DESCUENTO] ,
   --         OCD.[LineVat] [DESCUENTO] ,
   --         OC.[DiscPrcnt] [FACT_DESC] ,
   --         OCD.[LineTotal] [SUB_TOTAL] ,
   --         OC.[DocTotal] [TOTAL_NETO] ,
   --         OCD.[PriceAfVAT] * OCD.[Quantity] [TOTAL_BRUTO] ,
   --         OCD.[ItemType] [GRUPO_SKU] ,
   --         OCD.[TranType] [TIPO]
   -- FROM    [SAPSERVER].[SBOFERCO].dbo.[OPOR] [OC]
   --         INNER JOIN [SAPSERVER].[SBOFERCO].dbo.[RDR1] [OCD] ON [OCD].[DocEntry] = [OC].[DocEntry]
   --         INNER JOIN [SAPSERVER].[SBOFERCO].[dbo].[OSLP] [VENDEDOR] ON [VENDEDOR].[SlpCode] = [OC].[SlpCode]
   --         INNER JOIN [SAPSERVER].[SBOFERCO].dbo.[OCRD] [CLIENTE] ON [OC].[CardCode] = [CLIENTE].[CardCode]
			--WHERE  OC.[DocDate] BETWEEN GETDATE()-90 AND GETDATE()




