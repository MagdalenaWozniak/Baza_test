--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CREATE PROCEDURE CDN.TypWyplataNoUpdateSP
 @PdpId int, @PdzId int, @ParentId int, @Nazwa NVARCHAR(40),  @Nazwa2 NVARCHAR(50), @NazwaPelna NVARCHAR(127),
 @Skrot NVARCHAR(40), @Skrot2 NVARCHAR(50), @RodzajZrodla int, @ZalPodat int, @ImPrzelZalPodat smallint,
 @Koszty int, @KodRNA int, @SklZUS int, @SklZdrow int, @NiePomniejszZdrow smallint, @Korygowana smallint,
 @WchodziDoWyplaty smallint, @UwzglMin smallint, @UwzglNadgodz smallint, @OkresWyplaty int,
 @WplywaZalPodat smallint, @WliczUrlop int, @WliczChor int, @WliczEkwiwal int, @StOkrWartosc NVARCHAR(41),
 @StOkrTyp int, @ZaOkrZwolLek smallint, @AlgAlgorytm int, @AlgPotracenie smallint,
 @AlgZaokraglenie decimal(15,2), @AlgPotrNieobec smallint, @AlgOdchylki smallint, @AlgProcWynagr decimal(15,2),
 @AlgStaz smallint, @AlgStOkrTyp int, @AlgStOkrWartosc NVARCHAR(41), @AlgWspolcz decimal(15,2),
 @AlgLiczbaDni int, @AlgLiczbaGodz int, @AlgBrutto smallint, @AlgUrlop smallint, @AlgAutomat smallint,
 @AlgProcent decimal(15,2), @AlgKwota decimal(15,2), @AlgUzyjKwota smallint, @AlgStdWspolcz smallint,
 @AlgIlosc decimal(15,2), @AlgIloscMies int, @AlgStdIloscMies smallint, @KosztyProc decimal(15,2),
 @Zmienna1 NVARCHAR(128), @Zmienna2 NVARCHAR(128), @AktPoWyp1 smallint, @AktPoWyp2 smallint, @PriorytetZUS smallint,
 @PriorytetFIS smallint, @PriorytetKoszty smallint,  @RodzajFIS smallint, @Kategoria int, @Podstawowe smallint,
 @Standardowy smallint, @Zasadnicze smallint, @RodzajPotracenia smallint, @Wycofany smallint,
 @AlgSposobZaokr smallint, @Priorytet int,  @AlgStOkrPlusTyp int, @AlgStOkrPlusWartosc NVARCHAR(41),
 @AlgStazSposob  smallint, @Ulga smallint, @WzrId int, @AlgWzorzec NVARCHAR(2048),
 @AlgRodzaj12 smallint, @AlgSposobPomn smallint, @Nieaktywny smallint, @AlgPodstDzielGodz smallint,
 @AlgGodziny datetime, @WliczPFRON smallint, @KosztFirma smallint, @OpisAnalitCzasPracy smallint,
 @Kopia int, @PozycjaRP7 int, @Wskaznik smallint, @Umowa smallint, @WliczanyDoGUS smallint, @ZalPodProc decimal(15,2),
 @PKZP smallint, @SwiadczFS smallint, @TypWaluty tinyint, @NieZapisujZerowego tinyint, @AlgIloscMiesWszystkie tinyint, @AlgGodzinyDni tinyint,
 @ZajecieWynagr tinyint, @DoliczNaKoncu tinyint, @AlgKnfWspolcz tinyint, @WliczChorPodwojnie tinyint, @NieZapisujZerowegoPKZP tinyint,
 @WykazZUSRPA tinyint, @ImportAppId nvarchar(5), @ImportRowId nvarchar(36), @TS_Export datetime,
 @OpeZalId int, @TS_Zal datetime, @OpeModId int,  @TS_Mod datetime
