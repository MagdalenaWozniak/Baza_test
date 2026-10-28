
--* gSkrypt.sOpis = $Tworzenie procedury CDN.Jpk_V7_Xml2Deklaracja$
-->
CREATE FUNCTION [CDN].[Jpk_V7_Xml2Deklaracja](@JpkId int)
RETURNS @Wyniki TABLE(
    CelZlozenia int,
    KodUrzedu nvarchar(255),
    Rok int,
    Miesiac int,
    NIP nvarchar(255),
    ImiePierwsze nvarchar(255),
    Nazwisko nvarchar(255),
    DataUrodzenia nvarchar(255),
    PelnaNazwa nvarchar(max),
    Email nvarchar(255),
    Telefon nvarchar(255),
		P_10 int,
		P_11 int,
		P_12 int,
		P_13 int,
		P_14 int,
		P_15 int,
		P_16 int,
		P_17 int,
		P_18 int,
		P_19 int,
		P_20 int,
		P_21 int,
		P_22 int,
		P_23 int,
		P_24 int,
		P_25 int,
		P_26 int,
		P_27 int,
		P_28 int,
		P_29 int,
		P_30 int,
		P_31 int,
		P_32 int,
		P_33 int,
		P_34 int,
		P_35 int,
		P_36 int,
		P_37 int,
		P_38 int,
		P_39 int,
		P_40 int,
		P_41 int,
		P_42 int,
		P_43 int,
		P_44 int,
		P_45 int,
		P_46 int,
		P_47 int,
		P_48 int,
		P_49 int,
		P_50 int,
		P_51 int,
		P_52 int,
		P_53 int,
		P_54 int,
		P_55 int,
		P_56 int,
		P_57 int,
		P_58 int,
		P_59 int,
		P_60 int,
		P_61 nvarchar(max),
		P_62 int,
		P_63 int,
		P_64 int,
		P_65 int,
		P_66 int,
		P_67 int,
		P_68 int,
		P_69 int,
		P_ORDZU nvarchar(max) )
