Create Function CDN.ZakazDoRachunku (@BRaId INT, @OpeId INT)
Returns Int
As
Begin
Declare @Wynik Int
Set @Wynik = 0
If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId)
 Set @Wynik=1
Return @Wynik
End
