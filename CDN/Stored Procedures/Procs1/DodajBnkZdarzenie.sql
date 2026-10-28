CREATE Procedure [CDN].[DodajBnkZdarzenie]
  @DokumentTyp        SmallInt,
  @DokumentID         Int,
  @NumerPelny         NVARCHAR(256),
  @NumerObcy          NVARCHAR(256),
  @PodmiotTyp         SmallInt,
  @PodmiotID          Int,
  @DDfID              Int,
  @Kierunek           SmallInt,
  @KatID              Int,
  @FPlId              Int,
  @DataDok            DateTime,
  @DataKur            DateTime,
  @KwotaSys           Decimal(15,2),
  @Kwota              Decimal(15,2),
  @Waluta             NVARCHAR(3),
  @KursNumer          Int,
  @KursL              Decimal(15,4),
  @KursM              Decimal(5,0),
  @Stan               SmallInt,
  @Opis               NVARCHAR(254),
  @OpeId              Int,
  @StaId              Int,
  @Termin             DateTime  = Null,
 @KontoPrzeciwstawne NVARCHAR(50) = Null
As
Begin
 Set NoCount On
 Declare
 @SPLID    Int,
 @BRaID    Int,
 @BNaID    Int,
 @ZrdBNaID    Int,
 @RachunekNr   NVARCHAR(51),
 @IBAN     SmallInt,
 @DataReal    DateTime,
 @Zwloka    SmallInt,
 @IleZdarzen   Int,
 @ElixirO1    NVARCHAR(35),
 @ElixirO2    NVARCHAR(35),
 @ElixirO3    NVARCHAR(35),
 @ElixirO4    NVARCHAR(35),
 @PrzelewSEPA   Int
 DECLARE @DokumentIDTable cdn.IdsTableType
 set @PrzelewSEPA = 0
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 If Exists (Select * From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId And BZd_Rozliczono2 > 1)
    Begin
  exec CDN.RiseOptimaException 32571
  Rollback Tran
  Set NoCount Off
  Return
    End
 If @Kwota = 0 And @KwotaSys = 0
 Begin
  If Exists (Select * From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId)
  Delete From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId
  Set NoCount Off
  Return
 End
 If @Kwota = 0 And @KwotaSys <> 0 Or @Kwota <> 0 And @KwotaSys = 0
 Begin
  exec CDN.RiseOptimaException 32572
  Rollback Tran
  Set NoCount Off
  Return
    End
 Select @IleZdarzen = Count(*) From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId
 If @IleZdarzen = 0
 Begin
  Declare @LastId Int
  Set @LastId = @@Identity
 End
 Else If @IleZdarzen = 1
 Begin
  Declare @BZdId Int
  Select Top 1 @BZdId = BZd_BZdId From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId
 End
 Else
 Begin
  Declare @KwotaSum Decimal(15,2), @KwotaSumSys Decimal(15,2), @WalutaSum NVARCHAR(3), @KierunekSum Int
  Select @KwotaSum = Sum(BZd_Kwota), @KwotaSumSys = Sum(BZd_KwotaSys), @WalutaSum = Max(BZd_Waluta), @KierunekSum = Max(BZd_Kierunek)
  From CDN.BnkZdarzenia Where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId
  If @KwotaSum <> @Kwota
  Begin
   Declare @Roznica NVARCHAR(15)
   Set @Roznica = LTrim(Str(@KwotaSum - @Kwota, 15, 2))
   exec CDN.RiseOptimaException 32573, 's1', @Roznica
   Rollback Tran
   Set NoCount Off
   Return
  End
  If @KwotaSumSys <> @KwotaSys Or @WalutaSum <> @Waluta Or @KierunekSum <> @Kierunek
  Begin
   exec CDN.RiseOptimaException 32574
   Rollback Tran
   Set NoCount Off
   Return
  End
 End
 If @IleZdarzen <= 1
 Begin
  If @Waluta <> ''
   Select @BRaId = FPW_BRaId From CDN.FormyPlatnWaluty Join CDN.BnkRachunki On BRa_BRaId = FPW_BRaId Where FPW_FPlId = @FPlId And BRa_Waluta = @Waluta
  If @BRaId Is Null
   Select @BRaId = FPl_BRaId From CDN.FormyPlatnosci Where FPl_FPlId = @FPlId
  If @BRaId Is Null
  Begin
   Declare @SrvName sysname, @DbName sysname, @FullDbName sysname, @SqlStm NVarChar(1000), @Kasa NVARCHAR(20)
   Select @SrvName = SYS_Wartosc From CDN.SystemCDN Where SYS_ID = 1001
   Select @DbName  = SYS_Wartosc From CDN.SystemCDN Where SYS_ID = 1002
   If @SrvName = @@ServerName
    Set @FullDbName = '[' + @DbName + ']'
   Else
    Set @FullDbName = '[' + @SrvName + '].[' + @DbName + ']'
   Create Table #Kasa (Symbol NVARCHAR(20))
   Set @SqlStm = N'Insert InTo #Kasa(Symbol) Select Ope_Kasa From ' + @FullDbName + '.[CDN].[Operatorzy] Where Ope_OpeId=' + Str(@OpeId)
   Execute sp_executesql @SqlStm
   Select @Kasa = Symbol From #Kasa Where Symbol <> ''
   Drop Table #Kasa
   Set @Kasa = IsNull(@Kasa, '')
   If @Kasa = ''
   Begin
    exec CDN.RiseOptimaException 32575
    Rollback Tran
    Set NoCount Off
    Return
   End
   Select @BRaId = BRa_BRaId From CDN.BnkRachunki Where BRa_Akronim = @Kasa
   If @BRaId Is Null
   Begin
    exec CDN.RiseOptimaException 32576, 's1', @Kasa
    Rollback Tran
    Set NoCount Off
    Return
   End
  End
  Select @ZrdBNaId = BRa_BNaId, @PrzelewSEPA = BRa_PrzelewySEPA From CDN.BnkRachunki Where BRa_BRaId = @BRaId
 End
 DECLARE @Bzd_WindykacjaSchematId INT
 If @PodmiotTyp = 1
 Begin
  Select Top 1
  @SPLID = SPL_SPLID,
  @BNaId = SPL_BNaId,
  @RachunekNr = SPL_RachunekNr,
  @IBAN = SPL_IBAN,
  @Zwloka = Knt_MaxZwloka,
  @KontoPrzeciwstawne = IsNull(@KontoPrzeciwstawne, Case @Kierunek When 1 Then Knt_KontoOdb Else Knt_KontoDost End),
  @Bzd_WindykacjaSchematId = Knt_WindykacjaSchematId
  From CDN.Kontrahenci Join CDN.SchematPlatnosci On (SPL_PodmiotTyp = @PodmiotTyp and SPL_PodmiotId = Knt_KntID)
  Where Knt_KntId = @PodmiotId Order By SPL_LiczbaPorz
 End
 Else If @PodmiotTyp = 3
 Begin
  Select Top 1
  @SPLID = SPL_SPLID,
  @BNaId = SPL_BNaId,
  @RachunekNr = SPL_RachunekNr,
  @IBAN = SPL_IBAN,
  @Zwloka = 0,
  @KontoPrzeciwstawne = ''
  From CDN.PracEtaty
  Join CDN.SchematPlatnosci On (SPL_PodmiotTyp = @PodmiotTyp and SPL_PodmiotId = PRE_PREId)
  Where PRE_PRAId = @PodmiotId And PRE_DataDo = Convert(DateTime, '2999-12-31', 120)
    Order By SPL_LiczbaPorz
 End
 Else If @PodmiotTyp = 5
 Begin
    Select top 1
    @BNaId = URa_BNaId,
    @RachunekNr = URa_RachunekNr,
    @IBAN = URa_IBAN,
    @Zwloka = 0,
    @KontoPrzeciwstawne = ''
    From CDN.Urzrachunki
    LEFT OUTER JOIN CDN.Urzedy ON URa_UrzId = Urz_UrzId
    Where URa_UrzId = @PodmiotId AND URa_Lp >= 0
    and Urz_TypUrzedu = 2  and URa_Lp = 3
    Select
    @BNaId = URa_BNaId,
    @RachunekNr = URa_RachunekNr,
    @IBAN = URa_IBAN,
    @Zwloka = 0,
    @KontoPrzeciwstawne = ''
    From CDN.Urzrachunki
    LEFT OUTER JOIN CDN.Urzedy ON URa_UrzId = Urz_UrzId
    Where URa_UrzId = @PodmiotId AND URa_Lp >= 0
    and Urz_TypUrzedu  >= 3
 End
 Set @RachunekNr = IsNull(@RachunekNr, '')
 Set @IBAN = IsNull(@IBAN, 1)
 Set @Zwloka = IsNull(@Zwloka, 0)
 Set @KontoPrzeciwstawne = IsNull(@KontoPrzeciwstawne, '')
 If @Termin Is Null
  Select @Termin = DateAdd(day, FPl_Termin, @DataDok) From CDN.FormyPlatnosci Where FPl_FPlId = @FplId
 If @Kierunek = 1
 Begin
  Select @DataReal = DateAdd(day, @Zwloka-BNa_CzasRealizacji, @Termin) From CDN.BnkNazwy Where BNa_BNaId = IsNull(@ZrdBNaId, 1)
  If Cast(@DataReal As Int)%7 = 6 Set @DataReal = DateAdd(day, 1, @DataReal)
  If Cast(@DataReal As Int)%7 = 5 Set @DataReal = DateAdd(day, 2, @DataReal)
 End
 Else
 Begin
  Select @DataReal = DateAdd(day, @Zwloka+BNa_CzasRealizacji, @Termin) From CDN.BnkNazwy Where BNa_BNaId = IsNull(@BNaId, 1)
  If Cast(@DataReal As Int)%7 = 6 Set @DataReal = DateAdd(day, -2, @DataReal)
  If Cast(@DataReal As Int)%7 = 5 Set @DataReal = DateAdd(day, -1, @DataReal)
 End
 DECLARE @UstawionoElixirO TINYINT
 SELECT @UstawionoElixirO = 0
 IF @KatID<>0
 BEGIN
  DECLARE @PodmiotKod VARCHAR(20)
  SELECT @PodmiotKod = Pod_Kod FROM cdn.PodmiotyView WHERE Pod_PodmiotTyp = @PodmiotTyp AND Pod_PodID = @PodmiotID
  DECLARE @KatElixirO1 VARCHAR(35)
  DECLARE @KatElixirO2 VARCHAR(35)
  DECLARE @KatElixirO3 VARCHAR(35)
  DECLARE @KatElixirO4 VARCHAR(35)
  DECLARE @KatOpis VARCHAR(50)
  SELECT @KatElixirO1 = Kat_ElixirO1, @KatElixirO2 = Kat_ElixirO2, @KatElixirO3 = Kat_ElixirO3, @KatElixirO4 = Kat_ElixirO4, @KatOpis = Kat_Opis
   FROM cdn.Kategorie WHERE Kat_KatID = @KatID
  DECLARE @NrDok NVARCHAR(256)
  SET @NrDok = @NumerObcy
  IF @NrDok = ''
   SET @NrDok = @NumerPelny
  IF @KatElixirO1<>''
  BEGIN
   SELECT @ElixirO1 = cdn.fn_RozwinMakraElixirO(@KatElixirO1, @DataDok, @NrDok, @DokumentTyp, @DokumentID, @PodmiotTyp, @PodmiotID, @PodmiotKod, 0, @KatOpis)
   IF @KatElixirO1 <> '@DokumentyRozliczające'
    SELECT @UstawionoElixirO = 1
  END
  IF @KatElixirO2<>''
  BEGIN
   SELECT @ElixirO2 = cdn.fn_RozwinMakraElixirO(@KatElixirO2, @DataDok, @NrDok, @DokumentTyp, @DokumentID, @PodmiotTyp, @PodmiotID, @PodmiotKod, 0, @KatOpis)
   IF @KatElixirO2 <> '@DokumentyRozliczające'
   SELECT @UstawionoElixirO = 1
  END
  IF @KatElixirO3<>''
  BEGIN
   SELECT @ElixirO3 = cdn.fn_RozwinMakraElixirO(@KatElixirO3, @DataDok, @NrDok, @DokumentTyp, @DokumentID, @PodmiotTyp, @PodmiotID, @PodmiotKod, 0, @KatOpis)
   IF @KatElixirO3 <> '@DokumentyRozliczające'
    SELECT @UstawionoElixirO = 1
  END
  IF @KatElixirO4<>''
  BEGIN
   SELECT @ElixirO4 = cdn.fn_RozwinMakraElixirO(@KatElixirO4, @DataDok, @NrDok, @DokumentTyp, @DokumentID, @PodmiotTyp, @PodmiotID, @PodmiotKod, 0, @KatOpis)
   IF @KatElixirO4 <> '@DokumentyRozliczające'
    SELECT @UstawionoElixirO = 1
  END
 END
 DECLARE @DomyslnyPoczatekOpisuDoBankuDlaPrzelewowZwyklych VARCHAR(255)
 SELECT @DomyslnyPoczatekOpisuDoBankuDlaPrzelewowZwyklych = Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 2172
 IF @UstawionoElixirO = 0
 BEGIN
  if @DokumentTyp in (27,28,1)
  begin
   IF @DomyslnyPoczatekOpisuDoBankuDlaPrzelewowZwyklych = ''
    Set @ElixirO1 = 'Zapłata za'
   ELSE
    Set @ElixirO1 = @DomyslnyPoczatekOpisuDoBankuDlaPrzelewowZwyklych
    Set @ElixirO2 = IsNull(@NumerPelny, '')
   end
  else if @DokumentTyp in (39,40)
  begin
   IF @DomyslnyPoczatekOpisuDoBankuDlaPrzelewowZwyklych = ''
    Set @ElixirO1 = 'Zapłata za'
  ELSE
   Set @ElixirO1 = @DomyslnyPoczatekOpisuDoBankuDlaPrzelewowZwyklych
   if IsNull(@NumerObcy, '') <> ''
   begin
    Set @ElixirO2 = IsNull(@NumerObcy, '')
   end
   else
   begin
    Set @ElixirO2 = IsNull(@NumerPelny, '')
   end
  end
  else
  begin
   Set @ElixirO1 = ''
   Set @ElixirO2 = ''
  end
  Set @ElixirO3 = ''
  Set @ElixirO4 = ''
 END
 IF @ElixirO1 Is Null
  SELECT @ElixirO1 = ''
 IF @ElixirO2 Is Null
  SELECT @ElixirO2 = ''
 IF @ElixirO3 Is Null
  SELECT @ElixirO3 = ''
 IF @ElixirO4 Is Null
  SELECT @ElixirO4 = ''
 If @IleZdarzen = 0
 Begin
  DECLARE @NieNaliczajOdsetek TINYINT
  SET @NieNaliczajOdsetek = 0
  IF @PodmiotTyp = 1
  SELECT @NieNaliczajOdsetek = IsNull(Knt_NieNaliczajOdsetek, 0) FROM cdn.Kontrahenci WHERE Knt_KntID = @PodmiotID
  Insert InTo CDN.BnkZdarzenia (
  BZd_RelTyp,
  BZd_RelID,
  BZd_PrwTyp,
  BZd_PrwID,
  BZd_BRaID,
  BZd_DDfID,
  BZd_DokumentTyp,
  BZd_DokumentID,
  BZd_NumerPelny,
  BZd_NumerObcy,
  BZd_PodmiotTyp,
  BZd_PodmiotID,
  BZd_PodmiotRachunekLp,
  BZd_BNaID,
  BZd_RachunekNr,
  BZd_IBAN,
  BZd_KatID,
  BZd_FPlId,
  BZd_DataDok,
  BZd_DataKur,
  BZd_Termin,
  BZd_DataReal,
  BZd_KwotaSys,
  BZd_KwotaRozSys,
  BZd_Kwota,
  BZd_KwotaRoz,
  BZd_Waluta,
  BZd_KursNumer,
  BZd_KursL,
  BZd_KursM,
  BZd_Kierunek,
  BZd_Zwloka,
  BZd_Priorytet,
  BZd_Rozliczono,
  BZd_Rozliczono2,
  BZd_Stan,
  BZd_ElixirO1,
  BZd_ElixirO2,
  BZd_ElixirO3,
  BZd_ElixirO4,
  BZd_Opis,
  BZd_KontoPrzeciwstawne,
  BZd_ImportAppId,
  BZd_ImportRowId,
  BZd_OpeZalId,
  BZd_OpeZalKod,
  BZd_OpeZalNazwisko,
  BZd_StaZalId,
  BZd_TS_Zal,
  BZd_StaModId,
  BZd_OpeModId,
  BZd_OpeModKod,
  BZd_OpeModNazwisko,
  BZd_TS_Mod,
  BZd_WalutaDok,
  BZd_NieNaliczajOdsetek,
  BZd_PrzelewSEPA,
  Bzd_WindykacjaSchematId
  )
  Values (
  0,
  0,
  @DokumentTyp,
  @DokumentID,
  @BRaID,
  @DDfID,
  @DokumentTyp,
  @DokumentID,
  @NumerPelny,
  @NumerObcy,
  @PodmiotTyp,
  @PodmiotID,
  Case @PodmiotTyp When 5 Then 0 Else IsNUll(@SPLID, 0) End,
  @BNaID,
  @RachunekNr,
  @IBAN,
  @KatID,
  @FPlId,
  @DataDok,
  @DataKur,
  @Termin,
  @DataReal,
  @KwotaSys,
  0,
  @Kwota,
  0,
  @Waluta,
  @KursNumer,
  @KursL,
  @KursM,
  @Kierunek,
  @Zwloka,
  2,
  1,
  1,
  @Stan,
  @ElixirO1,
  @ElixirO2,
  @ElixirO3,
  @ElixirO4,
  @Opis,
  @KontoPrzeciwstawne,
  '',
  NewId(),
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  @StaId,
  GetDate(),
  @StaId,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  GetDate(),
  @Waluta,
  @NieNaliczajOdsetek,
  @PrzelewSEPA,
  @Bzd_WindykacjaSchematId
  )
  DECLARE @MyIdentity Int = IsNull(IDENT_CURRENT('CDN.BnkZdarzenia'), 0);
  EXEC [CDN].[RejestrOperacjiDodaj]
         @ObiektTyp  = 1001,
         @ObiektSubTyp = @Kierunek,
         @ObiektID  = @MyIdentity,
         @ObiektNazwa = @NumerPelny,
         @OperacjaTyp = 1,
         @Opis   = ''
  IF EXISTS(SELECT * FROM cdn.BnkZdarzenia WHERE BZd_BZdID = @MyIdentity)
  BEGIN
   INSERT INTO @DokumentIDTable SELECT BZd_BZdID FROM cdn.BnkZdarzenia where BZd_BZdID = @MyIdentity AND CHARINDEX('@ZdarzenieID', BZd_ElixirO1) > 0
   INSERT INTO @DokumentIDTable SELECT BZd_BZdID FROM cdn.BnkZdarzenia where BZd_BZdID = @MyIdentity AND CHARINDEX('@ZdarzenieID', BZd_ElixirO2) > 0
   INSERT INTO @DokumentIDTable SELECT BZd_BZdID FROM cdn.BnkZdarzenia where BZd_BZdID = @MyIdentity AND CHARINDEX('@ZdarzenieID', BZd_ElixirO3) > 0
   INSERT INTO @DokumentIDTable SELECT BZd_BZdID FROM cdn.BnkZdarzenia where BZd_BZdID = @MyIdentity AND CHARINDEX('@ZdarzenieID', BZd_ElixirO4) > 0
   UPDATE cdn.BnkZdarzenia SET BZd_ElixirO1 = REPLACE(BZd_ElixirO1, '@ZdarzenieID', @MyIdentity) WHERE BZd_BZdID = @MyIdentity AND CHARINDEX('@ZdarzenieID', BZd_ElixirO1) > 0
   UPDATE cdn.BnkZdarzenia SET BZd_ElixirO2 = REPLACE(BZd_ElixirO2, '@ZdarzenieID', @MyIdentity) WHERE BZd_BZdID = @MyIdentity AND CHARINDEX('@ZdarzenieID', BZd_ElixirO2) > 0
   UPDATE cdn.BnkZdarzenia SET BZd_ElixirO3 = REPLACE(BZd_ElixirO3, '@ZdarzenieID', @MyIdentity) WHERE BZd_BZdID = @MyIdentity AND CHARINDEX('@ZdarzenieID', BZd_ElixirO3) > 0
   UPDATE cdn.BnkZdarzenia SET BZd_ElixirO4 = REPLACE(BZd_ElixirO4, '@ZdarzenieID', @MyIdentity) WHERE BZd_BZdID = @MyIdentity AND CHARINDEX('@ZdarzenieID', BZd_ElixirO4) > 0
  END
  If @LastId Is Not Null
  Begin
   Create Table #IdTmp ( Ident INT Identity )
   Set Identity_Insert #IdTmp On
   Insert InTo #IdTmp (Ident) Values (@LastId)
   Set Identity_Insert #IdTmp Off
   Drop Table #IdTmp
  End
 End
 Else If @IleZdarzen = 1
 Begin
  Update CDN.BnkZdarzenia Set
   BZd_BRaID              = @BRaID,
   BZd_DDfID              = @DDfID,
   BZd_DokumentTyp        = @DokumentTyp,
   BZd_DokumentID         = @DokumentID,
   BZd_NumerPelny         = @NumerPelny,
   BZd_NumerObcy          = @NumerObcy,
   BZd_PodmiotTyp         = @PodmiotTyp,
   BZd_PodmiotID          = @PodmiotID,
   BZd_BNaID              = @BNaID,
   BZd_RachunekNr         = @RachunekNr,
   BZd_IBAN               = @IBAN,
   BZd_KatID              = @KatID,
   BZd_FPlId              = @FPlId,
   BZd_DataDok            = @DataDok,
   BZd_DataKur            = @DataKur,
   BZd_Termin             = @Termin,
   BZd_DataReal           = @DataReal,
   BZd_KwotaSys           = @KwotaSys,
   BZd_Kwota              = @Kwota,
   BZd_Waluta             = @Waluta,
   BZd_KursNumer          = @KursNumer,
   BZd_KursL              = @KursL,
   BZd_KursM              = @KursM,
   BZd_Kierunek           = @Kierunek,
   BZd_Zwloka             = @Zwloka,
   BZd_Stan               = Case When BZd_Stan = 0 And @Stan > 0 Or BZd_Stan > 0 And @Stan = 0 Then @Stan Else BZd_Stan End,
   BZd_Opis               = @Opis,
   BZd_KontoPrzeciwstawne = @KontoPrzeciwstawne,
   BZd_StaModId           = @StaId,
   BZd_OpeModId           = @OpeId,
   BZd_OpeModKod          = @OpeModKod,
   BZd_OpeModNazwisko     = @OpeModNazwisko,
   BZd_TS_Mod             = GetDate(),
   BZd_PrzelewSEPA  = @PrzelewSEPA
   Where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId;
   INSERT INTO @DokumentIDTable SELECT BZd_DokumentID FROM cdn.BnkZdarzenia where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId;
 End
 Else
 Begin
  Update CDN.BnkZdarzenia Set
   BZd_DDfID              = @DDfID,
   BZd_NumerPelny         = @NumerPelny,
   BZd_NumerObcy          = @NumerObcy,
   BZd_PodmiotTyp         = @PodmiotTyp,
   BZd_PodmiotID          = @PodmiotID,
   BZd_BNaID              = @BNaID,
   BZd_RachunekNr         = @RachunekNr,
   BZd_IBAN               = @IBAN,
   BZd_KatID              = @KatID,
   BZd_DataDok            = @DataDok,
   BZd_DataKur            = @DataKur,
   BZd_Stan               = Case When BZd_Stan = 0 And @Stan > 0 Or BZd_Stan > 0 And @Stan = 0 Then @Stan Else BZd_Stan End,
   BZd_Opis               = @Opis,
   BZd_KontoPrzeciwstawne = @KontoPrzeciwstawne,
   BZd_StaModId           = @StaId,
   BZd_OpeModId           = @OpeId,
   BZd_OpeModKod          = @OpeModKod,
   BZd_OpeModNazwisko     = @OpeModNazwisko,
   BZd_TS_Mod             = GetDate()
   Where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId;
   INSERT INTO @DokumentIDTable SELECT BZd_DokumentID FROM cdn.BnkZdarzenia where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId;
 End
 exec cdn.ModyfikujZdarzeniaKBDokumentu @DokumentTyp, @DokumentIDTable;
End
