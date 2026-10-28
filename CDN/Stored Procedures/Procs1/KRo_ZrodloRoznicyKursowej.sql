CREATE procedure CDN.KRo_ZrodloRoznicyKursowej
 @SourceKRoId int,
 @SourceDeEId int
As
 SET NOCOUNT ON
 if @SourceKRoId is not NULL
 begin
  select
  case when RozrachunekA.KRo_KwotaDok / RozrachunekA.KRo_KwotaDokWal < RozrachunekB.KRo_KwotaDok / RozrachunekB.KRo_KwotaDokWal then 1 else 2 end as AB,
  RozrachunekA.KRo_KRoId as KRoIdA, RozrachunekA.KRo_Dokument as DokumentA, RozrachunekA.KRo_KwotaDok / RozrachunekA.KRo_KwotaDokWal as KursA,
  RozrachunekA.KRo_Typ as TypA,
  case when RozrachunekA.KRo_Typ = 1 then RozrachunekA.KRo_DeEId else RozrachunekA.KRo_BOEId end as DekIdA,
  RozrachunekB.KRo_KRoId as KRoIdB, RozrachunekB.KRo_Dokument as DokumentB, RozrachunekB.KRo_KwotaDok / RozrachunekB.KRo_KwotaDokWal as KursB,
  RozrachunekB.KRo_Typ as TypB,
  case when RozrachunekB.KRo_Typ = 1 then RozrachunekB.KRo_DeEId else RozrachunekB.KRo_BOEId end as DekIdB
  from cdn.KsiRozrachunki RoznicaKursowa join cdn.DekretyElem on (RoznicaKursowa.KRo_DeEId = DeE_DeEId)
  join cdn.KsiRozrachunki RozrachunekA on (DeE_DokumentId = RozrachunekA.KRo_KRoId)
  join cdn.KsiRozrachunki RozrachunekB on (RozrachunekA.KRo_RozliczenieId = RozrachunekB.KRo_KRoId)
  where DeE_DokumentTyp = 44
  and (RoznicaKursowa.KRo_KRoId = @SourceKRoId)
  --and (RoznicaKursowa.KRo_DeEId = @SourceDeEId)
 end
 else
 begin
  select
  case when RozrachunekA.KRo_KwotaDok / RozrachunekA.KRo_KwotaDokWal < RozrachunekB.KRo_KwotaDok / RozrachunekB.KRo_KwotaDokWal then 1 else 2 end as AB,
  RozrachunekA.KRo_KRoId as KRoIdA, RozrachunekA.KRo_Dokument as DokumentA, RozrachunekA.KRo_KwotaDok / RozrachunekA.KRo_KwotaDokWal as KursA,
  RozrachunekA.KRo_Typ as TypA,
  case when RozrachunekA.KRo_Typ = 1 then RozrachunekA.KRo_DeEId else RozrachunekA.KRo_BOEId end as DekIdA,
  RozrachunekB.KRo_KRoId as KRoIdB, RozrachunekB.KRo_Dokument as DokumentB, RozrachunekB.KRo_KwotaDok / RozrachunekB.KRo_KwotaDokWal as KursB,
  RozrachunekB.KRo_Typ as TypB,
  case when RozrachunekB.KRo_Typ = 1 then RozrachunekB.KRo_DeEId else RozrachunekB.KRo_BOEId end as DekIdB
  from cdn.KsiRozrachunki RoznicaKursowa join cdn.DekretyElem on (RoznicaKursowa.KRo_DeEId = DeE_DeEId)
  join cdn.KsiRozrachunki RozrachunekA on (DeE_DokumentId = RozrachunekA.KRo_KRoId)
  join cdn.KsiRozrachunki RozrachunekB on (RozrachunekA.KRo_RozliczenieId = RozrachunekB.KRo_KRoId)
  where DeE_DokumentTyp = 44
  --and (RoznicaKursowa.KRo_KRoId = @SourceKRoId)
  and (RoznicaKursowa.KRo_DeEId = @SourceDeEId)
 end
 SET NOCOUNT ON
