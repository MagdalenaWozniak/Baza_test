Create Function CDN.IdKsieg(@DokTyp Int, @DokId Int)
Returns NVARCHAR(256)
As
Begin
Declare @Wynik NVARCHAR(256)
If @DokTyp = 1
    Select @Wynik = VaN_IdentKsieg From CDN.VatNag Join CDN.TraNag On TrN_VaNId = VaN_VaNId Where TrN_TrNId = @DokId AND TrN_TypDokumentu <> 305
Return IsNull(@Wynik, '')
End
