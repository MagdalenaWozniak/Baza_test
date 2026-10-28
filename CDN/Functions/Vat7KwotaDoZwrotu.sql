
--* gSkrypt.sOpis = $Tworzenie funkcji CDN.Vat7KwotaDoZwrotu$
-->
CREATE FUNCTION CDN.Vat7KwotaDoZwrotu(@DkNId int, @RodzajKwoty int)
RETURNS decimal(15,2)
AS
BEGIN
--@RodzajKwoty
--1 na rachunek VAT
--2  25 dni
--3  60 dni
--4 180 dni

	declare @result decimal(15,2) = 0;	
	declare @wersja int; select @wersja = DkN_Wersja from cdn.DeklNag where DkN_DkNId = @DkNId;
	
	if @wersja < 21
	begin
		set @result  = 
		case @RodzajKwoty 
			when 1 then CDN.KwotaKsiegDekl (@DkNId, 15101)
			when 2 then CDN.KwotaKsiegDekl (@DkNId, 15102)
			when 3 then CDN.KwotaKsiegDekl (@DkNId, 15105)
			when 4 then CDN.KwotaKsiegDekl (@DkNId, 15110)
			else 0
		end
	end
	else
	begin
		declare @KwotaDoZwrotu int; select @KwotaDoZwrotu = CDN.KwotaKsiegDekl (@DkNId, 15101);
		if @KwotaDoZwrotu = 1
		begin
			declare @KwotaDoZwrotuRodzaj int; select @KwotaDoZwrotuRodzaj = CDN.KwotaKsiegDekl (@DkNId, 15102);
			if @KwotaDoZwrotuRodzaj = @RodzajKwoty
				set @result = CDN.KwotaKsiegDekl (@DkNId, 15100);;
		end
	end
	

	return @result;
END
