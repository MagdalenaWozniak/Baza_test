CREATE VIEW CDN.ZasobyView
As
Select
P.RpT2_Rpt2ID    As TwZV_RpT2Id,
A.Twr_TwrId      As TwZV_TwrId,
A.Twr_Typ        As TwZV_TwrTyp,
A.Twr_Produkt    As TwZV_Produkt,
A.Twr_Kod        As TwZV_Kod,
A.Twr_NumerKat   As TwZV_NumerKat,
A.Twr_Nazwa      As TwZV_Nazwa,
E.Sciezka        As TwZV_Grupa,
A.Twr_KatId      As TwZV_KatId,
A.Twr_Kategoria  As TwZV_Kategoria,
A.Twr_KatZakId   As TwZV_KatZakId,
A.Twr_Opis       As TwZV_Opis,
A.Twr_JM         As TwZV_Jm,
A.Twr_JMZ        As TwZV_JmZ,
A.Twr_TwCNumer   As TwZV_TwCNumer,
B.TwI_MagId      As TwZV_MagId,
B.TwI_Data       As TwZV_Data,
B.TwI_Ilosc      As TwZV_Ilosc,
B.TwI_Braki      As TwZV_Braki,
B.TwI_Rezerwacje As TwZV_Rezerwacje,
B.TwI_Zamowienia As TwZV_Zamowienia,
B.TwI_Wartosc    As TwZV_Wartosc,
D.TwC_Wartosc    As TwZV_Cena,
D.TwC_Waluta     As TwZV_Waluta,
B.TwI_TwIId      As TwZV_TwIId
From CDN.RptTemp2 P join CDN.Towary A On 1=1
Left Outer Join CDN.TwrIlosci B
  On A.Twr_TwrID = B.TwI_TwrID
 And ( P.RpT2_TmpId Is Not Null Or B.TwI_MagId IS NULL )
 And ( P.RpT2_TmpId Is Null Or B.TwI_MagId = P.RpT2_TmpId )
 And B.TwI_Data = (
    Select Top 1 H.TwI_Data From CDN.TwrIlosci H Where H.TwI_TwrId = A.Twr_TwrId
    And ( P.RpT2_TmpId Is Not Null Or H.TwI_MagId Is Null )
    And ( P.RpT2_TmpId Is Null Or H.TwI_MagId = P.RpT2_TmpId )
    And H.TwI_Data <= P.RpT2_Data
    Order By H.TwI_Data Desc )
Left Outer Join CDN.Magazyny C ON B.TwI_MagId= C.Mag_MagId
Left Outer Join CDN.TwrCeny D ON A.Twr_TwrId= D.TwC_TwrID AND A.Twr_TwCNumer = D.TwC_TwCNumer
Left Outer Join CDN.TwrGrupyView E ON A.Twr_TwGGIDNumer = E.GIDNumer
