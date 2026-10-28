CREATE Procedure [CDN].[Mobile_EksportWal]
AS
  DECLARE
  @sqltxt   NVARCHAR(1024),
  @FullKnfName      NVARCHAR(512)
 SET @FullKnfName = CDN.GetFullKnfName()
SET @sqltxt =  'select top 1 wna_wnaid,wna_symbol,1 as wna_Systemowa from' + @FullKnfName+'.[CDN].[WalNazwy] where wna_wnaid = 1'
EXEC sp_executesql @sqltxt
