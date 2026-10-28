Create Function CDN.PrzekroczonyZakresDatWBuforze (@DataDok DateTime, @OObId Int, @Bufor Int)
Returns int
As
Begin
    Declare @iResult Int
  Set @iResult = 0
  If  @Bufor = 1
   And Exists(select * from CDN.Firma where Fir_Numer = 1735 and Fir_Wartosc='1')
   And Exists(Select * from CDN.DekretyNag where DeN_Typ = 2 And DeN_Bufor = 1 And DeN_OObId = @OObId)
  Begin
  If   Exists (Select * from CDN.DekretyNag where DeN_Typ = 2 And DeN_OObId = @OObId And DeN_Bufor = 1 And DateDiff(Month, DeN_DataDok, @DataDok) > 1)
    Or Exists (Select * from CDN.DekretyNag where DeN_Typ = 2 And DeN_OObId = @OObId And DeN_Bufor = 1 And DateDiff(Month, DeN_DataDok, @DataDok) <-1)
     Begin
    Set @iResult = 1
     End
  End
    Return @iResult
End
