-- =============================================
-- Author:		Elder Lucas
-- Create date: 2021.11.08
-- Description:	Trae doc entry con pass id para ordenes de ecommerce

-- Ejemplo:
--				EXEC FERCO.[GETSODOCENTRY_BY_PASS_ID_ECOMMERCE] @PASS_ID = 1576530
-- =============================================
CREATE PROCEDURE [FERCO].[GETSODOCENTRY_BY_PASS_ID_ECOMMERCE]
	(@PASS_ID INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARE @WAVE_PICKING_ID INT;

    -- Insert statements for procedure here
	SELECT DISTINCT [PD].[WAVE_PICKING_ID] INTO #WAVE_PICKING
    FROM [FERCO].[OP_WMS_PASS_DETAIL] [PD]
    WHERE [PD].[PASS_HEADER_ID] = @PASS_ID;


	--SELECT * FROM #WAVE_PICKING

	SELECT DOC_ENTRY FROM FERCO.OP_WMS_NEXT_PICKING_DEMAND_HEADER PDH
	INNER JOIN #WAVE_PICKING WP ON PDH.WAVE_PICKING_ID = WP.WAVE_PICKING_ID
	AND PDH.SOURCE_TYPE = 'SO - ERP' AND PDH.SERIES = 362;
END