Create Function CDN.DeklNumer (@DkNId Int)
Returns NVARCHAR(26)
As
Begin
Declare @Numer NVARCHAR(26), @DDfId Int, @Schemat NVARCHAR(50), @Symbol NVARCHAR(5), @RokObr NVARCHAR(5), @TypDekl Int, @RokMc Int
DECLARE @NumerStr NVARCHAR(10), @NumerStrS NVARCHAR(10), @NumerNr INT, @Wersja INT
Set @NumerStrS = ''
Set @NumerStr  = ''
Set @NumerNr=0
Set @Numer = ''
While 1=1
Begin
 If Not Exists (Select * From CDN.DeklNag Where DkN_DkNId=@DknId) Break
 Select @TypDekl=DkN_TypDeklar, @RokMc=DkN_RokMiesiac, @NumerNr = DkN_Numer, @Wersja = DkN_Wersja
  From CDN.DeklNag Where DkN_DkNId=@DknId
 Set @DDfId = Null
 If Not Exists (Select * From CDN.Firma Where Fir_Numer=1391 And IsNumeric(Fir_Wartosc)=1) Break
 Select @DDfId = Cast (Fir_Wartosc As Int) From CDN.Firma Where Fir_Numer=1391
 If @DDfId Is Null Break
 If Not Exists (Select * From CDN.DokDefinicje Where DDf_DDfId = @DDfId) Break
 Select @Symbol = DDf_Symbol, @Schemat = DDf_Numeracja From CDN.DokDefinicje Where DDf_DDfId = @DDfId
    SET @NumerStrS = LTRIM(CAST(@NumerNr AS NVARCHAR(10)))
    IF LEN(@NumerStrS)<6
     SET @NumerStr = REPLICATE('0', 6 - LEN(@NumerStrS)) + @NumerStrS
    ELSE
     SET @NumerStr = @NumerStrS
 Set @Schemat = Replace(@Schemat, '@brak/', '')
 Set @Schemat = Replace(@Schemat, '/@brak', '')
 Set @Schemat = Replace(@Schemat, '@numerS/', Case @NumerNr When 0 Then '' Else @NumerStrS+'/' End)
 Set @Schemat = Replace(@Schemat, '/@numerS', Case @NumerNr When 0 Then '' Else '/'+@NumerStrS End)
 Set @Schemat = Replace(@Schemat, '@numer/', Case @NumerNr When 0 Then '' Else @NumerStr+'/' End)
 Set @Schemat = Replace(@Schemat, '/@numer', Case @NumerNr When 0 Then '' Else '/'+@NumerStrS End)
 Set @Schemat = Replace(@Schemat, '@symbol', @Symbol)
 Set @Schemat = Replace(@Schemat, '@rok_kal', Str(Floor(@RokMc/100),4))
 Set @Schemat = Replace(@Schemat, '@miesiac', Replace(Str(@RokMc % 100,2),' ', '0'))
 Declare @TypStr NVARCHAR(6)
 Set @TypStr = Case @TypDekl
  When 1 Then 'VAT7'
  When 2 Then case when @Wersja >= 16 then 'PIT'   else 'PIT5' end
  When 3 Then case when @Wersja >= 18 then 'PIT4R' else 'PIT4' end
  When 4 Then 'ZNPR'
  When 5 Then 'PIT11'
  When 6 Then 'PIT8A'
  When 7 Then 'PIT8B'
  When 8 Then case when @Wersja >= 18 then 'CIT'   else 'CIT2' end
  When 9 Then 'PIT40'
  When 10 Then 'IFT1'
  When 11 Then 'VATUE'
  When 12 Then case when @Wersja >= 4 then 'PPL'   else 'PIT5L' end
  When 15 Then 'PIT36'
  When 16 Then 'P36L'
  When 17 Then 'CIT8'
  When 20 Then 'PIT28'
  When 40 Then 'CIT'
  When 41 Then 'PIT_U'
  When 42 Then 'PPL_U'
  When 43 Then 'VAT8'
  When 100 Then 'ZUA'
  When 101 Then 'ZIUA'
  When 102 Then 'ZCNA'
  When 103 Then 'ZCZA'
  When 104 Then 'ZWUA'
  When 105 Then 'ZZA'
  When 120 Then 'DRA'
  When 121 Then 'RCA'
  When 122 Then 'RNA'
  When 123 Then 'RZA'
  When 124 Then 'RSA'
  When 125 Then 'RGA'
  When 125 Then 'RGA'
  When 401 Then 'AKCWW'
  When 404 Then 'VAT9M'
  When 500 Then 'PPK'
  Else '' End
 Set @Schemat = Replace(@Schemat, '@rejestr', @TypStr)
 If CharIndex('@rok_obr', @Schemat) <> 0
 Begin
  If Not Exists (Select * From CDN.OkresyObrach Where CDN.EOMonth(@RokMc) Between OOb_DataOtw And OOb_DataKoncowa) Break
  Select @RokObr=OOb_Symbol From CDN.OkresyObrach Where CDN.EOMonth(@RokMc) Between OOb_DataOtw And OOb_DataKoncowa
  Set @Schemat = Replace(@Schemat, '@rok_obr', @RokObr)
 End
 Set @Numer = @Schemat
 Break
End
Return @Numer
End