as
Begin
        --private const string namespaceAP_M = "http://crd.gov.pl/wzor/2020/05/08/9393/";
        --private const string namespaceAP_K = "http://crd.gov.pl/wzor/2020/05/08/9394/";

	if exists (select * from CDN.PlikiJPK where JPK_JPKID = @JpkId and JPK_Typ='JPK_V7M')
		WITH xmlnamespaces ('http://crd.gov.pl/wzor/2020/05/08/9393/' as tns, 'http://crd.gov.pl/xml/schematy/dziedzinowe/mf/2020/03/11/eD/DefinicjeTypy/' as etd)
		Insert into  @Wyniki
		SELECT	
		
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:CelZlozenia)[1]', 'int') as CelZlozenia,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodUrzedu)[1]', 'nvarchar(255)') as CelZlozenia,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:Rok)[1]', 'int') as Rok,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:Miesiac)[1]', 'int') as Miesiac,
      
      IsNull(
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/etd:NIP)[1]', 'nvarchar(255)'),
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaNiefizyczna/tns:NIP)[1]', 'nvarchar(255)')
      ) as NIP,
      
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/etd:ImiePierwsze)[1]', 'nvarchar(255)') as ImiePierwsze,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/etd:Nazwisko)[1]', 'nvarchar(255)') as Nazwisko,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/etd:DataUrodzenia)[1]', 'nvarchar(255)') as DataUrodzenia,
      
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaNiefizyczna/tns:PelnaNazwa)[1]', 'nvarchar(255)') as PelnaNazwa,
      
      IsNull(
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/tns:Email)[1]', 'nvarchar(255)'),
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaNiefizyczna/tns:Email)[1]', 'nvarchar(255)')
      ) as Email,
      
      IsNull(
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/tns:Telefon)[1]', 'nvarchar(255)'),
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaNiefizyczna/tns:Telefon)[1]', 'nvarchar(255)')
      ) as Telefon,

			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_10)[1]', 'int') as P_10,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_11)[1]', 'int') as P_11,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_12)[1]', 'int') as P_12,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_13)[1]', 'int') as P_13,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_14)[1]', 'int') as P_14,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_15)[1]', 'int') as P_15,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_16)[1]', 'int') as P_16,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_17)[1]', 'int') as P_17,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_18)[1]', 'int') as P_18,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_19)[1]', 'int') as P_19,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_20)[1]', 'int') as P_20,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_21)[1]', 'int') as P_21,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_22)[1]', 'int') as P_22,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_23)[1]', 'int') as P_23,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_24)[1]', 'int') as P_24,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_25)[1]', 'int') as P_25,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_26)[1]', 'int') as P_26,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_27)[1]', 'int') as P_27,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_28)[1]', 'int') as P_28,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_29)[1]', 'int') as P_29,

			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_30)[1]', 'int') as P_30,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_31)[1]', 'int') as P_31,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_32)[1]', 'int') as P_32,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_33)[1]', 'int') as P_33,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_34)[1]', 'int') as P_34,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_35)[1]', 'int') as P_35,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_36)[1]', 'int') as P_36,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_37)[1]', 'int') as P_37,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_38)[1]', 'int') as P_38,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_39)[1]', 'int') as P_39,

			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_40)[1]', 'int') as P_40,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_41)[1]', 'int') as P_41,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_42)[1]', 'int') as P_42,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_43)[1]', 'int') as P_43,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_44)[1]', 'int') as P_44,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_45)[1]', 'int') as P_45,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_46)[1]', 'int') as P_46,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_47)[1]', 'int') as P_47,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_48)[1]', 'int') as P_48,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_49)[1]', 'int') as P_49,

			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_50)[1]', 'int') as P_50,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_51)[1]', 'int') as P_51,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_52)[1]', 'int') as P_52,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_53)[1]', 'int') as P_53,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_54)[1]', 'int') as P_54,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_55)[1]', 'int') as P_55,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_56)[1]', 'int') as P_56,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_57)[1]', 'int') as P_57,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_58)[1]', 'int') as P_58,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_59)[1]', 'int') as P_59,

			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_60)[1]', 'int') as P_60,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_61)[1]', 'nvarchar(max)') as P_61,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_62)[1]', 'int') as P_62,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_63)[1]', 'int') as P_63,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_64)[1]', 'int') as P_64,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_65)[1]', 'int') as P_65,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_66)[1]', 'int') as P_66,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_67)[1]', 'int') as P_67,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_68)[1]', 'int') as P_68,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_69)[1]', 'int') as P_69,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_ORDZU)[1]', 'nvarchar(max)') as P_ORDZU
		
		from CDN.PlikiJPK where Jpk_JpkId=@JpkId 
	else
		WITH xmlnamespaces ('http://crd.gov.pl/wzor/2020/05/08/9394/' as tns, 'http://crd.gov.pl/xml/schematy/dziedzinowe/mf/2020/03/11/eD/DefinicjeTypy/' as etd)
		Insert into  @Wyniki
		SELECT	
		
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:CelZlozenia)[1]', 'int') as CelZlozenia,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodUrzedu)[1]', 'nvarchar(255)') as CelZlozenia,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:Rok)[1]', 'int') as Rok,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:Miesiac)[1]', 'int') as Miesiac,
		
      IsNull(
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/etd:NIP)[1]', 'nvarchar(255)'),
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaNiefizyczna/tns:NIP)[1]', 'nvarchar(255)')
      ) as NIP,
      
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/etd:ImiePierwsze)[1]', 'nvarchar(255)') as ImiePierwsze,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/etd:Nazwisko)[1]', 'nvarchar(255)') as Nazwisko,
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/etd:DataUrodzenia)[1]', 'nvarchar(255)') as DataUrodzenia,
      		
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaNiefizyczna/tns:PelnaNazwa)[1]', 'nvarchar(255)') as PelnaNazwa,
      		
      IsNull(
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/tns:Email)[1]', 'nvarchar(255)'),
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaNiefizyczna/tns:Email)[1]', 'nvarchar(255)')
      ) as email,
      
      IsNull(
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaFizyczna/tns:Telefon)[1]', 'nvarchar(255)'),
      CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Podmiot1/tns:OsobaNiefizyczna/tns:Telefon)[1]', 'nvarchar(255)')
      ) as telefon,
		
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_10)[1]', 'int') as P_10,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_11)[1]', 'int') as P_11,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_12)[1]', 'int') as P_12,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_13)[1]', 'int') as P_13,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_14)[1]', 'int') as P_14,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_15)[1]', 'int') as P_15,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_16)[1]', 'int') as P_16,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_17)[1]', 'int') as P_17,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_18)[1]', 'int') as P_18,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_19)[1]', 'int') as P_19,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_20)[1]', 'int') as P_20,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_21)[1]', 'int') as P_21,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_22)[1]', 'int') as P_22,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_23)[1]', 'int') as P_23,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_24)[1]', 'int') as P_24,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_25)[1]', 'int') as P_25,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_26)[1]', 'int') as P_26,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_27)[1]', 'int') as P_27,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_28)[1]', 'int') as P_28,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_29)[1]', 'int') as P_29,

			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_30)[1]', 'int') as P_30,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_31)[1]', 'int') as P_31,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_32)[1]', 'int') as P_32,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_33)[1]', 'int') as P_33,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_34)[1]', 'int') as P_34,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_35)[1]', 'int') as P_35,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_36)[1]', 'int') as P_36,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_37)[1]', 'int') as P_37,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_38)[1]', 'int') as P_38,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_39)[1]', 'int') as P_39,

			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_40)[1]', 'int') as P_40,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_41)[1]', 'int') as P_41,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_42)[1]', 'int') as P_42,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_43)[1]', 'int') as P_43,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_44)[1]', 'int') as P_44,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_45)[1]', 'int') as P_45,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_46)[1]', 'int') as P_46,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_47)[1]', 'int') as P_47,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_48)[1]', 'int') as P_48,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_49)[1]', 'int') as P_49,

			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_50)[1]', 'int') as P_50,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_51)[1]', 'int') as P_51,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_52)[1]', 'int') as P_52,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_53)[1]', 'int') as P_53,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_54)[1]', 'int') as P_54,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_55)[1]', 'int') as P_55,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_56)[1]', 'int') as P_56,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_57)[1]', 'int') as P_57,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_58)[1]', 'int') as P_58,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_59)[1]', 'int') as P_59,

			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_60)[1]', 'int') as P_60,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_61)[1]', 'nvarchar(max)') as P_61,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_62)[1]', 'int') as P_62,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_63)[1]', 'int') as P_63,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_64)[1]', 'int') as P_64,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_65)[1]', 'int') as P_65,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_66)[1]', 'int') as P_66,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_67)[1]', 'int') as P_67,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_68)[1]', 'int') as P_68,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_69)[1]', 'int') as P_69,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:PozycjeSzczegolowe/tns:P_ORDZU)[1]', 'nvarchar(max)') as P_ORDZU
		
		from CDN.PlikiJPK where Jpk_JpkId=@JpkId 


	return
end
