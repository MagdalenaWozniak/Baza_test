CREATE TABLE [CDN].[DefAtrElem] (
    [DAE_DAEId]   INT            IDENTITY (1, 1) NOT NULL,
    [DAE_DeAId]   INT            NOT NULL,
    [DAE_Wartosc] NVARCHAR (100) NOT NULL,
    [DAE_Lp]      INT            CONSTRAINT [DF_DAE_Lp] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [DAE_Primary] PRIMARY KEY CLUSTERED ([DAE_DAEId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [TwADefAtrybut]
    ON [CDN].[DefAtrElem]([DAE_DeAId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE   TRIGGER CDN.DefAtrElem_Update_Trigger
  ON CDN.DefAtrElem
  FOR UPDATE, INSERT
AS
 SET NOCOUNT ON
 if Update(DAE_Wartosc)
 begin
  if exists(SELECT DeA_DeAId
  FROM deleted
  JOIN CDN.DefAtrybuty  ON DeA_DeAId = DAE_DeAId
  join cdn.TwrAtrybuty on TwA_DeAId = DAE_DeAId and DAE_Wartosc = TwA_WartoscTxt
  where DeA_Format = 3  AND LTRIM(RTRIM(TwA_WartoscTxt)) != '' )
  begin
   update cdn.TwrAtrybuty set TwA_WartoscTxt = i.DAE_Wartosc from
   inserted i
   join deleted d on d.DAE_DeAId = i.DAE_DeAId
   JOIN CDN.DefAtrybuty  ON DeA_DeAId = i.DAE_DeAId
   join cdn.TwrAtrybuty on TwA_DeAId = i.DAE_DeAId and d.DAE_Wartosc = TwA_WartoscTxt
   where DeA_Format = 3  AND LTRIM(RTRIM(TwA_WartoscTxt)) != ''
   update Twr  set TwTS_TS_ModESklep = GETDATE() from CDN.TwrTSModEsklep Twr
   join cdn.Towary on TwTS_TwrId = Twr_TwrId
   where Twr_TwrId in (
   select distinct twa_twrid from CDN.TwrAtrybuty
   right outer join inserted on Twa_DeAId = DAE_DeAId
   where TwA_ESklep =1)
   and exists (select * from cdn.TwrESklep where  Twr_TwrId = Twes_TwrID and Twes_Udostepnij = 1)
   insert into  CDN.TwrTSModEsklep
   select Twr_TwrId,GETDATE() from cdn.Towary
   left join CDN.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
   where TwTS_TwrId is null and Twr_TwrId in (
   select distinct twa_twrid from CDN.TwrAtrybuty
   right outer join inserted on Twa_DeAId = DAE_DeAId
   where TwA_ESklep =1)
   and exists (select * from cdn.TwrESklep where  Twr_TwrId = Twes_TwrID and Twes_Udostepnij = 1)
  end
 end
 Update CDN.DefAtrybuty Set DeA_TS_Export = Null Where DeA_DeAId In (Select DAE_DeAId From inserted)
 SET NOCOUNT OFF

GO
CREATE   TRIGGER CDN.DefAtrElem_Delete_Trigger
  ON CDN.DefAtrElem
  FOR Delete
AS
  SET NOCOUNT ON
if exists(SELECT DeA_DeAId
FROM deleted del
JOIN CDN.DefAtrybuty  ON DeA_DeAId = del.DAE_DeAId
join cdn.TwrAtrybuty on TwA_DeAId = del.DAE_DeAId and del.DAE_Wartosc = TwA_WartoscTxt
where DeA_Format = 3  AND LTRIM(RTRIM(TwA_WartoscTxt)) != ''
AND Not exists (select * from DefAtrElem org where org.DAE_Wartosc =  del.DAE_Wartosc and org.DAE_DeAId = del.DAE_DeAId) )
begin
 CREATE TABLE #TWRID(Id int)
 INSERT INTO #TWRID
 SELECT distinct TwA_TwrId
 FROM deleted
 JOIN CDN.DefAtrybuty  ON DeA_DeAId = DAE_DeAId
 JOIN cdn.TwrAtrybuty on TwA_DeAId = DAE_DeAId and DAE_Wartosc = TwA_WartoscTxt
 where DeA_Format = 3  AND LTRIM(RTRIM(TwA_WartoscTxt)) != ''
 delete from cdn.TwrAtrybuty where   TwA_TwAId in(
 SELECT distinct TwA_TwAId
 FROM deleted
 JOIN CDN.DefAtrybuty  ON DeA_DeAId = DAE_DeAId
 JOIN cdn.TwrAtrybuty on TwA_DeAId = DAE_DeAId and DAE_Wartosc = TwA_WartoscTxt
 where DeA_Format = 3  AND LTRIM(RTRIM(TwA_WartoscTxt)) != ''
 )
 UPDATE  A SET Twa_Lp = lp FROM cdn.TwrAtrybuty A
 JOIN
 (select TwA_TwaID ,ROW_NUMBER() OVER(PARTITION BY TwA_TwrId  ORDER BY Twa_Lp )as lp from CDN.TwrAtrybuty where TwA_TwrId in
 (
 select Id from #TWRID)) B on A.TwA_TwAId = B.TwA_TwAId
 update Twr  set TwTS_TS_ModESklep = GETDATE() from CDN.TwrTSModEsklep Twr
 join cdn.Towary on TwTS_TwrId = Twr_TwrId
 where Twr_TwrId in (
 select distinct twa_twrid from CDN.TwrAtrybuty
 right outer join deleted on Twa_DeAId = DAE_DeAId
 where TwA_ESklep =1)
 and exists (select * from cdn.TwrESklep where  Twr_TwrId = Twes_TwrID and Twes_Udostepnij = 1)
 insert into  CDN.TwrTSModEsklep
 select Twr_TwrId,GETDATE() from cdn.Towary
 left join CDN.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
 where TwTS_TwrId is null and Twr_TwrId in (
 select distinct twa_twrid from CDN.TwrAtrybuty
 right outer join deleted on Twa_DeAId = DAE_DeAId
 where TwA_ESklep =1)
 and exists (select * from cdn.TwrESklep where  Twr_TwrId = Twes_TwrID and Twes_Udostepnij = 1)
end
SET NOCOUNT OFF
