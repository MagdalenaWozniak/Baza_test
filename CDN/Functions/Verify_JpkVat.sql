CREATE FUNCTION CDN.Verify_JpkVat(@JpkNagId int)
RETURNS @Result TABLE(	
	message varchar (512),
	vanid int,
	type int default (4),
	resourceName varchar(256) default (''),
	param01 varchar(256) default (''),
	param02 varchar(256) default ('')
)
AS
BEGIN

	declare @REJESTR_ZAKUPOW	int = 1;
	declare @REJESTR_SPRZEDAZY	int = 2;

	if exists(select * from cdn.Jpkvat where IsNull(NIP, '') = 'BRAK' and JpNId = @JpkNagId)
		insert into @result (vanid, message, type, resourceName, param01) (
		select 
		VaNId,
		'Na dokumencie ' + Dokument + ' w polu NIP zapisano BRAK. Zweryfikuj poprawność.',
		3, 'JpkVat_01', Dokument
		from cdn.Jpkvat where IsNull(NIP, '') = 'BRAK' and JpNId = @JpkNagId
		)
	if exists(select * from cdn.Jpkvat where IsNull(Kontrahent, '') = 'BRAK' and JpNId = @JpkNagId)
		insert into @result (vanid, message, type, resourceName, param01) (
		select 
		VaNId,
		'Na dokumencie ' + Dokument + ' w polu Nazwa kontrahenta zapisano BRAK. Zweryfikuj poprawność.',
		3, 'JpkVat_02', Dokument
		from cdn.Jpkvat where IsNull(Kontrahent, '') = 'BRAK' and JpNId = @JpkNagId
		)
	if exists(select * from cdn.Jpkvat where IsNull(Adres, '') = 'BRAK' and JpNId = @JpkNagId)
		insert into @result (vanid, message, type, resourceName, param01) (
		select
		VaNId, 
		'Na dokumencie ' + Dokument + ' w polu Adres kontrahenta zapisano BRAK. Zweryfikuj poprawność.',
		3, 'JpkVat_03', Dokument
		from cdn.Jpkvat where IsNull(Adres, '') = 'BRAK' and JpNId = @JpkNagId
		)
	if exists(select * from cdn.Jpkvat where IsNull(Kontrahent, '') = 'SPRZEDAŻ PARAGONOWA' and JpNId = @JpkNagId)
		insert into @result (vanid, message, type, resourceName, param01) (
		select
		VaNId, 
		'Na dokumencie ' + Dokument + ' w polu Nazwa kontrahenta zapisano SPRZEDAŻ PARAGONOWA. Zweryfikuj poprawność.',
		3, 'JpkVat_04', Dokument
		from cdn.Jpkvat where IsNull(Kontrahent, '') = 'SPRZEDAŻ PARAGONOWA' and JpNId = @JpkNagId
		)
	if exists(select * from cdn.Jpkvat where IsNull(Adres, '') = 'SPRZEDAŻ PARAGONOWA' and JpNId = @JpkNagId)
		insert into @result (vanid, message, type, resourceName, param01) (
		select
		VaNId, 
		'Na dokumencie ' + Dokument + ' w polu Adres kontrahenta zapisano SPRZEDAŻ PARAGONOWA. Zweryfikuj poprawność.',
		3, 'JpkVat_05', Dokument
		from cdn.Jpkvat where IsNull(Adres, '') = 'SPRZEDAŻ PARAGONOWA' and JpNId = @JpkNagId
		)
		


	if exists(select * from cdn.Jpkvat where Typ=@REJESTR_ZAKUPOW and IsNull(NIP, '') = '' and JpNId = @JpkNagId)
		insert into @result (vanid, message, resourceName, param01) (
		select
		VaNId, 
		'Na dokumencie ' + Dokument + ' nie uzupełniono identyfikatora podatkowego kontrahenta. Zweryfikuj poprawność.'
		, 'JpkVat_06', Dokument
		from cdn.Jpkvat where Typ=@REJESTR_ZAKUPOW and IsNull(NIP, '') = '' and JpNId = @JpkNagId
		)

	if exists(select * from cdn.Jpkvat where Typ=@REJESTR_ZAKUPOW and IsNull(Kontrahent, '') = '' and JpNId = @JpkNagId)
		insert into @result (vanid, message, resourceName, param01) (
		select
		VaNId, 
		'Na dokumencie ' + Dokument + ' nie uzupełniono nazwy kontrahenta. Zweryfikuj poprawność.'
		, 'JpkVat_07', Dokument
		from cdn.Jpkvat where Typ=@REJESTR_ZAKUPOW and IsNull(Kontrahent, '') = '' and JpNId = @JpkNagId
		)


	if exists(select * from cdn.Jpkvat where Typ=@REJESTR_ZAKUPOW and IsNull(Adres, '') = '' and JpNId = @JpkNagId)
		insert into @result (vanid, message, resourceName, param01) (
		select
		VaNId, 
		'Na dokumencie ' + Dokument + ' nie uzupełniono danych adresowych kontrahenta. Zweryfikuj poprawność.'
		, 'JpkVat_08', Dokument
		from cdn.Jpkvat where Typ=@REJESTR_ZAKUPOW and IsNull(Adres, '') = '' and JpNId = @JpkNagId
		)

	return 
end
