CREATE  PROCEDURE CDN.GetRapKasBnkPozycje
@DokId int
AS
BEGIN
 IF((SELECT Fir_Wartosc FROM cdn.firma WHERE fir_numer = 1542) = 1)
  Select IsNull(Kat_ImportRowId, '') As Kat_ImportRowId,
  IsNull(Kat_KodSzczegol, '') As Kat_KodSzczegol,
  Sum(TrE_WartoscNetto) As TrE_Wartosc
  From CDN.TraElem Left Outer Join CDN.Kategorie On TrE_KatId=Kat_KatId
  Where TrE_TrNId = @DokId
  Group By Kat_ImportRowId, Kat_KodSzczegol
  Having IsNull(Sum(TrE_WartoscZakupu), 0) <> 0
 ELSE
  Select IsNull(Kat_ImportRowId, '') As Kat_ImportRowId,
  IsNull(Kat_KodSzczegol, '') As Kat_KodSzczegol,
  Sum(TrE_WartoscZakupu) As TrE_Wartosc
  From CDN.TraElem Left Outer Join CDN.Kategorie On TrE_KatId=Kat_KatId
  Where TrE_TrNId = @DokId
  Group By Kat_ImportRowId, Kat_KodSzczegol
  Having IsNull(Sum(TrE_WartoscZakupu), 0) <> 0
END
