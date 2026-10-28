CREATE FUNCTION CDN.Verify_JpkV7(@JpkNagId int)
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

	if exists(select * from cdn.JpkV7 where IsNull(NIP, '') = 'BRAK' and JpNId = @JpkNagId)
		insert into @result (vanid, message, type, resourceName, param01) (
		select 
		VaNId,
		'Na dokumencie ' + Dokument + ' w polu NIP zapisano BRAK. Zweryfikuj poprawność.',
		3, 'JpkVat_01', Dokument
		from cdn.JpkV7 where IsNull(NIP, '') = 'BRAK' and JpNId = @JpkNagId and Dokument != 'DEKLARACJA' and Dokument not like 'DEKLARACJA_%'
		)

	if exists(select * from cdn.JpkV7 where IsNull(Kontrahent, '') = 'BRAK' and JpNId = @JpkNagId)
		insert into @result (vanid, message, type, resourceName, param01) (
		select 
		VaNId,
		'Na dokumencie ' + Dokument + ' w polu Nazwa kontrahenta zapisano BRAK. Zweryfikuj poprawność.',
		3, 'JpkVat_02', Dokument
		from cdn.JpkV7 where IsNull(Kontrahent, '') = 'BRAK' and JpNId = @JpkNagId and Dokument != 'DEKLARACJA' and Dokument not like 'DEKLARACJA_%'
		)

	if exists(select * from cdn.JpkV7 where IsNull(Kontrahent, '') = 'SPRZEDAŻ PARAGONOWA' and JpNId = @JpkNagId)
		insert into @result (vanid, message, type, resourceName, param01) (
		select
		VaNId, 
		'Na dokumencie ' + Dokument + ' w polu Nazwa kontrahenta zapisano SPRZEDAŻ PARAGONOWA. Zweryfikuj poprawność.',
		3, 'JpkVat_04', Dokument
		from cdn.JpkV7 where IsNull(Kontrahent, '') = 'SPRZEDAŻ PARAGONOWA' and JpNId = @JpkNagId and Dokument != 'DEKLARACJA' and Dokument not like 'DEKLARACJA_%'
		)

	if exists(select * from cdn.JpkV7 where Typ=@REJESTR_ZAKUPOW and IsNull(NIP, '') = '' and JpNId = @JpkNagId)
		insert into @result (vanid, message, resourceName, param01) (
		select
		VaNId, 
		'Na dokumencie ' + Dokument + ' nie uzupełniono identyfikatora podatkowego kontrahenta. Zweryfikuj poprawność.'
		, 'JpkVat_06', Dokument
		from cdn.JpkV7 where Typ=@REJESTR_ZAKUPOW and IsNull(NIP, '') = '' and JpNId = @JpkNagId and Dokument != 'DEKLARACJA' and Dokument not like 'DEKLARACJA_%'
		)

	if exists(select * from cdn.JpkV7 where Typ=@REJESTR_ZAKUPOW and IsNull(Kontrahent, '') = '' and JpNId = @JpkNagId)
		insert into @result (vanid, message, resourceName, param01) (
		select
		VaNId, 
		'Na dokumencie ' + Dokument + ' nie uzupełniono nazwy kontrahenta. Zweryfikuj poprawność.'
		, 'JpkVat_07', Dokument
		from cdn.JpkV7 where Typ=@REJESTR_ZAKUPOW and IsNull(Kontrahent, '') = '' and JpNId = @JpkNagId and Dokument != 'DEKLARACJA' and Dokument not like 'DEKLARACJA_%'
		)


	return 
end
