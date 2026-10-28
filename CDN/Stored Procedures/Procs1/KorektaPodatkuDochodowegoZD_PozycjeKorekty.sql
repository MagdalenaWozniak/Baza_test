CREATE PROCEDURE CDN.KorektaPodatkuDochodowegoZD_PozycjeKorekty(
@Rok INTEGER,
@Miesiac INTEGER,
@NaDzien NVARCHAR(20),
@Wierzytelnosci INTEGER,
@WierzytelnosciPrzeterminowane30Dni INTEGER,
@Zobowiazania INTEGER,
@PraID INTEGER,
@TypDeklar INTEGER,
@DkNID INTEGER
)
AS
BEGIN
DECLARE @KoniecMc DATETIME
DECLARE @PoczatekRoku DATETIME
DECLARE @NaDzienD DATETIME
DECLARE @RokMies INTEGER
SET @KoniecMc = DATEADD(day, -1, DATEADD(month, @Miesiac, DATEADD(year, @Rok-1900, 0)));
SET @PoczatekRoku = DATEADD(day, 0, DATEADD(month, 0, DATEADD(year, @Rok-1900, 0)));
SET @NaDzienD = CONVERT(Datetime, @NaDzien, 120);
SET @RokMies = @Rok * 100 + @Miesiac
-- Pierwotna kwalifikacja dokumentów
SELECT
CASE WHEN LEN(BZd_NumerObcy) > 0 THEN BZd_NumerObcy ELSE BZd_NumerPelny END AS NumerDokumentu,
VaN_KntNazwa1 + ' ' + VaN_KntNazwa2 + ' ' + VaN_KntNazwa3 AS Kontrahent,
VaN_KntNipE AS NIP,
VaN_DataWys AS DataWystawienia,
BZd_Termin AS TerminPlatnosci,
BZd_KwotaSys AS KwotaPlatnosci,
CDN.KorektaPodatku_RozliczonaKwota(BZd_BZdID, @NaDzienD) AS RozliczonaKwota,
CASE WHEN VaN_TrybNettoVAT = 1 THEN CDN.KorektaPodatku_PozycjeVAT(VaN_VaNID) ELSE VaN_RazemBrutto END AS RazemBrutto,
CDN.KorektaPodatku_PozycjeVAT(VaN_VaNID) AS RazemNetto,
CDN.KorektaPodatku_UdzialDoPozycji(VaN_DataWys, VaN_RycID, VaN_KPRID, VaN_DekID, @PraID) AS Udzial,
BZd_DokumentID AS DokumentID,
BZd_DokumentTyp AS DokumentTyp,
BZd_BZdID AS PlatnoscID,
Knt_KntId AS KontrahentID,
BZd_Kierunek * -1 AS Kierunek,
CDN.KorektaPodatku_KwotaDoKorekty(BZd_BZdID, @DkNID, @PraID, @TypDeklar, @Rok * 100 + @Miesiac) AS KwotaNar,
1 AS Pierwszy,
CDN.KorektaPodatku_UstalRodzaj( BZd_DokumentTyp, VaN_Typ, 0) AS Rodzaj,
@PraID AS PraID,
'' AS InfoDodatkowe
FROM CDN.BnkZdarzenia
JOIN CDN.VatNag ON BZd_DokumentID = VaN_VaNID AND BZd_DokumentTyp = 2
JOIN CDN.Kontrahenci ON Knt_KntId = VaN_PodID AND VaN_PodmiotTyp = 1
WHERE
VaN_Finalny = 0
AND Knt_PowiazanyUoV = 0
AND YEAR(VaN_DataWys) >= @Rok - 2
AND YEAR(BZd_Termin) >= 2020
AND ((VaN_Typ = 2 AND @Wierzytelnosci = 1 AND DATEADD(day, 90, BZd_TerminR) <= @KoniecMc)
 OR (VaN_Typ = 1 AND @Zobowiazania = 1 AND DATEADD(day, 90, BZd_TerminR) BETWEEN @PoczatekRoku AND @KoniecMc)
 OR(VaN_Typ = 2 AND @WierzytelnosciPrzeterminowane30Dni = 1 AND DATEADD(day, 30, BZd_TerminR) <= @KoniecMc))
