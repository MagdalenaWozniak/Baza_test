CREATE PROCEDURE [CDN].[PrzepiszDaneZeSklep]
AS
BEGIN
SET NOCOUNT ON
declare
 @ESS_Typ tinyint,
 @ESS_ASSerwer nvarchar(254),
 @ESS_Hash nvarchar(54),
 @ESS_IdKlienta nvarchar(10),
 @ESS_IdISklep int,
 @ESS_DomyslnaWaluta nvarchar(5),
 @ESS_DomyslnyMagazyn int,
 @ESS_ExpZasoby tinyint,
 @ESS_WyslijStanWszystkieMag tinyint,
 @ESS_StanyNaDzien tinyint,
 @ESS_TwGNumer int,
 @ESS_SchematNumeracjiRO int,
 @ESS_SchematNumeracjiROSeria nvarchar(10),
 @ESS_ExpGrup tinyint,
 @ESS_ExpGrupTyp tinyint,
 @ESS_NrCeny int,
 @ESS_NrCenyDomyslnej int,
 @ESS_EsklepCena0 tinyint,
 @ESS_ExpCennik tinyint,
 @ESS_ExpCennikTyp tinyint,
 @ESS_KosztPrzesylki int,
 @ESS_FormaPlatnosciESPOS1 int,
 @ESS_FormaPlatnosciESPOS2 int,
 @ESS_FormaPlatnosciESPOS3 int,
 @ESS_FormaPlatnosciESPOS4 int,
 @ESS_FormaPlatnosciESPOS5 int,
 @ESS_KntSprawdzNIP tinyint,
 @ESS_KntSprawdzEMail tinyint,
 @ESS_DaneFirmyNazwa nvarchar(254),
 @ESS_DaneFirmyOpis nvarchar(254),
 @ESS_DaneFirmyUlica nvarchar(254),
 @ESS_DaneFirmyNrDomu nvarchar(254),
 @ESS_DaneFirmyNrMieszkania nvarchar(254),
 @ESS_DaneFirmyMiasto nvarchar(254),
 @ESS_DaneFirmyKodPocztowy nvarchar(254),
 @ESS_DaneFirmyWojewodztwo nvarchar(254),
 @ESS_DaneFirmyTelefon nvarchar(254),
 @ESS_DaneFirmyEmail nvarchar(254),
 @ESS_DaneFirmyURL nvarchar(254),
 @ESS_DaneFirmyGG nvarchar(254),
 @ESS_DaneFirmySkype nvarchar(254),
 @ESS_DaneFirmyLogo int,
 @ESS_DaneFirmyRok nvarchar(4),
 @ESS_DaneFirmyGSM nvarchar(254),
 @ESS_DaneFirmyFacebook nvarchar(254),
 @ESS_TS_Synchro int,
 @ESS_TS_SynchroPotw int,
 @ESS_TS_SynchroTwr int,
 @ESS_TS_SynchroTwrPotw int,
 @ESS_TS_SynchroKnt int,
 @ESS_TS_SynchroKntPotw int,
 @ESS_TS_SynchroGrup int,
 @ESS_TS_SynchroGrupPotw int,
 @ESS_TS_SynchroSlowniki int,
 @ESS_ESSID int
 IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1800) SELECT @ESS_Typ = 0 ELSE SELECT @ESS_Typ = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1800
 IF @ESS_Typ = 0
  return
 IF @ESS_Typ = 1
 BEGIN
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1842) SELECT @ESS_ASSerwer = '' ELSE SELECT @ESS_ASSerwer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1842
  if (@ESS_ASSerwer = 'serwis.esklep.icomarch24.pl')
    SELECT @ESS_ASSerwer = 'https://serwis.isklep24.pl/comarchsrv/'
  SET @ESS_Hash = ''
  SET @ESS_IdKlienta = ''
  SET @ESS_IdISklep = 0
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849) SELECT @ESS_DomyslnaWaluta = '' ELSE SELECT @ESS_DomyslnaWaluta = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1848) SELECT @ESS_DomyslnyMagazyn = 0 ELSE SELECT @ESS_DomyslnyMagazyn = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1848
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1855) SELECT @ESS_ExpZasoby = 0 ELSE SELECT @ESS_ExpZasoby = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1855
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1895) SELECT @ESS_WyslijStanWszystkieMag = 0 ELSE SELECT @ESS_WyslijStanWszystkieMag = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1895
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 2080) SELECT @ESS_StanyNaDzien = 0 ELSE SELECT @ESS_StanyNaDzien = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 2080
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1837) SELECT @ESS_TwGNumer = 0 ELSE SELECT @ESS_TwGNumer = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1837
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1890) SELECT @ESS_SchematNumeracjiRO = 0 ELSE SELECT @ESS_SchematNumeracjiRO = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1890
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1891) SELECT @ESS_SchematNumeracjiROSeria = '' ELSE SELECT @ESS_SchematNumeracjiROSeria = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1891
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1838) SELECT @ESS_ExpGrup = 0 ELSE SELECT @ESS_ExpGrup = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1838
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1839) SELECT @ESS_ExpGrupTyp = 0 ELSE SELECT @ESS_ExpGrupTyp = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1839
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1833) SELECT @ESS_NrCeny = 0 ELSE SELECT @ESS_NrCeny = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1833
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1834) SELECT @ESS_NrCenyDomyslnej = 0 ELSE SELECT @ESS_NrCenyDomyslnej = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1834
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1889) SELECT @ESS_EsklepCena0 = 0 ELSE SELECT @ESS_EsklepCena0 = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1889
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1831) SELECT @ESS_ExpCennik = 0 ELSE SELECT @ESS_ExpCennik = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1831
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1832) SELECT @ESS_ExpCennikTyp = 0 ELSE SELECT @ESS_ExpCennikTyp = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1832
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1844) SELECT @ESS_KosztPrzesylki = 0 ELSE SELECT @ESS_KosztPrzesylki = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1844
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1845) SELECT @ESS_FormaPlatnosciESPOS1 = 0 ELSE SELECT @ESS_FormaPlatnosciESPOS1 = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1845
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1846) SELECT @ESS_FormaPlatnosciESPOS2 = 0 ELSE SELECT @ESS_FormaPlatnosciESPOS2 = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1846
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1847) SELECT @ESS_FormaPlatnosciESPOS3 = 0 ELSE SELECT @ESS_FormaPlatnosciESPOS3 = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1847
  SET @ESS_FormaPlatnosciESPOS4 = 0
  SET @ESS_FormaPlatnosciESPOS5 = 0
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1893) SELECT @ESS_KntSprawdzNIP = 0 ELSE SELECT @ESS_KntSprawdzNIP = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1893
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1894) SELECT @ESS_KntSprawdzEMail = 0 ELSE SELECT @ESS_KntSprawdzEMail = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1894
  select @ESS_DaneFirmyNazwa ='',
         @ESS_DaneFirmyOpis ='',
         @ESS_DaneFirmyUlica ='',
         @ESS_DaneFirmyNrDomu ='',
         @ESS_DaneFirmyNrMieszkania ='',
         @ESS_DaneFirmyMiasto ='',
         @ESS_DaneFirmyKodPocztowy ='',
         @ESS_DaneFirmyWojewodztwo ='',
         @ESS_DaneFirmyTelefon ='',
         @ESS_DaneFirmyEmail ='',
         @ESS_DaneFirmyURL ='',
         @ESS_DaneFirmyGG  ='',
         @ESS_DaneFirmySkype ='',
         @ESS_DaneFirmyLogo =0,
         @ESS_DaneFirmyRok ='',
         @ESS_DaneFirmyGSM ='',
         @ESS_DaneFirmyFacebook  =''
     IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1827) SELECT @ESS_TS_Synchro = 0 ELSE SELECT @ESS_TS_Synchro = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1827
     IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1828) SELECT @ESS_TS_SynchroPotw = 0 ELSE SELECT @ESS_TS_SynchroPotw = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1828
     IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1829) SELECT @ESS_TS_SynchroKnt = 0 ELSE SELECT @ESS_TS_SynchroKnt = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1829
     IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1830) SELECT @ESS_TS_SynchroKntPotw = 0 ELSE SELECT @ESS_TS_SynchroKntPotw = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1830
        IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1835) SELECT @ESS_TS_SynchroTwr = 0 ELSE SELECT @ESS_TS_SynchroTwr = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1835
        IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @ESS_TS_SynchroTwrPotw = 0 ELSE SELECT @ESS_TS_SynchroTwrPotw = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1836
        IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1840) SELECT @ESS_TS_SynchroGrup = 0 ELSE SELECT @ESS_TS_SynchroGrup = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1840
        IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1841) SELECT @ESS_TS_SynchroGrupPotw = 0 ELSE SELECT @ESS_TS_SynchroGrupPotw = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1841
        set @ESS_TS_SynchroSlowniki = 0
 END
 ELSE
 BEGIN
  SET @ESS_ASSerwer = ''
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1912) SELECT @ESS_Hash = '' ELSE SELECT @ESS_Hash = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1912
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1911) SELECT @ESS_IdKlienta = 0 ELSE SELECT @ESS_IdKlienta = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1911
  SET @ESS_IdISklep = 0
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1903) SELECT @ESS_DomyslnaWaluta = '' ELSE SELECT @ESS_DomyslnaWaluta = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1903
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1896) SELECT @ESS_DomyslnyMagazyn = 0 ELSE SELECT @ESS_DomyslnyMagazyn = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1896
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1897) SELECT @ESS_ExpZasoby = 0 ELSE SELECT @ESS_ExpZasoby = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1897
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1898) SELECT @ESS_WyslijStanWszystkieMag = 0 ELSE SELECT @ESS_WyslijStanWszystkieMag = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1898
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1899) SELECT @ESS_StanyNaDzien = 0 ELSE SELECT @ESS_StanyNaDzien = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1899
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900) SELECT @ESS_TwGNumer = 0 ELSE SELECT @ESS_TwGNumer = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1900
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1901) SELECT @ESS_SchematNumeracjiRO = 0 ELSE SELECT @ESS_SchematNumeracjiRO = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1901
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1902) SELECT @ESS_SchematNumeracjiROSeria = '' ELSE SELECT @ESS_SchematNumeracjiROSeria = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1902
  SET @ESS_ExpGrup = 0
  SET @ESS_ExpGrupTyp = 0
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1904) SELECT @ESS_NrCeny = 0 ELSE SELECT @ESS_NrCeny = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1904
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1935) SELECT @ESS_NrCenyDomyslnej = 0 ELSE SELECT @ESS_NrCenyDomyslnej = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1935
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1905) SELECT @ESS_EsklepCena0 = 0 ELSE SELECT @ESS_EsklepCena0 = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1905
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1906) SELECT @ESS_ExpCennik = 0 ELSE SELECT @ESS_ExpCennik = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1906
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1907) SELECT @ESS_ExpCennikTyp = 0 ELSE SELECT @ESS_ExpCennikTyp = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1907
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1908) SELECT @ESS_KosztPrzesylki = 0 ELSE SELECT @ESS_KosztPrzesylki = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1908
  SET @ESS_FormaPlatnosciESPOS1 = 0
  SET @ESS_FormaPlatnosciESPOS2 = 0
  SET @ESS_FormaPlatnosciESPOS3 = 0
  SET @ESS_FormaPlatnosciESPOS4 = 0
  SET @ESS_FormaPlatnosciESPOS5 = 0
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1909) SELECT @ESS_KntSprawdzNIP = 0 ELSE SELECT @ESS_KntSprawdzNIP = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1909
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1910) SELECT @ESS_KntSprawdzEMail = 0 ELSE SELECT @ESS_KntSprawdzEMail = CONVERT(TINYINT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1910
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1913) SELECT @ESS_DaneFirmyNazwa = '' ELSE SELECT @ESS_DaneFirmyNazwa = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1913
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1914) SELECT @ESS_DaneFirmyOpis = '' ELSE SELECT @ESS_DaneFirmyOpis = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1914
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1915) SELECT @ESS_DaneFirmyUlica = '' ELSE SELECT @ESS_DaneFirmyUlica = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1915
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1916) SELECT @ESS_DaneFirmyNrDomu = '' ELSE SELECT @ESS_DaneFirmyNrDomu = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1916
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1917) SELECT @ESS_DaneFirmyNrMieszkania = '' ELSE SELECT @ESS_DaneFirmyNrMieszkania = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1917
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1918) SELECT @ESS_DaneFirmyMiasto = '' ELSE SELECT @ESS_DaneFirmyMiasto = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1918
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1919) SELECT @ESS_DaneFirmyKodPocztowy = '' ELSE SELECT @ESS_DaneFirmyKodPocztowy = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1919
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1920) SELECT @ESS_DaneFirmyWojewodztwo = '' ELSE SELECT @ESS_DaneFirmyWojewodztwo = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1920
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1921) SELECT @ESS_DaneFirmyTelefon = '' ELSE SELECT @ESS_DaneFirmyTelefon = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1921
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1922) SELECT @ESS_DaneFirmyEmail = '' ELSE SELECT @ESS_DaneFirmyEmail = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1922
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1923) SELECT @ESS_DaneFirmyURL = '' ELSE SELECT @ESS_DaneFirmyURL = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1923
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1924) SELECT @ESS_DaneFirmyGG = '' ELSE SELECT @ESS_DaneFirmyGG = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1924
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1925) SELECT @ESS_DaneFirmySkype = '' ELSE SELECT @ESS_DaneFirmySkype = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1925
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1926) SELECT @ESS_DaneFirmyLogo = 0 ELSE SELECT @ESS_DaneFirmyLogo = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1926
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1927) SELECT @ESS_DaneFirmyRok = 0 ELSE SELECT @ESS_DaneFirmyRok = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1927
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1936) SELECT @ESS_DaneFirmyGSM = '' ELSE SELECT @ESS_DaneFirmyGSM = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1936
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1937) SELECT @ESS_DaneFirmyFacebook = '' ELSE SELECT @ESS_DaneFirmyFacebook = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1937
  IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1929) SELECT @ESS_TS_Synchro = 0 ELSE SELECT @ESS_TS_Synchro = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1929
     IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1930) SELECT @ESS_TS_SynchroPotw = 0 ELSE SELECT @ESS_TS_SynchroPotw = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1930
     IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1931) SELECT @ESS_TS_SynchroKnt = 0 ELSE SELECT @ESS_TS_SynchroKnt = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1931
     IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1932) SELECT @ESS_TS_SynchroKntPotw = 0 ELSE SELECT @ESS_TS_SynchroKntPotw = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1932
        IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1933) SELECT @ESS_TS_SynchroTwr = 0 ELSE SELECT @ESS_TS_SynchroTwr = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1933
        IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1934) SELECT @ESS_TS_SynchroTwrPotw = 0 ELSE SELECT @ESS_TS_SynchroTwrPotw = CONVERT(INT,Fir_Wartosc) FROM Cdn.Firma WHERE Fir_Numer = 1934
        SET @ESS_TS_SynchroGrup = 0
        SET @ESS_TS_SynchroGrupPotw = 0
        IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1928) SELECT @ESS_TS_SynchroSlowniki = 0 ELSE SELECT @ESS_TS_SynchroSlowniki = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1928
 END
 INSERT INTO CDN.eSklepStanowiska(
 ESS_Typ,
 ESS_Nazwa,
 ESS_ASSerwer,
 ESS_Hash,
 ESS_IdKlienta,
 ESS_IdISklep,
 ESS_DomyslnaWaluta,
 ESS_DomyslnyMagazyn,
 ESS_ExpZasoby,
 ESS_WyslijStanWszystkieMag,
 ESS_StanyNaDzien,
 ESS_WyslijCechyPartii,
 ESS_TwGNumer,
 ESS_SchematNumeracjiRO,
 ESS_SchematNumeracjiROSeria,
 ESS_ExpGrup,
 ESS_ExpGrupTyp,
 ESS_NrCeny,
 ESS_NrCenyDomyslnej,
 ESS_EsklepCena0,
 ESS_ExpCennik,
 ESS_ExpCennikTyp,
 ESS_KosztPrzesylki,
 ESS_FormaPlatnosciESPOS1,
 ESS_FormaPlatnosciESPOS2,
 ESS_FormaPlatnosciESPOS3,
 ESS_FormaPlatnosciESPOS4,
 ESS_FormaPlatnosciESPOS5,
 ESS_KntSprawdzNIP,
 ESS_KntSprawdzEMail,
 ESS_KntGrupa,
 ESS_DaneFirmyNazwa,
 ESS_DaneFirmyOpis,
 ESS_DaneFirmyUlica,
 ESS_DaneFirmyNrDomu,
 ESS_DaneFirmyNrMieszkania,
 ESS_DaneFirmyMiasto,
 ESS_DaneFirmyKodPocztowy,
 ESS_DaneFirmyWojewodztwo,
 ESS_DaneFirmyTelefon,
 ESS_DaneFirmyEmail,
 ESS_DaneFirmyURL,
 ESS_DaneFirmyGG,
 ESS_DaneFirmySkype,
 ESS_DaneFirmyLogo,
 ESS_DaneFirmyRok,
 ESS_DaneFirmyGSM,
 ESS_DaneFirmyFacebook,
 ESS_FakturaPDF,
 ESS_TS_Synchro,
 ESS_TS_SynchroPotw,
 ESS_TS_SynchroTwr,
 ESS_TS_SynchroTwrPotw,
 ESS_TS_SynchroKnt,
 ESS_TS_SynchroKntPotw,
 ESS_TS_SynchroGrup,
 ESS_TS_SynchroGrupPotw,
 ESS_TS_SynchroSlowniki)
 SELECT
 @ESS_Typ,
 '',
 @ESS_ASSerwer,
 @ESS_Hash,
 @ESS_IdKlienta,
 @ESS_IdISklep,
 @ESS_DomyslnaWaluta,
 @ESS_DomyslnyMagazyn,
 @ESS_ExpZasoby,
 @ESS_WyslijStanWszystkieMag,
 @ESS_StanyNaDzien,
 0,
 @ESS_TwGNumer,
 @ESS_SchematNumeracjiRO,
 @ESS_SchematNumeracjiROSeria,
 @ESS_ExpGrup,
 @ESS_ExpGrupTyp,
 @ESS_NrCeny,
 @ESS_NrCenyDomyslnej,
 @ESS_EsklepCena0,
 @ESS_ExpCennik,
 @ESS_ExpCennikTyp,
 @ESS_KosztPrzesylki,
 @ESS_FormaPlatnosciESPOS1,
 @ESS_FormaPlatnosciESPOS2,
 @ESS_FormaPlatnosciESPOS3,
 @ESS_FormaPlatnosciESPOS4,
 @ESS_FormaPlatnosciESPOS5,
 @ESS_KntSprawdzNIP,
 @ESS_KntSprawdzEMail,
 '',
 @ESS_DaneFirmyNazwa,
 @ESS_DaneFirmyOpis,
 @ESS_DaneFirmyUlica,
 @ESS_DaneFirmyNrDomu,
 @ESS_DaneFirmyNrMieszkania,
 @ESS_DaneFirmyMiasto,
 @ESS_DaneFirmyKodPocztowy,
 @ESS_DaneFirmyWojewodztwo,
 @ESS_DaneFirmyTelefon,
 @ESS_DaneFirmyEmail,
 @ESS_DaneFirmyURL,
 @ESS_DaneFirmyGG,
 @ESS_DaneFirmySkype,
 @ESS_DaneFirmyLogo,
 @ESS_DaneFirmyRok,
 @ESS_DaneFirmyGSM,
 @ESS_DaneFirmyFacebook,
 0,
 @ESS_TS_Synchro,
 @ESS_TS_SynchroPotw,
 @ESS_TS_SynchroTwr,
 @ESS_TS_SynchroTwrPotw,
 @ESS_TS_SynchroKnt,
 @ESS_TS_SynchroKntPotw,
 @ESS_TS_SynchroGrup,
 @ESS_TS_SynchroGrupPotw,
 @ESS_TS_SynchroSlowniki
 SET @ESS_ESSID = 0
 SELECT TOP 1 @ESS_ESSID = ESS_ESSID FROM CDN.eSklepStanowiska
 alter table CDN.TraNag  disable  trigger all
 UPDATE CDN.TraNag set TrN_eSklepID = @ESS_ESSID  where TrN_GIDNumer > 0
 alter table CDN.TraNag  enable  trigger all
 UPDATE CDN.Kontrahenci set Knt_eSklepID = @ESS_ESSID  where Knt_GIDNumer > 0 AND Knt_GIDFirma > 0
    INSERT INTO CDN.eSklepKntRelacje ( ESK_KntOptimaID,ESK_KnteSklepID,ESK_eSklepID)
    Select A.Knt_KntId,A.Knt_GIDNumer,A.Knt_eSklepID From CDN.Kontrahenci A
          WHERE IsNull(A.Knt_eSklepID, 0) > 0 AND  IsNull(A.Knt_GIDNumer, 0) <> 0  AND A.Knt_KntId not in (Select A.Knt_KntId From CDN.Kontrahenci A, CDN.eSklepKntRelacje B Where
          A.Knt_eSklepID = B.ESK_eSklepID  And
          A.Knt_GIDNumer = B.ESK_KnteSklepID And
          A.Knt_KntId   = B.ESK_KntOptimaID  And
          IsNull(A.Knt_GIDNumer, 0) <> 0  And
          IsNull(A.Knt_eSklepID, 0) <> 0 )
 IF @ESS_ESSID > 0
 BEGIN
  IF @ESS_Typ = 2
  INSERT INTO CDN.eSklepFormyPlatnosci(
  ESF_ESSId,
  ESF_IGFPlId,
  ESF_FPlId,
  ESF_Nazwa,
  ESF_Aktywna)
  SELECT
  @ESS_ESSID,
  IGFPl_IGFPlId,
  IGFPl_FPlId,
  IGFPl_Nazwa,
  IGFPl_Aktywna
  FROM
  CDN.IGaleriaFormyPlatnosci
  IF @ESS_Typ = 1
  BEGIN
     INSERT INTO CDN.eSklepFormyPlatnosci(
  ESF_ESSId,
  ESF_IGFPlId,
  ESF_FPlId,
  ESF_Nazwa,
  ESF_Aktywna)
  SELECT
  @ESS_ESSID,
  1,
  @ESS_FormaPlatnosciESPOS1,
  'GOTÓWKA',
  1
  INSERT INTO CDN.eSklepFormyPlatnosci(
  ESF_ESSId,
  ESF_IGFPlId,
  ESF_FPlId,
  ESF_Nazwa,
  ESF_Aktywna)
  SELECT
  @ESS_ESSID,
  2,
  @ESS_FormaPlatnosciESPOS3,
  'ON-LINE',
  1
  INSERT INTO CDN.eSklepFormyPlatnosci(
  ESF_ESSId,
  ESF_IGFPlId,
  ESF_FPlId,
  ESF_Nazwa,
  ESF_Aktywna)
  SELECT
  @ESS_ESSID,
  3,
  @ESS_FormaPlatnosciESPOS2,
  'PRZELEW',
  1
  INSERT INTO CDN.eSklepFormyPlatnosci(
  ESF_ESSId,
  ESF_IGFPlId,
  ESF_FPlId,
  ESF_Nazwa,
  ESF_Aktywna)
  SELECT
  @ESS_ESSID,
  4,
  0,
  'RATY',
  1
  INSERT INTO CDN.eSklepFormyPlatnosci(
  ESF_ESSId,
  ESF_IGFPlId,
  ESF_FPlId,
  ESF_Nazwa,
  ESF_Aktywna)
  SELECT
  @ESS_ESSID,
  5,
  0,
  'Dodatkowa 1',
  1
  INSERT INTO CDN.eSklepFormyPlatnosci(
  ESF_ESSId,
  ESF_IGFPlId,
  ESF_FPlId,
  ESF_Nazwa,
  ESF_Aktywna)
  SELECT
  @ESS_ESSID,
  6,
  0,
  'Dodatkowa 2',
  1
  END
 END
 SET NOCOUNT OFF
END
