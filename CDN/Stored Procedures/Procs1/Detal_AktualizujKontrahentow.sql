CREATE PROCEDURE [CDN].[Detal_AktualizujKontrahentow]
 @DSKntId int ,
 @OptimaId int ,
 @StanDetalID int,
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
 @OptimaIdnew int output,
 @Kodnew nvarchar(20) output
AS
SET NOCOUNT ON
DECLARE
    @AAA            NVARCHAR(20),
    @Val1           NVARCHAR(20),
    @Val2           NVARCHAR(20),
    @Knt_KntID      INT,
    @Ilosc          INT,
    @DKnt_DKntId    INT,
    @Domyslny       INT,
    @fplId int
 declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeID, @OpeZalKod OUT, @OpeZalNazwisko OUT
    if Exists(select * from CDN.FormyPlatnosci WHERE FPl_FPlId = 1)
  SELECT @fplId = 1
 else
  if Exists(select dfpl_Fplid from CDN.detalformyplatnosci where dfpl_domyslna = 1)
   SELECT Top 1 @fplId = dfpl_Fplid From CDN.detalformyplatnosci where dfpl_domyslna = 1
        else
   SELECT Top 1 @fplId = dfpl_Fplid From CDN.detalformyplatnosci
  SELECT  @DKnt_DKntId = DKnt_DKntId, @OptimaID = DKnt_OptimaID
    FROM CDN.DetalKontrahenci
    WHERE DKnt_DSKntId = @DSKntId and DKnt_StanDetalID = @StanDetalID
  IF @DKnt_DKntId IS NULL
    BEGIN
       INSERT INTO CDN.DetalKontrahenci (
         DKnt_DSKntId,
        DKnt_OptimaId,
        DKnt_StanDetalID,
        DKnt_Kod,
        DKnt_EAN,
        DKnt_Nazwa1,
        DKnt_Nazwa2,
        DKnt_Nazwa3,
        DKnt_Kraj,
        DKnt_Wojewodztwo,
        DKnt_Powiat,
        DKnt_Gmina,
        DKnt_Ulica,
        DKnt_NrDomu,
        DKnt_NrLokalu,
        DKnt_Miasto,
        DKnt_KodPocztowy,
        DKnt_Poczta,
        DKnt_Adres2,
        DKnt_NipKraj,
        DKnt_NipE,
        DKnt_Nip,
        DKnt_Regon,
        DKnt_Pesel,
        DKnt_Telefon,
        DKnt_Opis,
        DKnt_OsobaOdbierajaca,
        DKnt_OpeID,
        DKnt_TS_Mod,
        DKnt_StanSynchronizacji
    )
  VALUES (
 @DSKntId,
 @OptimaId,
 @StanDetalID,
 @Kod,
 @EAN,
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
 @Opis,
 @OsobaOdbierajaca,
 @OpeID,
 @TS_Mod,
    1
         )
    END
  ELSE
 BEGIN
     UPDATE  CDN.DetalKontrahenci
   SET
 DKnt_DSKntId= @DSKntId ,
 DKnt_OptimaId= @OptimaId ,
 DKnt_Kod= @Kod ,
 DKnt_EAN= @EAN ,
 DKnt_Nazwa1= @Nazwa1 ,
 DKnt_Nazwa2= @Nazwa2 ,
 DKnt_Nazwa3= @Nazwa3 ,
 DKnt_Kraj= @Kraj ,
 DKnt_Wojewodztwo= @Wojewodztwo ,
 DKnt_Powiat= @Powiat ,
 DKnt_Gmina= @Gmina ,
 DKnt_Ulica= @Ulica ,
 DKnt_NrDomu= @NrDomu ,
 DKnt_NrLokalu= @NrLokalu ,
 DKnt_Miasto= @Miasto ,
 DKnt_KodPocztowy= @KodPocztowy ,
 DKnt_Poczta= @Poczta ,
 DKnt_Adres2= @Adres2 ,
 DKnt_NipKraj= @NipKraj ,
 DKnt_NipE= @NipE ,
 DKnt_Nip= @Nip ,
 DKnt_Regon= @Regon ,
 DKnt_Pesel= @Pesel ,
 DKnt_Telefon = @Telefon,
 DKnt_Opis = @Opis,
 DKnt_OsobaOdbierajaca = @OsobaOdbierajaca,
 DKnt_OpeID = @OpeID,
 DKnt_TS_Mod= @TS_Mod,
 DKnt_StanSynchronizacji = 1
  WHERE (@DKnt_DKntId = DKnt_DKntId) and DKnt_TS_Mod > @TS_Mod and DKnt_StanSynchronizacji = 1
      END
if @OptimaId = 0
 BEGIN
      --  najpierw sprawdzenie, czy kod istnieje
      DECLARE @I INT
      SET @I=1
      WHILE @I < 1000
        BEGIN
            SET @I=@I+1
            IF EXISTS ( SELECT Knt_Kod FROM cdn.Kontrahenci WHERE Knt_Kod = @Kod )
               BEGIN
                   SET @Kod = REVERSE(@Kod)
                   IF(CHARINDEX('(', @Kod)!=0 AND substring(@Kod,1,1)=')')
                      BEGIN
                          SET @Val1=substring(@Kod,2,CHARINDEX('(', @Kod)-2)
                          SET @Val2=substring(@Kod,CHARINDEX('(', @Kod)+1,20)
                          SET @AAA = REVERSE(@Val1) +2;
                          SET @Val2 = REVERSE(@Val2)
                          SET @Kod=SUBSTRING(@Val2,1,20-LEN(@AAA)-2)+'('+CONVERT(NVARCHAR(3),@AAA)+')'
                      END
               ELSE
                      BEGIN
                          SET @Kod = REVERSE(@Kod)
                          SET @Kod = substring(@Kod,1,17)+'(2)'
                      END
        END
      ELSE
        BEGIN
            BREAK
        END
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
        '',
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
        @fplId,
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
        '',
        NULL,
        @OpeID,
  @OpeZalKod,
  @OpeZalNazwisko,
        NULL,
        @TS_Mod,
        @OpeID,
  @OpeZalKod,
  @OpeZalNazwisko,
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
 update CDN.DetalKontrahenci SET DKnt_Kod = @Kod,DKnt_OptimaId = @Knt_KntID, DKnt_StanSynchronizacji = 2 WHERE  DKnt_DSKntId = @DSKntId and DKnt_StanDetalID = @StanDetalID
 select @OptimaIdnew = @Knt_KntID, @Kodnew = @Kod
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
    UPDATE cdn.Kontrahenci SET
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
        Knt_Poczta = @Poczta,
        Knt_NipE = @NipE,
        Knt_Nip = @Nip,
        Knt_Telefon1 = @Telefon,
        Knt_TS_Mod = @TS_Mod,
        Knt_OpeModID  = @OpeID,
  Knt_OpeModKod  = @OpeZalKod,
  Knt_OpeModNazwisko  = @OpeZalNazwisko
      WHERE Knt_KntId = @OptimaId and Knt_TS_Mod < @TS_Mod
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
 update CDN.DetalKontrahenci SET  DKnt_StanSynchronizacji = 2 WHERE  DKnt_DSKntId = @DSKntId and DKnt_StanDetalID = @StanDetalID
 END
  SET NOCOUNT OFF
