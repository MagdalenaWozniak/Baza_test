CREATE PROCEDURE [CDN].[SprawdzCzyMoznaKorZbiorczaDokId]
  @DokId                  TEXT,
  @WalSys                 VARCHAR(3)
AS
SET NOCOUNT ON
declare @TrNID table (Id int)
 INSERT INTO @TrNID
 SELECT NextIdInt from
 CDN.Text2TableInt ( @DokId )
select 1 as Typ, TrN_NumerPelny  from cdn.TraNag where TrN_TrNId in (select ID from @TrNID)  and TrN_Bufor = 1
union all
select 2,'waluta' from (select case when TrN_Waluta = '' then @WalSys else TrN_Waluta end as waluta  from cdn.TraNag
where TrN_TrNId in (select ID from @TrNID) AND TrN_Bufor = 0
group by case when TrN_Waluta = '' then @WalSys else TrN_Waluta end ) wal
having count(*)> 1
SET NOCOUNT OFF
