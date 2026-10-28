CREATE PROCEDURE CDN.InsPowiazDekretyZPreliminarzem
@DeEId     INT,
@KwotaSys       decimal(15, 2),
@KwotaRozSys    decimal(15, 2),
@Kwota          decimal(15, 2),
@KwotaRoz       decimal(15, 2),
@Waluta         NVARCHAR (3),
@KursNumer      int,
@KursL          decimal(15, 4),
@KursM          decimal(5, 0),
@KontoWn      NVARCHAR(50),
@KontoMa      NVARCHAR(50),
@DataDok  datetime,
@DataReal  datetime,
@FPlID   int,
@Dokument  NVARCHAR(30),
@KatID   int
AS
BEGIN
 DECLARE
  @BZdID        int,
  @RelTyp              smallint  ,
  @RelID               int  ,
  @PrwTyp              smallint  ,
  @PrwID               int  ,
  @BRaID               int  ,
  @DDfID               int  ,
  @DokumentTyp         smallint  ,
  @NumerPelny          NVARCHAR (30) ,
  @NumerObcy           NVARCHAR (30) ,
  @PodmiotTyp          smallint   ,
  @PodmiotID           int   ,
  @PodmiotRachunekLp   smallint   ,
  @BNaID               int  ,
  @RachunekNr          NVARCHAR (51) ,
  @IBAN                smallint   ,
--  @KatID               int  ,
  @Termin              datetime   ,
  @DataRoz       datetime,
  @Kierunek            smallint   ,
  @Zwloka              smallint   ,
  @Priorytet           smallint   ,
  @Rozliczono          smallint   ,
  @Rozliczono2         smallint   ,
  @Stan                smallint   ,
  @ElixirO1            NVARCHAR (35) ,
  @ElixirO2            NVARCHAR (35) ,
  @ElixirO3            NVARCHAR (35) ,
  @ElixirO4            NVARCHAR (35) ,
  @Opis                NVARCHAR (254) ,
  @KontoPrzeciwstawne  NVARCHAR (50) ,
  @OpeWysId            int  ,
  @TS_Wys              datetime  ,
  @OpePotwId           int  ,
  @TS_Potw             datetime  ,
  @TS_Export           datetime  ,
  @ImportAppId         NVARCHAR (5) ,
  @ImportRowId         NVARCHAR (36) ,
  @IdSynchro           int  ,
  @OpeZalId            int  ,
  @StaZalId            int  ,
  @TS_Zal              datetime   ,
  @OpeModId            int  ,
  @StaModId            int  ,
  @TS_Mod              datetime
  SET @RelTyp              = 0
  SET @RelID               = 0
  SET @PrwTyp              = 0
  SET @PrwID               = 0
--  SET @BRaID               = NULL
--  SET @DDfID               =
  SET @DokumentTyp         = 17
  SET @NumerPelny          = @Dokument
  SET @NumerObcy           = @Dokument
--  SET @PodmiotTyp          = 1
--  SET @PodmiotID           = 1
  SET @PodmiotRachunekLp   = 1
  SET @BNaID               = NULL
  SET @RachunekNr          = ''
  SET @IBAN                = ''
--  SET @KatID               = NULL
--  SET @FPlId               = NULL
  --SET @DataDok             =
  SET @Termin              = 5
  --SET @DataReal            =
  --SET @KwotaSys            =
  --SET @KwotaRozSys         =
  --SET @Kwota               =
  --SET @KwotaRoz            =
  --SET @Waluta              =
  --SET @KursNumer           =
  --SET @KursL               =
  --SET @KursM               =
