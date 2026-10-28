CREATE PROCEDURE CDN.Anonimizacja_BnkZapisy_BlokujaceKnt(@id INT, @thresholdDate  DATE)
AS
BEGIN
 SELECT DISTINCT 1000  As TypDok, cdn.OptimaNazwaObiektu(1000, BZP_Kierunek) As TypDokDesc, 0 As Mode, BzP_BZPId As Id, BzP_NumerPelny As NumerDok, BzP_DataDok As DataDok, N'' As Opis, 0 As SekcjaId
 FROM cdn.BnkZapisy WHERE BZp_PodmiotTyp = 1 AND BZp_PodmiotID = @id AND BZp_DataDok > @thresholdDate
 ORDER BY SekcjaId, TypDok, DataDok, Id
END
