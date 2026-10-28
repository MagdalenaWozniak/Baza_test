CREATE PROCEDURE CDN.ImportKntWeryfStatHist
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@KWSH_TypWeryfikacji tinyint,
@KWSH_Data nvarchar(10),
@KWSH_Nip nvarchar(20),
@KWSH_Status tinyint,
@DAB_Wartosc nvarchar(max),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 EXEC CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 IF NOT EXISTS (SELECT * FROM cdn.KntWeryfStatHist WHERE KWSH_KntID = @SlowId AND KWSH_TypWeryfikacji = IsNull(@KWSH_TypWeryfikacji, 0) AND KWSH_Nip = @KWSH_Nip AND KWSH_Data = CONVERT(datetime, @KWSH_Data, 120))
 BEGIN
  INSERT INTO CDN.KntWeryfStatHist (
      KWSH_KntID,
   KWSH_TypWeryfikacji,
   KWSH_Data,
   KWSH_Nip,
   KWSH_Status
   )
  VALUES(
   @SlowId,
   IsNull(@KWSH_TypWeryfikacji, 0),
      CONVERT(datetime, @KWSH_Data, 120),
   @KWSH_Nip,
      @KWSH_Status
   )
  DECLARE @KWSHID INT
  SELECT @KWSHID = SCOPE_IDENTITY()
  DECLARE @decoded VARBINARY(max)
  IF @DAB_Wartosc Is NOT Null
  BEGIN
   SET @decoded = cast('' as xml).value('xs:base64Binary(sql:variable(''@DAB_Wartosc''))', 'varbinary(max)')
   INSERT INTO CDN.DaneBinarne
   (
   DAB_MagazynDanych,
   DAB_MagazynDanychId,
   DAB_Typ,
   DAB_Flaga,
   DAB_TwAID,
   DAB_Wartosc,
   DAB_Rozmiar,
   DAB_NazwaPliku,
   DAB_Nazwa,
   DAB_Rozszerzenie,
   DAB_Sciezka,
   DAB_Wersja,
   DAB_IBard24Id,
   DAB_IBard24LinkPrywatny,
   DAB_OpeZalID,
   DAB_OpeZalKod,
   DAB_OpeZalNazwisko,
   DAB_StaZalId,
   DAB_TS_Zal,
   DAB_OpeModID,
   DAB_OpeModKod,
   DAB_OpeModNazwisko,
   DAB_StaModId,
   DAB_TS_Mod
   )
   VALUES
   (
   1,
   NULL,
   11,
   NULL,
   @KWSHID,
   @decoded,
   0,
   '',
   NULL,
   NULL,
   '',
   NULL,
   NULL,
   '',
   @OpeID,
   @OpeModKod,
   @OpeModNazwisko,
   NULL,
   GETDATE(),
   @OpeID,
   @OpeModKod,
   @OpeModNazwisko,
   NULL,
   GETDATE()
   )
  END
 END
 ELSE
  UPDATE CDN.KntWeryfStatHist SET KWSH_Status = @KWSH_Status WHERE KWSH_KntID = @SlowId AND KWSH_TypWeryfikacji = IsNull(@KWSH_TypWeryfikacji, 0) AND KWSH_Nip = @KWSH_Nip AND KWSH_Data = CONVERT(datetime, @KWSH_Data, 120)
END
