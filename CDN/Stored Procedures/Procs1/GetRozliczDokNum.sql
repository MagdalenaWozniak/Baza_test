CREATE PROCEDURE CDN.GetRozliczDokNum
@DocId int,
@DocType int
AS
BEGIN
 DECLARE @NumerObcy nvarchar(256),
  @NumerPelny nvarchar(30),
  @Opis nvarchar(30),
  @ImportRowId nvarchar(36)
 SET @NumerObcy = NULL
 SET @NumerPelny = NULL
 SET @Opis = NULL
 SET @ImportRowId = NULL
 IF(@DocType = 1)
 BEGIN
  SELECT @NumerObcy = BZd_NumerObcy,
   @NumerPelny = BZd_NumerPelny,
   @Opis = BZd_Opis,
   @ImportRowId = BZd_ImportRowId
  FROM CDN.BnkZdarzenia
  WHERE BZd_BZdID = @DocId
 END
 ELSE
 IF(@DocType = 2)
 BEGIN
  SELECT @NumerObcy = BZp_NumerObcy,
   @NumerPelny = BZp_NumerPelny,
   @Opis = BZp_Opis,
   @ImportRowId = BZp_ImportRowId
  FROM CDN.BnkZapisy
  WHERE BZp_BZpID = @DocId
 END
 ELSE
 BEGIN
 SELECT 'błąd numeracji' as DocNum, 'nieznany typ dokumentu' as ImportRowId
 RETURN
 END
 IF(@NumerPelny is NULL )
 BEGIN
  SELECT 'błąd numeracji' as DocNum, 'nieznany typ dokumentu' as ImportRowId
  RETURN
 END
 IF(@NumerObcy <> '')
 BEGIN
  SELECT @NumerObcy as DocNum, @ImportRowId as ImportRowId
  RETURN
 END
 ELSE
 BEGIN
  IF(@NumerPelny <> '')
  BEGIN
   SELECT @NumerPelny as DocNum, @ImportRowId as ImportRowId
   RETURN
  END
  ELSE SELECT @Opis as DocNum, IsNull(@ImportRowId, '')  as ImportRowId
 END
END
