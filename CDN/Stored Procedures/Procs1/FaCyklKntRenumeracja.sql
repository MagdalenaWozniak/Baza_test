CREATE PROCEDURE cdn.FaCyklKntRenumeracja
AS
BEGIN
 SET NOCOUNT ON
 ;WITH cte AS(
 SELECT *, ROW_NUMBER() OVER (PARTITION BY FcK_FcNId, FcK_TypKnt ORDER BY FcK_FcNId, FcK_TypKnt) AS KntLp
 FROM cdn.FaCyklKnt)
 UPDATE FaCyklOrg SET FaCyklOrg.FcK_LpDlaTypKnt = t2.KntLp
 FROM cdn.FaCyklKnt  As FaCyklOrg INNER JOIN cte AS t2 ON FaCyklOrg.FcK_FcKId = t2.FcK_FcKId
 ALTER TABLE cdn.FaCyklKnt ALTER COLUMN FCK_LpDlaTypKnt INT NOT NULL
 UPDATE CDN.FaCyklTwrKnt SET FCT_KntLp = FcK_LpDlaTypKnt FROM cdn.FaCyklTwrKnt JOIN cdn.FaCyklKnt ON FcK_FCKID=FcT_FcKId
END
