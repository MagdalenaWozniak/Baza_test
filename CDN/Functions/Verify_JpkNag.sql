 CREATE FUNCTION CDN.Verify_JpkNag(@JpkNagId int)
RETURNS @Result TABLE(
	message varchar (512),
	type int default (4),
	resourceName varchar(256) default (''),
	param01 varchar(256) default (''),
	param02 varchar(256) default ('')
)
AS
BEGIN

	-- cdn.JpkNag::Typ
    -- 0 Undefined = 0,
    -- 1 Ksiegi_Rachunkowe,
    -- 2 Wyciag_Bankowy,
    -- 3 Magazyn,
    -- 4 Ewidencje_Zakupu_Sprzedazy_VAT,
    -- 5 Faktury_VAT,
    -- 6 Podatkowa_Księga_Przychodów_Rozchodow,
    -- 7 Ewidencja_Przychodow
	-- 8 JPK_V7M
	-- 9 JPK_V7K

	declare @typ int;
	declare @wersja int;
	select @typ = Typ, @wersja = Wersja from cdn.jpknag where id = @JpkNagId;

	--if @typ in (8,9)
		


	if @Typ not in (4,8,9) or @Wersja < 2 and @Typ not in (8,9)
	begin
		if exists(select * from cdn.JpkNag where IsNull(PodAdrKodKraju, '') = '' and id = @JpkNagId)
			insert into @result (message, resourceName) values('Nie uzupełniono pola Kod kraju w Pieczątce firmy.', 'JpkNag_01');

		if exists(select * from cdn.JpkNag where IsNull(PodAdrMiejscowosc, '') = '' and id = @JpkNagId)
			insert into @result (message, resourceName) values('Nie uzupełniono pola Miejscowość w Pieczątce firmy.', 'JpkNag_02');
	end


	if @Typ in (4, 6, 8, 9) and @Wersja >= 1 
	begin
		if exists(select * from cdn.JpkNag where IsNull(PodPelnaNazwa, '') = '' and id = @JpkNagId)
			insert into @result (message, resourceName) values('Nie uzupełniono pola Nazwa firmy w Pieczątce Firmy.', 'JpkNag_03');
	end


	if exists(select * from cdn.JpkNag where IsNull(PodNip, '') = '' and id = @JpkNagId)
		insert into @result (message, resourceName) values('Nie uzupełniono pola NIP w Pieczątce firmy.', 'JpkNag_04');

	if @Typ in (4, 6, 8, 9) and @Wersja >= 1 
	begin
		if exists(select * from cdn.JpkNag where IsNull(PodPelnaNazwa, '') = '' and id = @JpkNagId)
			insert into @result (message, resourceName) values('Nie uzupełniono pola Nazwa firmy w Pieczątce Firmy.', 'JpkNag_03');
	end
	

	if @Typ IN (4, 6, 8, 9) and @Wersja >= 1 return;


	if exists(select * from cdn.JpkNag where len(IsNull(PodRegon,'')) not in (0,9,14) and id = @JpkNagId)
	begin
		declare @regon varchar(16);
		select @regon = IsNull(PodRegon,'') from cdn.JpkNag where id = @JpkNagId;
		insert into @result (message, resourceName, param01) values('Nr REGON ['+@regon+'] zawiera niepoprawną ilość znaków.', 'JpkNag_05', @regon);
	end

	if exists(select * from cdn.JpkNag where IsNull(PodAdrWojewodztwo, '') = '' and id = @JpkNagId)
		insert into @result (message, resourceName) values('Nie uzupełniono pola Województwo w Pieczątce firmy.', 'JpkNag_06');

	if exists(select * from cdn.JpkNag where IsNull(PodAdrPowiat, '') = '' and id = @JpkNagId)
		insert into @result (message, resourceName) values('Nie uzupełniono pola Powiat w Pieczątce firmy.', 'JpkNag_07');

	if exists(select * from cdn.JpkNag where IsNull(PodAdrGmina, '') = '' and id = @JpkNagId)
		insert into @result (message, resourceName) values('Nie uzupełniono pola Gmina w Pieczątce firmy.', 'JpkNag_08');

	if exists(select * from cdn.JpkNag where IsNull(PodAdrNrDomu, '') = '' and id = @JpkNagId)
		insert into @result (message, resourceName) values('Nie uzupełniono pola Nr domu w Pieczątce firmy.', 'JpkNag_09');

	if exists(select * from cdn.JpkNag where IsNull(PodAdrKodP, '') = '' and id = @JpkNagId)
		insert into @result (message, resourceName) values('Nie uzupełniono pola Kod pocztowy w Pieczątce firmy.', 'JpkNag_10');

	if exists(select * from cdn.JpkNag where IsNull(PodAdrPoczta, '') = '' and id = @JpkNagId)
		insert into @result (message, resourceName) values('Nie uzupełniono pola Poczta w Pieczątce firmy.', 'JpkNag_11');

	return 
end
