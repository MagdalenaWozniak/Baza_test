Create Procedure CDN.KasujRozliczenia @DokTyp Int, @DokId Int
As
Begin
Set NoCount On
Declare @KasujAutomatyczne TinyInt
Set @KasujAutomatyczne = 1
DECLARE @DokTypStr VARCHAR(10)
SELECT @DokTypStr = CONVERT(VARCHAR(10), @DokTyp)
DECLARE @DokTyp2Str VARCHAR(10)
SELECT @DokTyp2Str = CONVERT(VARCHAR(10), Case @DokTyp When 1 Then 101 Else @DokTyp End)
DECLARE @DokIDStr VARCHAR(10)
SELECT @DokIDStr = CONVERT(VARCHAR(10), @DokID)
DECLARE @fromParam NVARCHAR(1024)
DECLARE @whereParam NVARCHAR(1024)
If Not Exists (Select * From CDN.Firma Where Fir_Numer = 1394 And Fir_Wartosc = '1')
 Set @KasujAutomatyczne = 0
If Not Exists (Select * From CDN.BnkRozKwoty
 Where BRK_BRKId In (
  Select BRR_BRKId From CDN.BnkRozRelacje Join CDN.BnkZdarzenia On BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID
  Where BZd_DokumentTyp In (@DokTyp, Case @DokTyp When 1 Then 101 Else @DokTyp End) And BZd_DokumentID = @DokId
  )
   And (@KasujAutomatyczne = 1 Or BRK_AutoOffLine=1)
  )
 Begin
 If Exists (Select * From CDN.BnkZdarzenia
   Where BZd_DokumentTyp In (@DokTyp, Case @DokTyp When 1 Then 101 Else @DokTyp End) And BZd_DokumentID = @DokId And BZd_Stan > 1
   And Not Exists (Select * From CDN.BnkRozRelacje Where BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID))
   Begin
     Alter Table CDN.BnkZdarzenia Disable Trigger All
   SELECT @whereParam = 'BZd_DokumentTyp In (' + @DokTypStr + ', ' + @DokTyp2Str + ') And BZd_DokumentID = ' + @DokIDStr + ' And BZd_Stan > 1 ' +
   'And Not Exists (Select * From CDN.BnkRozRelacje Where BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID)'
   exec cdn.RejestrOperacjiDodajEx @ObiektTyp = '1001', @ObiektSubTyp = 'BZd_Kierunek', @ObiektID = 'BZd_BZdID', @ObiektNazwa = 'CASE WHEN BZd_NumerPelny<>'''' THEN BZd_NumerPelny ELSE (CASE WHEN BZd_DokumentTyp = 0 THEN BZd_NumerObcy ELSE '''' END) END',
          @OperacjaTyp = 2, @Opis = 'BZd_Opis', @From = 'cdn.BnkZdarzenia', @Where = @whereParam
     Update CDN.BnkZdarzenia Set BZd_Stan = 1
      Where BZd_DokumentTyp In (@DokTyp, Case @DokTyp When 1 Then 101 Else @DokTyp End) And BZd_DokumentID = @DokId And BZd_Stan > 1
      And Not Exists (Select * From CDN.BnkRozRelacje Where BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID)
     Alter Table CDN.BnkZdarzenia Enable Trigger All
    End
  Return
 End
Select BZp_BZpID, BZp_Kierunek, BZp_NumerPelny
InTo #BZpAuto
From CDN.BnkZdarzenia
 Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID
 Join CDN.BnkZapisy On BRR_DDokTyp = 2 And BRR_DDokID = BZp_BZpID
 Where BZd_DokumentTyp In (@DokTyp, Case @DokTyp When 1 Then 101 Else @DokTyp End) And BZd_DokumentID = @DokId
   And (@KasujAutomatyczne = 1 And BZp_ZapisAutomatyczny = 1 Or BZp_AutoOffLine = 1 Or BZd_DokumentTyp=108)
