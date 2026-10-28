create procedure CDN.DodajFirmaDefaultDokDefinicje
as
declare @id int
select @id = DDF_DdfId from cdn.DokDefinicje where DDf_Klasa = 600 and DDf_SeriaOperatora = 1 and DDf_Symbol = 'E' and DDf_Nieaktywna = 0
if @id > 0
exec CDN.AddDokDef 1980, @id, 'Domyślny typ - lista płac'
else
begin
select @id = DDF_DdfId from cdn.DokDefinicje where DDf_Klasa = 600 and DDf_SeriaOperatora = 1 and DDf_Symbol <> 'BOWYP' and DDf_Nieaktywna = 0
if @id > 0
exec CDN.AddDokDef 1980, @id, 'Domyślny typ - lista płac'
else
begin
select @id = min(DDF_DdfId) from cdn.DokDefinicje where DDf_Klasa = 600 and DDf_Symbol <> 'BOWYP' and DDf_Nieaktywna = 0
if @id > 0
exec CDN.AddDokDef 1980, @id, 'Domyślny typ - lista płac'
end
end
set @id = 0
select @id = DDF_DdfId from cdn.DokDefinicje where DDf_Klasa = 400 and DDf_Symbol = 'UMW' and DDf_Nieaktywna = 0
if @id > 0
begin
exec CDN.AddDokDef 2980, @id, 'Domyślny typ - umowa'
end
else
begin
select @id = min(DDF_DdfId) from cdn.DokDefinicje where DDf_Klasa = 400 and DDf_Symbol <> 'BOUMW' and DDf_Nieaktywna = 0
if @id > 0
exec CDN.AddDokDef 2980, @id, 'Domyślny typ - umowa'
end
set @id = 0
select @id = DDF_DdfId from cdn.DokDefinicje where DDf_Klasa = 410 and DDf_Symbol = 'EDOK' and DDf_Nieaktywna = 0
if @id > 0
begin
exec CDN.AddDokDef 2970, @id, 'Domyślny typ - e-Teczka'
end
else
begin
select @id = min(DDF_DdfId) from cdn.DokDefinicje where DDf_Klasa = 410 and DDf_Nieaktywna = 0
if @id > 0
exec CDN.AddDokDef 2970, @id, 'Domyślny typ - e-Teczka'
end
set @id = 0
if not (select Fir_Wartosc from cdn.Firma where Fir_Numer = 1819) > 0
begin
select @id = min(DDF_DdfId) from cdn.DokDefinicje where DDf_Klasa = 650
if @id > 0
exec CDN.AddDokDef 1819, @id, 'Domyślny typ - Etat korygująca'
end