AND VaN_Export IN (0, 5)
AND (BZd_Rozliczono = 1 OR BZd_DataRoz > @NaDzienD)
AND CDN.KorektaPodatku_Usuniete(BZd_BZdID, @PraID) = 0
AND CDN.KorektaPodatku_UstalPierwszy(BZd_BZdID, @DkNID, @PraID, @TypDeklar, @RokMies) = 1
AND NOT (VaN_TrybNettoVAT = 1 AND BZd_WalutaDok = '' AND (VaN_Typ = 2 OR (VaN_Typ = 1 AND NOT EXISTS(SELECT * FROM CDN.VatTab WHERE VaT_VaNID = VaN_VaNID AND VaT_Odliczenia = 0))))
UNION ALL
SELECT
CASE WHEN LEN(BZd_NumerObcy) > 0 THEN BZd_NumerObcy ELSE BZd_NumerPelny END AS NumerDokumentu,
EDN_Nazwa1 + ' ' + EDN_Nazwa2 + ' ' + EDN_Nazwa3 AS Kontrahent,
EDN_NipE AS NIP,
EDN_DataWys AS DataWystawienia,
BZd_Termin AS TerminPlatnosci,
BZd_KwotaSys AS KwotaPlatnosci,
CDN.KorektaPodatku_RozliczonaKwota(BZd_BZdID, @NaDzienD) AS RozliczonaKwota,
-1 AS RazemBrutto,
-1 AS RazemNetto,
CDN.KorektaPodatku_UdzialDoPozycji(EDN_DataWys, EDN_RycID, EDN_KPRID, EDN_DekID, @PraID) AS Udzial,
BZd_DokumentID AS DokumentID,
BZd_DokumentTyp AS DokumentTyp,
BZd_BZdID AS PlatnoscID,
Knt_KntId AS KontrahentID,
BZd_Kierunek * -1 AS Kierunek,
CDN.KorektaPodatku_KwotaDoKorekty(BZd_BZdID, @DkNID, @PraID, @TypDeklar, @RokMies) AS KwotaNar,
1 AS Pierwszy,
CDN.KorektaPodatku_UstalRodzaj( BZd_DokumentTyp, EDN_Typ, 0) AS Rodzaj,
@PraID AS PraID,
'' AS InfoDodatkowe
FROM CDN.BnkZdarzenia
JOIN CDN.EwidDodNag ON BZd_DokumentID = EDN_EDNID AND BZd_DokumentTyp = 12
JOIN CDN.Kontrahenci ON Knt_KntId = EDN_PodID AND EDN_PodmiotTyp = 1
WHERE
Knt_Finalny = 0
AND Knt_PowiazanyUoV = 0
AND YEAR(EDN_DataWys) >= @Rok - 2
AND YEAR(BZd_Termin) >= 2020
AND ((EDN_Typ = 101 AND @Wierzytelnosci = 1 AND DATEADD(day, 90, BZd_TerminR) <= @KoniecMc)
 OR (EDN_Typ = 102 AND @Zobowiazania = 1 AND DATEADD(day, 90, BZd_TerminR) BETWEEN @PoczatekRoku AND @KoniecMc)
 OR(EDN_Typ = 101 AND @WierzytelnosciPrzeterminowane30Dni = 1 AND DATEADD(day, 30, BZd_TerminR) <= @KoniecMc))
