CREATE PROCEDURE CDN.OFF_AktualizujKontrahenci
  @Knt_GIDNumerChr                nvarchar(11),
  @IDChr                          nvarchar(11),
  @Knt_TS_Mod                     nvarchar(30),
  @Knt_Kod                        nvarchar(20),
  @Knt_Nazwa1                     nvarchar(50),
  @Knt_Nazwa2                     nvarchar(50),
  @Knt_Nazwa3                     nvarchar(250),
  @Knt_NipE                       nvarchar(20),
  @Knt_KodPocztowy                nvarchar(40),
  @Knt_Wojewodztwo                nvarchar(40),
  @Knt_Ulica                      nvarchar(40),
  @Knt_Miasto                     nvarchar(40),
  @Knt_Telefon1                   nvarchar(20),
  @Knt_RabatChr                   nvarchar(19),
  @Knt_CenyChr                    nvarchar(5),
  @Knt_LimitKredytuWal            nvarchar(3),
  @Knt_LimitKredytuChr            nvarchar(19),
  @Knt_LimitKredytuWykorzystanyChr nvarchar(19),
  @Knt_FplIDXLChr                 nvarchar(11),
  @Knt_Regon                      nvarchar(20),
  @Knt_Telefon2                   nvarchar(20),
  @Knt_Fax                        nvarchar(20),
  @Knt_EAN                        nvarchar(16),
  @Knt_URL                        nvarchar(254),
  @Knt_Email                      nvarchar(40),
  @Knt_PodatekVatChr              nvarchar(2),
  @Knt_Adres2                     nvarchar(40),
  @Knt_RodzajChr                  nvarchar(2),
  @Knt_NieaktywnyChr              nvarchar(2),
  @Knt_TerminChr                  nvarchar(5),
  @Knt_GLN                        nvarchar(13),
  @Knt_NipKraj                    nvarchar(2),
  @Knt_FinalnyChr                 nvarchar(2),
  @Knt_NaliczajPlatnoscChr        nvarchar(2),
  @Knt_TerminZwrotuKaucjiChr      nvarchar(5),
  @Knt_Pesel                      nvarchar(11),
  @KasujUpustyChr                 nvarchar(3),       -- 1 - kasuj, 0 - zostaw
  @Knt_OpeZalIDChr                nvarchar(11),
  @Knt_StaZalIdChr                nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
  @Knt_GIDFirma                   INT,
  @Knt_GIDTyp                     SMALLINT,
  @Knt_GIDNumer                   INT,
  @Knt_GIDLp                      SMALLINT,
  @ID                             INT,
  @Knt_Rabat                      DECIMAL(15,2),
  @Knt_Ceny                       SMALLINT,
  @Knt_LimitKredytu               DECIMAL(15,2),
  @Knt_LimitKredytuWykorzystany   DECIMAL(15,2),
  @Knt_FplIDXL                    INT,
  @Knt_PodatekVat                 TINYINT,
  @Knt_Rodzaj                     TINYINT,
  @Knt_Finalny                    TINYINT,
  @Knt_Nieaktywny                 TINYINT,
  @Knt_Termin                     SMALLINT,
  @KasujUpusty                    TINYINT,       -- 1 - kasuj, 0 - zostaw
  @Knt_OpeZalID                   INT,
  @Knt_StaZalId                   INT,
  @Knt_KntId                      INT,
  @Knt_Kod_New                    nvarchar(3),
  @Komunikat                      nvarchar(254),
  @Knt_TS_Export                  DATETIME,
  @Val1                           nvarchar(20),
  @Val2                           nvarchar(20),
  @AAA                            nvarchar(20),
  @Knt_FplID                      INT,
  @Knt_Poczta                     nvarchar(40),
  @Knt_Nip                        nvarchar(20),
  @Knt_LimitFlag                  TINYINT,
  @Knt_TerminPlat                 TINYINT,
  @Knt_TS_Zal                     nvarchar(30),
  @Knt_OpeModID                   INT,
  @Knt_StaModId                   INT,
  @Knt_Rodzaj_Dostawca            TINYINT,
  @Knt_Rodzaj_Odbiorca            TINYINT,
  @Knt_NaliczajPlatnosc           TINYINT,
  @Knt_TerminZwrotuKaucji         SMALLINT
   if len(@Knt_NipE) > 13
  BEGIN
      --SET @Komunikat = @Knt_Kod +' -kontrahent z NIP powyżej 13 znaków.'
   SET @Komunikat = '##OPT34482##%%s1%%=' + @Knt_Kod+ '##'
      RAISERROR( @Komunikat, 16, 1)
      RETURN
    END
  SET @Knt_TS_Zal =  @Knt_TS_Mod
  IF(@Knt_LimitKredytuChr ='' OR @Knt_LimitKredytuChr IS NULL) SET @Knt_LimitKredytu = NULL
  ELSE SET @Knt_LimitKredytu = CONVERT(DECIMAL(15,2),REPLACE(@Knt_LimitKredytuChr,',','.'))
  IF(@Knt_LimitKredytuWal ='') SET @Knt_LimitKredytuWal = ''
  IF(@Knt_LimitKredytuWykorzystanyChr ='' OR @Knt_LimitKredytuWykorzystanyChr IS NULL ) SET @Knt_LimitKredytuWykorzystany = NULL
  ELSE SET @Knt_LimitKredytuWykorzystany    = CONVERT(DECIMAL(15,2),REPLACE(@Knt_LimitKredytuWykorzystanyChr,',','.'))
  SELECT
    @Knt_TS_Export         = CONVERT(DATETIME, @Knt_TS_Export, 120 ),
    @Knt_TS_Zal            = CONVERT(DATETIME, @Knt_TS_Zal,    120 ),
    @Knt_TS_Mod            = CONVERT(DATETIME, @Knt_TS_Mod,    120 ),
    @Knt_GIDFirma          = 0,
    @Knt_GIDTyp            = 32,
    @Knt_GIDNumer          = CONVERT(INT,@Knt_GIDNumerChr),
    @Knt_GIDLp             = 0,
    @Knt_Rabat             = CONVERT(DECIMAL(15,2),REPLACE(@Knt_RabatChr,',','.')),
    @Knt_Ceny              = CONVERT(SMALLINT,@Knt_CenyChr),
    @Knt_FplIDXL           = CONVERT(INT,@Knt_FplIDXLChr),
    @Knt_PodatekVat        = CONVERT(TINYINT,@Knt_PodatekVatChr),
    @Knt_Rodzaj            = CONVERT(TINYINT,@Knt_RodzajChr),
    @Knt_Finalny           = CONVERT(TINYINT,@Knt_FinalnyChr),
    @Knt_Nieaktywny        = CONVERT(TINYINT,@Knt_NieaktywnyChr),
    @Knt_Termin            = CONVERT(SMALLINT, @Knt_TerminChr),
    @KasujUpusty           = CONVERT(TINYINT,@KasujUpustyChr),      -- 1 - kasuj, 0 - zostaw
    @Knt_OpeZalID          = CONVERT(INT,@Knt_OpeZalIDChr),
    @Knt_StaZalId          = CONVERT(INT,@Knt_StaZalIdChr),
    @Knt_NaliczajPlatnosc  = CONVERT(TINYINT, @Knt_NaliczajPlatnoscChr),
    @Knt_TerminZwrotuKaucji= CONVERT(SMALLINT, @Knt_TerminZwrotuKaucjiChr),
    @Komunikat             = ''
  SET @Knt_Poczta =   @Knt_Miasto
