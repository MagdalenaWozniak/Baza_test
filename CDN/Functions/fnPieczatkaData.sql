CREATE function [CDN].[fnPieczatkaData](
 @Data datetime, /*data obowiązywania pieczątek*/
 @DrukujJednSam int = 0 /*Parametr na definicji wydruku "Dane jednostki samorządowej na wydruku."*/)
RETURNS @Pieczatka TABLE(
  Firm_Logo   [image]
 ,Firm_Nazwa1  nvarchar(50)
 ,Firm_Nazwa2  nvarchar(50)
 ,Firm_Nazwa3  nvarchar(512)
 ,Firm_NipKraj  nvarchar(2)
 ,Firm_NipE   nvarchar(20)
 ,Firm_Regon   nvarchar(20)
 ,Firm_Kraj   nvarchar(40)
 ,Firm_KrajISO  nvarchar(9)
 ,Firm_Wojewodztwo nvarchar(40)
 ,Firm_Powiat  nvarchar(40)
 ,Firm_Gmina   nvarchar(40)
 ,Firm_KodGminy  nvarchar(7)
 ,Firm_Miasto  nvarchar(40)
 ,Firm_Ulica   nvarchar(40)
 ,Firm_NrDomu  nvarchar(10)
 ,Firm_NrLokalu  nvarchar(10)
 ,Firm_KodP   nvarchar(10)
 ,Firm_Poczta  nvarchar(40)
 ,Firm_UlNrDomLok nvarchar(62)
 ,Firm_Telefon  nvarchar(20)
 ,Firm_Email   nvarchar(127)
 ,Firm_URL   nvarchar(254)
 ,Firm_Opis   nvarchar(50)
 ,Firm_KRS_Sad  nvarchar(100)
 ,Firm_KRS_Numer  nvarchar(10)
 ,Firm_KRS_KapZak nvarchar(40)
 ,Firm_KRS_KapWpl nvarchar(40)
 ,Firm_ILNGLNWlasny nvarchar(13)
 ,Firm_ILNGLNCentr nvarchar(13)
 ,Firm_PUESC   nvarchar(50)
 ,Firm_KGO   nvarchar(30)
 ,Firm_String  nvarchar(2048)
 ,Firm_UlicaString nvarchar(70)
 ,Firm_PocztaString nvarchar(70)
 ,Jorg_Nazwa1  nvarchar(50)
 ,Jorg_Nazwa2  nvarchar(50)
 ,Jorg_Nazwa3  nvarchar(512)
 ,Jorg_NipKraj  nvarchar(2)
 ,Jorg_NipE   nvarchar(20)
 ,Jorg_Regon   nvarchar(20)
 ,Jorg_Kraj   nvarchar(40)
 ,Jorg_KrajISO  nvarchar(9)
 ,Jorg_Wojewodztwo nvarchar(40)
 ,Jorg_Powiat  nvarchar(40)
 ,Jorg_Gmina   nvarchar(40)
 ,Jorg_KodGminy  nvarchar(7)
 ,Jorg_Miasto  nvarchar(40)
 ,Jorg_Ulica   nvarchar(40)
 ,Jorg_NrDomu  nvarchar(10)
 ,Jorg_NrLokalu  nvarchar(10)
 ,Jorg_KodP   nvarchar(10)
 ,Jorg_Poczta  nvarchar(40)
 ,Jorg_UlNrDomLok nvarchar(62)
 ,Jorg_Telefon  nvarchar(20)
 ,Jorg_Email   nvarchar(127)
 ,Jorg_URL   nvarchar(254)
 ,Jorg_String  nvarchar(2048)
 ,Jorg_UlicaString nvarchar(70)
 ,Jorg_PocztaString nvarchar(70)
 )
