Create Procedure CDN.RozliczenieVatTab7 @BZdId Int
As
Begin
Set NoCount On
Declare @DokTyp Int, @DokId Int, @VaNId Int
Select @DokTyp = BZd_DokumentTyp, @DokId = BZd_DokumentId From CDN.BnkZdarzenia Where BZd_BZdId = @BZdId
If @DokTyp In (1,2)
  Begin
    If @DokTyp = 1
      Select @VaNId = TrN_VaNId From CDN.TraNag Where TrN_TrNId = @DokId
    Else
      Set @VaNId = @DokId
    Execute CDN.GenerujVatTab7 @VaNId
  End
End
