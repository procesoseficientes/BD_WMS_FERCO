

CREATE VIEW [FERCO].[ERP_VIEW_ORDER_SERIE_DETAIL]
as 
select *from openquery (SAPSERVER,'SELECT     [SBOFERCO].dbo.OSRN.SysNumber, [SBOFERCO].dbo.OSRN.MnfSerial, [SBOFERCO].dbo.OSRN.ItemCode
                                                    FROM          [SBOFERCO].dbo.PDN1 INNER JOIN
                                                                           [SBOFERCO].dbo.OPDN ON [SBOFERCO].dbo.PDN1.DocEntry = [SBOFERCO].dbo.OPDN.DocEntry INNER JOIN
                                                                           [SBOFERCO].dbo.OITL ON [SBOFERCO].dbo.PDN1.ItemCode = [SBOFERCO].dbo.OITL.ItemCode AND [SBOFERCO].dbo.PDN1.DocEntry = [SBOFERCO].dbo.OITL.DocEntry AND 
                                                                           [SBOFERCO].dbo.PDN1.LineNum = [SBOFERCO].dbo.OITL.DocLine INNER JOIN
                                                                           [SBOFERCO].dbo.ITL1 ON [SBOFERCO].dbo.OITL.LogEntry = [SBOFERCO].dbo.ITL1.LogEntry INNER JOIN
                                                                           [SBOFERCO].dbo.OSRN ON [SBOFERCO].dbo.ITL1.MdAbsEntry = [SBOFERCO].dbo.OSRN.AbsEntry
                                                    WHERE      ([SBOFERCO].dbo.OITL.DocType = 20) AND ([SBOFERCO].dbo.OITL.ManagedBy = 10000045) ')