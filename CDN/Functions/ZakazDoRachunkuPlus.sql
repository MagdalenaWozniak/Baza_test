Create Function CDN.ZakazDoRachunkuPlus (@BRaId INT, @OpeId INT, @Obiekt INT = 0, @Akcja INT = 0)
Returns Int
As
Begin
Declare @Wynik Int
Set @Wynik = 0
If @Obiekt=1 And @Akcja=0
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RachL=1)
  Set @Wynik = 1
End
If @Obiekt=1 And @Akcja=2
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RachP=1)
  Set @Wynik = 1
End
Else If @Obiekt=1 And @Akcja=3
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RachZ=1)
  Set @Wynik = 1
End
Else If @Obiekt=1 And @Akcja=5
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RachR=1)
  Set @Wynik = 1
End
Else If @Obiekt=1 And @Akcja=6
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RachU=1)
  Set @Wynik = 1
End
Else If @Obiekt=2 And @Akcja=1
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RapD=1)
  Set @Wynik = 1
End
Else If @Obiekt=2 And @Akcja=2
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RapP=1)
  Set @Wynik = 1
End
Else If @Obiekt=2 And @Akcja=3
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RapZ=1)
  Set @Wynik = 1
End
Else If @Obiekt=2 And @Akcja=4
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RapZC=1)
  Set @Wynik = 1
End
Else If @Obiekt=2 And @Akcja=6
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RapU=1)
  Set @Wynik = 1
End
Else If @Obiekt=2 And @Akcja=7
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_RapUC=1)
  Set @Wynik = 1
End
Else If @Obiekt=3 And @Akcja=1
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZdarzD=1)
  Set @Wynik = 1
End
Else If @Obiekt=3 And @Akcja=2
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZdarzP=1)
  Set @Wynik = 1
End
Else If @Obiekt=3 And @Akcja=3
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZdarzZ=1)
  Set @Wynik = 1
End
Else If @Obiekt=3 And @Akcja=4
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZdarzZC=1)
  Set @Wynik = 1
End
Else If @Obiekt=3 And @Akcja=6
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZdarzU=1)
  Set @Wynik = 1
End
Else If @Obiekt=3 And @Akcja=7
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZdarzUC=1)
  Set @Wynik = 1
End
Else If @Obiekt=4 And @Akcja=1
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZapD=1)
  Set @Wynik = 1
End
Else If @Obiekt=4 And @Akcja=2
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZapP=1)
  Set @Wynik = 1
End
Else If @Obiekt=4 And @Akcja=3
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZapZ=1)
  Set @Wynik = 1
End
Else If @Obiekt=4 And @Akcja=4
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZapZC=1)
  Set @Wynik = 1
End
Else If @Obiekt=4 And @Akcja=6
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZapU=1)
  Set @Wynik = 1
End
Else If @Obiekt=4 And @Akcja=7
Begin
 If Exists (Select * From CDN.BnkRachZakazy Where BRZ_BRaId=@BRaId And BRZ_OpeId=@OpeId And BRZ_ZapUC=1)
  Set @Wynik = 1
End
Return @Wynik
End
