CREATE PROCEDURE CDN.Med_OptimaFormyPlatnosci
AS
SET NOCOUNT ON
DECLARE
  @KartyJakoGotowka smallint
if exists (select fir_numer from cdn.firma where fir_numer =  1587 and fir_wartosc = 1) select @KartyJakoGotowka =1  else select @KartyJakoGotowka =0
  select fpl_fplid,fpl_nazwa,fpl_nieaktywny,
(case when (FPl_Typ = 1 and FPl_Termin = 0) or (FPl_Typ = 3 and @KartyJakoGotowka =1 and FPl_Termin = 0)then 1 else 0 end) as DFPl_Gotowka,
     FPl_Termin,
     case when Bra_typ = 2 then bna_Nazwa1 else ''end as NazwaRachunku,
     case when Bra_typ = 2 then bra_RachunekNr else ''end as RachunekNr
 from cdn.formyplatnosci
   left join cdn.bnkrachunki on fpl_braid = bra_braid
   left join cdn.bnknazwy on bra_bnaid = bna_bnaid
SET NOCOUNT OFF
