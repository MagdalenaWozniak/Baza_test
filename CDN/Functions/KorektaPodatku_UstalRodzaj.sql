CREATE FUNCTION CDN.KorektaPodatku_UstalRodzaj(@DokumentTyp INTEGER, @DokumentSubTyp INTEGER, @KorektaPowrotna INTEGER)
RETURNS INTEGER
AS
BEGIN
 DECLARE @Rodzaj INTEGER
  SET @Rodzaj = 0;
 IF @DokumentTyp = 1
 BEGIN
  IF @DokumentSubTyp IN (301, 313)
   SET @Rodzaj = 1;
  IF @DokumentSubTyp IN (302, 305, 314, 345)
   SET @Rodzaj = 2;
 END
 ELSE IF @DokumentTyp = 2
 BEGIN
  IF @DokumentSubTyp = 1
   SET @Rodzaj = 1;
  IF @DokumentSubTyp = 2
   SET @Rodzaj = 2;
 END
 ELSE IF @DokumentTyp = 12
 BEGIN
  IF @DokumentSubTyp = 102
   SET @Rodzaj = 1;
  IF @DokumentSubTyp = 101
   SET @Rodzaj = 2;
 END
 IF @KorektaPowrotna = 1
  SET @Rodzaj = @Rodzaj + 2;
 RETURN @Rodzaj
END
