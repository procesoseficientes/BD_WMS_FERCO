﻿
--use SWIFT_INTERFACES;

CREATE VIEW [ferco].[ERP_ORDER_HEADER]
as 
SELECT
  [EOH].[DocEntry]
 ,[EOH].[DocNum]
 ,[EOH].[DocType]
 ,[EOH].[CANCELED]
 ,[EOH].[Handwrtten]
 ,[EOH].[Printed]
 ,[EOH].[DocStatus]
 ,[EOH].[InvntSttus]
 ,[EOH].[Transfered]
 ,[EOH].[ObjType]
 ,[EOH].[DocDate]
 ,[EOH].[DocDueDate]
 ,[EOH].[CardCode]
 ,[EOH].[CardName]
 ,[EOH].[Address]
 ,[EOH].[NumAtCard]
 ,[EOH].[VatPercent]
 ,[EOH].[VatSum]
 ,[EOH].[VatSumFC]
 ,[EOH].[DiscPrcnt]
 ,[EOH].[DiscSum]
 ,[EOH].[DiscSumFC]
 ,[EOH].[DocCur]
 ,[EOH].[DocRate]
 ,[EOH].[DocTotal]
 ,[EOH].[DocTotalFC]
 ,[EOH].[PaidToDate]
 ,[EOH].[PaidFC]
 ,[EOH].[GrosProfit]
 ,[EOH].[GrosProfFC]
 ,[EOH].[Ref1]
 ,[EOH].[Ref2]
 ,[EOH].[Comments]
 ,[EOH].[JrnlMemo]
 ,[EOH].[TransId]
 ,[EOH].[ReceiptNum]
 ,[EOH].[GroupNum]
 ,[EOH].[DocTime]
 ,[EOH].[SlpCode]
 ,[EOH].[TrnspCode]
 ,[EOH].[PartSupply]
 ,[EOH].[Confirmed]
 ,[EOH].[GrossBase]
 ,[EOH].[ImportEnt]
 ,[EOH].[CreateTran]
 ,[EOH].[SummryType]
 ,[EOH].[UpdInvnt]
 ,[EOH].[UpdCardBal]
 ,[EOH].[Instance]
 ,[EOH].[Flags]
 ,[EOH].[InvntDirec]
 ,[EOH].[CntctCode]
 ,[EOH].[ShowSCN]
 ,[EOH].[FatherCard]
 ,[EOH].[SysRate]
 ,[EOH].[CurSource]
 ,[EOH].[VatSumSy]
 ,[EOH].[DiscSumSy]
 ,[EOH].[DocTotalSy]
 ,[EOH].[PaidSys]
 ,[EOH].[FatherType]
 ,[EOH].[GrosProfSy]
 ,[EOH].[UpdateDate]
 ,[EOH].[IsICT]
 ,[EOH].[CreateDate]
 ,[EOH].[Volume]
 ,[EOH].[VolUnit]
 ,[EOH].[Weight]
 ,[EOH].[WeightUnit]
 ,[EOH].[Series]
 ,[EOH].[TaxDate]
 ,[EOH].[Filler]
 ,[EOH].[DataSource]
 ,[EOH].[StampNum]
 ,[EOH].[isCrin]
 ,[EOH].[FinncPriod]
 ,[EOH].[UserSign]
 ,[EOH].[selfInv]
 ,[EOH].[VatPaid]
 ,[EOH].[VatPaidFC]
 ,[EOH].[VatPaidSys]
 ,[EOH].[UserSign2]
 ,[EOH].[WddStatus]
 ,[EOH].[draftKey]
 ,[EOH].[TotalExpns]
 ,[EOH].[TotalExpFC]
 ,[EOH].[TotalExpSC]
 ,[EOH].[DunnLevel]
 ,[EOH].[Address2]
 ,[EOH].[LogInstanc]
 ,[EOH].[Exported]
 ,[EOH].[StationID]
 ,[EOH].[Indicator]
 ,[EOH].[NetProc]
 ,[EOH].[AqcsTax]
 ,[EOH].[AqcsTaxFC]
 ,[EOH].[AqcsTaxSC]
 ,[EOH].[CashDiscPr]
 ,[EOH].[CashDiscnt]
 ,[EOH].[CashDiscFC]
 ,[EOH].[CashDiscSC]
 ,[EOH].[ShipToCode]
 ,[EOH].[LicTradNum]
 ,[EOH].[PaymentRef]
 ,[EOH].[WTSum]
 ,[EOH].[WTSumFC]
 ,[EOH].[WTSumSC]
 ,[EOH].[RoundDif]
 ,[EOH].[RoundDifFC]
 ,[EOH].[RoundDifSy]
 ,[EOH].[CheckDigit]
 ,[EOH].[Form1099]
 ,[EOH].[Box1099]
 ,[EOH].[submitted]
 ,[EOH].[PoPrss]
 ,[EOH].[Rounding]
 ,[EOH].[RevisionPo]
 ,[EOH].[Segment]
 ,[EOH].[ReqDate]
 ,[EOH].[CancelDate]
 ,[EOH].[PickStatus]
 ,[EOH].[Pick]
 ,[EOH].[BlockDunn]
 ,[EOH].[PeyMethod]
 ,[EOH].[PayBlock]
 ,[EOH].[PayBlckRef]
 ,[EOH].[MaxDscn]
 ,[EOH].[Reserve]
 ,[EOH].[Max1099]
 ,[EOH].[CntrlBnk]
 ,[EOH].[PickRmrk]
 ,[EOH].[ISRCodLine]
 ,[EOH].[ExpAppl]
 ,[EOH].[ExpApplFC]
 ,[EOH].[ExpApplSC]
 ,[EOH].[Project]
 ,[EOH].[DeferrTax]
 ,[EOH].[LetterNum]
 ,[EOH].[FromDate]
 ,[EOH].[ToDate]
 ,[EOH].[WTApplied]
 ,[EOH].[WTAppliedF]
 ,[EOH].[BoeReserev]
 ,[EOH].[AgentCode]
 ,[EOH].[WTAppliedS]
 ,[EOH].[EquVatSum]
 ,[EOH].[EquVatSumF]
 ,[EOH].[EquVatSumS]
 ,[EOH].[Installmnt]
 ,[EOH].[VATFirst]
 ,[EOH].[NnSbAmnt]
 ,[EOH].[NnSbAmntSC]
 ,[EOH].[NbSbAmntFC]
 ,[EOH].[ExepAmnt]
 ,[EOH].[ExepAmntSC]
 ,[EOH].[ExepAmntFC]
 ,[EOH].[VatDate]
 ,[EOH].[CorrExt]
 ,[EOH].[CorrInv]
 ,[EOH].[NCorrInv]
 ,[EOH].[CEECFlag]
 ,[EOH].[BaseAmnt]
 ,[EOH].[BaseAmntSC]
 ,[EOH].[BaseAmntFC]
 ,[EOH].[CtlAccount]
 ,[EOH].[BPLId]
 ,[EOH].[BPLName]
 ,[EOH].[VATRegNum]
 ,[EOH].[TxInvRptNo]
 ,[EOH].[TxInvRptDt]
 ,[EOH].[KVVATCode]
 ,[EOH].[WTDetails]
 ,[EOH].[SumAbsId]
 ,[EOH].[SumRptDate]
 ,[EOH].[PIndicator]
 ,[EOH].[ManualNum]
 ,[EOH].[UseShpdGd]
 ,[EOH].[BaseVtAt]
 ,[EOH].[BaseVtAtSC]
 ,[EOH].[BaseVtAtFC]
 ,[EOH].[NnSbVAt]
 ,[EOH].[NnSbVAtSC]
 ,[EOH].[NbSbVAtFC]
 ,[EOH].[ExptVAt]
 ,[EOH].[ExptVAtSC]
 ,[EOH].[ExptVAtFC]
 ,[EOH].[LYPmtAt]
 ,[EOH].[LYPmtAtSC]
 ,[EOH].[LYPmtAtFC]
 ,[EOH].[ExpAnSum]
 ,[EOH].[ExpAnSys]
 ,[EOH].[ExpAnFrgn]
 ,[EOH].[DocSubType]
 ,[EOH].[DpmStatus]
 ,[EOH].[DpmAmnt]
 ,[EOH].[DpmAmntSC]
 ,[EOH].[DpmAmntFC]
 ,[EOH].[DpmDrawn]
 ,[EOH].[DpmPrcnt]
 ,[EOH].[PaidSum]
 ,[EOH].[PaidSumFc]
 ,[EOH].[PaidSumSc]
 ,[EOH].[FolioPref]
 ,[EOH].[FolioNum]
 ,[EOH].[DpmAppl]
 ,[EOH].[DpmApplFc]
 ,[EOH].[DpmApplSc]
 ,[EOH].[LPgFolioN]
 ,[EOH].[Header]
 ,[EOH].[Footer]
 ,[EOH].[Posted]
 ,[EOH].[OwnerCode]
 ,[EOH].[BPChCode]
 ,[EOH].[BPChCntc]
 ,[EOH].[PayToCode]
 ,[EOH].[IsPaytoBnk]
 ,[EOH].[BnkCntry]
 ,[EOH].[BankCode]
 ,[EOH].[BnkAccount]
 ,[EOH].[BnkBranch]
 ,[EOH].[isIns]
 ,[EOH].[TrackNo]
 ,[EOH].[VersionNum]
 ,[EOH].[LangCode]
 ,[EOH].[BPNameOW]
 ,[EOH].[BillToOW]
 ,[EOH].[ShipToOW]
 ,[EOH].[RetInvoice]
 ,[EOH].[ClsDate]
 ,[EOH].[MInvNum]
 ,[EOH].[MInvDate]
 ,[EOH].[SeqCode]
 ,[EOH].[Serial]
 ,[EOH].[SeriesStr]
 ,[EOH].[SubStr]
 ,[EOH].[Model]
 ,[EOH].[TaxOnExp]
 ,[EOH].[TaxOnExpFc]
 ,[EOH].[TaxOnExpSc]
 ,[EOH].[TaxOnExAp]
 ,[EOH].[TaxOnExApF]
 ,[EOH].[TaxOnExApS]
 ,[EOH].[LastPmnTyp]
 ,[EOH].[LndCstNum]
 ,[EOH].[UseCorrVat]
 ,[EOH].[BlkCredMmo]
 ,[EOH].[OpenForLaC]
 ,[EOH].[Excised]
 ,[EOH].[ExcRefDate]
 ,[EOH].[ExcRmvTime]
 ,[EOH].[SrvGpPrcnt]
 ,[EOH].[DepositNum]
 ,[EOH].[CertNum]
 ,[EOH].[DutyStatus]
 ,[EOH].[AutoCrtFlw]
 ,[EOH].[FlwRefDate]
 ,[EOH].[FlwRefNum]
 ,[EOH].[VatJENum]
 ,[EOH].[DpmVat]
 ,[EOH].[DpmVatFc]
 ,[EOH].[DpmVatSc]
 ,[EOH].[DpmAppVat]
 ,[EOH].[DpmAppVatF]
 ,[EOH].[DpmAppVatS]
 ,[EOH].[InsurOp347]
 ,[EOH].[IgnRelDoc]
 ,[EOH].[BuildDesc]
 ,[EOH].[ResidenNum]
 ,[EOH].[Checker]
 ,[EOH].[Payee]
 ,[EOH].[CopyNumber]
 ,[EOH].[SSIExmpt]
 ,[EOH].[PQTGrpSer]
 ,[EOH].[PQTGrpNum]
 ,[EOH].[PQTGrpHW]
 ,[EOH].[ReopOriDoc]
 ,[EOH].[ReopManCls]
 ,[EOH].[DocManClsd]
 ,[EOH].[ClosingOpt]
 ,[EOH].[SpecDate]
 ,[EOH].[Ordered]
 ,[EOH].[NTSApprov]
 ,[EOH].[NTSWebSite]
 ,[EOH].[NTSeTaxNo]
 ,[EOH].[NTSApprNo]
 ,[EOH].[PayDuMonth]
 ,[EOH].[ExtraMonth]
 ,[EOH].[ExtraDays]
 ,[EOH].[CdcOffset]
 ,[EOH].[SignMsg]
 ,[EOH].[SignDigest]
 ,[EOH].[CertifNum]
 ,[EOH].[KeyVersion]
 ,[EOH].[EDocGenTyp]
 ,[EOH].[ESeries]
 ,[EOH].[EDocNum]
 ,[EOH].[EDocExpFrm]
 ,[EOH].[OnlineQuo]
 ,[EOH].[POSEqNum]
 ,[EOH].[POSManufSN]
 ,[EOH].[POSCashN]
 ,[EOH].[EDocStatus]
 ,[EOH].[EDocCntnt]
 ,[EOH].[EDocProces]
 ,[EOH].[EDocErrCod]
 ,[EOH].[EDocErrMsg]
 ,[EOH].[EDocCancel]
 ,[EOH].[EDocTest]
 ,[EOH].[EDocPrefix]
 ,[EOH].[CUP]
 ,[EOH].[CIG]
 ,[EOH].[DpmAsDscnt]
 ,[EOH].[Attachment]
 ,[EOH].[AtcEntry]
 ,[EOH].[SupplCode]
 ,[EOH].[GTSRlvnt]
 ,[EOH].[BaseDisc]
 ,[EOH].[BaseDiscSc]
 ,[EOH].[BaseDiscFc]
 ,[EOH].[BaseDiscPr]
 ,[EOH].[CreateTS]
 ,[EOH].[UpdateTS]
 ,[EOH].[SrvTaxRule]
 ,[EOH].[AnnInvDecR]
 ,[EOH].[Supplier]
 ,[EOH].[Releaser]
 ,[EOH].[Receiver]
 ,[EOH].[AgrNo]
 ,[EOH].[IsAlt]
 ,[EOH].[AltBaseTyp]
 ,[EOH].[AltBaseEnt]
 ,[EOH].[PaidDpm]
 ,[EOH].[PaidDpmF]
 ,[EOH].[PaidDpmS]
 ,[EOH].[U_Guatex]
 ,[EOH].[U_KM]
 ,[EOH].[Ship_To_Address_Type]
 ,[EOH].[Ship_To_Street]
 ,[EOH].[Ship_To_State]
 ,[EOH].[Ship_To_Country]
FROM [ferco].[SWIFT_ERP_ORDER_HEADER] [EOH]