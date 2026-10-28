create procedure cdn.Synch2015 @pWynik INT OUT
as
begin
set nocount on
if exists ( select * from cdn.Firma where Fir_Numer = 2223)
 select @pWynik = Fir_Wartosc from cdn.Firma where Fir_Numer = 2223
else
 set @pWynik = 0
set nocount off
end
