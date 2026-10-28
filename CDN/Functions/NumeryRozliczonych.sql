CREATE  Function CDN.NumeryRozliczonych(@DokId Int, @DokTyp Int, @BlokPrac Int)
Returns NVARCHAR(255)
As
Begin
Declare @NrRoz NVARCHAR(255)
Set @NrRoz = ''
Declare @NrRoz1 NVARCHAR(255)
Declare c Cursor Local Fast_Forward For
Select Case When (@BlokPrac=1 And BRK_PPodTyp=3) Then '-' Else BZp_NumerPelny End
From CDN.BnkRozKwoty Join CDN.BnkZapisy On BZp_BZpID = BRK_PDokID
Where BRK_PDokTyp=2 AND BRK_LDokTyp=@DokTyp AND BRK_LDokID = @DokId
Union All
Select Case When (@BlokPrac=1 And BRK_LPodTyp=3) Then '-' Else BZp_NumerPelny End
From CDN.BnkRozKwoty Join CDN.BnkZapisy On BZp_BZpID = BRK_LDokID
Where BRK_LDokTyp=2 AND BRK_PDokTyp=@DokTyp AND BRK_PDokID = @DokId
Union All
Select Case When (@BlokPrac=1 And BRK_PPodTyp=3) Then '-' Else Case BZd_NumerObcy When '' Then RTrim(BZd_NumerPelny) Else RTrim(BZd_NumerObcy) End End
From CDN.BnkRozKwoty Join CDN.BnkZdarzenia On BZd_BZdID = BRK_PDokID
Where BRK_PDokTyp=1 AND BRK_LDokTyp=@DokTyp AND BRK_LDokID = @DokId
Union All
Select Case When (@BlokPrac=1 And BRK_LPodTyp=3) Then '-' Else Case BZd_NumerObcy When '' Then RTrim(BZd_NumerPelny) Else RTrim(BZd_NumerObcy) End End
From CDN.BnkRozKwoty Join CDN.BnkZdarzenia On BZd_BZdID = BRK_LDokID
Where BRK_LDokTyp=1 AND BRK_PDokTyp=@DokTyp AND BRK_PDokID = @DokId
Open c
While 1=1
Begin
  Fetch Next From c InTo @NrRoz1
  If @@Fetch_Status<>0 Break
  Set @NrRoz = RTrim(@NrRoz) + '; ' + @NrRoz1;
  End
  Close c
  Deallocate c
  Return Substring(@NrRoz,2,255)
End