--  SET @Kierunek            = 1
  SET @Zwloka              = 0
  SET @Priorytet           = 2
  SET @Rozliczono          = 1
  SET @Rozliczono2         = 1
  SET @Stan                = 1
  SET @ElixirO1            =''
  SET @ElixirO2            =''
  SET @ElixirO3            =''
  SET @ElixirO4            =''
  SET @Opis                =''
  SET @KontoPrzeciwstawne  =''
  --SET @OpeWysId            =NULL
  --SET @TS_Wys              =NULL
  --SET @OpePotwId           =NULL
  --SET @TS_Potw             =NULL
  --SET @TS_Export           =NULL
  --SET @ImportAppId         =NULL
  --SET @ImportRowId         =NULL
  --SET @IdSynchro           =NULL
  --SET @OpeZalId            =NULL
  --SET @StaZalId            =NULL
  SET @TS_Zal              = GETDATE ( )
  --SET @OpeModId            =NULL
  --SET @StaModId            =NULL
  SET @TS_Mod              = GETDATE ( )
  Select @BRaID = FPl_BRaId from CDN.FormyPlatnosci where FPl_FPlId=@FPlID
  IF  LEN(@KontoWn) > 0
   BEGIN
    if @Kwota > 0
     Begin
      SET @Kierunek = 1;
       Select @DDfID = IsNULL(Fir_Wartosc,5) from CDN.Firma where Fir_Numer = 1727
     End
    else
     Begin
      SET @Kierunek = -1;
       Select @DDfID = IsNULL(Fir_Wartosc,5) from CDN.Firma where Fir_Numer = 1730
     End
     Select  @PodmiotTyp = Acc_SlownikTyp,
        @PodmiotID  = Acc_SlownikId From CDN.Konta Where Acc_Numer = @KontoWn
    print '@Kierunek = ' + convert(NVARCHAR(10), @Kierunek)
   Insert Into CDN.BnkZdarzenia (
         BZd_RelTyp  ,
         BZd_RelID ,
         BZd_PrwTyp  ,
         BZd_PrwID ,
         BZd_BRaID ,
         BZd_DDfID ,
         BZd_DokumentTyp ,
         BZd_DokumentID  ,
         BZd_NumerPelny  ,
         BZd_NumerObcy ,
         BZd_PodmiotTyp  ,
         BZd_PodmiotID ,
         BZd_PodmiotRachunekLp ,
         BZd_BNaID ,
         BZd_RachunekNr  ,
         BZd_IBAN  ,
         BZd_KatID ,
         BZd_FPlId ,
         BZd_DataDok ,
         BZd_Termin  ,
         BZd_DataReal  ,
         BZd_KwotaSys  ,
         BZd_KwotaRozSys ,
         BZd_Kwota ,
         BZd_KwotaRoz  ,
         BZd_Waluta  ,
         BZd_KursNumer ,
         BZd_KursL ,
         BZd_KursM ,
         BZd_DataRoz ,
         BZd_Kierunek  ,
         BZd_Zwloka  ,
         BZd_Priorytet ,
         BZd_Rozliczono  ,
         BZd_Rozliczono2 ,
         BZd_Stan  ,
         BZd_ElixirO1  ,
         BZd_ElixirO2  ,
         BZd_ElixirO3  ,
         BZd_ElixirO4  ,
         BZd_Opis  ,
         BZd_KontoPrzeciwstawne,
--         BZd_OpeWysId  ,
--         BZd_TS_Wys  ,
--         BZd_OpePotwId ,
--         BZd_TS_Potw ,
--          BZd_TS_Export ,
--         BZd_ImportAppId ,
--         BZd_ImportRowId ,
--         BZd_IdSynchro ,
--         BZd_OpeZalId  ,
--         BZd_StaZalId  ,
         BZd_TS_Zal  ,
--         BZd_OpeModId  ,
--         BZd_StaModId  ,
           BZd_TS_Mod )
      Values (
         @RelTyp  ,
         @RelID ,
         @PrwTyp  ,
         @PrwID ,
         @BRaID ,
         @DDfID ,
         @DokumentTyp ,
         @DeEId  ,
         @NumerPelny  ,
         @NumerObcy ,
         @PodmiotTyp  ,
         @PodmiotID ,
         @PodmiotRachunekLp ,
         @BNaID ,
         @RachunekNr  ,
         @IBAN  ,
         @KatID ,
         @FPlID ,
         @DataDok ,
         @Termin  ,
         @DataReal  ,
         @KwotaSys  ,
         @KwotaRozSys ,
         @Kwota ,
         @KwotaRoz  ,
         @Waluta  ,
         @KursNumer ,
         @KursL ,
         @KursM ,
         @DataRoz ,
         @Kierunek  ,
         @Zwloka  ,
         @Priorytet ,
         @Rozliczono  ,
         @Rozliczono2 ,
         @Stan  ,
         @ElixirO1  ,
         @ElixirO2  ,
         @ElixirO3  ,
         @ElixirO4  ,
         @Opis  ,
         @KontoPrzeciwstawne,
--         @OpeWysId  ,
--         @TS_Wys  ,
--         @OpePotwId ,
--         @TS_Potw ,
--         @TS_Export ,
--         @ImportAppId ,
--         @ImportRowId ,
--         @IdSynchro ,
--         @OpeZalId  ,
--         @StaZalId  ,
         @TS_Zal  ,
--         @OpeModId  ,
--         @StaModId  ,
         @TS_Mod)
   END
  IF   LEN(@KontoMa) > 0
   BEGIN
    if @Kwota > 0
     Begin
      SET @Kierunek = -1;
        Select @DDfID = IsNULL(Fir_Wartosc,5) from CDN.Firma where Fir_Numer = 1730
     End
    else
     Begin
      SET @Kierunek = 1;
      Select @DDfID = IsNULL(Fir_Wartosc,5) from CDN.Firma where Fir_Numer = 1727
     End
     Select  @PodmiotTyp = Acc_SlownikTyp,
        @PodmiotID  = Acc_SlownikId From CDN.Konta Where Acc_Numer = @KontoMa
    print '@Kierunek = ' + convert(NVARCHAR(10), @Kierunek)
    Insert Into CDN.BnkZdarzenia (
         BZd_RelTyp  ,
         BZd_RelID ,
         BZd_PrwTyp  ,
         BZd_PrwID ,
         BZd_BRaID ,
         BZd_DDfID ,
         BZd_DokumentTyp ,
         BZd_DokumentID  ,
         BZd_NumerPelny  ,
         BZd_NumerObcy ,
         BZd_PodmiotTyp  ,
         BZd_PodmiotID ,
         BZd_PodmiotRachunekLp ,
         BZd_BNaID ,
         BZd_RachunekNr  ,
         BZd_IBAN  ,
         BZd_KatID ,
         BZd_FPlId ,
         BZd_DataDok ,
         BZd_Termin  ,
         BZd_DataReal  ,
         BZd_KwotaSys  ,
         BZd_KwotaRozSys ,
         BZd_Kwota ,
         BZd_KwotaRoz  ,
         BZd_Waluta  ,
         BZd_KursNumer ,
         BZd_KursL ,
         BZd_KursM ,
         BZd_DataRoz ,
         BZd_Kierunek  ,
         BZd_Zwloka  ,
         BZd_Priorytet ,
         BZd_Rozliczono  ,
         BZd_Rozliczono2 ,
         BZd_Stan  ,
         BZd_ElixirO1  ,
         BZd_ElixirO2  ,
         BZd_ElixirO3  ,
         BZd_ElixirO4  ,
         BZd_Opis  ,
         BZd_KontoPrzeciwstawne,
--         BZd_OpeWysId  ,
--         BZd_TS_Wys  ,
--         BZd_OpePotwId ,
--         BZd_TS_Potw ,
--          BZd_TS_Export ,
--         BZd_ImportAppId ,
--         BZd_ImportRowId ,
--         BZd_IdSynchro ,
--         BZd_OpeZalId  ,
--         BZd_StaZalId  ,
         BZd_TS_Zal  ,
--         BZd_OpeModId  ,
--         BZd_StaModId  ,
           BZd_TS_Mod )
      Values (
         @RelTyp  ,
         @RelID ,
         @PrwTyp  ,
         @PrwID ,
         @BRaID ,
         @DDfID ,
         @DokumentTyp ,
         @DeEId  ,
         @NumerPelny  ,
         @NumerObcy ,
         @PodmiotTyp  ,
         @PodmiotID ,
         @PodmiotRachunekLp ,
         @BNaID ,
         @RachunekNr  ,
         @IBAN  ,
         @KatID ,
         @FPlID ,
         @DataDok ,
         @Termin  ,
         @DataReal  ,
         @KwotaSys  ,
         @KwotaRozSys ,
         @Kwota ,
         @KwotaRoz  ,
         @Waluta  ,
         @KursNumer ,
         @KursL ,
         @KursM ,
         @DataRoz ,
         @Kierunek  ,
         @Zwloka  ,
         @Priorytet ,
         @Rozliczono  ,
         @Rozliczono2 ,
         @Stan  ,
         @ElixirO1  ,
         @ElixirO2  ,
         @ElixirO3  ,
         @ElixirO4  ,
         @Opis  ,
         @KontoPrzeciwstawne,
--         @OpeWysId  ,
--         @TS_Wys  ,
--         @OpePotwId ,
--         @TS_Potw ,
--         @TS_Export ,
--         @ImportAppId ,
--         @ImportRowId ,
--         @IdSynchro ,
--         @OpeZalId  ,
--         @StaZalId  ,
         @TS_Zal  ,
--         @OpeModId  ,
--         @StaModId  ,
         @TS_Mod)
   END
END
