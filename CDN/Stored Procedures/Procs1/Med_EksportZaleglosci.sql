CREATE PROCEDURE [CDN].[Med_EksportZaleglosci]
 @StanDetalID int AS
DECLARE
  @KartyJakoGotowka smallint
if exists (select fir_numer from cdn.firma where fir_numer =  1587 and fir_wartosc = 1) select @KartyJakoGotowka =1  else select @KartyJakoGotowka =0
select DTrN_DSTrNID from cdn.DetalTraNag
left join cdn.bnkzdarzenia on DTrN_OptimaId = BZd_DokumentID and BZd_DokumentTyp = 1
left join cdn.formyplatnosci on BZd_FPlId = FPl_FPlId
where
DTrN_StanDetalID = @StanDetalID and
DTrN_StanSynchronizacji = 1 or
(
Bzd_KwotaSys - Bzd_KwotaRozSys != 0 AND bzd_rozliczono != 0 and bzd_stan != 0 and
not (FPl_Typ = 1 and FPl_Termin = 0) or (FPl_Typ = 3 and @KartyJakoGotowka =1 and FPl_Termin = 0)
)
