CREATE PROCEDURE CDN.Sendit_DataZmianyDanych
as
begin
declare @datamod datetime,@datasynchro datetime
if not exists (select * from cdn.firma where fir_numer = 1943)
select @datamod = convert(datetime, 0,120)
else select @datamod = convert(datetime, fir_wartosc,120) from cdn.firma where fir_numer = 1943
if not exists (select * from cdn.firma where fir_numer = 1944)
select @datasynchro = convert(datetime, 0,120)
else select @datasynchro = convert(datetime, fir_wartosc,120) from cdn.firma where fir_numer = 1944
if @datamod > @datasynchro select 1 else select 0
end
