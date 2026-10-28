CREATE PROCEDURE CDN.JpkGenerujNag
@JpkMode int,
@JpkTyp int,
@Wersja int,
@CelZlozenia int,
@DataWytworzenia DateTime,
@ZakresDat tinyint,
@DataOd DateTime, 
@DataDo DateTime, 
@Waluta varchar(3),
@Magazyn nvarchar(50),
@KodUrzedu varchar(4),

@PieczPelnaNazwa nvarchar(512),
@PieczNIP varchar(16),
@PieczRegon varchar(16),
@PieczAdrKodKraju varchar(2),
@PieczAdrWojewodztwo nvarchar(40),
@PieczAdrPowiat nvarchar(40),
@PieczAdrGmina nvarchar(40),
@PieczAdrMiejscowosc nvarchar(40),
@PieczAdrUlica nvarchar(40),
@PieczAdrNrDomu nvarchar(10),
@PieczAdrNrLokalu nvarchar(10),
@PieczAdrKodP nvarchar(10),
@PieczAdrPoczta nvarchar(40),

@NazwaSystemu nvarchar(255),
@Email nvarchar(255),

@OsobaFizyczna int,
@Imie nvarchar(255),
@Nazwisko nvarchar(255),
@Telefon nvarchar(255),
@DataUrodzenia DateTime,

@Bufor tinyint,
@OObId int,
@WspolczynnikSprzedazy decimal(5,2),
@JpkNagId int OUTPUT
AS

	insert into CDN.JpkNag (Mode, Typ, Wersja, CelZlozenia, DataWytworzenia, ZakresDat, DataOd, DataDo, Waluta, Magazyn,
		KodUrzedu, 
		PodPelnaNazwa, PodNIP, PodRegon, PodAdrKodKraju, PodAdrWojewodztwo, PodAdrPowiat, PodAdrGmina, PodAdrMiejscowosc, PodAdrUlica, PodAdrNrDomu, PodAdrNrLokalu, PodAdrKodP, PodAdrPoczta,
		NazwaSystemu, PodEMail,
		OsobaFizyczna,Imie,Nazwisko,Telefon,DataUrodzenia,
		Bufor, OObId, WspolczynnikSprzedazy)
	values(@JpkMode, @JpkTyp, @Wersja, @CelZlozenia, @DataWytworzenia, @ZakresDat, Convert(Date,@DataOd), Convert(Date,@DataDo), 

		rtrim(ltrim(@Waluta)),
		rtrim(ltrim(@Magazyn)),
		rtrim(ltrim(@KodUrzedu)),
		SUBSTRING(rtrim(ltrim(@PieczPelnaNazwa)),1,240),
		CDN.NIP('',@PieczNIP), 
		rtrim(ltrim(@PieczRegon)),
		rtrim(ltrim(@PieczAdrKodKraju)),
		rtrim(ltrim(@PieczAdrWojewodztwo)),
		rtrim(ltrim(@PieczAdrPowiat)),
		rtrim(ltrim(@PieczAdrGmina)),
		rtrim(ltrim(@PieczAdrMiejscowosc)),
		rtrim(ltrim(@PieczAdrUlica)),
		rtrim(ltrim(@PieczAdrNrDomu)),
		rtrim(ltrim(@PieczAdrNrLokalu)), 
		rtrim(ltrim(@PieczAdrKodP)),
		rtrim(ltrim(@PieczAdrPoczta)),

		rtrim(ltrim(@NazwaSystemu)),
		rtrim(ltrim(@Email)),

		@OsobaFizyczna,
		rtrim(ltrim(@Imie)),
		rtrim(ltrim(@Nazwisko)),
		rtrim(ltrim(@Telefon)),
		convert(varchar, @DataUrodzenia, 23),
		@Bufor, 
		@OObId,
		@WspolczynnikSprzedazy);

	select @JpkNagId = SCOPE_IDENTITY();

	return

