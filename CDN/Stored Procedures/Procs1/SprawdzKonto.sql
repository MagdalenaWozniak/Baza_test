Create Procedure CDN.SprawdzKonto
 @OObId Int,
 @Numer NVARCHAR(50) ,
 @SloTyp Int = Null ,
 @SloId  Int = Null ,
 @OpeId Int = Null ,
 @StaId Int = Null ,
 @Waluta NVARCHAR(3)= NULL
As
 Begin
  Set NoCount On
  Declare @AccIdOut Int, @AccNumerOut NVARCHAR(50), @WalutaOut NVARCHAR(3)
  Declare @Analityka Int, @Slownik Int, @NieAktywne Int
  Set @AccNumerOut = @Numer
  Set @Numer = Replace(@Numer, '-', '.')
  If @Waluta = CDN.Waluta('')
    Set @Waluta = ''
  If Not Exists (Select * From CDN.Konta Where Acc_OObId = @OObId And Acc_NumerIdx = @Numer)
    execute CDN.DodajKontoAnl @AccNumerOut, @OObId, '', @OpeId, @StaId, @Waluta
  If @@Error <> 0 Return
  Set @AccIdOut = Null
  Select
   @AccIdOut = Acc_AccId,
   @Analityka = Acc_Analityka,
   @Slownik = Acc_Slownik,
   @WalutaOut = Acc_Waluta,
   @NieAktywne = Acc_NieAktywne
  From CDN.Konta Where Acc_OObId = @OObId And Acc_NumerIdx = @Numer
  If @AccIdOut Is Null
   Begin
  exec CDN.RiseOptimaException 32566, 's1', @AccNumerOut
  Return
   End
  If @NieAktywne = 1
   Begin
  exec CDN.RiseOptimaException 32567, 's1', @AccNumerOut
  Return
   End
  If CDN.ZakazDoKonta (@AccIdOut, @OpeId) = 1
   Begin
  exec CDN.RiseOptimaException 32568, 's1', @AccNumerOut
  Return
   End
  If @Slownik <> 0
   Begin
    Create Table #SloTmp (AccId Int, Numer NVARCHAR(50), NieAktywne Int)
    Insert Into #SloTmp execute CDN.KontoSlownikowe @AccIdOut, @SloTyp, @SloId, @OpeId, @StaId, @Waluta
    If @@Error <> 0 Return
    Select
     @AccIdOut  = AccId,
     @AccNumerOut  = Numer
    From #SloTmp
    Set @Analityka = 1
    Set @WalutaOut = @Waluta
    Drop Table #SloTmp
   End
  If @Analityka = 0
   Begin
     exec CDN.RiseOptimaException 32569, 's1', @AccNumerOut
     Return
   End
  If @WalutaOut <> @Waluta
   Begin
     Set @WalutaOut = CDN.Waluta(@WalutaOut)
     Set @Waluta = CDN.Waluta(@Waluta)
     exec CDN.RiseOptimaException 32570, 's1', @Waluta, 's2', @AccNumerOut, 's3', @WalutaOut
     Return
   End
  Set NoCount Off
  Select Acc_AccId = @AccIdOut, Acc_Numer = @AccNumerOut
 End
