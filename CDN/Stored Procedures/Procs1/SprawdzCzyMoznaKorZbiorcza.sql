CREATE PROCEDURE CDN.SprawdzCzyMoznaKorZbiorcza
  @PodID                  INT,
  @PodTyp                 INT,
  @MagID                  INT,
  @TrN_DataOdChar         NVARCHAR(25),
  @TrN_DataDoChar         NVARCHAR(25),
  @KorektyPrzed     INT,
  @KorektyPo     INT,
  @WalSys                 VARCHAR(3)
AS
SET NOCOUNT ON
DECLARE
  @TrN_DataOd         NVARCHAR(25),
  @TrN_DataDo         NVARCHAR(25)
declare @TrNID table (Id int)
SELECT
    @TrN_DataOd = CONVERT(DATETIME, @TrN_DataOdChar, 120),
    @TrN_DataDo = CONVERT(DATETIME, @TrN_DataDoChar, 120)
 if @MagID = 0
 INSERT INTO @TrNId
     SELECT distinct TrN_TrNId
     FROM cdn.TraNag
     WHERE TrN_TypDokumentu = 302 and  TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID and @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID and @PodTyp = 1 ) and  TrN_PodmiotTyp = @PodTyp  and TrN_DataOpe >= @TrN_DataOd and TrN_DataOpe <= @TrN_DataDo AND TrN_Korekta = 0 and trn_rodzaj != 302100
 else
 INSERT INTO @TrNId
     SELECT distinct TrN_TrNId
     FROM cdn.TraNag
     WHERE TrN_TypDokumentu = 302 and  TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID and @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID and @PodTyp = 1 ) and  TrN_PodmiotTyp = @PodTyp and TrN_MagZrdId = @MagID  and TrN_DataOpe >= @TrN_DataOd and TrN_DataOpe <= @TrN_DataDo AND TrN_Korekta = 0 and trn_rodzaj != 302100
 INSERT INTO @TrNId
     SELECT distinct TrN_TrNId
     FROM cdn.TraNag
     WHERE  TrN_TypDokumentu = 302  and TrN_DataOpe >= @TrN_DataOd and TrN_DataOpe <= @TrN_DataDo
     AND  TrN_ZwrId in (select ID from @TrNID)  AND TrN_Rodzaj not in (302101,302102,302103)
 if (@KorektyPo = 1)
 INSERT INTO @TrNId
     SELECT distinct TrN_TrNId
     FROM cdn.TraNag
     WHERE TrN_ZwRID in (select ID from @TrNID) and TrN_DataOpe > @TrN_DataDo AND TrN_Rodzaj not in (302101,302102,302103)
if (@KorektyPrzed = 1)
 if @MagID = 0
  INSERT INTO @TrNId
     SELECT distinct KOR.TrN_TrNId
     FROM cdn.TraNag KOR
     join cdn.TraNag FAK ON Kor.TrN_ZwrId = FAK.TrN_TrNID
     WHERE  KOR.TrN_TypDokumentu = 302 and  KOR.TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID and @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID and @PodTyp = 1 ) and  KOR.TrN_PodmiotTyp = @PodTyp  AND KOR.TrN_Korekta > 0 AND KOR.TrN_Bufor = 0
  AND FAK.TrN_DataOpe < @TrN_DataOd  and  Kor.TrN_DataOpe >= @TrN_DataOd and Kor.TrN_DataOpe <= @TrN_DataDo AND KOR.TrN_Rodzaj not in (302101,302102,302103)
 else
 INSERT INTO @TrNId
     SELECT distinct KOR.TrN_TrNId
     FROM cdn.TraNag KOR
     join cdn.TraNag FAK ON Kor.TrN_ZwrId = FAK.TrN_TrNID
     WHERE  KOR.TrN_TypDokumentu = 302 and  KOR.TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID and @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID and @PodTyp = 1 ) and  KOR.TrN_PodmiotTyp = @PodTyp and KOR.TrN_MagZrdId = @MagID AND KOR.TrN_Korekta > 0 AND KOR.TrN_Bufor = 0
  AND FAK.TrN_DataOpe < @TrN_DataOd  and  Kor.TrN_DataOpe >= @TrN_DataOd and Kor.TrN_DataOpe <= @TrN_DataDo AND KOR.TrN_Rodzaj not in (302101,302102,302103)
select 1 as Typ, TrN_NumerPelny  from cdn.TraNag where TrN_TrNId in (select ID from @TrNID)  and TrN_Bufor = 1
union all
select 2,'waluta' from (select case when TrN_Waluta = '' then @WalSys else TrN_Waluta end as waluta  from cdn.TraNag
where TrN_TrNId in (select ID from @TrNID) AND TrN_Bufor = 0
group by case when TrN_Waluta = '' then @WalSys else TrN_Waluta end ) wal
having count(*)> 1
SET NOCOUNT OFF
