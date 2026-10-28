CREATE   Function CDN.KwotaRozNaDzien(@DokId Int, @DokTyp Int, @Data DateTime)
Returns Decimal(15,2)
As
Begin
Declare @KwotaRoz Decimal(15,2)
Declare @KwotaRoz1 Decimal(15,2)
Set @KwotaRoz = 0
Declare c Cursor Local Fast_Forward For
Select BZp_Kwota
From CDN.BnkRozKwoty Join CDN.BnkZapisy On BZp_BZpID = BRK_PDokID
Where BRK_PDokTyp=2 AND BRK_LDokTyp=@DokTyp AND BRK_LDokID = @DokId AND BRK_DataDok <= @Data
Union All
Select BZp_Kwota
From CDN.BnkRozKwoty Join CDN.BnkZapisy On BZp_BZpID = BRK_LDokID
Where BRK_LDokTyp=2 AND BRK_PDokTyp=@DokTyp AND BRK_PDokID = @DokId AND BRK_DataDok <= @Data
Union All
Select BZd_Kwota
From CDN.BnkRozKwoty Join CDN.BnkZdarzenia On BZd_BZdID = BRK_PDokID
Where BRK_PDokTyp=1 AND BRK_LDokTyp=@DokTyp AND BRK_LDokID = @DokId AND BRK_DataDok <= @Data
Union All
Select BZd_Kwota
From CDN.BnkRozKwoty Join CDN.BnkZdarzenia On BZd_BZdID = BRK_LDokID
Where BRK_LDokTyp=1 AND BRK_PDokTyp=@DokTyp AND BRK_PDokID = @DokId AND BRK_DataDok <= @Data
Open c
While 1=1
Begin
  Fetch Next From c InTo @KwotaRoz1
  If @@Fetch_Status<>0 Break
  Set @KwotaRoz = @KwotaRoz + @KwotaRoz1;
  End
  Close c
  Deallocate c
  Return @KwotaRoz
End
