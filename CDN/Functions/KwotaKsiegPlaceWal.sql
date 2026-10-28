Create Function CDN.KwotaKsiegPlaceWal (@WpEId Int, @Tryb NVARCHAR(20))
Returns Numeric (15,2)
As
Begin
Declare @Wynik Numeric(15,2)
If @Tryb = 'ZAS OPOD'
 Select @Wynik = Sum(WpE_WartoscWal)
  From CDN.WypElementy
  Join CDN.TypWyplata On WpE_TWPId = TWP_TWPId
  Join CDN.PozDeklZUS On TWP_PDZId = PDZ_PDZId
 Where WPE_WpeId = @WpEId
 And TWP_Standardowy not in (40, 41, 42, 43, 44)
  And TWP_RodzajFis In (2, 3, 7)
  And (PDZ_Kod In ('0010', '0011', '0012', '100', '121', '122') Or PDZ_Kod Between '311' And '328' Or PDZ_Kod Between '211' And '216')
Else If @Tryb = 'ZAS NOPOD'
 Select @Wynik = Sum(WpE_WartoscWal)
  From CDN.WypElementy
  Join CDN.TypWyplata On WpE_TWPId = TWP_TWPId
  Join CDN.PozDeklZUS On TWP_PDZId = PDZ_PDZId
 Where WPE_WpeId = @WpEId
  And TWP_Standardowy not in (40, 41, 42, 43, 44)
  And TWP_RodzajFis = 1
  And (PDZ_Kod In ('0010', '0011', '0012', '100', '121', '122', '211', '212', '213', '325', '327', '329') Or PDZ_Kod Between '311' And '322')
Else If @Tryb = 'DOD OPOD'
 Select @Wynik = Sum(WpE_WartoscWal)
  From CDN.WypElementy
  Join CDN.TypWyplata On WpE_TWPId = TWP_TWPId
  Join CDN.PozDeklZUS On TWP_PDZId = PDZ_PDZId
 Where WPE_WpeId = @WpEId
  And TWP_RodzajFis In (2, 3, 7) And TWP_RodzajZrodla = 4
  And Not (PDZ_Kod In ('01', '0010', '0011', '0012', '100', '121', '122', '211', '212', '213') Or PDZ_Kod Between '311' And '322')
  And WpE_Wartosc > 0
Else If @Tryb = 'DOD NOPOD'
 Select @Wynik = Sum(WpE_WartoscWal)
  From CDN.WypElementy
  Join CDN.TypWyplata On WpE_TWPId = TWP_TWPId
  Join CDN.PozDeklZUS On TWP_PDZId = PDZ_PDZId
 Where WPE_WpeId = @WpEId
  And TWP_RodzajFis = 1 And TWP_RodzajZrodla = 4
  And Not (PDZ_Kod In ('01', '0010', '0011', '0012', '100', '121', '122', '211', '212', '213') Or PDZ_Kod Between '311' And '322')
  And WpE_Wartosc > 0
Else If @Tryb = 'POTR OPOD'
 Select @Wynik = Sum(WpE_WartoscWal)
  From CDN.WypElementy
  Join CDN.TypWyplata On WpE_TWPId = TWP_TWPId
  Join CDN.PozDeklZUS On TWP_PDZId = PDZ_PDZId
 Where WPE_WpeId = @WpEId
  And TWP_RodzajFis In (2, 3, 7)
  And Not (PDZ_Kod In ('01', '0010', '0011', '0012', '100', '121', '122', '211', '212', '213') Or PDZ_Kod Between '311' And '322')
  And WpE_Wartosc < 0
Else If @Tryb = 'POTR NOPOD'
 Select @Wynik = Sum(WpE_WartoscWal)
  From CDN.WypElementy
  Join CDN.TypWyplata On WpE_TWPId = TWP_TWPId
  Join CDN.PozDeklZUS On TWP_PDZId = PDZ_PDZId
 Where WPE_WpeId = @WpEId
  And TWP_RodzajFis = 1
  And Not (PDZ_Kod In ('01', '0010', '0011', '0012', '100', '121', '122', '211', '212', '213') Or PDZ_Kod Between '311' And '322')
  And WpE_Wartosc < 0
Return IsNull(@Wynik, 0)
End
