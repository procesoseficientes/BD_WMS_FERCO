

-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	24-Jul-2018 @ G-Force Team Sprint FocaMonje
-- Description:			SP que obtiene la informacion del vendedor.

-- Autor:				Gildardo.Alvarado
-- Fecha de Creacion: 	10-Feb-2021 @ ProcesosEficientes
-- Description:			Copia del SP SWIFT_SP_GET_INFORMATION_OF_SELLER.
--						Adaptado para las draft, entregas preliminares o tambien llamandas Delivery order.
/*
-- Ejemplo de Ejecucion:
				DECLARE @DOC_NUM INT =-1
				--
				EXEC [ferco].[SWIFT_SP_GET_INFORMATION_OF_SELLER_DELIVERY]				
					@DOC_NUM = '298552'
				--
				SELECT @DOC_NUM
*/
-- =============================================
CREATE PROCEDURE [ferco].[SWIFT_SP_GET_INFORMATION_OF_SELLER_DELIVERY] (@DOC_NUM VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @QUERY NVARCHAR(2000)

  SELECT
    @QUERY = N'
	SELECT DISTINCT
      a.docnum [DOC_NUM]
     ,b.slpname [SELLER]
     ,c.trnspname [TRNSP_NAME]
     ,a.comments [COMMENTS]
     ,e.pymntgroup [PYMNT_GROUP]
     ,f.u_branchname AS [BRANCH_NAME]    
    FROM [SBOPruebas].[dbo].ODLN a
    INNER JOIN [SBOPruebas].[dbo].DLN1 a1
      ON a.docentry = a1.docentry
    INNER JOIN [SBOPruebas].[dbo].oslp b
      ON a.slpcode = b.slpcode
    INNER JOIN [SBOPruebas].[dbo].oshp c
      ON a.trnspcode = c.trnspcode
    INNER JOIN [SBOPruebas].[dbo].ocrd d
      ON a.cardcode = d.cardcode
    INNER JOIN [SBOPruebas].[dbo].octg e
      ON d.groupnum = e.groupnum
    INNER JOIN [SBOPruebas].[dbo].[@SUCURSAL_CCOSTO] f
      ON a.u_sucursal = f.name
    WHERE a.docnum  IN (' + @DOC_NUM + ')'
  --

  SET @QUERY = N'SELECT * FROM OPENQUERY ([SAPSERVER], ''' + @QUERY + ''')'

  PRINT @QUERY

  EXEC sp_executesql @QUERY


END