create  Procedure [CDN].[UstawRachunki] @RachunekLp int, @PlatnikID int, @PlatnikTyp int
As
SET NOCOUNT ON
declare
@NrRachunku nvarchar(255)
set @NrRachunku = ''
--exec [CDN].[UstawRachunki] 0, 1, 5, ''
--select @rachunekLp = 0,@PlatnikID = 1,@PlatnikTyp =5, @NrRachunku = ''
if @RachunekLp != 0
if (@PlatnikTyp = 1 or @PlatnikTyp = 3)  --kontrahent lub wspólnik
 select @NrRachunku = isnull(SPL_RachunekNr,'') from CDN.SchematPlatnosci where SPL_SplId = @RachunekLp
if (@PlatnikTyp = 5) --urząd
 select @NrRachunku = isnull(URa_RachunekNr,'') from CDN.UrzRachunki where URa_Lp = @RachunekLp and URa_UrzId = @PlatnikID
if @NrRachunku = ''
begin
 if (@PlatnikTyp = 1)
 begin
  select top 1 @RachunekLp = isnull(SPL_SplId, 0) , @NrRachunku = isnull(SPL_RachunekNr,'')  from CDN.SchematPlatnosci
  where SPL_PodmiotTyp = @PlatnikTyp  and SPL_PodmiotID = @PlatnikID and SPL_Reszta =1
 end
 if (@PlatnikTyp = 3)
    select top 1 @RachunekLp = isnull(SPL_SplId, 0) , @NrRachunku = isnull(SPL_RachunekNr,'')
    from CDN.SchematPlatnosci where SPL_PodmiotTyp = @PlatnikTyp
    and SPL_PodmiotID = @PlatnikID
    and SPL_FplId in (select FPl_FPlId from cdn.FormyPlatnosci where FPl_Typ = 2)
    order by SPL_LiczbaPorz
 if (@PlatnikTyp = 5)
 begin
  SELECT top 1  @NrRachunku = isnull(URa_RachunekNr,''), @RachunekLp = isnull(URa_Lp, 0)
   FROM CDN.UrzRachunki LEFT OUTER JOIN CDN.Urzedy ON URa_UrzId = Urz_UrzId
    WHERE URa_RachunekNr <> '' AND URa_Lp >= 0  AND URa_UrzId = @PlatnikID
    and Urz_TypUrzedu = 2 and URa_Lp = 3
  if @NrRachunku = ''
    SELECT top 1  @NrRachunku = isnull(URa_RachunekNr,''), @RachunekLp = isnull(URa_Lp, 0)
   FROM CDN.UrzRachunki LEFT OUTER JOIN CDN.Urzedy ON URa_UrzId = Urz_UrzId
    WHERE URa_RachunekNr <> '' AND URa_Lp >= 0  AND URa_UrzId = @PlatnikID
    and Urz_TypUrzedu < 3 and Urz_TypUrzedu != 2 and Urz_TypUrzedu != 1 and URa_Lp = 3
  if @NrRachunku = ''
    SELECT top 1  @NrRachunku = isnull(URa_RachunekNr,''), @RachunekLp = isnull(URa_Lp, 0)
   FROM CDN.UrzRachunki LEFT OUTER JOIN CDN.Urzedy ON URa_UrzId = Urz_UrzId
    WHERE URa_RachunekNr <> '' AND URa_Lp >= 0  AND URa_UrzId = @PlatnikID
    and Urz_TypUrzedu >= 3
 end
end
if @NrRachunku = ''
 set @RachunekLp = 0
SET NOCOUNT OFF
select @RachunekLp  ,@NrRachunku
