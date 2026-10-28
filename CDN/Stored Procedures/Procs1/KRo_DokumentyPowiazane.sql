CREATE procedure CDN.KRo_DokumentyPowiazane
 @SourceDeEId int
As
 SET NOCOUNT ON
 declare @SourceType int; select @SourceType = DeE_DokumentTyp from CDN.DekretyElem where DeE_DeEId = @SourceDeEId
 if @SourceType = 50  -- kompensaty
 begin
  select
   rozliczenia.Identksieg as IdKsiegowy,
   case when rozliczenia.Bufor <> 0 then rozliczenia.NrKsiegi + ' B' else rozliczenia.NrKsiegi end as NrDziennika,
   RTRIM(case when rozliczenia.Typ = 2 then rozliczenia.NrKsiegi when OOb_CiaglaNumeracjaDC=1 then rozliczenia.Dziennik+ '/' + convert (char, rozliczenia.NumerDziennika) else rozliczenia.Dziennik+ '/' + convert(char(7), rozliczenia.DataDokumentu, 111) + '/' + convert (char, rozliczenia.NumerDziennika) end) as NrKsiegi,
   rozliczenia.DataDokumentu as DataDokumentu,
   rozliczenia.Dokument as Dokument,
   rozliczenia.KwotaWn as KwotaWn,
   rozliczenia.KwotaMa as KwotaMa,
   rozliczenia.Opis as Opis,
   rozliczenia.Id as DokId,
   rozliczenia.Typ as DokTyp
  from
  (
   select distinct
    case when Rozliczane.KRo_Typ=1 then DeN_Identksieg else '' end as Identksieg,
    case when Rozliczane.KRo_Typ =1 then DeN_DeNId else Rozliczane.KRo_BOEId end as Id,
    Rozliczane.KRo_Typ as Typ,
    Rozliczane.KRo_OObId as OObId,
    case when Rozliczane.KRo_Typ=1 then DeN_Bufor else BoN_Bufor end as Bufor,
    case when Rozliczane.KRo_Typ=1 then (convert(nvarchar(30), DeN_NrKsiegi)) else '' end as NrKsiegi,
    case when Rozliczane.KRo_Typ=1 then DeN_NrDziennika else '' end as NumerDziennika,
    case when Rozliczane.KRo_Typ=1 then DeN_Dziennik else '' end as Dziennik,
    case when Rozliczane.KRo_Typ=1 then DeN_DataDok else BoN_DataDok end as DataDokumentu,
    case when Rozliczane.KRo_Typ=1 then DeN_Dokument else BON_NumerPelny end as Dokument,
    case when Rozliczane.KRo_Typ=1 then DeN_KwotaWn else BON_KwotaWn end as KwotaWn,
    case when Rozliczane.KRo_Typ=1 then DeN_KwotaMa else BON_KwotaMa end as KwotaMa,
    case when Rozliczane.KRo_Typ=1 then DeN_Kategoria else BON_Kategoria end as Opis
    from cdn.DekretyElem as sourceElem
    join cdn.KsiRozrachunki Rozliczane on (sourceElem.DeE_DokumentId = Rozliczane.KRo_KRoId)
    join cdn.KsiRozrachunki Rozliczajace on (Rozliczane.KRo_RozliczenieId = Rozliczajace.KRo_KRoId)
    left outer join CDN.DekretyElem E on (E.DeE_DeEId = Rozliczane.KRo_DeEId)
    left outer join CDN.DekretyNag on (DeN_DeNId = E.DeE_DeNId)
    left outer join CDN.BOElem on (BoE_BoEId = Rozliczane.KRo_BoEId)
    left outer join CDN.BONag on (BoN_BoNId = BoE_BoNId)
   where sourceElem.DeE_DokumentTyp = 50 and sourceElem.DeE_DeEId = @SourceDeEId
   union all
   select distinct
    case when Rozliczajace.KRo_Typ=1 then DeN_Identksieg else '' end as Identksieg,
    case when Rozliczajace.KRo_Typ =1 then DeN_DeNId else Rozliczajace.KRo_BOEId end as Id,
    Rozliczajace.KRo_Typ as Typ,
    Rozliczajace.KRo_OObId as OObId,
    case when Rozliczajace.KRo_Typ=1 then DeN_Bufor else BoN_Bufor end as Bufor,
    case when Rozliczajace.KRo_Typ=1 then (convert(nvarchar(30), DeN_NrKsiegi)) else '' end as NrKsiegi,
    case when Rozliczajace.KRo_Typ=1 then DeN_NrDziennika else '' end as NumerDziennika,
    case when Rozliczajace.KRo_Typ=1 then DeN_Dziennik else '' end as Dziennik,
    case when Rozliczajace.KRo_Typ=1 then DeN_DataDok else BoN_DataDok end as DataDokumentu,
    case when Rozliczajace.KRo_Typ=1 then DeN_Dokument else BON_NumerPelny end as Dokument,
    case when Rozliczajace.KRo_Typ=1 then DeN_KwotaWn else BON_KwotaWn end as KwotaWn,
    case when Rozliczajace.KRo_Typ=1 then DeN_KwotaMa else BON_KwotaMa end as KwotaMa,
    case when Rozliczajace.KRo_Typ=1 then DeN_Kategoria else BON_Kategoria end as Opis
    from cdn.DekretyElem as sourceElem
    join cdn.KsiRozrachunki Rozliczane on (sourceElem.DeE_DokumentId = Rozliczane.KRo_KRoId)
    join cdn.KsiRozrachunki Rozliczajace on (Rozliczane.KRo_RozliczenieId = Rozliczajace.KRo_KRoId)
    left outer join CDN.DekretyElem E on (E.DeE_DeEId = Rozliczajace.KRo_DeEId)
    left outer join CDN.DekretyNag on (DeN_DeNId = E.DeE_DeNId)
    left outer join CDN.BOElem on (BoE_BoEId = Rozliczajace.KRo_BoEId)
    left outer join CDN.BONag on (BoN_BoNId = BoE_BoNId)
   where sourceElem.DeE_DokumentTyp = 50 and sourceElem.DeE_DeEId = @SourceDeEId
  ) rozliczenia
  join CDN.OkresyObrach on (rozliczenia.OObId = OOb_OObId)
 end
 else
 begin
  select
   rozliczenia.Identksieg as IdKsiegowy,
   case when rozliczenia.Bufor <> 0 then rozliczenia.NrKsiegi + ' B' else rozliczenia.NrKsiegi end as NrDziennika,
   RTRIM(case when rozliczenia.Typ = 2 then rozliczenia.NrKsiegi when OOb_CiaglaNumeracjaDC=1 then rozliczenia.Dziennik+ '/' + convert (char, rozliczenia.NumerDziennika) else rozliczenia.Dziennik+ '/' + convert(char(7), rozliczenia.DataDokumentu, 111) + '/' + convert (char, rozliczenia.NumerDziennika) end) as NrKsiegi,
   rozliczenia.DataDokumentu as DataDokumentu,
   rozliczenia.Dokument as Dokument,
   rozliczenia.KwotaWn as KwotaWn,
   rozliczenia.KwotaMa as KwotaMa,
   rozliczenia.Opis as Opis,
   rozliczenia.Id as DokId,
   rozliczenia.Typ as DokTyp
  from
  (
   -- work
   select distinct
    case when rozliczenia.KRo_Typ=1 then DeN_Identksieg else '' end as Identksieg,
    case when rozliczenia.KRo_Typ =1 then DeN_DeNId else rozliczenia.KRo_BOEId end as Id,
    rozliczenia.KRo_Typ as Typ,
    rozliczenia.KRo_OObId as OObId,
    case when rozliczenia.KRo_Typ=1 then DeN_Bufor else BoN_Bufor end as Bufor,
    case when rozliczenia.KRo_Typ=1 then (convert(nvarchar(30), DeN_NrKsiegi)) else '' end as NrKsiegi,
    case when rozliczenia.KRo_Typ=1 then DeN_NrDziennika else '' end as NumerDziennika,
    case when rozliczenia.KRo_Typ=1 then DeN_Dziennik else '' end as Dziennik,
    case when rozliczenia.KRo_Typ=1 then DeN_DataDok else BoN_DataDok end as DataDokumentu,
    case when rozliczenia.KRo_Typ=1 then DeN_Dokument else BON_NumerPelny end as Dokument,
    case when rozliczenia.KRo_Typ=1 then DeN_KwotaWn else BON_KwotaWn end as KwotaWn,
    case when rozliczenia.KRo_Typ=1 then DeN_KwotaMa else BON_KwotaMa end as KwotaMa,
    case when rozliczenia.KRo_Typ=1 then DeN_Kategoria else BON_Kategoria end as Opis
   from cdn.KsiRozrachunki dokumenty join cdn.KsiRozrachunki rozliczenia on (dokumenty.KRo_RozliczenieId = rozliczenia.KRo_KRoId)
    join CDN.OkresyObrach on (rozliczenia.KRo_OObId = OOb_OObId)
    left outer join CDN.DekretyElem on (DeE_DeEId = rozliczenia.KRo_DeEId)
    left outer join CDN.DekretyNag on (DeN_DeNId = DeE_DeNId)
    left outer join CDN.BOElem on (BoE_BoEId = rozliczenia.KRo_BoEId)
    left outer join CDN.BONag on (BoN_BoNId = BoE_BoNId)
   where dokumenty.KRo_DeEId =  + @SourceDeEId
   union
   select distinct
    DeN_Identksieg as Identksieg,
    DeN_DeNId as Id,
    1 as Typ,
    DeN_OObId as OObId,
    DeN_Bufor as Bufor,
    convert(nvarchar(30), DeN_NrKsiegi) as NrKsiegi,
    DeN_NrDziennika as NumerDziennika,
    DeN_Dziennik as Dziennik,
    DeN_DataDok as DataDokumentu,
    DeN_Dokument as Dokument,
    DeN_KwotaWn as KwotaWn,
    DeN_KwotaMa as KwotaMa,
    DeN_Kategoria as Opis
   from
   cdn.KsiRozrachunki Rozliczane
    join cdn.KsiRozrachunki Rozliczajace on (Rozliczane.KRo_RozliczenieId = Rozliczajace.KRo_KRoId)
    join cdn.DekretyElem on (DeE_DokumentId = Rozliczane.KRo_KRoId) join CDN.DekretyNag on (DeN_DeNId = DeE_DeNId)
   where DeE_DokumentTyp = 50 and Rozliczane.KRo_DeEId= + @SourceDeEId
   union
   select distinct
    DeN_Identksieg as Identksieg,
    DeN_DeNId as Id,
    1 as Typ,
    DeN_OObId as OObId,
    DeN_Bufor as Bufor,
    convert(nvarchar(30), DeN_NrKsiegi) as NrKsiegi,
    DeN_NrDziennika as NumerDziennika,
    DeN_Dziennik as Dziennik,
    DeN_DataDok as DataDokumentu,
    DeN_Dokument as Dokument,
    DeN_KwotaWn as KwotaWn,
    DeN_KwotaMa as KwotaMa,
    DeN_Kategoria as Opis
   from
   cdn.KsiRozrachunki Rozliczane
    join cdn.KsiRozrachunki Rozliczajace on (Rozliczane.KRo_RozliczenieId = Rozliczajace.KRo_KRoId)
    join cdn.DekretyElem on (DeE_DokumentId = Rozliczajace.KRo_KRoId)
    join CDN.DekretyNag on (DeN_DeNId = DeE_DeNId)
   where DeE_DokumentTyp = 50 and Rozliczane.KRo_DeEId= + @SourceDeEId
  ) rozliczenia
  join CDN.OkresyObrach on (rozliczenia.OObId = OOb_OObId);
 end
 SET NOCOUNT ON
