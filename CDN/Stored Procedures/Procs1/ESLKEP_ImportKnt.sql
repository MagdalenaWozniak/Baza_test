CREATE PROCEDURE [CDN].[ESLKEP_ImportKnt]
  @KntIDEsklepChr                 nvarchar(11),
  @Knt_Nazwa1                     nvarchar(50),
  @Knt_Nazwa2                     nvarchar(50),
  @Knt_Nazwa3                     nvarchar(250),
  @Knt_Miasto                     nvarchar(40),
  @Knt_KodPocztowy                nvarchar(10),
  @Knt_Ulica                      nvarchar(40),
  @Knt_NipE                       nvarchar(20),
  @Knt_Email                      nvarchar(127),
  @KnT_Telefon                    nvarchar(20),
  @Knt_Wojewodztwo                nvarchar(40),
  @Knt_Kraj                       nvarchar(40),
  @Knt_RabatChr                   nvarchar(19),
  @Knt_NrDomu                     nvarchar(11),
  @Knt_NrLokalu                   nvarchar(11),
  @Knt_Pesel                      nvarchar(11),
  @Knt_FinalnyChr                 nvarchar(2),
  @Knt_ExportChr      nvarchar(2),
  @Knt_KodKraju                   nvarchar(5),
  @Knt_NipKraj                    nvarchar(5),
  @Knt_ESklepZrodlo      nvarchar(2),
  @Knt_OpeZalIDChr                nvarchar(11),
  @Knt_StaZalIdChr                nvarchar(11),
  @IDEsklepChr                    nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
  @Knt_KntId                      INT,
  @KntIDEsklep                    INT,
  @Knt_OpeZalID                   INT,
  @Knt_StaZalId                   INT,
  @Val1                           nvarchar(20),
  @Val2                           nvarchar(20),
  @Knt_Nip                        nvarchar(20),
  @NrCeny                         nvarchar(254),
  @NrCenyInt                      INT,
  @TypCeny        INT,
  @Knt_Kod                        nvarchar(20),
  @AAA                            nvarchar(20),
  @Knt_TS_Export                  DATETIME,
  @Komunikat                      nvarchar(254),
  @Knt_Rabat                      DECIMAL(15,2),
  @KntSprawdzNIP                  Tinyint,
  @KntSprawdzEMail                Tinyint,
  @KntGrupa                       nvarchar(20),
  @Knt_Finalny                    TinyInt,
  @Knt_Export                     TinyInt,
  @IDEsklep                       INT,
  @ESSID                          INT
  --jesli jeszcze nie ustawiane
  if @Knt_FinalnyChr = ''
 set @Knt_FinalnyChr = 0
  SELECT
    @KntIDEsklep           = CONVERT(INT,@KntIDEsklepChr),
    @IDEsklep              = CONVERT(INT,@IDEsklepChr),
    @Knt_OpeZalID          = CONVERT(INT,@Knt_OpeZalIDChr),
    @Knt_StaZalId          = CONVERT(INT,@Knt_StaZalIdChr),
    @Knt_Finalny           = CONVERT(TINYINT,@Knt_FinalnyChr),
 @Knt_Export            = CONVERT(TINYINT,@Knt_ExportChr),
    @Knt_Rabat = case when   @Knt_RabatChr = '' then 0 else CONVERT(DECIMAL(15,2),REPLACE(@Knt_RabatChr,',','.'))end,
    @Komunikat             = ''
-- nip
   set @Knt_Nip = @Knt_Nipe
   while  CHARINDEX('-', @Knt_Nip)!=0
      begin
            SET @Val1=substring(@Knt_Nip,0,CHARINDEX('-', @Knt_Nip))
            SET @Val2=substring(@Knt_Nip,CHARINDEX('-', @Knt_Nip)+1,20)
            SET @Knt_Nip = @Val1+@Val2
      end
 declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @Knt_OpeZalID, @OpeZalKod OUT, @OpeZalNazwisko OUT
