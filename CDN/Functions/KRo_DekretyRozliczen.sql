CREATE FUNCTION CDN.KRo_DekretyRozliczen(@DeNId int, @BoNId int)
RETURNS @Result TABLE( RozliczenieDokument nvarchar(50), DokumentTyp INT, DeNId int, DeEId int, DeN_Dokument nvarchar(50), DeN_Bufor int, BoNId int, BoEId int, BoN_Dokument nvarchar(50),  BoN_Bufor int)
AS
BEGIN
 insert into @result (RozliczenieDokument, DokumentTyp , DeNId , DeEId , DeN_Dokument , DeN_Bufor , BoNId , BoEId , BoN_Dokument ,  BoN_Bufor)
 select distinct * from (
 select rozliczenie.DeE_Dokument as RozliczenieDokument, rozliczenie.DeE_DokumentTyp as DokumentTyp, dn.DeN_DeNId as DeNId,  de.DeE_DeEId as DeEId, dn.DeN_Dokument as DeN_Dokument, dn.DeN_Bufor as DeN_Bufor, bn.BoN_BoNId as BoNId,  be.BoE_BoEId as BoEId, bn.BON_NumerPelny as BoN_Dokument, bn.BON_Bufor as BoN_Bufor
 from cdn.KsiRozrachunki
 join cdn.DekretyElem rozliczenie on (rozliczenie.DeE_DokumentId = KRo_KRoId)
 left outer join cdn.DekretyElem de on (KRo_DeEId = de.DeE_DeEId) left outer join cdn.DekretyNag dn on (de.DeE_DeNId = dn.DeN_DeNId)
 left outer join cdn.BOElem be on (KRo_BoEId = be.BoE_BoEId) left outer join cdn.BONag bn on (be.BOE_BONId = bn.BoN_BoNId)
 where
 rozliczenie.DeE_DokumentTyp = 44
 union
 select rozliczenie.DeE_Dokument as RozliczenieDokument, rozliczenie.DeE_DokumentTyp as DokumentTyp, dn.DeN_DeNId as DeNId,  de.DeE_DeEId as DeEId, dn.DeN_Dokument as DeN_Dokument, dn.DeN_Bufor as DeN_Bufor, bn.BoN_BoNId as BoNId,  be.BoE_BoEId as BoEId, bn.BON_NumerPelny as BoN_Dokument, bn.BON_Bufor as BoN_Bufor
 from cdn.KsiRozrachunki
 join cdn.DekretyElem rozliczenie on (rozliczenie.DeE_DokumentId = KRo_ROzliczenieId)
 left outer join cdn.DekretyElem de on (KRo_DeEId = de.DeE_DeEId) left outer join cdn.DekretyNag dn on (de.DeE_DeNId = dn.DeN_DeNId)
 left outer join cdn.BOElem be on (KRo_BoEId = be.BoE_BoEId) left outer join cdn.BONag bn on (be.BOE_BONId = bn.BoN_BoNId)
 where
 rozliczenie.DeE_DokumentTyp = 44
 union
 select rozliczenie.DeE_Dokument as RozliczenieDokument, rozliczenie.DeE_DokumentTyp as DokumentTyp, dn.DeN_DeNId as DeNId,  de.DeE_DeEId as DeEId, dn.DeN_Dokument as DeN_Dokument, dn.DeN_Bufor as DeN_Bufor, bn.BoN_BoNId as BoNId,  be.BoE_BoEId as BoEId, bn.BON_NumerPelny as BoN_Dokument, bn.BON_Bufor as BoN_Bufor
 from cdn.KsiRozrachunki
 join cdn.DekretyElem rozliczenie on (rozliczenie.DeE_DokumentId = KRo_KRoId)
 left outer join cdn.DekretyElem de on (KRo_DeEId = de.DeE_DeEId) left outer join cdn.DekretyNag dn on (de.DeE_DeNId = dn.DeN_DeNId)
 left outer join cdn.BOElem be on (KRo_BoEId = be.BoE_BoEId) left outer join cdn.BONag bn on (be.BOE_BONId = bn.BoN_BoNId)
 where
 rozliczenie.DeE_DokumentTyp = 50
 union
 select rozliczenie.DeE_Dokument as RozliczenieDokument, rozliczenie.DeE_DokumentTyp as DokumentTyp, dn.DeN_DeNId as DeNId,  de.DeE_DeEId as DeEId, dn.DeN_Dokument as DeN_Dokument, dn.DeN_Bufor as DeN_Bufor, bn.BoN_BoNId as BoNId,  be.BoE_BoEId as BoEId, bn.BON_NumerPelny as BoN_Dokument, bn.BON_Bufor as BoN_Bufor
 from cdn.KsiRozrachunki
 join cdn.DekretyElem rozliczenie on (rozliczenie.DeE_DokumentId = KRo_ROzliczenieId)
 left outer join cdn.DekretyElem de on (KRo_DeEId = de.DeE_DeEId) left outer join cdn.DekretyNag dn on (de.DeE_DeNId = dn.DeN_DeNId)
 left outer join cdn.BOElem be on (KRo_BoEId = be.BoE_BoEId) left outer join cdn.BONag bn on (be.BOE_BONId = bn.BoN_BoNId)
 where
 rozliczenie.DeE_DokumentTyp = 50
 ) as rozliczenia
 where rozliczenia.DeNId = @DeNId or rozliczenia.BoNId = @BoNId
 return
END
