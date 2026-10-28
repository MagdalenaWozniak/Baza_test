CREATE FUNCTION CDN.ListaZasobow (@Magazyn INT, @Typ INT)
RETURNS @Zasoby TABLE  (Zas_TwrId INT PRIMARY KEY (Zas_TwrId))
AS
BEGIN
   IF @Typ = 1
    BEGIN
      INSERT INTO @Zasoby (Zas_TwrID)
       SELECT DISTINCT TrE_TwrID from CDN.TraElem  JOIN CDN.TraNag ON
       (TrN_TrnId=TrE_TrNId AND TrN_TypDokumentu<>310 AND TrN_Rodzaj<>310000 AND TrN_Bufor<>-1 AND TrN_MagZrdID=@Magazyn)
       OR (Trn_TrnID=TrE_TrNID AND TrN_TypDokumentu=310 and TrN_Rodzaj=310000 and trn_bufor=0 AND TrN_MagZrdID=@Magazyn)
       OR (Trn_TrnID=TrE_TrNID AND TrN_TypDokumentu=312 and trn_Rodzaj in (312000,312010,312008) and trn_bufor=0 AND TrN_MagDocID=@Magazyn)
    END
   IF @Typ = 2
    BEGIN
     INSERT INTO @Zasoby (Zas_TwrId)
       SELECT DISTINCT TrE_TwrID from CDN.TraElem  JOIN CDN.TraNag ON
         TrN_TrnId=TrE_TrNId AND TrN_TypDokumentu=311 AND TrN_Rodzaj=311000 AND TrN_Bufor=0 AND TrN_MagZrdID=@Magazyn
     END
RETURN
END