Alter Table CDN.BnkZdarzenia Disable Trigger All
-- Ponieważ trigger na BnkZdarzenia jest zdisablowany, trzeba ręcznie zaktualizować limit kredytowy
Update CDN.Kontrahenci
Set Knt_LimitKredytuWykorzystany = Knt_LimitKredytuWykorzystany + BZd_ZmianaLimitu,
    Knt_TS_Export = Knt_TS_Export
From
 CDN.Kontrahenci
 Join (Select BZd_PodmiotId, BZd_ZmianaLimitu = Sum (BZd_Kierunek * BRK_KwotaSys)
       From CDN.BnkZdarzenia
       Join (Select BRR_ZDokTyp, BRR_ZDokId, BRK_KwotaSys = Case When BRR_ZDokTyp=BRK_LDokTyp And BRR_ZDokId=BRK_LDokId Then BRK_KwotaSysL Else BRK_KwotaSysP End
             From CDN.BnkRozRelacje
             Join CDN.BnkRozKwoty On BRR_BRKId = BRK_BRKId
             Join CDN.BnkZdarzenia On BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID
             Where BZd_DokumentTyp In (@DokTyp, Case @DokTyp When 1 Then 101 Else @DokTyp End) And BZd_DokumentID = @DokId
             Union All
            Select BRR_DDokTyp, BRR_DDokId, BRK_KwotaSys = Case When BRR_DDokTyp=BRK_LDokTyp And BRR_DDokId=BRK_LDokId Then BRK_KwotaSysL Else BRK_KwotaSysP End
             From CDN.BnkRozRelacje
             Join CDN.BnkRozKwoty On BRR_BRKId = BRK_BRKId
             Join CDN.BnkZdarzenia On BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID
             Where BZd_DokumentTyp In (@DokTyp, Case @DokTyp When 1 Then 101 Else @DokTyp End) And BZd_DokumentID = @DokId
            ) As Rozliczenia
        On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
       Where BZd_PodmiotTyp = 1 And BZd_Rozliczono > 0
       Group By BZd_PodmiotId)  As Kwoty
 On Knt_KntId = BZd_PodmiotId
SELECT @fromParam = 'CDN.BnkRozKwoty JOIN CDN.BnkZdarzenia ON (BRK_LDokTyp = 1 And BRK_LDokID = BZd_BZdID OR BRK_PDokTyp = 1 And BRK_PDokID = BZd_BZdID)'
SELECT @whereParam = 'BRK_BRKID In (Select BRR_BRKId From CDN.BnkRozRelacje Join CDN.BnkZdarzenia Z On BRR_ZDokTyp = 1 And BRR_ZDokID = Z.BZd_BZdID WHERE ' +
     'Z.BZd_DokumentTyp In (' + @DokTypStr + ', ' + @DokTyp2Str + ') And Z.BZd_DokumentID = ' + @DokIdStr + ') And (' + CONVERT(VARCHAR(1), @KasujAutomatyczne) + '= 1 Or BRK_AutoOffLine=1)'
exec cdn.RejestrOperacjiDodajEx @ObiektTyp = '1001', @ObiektSubTyp = 'BZd_Kierunek', @ObiektID = 'BZd_BZdID', @ObiektNazwa = 'CASE WHEN BZd_NumerPelny<>'''' THEN BZd_NumerPelny ELSE (CASE WHEN BZd_DokumentTyp = 0 THEN BZd_NumerObcy ELSE '''' END) END',
        @OperacjaTyp = 111, @Opis = 'BZd_Opis', @From = @fromParam, @Where = @whereParam
SELECT @fromParam = 'CDN.BnkRozKwoty JOIN CDN.BnkZapisy ON (BRK_LDokTyp = 2 And BRK_LDokID = BZp_BZpID OR BRK_PDokTyp = 2 And BRK_PDokID = BZp_BZpID)'
SELECT @whereParam = 'BRK_BRKID In (Select BRR_BRKId From CDN.BnkRozRelacje Join CDN.BnkZdarzenia Z On BRR_ZDokTyp = 1 And BRR_ZDokID = Z.BZd_BZdID WHERE ' +
     'Z.BZd_DokumentTyp In (' + @DokTypStr + ', ' + @DokTyp2Str + ') And Z.BZd_DokumentID = ' + @DokIdStr + ') And (' + CONVERT(VARCHAR(1), @KasujAutomatyczne) + '= 1 Or BRK_AutoOffLine=1)'
