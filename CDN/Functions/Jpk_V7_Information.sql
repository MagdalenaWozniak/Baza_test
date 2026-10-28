
--* gSkrypt.sOpis = $Tworzenie procedury CDN.Jpk_V7_Information$
-->
CREATE FUNCTION [CDN].[Jpk_V7_Information]()
RETURNS @Wyniki TABLE(
JpkId int,
CelZlozenia int,
KodUrzedu nvarchar(50),  
Rok int,
Miesiac int,
Kwartalna int,
kodSystemowy nvarchar(50),  
KodFormularza nvarchar(50),  
wersjaSchemy nvarchar(50),  
Sprzedaz int,		
Zakup int,		
Deklaracja int,		
Ewidencja int,		
KodFormularzaDekl nvarchar(50),  
wersjaSchemyDekl nvarchar(50),  
kodSystemowyDekl nvarchar(50)
)

AS
begin

	declare @NodeDeklaracka nvarchar(50) = 'Deklaracja';
	declare @NodeEwidencja nvarchar(50) = 'Ewidencja';
	declare @NodeSprzedaz nvarchar(50) = 'SprzedazWiersz';
	declare @NodeZakup nvarchar(50) = 'ZakupWiersz';
	
	
	
	WITH xmlnamespaces ('http://crd.gov.pl/wzor/2020/05/08/9393/' as tns)
	insert into @Wyniki 
	SELECT	Jpk_JpkId,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:CelZlozenia)[1]', 'int') as CelZlozenia,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodUrzedu)[1]', 'nvarchar(10)') as KodUrzedu,  
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:Rok)[1]', 'int') as Rok,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:Miesiac)[1]', 'int') as Miesiac,
			0 as Kwartalna,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodFormularza/@kodSystemowy)[1]', 'nvarchar(50)') as kodSystemowy,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodFormularza)[1]', 'nvarchar(50)') as KodFormularza,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodFormularza/@wersjaSchemy)[1]', 'nvarchar(50)') as wersjaSchemy,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).exist(N'//.[local-name()=sql:variable("@NodeSprzedaz")]') as Sprzedaz,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).exist(N'//.[local-name()=sql:variable("@NodeZakup")]') as Zakup,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).exist(N'//.[local-name()=sql:variable("@NodeDeklaracka")]') as Deklaracja,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).exist(N'//.[local-name()=sql:variable("@NodeEwidencja")]') as Ewidencja,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:Naglowek/tns:KodFormularzaDekl)[1]', 'nvarchar(50)') as KodFormularzaDekl,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:Naglowek/tns:KodFormularzaDekl/@wersjaSchemy)[1]', 'nvarchar(50)') as wersjaSchemyDekl,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:Naglowek/tns:KodFormularzaDekl/@kodSystemowy)[1]', 'nvarchar(50)') as kodSystemowyDekl
	from CDN.PlikiJPK where JPK_Typ = 'JPK_V7M';

	WITH xmlnamespaces ('http://crd.gov.pl/wzor/2020/05/08/9394/' as tns)
	insert into @Wyniki 
	SELECT	Jpk_JpkId,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:CelZlozenia)[1]', 'int') as CelZlozenia,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodUrzedu)[1]', 'nvarchar(10)') as KodUrzedu,  
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:Rok)[1]', 'int') as Rok,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:Miesiac)[1]', 'int') as Miesiac,
			1 as Kwartalna,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodFormularza/@kodSystemowy)[1]', 'nvarchar(50)') as kodSystemowy,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodFormularza)[1]', 'nvarchar(50)') as KodFormularza,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Naglowek/tns:KodFormularza/@wersjaSchemy)[1]', 'nvarchar(50)') as wersjaSchemy,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).exist(N'//.[local-name()=sql:variable("@NodeSprzedaz")]') as Sprzedaz,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).exist(N'//.[local-name()=sql:variable("@NodeZakup")]') as Zakup,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).exist(N'//.[local-name()=sql:variable("@NodeDeklaracka")]') as Deklaracja,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).exist(N'//.[local-name()=sql:variable("@NodeEwidencja")]') as Ewidencja,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:Naglowek/tns:KodFormularzaDekl)[1]', 'nvarchar(50)') as KodFormularzaDekl,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:Naglowek/tns:KodFormularzaDekl/@wersjaSchemy)[1]', 'nvarchar(50)') as wersjaSchemyDekl,
			CONVERT(xml,(CONVERT(varbinary(max),JPK_XML))).value('(/tns:JPK/tns:Deklaracja/tns:Naglowek/tns:KodFormularzaDekl/@kodSystemowy)[1]', 'nvarchar(50)') as kodSystemowyDekl
	from CDN.PlikiJPK where JPK_Typ = 'JPK_V7K';


	return 
end
