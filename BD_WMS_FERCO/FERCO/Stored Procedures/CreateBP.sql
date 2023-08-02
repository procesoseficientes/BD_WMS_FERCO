
-- =============================================
-- Author:		Ing. Carlos Rodriguez
-- Create date: 18/05/2010
-- Description:	Crea Socios de Negocios
-- =============================================
CREATE PROCEDURE FERCO.CreateBP
-- Add the parameters for the stored procedure here
@CodigoCliente NVARCHAR(15),
@NombreCliente NVARCHAR(100),
@RutaUser NVARCHAR(20),
@Sector NVARCHAR(20),
@Bloqueado INT,
@Territorio NVARCHAR(20),
@Transaction_Type NVARCHAR(1)
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

  INSERT INTO FERCO.OP_WMS_CLIENTS ([CLIENT_CODE]
  , [CLIENT_NAME]
  , [CLIENT_ROUTE]
  , [CLIENT_CLASS]
  , [CLIENT_STATUS]
  , [CLIENT_REGION])
    SELECT
      @CodigoCliente
     ,@NombreCliente
     ,@RutaUser
     ,@Sector
     ,@Bloqueado
     ,@Territorio
--
--			@CodigoCliCardCode
--			,CardName
--			,isnull(U_Ruta, '') as Ruta
--			,B.GroupName
--			,case FrozenFor
--			when 'N' then 1 else 0 end as StatusCliente
--			,isnull(c.Descript,'') as Territorio
--		from 
--		[192.168.16.5].SBO_Cosmetica.dbo.ocrd a join 
--		[192.168.16.5].SBO_Cosmetica.dbo.ocrg b on a.groupcode = b.groupcode left join 
--		[192.168.16.5].SBO_Cosmetica.dbo.oter c on a.Territory = c.TerritryID
--		where cardtype = 'C' and CardCode = @SN
--

-- Insert statements for procedure here
END
