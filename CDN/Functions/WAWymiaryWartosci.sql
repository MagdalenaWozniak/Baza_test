CREATE FUNCTION CDN.WAWymiaryWartosci(@konfiguracja1 varchar(100), @konfiguracja2 varchar(100), @nazwa1 varchar(100), @nazwa2 varchar(100))
RETURNS @Result TABLE(
 WyWID int,
 WyyId int,
 SRCGUID nvarchar(255),
 GUID nvarchar(255),
 Wartosc nvarchar(255),
 DokumentTyp int,
 DokumentId int,
 KwotaPozycji DECIMAL(15,4),
 Procent DECIMAL(15,4),
 Kwota DECIMAL(15,4))
AS
BEGIN
 if @nazwa1 is not null or @nazwa2 is not null
  insert into @Result(WyWID,WyyId,SRCGUID,GUID,Wartosc,DokumentTyp,DokumentId,KwotaPozycji,Procent,Kwota)
  select WyW_WyWID,WyW_WyyId,WyW_SRCGUID,WyW_GUID,WyW_Wartosc,WyW_DokumentTyp,WyW_DokumentId,WyW_KwotaPozycji,WyW_Procent,WyW_Kwota
  from CDN.WymiaryWartosci where WyW_DokumentTyp in(select id from CDN.ListaDokumentowWymiarowanych() where nazwa in (@nazwa1, @nazwa2)) order by WyW_GUID;
 else
  insert into @Result(WyWID,WyyId,SRCGUID,GUID,Wartosc,DokumentTyp,DokumentId,KwotaPozycji,Procent,Kwota)
  select WyW_WyWID,WyW_WyyId,WyW_SRCGUID,WyW_GUID,WyW_Wartosc,WyW_DokumentTyp,WyW_DokumentId,WyW_KwotaPozycji,WyW_Procent,WyW_Kwota
  from CDN.WymiaryWartosci where WyW_DokumentTyp in(select id from CDN.ListaDokumentowWymiarowanych() where konfiguracja in (@konfiguracja1, @konfiguracja2)) order by WyW_GUID;
 update @Result set Kwota = 0 where WyyId = 0;
  --delete from @Result where CDN.WAKontoOpisuAnalitycznego(WyyId, 1, '') is null and CDN.WAKontoOpisuAnalitycznego(WyyId, 2, '') is null;
 return;
END
