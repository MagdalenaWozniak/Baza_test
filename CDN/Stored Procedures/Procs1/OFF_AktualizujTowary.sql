CREATE  PROCEDURE CDN.OFF_AktualizujTowary
      @Twr_GIDNumerChr       nvarchar(11),
      @Twr_Nazwa             nvarchar(254),
      @Twr_Kod               nvarchar(50),
      @Twr_Opis              nvarchar(1024),
      @Twr_EAN               nvarchar(40),
      @Twr_JM                nvarchar(20),
      @Twr_StawkaChr         nvarchar(11),
      @Twr_FlagaChr          nvarchar(5),
      @Twr_StawkaZakChr      nvarchar(11),
      @Twr_FlagaZakChr       nvarchar(5),
      @Twr_BezRabatuChr      nvarchar(2),
      @Twr_MarzaMinChr       nvarchar(11),
      @Twr_TwCNumerChr       nvarchar(11),
      @Twr_SWW               nvarchar(20),
      @Twr_IloscMinChr       nvarchar(21),
      @Twr_IloscMaxChr       nvarchar(21),
      @Twr_IloscZamChr       nvarchar(21),
      @Twr_URL               nvarchar(254),
      @Twr_NumerKat          nvarchar(40),
      @Twr_EdycjaNazwyChr    nvarchar(2),
      @nie_potrzebneChr      nvarchar(11),
      @Twr_JMCalkowiteChr    nvarchar(2),
      @Twr_TypChr            nvarchar(2),      --UslugaTowar(UF)
      @Twr_NieAktywnyChr     nvarchar(2),
      @Twr_KosztUslugiChr    nvarchar(19),
      @Twr_KosztUslugiTypChr nvarchar(2),
      @Twr_TS_XL             nvarchar(30),
      @Twr_SONIdChr          nvarchar(11),
      @Twr_KaucjaChr         nvarchar(2),
      @Twr_TwGGIDNumerChr    nvarchar(11),--
      @KasujUpustyChr        nvarchar(2),
      @Twr_OpeZalIdChr       nvarchar(11),
      @Twr_StaZalIdChr       nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
    @Twr_TwrId INT,
    @Twr_KosztUslugiWal      DECIMAL(15,2),
    @Twr_OpeModID            INT,
    @Twr_StaModId            INT,
    @Twr_GIDFirma            INT,
    @Twr_GIDNumer            INT,
    @Twr_GIDLp               SMALLINT,
    @Twr_GIDTyp              SMALLINT,
    @Twr_Stawka              DECIMAL(5,2),
    @Twr_Flaga               SMALLINT,
    @Twr_FlagaZm             SMALLINT,
    @Twr_StawkaZak           DECIMAL(5,2),
    @Twr_FlagaZak            SMALLINT,
    @Twr_FlagaZakZm          SMALLINT,
    @Twr_BezRabatu           TINYINT,
    @Twr_Upust               TINYINT,
    @Twr_Prog                TINYINT,
    @Twr_UpustData           TINYINT,
    @Twr_UpustDataOd         INT,
    @Twr_UpustDataDo         INT,
    @Twr_UpustGodz           TINYINT,
    @Twr_UpustGodzOd         INT,
    @Twr_UpustGodzDo         INT,
    @Twr_MarzaMin            DECIMAL(5,2),
    @Twr_TwCNumer            INT,
    @Twr_IloscMin            DECIMAL(15,4),
    @Twr_IloscMax            DECIMAL(15,4),
    @Twr_IloscZam            DECIMAL(15,4),
    @Twr_EdycjaNazwy         TINYINT,
    @Twr_JMCalkowite         TINYINT,
    @Twr_Typ                 TINYINT,      --UslugaTowar(UF)
    @Twr_NieAktywny          TINYINT,
    @Twr_KosztUslugi         DECIMAL(15,2),
    @Twr_KosztUslugiTyp      TINYINT,
    @KasujUpusty             TINYINT,
    @Twr_OpeZalID            INT,
    @Twr_StaZalId            INT,
    @godzst                  nvarchar(2),
    @minst                   nvarchar(2),
    @secst                   nvarchar(2),
    @godz                    INT,
    @min                     INT,
    @sec                     INT,
    @reszta                  INT,
    @Twr_SONId               INT,
    @Twr_Kaucja              TINYINT,
    @Twr_TwGGIDNumer         INT,
    @Komunikat               nvarchar(255)
--zabezpieczenie przed tym jak idzie data 0
         if @Twr_TS_XL = '0-00-00 00:00:00' set @Twr_TS_XL = '1800-12-28 00:00:00'
