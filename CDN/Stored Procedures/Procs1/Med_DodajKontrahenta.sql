CREATE PROCEDURE CDN.Med_DodajKontrahenta
 @OptimaId int ,
 @Kod nvarchar(20) ,
 @EAN nvarchar(16) ,
 @Nazwa1 nvarchar(50) ,
 @Nazwa2 nvarchar(50) ,
 @Nazwa3 nvarchar(250) ,
 @Kraj nvarchar(40) ,
 @Wojewodztwo nvarchar(40) ,
 @Powiat nvarchar(40) ,
 @Gmina nvarchar(40) ,
 @Ulica nvarchar(40) ,
 @NrDomu nvarchar(10) ,
 @NrLokalu nvarchar(10) ,
 @Miasto nvarchar(40) ,
 @KodPocztowy nvarchar(10) ,
 @Poczta nvarchar(40) ,
 @Adres2 nvarchar(40) ,
 @NipKraj nvarchar(2) ,
 @NipE nvarchar(20) ,
 @Nip nvarchar(20) ,
 @Regon nvarchar(20) ,
 @Pesel nvarchar(11) ,
 @Telefon nvarchar(20),
 @Opis nvarchar(254),
 @OsobaOdbierajaca nvarchar(40),
 @OpeID int,
 @TS_Mod datetime,
 @KodGrupyKnt NVARCHAR(20)= '',
 @StanDetalID int = 0
AS
SET NOCOUNT ON
DECLARE
    @Knt_KntID      INT,
    @Ilosc          INT,
    @DKnt_DKntId    INT,
    @Domyslny       INT
    declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeID, @OpeModKod OUT, @OpeModNazwisko OUT
if @KodGrupyKnt ! = ''
begin
if not exists(select * from cdn.Grupy where Gru_Nazwa = @KodGrupyKnt)
 INSERT INTO [CDN].[Grupy]
           ([Gru_Typ]
           ,[Gru_Nazwa]
           ,[Gru_Opis]
           ,[Gru_Flaga])
     VALUES
           (31
           ,@KodGrupyKnt
           ,''
           ,NULL)
end
else
 select @KodGrupyKnt = ISNULL(DSta_KntGrupa,'') from CDN.DetalStanowiska where  DSta_DStaId = @StanDetalID
if @OptimaId = 0
 BEGIN
    if exists (SELECT   Knt_KntID    FROM CDN.Kontrahenci    WHERE Knt_Kod = @Kod)
    BEGIN
     RAISERROR( 'Taki symbol kontrahenta już istnieje', 16, 1)
     RETURN
    END
      -- dodajemy nowego
   INSERT INTO cdn.Kontrahenci
      (
        Knt_Kod,
        Knt_GLN,
        Knt_EAN,
        Knt_Grupa,
        Knt_Nazwa1,
        Knt_Nazwa2,
        Knt_Nazwa3,
        Knt_Kraj,
        Knt_Wojewodztwo,
        Knt_Powiat,
        Knt_Gmina,
        Knt_Ulica,
        Knt_NrDomu,
        Knt_NrLokalu,
        Knt_Miasto,
        Knt_KodPocztowy,
        Knt_Poczta,
        Knt_Adres2,
        Knt_NipKraj,
        Knt_NipE,
        Knt_Nip,
        Knt_Regon,
        Knt_Pesel,
        Knt_Telefon1,
        Knt_Telefon2,
        Knt_Fax,
        Knt_Email,
        Knt_URL,
        Knt_Zezwolenie,
        Knt_RachunekNr,
        Knt_IBAN,
        Knt_OsTytul,
        Knt_OsPlec,
        Knt_OsNazwisko,
        Knt_OsKraj,
        Knt_OsWojewodztwo,
        Knt_OsPowiat,
        Knt_OsGmina,
        Knt_OsUlica,
        Knt_OsNrDomu,
        Knt_OsNrLokalu,
        Knt_OsMiasto,
        Knt_OsKodPocztowy,
        Knt_OsPoczta,
        Knt_OsAdres2,
        Knt_OsTelefon,
        Knt_OsGSM,
        Knt_OsEmail,
        Knt_Informacje,
        Knt_Upust,
        Knt_LimitFlag,
        Knt_LimitKredytu,
        Knt_Ceny,
        Knt_FplId,
        Knt_MaxZwloka,
        Knt_TerminPlat,
        Knt_Termin,
        Knt_KontoOdb,
        Knt_KontoDost,
        Knt_BlokadaDok,
        Knt_LimitKredytuWal,
        Knt_LimitKredytuWykorzystany,
        Knt_NieRozliczac,
        Knt_PodatekVat,
        Knt_Finalny,
        Knt_Export,
        Knt_Rodzaj,
        Knt_Rodzaj_Dostawca,
        Knt_Rodzaj_Odbiorca,
        Knt_Rodzaj_Konkurencja,
        Knt_Rodzaj_Partner,
        Knt_Rodzaj_Potencjalny,
        Knt_Medialny,
        Knt_MalyPod,
        Knt_Nieaktywny,
        Knt_Chroniony,
        Knt_Opis,
        Knt_TS_Export,
        Knt_OpeZalID,
  Knt_OpeZalKod,
  Knt_OpeZalNazwisko,
        Knt_StaZalId,
        Knt_TS_Zal,
        Knt_OpeModID,
  Knt_OpeModKod,
  Knt_OpeModNazwisko,
        Knt_StaModId,
        Knt_TS_Mod,
        Knt_GIDTyp,
        Knt_GIDFirma,
        Knt_GIDNumer,
        Knt_GIDLp,
        Knt_KodTransakcji,
        Knt_TerminZwrotuKaucji,
        Knt_ZakazDokumentowHaMag,
        Knt_NaliczajPlatnosc,
        Knt_Rolnik,
        Knt_KrajISO,
        Knt_LimitPrzeterKredytFlag,
        Knt_LimitPrzeterKredytWartosc,
        Knt_ZgodaNaEFaktury,
        Knt_OpiekunKsiegDomyslny,
        Knt_OPiekunPikDomyslny
       )
      VALUES
      (
        @Kod,
        '',
        @EAN,
        @KodGrupyKnt,
        @Nazwa1,
        @Nazwa2,
        @Nazwa3,
        @Kraj,
        @Wojewodztwo,
        @Powiat,
        @Gmina,
        @Ulica,
        @NrDomu,
        @NrLokalu,
        @Miasto,
        @KodPocztowy,
        @Poczta,
        @Adres2,
        @NipKraj,
        @NipE,
        @Nip,
        @Regon,
        @Pesel,
        @Telefon,
        '',
        '',
        '',
        '',
        '',
        '',
        0,
        '',
        1,
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        '',
        '',
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        @Opis,
        NULL,
        @OpeID,
  @OpeModKod,
  @OpeModNazwisko,
        NULL,
        @TS_Mod,
        @OpeID,
  @OpeModKod,
  @OpeModNazwisko,
        NULL,
        @TS_Mod,
        '',
        1,
        0,
        '',
        '',
        60,
        0,
        0,
        0,
        '',
        0,
        0,
        0,
        1,
        0
       )
 select @Knt_KntID = Knt_KntID from CDN.Kontrahenci where Knt_Kod = @Kod
 IF @OsobaOdbierajaca != ''
   BEGIN
    INSERT INTO CDN.KntOsoby
           (KnO_KntId
           ,KnO_Tytul
           ,KnO_Plec
           ,KnO_Nazwisko
           ,KnO_Kraj
           ,KnO_Wojewodztwo
           ,KnO_Powiat
           ,KnO_Gmina
           ,KnO_Ulica
           ,KnO_NrDomu
           ,KnO_NrLokalu
           ,KnO_Miasto
           ,KnO_KodPocztowy
           ,KnO_Poczta
           ,KnO_Adres2
           ,KnO_Telefon
           ,KnO_GSM
           ,KnO_Email
           ,KnO_Informacje
           ,KnO_Domyslny)
     VALUES
           (@Knt_KntID
           ,''
           ,1
           ,@OsobaOdbierajaca
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,0
           ,1)
     END
 END
