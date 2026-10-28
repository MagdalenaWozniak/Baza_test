CREATE FUNCTION cdn.CrmRealizacjaZadanPow(@parentId INT)
RETURNS INT
AS
BEGIN
   DECLARE @Zrealizowano  INT
   DECLARE @CzasZadania  INT
   DECLARE @ProcentWykonania FLOAT
    DECLARE @Wykonano   DECIMAL(5,2)
   DECLARE @Udzial    FLOAT
    DECLARE @CzasAll   INT
 SET @ProcentWykonania = 0.00
 SELECT @CzasAll = Sum( DATEDIFF(mi, CRK_TerminOd, CRK_TerminDo) )
  FROM cdn.CrmKontakty
  WHERE CRK_Zadanie = 1 AND CRK_Bufor <> -1 AND (CRK_ParId Is Not NULL AND CRK_ParId = @parentId)
 IF @CzasAll = 0
 BEGIN
  SET @ProcentWykonania = 0.00
  GOTO KONIEC
 END
 DECLARE wszystkiePow CURSOR LOCAL FAST_FORWARD FOR
  SELECT DATEDIFF(mi, CRK_TerminOd, CRK_TerminDo) As CzasTrwania,
    CRK_Wykonano As Wykonano
  FROM cdn.CrmKontakty
  WHERE CRK_Zadanie = 1 AND CRK_Bufor <> -1 AND (CRK_ParId Is Not NULL AND CRK_ParId = @parentId)
 OPEN wszystkiePow
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM wszystkiePow INTO @CzasZadania, @Wykonano
  IF @@FETCH_STATUS <> 0 BREAK
  SET @Udzial = Cast(@CzasZadania As FLOAT) / CAST(@CzasAll As FLOAT)
  SET @ProcentWykonania = @ProcentWykonania + CAST(@Udzial * CAST(@Wykonano AS FLOAT) AS FLOAT)
 END
 CLOSE wszystkiePow
 DEALLOCATE wszystkiePow
 KONIEC:
  SET @Zrealizowano = CAST(ROUND(@ProcentWykonania, 0) AS INT)
  IF @Zrealizowano > 100
 SET @Zrealizowano = 100
  RETURN @Zrealizowano
END
