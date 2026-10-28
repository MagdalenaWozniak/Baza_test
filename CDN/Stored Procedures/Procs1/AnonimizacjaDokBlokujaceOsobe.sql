CREATE PROCEDURE CDN.AnonimizacjaDokBlokujaceOsobe( @id INT, @thresholdDate  DATE )
AS
BEGIN
 DECLARE @kntId INT
 SELECT TOP 1 @kntId = KnO_KntId FROM cdn.KntOsoby WHERE KnO_KnOId = @id
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.TraNag JOIN cdn.KntOsoby ON TrN_Odebral = KnO_Nazwisko AND KnO_KnOId = @id
 WHERE TrN_TypDokumentu IN (301,302,305,306,307,313,314)
 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @kntId) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @kntId))
 AND TrN_Bufor > -1 AND (TrN_DataDok > @thresholdDate OR TrN_DataOpe > @thresholdDate OR TrN_DataWys > @thresholdDate)
 AND TrN_Rodzaj NOT IN (306071, 306072, 306061)
 UNION
 SELECT DISTINCT TrN_TypDokumentu As TypDok, cdn.OptimaNazwaObiektu(TrN_TypDokumentu,0) As TypDokDesc, 0 As Mode, TrN_TrNId As Id, TrN_NumerPelny As NumerDok, TrN_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.TraNag JOIN cdn.KntOsoby ON TrN_Odebral = KnO_Nazwisko AND KnO_KnOId = @id
    WHERE TrN_TypDokumentu IN (308, 309) AND TrN_RezerwacjaWew = 0
 AND ((TrN_PodmiotTyp = 1 AND TrN_PodId = @kntId) OR (TrN_OdbiorcaTyp = 1 AND TrN_OdbId = @kntId))
 AND ((TrN_Bufor=1) OR (TrN_Bufor=0 AND TrN_ZwroconoCalaIlosc<3))
 UNION
 SELECT 700 As TypDok, cdn.OptimaNazwaObiektu(700,0) As TypDokDesc, 0 As Mode, CrK_CrKId As Id, CrK_NumerPelny As NumerDok, CrK_DataDok As DataDok, N'' As Opis, 0 As SekcjaId  FROM cdn.CrmKontakty WHERE CrK_Bufor > -1 AND CrK_OsobaId = @id AND CrK_Bufor = 1
 UNION  -- oferty
 SELECT DISTINCT 800 As TypDok, cdn.OptimaNazwaObiektu(800,0) As TypDokDesc, 0 As Mode, OfD_OfDId As Id, OfD_NumerPelny As NumerDok, OfD_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.OfertyKnt JOIN cdn.OfertyDok ON OfK_OfDId = OfD_OfDId WHERE OfD_Bufor = 1 AND OfK_PodmiotTyp=1 AND OfK_PodID = @kntId AND OfK_KnO_KnOId = @id
 UNION
 SELECT 900 As TypDok, cdn.OptimaNazwaObiektu(900,0) As TypDokDesc, 0 As Mode, SrZ_SrZId As Id, SrZ_NumerPelny As NumerDok, SrZ_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.SrsZlecenia WHERE (SrZ_Bufor = 1 OR (SrZ_Bufor = 0 AND SrZ_Stan < 2)) AND (SrZ_ZlecajacyId = @id OR SrZ_PrzedstawicielId = @id)
 UNION
 SELECT DISTINCT 1801 As TypDok, cdn.OptimaNazwaObiektu(1801,0) As TypDokDesc, 0 As Mode, RUN_RUNId As Id, N'Naruszenie' As NumerDok, RUN_DataNaruszenia As DataDok, N'' As Opis, 0 As SekcjaId
    FROM cdn.RejestrNaruszen WHERE RUN_OsobaId = @id
 ORDER BY SekcjaId, TypDok, DataDok, Id
END
