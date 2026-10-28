CREATE PROCEDURE [CDN].[ESLKEP_ImportPdfRegulamin]
  @Nazwa           nvarchar(200),
  @JezykIDChr      nvarchar(11),
  @PDFxml          xml,
  @NazwaPDF        nvarchar(200),
  @Tresc           nvarchar(max),
  @OpeZalIDChr     nvarchar(11),
  @StaZalIdChr     nvarchar(11),
  @IDEsklepChr     nvarchar(11),
  @VerIDChr        nvarchar(50),
  @IDChr           nvarchar(50)
AS
  SET NOCOUNT ON
  DECLARE
  @ESSID                 INT,
  @VerID                 UNIQUEIDENTIFIER,
  @ID                    UNIQUEIDENTIFIER,
  @OpeZalID              INT,
  @StaZalId              INT,
  @DABID                 INT,
  @Akronim               NVARCHAR(50),
  @ImieNazwisko          NVARCHAR(200),
  @IDEsklep              INT,
  @JezykId               INT,
  @PDF                   varbinary(max),
  @Deftext               varbinary(max)
  CREATE TABLE #BinaryData (DabData VARbinary(max))
  INSERT INTO #BinaryData (DabData)
  SELECT
  DAB.Attribute.value('@Pdf', 'VARbinary(MAX)')
  FROM @PDFxml.nodes('/aa/a') AS DAB(Attribute) OPTION (KEEP PLAN, MAXDOP 1, OPTIMIZE FOR(@PDFxml=NULL));
  SELECT top 1 @PDF = cast(dabdata as varbinary(max)) from #binarydata
  SELECT
    @IDEsklep          = CONVERT(INT,@IDEsklepChr),
    @OpeZalID          = CONVERT(INT,@OpeZalIDChr),
    @StaZalId          = CONVERT(INT,@StaZalIdChr),
  @VerID             = CONVERT(UNIQUEIDENTIFIER,@VerIDChr),
 @ID                = CONVERT(UNIQUEIDENTIFIER,@IDChr),
    @JezykId           = CONVERT(INT,@JezykIdChr)
 --@PDF               = CONVERT(IMAGE,@PDFChr)
  declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
  exec CDN.OpeKodNazwisko @OpeZalID, @OpeZalKod OUT, @OpeZalNazwisko OUT
  SELECT @ESSID = ESS_ESSID from cdn.eSklepStanowiska where ESS_IdISklep = @IDEsklep
  SELECT @Deftext = cdn.TextToUTF8Binary(@Tresc, 1)
  if not exists (select * FROM Cdn.DaneBinarne WHERE DAB_eSklepZalID =  @ID AND DAB_eSklepZalVerID =  @VerID AND DAB_eSklepJezykID = @JezykID AND DAB_eSklepID = @ESSID) and LEN(@PDF) > 0
  BEGIN
    INSERT INTO CDN.DaneBinarne
      (DAB_TwAID,DAB_Wartosc,DAB_Rozmiar,DAB_NazwaPliku,DAB_Nazwa,DAB_OpeZalID,DAB_StaZalId,DAB_TS_Zal,
      DAB_OpeModID,DAB_StaModId,DAB_TS_Mod,DAB_MagazynDanych,DAB_Sciezka,DAB_OpeModKod,DAB_OpeModNazwisko,
      DAB_OpeZalKod,DAB_OpeZalNazwisko,DAB_IBard24LinkPrywatny,DAB_eSklepZalVerID,DAB_eSklepJezykID,DAB_eSklepID,DAB_eSklepZalID)
    VALUES
  (0,@PDF,0,@NazwaPDF,@Nazwa,@OpeZalID,@StaZalId,GETDATE(),@OpeZalID,@StaZalId,GETDATE(),1,'',@OpeZalKod,@OpeZalNazwisko,@OpeZalKod,@OpeZalNazwisko,''
  ,@VerID,@JezykID,@ESSID,@ID)
    IF LEN(@Tresc) > 0
    INSERT INTO CDN.DaneBinarne
      (DAB_TwAID,DAB_Wartosc,DAB_Rozmiar,DAB_NazwaPliku,DAB_Nazwa,DAB_OpeZalID,DAB_StaZalId,DAB_TS_Zal,
      DAB_OpeModID,DAB_StaModId,DAB_TS_Mod,DAB_MagazynDanych,DAB_Sciezka,DAB_OpeModKod,DAB_OpeModNazwisko,
      DAB_OpeZalKod,DAB_OpeZalNazwisko,DAB_IBard24LinkPrywatny,DAB_eSklepZalVerID,DAB_eSklepJezykID,DAB_eSklepID,DAB_eSklepZalID)
    VALUES
  (0,@Deftext,0,REPLACE(LTRIM(RTRIM(@Nazwa)),' ','_') + '.txt',@Nazwa,@OpeZalID,@StaZalId,GETDATE(),@OpeZalID,@StaZalId,GETDATE(),1,'',@OpeZalKod,@OpeZalNazwisko,@OpeZalKod,@OpeZalNazwisko,''
  ,@VerID,@JezykID,@ESSID,@ID)
  END
  ELSE
  if not exists (select * FROM Cdn.DaneBinarne WHERE DAB_eSklepZalID =  @ID AND DAB_eSklepZalVerID =  @VerID AND DAB_eSklepJezykID = @JezykID AND DAB_eSklepID = @ESSID) and LEN(@PDF) = 0
  BEGIN
    IF LEN(@Tresc) > 0
    INSERT INTO CDN.DaneBinarne
      (DAB_TwAID,DAB_Wartosc,DAB_Rozmiar,DAB_NazwaPliku,DAB_Nazwa,DAB_OpeZalID,DAB_StaZalId,DAB_TS_Zal,
      DAB_OpeModID,DAB_StaModId,DAB_TS_Mod,DAB_MagazynDanych,DAB_Sciezka,DAB_OpeModKod,DAB_OpeModNazwisko,
      DAB_OpeZalKod,DAB_OpeZalNazwisko,DAB_IBard24LinkPrywatny,DAB_eSklepZalVerID,DAB_eSklepJezykID,DAB_eSklepID,DAB_eSklepZalID)
    VALUES
  (0,@Deftext,0,REPLACE(LTRIM(RTRIM(@Nazwa)),' ','_') + '.txt',@Nazwa,@OpeZalID,@StaZalId,GETDATE(),@OpeZalID,@StaZalId,GETDATE(),1,'',@OpeZalKod,@OpeZalNazwisko,@OpeZalKod,@OpeZalNazwisko,''
  ,@VerID,@JezykID,@ESSID,@ID)
  END
SET NOCOUNT OFF