exec cdn.RejestrOperacjiDodajEx @ObiektTyp = '1000', @ObiektSubTyp = 'BZp_Kierunek', @ObiektID = 'BZp_BZpID', @ObiektNazwa = 'BZp_NumerPelny',
        @OperacjaTyp = 111, @Opis = 'BZp_Opis', @From = @fromParam, @Where = @whereParam
Delete From CDN.BnkRozKwoty
 Where BRK_BRKId In (
  Select BRR_BRKId From CDN.BnkRozRelacje Join CDN.BnkZdarzenia On BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID
  Where BZd_DokumentTyp In (@DokTyp, Case @DokTyp When 1 Then 101 Else @DokTyp End) And BZd_DokumentID = @DokId
  )
   And (@KasujAutomatyczne = 1 Or BRK_AutoOffLine=1)
   /*
select * From CDN.BnkRozKwoty JOIN CDN.BnkZdarzenia On (BRK_LDokTyp = 1 And BRK_LDokID = BZd_BZdID OR BRK_PDokTyp = 1 And BRK_PDokID = BZd_BZdID)
 Where BRK_BRKId In (
  Select BRR_BRKId From CDN.BnkRozRelacje Join CDN.BnkZdarzenia On BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID
  Where BZd_DokumentTyp In (101, 1) And BZd_DokumentID = 8
  )
   And (1 = 1 Or BRK_AutoOffLine=1)
   */
Update CDN.BnkZdarzenia Set BZd_Stan = 1
 Where BZd_DokumentTyp In (@DokTyp, Case @DokTyp When 1 Then 101 Else @DokTyp End) And BZd_DokumentID = @DokId
   And Not Exists (Select * From CDN.BnkRozRelacje Where BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID)
SELECT @whereParam = 'BZd_DokumentTyp In (' + @DokTypStr + ', ' + @DokTyp2Str + ') And BZd_DokumentID = ' + @DokIdStr +
 'And Not Exists (Select * From CDN.BnkRozRelacje Where BRR_ZDokTyp = 1 And BRR_ZDokID = BZd_BZdID)'
exec cdn.RejestrOperacjiDodajEx @ObiektTyp = '1001', @ObiektSubTyp = 'BZd_Kierunek', @ObiektID = 'BZd_BZdID', @ObiektNazwa = 'CASE WHEN BZd_NumerPelny<>'''' THEN BZd_NumerPelny ELSE (CASE WHEN BZd_DokumentTyp = 0 THEN BZd_NumerObcy ELSE '''' END) END',
        @OperacjaTyp = 2, @Opis = 'BZd_Opis', @From = 'cdn.BnkZdarzenia', @Where = @whereParam
Alter Table CDN.BnkZdarzenia Enable Trigger All
Declare zapisy Cursor Local Fast_Forward For Select BZp_BZpID, BZp_Kierunek, BZp_NumerPelny From #BZpAuto
Declare @BzpAutoId Int
Declare @BzpAutoKierunek Int
Declare @BzpNumerPelny NVARCHAR(256)
Open zapisy
While 1=1
 Begin
  Fetch Next From zapisy InTo @BZpAutoId, @BzpAutoKierunek, @BzpNumerPelny
  If @@Fetch_Status <> 0 Break
  exec CDN.RejestrOperacjiDodaj 1000, @BzpAutoKierunek, @BZpAutoId, @BzpNumerPelny, 3, ''
  Delete From CDN.BnkZapisy Where BZp_BZpId = @BZpAutoId
 End
Close zapisy
Deallocate zapisy
Drop Table #BZpAuto
Set NoCount Off
End
