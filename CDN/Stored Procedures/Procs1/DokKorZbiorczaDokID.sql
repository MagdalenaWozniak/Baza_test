CREATE PROCEDURE [CDN].[DokKorZbiorczaDokID]
  @DokId                  TEXT
AS
SET NOCOUNT ON
declare @TrNID table (Id int)
INSERT INTO @TrNID
 SELECT NextIdInt from
 CDN.Text2TableInt ( @DokId )
select ID from @TrNID join cdn.tranag on ID = TrN_TrnID where TrN_Bufor = 0
SET NOCOUNT OFF