AS
BEGIN
 IF @DrukujJednSam = 1 AND EXISTS(SELECT * FROM CDN.PieczatkiJS WHERE @Data BETWEEN PCJS_DataOd AND PCJS_DataDo)
 BEGIN
  INSERT INTO @Pieczatka
  SELECT (SELECT TOP 1 DAB_Wartosc from  [CDN].[DaneBinarne] where Dab_typ = 13 and DAB_TwAID = PC_PCID)
    ,PCJS_Nazwa1, PCJS_Nazwa2, PCJS_Nazwa3
   ,PCJS_NipKraj, PCJS_NipE, PCJS_Regon
   ,PCJS_Kraj, PCJS_KrajISO, PCJS_Wojewodztwo, PCJS_Powiat, PCJS_Gmina, PCJS_KodGminy
   ,PCJS_Miasto, PCJS_Ulica, PCJS_NrDomu, PCJS_NrLokalu, PCJS_KodP, PCJS_Poczta, PCJS_UlicaNrDomLok
   ,PCJS_Telefon, PCJS_Email, PCJS_URL, ISNULL(PC_Opis,'')
   ,PC_KRS_Sad, PC_KRS_Numer, PC_KRS_KapitalZak, PC_KRS_KapitalWpl, PC_ILNGLNWlasny, PC_ILNGLNCentrali, PC_PUESC, PC_BDO
   ,ISNULL(PCJS_Nazwa1,'') + CASE WHEN PCJS_Nazwa2 <> '' THEN CHAR(13) + CHAR(10) + PCJS_Nazwa2 ELSE '' END + CASE WHEN PCJS_Nazwa3 <> '' THEN CHAR(13) + PCJS_Nazwa3 ELSE '' END
   + CHAR(13) + CASE WHEN PCJS_Ulica <> '' THEN PCJS_Ulica WHEN ISNULL(PCJS_Ulica,'') = '' AND PCJS_Miasto <> '' THEN PCJS_Miasto ELSE ISNULL(PCJS_Poczta,'') END
   + ' ' + CASE WHEN PCJS_NrDomu <> '' AND PCJS_NrLokalu <> '' THEN PCJS_NrDomu + '/' + PCJS_NrLokalu WHEN PCJS_NrDomu <> '' AND ISNULL(PCJS_NrLokalu,'') = '' THEN PCJS_NrDomu ELSE ISNULL(PCJS_NrLokalu,'') END
   + CASE WHEN PCJS_Ulica <> '' AND PCJS_Miasto <> PCJS_Ulica AND PCJS_Miasto <> PCJS_Poczta AND PCJS_Poczta <> '' THEN ', ' + PCJS_Miasto ELSE '' END
   + CASE WHEN PCJS_KodP <> '' THEN CHAR(13) + PCJS_KodP ELSE '' END + CASE WHEN PCJS_Poczta <> '' THEN PCJS_Poczta WHEN ISNULL(PCJS_Poczta,'')='' AND PCJS_Miasto <> '' THEN PCJS_Miasto ELSE '' END
   + CASE WHEN PCJS_Nipe <> '' THEN CHAR(13) + 'NIP: ' + CASE WHEN PCJS_NipKraj <> '' THEN  PCJS_NipKraj + ' ' ELSE '' END + PCJS_Nipe ELSE '' END
   + CASE WHEN PC_BDO <> '' THEN CHAR(13) + 'Numer rejestrowy: ' + PC_BDO ELSE '' END
   + CASE WHEN PCJS_Telefon <> '' THEN CHAR(13) + 'tel: ' + PCJS_Telefon ELSE '' END
   ,CASE WHEN PCJS_Ulica <> '' THEN PCJS_Ulica WHEN ISNULL(PCJS_Ulica,'') = '' AND PCJS_Miasto <> '' THEN PCJS_Miasto ELSE ISNULL(PCJS_Poczta,'') END
   + ' ' + CASE WHEN PCJS_NrDomu <> '' AND PCJS_NrLokalu <> '' THEN PCJS_NrDomu + '/' + PCJS_NrLokalu WHEN PCJS_NrDomu <> '' AND ISNULL(PCJS_NrLokalu,'') = '' THEN PCJS_NrDomu ELSE ISNULL(PCJS_NrLokalu,'') END
   + CASE WHEN PCJS_Ulica <> '' AND PCJS_Miasto <> PCJS_Ulica AND PCJS_Miasto <> PCJS_Poczta AND PCJS_Poczta <> '' THEN ', ' + PCJS_Miasto ELSE '' END
   ,CASE WHEN PCJS_KodP <> '' THEN PCJS_KodP + ' ' ELSE CHAR(13) END + CASE WHEN PCJS_Poczta <> '' THEN PCJS_Poczta WHEN ISNULL(PCJS_Poczta,'')='' AND PCJS_Miasto <> '' THEN PCJS_Miasto ELSE '' END
   ,PC_Nazwa1, PC_Nazwa2, PC_Nazwa3
   ,PC_NipKraj, PC_NipE, PC_Regon
   ,PC_Kraj, PC_KrajISO, PC_Wojewodztwo, PC_Powiat, PC_Gmina, PC_KodGminy
   ,PC_Miasto, PC_Ulica, PC_NrDomu, PC_NrLokalu, PC_KodP, PC_Poczta, PC_UlicaNrDomLok
   ,PC_Telefon, PC_Email, PC_URL
   ,ISNULL(PC_Nazwa1,'') + CASE WHEN PC_Nazwa2 <> '' THEN CHAR(13) + PC_Nazwa2 ELSE '' END + CASE WHEN PC_Nazwa3 <> '' THEN CHAR(13) + PC_Nazwa3 ELSE '' END
   + CHAR(13) + CASE WHEN PC_Ulica <> '' THEN PC_Ulica WHEN ISNULL(PC_Ulica,'') = '' AND PC_Miasto <> '' THEN PC_Miasto ELSE ISNULL(PC_Poczta,'') END
   + ' ' + CASE WHEN PC_NrDomu <> '' AND PC_NrLokalu <> '' THEN PC_NrDomu + '/' + PC_NrLokalu WHEN PC_NrDomu <> '' AND ISNULL(PC_NrLokalu,'') = '' THEN PC_NrDomu ELSE ISNULL(PC_NrLokalu,'') END
   + CASE WHEN PC_Ulica <> '' AND PC_Miasto <> PC_Ulica AND PC_Miasto <> PC_Poczta AND PC_Poczta <> '' THEN ', ' + PC_Miasto ELSE '' END
   + CASE WHEN PC_KodP <> '' THEN CHAR(13) + PC_KodP + ' ' ELSE CHAR(13) END + CASE WHEN PC_Poczta <> '' THEN PC_Poczta WHEN ISNULL(PC_Poczta,'')='' AND PC_Miasto <> '' THEN PC_Miasto ELSE '' END
   ,CASE WHEN PC_Ulica <> '' THEN PC_Ulica WHEN ISNULL(PC_Ulica,'') = '' AND PC_Miasto <> '' THEN PC_Miasto ELSE ISNULL(PC_Poczta,'') END
   + ' ' + CASE WHEN PC_NrDomu <> '' AND PC_NrLokalu <> '' THEN PC_NrDomu + '/' + PC_NrLokalu WHEN PC_NrDomu <> '' AND ISNULL(PC_NrLokalu,'') = '' THEN PC_NrDomu ELSE ISNULL(PC_NrLokalu,'') END
   + CASE WHEN PC_Ulica <> '' AND PC_Miasto <> PC_Ulica AND PC_Miasto <> PC_Poczta AND PC_Poczta <> '' THEN ', ' + PC_Miasto ELSE '' END
   ,CASE WHEN PC_KodP <> '' THEN PC_KodP + ' ' ELSE '' END + CASE WHEN PC_Poczta <> '' THEN PC_Poczta WHEN ISNULL(PC_Poczta,'')='' AND PC_Miasto <> '' THEN PC_Miasto ELSE '' END
  FROM CDN.Pieczatki
  LEFT JOIN CDN.PieczatkiJS on @Data BETWEEN PCJS_DataOd AND PCJS_DataDo
  WHERE @Data BETWEEN PC_DataOd AND PC_DataDo
 END
 ELSE
 BEGIN
  INSERT INTO @Pieczatka
  SELECT (SELECT TOP 1 DAB_Wartosc from  [CDN].[DaneBinarne] where Dab_typ = 13 and DAB_TwAID = PC_PCID)
   ,PC_Nazwa1, PC_Nazwa2, PC_Nazwa3
   ,PC_NipKraj, PC_NipE, PC_Regon
   ,PC_Kraj, PC_KrajISO, PC_Wojewodztwo, PC_Powiat, PC_Gmina, PC_KodGminy
   ,PC_Miasto, PC_Ulica, PC_NrDomu, PC_NrLokalu, PC_KodP, PC_Poczta, PC_UlicaNrDomLok
   ,PC_Telefon, PC_Email, PC_URL, ISNULL(PC_Opis,''),
   PC_KRS_Sad, PC_KRS_Numer, PC_KRS_KapitalZak, PC_KRS_KapitalWpl, PC_ILNGLNWlasny, PC_ILNGLNCentrali, PC_PUESC, PC_BDO
   ,ISNULL(PC_Nazwa1,'') + CASE WHEN PC_Nazwa2 <> '' THEN CHAR(13) + PC_Nazwa2 ELSE '' END + CASE WHEN PC_Nazwa3 <> '' THEN CHAR(13) + PC_Nazwa3 ELSE '' END
   + CHAR(13) + CASE WHEN PC_Ulica <> '' THEN PC_Ulica WHEN ISNULL(PC_Ulica,'') = '' AND PC_Miasto <> '' THEN PC_Miasto ELSE ISNULL(PC_Poczta,'') END
   + ' ' + CASE WHEN PC_NrDomu <> '' AND PC_NrLokalu <> '' THEN PC_NrDomu + '/' + PC_NrLokalu WHEN PC_NrDomu <> '' AND ISNULL(PC_NrLokalu,'') = '' THEN PC_NrDomu ELSE ISNULL(PC_NrLokalu,'') END
   + CASE WHEN PC_Ulica <> '' AND PC_Miasto <> PC_Ulica AND PC_Miasto <> PC_Poczta AND PC_Poczta <> '' THEN ', ' + PC_Miasto ELSE '' END
   + CASE WHEN PC_KodP <> '' THEN CHAR(13) + PC_KodP + ' ' ELSE CHAR(13) END + CASE WHEN PC_Poczta <> '' THEN PC_Poczta WHEN ISNULL(PC_Poczta,'')='' AND PC_Miasto <> '' THEN PC_Miasto ELSE '' END
   + CASE WHEN PC_Nipe <> '' THEN CHAR(13) + 'NIP: ' + CASE WHEN PC_NipKraj <> '' THEN  PC_NipKraj + ' ' ELSE '' END + PC_Nipe ELSE '' END
   + CASE WHEN PC_BDO <> '' THEN CHAR(13) + 'Numer rejestrowy: ' + PC_BDO ELSE '' END
   + CASE WHEN PC_Telefon <> '' THEN CHAR(13) + 'tel: ' + PC_Telefon ELSE '' END
   ,CASE WHEN PC_Ulica <> '' THEN PC_Ulica WHEN ISNULL(PC_Ulica,'') = '' AND PC_Miasto <> '' THEN PC_Miasto ELSE ISNULL(PC_Poczta,'') END
   + ' ' + CASE WHEN PC_NrDomu <> '' AND PC_NrLokalu <> '' THEN PC_NrDomu + '/' + PC_NrLokalu WHEN PC_NrDomu <> '' AND ISNULL(PC_NrLokalu,'') = '' THEN PC_NrDomu ELSE ISNULL(PC_NrLokalu,'') END
   + CASE WHEN PC_Ulica <> '' AND PC_Miasto <> PC_Ulica AND PC_Miasto <> PC_Poczta AND PC_Poczta <> '' THEN ', ' + PC_Miasto ELSE '' END
   ,CASE WHEN PC_KodP <> '' THEN PC_KodP + ' ' ELSE '' END + CASE WHEN PC_Poczta <> '' THEN PC_Poczta WHEN ISNULL(PC_Poczta,'')='' AND PC_Miasto <> '' THEN PC_Miasto ELSE '' END
   ,'','','','','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'', '', '', ''
  FROM CDN.Pieczatki
  WHERE @Data BETWEEN PC_DataOd AND PC_DataDo
 END
 RETURN
END
