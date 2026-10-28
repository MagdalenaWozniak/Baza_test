CREATE Procedure CDN.DodajKontoAnlwGrupie
 @Numer NVARCHAR(50) ,
 @OObId Int = Null ,
 @Nazwa NVARCHAR(50) = '' ,
 @Nazwa2 NVARCHAR(50) = '' ,
 @Slownik Int = 0,
 @SlownikGrupa Int = 0,
 @SlownikTyp Int = Null,
 @SlownikId Int = Null,
 @Rozrachunkowe Int = 0,
 @KontrolaSalda Int = 0,
 @KontrolaBudzetu Int = 0,
 @OpeId Int = Null ,
 @StaId Int = Null ,
 @Waluta NVARCHAR(3) = ''
As
 Begin
 Set NoCount On
 Declare @Auto NVARCHAR(1), @Pos SmallInt, @NumerSyn NVARCHAR(50), @AccIdSyn Int
 Declare @NazwaTmp NVARCHAR(50), @NumerTmp NVARCHAR(50), @TypKonta Int, @OpeIdTmp Int, @StaIdTmp Int
 Declare @SlownikSyn Int, @SlownikGrupaSyn Int, @KontrolaBudzetuSyn Int, @SlownikKod NVARCHAR(20)
 If IsNull(@Numer, '') = ''
  Begin
   exec CDN.RiseOptimaException 32484
   Return
  End
