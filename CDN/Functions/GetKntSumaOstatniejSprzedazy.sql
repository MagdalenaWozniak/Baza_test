CREATE FUNCTION CDN.GetKntSumaOstatniejSprzedazy(@kntId int, @dokumentId int, @operatorId int)
RETURNS nvarchar(255)
AS
BEGIN
 IF @dokumentId NOT IN (302, 305, 306, 308, 320) OR @kntId = 1
  RETURN 'Informacje o kontrahencie'
 DECLARE @suma decimal(15,2)
 SELECT @suma = SUM(A.TrN_RazemBrutto)
 FROM CDN.TraNag A LEFT JOIN CDN.TraNag B ON A.TrN_FaId = B.TrN_TrNID
 WHERE A.TrN_PodmiotTyp = 1
 AND A.TrN_PodID IN (SELECT Knt_KntId FROM CDN.Kontrahenci WHERE Knt_GlID = @kntId)
 AND A.TrN_Anulowany = 0
 AND A.TrN_DataWys >= GETDATE() - 90
 AND (A.TrN_TypDokumentu = 305 OR (A.TrN_TypDokumentu = 302 AND (B.TrN_TypDokumentu IS NULL OR B.TrN_TypDokumentu <> 305)))
 AND A.TrN_Rodzaj NOT IN (302100, 305100)
 RETURN 'Wartość sprzedaży z ost. 3 miesięcy: ' + CDN.FormatDecimalAmount(@suma) + ' PLN'
END
