CREATE FUNCTION cdn.CrmKontrolaTerminuDlaZadania (
@Id   INT,
@ParentId INT,
@OpiekunTyp INT,
@OpiekunId  INT,
@DataOd  DATETIME,
@DataDo  DATETIME,
@Mode  INT,
@resultType INT = 0,
@parentCyklId INT = 0)
  RETURNS     NVARCHAR(1280)
  AS
  BEGIN
    -- funkcja sprawdza, czy istnieja zadania w zadanym czasie
    DECLARE @Komunikat NVARCHAR(1280), @KomunikatCykl  NVARCHAR(1280)
    DECLARE @Numery    NVARCHAR(1024), @NumeryCykl     NVARCHAR(1024)
    DECLARE @Temat     NVARCHAR(255),  @TematCykl      NVARCHAR(255)
    DECLARE @NewId   INT
    DECLARE @dodajNawiasy   INT
 SET @dodajNawiasy = 0
    SET @Numery = ''
    SET @Temat = ''
    SET @Komunikat = ''
    SET @NumeryCykl = ''
    SET @TematCykl = ''
    SET @KomunikatCykl = ''
    IF @Id IS NULL
        SET @NewId = 0
    ELSE
        SET @NewId = @Id
 IF @Mode = 0  --sprawdzenie dla powiazanych
 BEGIN
     IF EXISTS(  SELECT * FROM cdn.CrmKontakty
                WHERE  CRK_CrkId = @ParentId
     AND CRK_Zadanie = 1
     AND CRK_Bufor <> -1
     AND (CRK_TerminOd < @DataDo AND CRK_TerminDo > @DataOd )
   )
   SET @Komunikat = ''  --zad powiazane w zakresie zadania glownego
  ELSE
  BEGIN
   IF EXISTS(  SELECT * FROM cdn.CrmKontakty  WHERE
     CRK_CrkId = @ParentId
     AND CRK_Zadanie = 1
     AND CRK_Bufor <> -1 )
    SET @Komunikat = 'poza zakresem'
   ELSE
    SET @Komunikat = ''  --zadania glowne JEST kontaktem
  END
  GOTO KONIEC
 END
    IF EXISTS(  SELECT * FROM cdn.CrmKontakty
       JOIN cdn.CrmUczestnicy ON CrU_CrKId = CRK_CRKId
                 WHERE   CRK_CRKID <> @NewId
     AND CRK_CrkId <> @ParentId
     AND CRK_Zadanie = 1
     AND CRK_Bufor = 1
     AND CrK_Cykl = 0
                    AND CrU_PodmiotTyp = @OpiekunTyp
     AND CrU_PodmiotId  = @OpiekunId
     AND (CRK_TerminOd < @DataDo AND CRK_TerminDo > @DataOd )
   )
    BEGIN
  IF @resultType = 1
  BEGIN
   SELECT  @Numery = COALESCE(@Numery + ',' , '' ) + Cast(CRK_CrKId as NVARCHAR(12))
   FROM cdn.CrmKontakty
   JOIN cdn.CrmUczestnicy ON CrU_CrKId = CRK_CRKId
   WHERE CRK_CRKID<>@NewId
      AND CRK_CrkId <> @ParentId
      AND CRK_Zadanie = 1
      AND CRK_Bufor = 1
      AND CrK_Cykl = 0
                    AND CrU_PodmiotTyp = @OpiekunTyp
     AND CrU_PodmiotId = @OpiekunId
     AND (CRK_TerminOd < @DataDo AND CRK_TerminDo > @DataOd )
     ORDER BY CRK_CRKID
