Create procedure [CDN].[SynchStrPodlXL] @pWynik INT OUT
as
begin
set nocount on
if exists ( select * from cdn.Firma where Fir_Numer = 2237)
 select @pWynik = Fir_Wartosc from cdn.Firma where Fir_Numer = 2237
else
 set @pWynik = 0
set nocount off
end
