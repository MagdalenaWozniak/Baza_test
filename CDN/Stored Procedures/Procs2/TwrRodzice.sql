CREATE PROCEDURE Cdn.TwrRodzice
@GIDNumer       int
AS
BEGIN
DECLARE @n INT
DECLARE @prevcount INT
DECLARE @count INT
SET     @count=-1
SET     @prevcount=0
CREATE TABLE #tmpnumery(GN INT,C INT)
INSERT INTO     #tmpnumery VALUES(@GIDNumer,1)
WHILE (@prevcount!=@count) --przechodzenie grafu wszerz, jezeli nic     nie     dodano konczymy
BEGIN
  INSERT INTO #tmpnumery SELECT DISTINCT Twg_GRONumer,0 FROM CDN.TwrGrupy WHERE Twg_GIDNumer IN(SELECT GN FROM #tmpnumery) AND TWG_GIDTyp=-16 AND TWG_GRONumer NOT IN (SELECT GN FROM #tmpnumery)
  SET @prevcount=@count
  SET @count=(SELECT COUNT(*) FROM #tmpnumery)
END
SET     @prevcount=0
SET     @count=-1
WHILE (@prevcount!=@count)
BEGIN
DECLARE c CURSOR FOR SELECT     GN FROM #tmpnumery
OPEN c
FETCH NEXT FROM c INTO @n
FETCH NEXT FROM c INTO @n --pomijamy pierwszy rekord - dla niego C=1
IF (@count=-1)
        SET     @count=0
WHILE @@FETCH_STATUS = 0
BEGIN
  UPDATE #tmpnumery     --podliczanie ilosci mozliwych sciezek jako     sumy ilosci     na elementach prowadzacych do elementu
  SET C=(SELECT SUM(C) FROM     #tmpnumery WHERE GN     IN (SELECT TWG_GIDNumer FROM CDN.TwrGrupy WHERE TWG_GRONumer=@n AND     TWG_GIDTyp=-16))
  WHERE GN=@n
  SET @prevcount=@count
  SET @count=(SELECT SUM(C)     FROM #tmpnumery)
  FETCH NEXT FROM c     INTO @n
END
CLOSE c
DEALLOCATE c
END
SELECT * FROM #tmpnumery
END
