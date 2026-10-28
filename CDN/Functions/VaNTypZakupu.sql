Create Function CDN.VaNTypZakupu (@VaNId Int, @Zakup Int)
Returns Int
As
Begin
--Set NoCount On
Declare @Wynik Int
Set @Wynik = 0
Declare @T1 Int, @T2 Int, @T3 Int, @T4 Int, @T5 Int, @T6 Int
Set @T1 =  @Zakup                                                           % 10
Set @T2 = (@Zakup                                           - @T1) /    10  % 10
Set @T3 = (@Zakup                                  - 10*@T2 - @T1) /    100 % 10
Set @T4 = (@Zakup                        - 100*@T3 - 10*@T2 - @T1) /   1000 % 10
Set @T5 = (@Zakup             - 1000*@T4 - 100*@T3 - 10*@T2 - @T1) /  10000 % 10
Set @T6 = (@Zakup - 10000*@T5 - 1000*@T4 - 100*@T3 - 10*@T2 - @T1) / 100000 % 10
If Exists (
 Select * From CDN.VatTab Where VaT_VaNId = @VaNId
  And VaT_RodzajZakupu In (@T1, @T2, @T3, @T4, @T5, @T6) And VaT_RodzajZakupu <> 0
 )
  Set @Wynik = 1
Return @Wynik
End