--cena dla kontrahenta
select @ESSID = ESS_ESSID, @NrCenyInt =  ESS_NrCeny, @KntSprawdzNIP =  ESS_KntSprawdzNIP,@KntSprawdzEMail = ESS_KntSprawdzEMail ,@KntGrupa = ESS_KntGrupa from cdn.eSklepStanowiska where ESS_IdISklep = @IDEsklep
select @TypCeny = dfc_typ from cdn.defceny where DfC_Lp = @NrCenyInt
--  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1833) SELECT @NrCeny = 0 ELSE SELECT @NrCeny = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1833
--     SELECT @NrCenyInt = CONVERT(INT,@NrCeny)--sprawdzamy czy istnieje
  SELECT @Knt_KntId = ESK_KntOptimaID
    FROM Cdn.eSklepKntRelacje
    WHERE ESK_KnteSklepID =  @KntIDEsklep AND ESK_eSklepID = @ESSID
--tworzymy kod
  SET @Knt_Kod = 'ESKL_' +@IDEsklepChr+'_' + @KntIDEsklepChr
-- identyfikacja po NIP i Miasto
  IF @KntSprawdzNIP = 1 AND @KntSprawdzEMail = 0 AND @Knt_KntId IS NULL
  BEGIN
    SELECT TOP 1 @Knt_KntId = Knt_KntId
      FROM cdn.Kontrahenci
      WHERE Knt_Nip     = @Knt_Nip
        AND Knt_Nip  !=''
        AND (Knt_GidTyp IS NULL OR Knt_GidTyp<1)
  AND knt_nieaktywny = 0
        --AND Knt_eSklepID IS NULL
        ORDER BY Knt_KntId
   END
   IF @KntSprawdzEMail = 1 AND @KntSprawdzNIP = 0 AND @Knt_KntId IS NULL  --identyfikacja po emailu
   BEGIN
     SELECT TOP 1 @Knt_KntId = Knt_KntId
      FROM cdn.Kontrahenci
      WHERE Knt_Email = @Knt_Email
        AND Knt_Email  !=''
        AND (Knt_GidTyp IS NULL OR Knt_GidTyp<1)
  AND knt_nieaktywny = 0
       -- AND Knt_eSklepID IS NULL
        ORDER BY Knt_KntId
   END
   IF @KntSprawdzNIP = 1 AND @KntSprawdzEMail = 1 AND @Knt_KntId IS NULL
   BEGIN
    SELECT TOP 1 @Knt_KntId = Knt_KntId
      FROM cdn.Kontrahenci
      WHERE Knt_Nip     = @Knt_Nip
        AND Knt_Nip  !=''
        AND Knt_Email = @Knt_Email
        AND Knt_Email  !=''
        AND (Knt_GidTyp IS NULL OR Knt_GidTyp<1)
  AND knt_nieaktywny = 0
        --AND Knt_eSklepID IS NULL
        ORDER BY Knt_KntId
   END
  -- dodanie kontrahenta jesli nie został zidentyfikowany również po NIP-ie i mieście
  IF @Knt_KntId IS NULL
    BEGIN
      --  najpierw sprawdzenie, czy kod istnieje
      DECLARE @I INT
      SET @I=1
      WHILE @I < 1000
        BEGIN
            SET @I=@I+1
            IF EXISTS ( SELECT Knt_Kod FROM cdn.Kontrahenci WHERE Knt_Kod = @Knt_Kod )
               BEGIN
                   SET @Knt_Kod = REVERSE(@Knt_Kod)
                   IF(CHARINDEX('(', @Knt_Kod)!=0 AND substring(@Knt_Kod,1,1)=')')
                      BEGIN
                          SET @Val1=substring(@Knt_Kod,2,CHARINDEX('(', @Knt_Kod)-2)
                          SET @Val2=substring(@Knt_Kod,CHARINDEX('(', @Knt_Kod)+1,20)
                          SET @AAA = REVERSE(@Val1) +2;
                          SET @Val2 = REVERSE(@Val2)
                          SET @Knt_Kod=SUBSTRING(@Val2,1,20-LEN(@AAA)-2)+'('+CONVERT(nvarchar(3),@AAA)+')'
                      END
               ELSE
                      BEGIN
                          SET @Knt_Kod = REVERSE(@Knt_Kod)
                          SET @Knt_Kod = substring(@Knt_Kod,1,17)+'(2)'
                      END
               SET @Knt_TS_Export = NULL
        END
      ELSE
        BEGIN
            SET @Knt_TS_Export = GETDATE()
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
        Knt_eSklepId,
  Knt_eSklepZrodlo,
        Knt_OpiekunKsiegDomyslny,
        Knt_OPiekunPikDomyslny,
  Knt_esklep,
  Knt_Algorytm
       )
      VALUES
      (
        @Knt_Kod,
        '',
        '',
        @KntGrupa,
        @Knt_Nazwa1,
        @Knt_Nazwa2,
        @Knt_Nazwa3,
        @Knt_Kraj,
        @Knt_Wojewodztwo,
        '',
        '',
        @Knt_Ulica,
        @Knt_NrDomu,
        @Knt_NrLokalu,
        @Knt_Miasto,
        @Knt_KodPocztowy,
        @Knt_Miasto,
        '',
        @Knt_NipKraj,
        @Knt_NipE,
        @Knt_Nip,
        '',
        @Knt_Pesel,
        @KnT_Telefon,
        '',
        '',
        @Knt_Email,
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
        @NrCenyInt,
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
        case when @Knt_Finalny = 1 then 0 else 1 end,
        case when @Knt_Export = 3 then 1 else case when @Knt_Export = 2 then 3 else 0 end end ,
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
        @Knt_TS_Export,
        @Knt_OpeZalID,
  @OpeZalKod,
  @OpeZalNazwisko,
        @Knt_StaZalId,
        GETDATE(),
        @Knt_OpeZalID,
  @OpeZalKod,
  @OpeZalNazwisko,
        @Knt_StaZalId,
        GETDATE(),
        '',
        1,
        @KntIDEsklep,
        '',
        '',
        60,
        0,
        0,
        0,
        @Knt_Kraj,
        0,
        0,
        0,
        @ESSID,
  @Knt_ESklepZrodlo,
        1,
        0,
  1,
  case when @Knt_Finalny = 0 and  @TypCeny = 2 then 1 else 0 end
       )
    SELECT @Knt_KntId = Knt_KntId FROM Cdn.Kontrahenci WHERE Knt_Kod = @Knt_Kod
     EXEC [CDN].[RejestrOperacjiDodaj]
          @ObiektTyp  = 1103,
          @ObiektSubTyp = 0,
          @ObiektID  = @Knt_KntId,
          @ObiektNazwa = @Knt_Kod,
          @OperacjaTyp = 1,
          @Opis   = N'Import z e-Sklep'
 END
  -- update kontrahenta, jesli został zidentyfikowany i data z XML późniejsza, niź data w bazie
  ELSE
    BEGIN
        --  najpierw sprawdzenie, czy kod istnieje
         DECLARE @J INT
         SET @J=1
         WHILE @J < 1000
            BEGIN
             SET @J=@J+1
             IF EXISTS ( SELECT Knt_Kod FROM cdn.Kontrahenci WHERE Knt_Kod = @Knt_Kod and Knt_KntId != @Knt_KntId)
               BEGIN
                SET @Knt_Kod = REVERSE(@Knt_Kod)
                IF(CHARINDEX('(', @Knt_Kod)!=0 AND substring(@Knt_Kod,1,1)=')')
                 BEGIN
                  SET @Val1=substring(@Knt_Kod,2,CHARINDEX('(', @Knt_Kod)-2)
                  SET @Val2=substring(@Knt_Kod,CHARINDEX('(', @Knt_Kod)+1,20)
                  SET @AAA = REVERSE(@Val1) +2;
                  SET @Val2 = REVERSE(@Val2)
                  SET @Knt_Kod=SUBSTRING(@Val2,1,20-LEN(@AAA)-2)+'('+CONVERT(nvarchar(3),@AAA)+')'
                 END
                ELSE
                 BEGIN
                  SET @Knt_Kod = REVERSE(@Knt_Kod)
                  SET @Knt_Kod = substring(@Knt_Kod,1,17)+'(2)'
                 END
                SET @Knt_TS_Export = NULL
               END
             ELSE
               BEGIN
                SET @Knt_TS_Export = GETDATE()
                BREAK
               END
           END
        UPDATE cdn.Kontrahenci SET
        --Knt_Kod                      = @Knt_Kod,
        Knt_Nazwa1                   = @Knt_Nazwa1,
        Knt_Nazwa2                   = @Knt_Nazwa2,
        Knt_Nazwa3                   = @Knt_Nazwa3,
        Knt_Wojewodztwo              = @Knt_Wojewodztwo,
        Knt_Kraj                     = @Knt_Kraj,
  Knt_KrajISO                  = @Knt_Kraj,
        Knt_Ulica                    = @Knt_Ulica,
        Knt_NrDomu                   = @Knt_NrDomu,
        Knt_NrLokalu                 = @Knt_NrLokalu,
        Knt_Miasto                   = @Knt_Miasto,
        Knt_KodPocztowy              = @Knt_KodPocztowy,
        Knt_Poczta                   = @Knt_Miasto,
        Knt_NipE                     = @Knt_NipE,
        Knt_Nip                      = @Knt_Nip,
  Knt_NipKraj                  = @Knt_NipKraj,
        Knt_Telefon1                 = @Knt_Telefon,
        Knt_Email                    = @Knt_Email,
        --Knt_Ceny                     = @NrCenyInt,
        Knt_Pesel                    = @Knt_Pesel,
        Knt_Finalny                  = case when @Knt_Finalny = 1 then 0 else 1 end,
  Knt_Export                   = case when @Knt_Export = 3 then 1 else case when @Knt_Export = 2 then 3 else 0 end end ,
        Knt_TS_Export                = @Knt_TS_Export,
        Knt_OpeModID                 = @Knt_OpeZalID,
  Knt_OpeModKod                = @OpeZalKod,
  Knt_OpeModNazwisko           = @OpeZalNazwisko,
        Knt_StaModId                 = @Knt_StaZalID,
        Knt_TS_Mod                   = GETDATE(),
        Knt_GidNumer                 = @KntIDEsklep,
        Knt_GidFirma                 = 1,
        Knt_eSklepId                 = @ESSID,
  Knt_eSklepZrodlo             = @Knt_eSklepZrodlo,
  Knt_eSklep      = 1
      WHERE Knt_KntId = @Knt_KntId
       SELECT @Knt_Kod = Knt_kod FROM Cdn.Kontrahenci WHERE Knt_KntId = @Knt_KntId
     EXEC [CDN].[RejestrOperacjiDodaj]
          @ObiektTyp  = 1103,
          @ObiektSubTyp = 0,
          @ObiektID  = @Knt_KntId,
          @ObiektNazwa = @Knt_Kod,
          @OperacjaTyp = 2,
          @Opis   = N'Import z e-Sklep'
END
if @knt_kntid is null
SELECT @Knt_KntId = Knt_KntId FROM Cdn.Kontrahenci WHERE Knt_Kod = @Knt_Kod
if not exists(select * from cdn.KntESklepy where KES_eSklepID = @ESSID and KES_KntID = @Knt_KntId) and ISNULL(@ESSID,0)> 0 and ISNULL(@Knt_KntId,0)>0
insert into cdn.KntESklepy(KES_eSklepID,KES_KntID) values(@ESSID,@Knt_KntId)
  SET NOCOUNT OFF
