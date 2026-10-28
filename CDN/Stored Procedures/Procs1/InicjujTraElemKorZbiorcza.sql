CREATE PROCEDURE CDN.InicjujTraElemKorZbiorcza
  @PodID                  INT,
  @PodTyp                 INT,
  @MagID                  INT,
  @TrN_DataOdChar         NVARCHAR(25),
  @TrN_DataDoChar         NVARCHAR(25),
  @KorektyPrzed     INT,
  @KorektyPo     INT
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
     WHERE TrN_TypDokumentu = 302 and  TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID and @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID and @PodTyp = 1 ) and  TrN_PodmiotTyp = @PodTyp  and TrN_DataOpe >= @TrN_DataOd and TrN_DataOpe <= @TrN_DataDo AND TrN_Korekta = 0 AND TrN_Bufor = 0  and trn_rodzaj != 302100
 else
 INSERT INTO @TrNId
     SELECT distinct TrN_TrNId
     FROM cdn.TraNag
     WHERE TrN_TypDokumentu = 302 and  TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID and @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID and @PodTyp = 1 ) and  TrN_PodmiotTyp = @PodTyp and TrN_MagZrdId = @MagID  and TrN_DataOpe >= @TrN_DataOd and TrN_DataOpe <= @TrN_DataDo AND TrN_Korekta = 0 AND TrN_Bufor = 0  and trn_rodzaj != 302100
 INSERT INTO @TrNId
     SELECT distinct TrN_TrNId
     FROM cdn.TraNag
     WHERE  TrN_TypDokumentu = 302  and TrN_DataOpe >= @TrN_DataOd and TrN_DataOpe <= @TrN_DataDo
     AND  TrN_ZwrId in (select ID from @TrNID)  AND TrN_Bufor = 0 AND TrN_Rodzaj not in (302101,302102,302103)
 if (@KorektyPo = 1)
 INSERT INTO @TrNId
     SELECT distinct TrN_TrNId
     FROM cdn.TraNag
     WHERE TrN_ZwRID in (select ID from @TrNID) and TrN_DataOpe > @TrN_DataDo AND TrN_Bufor = 0 AND TrN_Rodzaj not in (302101,302102,302103)
if (@KorektyPrzed = 1)
 if @MagID = 0
  INSERT INTO @TrNId
     SELECT distinct KOR.TrN_TrNId
     FROM cdn.TraNag KOR
     join cdn.TraNag FAK ON Kor.TrN_ZwrId = FAK.TrN_TrNID
     WHERE  KOR.TrN_TypDokumentu = 302 and  KOR.TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID and @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID and @PodTyp = 1 ) and  KOR.TrN_PodmiotTyp = @PodTyp  AND KOR.TrN_Korekta > 0 AND KOR.TrN_Bufor = 0
  AND KOR.TrN_Rodzaj not in (302101,302102,302103) AND FAK.TrN_DataOpe < @TrN_DataOd  and  Kor.TrN_DataOpe >= @TrN_DataOd and Kor.TrN_DataOpe <= @TrN_DataDo
 else
 INSERT INTO @TrNId
     SELECT distinct KOR.TrN_TrNId
     FROM cdn.TraNag KOR
     join cdn.TraNag FAK ON Kor.TrN_ZwrId = FAK.TrN_TrNID
     WHERE  KOR.TrN_TypDokumentu = 302 and  KOR.TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID and @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID and @PodTyp = 1 ) and  KOR.TrN_PodmiotTyp = @PodTyp and KOR.TrN_MagZrdId = @MagID AND KOR.TrN_Korekta > 0 AND KOR.TrN_Bufor = 0
  AND KOR.TrN_Rodzaj not in (302101,302102,302103) AND FAK.TrN_DataOpe < @TrN_DataOd  and  Kor.TrN_DataOpe >= @TrN_DataOd and Kor.TrN_DataOpe <= @TrN_DataDo
select TrV_Stawka as Stawka ,TrV_Flaga as Flaga,TrV_Zrodlowa as Zrodlowa,sum(TrV_NettoWal) as RazemNetto,sum(TrV_NettoWal)+sum(TrV_VATWal) as RazemBrutto,MAX(TrN_Waluta) as Waluta from cdn.TraVat
left join cdn.TraNag on TrN_TrNID = TrV_TrNID
where TrN_TrNID in (select ID from @TrNID)
group by TrV_Stawka,TrV_Flaga,TrV_Zrodlowa
SET NOCOUNT OFF
