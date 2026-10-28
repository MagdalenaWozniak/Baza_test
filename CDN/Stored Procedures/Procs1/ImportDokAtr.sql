CREATE PROCEDURE CDN.ImportDokAtr
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@DeA_Kod nvarchar(20),
@DeA_ImportRowId nvarchar(36),
@Wartosc nvarchar(1024),
@TypJPK TINYINT,
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
SET NOCOUNT ON
BEGIN
 DECLARE @DeAId int,
  @format int,
  @err nvarchar(50),
  @typDef int,
  @typJPKDef int
 SELECT @DeAId = DEA_DeAId, @format = DeA_Format, @typDef=DeA_Typ, @typJPKDef = CASE WHEN DeA_JPKDostepnyFAVAT <> 0 THEN 2 ELSE 1 END
 FROM CDN.DefAtrybuty
 WHERE DeA_ImportRowId = @DeA_ImportRowId
 IF(@DeAId is NULL)
 BEGIN
  SELECT @DeAId = DeA_DeAId, @format = DeA_Format, @typDef=DeA_Typ, @typJPKDef = CASE WHEN DeA_JPKDostepnyFAVAT <> 0 THEN 2 ELSE 1 END
  FROM CDN.DefAtrybuty
  WHERE DeA_Kod = @DeA_Kod
 END
 IF(@DeAId is NULL)
  --SET @Warnings = 'Brak atrybutu ' + @DeA_Kod +' w bazie.\'
  SET @Warnings = '##OPT33201##%%kod%%=' + @DeA_Kod + '##\'
 ELSE
 BEGIN
  IF @format = 4 and @Wartosc = ''
  BEGIN
   --SET @Warnings = 'Atrybut ' + @DeA_Kod +' nie został zaimportowany. Brak uzupełnionej daty.\'
   SET @Warnings = '##OPT33202##%%kod%%=' + @DeA_Kod + '##\'
    RETURN
  END
  IF @format = 4 SET @Wartosc = convert(int, convert(datetime, @Wartosc, 120) + 36163)
  if @typDef = 5 and @TypJPK is null
  begin
   SET @TypJPK = @typJPKDef
  end
  INSERT INTO CDN.DokAtrybuty
  (
  DAt_Kod,
  DAt_DeAId,
  DAt_WartoscTxt,
  DAt_TypJPK,
  DAt_TrNId,
  DAt_CRKId,
  DAt_SrZId,
  DAt_VaNID
  )
  VALUES
  (
  @DeA_Kod,
  @DeAId,
  @Wartosc,
  @TypJPK,
  NULL,
  NULL,
  NULL,
  @SlowId
  )
 END
END
