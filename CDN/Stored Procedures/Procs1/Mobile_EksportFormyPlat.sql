CREATE Procedure [CDN].[Mobile_EksportFormyPlat]
@ID INT
AS
declare
  @KartyJakoGotowka smallint
if exists (select fir_numer from cdn.firma where fir_numer =  1587 and fir_wartosc = 1) select @KartyJakoGotowka =1  else select @KartyJakoGotowka =0
select dfpl_fplid as Kon_Lp , Dfpl_NazwaDetal as Kon_FormaPl,0 as Kon_FormaPlRabat, fpl_termin as Kon_FormaPlTermin, 1 as Kon_Dostepna,
    case when (FPl_Typ = 1 and FPl_Termin = 0) or (FPl_Typ = 3 and @KartyJakoGotowka =1 and FPl_Termin = 0)then 1 else Fpl_Typ end as Kon_Typ
 from cdn.detalformyplatnosci
join cdn.formyplatnosci on dfpl_fplid = fpl_fplid
where Dfpl_Dstaid = @ID
ORDER BY Dfpl_dfplid
