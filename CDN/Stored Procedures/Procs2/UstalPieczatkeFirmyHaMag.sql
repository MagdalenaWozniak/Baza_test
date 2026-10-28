create  PROCEDURE [CDN].[UstalPieczatkeFirmyHaMag]
@DataWysS                   nvarchar(20)
,@DataBiezs                 nvarchar(20)
AS
BEGIN
  SET NOCOUNT ON
  DECLARE
  @PieczIdBiez INT,
  @PieczIdHist INT,
  @PieczIdJSBiez INT,
  @PieczIdJSHist INT,
  @PieczIdHistNazwa nvarchar(50),
  @PieczIdHistNipKraj varchar(2),
  @PieczIdHistNIP nvarchar(20),
  @PieczIdHistKodP varchar(50),
  @PieczIdHistUlicaNrDomLok   nvarchar(60),
  @PieczIdBiezNazwa nvarchar(50),
  @PieczIdBiezNipKraj varchar(2),
  @PieczIdBiezNIP nvarchar(20),
  @PieczIdBiezKodP varchar(50),
  @PieczIdBiezUlicaNrDomLok   nvarchar(60),
  @PieczIdJSHistNazwa nvarchar(50),
  @PieczIdJSHistNipKraj varchar(2),
  @PieczIdJSHistNIP nvarchar(20),
  @PieczIdJSHistKodP varchar(50),
  @PieczIdJSHistUlicaNrDomLok   nvarchar(60),
  @PieczIdJSBiezNazwa nvarchar(50),
  @PieczIdJSBiezNipKraj varchar(2),
  @PieczIdJSBiezNIP nvarchar(20),
  @PieczIdJSBiezKodP varchar(50),
  @PieczIdJSBiezUlicaNrDomLok   nvarchar(60),
  @DataWys                   DateTime,
  @DataBiez                  DateTime
  select
   @PieczIdBiez = 0,
   @PieczIdHist = 0,
   @PieczIdJSBiez = 0,
   @PieczIdJSHist = 0,
   @DataWys = CONVERT(DATETIME,@DataWysS,120),
   @DataBiez = CONVERT(DATETIME,@DataBiezS,120)
  SELECT @PieczIdHist = PC_PCID,
         @PieczIdHistNazwa = PC_Nazwa1,
         @PieczIdHistNipKraj = PC_NipKraj,
         @PieczIdHistNIP = PC_NipE,
         @PieczIdHistKodP = CASE WHEN PC_KodP <> '' THEN PC_KodP + ' ' ELSE '' END + CASE WHEN PC_Poczta <> '' THEN PC_Poczta WHEN ISNULL(PC_Poczta,'')='' AND PC_Miasto <> '' THEN PC_Miasto ELSE '' END,
         @PieczIdHistUlicaNrDomLok = CASE WHEN PC_Ulica <> '' THEN PC_Ulica WHEN ISNULL(PC_Ulica,'') = '' AND PC_Miasto <> '' THEN PC_Miasto ELSE ISNULL(PC_Poczta,'') END
         + ' ' + CASE WHEN PC_NrDomu <> '' AND PC_NrLokalu <> '' THEN PC_NrDomu + '/' + PC_NrLokalu WHEN PC_NrDomu <> '' AND ISNULL(PC_NrLokalu,'') = '' THEN PC_NrDomu ELSE ISNULL(PC_NrLokalu,'') END
         + CASE WHEN PC_Ulica <> '' AND PC_Miasto <> PC_Ulica AND PC_Miasto <> PC_Poczta AND PC_Poczta <> '' THEN ', ' + PC_Miasto ELSE '' END
  FROM CDN.Pieczatki WHERE  @DataWys BETWEEN PC_DataOd AND PC_DataDo
  SELECT @PieczIdBiez = PC_PCID,
         @PieczIdBiezNazwa = PC_Nazwa1,
         @PieczIdBiezNipKraj = PC_NipKraj,
         @PieczIdBiezNIP = PC_NipE,
         @PieczIdBiezKodP = CASE WHEN PC_KodP <> '' THEN PC_KodP + ' ' ELSE '' END + CASE WHEN PC_Poczta <> '' THEN PC_Poczta WHEN ISNULL(PC_Poczta,'')='' AND PC_Miasto <> '' THEN PC_Miasto ELSE '' END,
         @PieczIdBiezUlicaNrDomLok = CASE WHEN PC_Ulica <> '' THEN PC_Ulica WHEN ISNULL(PC_Ulica,'') = '' AND PC_Miasto <> '' THEN PC_Miasto ELSE ISNULL(PC_Poczta,'') END
         + ' ' + CASE WHEN PC_NrDomu <> '' AND PC_NrLokalu <> '' THEN PC_NrDomu + '/' + PC_NrLokalu WHEN PC_NrDomu <> '' AND ISNULL(PC_NrLokalu,'') = '' THEN PC_NrDomu ELSE ISNULL(PC_NrLokalu,'') END
         + CASE WHEN PC_Ulica <> '' AND PC_Miasto <> PC_Ulica AND PC_Miasto <> PC_Poczta AND PC_Poczta <> '' THEN ', ' + PC_Miasto ELSE '' END
  FROM CDN.Pieczatki WHERE  @DataBiez BETWEEN PC_DataOd AND PC_DataDo
  SELECT @PieczIdJSHist = PCJS_PCJSID,
         @PieczIdJSHistNazwa = PCJS_Nazwa1,
         @PieczIdJSHistNipKraj = PCJS_NipKraj,
         @PieczIdJSHistNIP = PCJS_NipE,
         @PieczIdJSHistKodP = CASE WHEN PCJS_KodP <> '' THEN PCJS_KodP + ' ' ELSE '' END + CASE WHEN PCJS_Poczta <> '' THEN PCJS_Poczta WHEN ISNULL(PCJS_Poczta,'')='' AND PCJS_Miasto <> '' THEN PCJS_Miasto ELSE '' END ,
         @PieczIdJSHistUlicaNrDomLok = CASE WHEN PCJS_Ulica <> '' THEN PCJS_Ulica WHEN ISNULL(PCJS_Ulica,'') = '' AND PCJS_Miasto <> '' THEN PCJS_Miasto ELSE ISNULL(PCJS_Poczta,'') END
         + ' ' + CASE WHEN PCJS_NrDomu <> '' AND PCJS_NrLokalu <> '' THEN PCJS_NrDomu + '/' + PCJS_NrLokalu WHEN PCJS_NrDomu <> '' AND ISNULL(PCJS_NrLokalu,'') = '' THEN PCJS_NrDomu ELSE ISNULL(PCJS_NrLokalu,'') END
         + CASE WHEN PCJS_Ulica <> '' AND PCJS_Miasto <> PCJS_Ulica AND PCJS_Miasto <> PCJS_Poczta AND PCJS_Poczta <> '' THEN ', ' + PCJS_Miasto ELSE '' END
   FROM CDN.PieczatkiJS WHERE  @DataWys BETWEEN PCJS_DataOd AND PCJS_DataDo
   SELECT @PieczIdJSBiez = PCJS_PCJSID,
          @PieczIdJSBiezNazwa = PCJS_Nazwa1,
          @PieczIdJSBiezNipKraj = PCJS_NipKraj,
          @PieczIdJSBiezNIP = PCJS_NipE,
          @PieczIdJSBiezKodP = CASE WHEN PCJS_KodP <> '' THEN PCJS_KodP + ' ' ELSE '' END + CASE WHEN PCJS_Poczta <> '' THEN PCJS_Poczta WHEN ISNULL(PCJS_Poczta,'')='' AND PCJS_Miasto <> '' THEN PCJS_Miasto ELSE '' END  ,
          @PieczIdJSBiezUlicaNrDomLok = CASE WHEN PCJS_Ulica <> '' THEN PCJS_Ulica WHEN ISNULL(PCJS_Ulica,'') = '' AND PCJS_Miasto <> '' THEN PCJS_Miasto ELSE ISNULL(PCJS_Poczta,'') END
          + ' ' + CASE WHEN PCJS_NrDomu <> '' AND PCJS_NrLokalu <> '' THEN PCJS_NrDomu + '/' + PCJS_NrLokalu WHEN PCJS_NrDomu <> '' AND ISNULL(PCJS_NrLokalu,'') = '' THEN PCJS_NrDomu ELSE ISNULL(PCJS_NrLokalu,'') END
          + CASE WHEN PCJS_Ulica <> '' AND PCJS_Miasto <> PCJS_Ulica AND PCJS_Miasto <> PCJS_Poczta AND PCJS_Poczta <> '' THEN ', ' + PCJS_Miasto ELSE '' END
   FROM CDN.PieczatkiJS WHERE  @DataBiez BETWEEN PCJS_DataOd AND PCJS_DataDo
