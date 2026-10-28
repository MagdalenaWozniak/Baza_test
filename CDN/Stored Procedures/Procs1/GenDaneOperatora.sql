create Procedure CDN.GenDaneOperatora
@ID int
as
Set NoCount on
DECLARE @dbn nvarchar(300)
DECLARE @srv nvarchar(300)
select @dbn = sys_wartosc from cdn.systemcdn where sys_id = 1002
select @srv = sys_wartosc from cdn.systemcdn where sys_id = 1001
DECLARE @fulldbname nVARCHAR(300)
If  @srv = CONVERT(sysname, SERVERPROPERTY('servername'))
 Or IsNull (CONVERT(sysname, SERVERPROPERTY('servername')), '') = ''
  Set @srv = ''
  If  @srv = ''
   Set @fulldbname = '[' + @dbn + ']'
  Else
   Set @fulldbname = '[' + @srv + '].[' + @dbn + ']'
declare @Query1  nvarchar(2000)
set @Query1 =
N'select Ope_Kod AS Kod,Ope_Nazwisko AS Nazwisko,Ope_OpeID,Ope_Kod,Ope_Nazwisko,Ope_Haslo,Ope_HasloChk,Ope_NTSid,Ope_NTKonto,Ope_NTLogin,Ope_Administrator,Ope_Startowa,Ope_BuforNazwa,Ope_KsiegaGlowna,Ope_BuforVATSpr,Ope_BuforVATZak,Ope_BuforKasa,Ope_BuforOkres,
Ope_BuforAmortyz,Ope_BuforPlace,Ope_BuforEwid,Ope_ZakazCenyZak,Ope_ZmianyOffLine,Ope_TylkoStartowa,Ope_KlasycznaKlawiatura,Ope_Powiadamianie,Ope_NumerSMS,Ope_Email,Ope_NazwaKomputera,Ope_InfoPoUruchomieniu,Ope_InfoRazDziennie,Ope_ZmianaLimituKred,
Ope_ZmianaKategorii,Ope_Kierownik,Ope_BlokadaZmianTowaru,Ope_BlokadaZmianMagazynu,Ope_BlokadaZmianMagazynuListy,Ope_BlokadaZmianCenFA,Ope_BlokadaZmianCenFPF,Ope_BlokadaZmianCenPA,Ope_BlokadaZmianCenRO,Ope_BlokadaZmianCenZD,
Ope_BlokadaZmianCenFZ,Ope_BlokadaFAPAdoBufora,Ope_BlokadaPonownejFiskFAPA,Ope_ZapisFAPApoWydruku,Ope_ZamkniecieDnia,Ope_AktualizacjaKntHaMag,Ope_ZmianaOpisuHaMag,Ope_MinMarzaHaMag,Ope_BlokadaAnulowaniaHaMag,Ope_RozliczanieZListyHaMag,
Ope_SymbolDlaNumeracji,Ope_Magazyn,Ope_Kasa,Ope_Parametr,Ope_Nieaktywny,Ope_KodDlaDF,Ope_Opis,Ope_InfoData,Ope_GIDTyp,Ope_GIDFirma,
Ope_GIDNumer,Ope_GIDLp,Ope_PelneMenu,Ope_ModulKP,Ope_ModulKH,Ope_ModulST,Ope_ModulFA,Ope_ModulMAG,Ope_ModulPK,Ope_ModulPKXL,Ope_ModulANL,Ope_ModulCRM,Ope_ModulKHP,Ope_ModulDET,Ope_ModulBIU,Ope_BlokadaPlac,Ope_BlokadaDanychPlacowych,Ope_Bank
from ' + @fulldbname +N'.CDN.Operatorzy where Ope_OpeID='
+ convert(nvarchar(20),@ID)
Set NoCount Off
Execute dbo.sp_executesql @Query1
