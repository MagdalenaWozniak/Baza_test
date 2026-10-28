CREATE FUNCTION CDN.TeRStatusString (@ParentTyp INT, @ParentId INT, @TypWyniku INT)
--@TypWyniku = 0  tylko rozchodowe
--           = 1  tylko przychodowe
--           = 2  wszystkie
RETURNS NVARCHAR(30)
AS
BEGIN
 DECLARE @wynik NVARCHAR(30)
 SET @wynik = ''
 IF @TypWyniku = 0 -- tylko rozchodowe
 BEGIN
  SELECT @wynik = COALESCE(@wynik + ' ', '' ) + CDN.TypDokumentu(TeR_ChildTyp)
  FROM cdn.TraElemRelacje
  WHERE
  TeR_ParentTyp=@ParentTyp
  AND TeR_ParentId=@ParentId
  AND (ABS(TeR_ChildTyp) % 2 = 0 OR TeR_ChildTyp = 305) -- PA do rozchodowych
  ORDER BY TeR_TeRId
  GOTO KONIEC
 END
 IF @TypWyniku = 1 -- tylko przychodowe
 BEGIN
  SELECT @wynik = COALESCE(@wynik + ' ', '' ) + CDN.TypDokumentu(TeR_ChildTyp)
  FROM cdn.TraElemRelacje
  WHERE
  TeR_ParentTyp=@ParentTyp
  AND TeR_ParentId=@ParentId
  AND TeR_ChildTyp <> 305
  AND ABS(TeR_ChildTyp) % 2 = 1
  ORDER BY TeR_TeRId
  GOTO KONIEC
 END
 IF @TypWyniku = 2 -- wszystkie
 BEGIN
  SELECT @wynik = COALESCE(@wynik + ' ', '' ) + CDN.TypDokumentu(TeR_ChildTyp)
  FROM cdn.TraElemRelacje
  WHERE
  TeR_ParentTyp=@ParentTyp
  AND TeR_ParentId=@ParentId
  AND TeR_ChildTyp <> 305
  AND ABS(TeR_ChildTyp) % 2 = 1
  ORDER BY TeR_TeRId
  GOTO KONIEC
 END
KONIEC:
    IF @wynik Is NULL
        SET @wynik = ''
 RETURN @wynik
END
