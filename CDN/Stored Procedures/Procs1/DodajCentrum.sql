--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure [CDN].[DodajCentrum] @_KIEROWNIKID int, @_ADRESWEZLA varchar(128), @_POZIOM int, @_LISC int, @_PARENTID int
as
set nocount on
 declare @PRAKOD varchar(128), @NEWCNTID int, @OSOBA varchar(128)
 select @PRAKOD = PRA_Kod from cdn.PracKod where PRA_PraId = @_KIEROWNIKID --pobranie akronimu
 select top 1 @OSOBA = PRE_Nazwisko + ' ' + PRE_Imie1 from CDN.PracEtaty where PRE_DataDo >= convert(datetime, '2999-12-31', 120) and PRE_PraId = @_KIEROWNIKID --pobranie nazwiska i imienia
 insert into cdn.Centra --tworzenie centrum na podstawie kierownika
 (
  CNT_Kod, CNT_Nazwa, CNT_ParentId, CNT_Nieaktywny, CNT_AdresWezla, CNT_Poziom, CNT_Lisc, CNT_AddMethod, CNT_ImpId, CNT_Last,
  CNT_OpeZalId, CNT_StaZalId, CNT_TS_Zal, CNT_OpeModId, CNT_StaModId, CNT_TS_Mod
 )
 values
 (
  @PRAKOD, @OSOBA, @_PARENTID, 0, @_ADRESWEZLA, @_POZIOM + 1, @_LISC, 0, 0, 0,
  1, 1, GETDATE(), 1, 1, GETDATE()
 )
 --select @PRAKOD, @OSOBA, @_PARENTID, 0, @_ADRESWEZLA, @_POZIOM + 1, @_LISC
 select @NEWCNTID = @@IDENTITY
 insert into cdn.CentraKierownicy --przypisanie kierownika do centrum
 (
  CNK_CntId, CNK_PraId, CNK_Rodzaj, CNK_Kod, CNK_OkresOd, CNK_OkresDo,
  CNK_OpeZalId, CNK_StaZalId, CNK_TS_Zal, CNK_OpeModId, CNK_StaModId, CNK_TS_Mod
 )
 values
 (
  @NEWCNTID, @_KIEROWNIKID, 0, '', CONVERT(datetime, '1900-01-01', 120), CONVERT(datetime, '2999-12-31', 120),
  1, 1, GETDATE(), 1, 1, GETDATE()
 )
 --dodanie kierownika do swojego centrum
 update cdn.PracEtaty set PRE_CntId = @NEWCNTID, PRE_AdresCentrum = @_ADRESWEZLA where PRE_PraId = @_KIEROWNIKID
 update cdn.Pracidx set PRI_CntId = @NEWCNTID, PRI_AdresCentrum = @_ADRESWEZLA where PRI_PraId = @_KIEROWNIKID
set nocount off
