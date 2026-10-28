CREATE PROCEDURE CDN.Med_EksportFormyPlatnosci
  @ID INT      -- ID Stanowiska
AS
SET NOCOUNT ON
DECLARE
  @KartyJakoGotowka smallint
if exists (select fir_numer from cdn.firma where fir_numer =  1587 and fir_wartosc = 1) select @KartyJakoGotowka =1  else select @KartyJakoGotowka =0
  SELECT
    DFPl_FPlId as FPl_OptimaId,
    DFPl_NazwaDetal as FPl_Nazwa,
    FPl_Nieaktywny,
    DFPl_Domyslna,
    (case when (FPl_Typ = 1 and FPl_Termin = 0) or (FPl_Typ = 3 and @KartyJakoGotowka =1 and FPl_Termin = 0)then 1 else 0 end) as DFPl_Gotowka,
     FPl_Termin,
     case when Bra_typ = 2 then bna_Nazwa1 else ''end as NazwaRachunku,
     case when Bra_typ = 2 then bra_RachunekNr else ''end as RachunekNr
   from CDN.DetalFormyPlatnosci
   left join CDN.FormyPlatnosci ON DFPl_FPlId = FPl_FPlId
   left join cdn.bnkrachunki on fpl_braid = bra_braid
   left join cdn.bnknazwy on bra_bnaid = bna_bnaid
   where Dfpl_dstaid = @ID
SET NOCOUNT OFF
