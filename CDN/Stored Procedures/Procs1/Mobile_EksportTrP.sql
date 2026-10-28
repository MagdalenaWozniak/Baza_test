CREATE PROCEDURE [CDN].[Mobile_EksportTrP]
@ID  INT
AS
declare
@FplId int,
@KntGrupa NVARCHAR(20)
select @FplId =dfpl_fplid  from cdn.detalformyplatnosci
  where Dfpl_Dstaid = @ID and  Dfpl_Domyslna = 1
  ORDER BY Dfpl_dfplid
 select @KntGrupa = DSta_KntGrupa FROM CDN.DetalStanowiska  WHERE DSta_DStaId = @ID
 if @KntGrupa = ''
select
1 as Id ,
BzD_BZdId as ErpId,
(case when bzd_kierunek = 1 then 0 else 1 end) as IsReceivable,
BzD_PodmiotId as PayerId,
bzd_NumerPelny as ErpDocument,
Bzd_Termin as PaymentDate,
Bzd_KwotaSys - Bzd_KwotaRozSys as GrossValue,
case when dfpl_fplid is null then @FplId else Bzd_FplId end as PaymentFormId,
case when  bzd_kierunek = 1 then 40 else 41 end as ErpDocumentType
   from cdn.bnkzdarzenia
join cdn.dokdefinicje on bzd_ddfid = ddf_ddfid
 LEFT JOIN cdn.detalformyplatnosci ON Bzd_FplId= dfpl_fplid and @ID =dfpl_dstaid
where Bzd_KwotaSys - Bzd_KwotaRozSys <> 0  and bzd_stan <> 0 and bzd_rozliczono <> 0 and
bzd_podmiottyp = 1
else
select
1 as Id ,
BzD_BZdId as ErpId,
(case when bzd_kierunek = 1 then 0 else 1 end) as IsReceivable,
BzD_PodmiotId as PayerId,
bzd_NumerPelny as ErpDocument,
Bzd_Termin as PaymentDate,
Bzd_KwotaSys - Bzd_KwotaRozSys as GrossValue,
case when dfpl_fplid is null then @FplId else Bzd_FplId end as PaymentFormId,
case when  bzd_kierunek = 1 then 40 else 41 end as ErpDocumentType
   from cdn.bnkzdarzenia
join cdn.dokdefinicje on bzd_ddfid = ddf_ddfid
 LEFT JOIN cdn.detalformyplatnosci ON Bzd_FplId= dfpl_fplid and @ID =dfpl_dstaid
Join cdn.kontrahenci on BzD_PodmiotId = Knt_KntId and bzd_podmiottyp = 1
where Bzd_KwotaSys - Bzd_KwotaRozSys <> 0 and bzd_stan <> 0 and bzd_rozliczono <> 0 and
bzd_podmiottyp = 1 AND Knt_Grupa = @KntGrupa
