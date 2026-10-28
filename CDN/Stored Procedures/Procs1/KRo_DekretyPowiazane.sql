CREATE procedure CDN.KRo_DekretyPowiazane
 @SourceKRoId int
As
 SET NOCOUNT ON
 select dekrety.DeNId, dekrety.KRoId, dekrety.DokumentTyp from
 (
 -- dojście do rozrachunku nadrzędnego z którego powstała różnica kursowa i / lub kompensata
 -- z poziomu rozrachunku różnicy kursowej.
 select
 Distinct NULL  as DeNId,  Rozrachunek.KRo_KRoId as KRoId, 1 as DokumentTyp
 from cdn.KsiRozrachunki RoznicaKursowa join cdn.DekretyElem on (RoznicaKursowa.KRo_DeEId = DeE_DeEId)
 join cdn.KsiRozrachunki Rozrachunek on (DeE_DokumentId = Rozrachunek.KRo_KRoId)
 where DeE_DokumentTyp = 44 and (RoznicaKursowa.KRo_KRoId = @SourceKRoId)
 union
 select
 Distinct NULL  as DeNId,  Rozrachunek.KRo_KRoId as KRoId, 1 as DokumentTyp
 from cdn.KsiRozrachunki RoznicaKursowa join cdn.DekretyElem on (RoznicaKursowa.KRo_DeEId = DeE_DeEId)
 join cdn.KsiRozrachunki Rozrachunek on (DeE_DokumentId = Rozrachunek.KRo_KRoId)
 where DeE_DokumentTyp = 44 and (RoznicaKursowa.KRo_RozliczenieId = @SourceKRoId)
 -- dojście do dekretu RÓŻNICY KURSOWEJ
 -- z poziomu rozrachunku różnicy kursowej
 union
 select Distinct DeE_DeNId as DeNId,  NULL as KRoId, DeE_DokumentTyp as DokumentTyp from cdn.DekretyElem join cdn.KsiRozrachunki on (KRo_DeEId = DeE_DeEId)
 where DeE_DokumentTyp = 44 and (KRo_KRoId = @SourceKRoId)
 union
 select Distinct DeE_DeNId as DeNId,  NULL as KRoId, DeE_DokumentTyp as DokumentTyp from cdn.DekretyElem join cdn.KsiRozrachunki on (KRo_DeEId = DeE_DeEId)
 where DeE_DokumentTyp = 44 and (KRo_RozliczenieId = @SourceKRoId)
 -- dojście do dekretu RÓŻNICY KURSOWEJ
 -- usuwanie z poziomu rozrachunków z których powstała różnica kursowa;
 union
 select Distinct DeE_DeNId as DeNId,  RoznicaKursowa.KRo_KRoId as KRoId, DeE_DokumentTyp as DokumentTyp
 from
 cdn.DekretyElem
 join cdn.KsiRozrachunki Rozrachunek on (Rozrachunek.KRo_KRoId = DeE_DokumentId)
 join cdn.KsiRozrachunki RoznicaKursowa on (RoznicaKursowa.KRo_DeEID = DeE_DeEId)
 where DeE_DokumentTyp = 44 and (Rozrachunek.KRo_KRoId = @SourceKRoId)
 union
 select Distinct DeE_DeNId as DeNId,  RoznicaKursowa.KRo_KRoId as KRoId, DeE_DokumentTyp as DokumentTyp
 from
 cdn.DekretyElem
 join cdn.KsiRozrachunki Rozrachunek on (Rozrachunek.KRo_KRoId = DeE_DokumentId)
 join cdn.KsiRozrachunki RoznicaKursowa on (RoznicaKursowa.KRo_DeEID = DeE_DeEId)
 where DeE_DokumentTyp = 44 and (Rozrachunek.KRo_RozliczenieId = @SourceKRoId)
 -- dojście do dekretu KOMPENSATY
 -- z poziomu rozrachunków z których powstała kompensata;
 union
 select Distinct DeE_DeNId as DeNId,  NULL as KRoId, DeE_DokumentTyp as DokumentTyp
 from
 cdn.DekretyElem
 left outer join CDN.KsiRozrachunki On (DeE_DokumentId in (KRo_KRoId , KRo_RozliczenieId))
 where DeE_DokumentTyp = 50 and (KRo_KRoId = @SourceKRoId)
 union
 select Distinct DeE_DeNId as DeNId,  NULL as KRoId, DeE_DokumentTyp as DokumentTyp
 from
 cdn.DekretyElem
 left outer join CDN.KsiRozrachunki On (DeE_DokumentId in (KRo_KRoId , KRo_RozliczenieId))
 where DeE_DokumentTyp = 50 and (KRo_RozliczenieId = @SourceKRoId)
 ) dekrety
 SET NOCOUNT ON
