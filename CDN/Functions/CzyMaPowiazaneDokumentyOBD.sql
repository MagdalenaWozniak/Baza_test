CREATE FUNCTION CDN.CzyMaPowiazaneDokumentyOBD(@DokumentTyp INT, @DokumentID INT, @SprawdzajTylkoIBard24 INT)
RETURNS TINYINT
/*
  Procedura zwraca info czy są (1) jakieś dokumenty OBD skojarzone z dokumentem o podanym typie i ID, w których istnieją pliki związane z IBard24 czy też takich dokumentów nie ma (0).
  Dla wszystkich dokumentów zapisywanych w TraNag należy przesłać zbiorczy, umowny typ 300; właściwy typ zostanie wówczas odczytany z nagłówka dokumentu (TrN_TypDokumentu).
*/
AS
BEGIN
 IF @DokumentTyp = 300
   -- Eksportujemy OBD związane z dokumentem TraNag. W kodzie op_ImpExp nie jesteśmy w stanie przewidzieć typu, dlatego dla TraNag-a zawsze przesyłamy 300.
   -- Właściwy typ dla WHERE-a na DokRelacje trzeba odczytać z nagłówka dokumentu.
  -- Pozostałe typy przekazujemy 1:1.
  SELECT @DokumentTyp = TrN_TypDokumentu FROM CDN.TraNag WHERE TrN_TrNID = @DokumentID
  DECLARE @cnt INT
  SELECT @cnt = COUNT(*)
   FROM CDN.DokRelacje
   join CDN.DokNag on DoR_ParentTyp = 750 and DoN_DoNID = DoR_ParentId
   join CDN.DokDefinicje ON DDf_DDfID = DoN_DDfId
   /* left outer */ inner join CDN.DokNagPliki on DnP_DoNID = DoN_DoNID -- dajemy inner, bo jak z dokumentem OBD nie są związane pliki, to go nie eksportujemy
   left outer join CDN.DaneBinarne A ON A.DaB_Typ = 2 AND A.DAB_TwAID = DnP_DnPID -- musi być left outer, bo jak jest link do pliku lub ibard-a to nie bedzie powiązania z daną binarną
   WHERE DoR_ParentTyp = 750 and DoR_DokumentTyp = @DokumentTyp and DoR_DokumentId = @DokumentID AND (@SprawdzajTylkoIBard24 = 0 OR DnP_WBazie = 2)
  IF @cnt > 0
   RETURN 1
  RETURN 0
END
