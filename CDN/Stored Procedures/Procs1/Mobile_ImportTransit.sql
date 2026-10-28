CREATE PROCEDURE [CDN].[Mobile_ImportTransit]
@SamId int,
@Cel nvarchar(50),
@Trasa nvarchar(1000),
@OpeId int,
@Data DateTime,
@LicznikPocz int,
@LicznikKon int,
@UserCenterId int,
@TransitId int
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
declare @Stawka decimal(7,4)
declare @KlasaPoj int
declare @NazwaPoj nvarchar(32)
set @KlasaPoj = (select AuE_KlasaPoj from cdn.AutoEwid where AuE_AuEID = @SamId)
if @KlasaPoj = 1
 set @NazwaPoj = 'Powyżej 900'
else if @KlasaPoj = 2
 set @NazwaPoj = 'Do 900'
else if @KlasaPoj = 3
 set @NazwaPoj = 'Motocykl'
else if @KlasaPoj = 4
 set @NazwaPoj = 'Motorower'
else
 set @NazwaPoj = ''
DECLARE @DataStr as nvarchar(20)
set @DataStr = convert(nvarchar(30), @Data)
DECLARE @sqltxt NVARCHAR(500), @Parameters NVARCHAR(200)
set @sqltxt = 'select @Stawka = Isnull((select replace(cfw_wartosc, '','',''.'') from' + CDN.BazaKonfiguracyjna() + '.cdn.CfgWartosci where CFW_CfkId =
(select CFK_CfkId from ' + CDN.BazaKonfiguracyjna() + '.cdn.CfgKlucze where cfk_nazwa = ''' + @NazwaPoj +
''' and CFK_OkresOd <= convert(datetime, ''' + @DataStr + ''', 120)
and cfk_okresdo > convert(datetime, ''' + @DataStr + ''', 120))),0)'
SET @Parameters = '@Stawka decimal(7,4) OUTPUT'
exec sp_executesql @sqltxt, @Parameters, @Stawka = @Stawka output
declare @Lp int
declare @RokMies int
if(MONTH(@Data) < 10)
 set @RokMies = convert(nvarchar(4),YEAR(@Data)) + '0' + convert(nvarchar(2), MONTH(@Data))
else
 set @RokMies = convert(nvarchar(4),YEAR(@Data)) + convert(nvarchar(2), MONTH(@Data))
set @Lp = (select Isnull(MAX(AuP_Lp), 0) + 1 from CDN.AutoPrzejazd where AuP_AuEID = @SamId and AuP_RokMies = @RokMies)
declare @Dysponent nvarchar(50)
set @sqltxt = 'select @Dysponent = Ope_Nazwisko from ' + CDN.BazaKonfiguracyjna() + '.CDN.Operatorzy where Ope_OpeID = @OpeId'
set @Parameters = '@Dysponent nvarchar(50) output, @OpeId int'
exec sp_executesql @sqltxt, @Parameters, @Dysponent = @Dysponent output, @OpeId = @OpeId
INSERT INTO CDN.AutoPrzejazd (
AuP_AuEID,
AuP_RokMies,
AuP_Lp,
AuP_DataZap,
AuP_Dlugosc,
AuP_Miasto,
AuP_Stawka,
AuP_Cel,
AuP_Trasa,
AuP_PoczStanL,
AuP_KonStanL,
AuP_Potwierdzil,
AuP_OpeZalID,
AuP_OpeZalKod,
AuP_OpeZalNazwisko,
AuP_OpeModID,
AuP_OpeModKod,
AuP_OpeModNazwisko,
AuP_TS_Zal,
AuP_TS_Mod,
AuP_PrcNazwisko)
VALUES(
@SamId,
@RokMies,
@Lp,
@Data,
@LicznikKon - @LicznikPocz,
0,
@Stawka,
@Cel,
@Trasa,
@LicznikPocz,
@LicznikKon,
0,
@OpeId,
@OpeModKod,
@OpeModNazwisko,
@OpeId,
@OpeModKod,
@OpeModNazwisko,
GETDATE(),
GETDATE(),
@Dysponent)
if not exists (select * from SyncFramework.ConfirmationsTransits where ObjectId = @TransitId and UserCenterId = @UserCenterId)
INSERT INTO SyncFramework.ConfirmationsTransits
values(
@TransitId,
0,
DATEDIFF(s, convert(datetime,'1970-01-01',120),GETDATE()),
DATEDIFF(s, convert(datetime,'1970-01-01',120),GETDATE()),
@UserCenterId)
else
update SyncFramework.ConfirmationsTransits set UpdateTS = DATEDIFF(s, convert(datetime,'1970-01-01',120),GETDATE()) where ObjectId = @TransitId and UserCenterId = @UserCenterId
END
