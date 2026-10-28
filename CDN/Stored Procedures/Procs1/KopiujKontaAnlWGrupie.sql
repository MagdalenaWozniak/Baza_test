CREATE    Procedure CDN.KopiujKontaAnlWGrupie
 @OObId Int,
 @Numer NVARCHAR(50) ,
 @Wzor NVARCHAR(50) ,
 @OpeId Int = Null ,
 @StaId Int = Null ,
 @Waluta NVARCHAR(3)= NULL
As
 Begin
  Set NoCount On
  Declare @AccIdOut Int, @AccNumerOut NVARCHAR(50), @WalutaOut NVARCHAR(3)
  Declare @Analityka Int, @NieAktywne Int
  Declare @Nazwa NVARCHAR(50), @Slownik Int, @SlownikGrupa Int, @SlownikTyp Int, @SlownikId Int, @Rozrachunkowe Int, @KontrolaSalda Int, @KontrolaBudzetu Int
  Declare @Dodano Int, @Nazwa2 NVARCHAR(50)
  Set @Dodano = 0
  Set @AccNumerOut = @Numer
  Set @Numer = Replace(@Numer, '-', '.')
  If Not Exists (Select * From CDN.Konta Where Acc_OObId = @OObId And Acc_NumerIdx = Replace(@Numer, '-', '.'))
  begin
    Select  @Nazwa = Acc_Nazwa,
  @Nazwa2 = Acc_Nazwa2,
  @Slownik = Acc_Slownik,
  @Rozrachunkowe = Acc_Rozrachunkowe,
  @KontrolaSalda = Acc_KontrolaSalda,
  @KontrolaBudzetu = Acc_KontrolaBudzetu,
  @SlownikGrupa = Acc_SlownikGrupa,
  @SlownikTyp = Acc_SlownikTyp,
  @SlownikId = Acc_SlownikId,
  @Waluta = Acc_Waluta
    From CDN.Konta Where Acc_OObId = @OObId And Acc_NumerIdx = Replace(@Wzor, '-', '.')
    execute CDN.DodajKontoAnlwGrupie @AccNumerOut, @OObId, @Nazwa, @Nazwa2, @Slownik, @SlownikGrupa, @SlownikTyp, @SlownikId, @Rozrachunkowe, @KontrolaSalda, @KontrolaBudzetu, @OpeId, @StaId, @Waluta
    Set @Dodano = 1
  end
  If @@Error <> 0 Return
  Set @AccIdOut = Null
  Select
   @AccIdOut = Acc_AccId
  From CDN.Konta Where Acc_OObId = @OObId And Acc_NumerIdx = Replace(@Wzor, '-', '.')
  Set NoCount Off
  Select Acc_AccId = @AccIdOut, Acc_Numer = @AccNumerOut, Acc_NowyRekord = @Dodano
 End
