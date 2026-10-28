CREATE   PROCEDURE CDN.KRo_DokumentyKasowe
@DeNId  int
AS
begin
 select 1 as kbDokumentTyp, DeE_BZdId as kbDokumentId, KRo_KRoId as KRoId, DeE_DeEId as DeEId from cdn.DekretyElem join CDn.KsiRozrachunki on (DeE_DeEId = KRo_DeEId)
 where KRo_RozliczenieId is NULL and DeE_BZdId Is Not NULL and DeE_DeNId = @DeNId
 union
 select 1 as kbDokumentTyp, BZd_BZdID as kbDokumentId, KRo_KRoId as KRoId, DeE_DeEId as DeEId from cdn.DekretyElem join CDn.KsiRozrachunki on (DeE_DeEId = KRo_DeEId)
 join CDN.BnkZdarzenia on (BZd_DokumentId = DeE_DeEId)
 where BZd_DokumentTyp in (27,28) and KRo_RozliczenieId is NULL and DeE_DeNId = @DeNId
 union
 select 2 as kbDokumentTyp,  DeE_DokumentId as kbDokumentId, KRo_KRoId as KRoId, DeE_DeEId as DeEId from cdn.DekretyElem join CDn.KsiRozrachunki on (DeE_DeEId = KRo_DeEId)
 where KRo_RozliczenieId is NULL and DeE_DokumentTyp = 14 and DeE_DeNId = @DeNId
end
