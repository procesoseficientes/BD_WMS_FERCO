-- =============================================
-- Author:		<Fabrizzio,Rivera>
-- Create date: <01,Jul,20>
-- Description:	<UPDATE DLN1 ON SAP DB>
-- =============================================
CREATE PROCEDURE [FERCO].[OP_WMS_UPDATE_DELIVERY_ERP]
	-- Add the parameters for the stored procedure here
	@DOC INT,
	@PASS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-----
	-- GET CORRECT QUANTITY FROM NEXT PICKING DEMAND DETAIL
	-----
	SELECT DISTINCT
		PD.QTY,
		DocEntry,
		T0.LineNum
	INTO #DLN_QTY
	FROM 
	FERCO.[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] PD
	INNER JOIN [FERCO].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PH]
	ON [PH].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID]
	JOIN FERCO.OP_WMS_PASS_DETAIL PA
	ON PA.PICKING_DEMAND_HEADER_ID = PD.PICKING_DEMAND_HEADER_ID
	RIGHT JOIN [SAPSERVER].SBOPruebas.dbo.drf1 T0 
	ON T0.ItemCode COLLATE DATABASE_DEFAULT = [PD].MASTER_ID_MATERIAL COLLATE DATABASE_DEFAULT
	AND T0.DocEntry = @DOC
	WHERE PASS_HEADER_ID = @PASS

	DECLARE @QTY decimal(18, 4)
	DECLARE @DOCENTRY INT
	DECLARE @LINENUM INT

	---
	-- FOR LOOP THROUGH PICKING DEMAND DETAIL AND UPDATE SAP
	---
	While (Select Count(*) From #DLN_QTY) > 0
	Begin

		Select Top 1 @QTY = QTY, @DOCENTRY = DocEntry, @LINENUM = LineNum From #DLN_QTY

		UPDATE [SAPSERVER].SBOPruebas.dbo.drf1
		SET 
			OpenQty = OpenQty - @QTY
		WHERE DocEntry = @DOCENTRY
		AND LineNum = @LINENUM

		DELETE #DLN_QTY 
		WHERE DocEntry = @DOCENTRY
		AND LineNum = @LINENUM

	End;
	DROP TABLE #DLN_QTY;

	UPDATE [SAPSERVER].SBOPruebas.dbo.odrf
	SET
	u_estado2 = '05'--, InvntSttus   = 'C'
	WHERE DocEntry = @DOC
	AND (
		SELECT SUM(OpenQty) FROM [SAPSERVER].SBOPruebas.dbo.odrf T0 
		INNER JOIN [SAPSERVER].SBOPruebas.dbo.drf1 T1
		ON T0.DocEntry = T1.DocEntry
		WHERE T0.DocEntry = @DOC) <= 0

	UPDATE [SAPSERVER].SBOPruebas.dbo.oDLN
	SET
		u_estado2 = '05'
	WHERE DocEntry = @DOC

END