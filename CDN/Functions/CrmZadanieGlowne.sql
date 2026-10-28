CREATE FUNCTION cdn.CrmZadanieGlowne(@crkId INT)
RETURNS INT
--  0  - nie jest to zadanie główne (nie  posiada zadan powiązanych)
--  1  - jest to zadanie główne (posiada zadania powiązane)
--  3  - jest to zadanie główne i posiada niezamknięte zadania powiązane
--  4  - jest to zadanie główne i posiada zamknięte zadania powiązane
--  7  - posiada zamknięte i niezamknięte zadania powiązane
--  >8 - posiada zamknięte i niezamknięte zadania powiązane
AS
BEGIN
 DECLARE @wynik INT
 DECLARE @parentId INT
 SET @wynik = 0
 SELECT @parentId = IsNull(CRK_ParId, 0) FROM cdn.CrmKontakty WHERE CRK_CrkId = @crkId
 IF @parentId <> 0
 BEGIN
  SET @wynik = 0  -- nie jest to zadanie główne
  GOTO KONIEC
 END
 IF EXISTS( SELECT * FROM cdn.CrmKontakty
    WHERE (CRK_ParId Is Not NULL AND CRK_ParId = @crkId)
   )
 BEGIN
  SET @wynik = @wynik + 1  -- jest to zadanie główne, bo posiada zadania powiazane
 END
 -- czy zadanie glowne posiada niezamkniete zadania
 IF EXISTS(SELECT * FROM cdn.CrmKontakty
   WHERE (CRK_Bufor = 1 AND CRK_ParId Is Not NULL AND CRK_ParId = @crkId)
   )
 BEGIN
  SET @wynik = @wynik + 2  -- jest to zadanie główne i  posiada niezamknięte zadania powiazane
 END
 -- czy zadanie glowne posiada zamkniete zadania powiazane
 IF EXISTS(SELECT * FROM cdn.CrmKontakty
    WHERE (CRK_Bufor = 0 AND CRK_ParId Is Not NULL AND CRK_ParId = @crkId)
   )
 BEGIN
  SET @wynik = @wynik + 4  -- jest to zadanie główne i posiada zamknięte zadania powiazane
 END
 -- czy zadanie glowne posiada anulowane zadania powiazane
 IF EXISTS(SELECT * FROM cdn.CrmKontakty
    WHERE (CRK_Bufor = -1 AND CRK_ParId Is Not NULL AND CRK_ParId = @crkId)
   )
 BEGIN
  SET @wynik = @wynik + 8  -- jest to zadanie główne i posiada anulowane zadania powiazane
 END
KONIEC:
 RETURN @wynik
END