AND Knt_Export IN (0, 5)
AND (BZd_Rozliczono = 1 OR BZd_DataRoz > @NaDzienD)
AND CDN.KorektaPodatku_Usuniete(BZd_BZdID, @PraID) = 0
AND CDN.KorektaPodatku_UstalPierwszy(BZd_BZdID, @DkNID, @PraID, @TypDeklar, @RokMies) = 1
UNION ALL
SELECT
CASE WHEN LEN(BZd_NumerObcy) > 0 THEN BZd_NumerObcy ELSE BZd_NumerPelny END AS NumerDokumentu,
TrN_PodNazwa1 + ' ' + TrN_PodNazwa2 + ' ' + TrN_PodNazwa3 AS Kontrahent,
TrN_PodNipE AS NIP,
TrN_DataWys AS DataWystawienia,
BZd_Termin AS TerminPlatnosci,
BZd_KwotaSys AS KwotaPlatnosci,
CDN.KorektaPodatku_RozliczonaKwota(BZd_BZdID, @NaDzienD) AS RozliczonaKwota,
CASE WHEN TrN_TrybNettoVAT = 1
THEN
 CASE WHEN TrN_TypDokumentu IN (302, 305, 314, 345)
  THEN
   CASE WHEN TrN_VaNID IS NULL
   THEN TrN_RazemNetto
   ELSE CDN.KorektaPodatku_PozycjeVAT(TrN_VaNID)
   END
 ELSE
  CASE WHEN TrN_VaNID IS NULL
  THEN TrN_RazemBrutto
  ELSE CDN.KorektaPodatku_PozycjeVAT(TrN_VaNID)
  END
 END
ELSE TrN_RazemBrutto
END AS RazemBrutto,
CASE WHEN TrN_VaNID IS NULL THEN TrN_RazemNetto ELSE CDN.KorektaPodatku_PozycjeVAT(TrN_VaNID) END AS RazemNetto,
CDN.KorektaPodatku_UdzialDoPozycji(TrN_DataWys, NULL, NULL, TrN_DekID, @PraID) AS Udzial,
CASE WHEN TrN_VaNID IS NULL THEN BZd_DokumentID ELSE TrN_VaNID END AS DokumentID,
CASE WHEN TrN_VaNID IS NULL THEN BZd_DokumentTyp ELSE 2 END AS DokumentTyp,
BZd_BZdID AS PlatnoscID,
Knt_KntId AS KontrahentID,
BZd_Kierunek * -1 AS Kierunek,
CDN.KorektaPodatku_KwotaDoKorekty(BZd_BZdID, @DkNID, @PraID, @TypDeklar, @RokMies) AS KwotaNar,
1 AS Pierwszy,
CDN.KorektaPodatku_UstalRodzaj( BZd_DokumentTyp, TrN_TypDokumentu, 0) AS Rodzaj,
@PraID AS PraID,
'' AS InfoDodatkowe
FROM CDN.BnkZdarzenia
JOIN CDN.TraNag ON BZd_DokumentID = TrN_TrNID AND BZd_DokumentTyp = 1
JOIN CDN.Kontrahenci ON Knt_KntId = TrN_PodID AND TrN_PodmiotTyp = 1
WHERE
TrN_Finalny = 0
AND Knt_PowiazanyUoV = 0
AND YEAR(TrN_DataWys) >= @Rok - 2
AND YEAR(BZd_Termin) >= 2020
AND ((TrN_TypDokumentu IN (302, 305, 314, 345) AND @Wierzytelnosci = 1 AND DATEADD(day, 90, BZd_TerminR) <= @KoniecMc)
 OR (TrN_TypDokumentu IN (301, 313) AND @Zobowiazania = 1 AND DATEADD(day, 90, BZd_TerminR) BETWEEN @PoczatekRoku AND @KoniecMc)
 OR(TrN_TypDokumentu IN (302, 305, 314, 345) AND @WierzytelnosciPrzeterminowane30Dni = 1 AND DATEADD(day, 30, BZd_TerminR) <= @KoniecMc))
