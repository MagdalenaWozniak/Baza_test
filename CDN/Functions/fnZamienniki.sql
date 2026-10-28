CREATE FUNCTION CDN.fnZamienniki (@TwrId INT) RETURNS @Zamienniki TABLE (ZamID INT, TwrZamID INT, Poziom INT, Sciezka NVARCHAR(MAX), SciezkaLp NVARCHAR(2048), PRIMARY KEY(TwrZamID,ZamID))
AS
BEGIN
 DECLARE @Poziom INT  SET @Poziom = 0
 INSERT INTO @Zamienniki (ZamID, TwrZamID,  Poziom,  Sciezka, SciezkaLp)
 SELECT                   -1, Twr_TwrID, @Poziom, '', ''
 FROM CDN.Towary WHERE Twr_TwrID = @TwrId
  WHILE 1=1
   BEGIN
    INSERT INTO @Zamienniki (
      ZamID, TwrZamID,       Poziom,      Sciezka,  SciezkaLp)
    SELECT
      B.Zam_ZamID, B.Zam_ZamTwrID, @Poziom + 1, MAX( CAST(A.Sciezka + '\' + C.Twr_Kod As NVARCHAR(MAX))), MAX( CAST(A.SciezkaLp + '\' + case when len(cast(10 as NVARCHAR(10)))<8 then left('00000000', 8-len(cast(B.Zam_Lp as NVARCHAR(10))))+cast(B.Zam_Lp as NVARCHAR(10)) end As NVARCHAR(2048)))
    FROM @Zamienniki A
    JOIN CDN.Zamienniki B ON  B.Zam_TwrID = A.TwrZamID AND A.Poziom = @Poziom
    JOIN CDN.Towary C     ON B.Zam_ZamTwrID = C.Twr_TwrID
    WHERE NOT EXISTS (SELECT * FROM @Zamienniki D WHERE B.Zam_ZamTwrID = D.TwrZamID)
    GROUP BY B.Zam_ZamTwrID, B.Zam_ZamID
    IF @@ROWCOUNT = 0 BREAK
    SET @Poziom = @Poziom + 1
   END
 DELETE @Zamienniki WHERE Poziom = 0
 RETURN
END
