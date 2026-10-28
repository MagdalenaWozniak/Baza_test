CREATE PROCEDURE CDN.AnonimizacjaDokOsoba( @id INT )
AS
BEGIN
 DECLARE @kntId INT
 SELECT TOP 1 @kntId = KnO_KntId FROM cdn.KntOsoby WHERE KnO_KnOId = @id
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.TraNag JOIN cdn.KntOsoby ON TrN_Odebral = KnO_Nazwisko AND KnO_KnOId = @id
 WHERE TrN_TypDokumentu IN (301,302,305,306,307,313,314,320)
 AND TrN_Bufor > -1 AND  ((TrN_PodmiotTyp = 1 AND TrN_PodId = @kntId) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @kntId))
 AND TrN_Rodzaj NOT IN (306071, 306072, 306061)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'Dokument anulowany' As Opis, 2 As SekcjaId
 FROM cdn.TraNag JOIN cdn.KntOsoby ON TrN_Odebral = KnO_Nazwisko AND KnO_KnOId = @id
 WHERE TrN_TypDokumentu IN (301,302,305,306,307,313,314,320)
 AND TrN_Bufor = -1 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @kntId) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @kntId))
 AND TrN_Rodzaj NOT IN (306071, 306072, 306061)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.TraNag JOIN cdn.KntOsoby ON TrN_Odebral = KnO_Nazwisko AND KnO_KnOId = @id
    WHERE TrN_TypDokumentu IN (308, 309)  AND TrN_RezerwacjaWew = 0
 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @kntId) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @kntId))
 AND TrN_Bufor>-1
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'Dokument anulowany' As Opis, 2 As SekcjaId
 FROM cdn.TraNag JOIN cdn.KntOsoby ON TrN_Odebral = KnO_Nazwisko AND KnO_KnOId = @id
    WHERE TrN_TypDokumentu IN (308, 309)  AND TrN_RezerwacjaWew = 0
 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @kntId) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @kntId))
 AND TrN_Bufor=-1
 UNION
 SELECT DISTINCT 370 As TypDok, cdn.OptimaNazwaObiektu(370,0) As TypDokDesc, 0 As Mode, SzL_SZLId As Id, SZL_NumerPelny As NumerDok, SzL_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.SenditZleceniePrzesylki JOIN cdn.KntOsoby ON SZL_Odebral = KnO_Nazwisko AND KnO_KnOId = @id
 WHERE (SZL_OdbiorcaTyp = 1 AND SZL_OdbID = @kntId)
 UNION
 SELECT DISTINCT 700 As TypDok, cdn.OptimaNazwaObiektu(700,0) As TypDokDesc, 0 As Mode, CrK_CrKId As Id, CrK_NumerPelny As NumerDok, CrK_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.CrmKontakty WHERE CrK_Bufor > -1 AND CrK_OsobaId = @id
 UNION
 SELECT DISTINCT 710 As TypDok, cdn.OptimaNazwaObiektu(710,0) As TypDokDesc, 0 As Mode, AnkAnN_AnkAnNId As Id, AnkAnN_NumerPelny As NumerDok, AnkAnN_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.AnkAnkietyNag WHERE AnkAnN_PodmiotTyp = 1 AND AnkAnN_OsobaId = @id
 UNION
 SELECT DISTINCT 714 As TypDok, cdn.OptimaNazwaObiektu(714,0) As TypDokDesc, 0 As Mode, AnkWaN_AnkWaNId As Id, AnkWaN_Kod As NumerDok, AnkWaN_TS_Zal As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.AnkWzorzecAnkietyNag JOIN cdn.AnkWzorzecAnkietyAnkietowani ON AnkWaN_AnkWaNId = AnkWaA_AnkWaNId WHERE AnkWaA_PodmiotTyp = 1 AND AnkWaA_OsobaId = @id
 UNION  -- oferty
 SELECT DISTINCT 800 As TypDok, cdn.OptimaNazwaObiektu(800,0) As TypDokDesc, 0 As Mode, OfD_OfDId As Id, OfD_NumerPelny As NumerDok, OfD_DataDok As DataDok, N'' As Opis, 2 As SekcjaId
 FROM cdn.OfertyKnt JOIN cdn.OfertyDok ON OfK_OfDId = OfD_OfDId WHERE OfK_PodmiotTyp=1 AND OfK_PodID = @kntId AND OfK_KnO_KnOId = @id
 UNION
 SELECT DISTINCT 900 As TypDok, cdn.OptimaNazwaObiektu(900,0) As TypDokDesc, 1 As Mode, SrZ_SrZId As Id, SrZ_NumerPelny As NumerDok, SrZ_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.SrsZlecenia WHERE SrZ_Bufor > -1 AND (SrZ_ZlecajacyId = @id OR SrZ_PrzedstawicielId = @id)
 UNION
 SELECT DISTINCT 906 As TypDok, cdn.OptimaNazwaObiektu(906,0) As TypDokDesc, 0 As Mode, SrW_SrWId As Id, SrW_Kod As NumerDok, SrW_DataDok As DataDok, N'' As Opis, 2 As SekcjaId  FROM cdn.SrsCyklNag WHERE (SrW_ZlecajacyId = @id OR SrW_PrzedstawicielId = @id)
 ORDER BY SekcjaId, TypDok, DataDok, Id
END
