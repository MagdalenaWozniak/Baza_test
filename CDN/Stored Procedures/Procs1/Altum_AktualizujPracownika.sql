create procedure cdn.Altum_AktualizujPracownika
 @PracSynchId nvarchar(36),  --PRA_ImportRowId --unikalny identyfikator pracownika (GUID)
 @Kod nvarchar(20),
 @Nazwisko nvarchar(40),
 @Imie nvarchar(30),
 @NIP nvarchar(13),
 @Pesel nvarchar(11),
 @URL nvarchar(255),
 @Opis nvarchar(1024),
 @Archiwalny tinyint,   --rezerwacja
 @MldKraj nvarchar(40), @MldWojewodztwo nvarchar(40), @MldUlica nvarchar(40), @MldNrDomu nvarchar(10), @MldNrLokalu nvarchar(10),
 @MldMiasto nvarchar(40), @MldKodPocztowy nvarchar(10), @MldPoczta nvarchar(40), @MldGmina nvarchar(40), @MldPowiat nvarchar(40),
 @ZamKraj nvarchar(40), @ZamWojewodztwo nvarchar(40), @ZamUlica nvarchar(40), @ZamNrDomu nvarchar(10), @ZamNrLokalu nvarchar(10),
 @ZamMiasto nvarchar(40), @ZamKodPocztowy nvarchar(10), @ZamPoczta nvarchar(40), @ZamGmina nvarchar(40), @ZamPowiat nvarchar(40),
 @KorKraj nvarchar(40), @KorWojewodztwo nvarchar(40), @KorUlica nvarchar(40), @KorNrDomu nvarchar(10), @KorNrLokalu nvarchar(10),
 @KorMiasto nvarchar(40), @KorKodPocztowy nvarchar(10), @KorPoczta nvarchar(40), @KorGmina nvarchar(40), @KorPowiat nvarchar(40),
 @Telefon1 nvarchar(20),
 @Telefon2 nvarchar(20),   --prywatny
 @Telefon3 nvarchar(20),   --służbowy
 @Fax nvarchar(20),
 @EMail nvarchar(127),
 @Throw nvarchar(256) output  --treść wyjątku
 as
 set nocount on
  set @Throw = ''
  declare @s nvarchar(128)
  declare @PraId int
  set @PraId = 0
  select @PraId = PRA_PraId from cdn.PracKod
   where PRA_ImportRowId = @PracSynchId
  if (select count(PRA_Kod) from cdn.PracKod
   where PRA_Kod = @Kod and PRA_PraId <> @PraId) > 0
  begin
   set @Throw = '##OPT24003##'
   return
  end
  if @PraId > 0
   begin try
    declare @DataUrodzenia datetime
    if (len(@Pesel) > 0) and (((select PRE_DataUr from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120)) is null) or ((select top 1 PRE_DataUr from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120)) = convert(datetime, '1899-12-30', 120)))
     set @DataUrodzenia = CDN.PobierzDateUrodzenia(@Pesel)
    else
     set @DataUrodzenia = (select top 1 PRE_DataUr from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
    update cdn.PracKod
     set PRA_Kod = @Kod where PRA_PraId = @PraId
    declare @OpeId int
    set @OpeId = cdn.GetAltumOperatorID()
    declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
    exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
    update cdn.PracEtaty
     set
      PRE_Kod = @Kod,
      PRE_Nazwisko = @Nazwisko,
      PRE_Imie1 = @Imie,
      PRE_NipE = @NIP,
      PRE_Pesel = @Pesel,
      PRE_HDKURL = @URL,
      PRE_HDKUwagi = @Opis,
      PRE_MLDKraj = cdn.DomyslnyKraj(@MldKraj),
      PRE_MLDWojewodztwo = @MldWojewodztwo,
      PRE_MLDUlica = @MldUlica,
      PRE_MLDNrDomu = @MldNrDomu,
      PRE_MLDNrLokalu = @MldNrLokalu,
      PRE_MLDMiasto = @MldMiasto,
      PRE_MLDKodPocztowy = @MldKodPocztowy,
      PRE_MLDPoczta = @MldPoczta,
      PRE_MLDGmina = @MldGmina,
      PRE_MLDPowiat = @MldPowiat,
      PRE_ZAMKraj = cdn.DomyslnyKraj(@ZamKraj),
      PRE_ZAMWojewodztwo = @ZamWojewodztwo,
      PRE_ZAMUlica = @ZamUlica,
      PRE_ZAMNrDomu = @ZamNrDomu,
      PRE_ZAMNrLokalu = @ZamNrLokalu,
      PRE_ZAMMiasto = @ZamMiasto,
      PRE_ZAMKodPocztowy = @ZamKodPocztowy,
      PRE_ZAMPoczta = @ZamPoczta,
      PRE_ZAMGmina = @ZamGmina,
      PRE_ZAMPowiat = @ZamPowiat,
      PRE_KORKraj = cdn.DomyslnyKraj(@KorKraj),
      PRE_KORWojewodztwo = @KorWojewodztwo,
      PRE_KORUlica = @KorUlica,
      PRE_KORNrDomu = @KorNrDomu,
      PRE_KORNrLokalu = @KorNrLokalu,
      PRE_KORMiasto = @KorMiasto,
      PRE_KORKodPocztowy = @KorKodPocztowy,
      PRE_KORPoczta = @KorPoczta,
      PRE_KORGmina = @KorGmina,
      PRE_KORPowiat = @KorPowiat,
      PRE_HDKTelefon1  = @Telefon1,
      PRE_HDKTelefon2 = @Telefon2,
      PRE_TelefonSMS = @Telefon3,
      PRE_HDKFax = @Fax,
      PRE_HDKEmail = @EMail,
      PRE_DataUr = @DataUrodzenia,
      PRE_OpeModId = @OpeId,
      PRE_OpeModKod = @OpeModKod,
      PRE_OpeModNazwisko = @OpeModNazwisko,
      PRE_TS_Mod = getdate()
     where
      PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120)
      --KO2014.2
      declare @arch int, @parentid int, @nadrzedny int
      select @arch = PRA_Archiwalny, @parentid = PRA_ParentId,
      @nadrzedny = PRA_Nadrzedny from cdn.PracKod where PRA_PraId = @PraId
      execute cdn.AktualizujPracIdx @PraId, @arch, @parentid, @nadrzedny
      --[logowanie]
      declare @obj_id int
      select @obj_id = PRE_PreId from CDN.PracEtaty where PRE_PRAId = @PraId
      declare @obj_name nvarchar(128)
      set @obj_name = '[' + @Kod + '] ' + @Imie + ' ' + @Nazwisko
      declare @oid int
      set @oid = cdn.GetAltumOperatorID()
      if @oid > 0
      begin
       exec CDN.RejestrOperacjiContextInfo @oid
       exec CDN.RejestrOperacjiDodaj 24000, 0, @obj_id, @obj_name, 2, ''
      end
   end try
   begin catch
    set @Throw = '##OPT34223##'
   end catch
  else
  begin
   set @Throw = '##OPT34219##%guid%=' + @PracSynchId +'##'
  end
 set nocount off