-- nip
   set @Knt_Nip = @Knt_Nipe
   while  CHARINDEX('-', @Knt_Nip)!=0
      begin
            SET @Val1=substring(@Knt_Nip,0,CHARINDEX('-', @Knt_Nip))
            SET @Val2=substring(@Knt_Nip,CHARINDEX('-', @Knt_Nip)+1,20)
            SET @Knt_Nip = @Val1+@Val2
      end
--cena dla kontrahenta
  if (@Knt_Ceny != 0) SET @Knt_Ceny = @Knt_Ceny + 1
--IDOPER I IDSTANOW TAKIE SAME
  SET @Knt_OpeModID  = @Knt_OpeZalID
  SET @Knt_StaModId  = @Knt_StaZalId
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @Knt_OpeModID, @OpeModKod OUT, @OpeModNazwisko OUT
  IF(@Knt_Rodzaj=0) SELECT   @Knt_Rodzaj_Dostawca=0,@Knt_Rodzaj_Odbiorca=0
    ELSE IF(@Knt_Rodzaj=8) SELECT   @Knt_Rodzaj_Dostawca=1,@Knt_Rodzaj_Odbiorca=0
    ELSE IF(@Knt_Rodzaj=16) SELECT   @Knt_Rodzaj_Dostawca=0,@Knt_Rodzaj_Odbiorca=1
    ELSE SELECT    @Knt_Rodzaj_Dostawca=1,@Knt_Rodzaj_Odbiorca=1
  IF (@Knt_Termin =0) SET @Knt_TerminPlat= 0
  ELSE SET @Knt_TerminPlat = 1
  --ustawienie limitflag
  IF (@Knt_LimitKredytu = 0)      SET @Knt_LimitFlag = 0
  ELSE SET @Knt_LimitFlag = 1
  --ZAMIANA FORMY PLATNOSCI NA 0!
  SELECT @Knt_FplID = Fpl_FplId
   FROM Cdn.FormyPlatnosci
  WHERE Fpl_XlId = @Knt_FplIDXL
  -- identyfikacja po GID
  SELECT @Knt_KntId = Knt_KntId
    FROM Cdn.Kontrahenci
    WHERE Knt_GIDTyp   = @Knt_GIDTyp
      AND Knt_GIDNumer = @Knt_GIDNumer
  -- identyfikacja po NIP i Miasto
  IF @Knt_KntId IS NULL
    SELECT @Knt_KntId = Knt_KntId
      FROM cdn.Kontrahenci
      WHERE Knt_NipKraj = @Knt_NipKraj
        AND Knt_Nip     = @Knt_Nip
        AND Knt_MIasto  = @Knt_MIasto
        AND Knt_Nip  !=''
        AND Knt_Miasto  !=''
        AND (Knt_GidTyp IS NULL OR Knt_GidTyp<1)
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
        Knt_OpiekunKsiegDomyslny,
        Knt_OPiekunPikDomyslny
       )
      VALUES
      (
        @Knt_Kod,
        @Knt_GLN,
        @Knt_EAN,
        '',
        @Knt_Nazwa1,
        @Knt_Nazwa2,
        @Knt_Nazwa3,
        '',
        @Knt_Wojewodztwo,
        '',
        '',
        @Knt_Ulica,
        '',
        '',
        @Knt_Miasto,
        @Knt_KodPocztowy,
        @Knt_Poczta,
        @Knt_Adres2,
        @Knt_NipKraj,
        @Knt_NipE,
        @Knt_Nip,
        @Knt_Regon,
        @Knt_Pesel,
        @Knt_Telefon1,
        @Knt_Telefon2,
        @Knt_Fax,
        @Knt_Email,
        @Knt_URL,
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
        @Knt_LimitFlag,
        @Knt_LimitKredytu,
        @Knt_Ceny,
        @Knt_FplId,
        0,
        @Knt_TerminPlat,
        @Knt_Termin,
        '',
        '',
        0,
        @Knt_LimitKredytuWal,
        @Knt_LimitKredytuWykorzystany,
        0,
        @Knt_PodatekVat,
        @Knt_Finalny-1,
        0,
        0,
        @Knt_Rodzaj_Dostawca,
        @Knt_Rodzaj_Odbiorca,
        0,
        0,
        0,
        0,
        0,
        @Knt_Nieaktywny,
        0,
        '',
        @Knt_TS_Export,
        @Knt_OpeZalID,
  @OpeModKod,
  @OpeModNazwisko,
        @Knt_StaZalId,
        @Knt_TS_Zal,
        @Knt_OpeModID,
  @OpeModKod,
  @OpeModNazwisko,
        @Knt_StaModId,
        @Knt_TS_Mod,
        @Knt_GIDTyp,
        @Knt_GIDFirma,
        @Knt_GIDNumer,
        @Knt_GIDLp,
        '',
        @Knt_TerminZwrotuKaucji,
        @Knt_Nieaktywny,
        @Knt_NaliczajPlatnosc,
        0,
        '',
        0,
        0,
        0,
        1,
        0
       )
    --DODANIE RABATU DLA KONTRAHENTA
    IF @Knt_Rabat != 0
       BEGIN
           SELECT @Knt_KntId = Knt_KntId FROM Cdn.Kontrahenci WHERE Knt_GidNumer = @Knt_GIDNumer and Knt_GidTyp = @Knt_GIDTyp
           INSERT INTO CDN.RABATY(
                                  Rab_PodmiotId,
                                  Rab_PodmiotTyp,
                                  Rab_Rabat,
                                  Rab_Typ,
                                  Rab_Opis,
                                  Rab_Cena,
                                  Rab_TypCenyNB,
                                  Rab_Waluta
                                  )
                            VALUES
                                 (
                                  @Knt_KntId,
                                  1,
                                  @Knt_Rabat,
                                  2,
                                  '',
                                  0,
                                  1,
                                  ''
                                 )
     END
 END
  -- update kontrahenta, jesli został zidentyfikowany i data z XML późniejsza, niź data w bazie
  ELSE
    BEGIN
    IF @Knt_TS_Mod >= ( SELECT Knt_TS_Mod FROM cdn.Kontrahenci WHERE Knt_KntId = @Knt_KntId )
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
        Knt_Kod                      = @Knt_Kod,
        Knt_GLN                      = @Knt_GLN,
        Knt_EAN                      = @Knt_EAN,
        Knt_Nazwa1                   = @Knt_Nazwa1,
        Knt_Nazwa2                   = @Knt_Nazwa2,
        Knt_Nazwa3                   = @Knt_Nazwa3,
        Knt_Wojewodztwo              = @Knt_Wojewodztwo,
        Knt_Ulica                    = @Knt_Ulica,
        Knt_Miasto                   = @Knt_Miasto,
        Knt_KodPocztowy              = @Knt_KodPocztowy,
        Knt_Poczta                   = @Knt_Poczta,
        Knt_Adres2                   = @Knt_Adres2,
        Knt_NipKraj                  = @Knt_NipKraj,
        Knt_NipE                     = @Knt_NipE,
        Knt_Nip                      = @Knt_Nip,
        Knt_Regon                    = @Knt_Regon,
        Knt_Pesel                    = @Knt_Pesel,
        Knt_Telefon1                 = @Knt_Telefon1,
        Knt_Telefon2                 = @Knt_Telefon2,
        Knt_Fax                      = @Knt_Fax,
        Knt_Email                    = @Knt_Email,
        Knt_URL                      = @Knt_URL,
        Knt_LimitFlag                = @Knt_LimitFlag,
        Knt_LimitKredytu             = @Knt_LimitKredytu,
        Knt_Ceny                     = @Knt_Ceny,
        Knt_FplId                    = @Knt_FplId,
        Knt_TerminPlat               = @Knt_TerminPlat,
        Knt_Termin                   = @Knt_Termin,
        Knt_LimitKredytuWal          = @Knt_LimitKredytuWal,
        Knt_LimitKredytuWykorzystany = @Knt_LimitKredytuWykorzystany,
        Knt_PodatekVat               = @Knt_PodatekVat,
        Knt_Rodzaj                   = 0,
        Knt_Rodzaj_Dostawca          = @Knt_Rodzaj_Dostawca,
        Knt_Rodzaj_Odbiorca          = @Knt_Rodzaj_Odbiorca,
        Knt_Finalny                  = @Knt_Finalny-1,
        Knt_Nieaktywny               = @Knt_Nieaktywny,
        Knt_TS_Export                = @Knt_TS_Export,
        Knt_OpeZalID                 = @Knt_OpeZalID,
  Knt_OpeZalKod                = @OpeModKod,
  Knt_OpeZalNazwisko           = @OpeModNazwisko,
        Knt_StaZalId                 = @Knt_StaZalId,
        Knt_TS_Zal                   = @Knt_TS_Zal,
        Knt_OpeModID                 = @Knt_OpeModID,
  Knt_OpeModKod                 = @OpeModKod,
  Knt_OpeModNazwisko           = @OpeModNazwisko,
        Knt_StaModId                 = @Knt_StaModId,
        Knt_TS_Mod                   = @Knt_TS_Mod,
        Knt_TerminZwrotuKaucji       = @Knt_TerminZwrotuKaucji,
        Knt_NaliczajPlatnosc         = @Knt_NaliczajPlatnosc,
        Knt_ZakazDokumentowHaMag     = @Knt_Nieaktywny,
        Knt_GIDTyp                   = @Knt_GIDTyp,
        Knt_GIDFirma                 = 0,
        Knt_GIDNumer                 = @Knt_GIDNumer,
        Knt_GIDLp                    = @Knt_GIDLp
      WHERE Knt_KntId = @Knt_KntId
      --DODANIE RABATU DLA KONTRAHENTA
      IF @Knt_Rabat != 0
      IF EXISTS(SELECT Rab_PodmiotId FROM CDN.RABATY WHERE Rab_PodmiotId = @Knt_KntId)
       BEGIN
        UPDATE  CDN.RABATY SET  Rab_Rabat=@Knt_Rabat WHERE Rab_PodmiotId = @Knt_KntId
       END
      ELSE
       BEGIN
                 INSERT INTO CDN.RABATY(
                                        Rab_PodmiotId,
                                        Rab_PodmiotTyp,
                                        Rab_Rabat,
                                        Rab_Typ,
                                        Rab_Opis,
                                        Rab_Cena,
                                        Rab_TypCenyNB,
                                        Rab_Waluta
                                        )
                                  VALUES
                                        (
                                        @Knt_KntId,
                                        1,
                                        @Knt_Rabat,
                                        2,
                                        '',
                                        0,
                                        1,
                                        ''
                                        )
        END
      ELSE
  DELETE FROM CDN.Rabaty WHERE Rab_PodmiotId = @Knt_KntId AND Rab_PodmiotTyp = 1 AND Rab_Typ = 2
    END
END
  SET NOCOUNT OFF
