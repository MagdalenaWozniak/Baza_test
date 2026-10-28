Create Procedure CDN.DodajKontoAnl
 @Numer NVARCHAR(50) ,
 @OObId Int = Null ,
 @Nazwa NVARCHAR(50) = '' ,
 @OpeId Int = Null ,
 @StaId Int = Null ,
 @Waluta NVARCHAR(3) = ''
As
 Begin
 Set NoCount On
 Declare @Auto NVARCHAR(1), @Pos SmallInt, @NumerSyn NVARCHAR(50), @AccIdSyn Int, @Slownik Int
 Declare @NazwaTmp NVARCHAR(50), @NumerTmp NVARCHAR(50), @TypKonta Int, @Rozrachunkowe Int, @KontrolaSalda Int, @OpeIdTmp Int, @StaIdTmp Int
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
 -- Sprawdzenie parametru automatycznego zakładania kont
 Select @Auto = Cast (Fir_Wartosc As NVARCHAR(1)) From CDN.Firma Where Fir_Numer = 247
 If IsNull(@Auto,'') <> '1'
  Begin
   exec CDN.RiseOptimaException 32548, 's1', @Numer
   Return
  End
 -- Sprawdzenie czy konto jest analityczne
 If CharIndex('.', @Numer) = 0
  Begin
   exec CDN.RiseOptimaException 32549, 's1', @Numer
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
      Select  @AccIdSyn = Acc_AccId,
  @TypKonta = case when Acc_TypKonta = 7 then 4 else Acc_TypKonta end,
  @Rozrachunkowe = Acc_Rozrachunkowe,
  @Slownik = Acc_Slownik,
             @KontrolaSalda = Acc_KontrolaSalda, @OpeIdTmp = Acc_OpeModId, @StaIdTmp = Acc_StaModId
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
 -- Nie zakladamy w ten sposob kont slownikowych
 If @Slownik <> 0
  Begin
   exec CDN.RiseOptimaException 32553, 's1', @NumerSyn
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
 0,
 0,
 Null,
 Null,
 @OpeIdTmp,
 @StaIdTmp,
 @WalTmp
    If @@Error <> 0
     Break
    End
   Set @Pos = @Pos + 1
  End
 Set NoCount Off
 End
