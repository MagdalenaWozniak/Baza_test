CREATE FUNCTION CDN.OpisAnalitycznyDokumentuRowGuid(@konfiguracja1 varchar(64), @konfiguracja2 varchar(64), @dokumentNazwa1 varchar(64), @dokumentNazwa2 varchar(64))
RETURNS @Result TABLE(  Kwota decimal(15,4), Procent decimal(15,4), DokumentTyp int, DokumentId int, Guid nvarchar(255))
AS
BEGIN
 if @dokumentNazwa1 is not null or @dokumentNazwa2 is not null
 begin
  insert into @Result(Kwota, Procent, DokumentTyp, DokumentId, guid)
  SELECT WyW_Kwota, WyW_Procent, WyW_DokumentTyp, WyW_DokumentId, WyW_GUID from CDN.WymiaryWartosci
  where WyW_WyyId = 0 and WyW_DokumentTyp in (select id from CDN.ListaDokumentowWymiarowanych() where nazwa in (@dokumentNazwa1, @dokumentNazwa2))
 end
 else
 begin
  insert into @Result(Kwota, Procent, DokumentTyp, DokumentId, guid)
  SELECT WyW_Kwota, WyW_Procent, WyW_DokumentTyp, WyW_DokumentId, WyW_GUID from CDN.WymiaryWartosci
  where WyW_WyyId = 0 and WyW_DokumentTyp in (select id from CDN.ListaDokumentowWymiarowanych() where konfiguracja in (@konfiguracja1, @konfiguracja2))
 end
 return
END
