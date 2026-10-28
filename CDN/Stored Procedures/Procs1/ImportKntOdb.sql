CREATE PROCEDURE CDN.ImportKntOdb
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Knt_ImportRowId nvarchar(26),
@Knt_Kod nvarchar(20),
@Odb_Domyslny tinyint,
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @OdbId int
 SELECT @OdbId = Knt_KntId
 FROM CDN.Kontrahenci
 WHERE Knt_ImportRowId = @Knt_ImportRowId
 IF @OdbId is NULL
  SELECT @OdbId = Knt_KntId
  FROM CDN.Kontrahenci
  WHERE Knt_Kod = @Knt_Kod
 IF @OdbId is NULL
  --SET @Warnings = 'Brak odbiorcy ' + @Knt_Kod + ' w bazie docelowej. Odbiorca nie został zaimportowany\'
  SET @Warnings = '##OPT33203##%%kod%%=' + @Knt_Kod + '##\'
 ELSE
 BEGIN
  INSERT INTO CDN.KntOdbiorcy
  (
  Odb_KntOdbID,
  Odb_OdbKntID,
  Odb_Domyslny
  )
  VALUES
  (
  @SlowId,
  @OdbId,
  @Odb_Domyslny
  )
 END
END
