CREATE PROCEDURE [CDN].[InicjujTraElemKorZbiorczaDokId]
@DokId                  TEXT
AS
SET NOCOUNT ON
declare @TrNID table (Id int)
INSERT INTO @TrNID
 SELECT NextIdInt from
 CDN.Text2TableInt ( @DokId )
select TrV_Stawka as Stawka ,TrV_Flaga as Flaga,TrV_Zrodlowa as Zrodlowa,sum(TrV_NettoWal) as RazemNetto,sum(TrV_NettoWal)+sum(TrV_VATWal) as RazemBrutto,MAX(TrN_Waluta) as Waluta from cdn.TraVat
left join cdn.TraNag on TrN_TrNID = TrV_TrNID
where TrN_TrNID in (select ID from @TrNID) AND TrN_Bufor = 0
group by TrV_Stawka,TrV_Flaga,TrV_Zrodlowa
SET NOCOUNT OFF
