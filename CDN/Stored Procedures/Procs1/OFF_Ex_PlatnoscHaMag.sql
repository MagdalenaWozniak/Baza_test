CREATE PROCEDURE CDN.OFF_Ex_PlatnoscHaMag
 @TrN_TrNID INT,
 @Trn_PodID INT
  AS
  select (case when bzd_kierunek = 1 then 2 else 1 end) as bzd_kierunek,
         bzd_kwotasys,
         bzd_kwotarozsys ,
         bzd_termin,
         Fpl_XLID,
         0 as Rozliczaj
  from cdn.bnkzdarzenia
  join cdn.formyplatnosci on bzd_fplid = fpl_fplid where bzd_dokumentId =@TrN_TrNID and bzd_PodmiotId =@Trn_PodID