SELECT
    @Twr_GIDFirma         =0,
    @Twr_GIDNumer         =CONVERT(INT,@Twr_GIDNumerChr),
    @Twr_GIDLp            =0,
    @Twr_GIDTyp           =16,
    @Twr_Stawka           =CONVERT(DECIMAL(5,2),@Twr_StawkaChr),
    @Twr_Flaga            =CONVERT(SMALLINT,@Twr_FlagaChr),
    @Twr_StawkaZak        =CONVERT(DECIMAL(5,2),@Twr_StawkaZakChr),
    @Twr_FlagaZak         =CONVERT(SMALLINT,@Twr_FlagaZakChr),
    @Twr_BezRabatu        =CONVERT(TINYINT,@Twr_BezRabatuChr),
    @Twr_Upust            =0,
    @Twr_Prog             =0,
    @Twr_UpustData        =0,
    @Twr_UpustGodz        =0,
    @Twr_MarzaMin         =CONVERT(DECIMAL(5,2),@Twr_MarzaMinChr),
    @Twr_TwCNumer         =CONVERT(INT,@Twr_TwCNumerChr),
    @Twr_IloscMin         =CONVERT(DECIMAL(15,4),@Twr_IloscMinChr),
    @Twr_IloscMax         =CONVERT(DECIMAL(15,4),@Twr_IloscMaxChr),
    @Twr_IloscZam         =CONVERT(DECIMAL(15,4),@Twr_IloscZamChr),
    @Twr_EdycjaNazwy      =CONVERT(TINYINT,@Twr_EdycjaNazwyChr),
    @Twr_JMCalkowite      =CONVERT(TINYINT,@Twr_JMCalkowiteChr),
    @Twr_Typ              =CONVERT(TINYINT,@Twr_TypChr),      --UslugaTowar(UF)
    @Twr_NieAktywny       =CONVERT(TINYINT,@Twr_NieAktywnyChr),
    @Twr_KosztUslugi      =CONVERT(DECIMAL(15,2),@Twr_KosztUslugiChr),
    @Twr_KosztUslugiTyp   =CONVERT(TINYINT,@Twr_KosztUslugiTypChr),
    @KasujUpusty          =CONVERT(TINYINT,@KasujUpustyChr),
    @Twr_OpeZalID         =CONVERT(INT,@Twr_OpeZalIDChr),
    @Twr_StaZalId         =CONVERT(INT,@Twr_StaZalIdChr),
    @Twr_SONId            =CONVERT(INT,@Twr_SONIdChr),
    @Twr_Kaucja           =CONVERT(TINYINT,@Twr_KaucjaChr),
    @Twr_TS_XL            = CONVERT(DATETIME, @Twr_TS_XL,    120 )
    if @Twr_TwGGIDNumerChr='' SET @Twr_TwGGIDNumer = 0
    else set @Twr_TwGGIDNumer =CONVERT(INT,@Twr_TwGGIDNumerChr)
      SET @Twr_KosztUslugiWal       = @Twr_KosztUslugi
      SET @Twr_OpeModID = @Twr_OpeZalID
      SET @Twr_StaModId = @Twr_StaZalId
      SET @Twr_TwCNumer =@Twr_TwCNumer + 1
      IF(@Twr_Typ=1 or @Twr_Typ=2) SET @Twr_Typ = 1
      ELSE SET @Twr_Typ = 0
      IF(@Twr_KosztUslugiTyp=1) SET @Twr_KosztUslugiTyp=2
      ELSE SET @Twr_KosztUslugiTyp = 1
      IF @Twr_Nazwa='' OR @Twr_Nazwa is Null SET @Twr_Nazwa=@Twr_Kod
      IF @Twr_GIDNumer = 0 SET  @Twr_Kaucja = 1
      IF (@Twr_Flaga = 0) SET @Twr_FlagaZm = 1
      IF (@Twr_Flaga =1) SET @Twr_FlagaZm = 2
      IF (@Twr_Flaga =2) SET @Twr_FlagaZm = 4
      SET @Twr_Flaga = @Twr_FlagaZm
      IF (@Twr_FlagaZak = 0) SET @Twr_FlagaZakZm = 1
      IF (@Twr_FlagaZak =1) SET @Twr_FlagaZakZm = 2
      IF (@Twr_FlagaZak =2) SET @Twr_FlagaZakZm = 4
      SET @Twr_FlagaZak = @Twr_FlagaZakZm
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @Twr_OpeModID, @OpeModKod OUT, @OpeModNazwisko OUT
  SELECT @Twr_TwrId = Twr_TwrId
    FROM cdn.Towary
    WHERE Twr_GIDNumer = @Twr_GIDNumer
  IF @Twr_TwrId IS NULL
    BEGIN
      INSERT INTO Cdn.Towary(
                        Twr_Typ,
                        Twr_Produkt,
                        Twr_Kod,
                        Twr_NumerKat,
                        Twr_SWW,
                        Twr_EAN,
                        Twr_Nazwa,
                        Twr_URL,
                        Twr_Kategoria,
                        Twr_KategoriaZak,
                        Twr_Opis,
                        Twr_EdycjaNazwy,
                        Twr_KopiujOpis,
                        Twr_EdycjaOpisu,
                        Twr_JM,
                        Twr_JMCalkowite,
                        Twr_TwCNumer,
                        Twr_UdostepniajWCenniku,
                        Twr_Waluta,
                        Twr_KursNumer,
                        Twr_KursL,
                        Twr_KursM,
                        Twr_KosztUslugiWal,
                        Twr_KosztUslugi,
                        Twr_KosztUslugiTyp,
                        Twr_KodDostawcy,
                        Twr_IloscMin,
                        Twr_IloscMinJM,
                        Twr_IloscMax,
                        Twr_IloscMaxJM,
                        Twr_IloscZam,
                        Twr_IloscZamJM,
                        Twr_Stawka,
                        Twr_Flaga,
                        Twr_Zrodlowa,
                        Twr_StawkaExport,
                        Twr_FlagaExport,
                        Twr_ZrodlowaExport,
                        Twr_StawkaZak,
                        Twr_FlagaZak,
                        Twr_ZrodlowaZak,
                        Twr_Prog,
                        Twr_Upust,
                        Twr_UpustData,
                        Twr_UpustGodz,
                        Twr_BezRabatu,
                        Twr_MarzaMin,
                        Twr_NieAktywny,
                        Twr_OpeZalID,
      Twr_OpeZalKod,
      Twr_OpeZalNazwisko,
                        Twr_StaZalId,
                        Twr_TS_Zal,
                        Twr_OpeModID,
      Twr_OpeModKod,
      Twr_OpeModNazwisko,
                        Twr_StaModId,
                        Twr_TS_Mod,
                        Twr_GIDTyp,
                        Twr_GIDFirma,
                        Twr_GIDNumer,
                        Twr_GIDLp,
                        Twr_Masa,
                        Twr_KrajPochodzenia,
                        Twr_JmPomPrzelicznikL,
                        Twr_JmPomPrzelicznikM,
                        Twr_TS_XL,
                        Twr_TypMinimum,
                        Twr_Mincenamarza,
                        Twr_SONId,
                        Twr_Kaucja,
                        Twr_TwGGIDNumer
                        )
            VALUES(     @Twr_Typ,
                        0,
                        @Twr_Kod,
                        @Twr_NumerKat,
                        @Twr_SWW,
                        @Twr_EAN,
                        @Twr_Nazwa,
                        @Twr_URL,
                        '',
                        '',
                        @Twr_Opis,
                        @Twr_EdycjaNazwy,
                        0,
                        0,
                        @Twr_JM,
                        @Twr_JMCalkowite,
                        @Twr_TwCNumer,
                        0,
                        '',
                        0,
                        1,
                        1,
                        @Twr_KosztUslugiWal,
                        @Twr_KosztUslugi,
                        @Twr_KosztUslugiTyp,
                        '',
                        @Twr_IloscMin,
                        @Twr_JM,
                        @Twr_IloscMax,
                        @Twr_JM,
                        @Twr_IloscZam,
                        @Twr_JM,
                        @Twr_Stawka,
                        @Twr_Flaga,
                        0,
                        0,
                        0,
                        0,
                        @Twr_StawkaZak,
                        @Twr_FlagaZak,
                        0,
                        @Twr_Prog,
                        @Twr_Upust,
                        @Twr_UpustData,
                        @Twr_UpustGodz,
                        @Twr_BezRabatu,
                        @Twr_MarzaMin,
                        @Twr_NieAktywny,
                        @Twr_OpeZalID,
      @OpeModKod,
      @OpeModNazwisko,
                        @Twr_StaZalId,
                        getdate(),
                        @Twr_OpeModID,
      @OpeModKod,
      @OpeModNazwisko,
                        @Twr_StaModId,
                        getdate(),
                        @Twr_GIDTyp,
                        @Twr_GIDFirma,
                        @Twr_GIDNumer,
                        @Twr_GIDLp,
                        0,
                        '',
                        1,
                        1,
                        @Twr_TS_XL,
                        0,
                        0,
                        @Twr_SONId,
                        @Twr_Kaucja,
                        @Twr_TwGGIDNumer
                        )
      SELECT @Twr_TwrId = Twr_TwrId FROM Cdn.Towary WHERE Twr_Kod = @Twr_Kod
     if  @Twr_EAN != ''
     INSERT INTO CDN.TwrEan
        (TwE_TwrID
        ,TwE_EAN
        ,TwE_Opis
        ,TwE_Domyslny
        ,TwE_JM)
     VALUES
        (@Twr_TwrId
        ,@Twr_EAN
        ,''
        ,1
        ,@Twr_JM)
    END
  ELSE
    BEGIN
       IF @Twr_TS_XL >= ( SELECT isnull(Twr_TS_XL,0) FROM Cdn.Towary WHERE Twr_TwrId = @Twr_TwrId)
        BEGIN
                  UPDATE Cdn.Towary SET
                        Twr_Typ = @Twr_Typ,
                        Twr_Kod = @Twr_Kod,
                        Twr_NumerKat = @Twr_NumerKat,
                        Twr_SWW = @Twr_SWW,
                        Twr_EAN = @Twr_EAN,
                        Twr_Nazwa = @Twr_Nazwa,
                        Twr_URL = @Twr_URL,
                        Twr_Opis = @Twr_Opis,
                        Twr_EdycjaNazwy = @Twr_EdycjaNazwy,
                        Twr_JM = @Twr_JM,
                        Twr_JMCalkowite = @Twr_JMCalkowite,
                        Twr_TwCNumer = @Twr_TwCNumer,
                        Twr_KosztUslugiWal = @Twr_KosztUslugiWal,
                        Twr_KosztUslugi = @Twr_KosztUslugi,
                        Twr_KosztUslugiTyp = @Twr_KosztUslugiTyp,
                        Twr_IloscMin = @Twr_IloscMin,
                        Twr_IloscMax = @Twr_IloscMax,
                        Twr_IloscZam = @Twr_IloscZam,
                        Twr_Stawka = @Twr_Stawka,
                        Twr_Flaga = @Twr_Flaga,
                        Twr_StawkaZak = @Twr_StawkaZak,
                        Twr_FlagaZak = @Twr_FlagaZak,
                        Twr_BezRabatu = @Twr_BezRabatu,
                        Twr_MarzaMin = @Twr_MarzaMin,
                        Twr_NieAktywny = @Twr_NieAktywny,
                        Twr_OpeZalID = @Twr_OpeZalID,
      Twr_OpeZalKod =@OpeModKod,
      Twr_OpeZalNazwisko =@OpeModNazwisko,
                        Twr_StaZalId = @Twr_StaZalId,
                        Twr_TS_Zal=getdate(),
                        Twr_OpeModID = @Twr_OpeModID,
      Twr_OpeModKod =@OpeModKod,
      Twr_OpeModNazwisko =@OpeModNazwisko,
                        Twr_StaModId = @Twr_StaModId,
                        Twr_TS_XL = @Twr_TS_XL,
                        Twr_TS_Mod=getdate(),
                        Twr_SONId=@Twr_SONId,
                        Twr_Kaucja=@Twr_Kaucja,
                        Twr_TwGGIDNumer=@Twr_TwGGIDNumer
                      WHERE Twr_GIDNumer = @Twr_GIDNumer
            -- kasujemy ceny bo przyja nowe
                      DELETE FROM Cdn.TwrCeny
                      WHERE Twc_TwrNumer = @Twr_GIDNumer
                        AND Twc_TwrLp>=0
      if  @Twr_EAN != ''
                     begin
                         if not exists (select * from cdn.TwrEan where @Twr_TwrId = TwE_TwrID)
       INSERT INTO CDN.TwrEan
          (TwE_TwrID
          ,TwE_EAN
          ,TwE_Opis
          ,TwE_Domyslny
          ,TwE_JM)
       VALUES
          (@Twr_TwrId
          ,@Twr_EAN
          ,''
          ,1
          ,@Twr_JM)
      else
      update CDN.TwrEan set TwE_EAN = @Twr_EAN,TwE_JM = @Twr_JM where TwE_TwrID = @Twr_TwrId
     end
     else
     delete  CDN.TwrEan where TwE_TwrID = @Twr_TwrId
         END
      END
  if exists(select TwG_TwGId from Cdn.TwrGrupy where TwG_GidTyp=-16 and TwG_GiDNumer=@Twr_TwGGIDNumer)
  if not exists(select TwG_TwGId from Cdn.TwrGrupy where TwG_GidTyp=16 and TwG_GiDNumer=@Twr_GidNumer and TwG_GrONumer=@Twr_TwGGIDNumer)
  BEGIN
    ALTER TABLE CDN.TwrGrupy ENABLE Trigger [TwrLinkiInsert]
    INSERT INTO CDN.TwrGrupy (TwG_GIDTyp, TwG_GIDFirma, TwG_GIDNumer, TwG_GIDLp, TwG_GrOTyp, TwG_GrOFIrma, TwG_GrONumer, TwG_GrOLp, TwG_Kod, TwG_Nazwa,TwG_CzasModyfikacji) SELECT 16,0,@Twr_GidNumer,0,-16,0,@Twr_TwGGIDNumer,0,@Twr_Kod, '',0
    ALTER TABLE CDN.TwrGrupy DISABLE Trigger [TwrLinkiInsert]
  END
  SET NOCOUNT OFF