else
 BEGIN
    select @Knt_KntID = @OptimaId
    UPDATE cdn.Kontrahenci SET
        Knt_Kod = @Kod,
        Knt_EAN = @EAN,
        Knt_Nazwa1 = @Nazwa1,
        Knt_Nazwa2 = @Nazwa2,
        Knt_Nazwa3 = @Nazwa3,
        Knt_Kraj = @Kraj,
        Knt_Wojewodztwo = @Wojewodztwo,
        Knt_Powiat = @Powiat,
        Knt_Gmina = @Gmina,
        Knt_Ulica = @Ulica,
        Knt_NrDomu = @NrDomu,
        Knt_NrLokalu = @NrLokalu,
        Knt_Miasto = @Miasto,
        Knt_KodPocztowy = @KodPocztowy,
        Knt_Adres2 = @Adres2,
        Knt_NipKraj= @NipKraj,
        Knt_Opis = @Opis,
        Knt_Regon = @Regon,
        Knt_Pesel= @Pesel,
        Knt_Poczta = @Poczta,
        Knt_NipE = @NipE,
        Knt_Nip = @Nip,
        Knt_Telefon1 = @Telefon,
        Knt_TS_Mod = @TS_Mod,
        Knt_OpeModID  = @OpeID,
  Knt_OpeModKod  = @OpeModKod,
  Knt_OpeModNazwisko  = @OpeModNazwisko,
        Knt_Grupa = @KodGrupyKnt
      WHERE Knt_KntId = @OptimaId --and Knt_TS_Mod < @TS_Mod
   IF @OsobaOdbierajaca != ''
   BEGIN
    if not exists(select * from cdn.KntOsoby where KnO_Nazwisko = @OsobaOdbierajaca and KnO_KntId = @OptimaId)
    begin
       select @Ilosc = count(KnO_KntId) from cdn.KntOsoby where  KnO_KntId = @OptimaId
       INSERT INTO CDN.KntOsoby
           (KnO_KntId
           ,KnO_Tytul
           ,KnO_Plec
           ,KnO_Nazwisko
           ,KnO_Kraj
           ,KnO_Wojewodztwo
           ,KnO_Powiat
           ,KnO_Gmina
           ,KnO_Ulica
           ,KnO_NrDomu
           ,KnO_NrLokalu
           ,KnO_Miasto
           ,KnO_KodPocztowy
           ,KnO_Poczta
           ,KnO_Adres2
           ,KnO_Telefon
           ,KnO_GSM
           ,KnO_Email
           ,KnO_Informacje
           ,KnO_Domyslny)
       VALUES
           (@OptimaId
           ,''
           ,1
           ,@OsobaOdbierajaca
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,0
           ,case when @Ilosc>0 then 0 else 1 end)
       end
 END
 END
select  @Knt_KntID
  SET NOCOUNT OFF
