CREATE PROCEDURE CDN.KorektaPodatkuDochodowegoZD_UsunietePozycjeKorekty(
@PraID INTEGER,
@Rok INTEGER
)
AS
BEGIN
SELECT * FROM (
SELECT BZd_NumerPelny AS NumerDokumentu, VaN_KntNazwa1 + ' ' + VaN_KntNazwa2 + ' ' + VaN_KntNazwa3 AS Kontrahent, VaN_KntNipE AS NIP, VaN_DataWys AS DataWystawienia,
BZd_Termin AS TerminPlatnosci, BZd_TerminR AS TerminPlatnosciR, BZd_Kwota AS KwotaPlatnosci,
BZd_DokumentID AS DokumentID, BZd_DokumentTyp AS DokumentTyp, BZd_BZdID AS PlatnoscID,
CDN.KorektaPodatku_UstalRodzaj( BZd_DokumentTyp, VaN_Typ, 0) AS Rodzaj
FROM CDN.BnkZdarzenia
JOIN CDN.VatNag ON BZd_DokumentID = VaN_VaNID AND BZd_DokumentTyp = 2
JOIN CDN.KorektaPodatkuDochodowegoZDZakazy ON KZa_BZdID = BZd_BZdID AND ISNULL(KZa_PraID, 0) = ISNULL(@PraID, 0)
UNION ALL
SELECT BZd_NumerPelny AS NumerDokumentu, EDN_Nazwa1 + ' ' + EDN_Nazwa2 + ' ' + EDN_Nazwa3 AS Kontrahent, EDN_NipE AS NIP, EDN_DataWys AS DataWystawienia,
BZd_Termin AS TerminPlatnosci, BZd_TerminR AS TerminPlatnosciR, BZd_Kwota AS KwotaPlatnosci,
BZd_DokumentID AS DokumentID, BZd_DokumentTyp AS DokumentTyp, BZd_BZdID AS PlatnoscID,
CDN.KorektaPodatku_UstalRodzaj( BZd_DokumentTyp, EDN_Typ, 0) AS Rodzaj
FROM CDN.BnkZdarzenia
JOIN CDN.EwidDodNag ON BZd_DokumentID = EDN_EDNID AND BZd_DokumentTyp = 12
JOIN CDN.KorektaPodatkuDochodowegoZDZakazy ON KZa_BZdID = BZd_BZdID AND ISNULL(KZa_PraID, 0) = ISNULL(@PraID, 0)
UNION ALL
SELECT BZd_NumerPelny AS NumerDokumentu, TrN_PodNazwa1 + ' ' + TrN_PodNazwa2 + ' ' + TrN_PodNazwa3 AS Kontrahent, TrN_PodNipE AS NIP, TrN_DataWys AS DataWystawienia,
BZd_Termin AS TerminPlatnosci, BZd_TerminR AS TerminPlatnosciR, BZd_Kwota AS KwotaPlatnosci,
BZd_DokumentID AS DokumentID, BZd_DokumentTyp AS DokumentTyp, BZd_BZdID AS PlatnoscID,
CDN.KorektaPodatku_UstalRodzaj( BZd_DokumentTyp, TrN_TypDokumentu, 0) AS Rodzaj
FROM CDN.BnkZdarzenia
JOIN CDN.TraNag ON BZd_DokumentID = TrN_TrNID AND BZd_DokumentTyp = 1 AND TrN_TypDokumentu IN (301, 302, 305, 313, 314, 345)
JOIN CDN.KorektaPodatkuDochodowegoZDZakazy ON KZa_BZdID = BZd_BZdID AND ISNULL(KZa_PraID, 0) = ISNULL(@PraID, 0)
) S
WHERE (S.Rodzaj = 1 AND YEAR(S.TerminPlatnosciR) = @Rok) OR (S.Rodzaj = 2 AND YEAR(S.TerminPlatnosciR) BETWEEN @Rok - 3 AND @Rok)
END
