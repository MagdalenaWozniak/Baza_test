CREATE PROCEDURE CDN.DeleteSubItems
@ParentItemId int,
@ItemType int
AS
BEGIN
 /*
 IT_ATR = 0, IT_DEFDOK = 1, IT_KATEG = 2, IT_BANKI = 3, IT_URZEDY = 4, IT_PRAC = 5, IT_WSPOL = 6,
 IT_RACHUN = 7, IT_FORMY = 8, IT_KONTR = 9, IT_WALUTY = 10, IT_KURSY = 11, IT_NOTOW = 12,
 IT_FAKSPRZ = 13, IT_FAKZAK = 14, IT_FAKWEWSPRZ = 15, IT_FAKWEWZAK = 16,
 IT_REJSPRZ = 17, IT_REJZAK = 18, IT_DOKTAX = 19, IT_DOKINNEPRZ = 20, IT_DOKINNEKOSZT = 21,
 IT_EWIDDODPRZ = 22, IT_EWIDDODKOSZT = 23, IT_RAPKAS = 24, IT_PLAT = 25, IT_ROZL = 26
 */
 IF(@ItemType = 0) -- jesli typ = atrybuty usuwamy lelementy list atrybutów
 BEGIN
  DELETE
  FROM CDN.DefAtrElem
  WHERE DAE_DeAId = @ParentItemId
 END
 IF (@ItemType = 4) --jeśli typ = urzedy usuwamy rachunki dla urzedów
 BEGIN
  DELETE
  FROM CDN.UrzRachunki
  WHERE
  URa_UrzId = @ParentItemId
  AND URa_Lp > 0 -- aby nie usuwał indywidualnych rachunków ZUS (228827)
  RETURN
 END
 IF(@ItemType = 5 OR @ItemType = 6) --jeśli typ = pracownik or wspolnik usuwamy schematy platnosci
 BEGIN
  DELETE
  FROM CDN.SchematPlatnosci
  WHERE (SPL_PodmiotTyp = 3 OR SPL_PodmiotTyp = 4) AND SPL_PodmiotId = @ParentItemId
  RETURN
 END
 IF(@ItemType = 9) --jesli typ = kontrahent usuwamy osoby oraz atrybuty dla danego kontrahenta
 BEGIN
  DELETE
  FROM CDN.KntOsoby
  WHERE KnO_kntId = @ParentItemId
  DELETE
  FROM CDN.KntAtrybuty
  WHERE KnA_PodmiotId = @ParentItemId AND KnA_PodmiotTyp = 1
  DELETE
  FROM CDN.KntOdbiorcy
  WHERE Odb_KntOdbID = @ParentItemId
 /* DELETE
  FROM CDN.SchematPlatnosci
  WHERE Spl_PodmiotTyp=1 AND Spl_PodmiotID = @ParentItemId
  DELETE
  FROM CDN.Rabaty
  WHERE Rab_PodmiotTyp = 1 AND Rab_PodmiotId = @ParentItemId*/
  RETURN
 END
 IF(@ItemType = 8) --jeśli typ = formy platnosci usuwamy podpięte rachunki walutowe
 BEGIN
  DELETE
  FROM CDN.FormyPlatnWaluty
  WHERE FPW_FplId = @ParentItemId
 END
END
