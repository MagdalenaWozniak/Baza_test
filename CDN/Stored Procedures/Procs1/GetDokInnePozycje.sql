CREATE PROCEDURE CDN.GetDokInnePozycje
@DokId int
AS
BEGIN
 DECLARE @typDok TINYINT;
 SELECT @typDok =
  CASE WHEN TrN_TypDokumentu In (304, 306, 314, 318) THEN 1 -- Dokument przychodowy
  ELSE 0 END
 FROM CDN.TraNag WHERE TrN_TrNID = @DokId
 -- dokumenty kosztowe: zawsze z WartoscNetto eksportujemy
 IF(@typDok=0 OR (SELECT Fir_Wartosc FROM cdn.firma WHERE fir_numer = 1542) = 1)
  Select IsNull(Kat_ImportRowId, '') As Kat_ImportRowId,
  IsNull(Kat_KodSzczegol, '') As Kat_KodSzczegol,
  IsNull(Kat_Opis, '') As Kdd_Opis,
  Sum(A.TrE_WartoscNetto + IsNull(B.TrE_WartoscNetto, 0)) As TrE_Wartosc,
  '' as Kdd_Segment1,
  '' as Kdd_Segment2,
  0 as Kdd_Wartosc2,
  0 as Kdd_Wartosc1
  From CDN.TraElem A
      Left Outer Join CDN.TraElem B ON B.TrE_ZwrId = A.TrE_TrEID AND EXISTS (SELECT * FROM cdn.TraNag WHERE TrN_TrNID = B.TrE_TrNId AND TrN_Korekta = 8 AND TrN_Rodzaj not in (306061,306071,306072) AND TrN_Bufor <> -1)
      Left Outer Join CDN.Kategorie On A.TrE_KatId=Kat_KatId
  Where A.TrE_TrNId = @DokId
  Group By Kat_ImportRowId, Kat_KodSzczegol, Kat_Opis
  Having IsNull(Sum(A.TrE_WartoscZakupu + IsNull(B.TrE_WartoscZakupu, 0)), 0) <> 0
 ELSE
  Select IsNull(Kat_ImportRowId, '') As Kat_ImportRowId,
  IsNull(Kat_KodSzczegol, '') As Kat_KodSzczegol,
  IsNull(Kat_Opis, '') As Kdd_Opis,
  Sum(A.TrE_WartoscZakupu + IsNull(B.TrE_WartoscZakupu, 0)) As TrE_Wartosc,
  '' as Kdd_Segment1,
  '' as Kdd_Segment2,
  0 as Kdd_Wartosc2,
  0 as Kdd_Wartosc1
  From CDN.TraElem A
      Left Outer Join CDN.TraElem B ON B.TrE_ZwrId = A.TrE_TrEID AND EXISTS (SELECT * FROM cdn.TraNag WHERE TrN_TrNID = B.TrE_TrNId AND TrN_Korekta = 8 AND TrN_Rodzaj not in (306061,306071,306072) AND TrN_Bufor <> -1)
      Left Outer Join CDN.Kategorie On A.TrE_KatId=Kat_KatId
  Where A.TrE_TrNId = @DokId
  Group By Kat_ImportRowId, Kat_KodSzczegol, Kat_Opis
  Having IsNull(Sum(A.TrE_WartoscZakupu + IsNull(B.TrE_WartoscZakupu, 0)), 0) <> 0
END
