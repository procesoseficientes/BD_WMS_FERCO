﻿
CREATE VIEW [ferco].[ERP_VIEW_INVOICE_HEADER]
AS
select  
	[DocEntry]
 ,[DocNum]
 ,[DocType]
 ,[CANCELED]
 ,[Handwrtten]
 ,[Printed]
 ,[DocStatus]
 ,[InvntSttus]
 ,[Transfered]
 ,[ObjType]
 ,[DocDate]
 ,[DocDueDate]
 ,[CardCode]
 ,[CardName]
 ,[Address]
 ,[NumAtCard]
 ,[VatPercent]
 ,[VatSum]
 ,[VatSumFC]
 ,[DiscPrcnt]
 ,[DiscSum]
 ,[DiscSumFC]
 ,[DocCur]
 ,[DocRate]
 ,[DocTotal]
 ,[DocTotalFC]
 ,[PaidToDate]
 ,[PaidFC]
 ,[GrosProfit]
 ,[GrosProfFC]
 ,[Ref1]
 ,[Ref2]
 ,[Comments]
 ,[JrnlMemo]
 ,[TransId]
 ,[ReceiptNum]
 ,[GroupNum]
 ,[DocTime]
 ,[SlpCode]
 ,[TrnspCode]
 ,[PartSupply]
 ,[Confirmed]
 ,[GrossBase]
 ,[ImportEnt]
 ,[CreateTran]
 ,[SummryType]
 ,[UpdInvnt]
 ,[UpdCardBal]
 ,[Instance]
 ,[Flags]
 ,[InvntDirec]
 ,[CntctCode]
 ,[ShowSCN]
 ,[FatherCard]
 ,[SysRate]
 ,[CurSource]
 ,[VatSumSy]
 ,[DiscSumSy]
 ,[DocTotalSy]
 ,[PaidSys]
 ,[FatherType]
 ,[GrosProfSy]
 ,[UpdateDate]
 ,[IsICT]
 ,[CreateDate]
 ,[Volume]
 ,[VolUnit]
 ,[Weight]
 ,[WeightUnit]
 ,[Series]
 ,[TaxDate]
 ,[Filler]
 ,[DataSource]
 ,[StampNum]
 ,[isCrin]
 ,[FinncPriod]
 ,[UserSign]
 ,[selfInv]
 ,[VatPaid]
 ,[VatPaidFC]
 ,[VatPaidSys]
 ,[UserSign2]
 ,[WddStatus]
 ,[draftKey]
 ,[TotalExpns]
 ,[TotalExpFC]
 ,[TotalExpSC]
 ,[DunnLevel]
 ,[Address2]
 ,[LogInstanc]
 ,[Exported]
 ,[StationID]
 ,[Indicator]
 ,[NetProc]
 ,[AqcsTax]
 ,[AqcsTaxFC]
 ,[AqcsTaxSC]
 ,[CashDiscPr]
 ,[CashDiscnt]
 ,[CashDiscFC]
 ,[CashDiscSC]
 ,[ShipToCode]
 ,[LicTradNum]
 ,[PaymentRef]
 ,[WTSum]
 ,[WTSumFC]
 ,[WTSumSC]
 ,[RoundDif]
 ,[RoundDifFC]
 ,[RoundDifSy]
 ,[CheckDigit]
 ,[Form1099]
 ,[Box1099]
 ,[submitted]
 ,[PoPrss]
 ,[Rounding]
 ,[RevisionPo]
 ,[Segment]
 ,[ReqDate]
 ,[CancelDate]
 ,[PickStatus]
 ,[Pick]
 ,[BlockDunn]
 ,[PeyMethod]
 ,[PayBlock]
 ,[PayBlckRef]
 ,[MaxDscn]
 ,[Reserve]
 ,[Max1099]
 ,[CntrlBnk]
 ,[PickRmrk]
 ,[ISRCodLine]
 ,[ExpAppl]
 ,[ExpApplFC]
 ,[ExpApplSC]
 ,[Project]
 ,[DeferrTax]
 ,[LetterNum]
 ,[FromDate]
 ,[ToDate]
 ,[WTApplied]
 ,[WTAppliedF]
 ,[BoeReserev]
 ,[AgentCode]
 ,[WTAppliedS]
 ,[EquVatSum]
 ,[EquVatSumF]
 ,[EquVatSumS]
 ,[Installmnt]
 ,[VATFirst]
 ,[NnSbAmnt]
 ,[NnSbAmntSC]
 ,[NbSbAmntFC]
 ,[ExepAmnt]
 ,[ExepAmntSC]
 ,[ExepAmntFC]
 ,[VatDate]
 ,[CorrExt]
 ,[CorrInv]
 ,[NCorrInv]
 ,[CEECFlag]
 ,[BaseAmnt]
 ,[BaseAmntSC]
 ,[BaseAmntFC]
 ,[CtlAccount]
 ,[BPLId]
 ,[BPLName]
 ,[VATRegNum]
 ,[TxInvRptNo]
 ,[TxInvRptDt]
 ,[KVVATCode]
 ,[WTDetails]
 ,[SumAbsId]
 ,[SumRptDate]
 ,[PIndicator]
 ,[ManualNum]
 ,[UseShpdGd]
 ,[BaseVtAt]
 ,[BaseVtAtSC]
 ,[BaseVtAtFC]
 ,[NnSbVAt]
 ,[NnSbVAtSC]
 ,[NbSbVAtFC]
 ,[ExptVAt]
 ,[ExptVAtSC]
 ,[ExptVAtFC]
 ,[LYPmtAt]
 ,[LYPmtAtSC]
 ,[LYPmtAtFC]
 ,[ExpAnSum]
 ,[ExpAnSys]
 ,[ExpAnFrgn]
 ,[DocSubType]
 ,[DpmStatus]
 ,[DpmAmnt]
 ,[DpmAmntSC]
 ,[DpmAmntFC]
 ,[DpmDrawn]
 ,[DpmPrcnt]
 ,[PaidSum]
 ,[PaidSumFc]
 ,[PaidSumSc]
 ,[FolioPref]
 ,[FolioNum]
 ,[DpmAppl]
 ,[DpmApplFc]
 ,[DpmApplSc]
 ,[LPgFolioN]
 ,[Header]
 ,[Footer]
 ,[Posted]
 ,[OwnerCode]
 ,[BPChCode]
 ,[BPChCntc]
 ,[PayToCode]
 ,[IsPaytoBnk]
 ,[BnkCntry]
 ,[BankCode]
 ,[BnkAccount]
 ,[BnkBranch]
 ,[isIns]
 ,[TrackNo]
 ,[VersionNum]
 ,[LangCode]
 ,[BPNameOW]
 ,[BillToOW]
 ,[ShipToOW]
 ,[RetInvoice]
 ,[ClsDate]
 ,[MInvNum]
 ,[MInvDate]
 ,[SeqCode]
 ,[Serial]
 ,[SeriesStr]
 ,[SubStr]
 ,[Model]
 ,[TaxOnExp]
 ,[TaxOnExpFc]
 ,[TaxOnExpSc]
 ,[TaxOnExAp]
 ,[TaxOnExApF]
 ,[TaxOnExApS]
 ,[LastPmnTyp]
 ,[LndCstNum]
 ,[UseCorrVat]
 ,[BlkCredMmo]
 ,[OpenForLaC]
 ,[Excised]
 ,[ExcRefDate]
 ,[ExcRmvTime]
 ,[SrvGpPrcnt]
 ,[DepositNum]
 ,[CertNum]
 ,[DutyStatus]
 ,[AutoCrtFlw]
 ,[FlwRefDate]
 ,[FlwRefNum]
 ,[VatJENum]
 ,[DpmVat]
 ,[DpmVatFc]
 ,[DpmVatSc]
 ,[DpmAppVat]
 ,[DpmAppVatF]
 ,[DpmAppVatS]
 ,[InsurOp347]
 ,[IgnRelDoc]
 ,[BuildDesc]
 ,[ResidenNum]
 ,[Checker]
 ,[Payee]
 ,[CopyNumber]
 ,[SSIExmpt]
 ,[PQTGrpSer]
 ,[PQTGrpNum]
 ,[PQTGrpHW]
 ,[ReopOriDoc]
 ,[ReopManCls]
 ,[DocManClsd]
 ,[ClosingOpt]
 ,[SpecDate]
 ,[Ordered]
 ,[NTSApprov]
 ,[NTSWebSite]
 ,[NTSeTaxNo]
 ,[NTSApprNo]
 ,[PayDuMonth]
 ,[ExtraMonth]
 ,[ExtraDays]
 ,[CdcOffset]
 ,[SignMsg]
 ,[SignDigest]
 ,[CertifNum]
 ,[KeyVersion]
 ,[EDocGenTyp]
 ,[ESeries]
 ,[EDocNum]
 ,[EDocExpFrm]
 ,[OnlineQuo]
 ,[POSEqNum]
 ,[POSManufSN]
 ,[POSCashN]
 ,[EDocStatus]
 ,[EDocCntnt]
 ,[EDocProces]
 ,[EDocErrCod]
 ,[EDocErrMsg]
 ,[EDocCancel]
 ,[EDocTest]
 ,[EDocPrefix]
 ,[CUP]
 ,[CIG]
 ,[DpmAsDscnt]
 ,[Attachment]
 ,[AtcEntry]
 ,[SupplCode]
 ,[GTSRlvnt]
 ,[BaseDisc]
 ,[BaseDiscSc]
 ,[BaseDiscFc]
 ,[BaseDiscPr]
 ,[CreateTS]
 ,[UpdateTS]
 ,[SrvTaxRule]
 ,[AnnInvDecR]
 ,[Supplier]
 ,[Releaser]
 ,[Receiver]
 ,[ToWhsCode]
 ,[AssetDate]
 ,[Requester]
 ,[ReqName]
 ,[Branch]
 ,[Department]
 ,[Email]
 ,[Notify]
 ,[ReqType]
 ,[OriginType]
 ,[IsReuseNum]
 ,[IsReuseNFN]
 ,[DocDlvry]
 ,[PaidDpm]
 ,[PaidDpmF]
 ,[PaidDpmS]
 ,[EnvTypeNFe]
 ,[AgrNo]
 ,[IsAlt]
 ,[AltBaseTyp]
 ,[AltBaseEnt]
 ,[AuthCode]
 ,[StDlvDate]
 ,[StDlvTime]
 ,[EndDlvDate]
 ,[EndDlvTime]
 ,[VclPlate]
 ,[ElCoStatus]
 ,[AtDocType]
 ,[ElCoMsg]
 ,[PrintSEPA]
 ,[FreeChrg]
 ,[FreeChrgFC]
 ,[FreeChrgSC]
 ,[NfeValue]
 ,[FiscDocNum]
 ,[RelatedTyp]
 ,[RelatedEnt]
 ,[CCDEntry]
 ,[NfePrntFo]
 ,[ZrdAbs]
 ,[POSRcptNo]
 ,[FoCTax]
 ,[FoCTaxFC]
 ,[FoCTaxSC]
 ,[TpCusPres]
 ,[ExcDocDate]
 ,'' [U_OPER]
 ,'' [U_Serie]
from OPENQUERY([SAPSERVER],'SELECT * FROM [SBOFERCO].dbo.OINV')