AND TrN_Export IN (0, 5)
AND TrN_Bufor = 0
AND (BZd_Rozliczono = 1 OR BZd_DataRoz > @NaDzienD)
AND CDN.KorektaPodatku_Usuniete(BZd_BZdID, @PraID) = 0
AND CDN.KorektaPodatku_UstalPierwszy(BZd_BZdID, @DkNID, @PraID, @TypDeklar, @RokMies) = 1
AND NOT(TrN_TrybNettoVAT = 1 AND BZd_WalutaDok = '' AND (TrN_TypDokumentu IN (302, 305, 314, 345) OR (TrN_TypDokumentu IN (301, 313) AND TrN_VaNId IS NOT NULL AND NOT EXISTS(SELECT * FROM CDN.VatTab WHERE VaT_VaNID = TrN_VaNID AND VaT_Odliczenia = 0))))
UNION ALL
-- Kolejne wykazanie dokumentów
SELECT DISTINCT
KZD_NumerDokumentu AS NumerDokumentu,
KZD_Kontrahent AS Kontrahent,
KZD_NIP AS NIP,
KZD_DataWystawienia AS DataWystawienia,
KZD_TerminPlatnosci AS TerminPlatnosci,
KZD_KwotaPlatnosci AS KwotaPlatnosci,
KZD_RozliczonaKwota AS RozliczonaKwota,
0 AS RazemBrutto,
0 AS RazemNetto,
0 AS Udzial,
KZD_DokumentID AS DokumentID,
KZD_DokumentTyp AS DokumentTyp,
KZD_BZdID AS PlatnoscID,
KZD_KontrahentID AS KontrahentID,
KZD_Kierunek AS Kierunek,
KZD_KwotaDoKorekty AS KwotaDoKorekty,
0 AS Pierwszy,
KZD_Rodzaj AS Rodzaj,
KZD_PraID AS PraID,
KZD_InfoDodatkowe AS InfoDodatkowe
FROM CDN.KorektaPodatkuDochodowegoZD
JOIN CDN.DeklNag ON DkN_DkNID = KZD_DkNID
WHERE
DkN_DkNID <> @DkNID
AND ISNULL(DkN_PraID, 0) = ISNULL(@PraID, 0)
AND DkN_TypDeklar = @TypDeklar
AND DkN_RokMiesiac < @RokMies
AND DkN_RokMiesiac / 100 = @Rok
AND DkN_Finalna = 1
AND KZD_Pierwszy = 1
UNION ALL
-- Korekta powrotna dokumentów
SELECT DISTINCT
KZD_NumerDokumentu AS NumerDokumentu,
KZD_Kontrahent AS Kontrahent,
KZD_NIP AS NIP,
KZD_DataWystawienia AS DataWystawienia,
KZD_TerminPlatnosci AS TerminPlatnosci,
KZD_KwotaPlatnosci AS KwotaPlatnosci,
KZD_RozliczonaKwota AS RozliczonaKwota,
0 AS RazemBrutto,
0 AS RazemNetto,
0 AS Udzial,
KZD_DokumentID AS DokumentID,
KZD_DokumentTyp AS DokumentTyp,
KZD_BZdID AS PlatnoscID,
KZD_KontrahentID AS KontrahentID,
KZD_Kierunek AS Kierunek,
-1 * KZD_KwotaDoKorekty AS KwotaDoKorekty,
0 AS Pierwszy,
KZD_Rodzaj + 2 AS Rodzaj,
KZD_PraID AS PraID,
KZD_InfoDodatkowe AS InfoDodatkowe
FROM CDN.KorektaPodatkuDochodowegoZD
JOIN CDN.DeklNag ON DkN_DkNID = KZD_DkNID
WHERE
DkN_DkNID <> @DkNID
AND ISNULL(DkN_PraID, 0) = ISNULL(@PraID, 0)
AND DkN_TypDeklar = @TypDeklar
AND DkN_RokMiesiac < @RokMies
AND DkN_Finalna = 1
AND KZD_Pierwszy = 1
AND CDN.KorektaPodatku_UstalZaplacona(KZD_BZdID, @KoniecMc, @DkNID, @PraID, @TypDeklar) = 1
AND CDN.KorektaPodatku_UstalCzyRozliczonoWDanymRoku(KZD_BZdID, @Rok) > 0
END
