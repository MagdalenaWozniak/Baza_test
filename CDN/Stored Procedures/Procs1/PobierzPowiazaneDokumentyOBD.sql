CREATE PROCEDURE CDN.PobierzPowiazaneDokumentyOBD(@DokumentTyp INT, @DokumentID INT)
/*
  Procedura zwraca dokumenty OBD (wraz z podpiętymi plikami oraz danymi binarnymi!) skojarzone z dokumentem o podanym typie i ID.
  Dla wszystkich dokumentów zapisywanych w TraNag należy przesłać zbiorczy, umowny typ 300; właściwy typ zostanie wówczas odczytany z nagłówka dokumentu (TrN_TypDokumentu).
  Jeśli dokument OBD posiada wiele plików, to jest dla niego generowanych tyle rekordów wyniku ile jest plików.
*/
AS
BEGIN
 IF @DokumentTyp = 300
   -- Eksportujemy OBD związane z dokumentem TraNag. W kodzie op_ImpExp nie jesteśmy w stanie przewidzieć typu, dlatego dla TraNag-a zawsze przesyłamy 300.
   -- Właściwy typ dla WHERE-a na DokRelacje trzeba odczytać z nagłówka dokumentu.
  -- Pozostałe typy przekazujemy 1:1.
   SELECT @DokumentTyp = TrN_TypDokumentu FROM CDN.TraNag WHERE TrN_TrNID = @DokumentID
  SELECT
   DoN_ImportRowID, DoN_DDfID,
   DDf_ImportRowID, DDf_Symbol, DDf_Numeracja,
   DoN_NumerString, DoN_NumerNr, DoN_NumerPelny, DoN_NumerObcy, DoN_DataDok, DoN_Tytul, DoN_Dotyczy, DoN_Typ, DoN_Katalog, DoN_Status, DoN_OriginId,
   DnP_WBazie, DnP_NazwaPliku, DnP_Sciezka, DnP_Wersja, DnP_FileMode, DnP_DataDok, DnP_Typ, DnP_Archiwalny,
   DnPID = NULL,
   DAB_DABID, DAB_MagazynDanych, DAB_MagazynDanychID, DAB_Typ, DAB_Flaga,
   DAB_Wartosc =
   CASE DnP_WBazie
   WHEN 0 THEN
    NULL -- Dane w pliku - zostaną one wyeksportowane do XML-a z poziomu op_impexp (klasa FileContentPtrField)
   WHEN 1 THEN
    (SELECT
     CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'NVARCHAR(MAX)') Base64Encoding
     FROM (SELECT CAST((select B.DAB_Wartosc from CDN.DaneBinarne B where B.DAB_DABID = A.DAB_DABID) AS VARBINARY(MAX)) AS bin) AS myBase64Content
    )
   WHEN 2 THEN
    NULL
   END,
   DAB_Rozmiar, DAB_NazwaPliku, DAB_Nazwa, DAB_Rozszerzenie, DAB_Sciezka, DAB_Wersja, DAB_IBard24ID, DAB_IBard24LinkPrywatny
  FROM CDN.DokRelacje
  join CDN.DokNag on DoR_ParentTyp = 750 and DoN_DoNID = DoR_ParentId
  join CDN.DokDefinicje ON DDf_DDfID = DoN_DDfId
  /* left outer */ inner join CDN.DokNagPliki on DnP_DoNID = DoN_DoNID -- dajemy inner, bo jak z dokumentem OBD nie są związane pliki, to go nie eksportujemy
  left outer join CDN.DaneBinarne A ON A.DaB_Typ = 2 AND A.DAB_TwAID = DnP_DnPID -- musi być left outer, bo jak jest link do pliku lub ibard-a to nie bedzie powiązania z daną binarną
  WHERE DoR_ParentTyp = 750 and DoR_DokumentTyp = @DokumentTyp and DoR_DokumentId = @DokumentID
END
