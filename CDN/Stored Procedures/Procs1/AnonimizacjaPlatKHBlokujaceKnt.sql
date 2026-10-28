CREATE PROCEDURE CDN.AnonimizacjaPlatKHBlokujaceKnt(@id INT, @thresholdDate  DATE)
AS
BEGIN
 SELECT DISTINCT 227 As TypDok, cdn.OptimaNazwaObiektu(227, 0) As TypDokDesc, 0 As Mode, KrO_KrOId As Id, KrO_Dokument  As NumerDok, KrO_DataDokumentu As DataDok, N'' As Opis, 0 As SekcjaId
 FROM CDN.KsiRozrachunki WHERE KRo_RozliczenieId is Null AND KRo_DeEId in (SELECT DeE_DeEId from CDN.Konta join CDN.DekretyElem on (DeE_AccWnId = Acc_AccId)  where Acc_SlownikTyp = 1 AND Acc_SlownikId = @id)
 UNION
 SELECT DISTINCT 227 As TypDok, cdn.OptimaNazwaObiektu(227, 0) As TypDokDesc, 0 As Mode, KrO_KrOId As Id, KrO_Dokument  As NumerDok, KrO_DataDokumentu As DataDok, N'' As Opis, 0 As SekcjaId
 FROM CDN.KsiRozrachunki WHERE KRo_RozliczenieId is Null AND KRo_DeEId in ( select DeE_DeEId from CDN.Konta join CDN.DekretyElem on (DeE_AccMaId = Acc_AccId) where Acc_SlownikTyp = 1 and Acc_SlownikId = @id)
 UNION
 SELECT DISTINCT 227 As TypDok, cdn.OptimaNazwaObiektu(227, 0) As TypDokDesc, 0 As Mode, KrO_KrOId As Id, KrO_Dokument  As NumerDok, KrO_DataDokumentu As DataDok, N'' As Opis, 0 As SekcjaId
 FROM CDN.KsiRozrachunki WHERE KRo_RozliczenieId is Null AND KRo_BoEId in (select BoE_BoEId from CDN.Konta join CDN.BOElem on (BOE_AccId = Acc_AccId) where Acc_SlownikTyp =1 and Acc_SlownikId = @id)
 ORDER BY SekcjaId, TypDok, DataDok, Id
END