--   SET @Komunikat = RTRIM(@Numery)
  END
  ELSE
  BEGIN
   SELECT TOP 1  @Numery = IsNull(CRK_NumerPelny, '')
      ,@Temat  = CASE CONVERT(NVARCHAR(200),CRK_Temat)
          WHEN '' THEN
           CONVERT(NVARCHAR(200),CRK_Opis)
          ELSE
           CONVERT(NVARCHAR(200),CRK_Temat)
         END
   FROM cdn.CrmKontakty
   JOIN cdn.CrmUczestnicy ON CrU_CrKId = CRK_CRKId
     WHERE CRK_CRKID<>@NewId
      AND CRK_CrkId <> @ParentId
      AND CRK_Zadanie = 1
      AND CRK_Bufor = 1
      AND CrK_Cykl = 0
                    AND CrU_PodmiotTyp = @OpiekunTyp
     AND CrU_PodmiotId = @OpiekunId
     AND (CRK_TerminOd < @DataDo AND CRK_TerminDo > @DataOd )
   ORDER BY CRK_CRKID
   SET @dodajNawiasy = 1
   --SET @Komunikat = '( ' + RTRIM(@Numery) + ' )  ' + RTRIM(@Temat)
  END
    END
 -- teraz cykliczne
 DECLARE @parentCrkId INT
 SELECT TOP 1 @parentCrkId = CRC_CRKId FROM cdn.CrmKontaktyCykl WHERE CRC_CRCId = @parentCyklId
    IF EXISTS(  SELECT * FROM cdn.CrmKontakty
       JOIN cdn.CrmUczestnicy ON CrU_CrKId = CRK_CRKId
       JOIN cdn.CrmKontaktyCykl ON CrC_CrKId = CRK_CRKId AND CRC_Aktywny = 1 AND CRC_Bufor = 1
                 WHERE  CRK_CRKID <> @NewId
     AND CRK_CrkId <> @ParentId
     AND CRK_Zadanie = 1
     AND CRK_Bufor = 1
     AND CrK_Cykl = 1
                    AND CrU_PodmiotTyp = @OpiekunTyp
     AND CrU_PodmiotId  = @OpiekunId
     AND (CRC_TerminOd < @DataDo AND CRC_TerminDo > @DataOd )
     AND (@parentCyklId = 0 OR CRK_CrkId <> @parentCrkId)
   )
    BEGIN
  IF @resultType = 1
  BEGIN
   SELECT  @NumeryCykl = COALESCE(@NumeryCykl + ',' , '' ) + Cast(CRK_CrKId as NVARCHAR(12))
    FROM cdn.CrmKontakty
    JOIN cdn.CrmUczestnicy ON CrU_CrKId = CRK_CRKId
       JOIN cdn.CrmKontaktyCykl ON CrC_CrKId = CRK_CRKId AND CRC_Aktywny = 1 AND CRC_Bufor = 1
    WHERE CRK_CRKID<>@NewId
      AND CRK_CrkId <> @ParentId
      AND CRK_Zadanie = 1
      AND CRK_Bufor = 1
      AND CrK_Cykl = 1
                    AND CrU_PodmiotTyp = @OpiekunTyp
     AND CrU_PodmiotId = @OpiekunId
     AND (CRC_TerminOd < @DataDo AND CRC_TerminDo > @DataOd )
     AND (@parentCyklId = 0 OR CRK_CrkId <> @parentCrkId)
    ORDER BY CRK_CRKID
   SET @KomunikatCykl = RTRIM(@NumeryCykl)
  END
  ELSE
  BEGIN
   SELECT TOP 1 @NumeryCykl = IsNull(CRK_NumerPelny, '')
      ,@TematCykl  = CASE CONVERT(NVARCHAR(200),CRK_Temat)
          WHEN '' THEN
           CONVERT(NVARCHAR(200),CRK_Opis)
          ELSE
           CONVERT(NVARCHAR(200),CRK_Temat)
         END
   FROM cdn.CrmKontakty
   JOIN cdn.CrmUczestnicy ON CrU_CrKId = CRK_CRKId
      JOIN cdn.CrmKontaktyCykl ON CrC_CrKId = CRK_CRKId AND CRC_Aktywny = 1 AND CRC_Bufor = 1
     WHERE CRK_CRKID<>@NewId
      AND CRK_CrkId <> @ParentId
      AND CRK_Zadanie = 1
      AND CRK_Bufor = 1
      AND CRK_Cykl  = 1
                    AND CrU_PodmiotTyp = @OpiekunTyp
     AND CrU_PodmiotId = @OpiekunId
     AND (CRC_TerminOd < @DataDo AND CRC_TerminDo > @DataOd )
     AND (@parentCyklId = 0 OR CRK_CrkId <> @parentCrkId)
   ORDER BY CRK_CRKID
   SET @dodajNawiasy = 1
  END
    END
 IF @dodajNawiasy = 1
 BEGIN
  IF @NumeryCykl = ''
   SET @Komunikat = '( ' + RTRIM(@Numery) + ' )  ' + RTRIM(@Temat)
  ELSE
   SET @Komunikat = '( ' + RTRIM(@NumeryCykl)  + ' )  ' + RTRIM(@TematCykl)
 END
 ELSE
 BEGIN
  IF @NumeryCykl = ''
   SET @Komunikat = RTRIM(@Numery)
  ELSE
     IF SUBSTRING(LTRIM(@NumeryCykl),1,1) = ','
    SET @Komunikat = RTRIM(@Numery) + RTRIM(@NumeryCykl)
   ELSE
    SET @Komunikat = RTRIM(@Numery) + ',' + RTRIM(@NumeryCykl)
 END
KONIEC:
    RETURN  @Komunikat
  END
