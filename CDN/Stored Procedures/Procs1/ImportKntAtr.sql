CREATE  PROCEDURE CDN.ImportKntAtr
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@KnA_Kod nvarchar(20),
@KnA_ImportRowId nvarchar(36),
@Wartosc nvarchar(1024),
@KnA_CzyKopiowac tinyint,
@KnA_CzyKod tinyint,
@KnA_CzyPrzenosic tinyint,
@KnA_CzyDrukowac tinyint,
@KnA_CzyKopiowacDoVAT tinyint,
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
SET NOCOUNT ON
BEGIN
 DECLARE @DeAId int,
   @err nvarchar(50)
 IF @KnA_ImportRowId is NULL OR @KnA_ImportRowId = ''
  SELECT @DeAId = DeA_DeAId
  FROM CDN.DefAtrybuty
  WHERE DeA_Kod = @KnA_Kod
 ELSE
  SELECT @DeAId = DEA_DeAId
  FROM CDN.DefAtrybuty
  WHERE DeA_ImportRowId = @KnA_ImportRowId
 IF(@DeAId is NULL)
  --SET @Warnings = 'Brak atrybutu ' + @KnA_Kod +' w bazie.\'
  SET @Warnings = '##OPT33201##%%kod%%=' + @KnA_Kod + '##\'
 ELSE
 BEGIN
  INSERT INTO CDN.KntAtrybuty
  (
  KnA_DeAId,
  KnA_WartoscTxt,
  KnA_PodmiotTyp,
  KnA_PodmiotId,
  KnA_CzyKopiowac,
  KnA_CzyKod,
  KnA_CzyPrzenosic,
  KnA_CzyDrukowac,
  KnA_CzyKopiowacDoVAT
  )
  VALUES
  (
  @DeAId,
  @Wartosc,
  1,
  @SlowId,
  @KnA_CzyKopiowac,
  @KnA_CzyKod,
  @KnA_CzyPrzenosic,
  @KnA_CzyDrukowac,
  @KnA_CzyKopiowacDoVAT
  )
 END
END
