Create Procedure CDN.SprawdzDefinicjeKKK @KKEId Int
As
Begin
Set NoCount On
If Not Exists (Select * From CDN.KragKosztElem Where KKE_KKEId = @KKEId)
  Return
Declare @KKNId Int, @Konto NVARCHAR(50), @Strona Int, @NieAktywny Int, @OObId Int
Declare @Symbol NVARCHAR(20), @Konto2 NVARCHAR(50)
Select @KKNId = KKE_KKNId, @Konto = KKE_Konto, @Strona = KKE_Strona, @NieAktywny = KKN_NieAktywny, @OObId = KKN_OObId
 From CDN.KragKosztElem Join CDN.KragKosztNag On KKE_KKNId = KKN_KKNId
 Where KKE_KKEId = @KKEId
If @NieAktywny = 1 Return
Set @Symbol = Null
Set @Konto2 = Null
Select Top 1 @Symbol=KKN_Symbol, @Konto2=KKE_Konto From CDN.KragKosztElem Join CDN.KragKosztNag On KKE_KKNId = KKN_KKNId
  Where KKN_NieAktywny = 0
    And (KKN_KKNId <> @KKNId Or KKE_Strona <> @Strona)
    And KKN_OObId = @OObId
    And (KKE_Konto Like Replace(Replace(@Konto, '?', '_'), '*', '%') Or @Konto Like Replace(Replace(KKE_Konto, '?', '_'), '*', '%'))
If @Symbol Is Not Null And @Konto2 Is Not Null
 Begin
  exec CDN.RiseOptimaException 32535, 's1', @Konto, 's2', @Konto2, 's3', @Symbol
  RollBack Tran
  Set NoCount Off
  Return
 End
Set NoCount Off
End
