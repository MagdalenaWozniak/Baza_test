CREATE FUNCTION CDN.TrNOpisPlusNumeryKKW(@TrNID INT, @mode TINYINT)
RETURNS NVARCHAR(1024)
AS
BEGIN
 DECLARE @retVal NVARCHAR(1024)
  SELECT @retVal = ''
 DECLARE @numer VARCHAR(50)
 DECLARE c CURSOR LOCAL FAST_FORWARD FOR
 SELECT
  CASE WHEN IsNull(TrN_NumerObcy, '') <> '' THEN TrN_NumerObcy ELSE TrN_NumerPelny END
 FROM CDN.TraNag
 WHERE TrN_ZwrID = @TrNID AND TrN_Korekta = 8 AND TrN_Bufor = 0
 OPEN c
 WHILE 1 = 1
 BEGIN
  FETCH NEXT FROM c INTO @numer
  IF @@FETCH_STATUS <> 0 BREAK
  SELECT @retVal = (CASE WHEN @retVal = '' THEN @numer ELSE @retVal + ', ' + @numer END)
 END
 CLOSE c
 DEALLOCATE c
  DECLARE @OpisGlowny NVARCHAR(1024)
 IF @mode = 0
  SELECT @OpisGlowny = IsNull(TrN_Kategoria, '') FROM cdn.TraNag WHERE TrN_TrNID = @TrNID
 ELSE
  SELECT @OpisGlowny =
  case A.TrN_TypDokumentu when 305 then (case IsNull(NULL, '') when IsNull(NULL, '') then '' else 'Faktura ' + (SELECT TrN_NumerPelny FROM CDN.TraNag WHERE TrN_TrNId = (SELECT TrN_FaId FROM CDN.TraNag WHERE TrN_TrNId = @TrNID)) + ' ' + '' end) else TrN_Kategoria end
  FROM cdn.TraNag A WHERE A.TrN_TrNID = @TrNID
  IF IsNull(@OpisGlowny, '') <> ''
  BEGIN
    IF IsNull(@retVal, '') <> ''
      SET @retVal = @retVal + ', ' + @OpisGlowny
    ELSE
      SET @retVal = @OpisGlowny
  END
 RETURN @retVal
END