AS
 BEGIN
 SET NOCOUNT ON
 declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeZalID, @OpeZalKod OUT, @OpeZalNazwisko OUT
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeModID, @OpeModKod OUT, @OpeModNazwisko OUT
 Declare @UserTWPId Int, @NazwaTmp NVARCHAR(40), @Count Int
 Set @UserTWPId = Null
 Select @UserTWPId = TWP_TWPId From CDN.TypWyplata Where TWP_Nazwa = @Nazwa And TWP_Standardowy = 0
 If @UserTWPId Is Not Null
  Begin
  Set @Count = 1
  While @Count < 1000
   Begin
   --MC12
      set @Count = @Count + 1
   Set @NazwaTmp = Cast (@Nazwa As NVARCHAR(36)) + LTrim(Str(@Count))
   If Exists (Select * From CDN.TypWyplata Where TWP_Nazwa = @NazwaTmp) Continue
   Update CDN.TypWyplata Set TWP_Nazwa = @NazwaTmp Where TWP_TWPId = @UserTWPId
   Break
   End
  If @Count > 999
   Begin
   RAISERROR('##OPT32485##', 16, 1)--Raiserror('Błąd ustalania nazwy typu wypłaty. ', 16, 1)--ERR_SQL_Place_BladNazwyTWP 32485
   Rollback Tran
   Set Nocount Off
   Return
   End
  End
 IF NOT EXISTS (SELECT * FROM CDN.TypWyplata WHERE TWP_Standardowy = @Standardowy)
  BEGIN
   INSERT INTO CDN.TypWyplata
      (
      TWP_PdpId,TWP_PdzId,TWP_ParentId,TWP_Nazwa,TWP_Nazwa2,TWP_NazwaPelna,TWP_Skrot,TWP_Skrot2,
      TWP_RodzajZrodla,TWP_ZalPodat,TWP_ImPrzelZalPodat,TWP_Koszty,TWP_KodRNA,TWP_SklZUS,TWP_SklZdrow,
      TWP_NiePomniejszZdrow,TWP_Korygowana,TWP_WchodziDoWyplaty,TWP_UwzglMin,TWP_UwzglNadgodz,
      TWP_OkresWyplaty,TWP_WplywaZalPodat,TWP_WliczUrlop,TWP_WliczChor,TWP_WliczEkwiwal,TWP_StOkrWartosc,
      TWP_StOkrTyp,TWP_ZaOkrZwolLek,TWP_AlgAlgorytm,TWP_AlgPotracenie,TWP_AlgZaokraglenie,TWP_AlgPotrNieobec,
      TWP_AlgOdchylki,TWP_AlgProcWynagr,TWP_AlgStaz,TWP_AlgStOkrTyp,TWP_AlgStOkrWartosc,TWP_AlgWspolcz,
      TWP_AlgLiczbaDni,TWP_AlgLiczbaGodz,TWP_AlgBrutto,TWP_AlgUrlop,TWP_AlgAutomat,TWP_AlgProcent,
      TWP_AlgKwota,TWP_AlgUzyjKwota,TWP_AlgStdWspolcz,TWP_AlgIlosc,TWP_AlgIloscMies,TWP_AlgStdIloscMies,
      TWP_KosztyProc,TWP_Zmienna1,TWP_Zmienna2,TWP_AktPoWyp1,TWP_AktPoWyp2,TWP_PriorytetZUS,
      TWP_PriorytetFIS,TWP_PriorytetKoszty,TWP_RodzajFIS,TWP_Kategoria,TWP_Podstawowe,TWP_Standardowy,
      TWP_Zasadnicze, TWP_RodzajPotracenia,TWP_Wycofany,TWP_AlgSposobZaokr,TWP_Priorytet,TWP_AlgStOkrPlusTyp,
      TWP_AlgStOkrPlusWartosc,TWP_AlgStazSposob,TWP_Ulga,TWP_WzrId,TWP_AlgWzorzec,TWP_AlgRodzaj12,
      TWP_AlgSposobPomn,TWP_Nieaktywny,TWP_AlgPodstDzielGodz,TWP_AlgGodziny,TWP_WliczPFRON,TWP_KosztFirma,
      TWP_OpisAnalitCzasPracy,TWP_Kopia,TWP_PozycjaRP7,TWP_Wskaznik,TWP_Umowa, TWP_WliczanyDoGUS, TWP_ZalPodProc,
      TWP_PKZP, TWP_SwiadczFS, TWP_TypWaluty, TWP_NieZapisujZerowego, TWP_AlgIloscMiesWszystkie, TWP_AlgGodzinyDni,
      TWP_ZajecieWynagr, TWP_DoliczNaKoncu, TWP_AlgKnfWspolcz, TWP_WliczChorPodwojnie, TWP_NieZapisujZerowegoPKZP,
      TWP_WykazZUSRPA, TWP_ImportAppId, TWP_ImportRowId, TWP_TS_Export,
      TWP_OpeZalId,TWP_OpeZalKod,TWP_OpeZalNazwisko,TWP_TS_Zal,TWP_OpeModId,TWP_OpeModKod,TWP_OpeModNazwisko,TWP_TS_Mod
      )
    VALUES
     (
     @PdpId,@PdzId,@ParentId,@Nazwa,@Nazwa2,@NazwaPelna,@Skrot,@Skrot2,@RodzajZrodla,@ZalPodat,@ImPrzelZalPodat,
     @Koszty,@KodRNA,@SklZUS,@SklZdrow,@NiePomniejszZdrow,@Korygowana,@WchodziDoWyplaty,@UwzglMin,@UwzglNadgodz,
     @OkresWyplaty,@WplywaZalPodat,@WliczUrlop,@WliczChor,@WliczEkwiwal,@StOkrWartosc,@StOkrTyp,@ZaOkrZwolLek,
     @AlgAlgorytm,@AlgPotracenie,@AlgZaokraglenie,@AlgPotrNieobec,@AlgOdchylki,@AlgProcWynagr,@AlgStaz,@AlgStOkrTyp,
     @AlgStOkrWartosc,@AlgWspolcz,@AlgLiczbaDni,@AlgLiczbaGodz,@AlgBrutto,@AlgUrlop,@AlgAutomat,@AlgProcent,@AlgKwota,
     @AlgUzyjKwota,@AlgStdWspolcz,@AlgIlosc,@AlgIloscMies,@AlgStdIloscMies,@KosztyProc,@Zmienna1,@Zmienna2,
     @AktPoWyp1,@AktPoWyp2,@PriorytetZUS,@PriorytetFIS,@PriorytetKoszty,@RodzajFIS,@Kategoria,@Podstawowe,
     @Standardowy,@Zasadnicze, @RodzajPotracenia,@Wycofany,@AlgSposobZaokr,@Priorytet,@AlgStOkrPlusTyp,
     @AlgStOkrPlusWartosc,@AlgStazSposob,@Ulga,@WzrId,@AlgWzorzec,@AlgRodzaj12,@AlgSposobPomn,@Nieaktywny,
     @AlgPodstDzielGodz,@AlgGodziny,@WliczPFRON,@KosztFirma,@OpisAnalitCzasPracy,@Kopia,@PozycjaRP7,@Wskaznik,@Umowa,
     @WliczanyDoGUS, @ZalPodProc, @PKZP, @SwiadczFS, @TypWaluty, @NieZapisujZerowego, @AlgIloscMiesWszystkie, @AlgGodzinyDni,
     @ZajecieWynagr, @DoliczNaKoncu, @AlgKnfWspolcz, @WliczChorPodwojnie, @NieZapisujZerowegoPKZP, @WykazZUSRPA,
     @ImportAppId, @ImportRowId, @TS_Export,
     @OpeZalId,@OpeZalKod,@OpeZalNazwisko,@TS_Zal,@OpeModId,@OpeModKod,@OpeModNazwisko,@TS_Mod
     )
  END
 END
 SET NOCOUNT OFF
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