select
  @PieczIdBiez as PieczIdBiez,
  @PieczIdHist as PieczIdHist,
  @PieczIdJSBiez as PieczIdJSBiez,
  @PieczIdJSHist as PieczIdJSHist,
  @PieczIdHistNazwa as PieczIdHistNazwa,
  @PieczIdHistNipKraj as PieczIdHistNipKraj,
  @PieczIdHistNIP as PieczIdHistNIP,
  @PieczIdHistKodP as PieczIdHistKodP,
  @PieczIdHistUlicaNrDomLok as PieczIdHistUlicaNrDomLok,
  @PieczIdBiezNazwa as PieczIdBiezNazwa,
  @PieczIdBiezNipKraj as PieczIdBiezNipKraj,
  @PieczIdBiezNIP as PieczIdBiezNIP,
  @PieczIdBiezKodP as PieczIdBiezKodP,
  @PieczIdBiezUlicaNrDomLok as PieczIdBiezUlicaNrDomLok,
  @PieczIdJSHistNazwa as PieczIdJSHistNazwa,
  @PieczIdJSHistNipKraj as PieczIdJSHistNipKraj,
  @PieczIdJSHistNIP as PieczIdJSHistNIP,
  @PieczIdJSHistKodP as PieczIdJSHistKodP,
  @PieczIdJSHistUlicaNrDomLok as PieczIdJSHistUlicaNrDomLok,
  @PieczIdJSBiezNazwa as PieczIdJSBiezNazwa,
  @PieczIdJSBiezNipKraj as PieczIdJSBiezNipKraj,
  @PieczIdJSBiezNIP as PieczIdJSBiezNIP,
  @PieczIdJSBiezKodP as PieczIdJSBiezKodP,
  @PieczIdJSBiezUlicaNrDomLok as PieczIdJSBiezUlicaNrDomLok
  SET NOCOUNT OFF
END
