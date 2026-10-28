create procedure cdn.AddDokDef @numer int, @id int, @nazwa nvarchar(100), @klasa int = 0
as
if @id is null
select top 1 @id = ddf_ddfid from cdn.DokDefinicje where ddf_klasa = @klasa
if @id is not null
begin
if exists (select * from cdn.Firma where fir_numer = @numer)
update cdn.Firma set fir_wartosc = ltrim(str(@id)) where fir_numer = @numer
else
insert into cdn.Firma (fir_numer, fir_wartosc, fir_opis) values(@numer, ltrim(str(@id)), @nazwa)
end