If CharIndex('.', @Numer) <> 0
  Begin
   exec CDN.RiseOptimaException 32486
   Return
  End
 -- Odczytanie okresu obrachunkowego
 If @OObId Is Null
  Select @OObId = Cast(Fir_Wartosc As Int) From CDN.Firma Where Fir_Numer = 244
 If Not Exists (Select * From CDN.OkresyObrach Where OOb_OObId = @OObId)
  Begin
   exec CDN.RiseOptimaException 32487
   Return
  End
 -- Sprawdzenie czy konto istnieje
 Set @Numer = Replace (@Numer, '-', '.')
 If Exists (Select * From CDN.Konta Where Acc_OObId = @OObId And Acc_NumerIdx = @Numer )
  Return
 -- Sprawdzenie czy konto jest analityczne
 If CharIndex('.', @Numer) = 0
  Begin
   exec CDN.RiseOptimaException 32488, 's', @Numer
   Return
  End
 -- Szukamy istniejącego konta syntetycznego
 Set @Pos = Len (@Numer)
 Set @NumerSyn = ''
 While @Pos > 0
  Begin
   If SubString (@Numer, @Pos, 1) = '.'
    If Exists (Select * From CDN.Konta Where Acc_OObId = @OObId And Acc_NumerIdx = SubString (@Numer, 1, @Pos-1))
     Begin
      -- Ustalone konto syntetyczne
      Set @NumerSyn = SubString (@Numer, 1, @Pos-1)
      Select
  @AccIdSyn = Acc_AccId,
  @TypKonta = case when Acc_TypKonta = 7 then 4 else Acc_TypKonta end,
  @SlownikSyn = Acc_Slownik,
  @SlownikGrupaSyn = Acc_SlownikGrupa,
  @KontrolaBudzetuSyn = Acc_KontrolaBudzetu,
  @OpeIdTmp = Acc_OpeModId,
  @StaIdTmp = Acc_StaModId
       From CDN.Konta Where Acc_OObId = @OObId And Acc_NumerIdx = @NumerSyn
      Break
     End
   Set @Pos = @Pos - 1
  End
 If @NumerSyn = ''
  Begin
   exec CDN.RiseOptimaException 32489
   Return
  End
 -- Sprawdzenie, czy konto syntetyczne nie jest kontem walutowym
 If Exists (Select * From CDN.Konta Where Acc_AccId = @AccIdSyn And CDN.Waluta(Acc_Waluta) <> (Select Cast (Fir_Wartosc As NVARCHAR(3)) From CDN.Firma Where Fir_Numer = 3))
  Begin
   exec CDN.RiseOptimaException 26151
   Return
  End
 If @KontrolaBudzetuSyn = 1
  Begin
   exec CDN.RiseOptimaException 30243
   Return
  End
 If @SlownikGrupaSyn <> 0 And @SlownikGrupa = 1
  Begin
   exec CDN.RiseOptimaException 32490
   Return
  End
 Else If @SlownikSyn <> 0 AND @SlownikGrupaSyn <> 1 And @SlownikGrupa = 2
  Begin
   exec CDN.RiseOptimaException 32491
   Return
  End
 Else If @SlownikSyn <> 0 AND @SlownikGrupaSyn = 1 And @SlownikGrupa <> 2
  Begin
   exec CDN.RiseOptimaException 32491
   Return
  End
 Else If @SlownikSyn = 0 And @SlownikGrupa = 2
  Begin
   Set @Slownik = 0
   Set @SlownikGrupa = 0
  End
 If @SlownikSyn <> 0 AND Not (@SlownikTyp = @SlownikSyn)
  Begin
   exec CDN.RiseOptimaException 32492
   Return
  End
 Else If @SlownikSyn <> 0 AND Not (@Slownik = @SlownikSyn) And @SlownikGrupa = 2
  Begin
   exec CDN.RiseOptimaException 32492
   Return
  End
 Else If @SlownikSyn <> 0 AND isnull(@SlownikTyp,0) = 0 And @SlownikGrupa = 0
  Begin
   exec CDN.RiseOptimaException 32493
   Return
  End
 Else If @SlownikSyn = 0
  Begin
   Set @SlownikTyp = null
   Set @SlownikId = null
  End
 Set @SlownikKod = Null
 If @SlownikTyp In (1,2,3,5)
  Begin
   Select @SlownikKod = Pod_Kod From CDN.PodmiotyView Where Pod_PodmiotTyp = @SlownikTyp And Pod_PodId = @SlownikId
  End
 Else If @SlownikTyp = 6
  Begin
   Select @SlownikKod = SrT_NrInwent From CDN.Trwale Where SrT_SrTId = @SlownikId
  End
 Else If @SlownikTyp = 7
  Begin
  Select @SlownikKod = Twr_Kod From CDN.Towary Left Outer Join CDN.TwrGrupy On TwG_GIDTyp = -16 AND TwG_GIDNumer = Twr_TwGGIDNumer
    Where Twr_TwrId = @SlownikId
  End
 If @SlownikKod Is Null And isnull(@SlownikTyp,0) <> 0
  Begin
   exec CDN.RiseOptimaException 32493
   Return
  End
 -- Sprawdzenie, czy na koncie syntetycznym nie występują księgowania
 If Exists (Select * From CDN.DekretyKonta Where DeK_AccId = @AccIdSyn)
  Begin
   exec CDN.RiseOptimaException 32494, 's1', @NumerSyn
   Return
  End
 If @OpeId Is Not Null
  Set @OpeIdTmp = @OpeId
 If @StaId Is Not Null
  Set @StaIdTmp = @StaId
 Set @Pos = @Pos + 1
 Declare @WalTmp NVARCHAR(3)
 Set @WalTmp = ''
 While @Pos <= Len (@Numer) + 1
  Begin
   If SubString (@Numer, @Pos, 1) = '.' Or @Pos = Len (@Numer) + 1
    Begin
 Set @NumerTmp = Replace ( SubString(@Numer, 1, @Pos - 1), '.', '-')
 Set @NazwaTmp = Case When IsNull(@Nazwa, '') <> '' Then @Nazwa Else @NumerTmp End
    If @Pos = Len (@Numer) + 1
     Set @WalTmp = @Waluta
 -- Założenie konta
 exec CDN.DodajKonto
 @OObID,
 @NumerTmp,
 @NazwaTmp,
 @TypKonta,
 @Rozrachunkowe,
 @KontrolaSalda,
 @Slownik,
 @SlownikGrupa,
 @SlownikTyp,
 @SlownikId,
 @OpeIdTmp,
 @StaIdTmp,
 @WalTmp,
 @KontrolaBudzetu,
 @Nazwa2
    If @@Error <> 0
     Break
    End
   Set @Pos = @Pos + 1
  End
 Set NoCount Off
 End
