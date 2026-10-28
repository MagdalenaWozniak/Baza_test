create PROCEDURE CDN.Asygnata @dataOd DATETIME, @dataDo DATETIME, @PrcId INT, @zus INT, @NbId INT
AS
SET NOCOUNT ON
DECLARE @NieobOd DATETIME
DECLARE @NieobDo DATETIME
DECLARE @Seria  NVARCHAR(10)
DECLARE @Nr  NVARCHAR(20)
DECLARE @Od  DATETIME
DECLARE @Do  DATETIME
DECLARE @Flaga  INT
DECLARE @Fl  INT
DECLARE @Ile  INT
DECLARE @Check  INT
SET @NieobOd = @dataOd
SET @NieobDo = @dataDo
SET @Check = 1
CREATE TABLE #Asygn1 (
 Tmp_DataOd DATETIME,
 Tmp_DataDo DATETIME
 )
SET @Ile = (select count(PNB_PnbId) from cdn.pracnieobec where PNB_PraId = @PrcId)
IF @Ile = 1
 BEGIN
  SET @NieobOd = (select PNB_OkresOd from cdn.pracnieobec where PNB_PraId = @PrcId)
  SET @NieobDo = (select PNB_OkresDo from cdn.pracnieobec where PNB_PraId = @PrcId)
  SET @Seria = (select PNB_Seria from cdn.pracnieobec where PNB_PraId = @PrcId)
  SET @Nr = (select PNB_Numer from cdn.pracnieobec where PNB_PraId = @PrcId)
 END
--Szukamy Od
IF @Ile>1
BEGIN
SET @Flaga = (select top 1 PNB_NaPodstPoprzNB from cdn.pracnieobec
inner join cdn.wypskladniki on pnb_pnbid = wps_zrodloid
inner join cdn.typwyplata on wps_twpid = twp_twpid
where wps_rodzajzrodla = 6
and PNB_PnbId = @NbId and
PNB_PraId= @PrcId and TWP_PdzId = @ZUS
order by WPS_Datado DESC)
IF @Flaga = 0
   SET @NieobOd = @dataOd
IF @Flaga = 1
 BEGIN
  DECLARE Tmp_Asygn CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
 PNB_OkresOd,
 PNB_OkresDo,
 PNB_NaPodstPoprzNB
  FROM CDN.PracNieobec
  WHERE PNB_PraID = @PrcId AND PNB_Tryb<>1 AND PNB_OkresDo<@dataOd
  ORDER BY PNB_OkresOd DESC
  OPEN Tmp_Asygn
  WHILE 1=1
 BEGIN
  FETCH NEXT FROM Tmp_Asygn INTO  @Od, @Do, @Fl
  IF @@FETCH_STATUS <> 0 BREAK
  IF @Check = 1
  BEGIN
   IF @Do+1 = @NieobOd
      SET @NieobOd = @Od
      SET @Check = @Fl
  END
 END
  CLOSE  Tmp_Asygn
  DEALLOCATE  Tmp_Asygn
  SET NOCOUNT OFF
 END
--Szukamy do
DECLARE Tmp_Asygn CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  SELECT
 PNB_OkresOd,
 PNB_OkresDo,
 PNB_NaPodstPoprzNB
  FROM CDN.PracNieobec
  WHERE PNB_PraID = @PrcId AND PNB_Tryb<>1 AND PNB_OkresOd>@dataDo AND PNB_NaPodstPoprzNB = 1
  ORDER BY PNB_OkresOd
  OPEN Tmp_Asygn
  WHILE 1=1
 BEGIN
  FETCH NEXT FROM Tmp_Asygn INTO  @Od, @Do, @Fl
  IF @@FETCH_STATUS <> 0 BREAK
  BEGIN
   IF @NieobDo+ 1 = @Od
   SET @NieobDo = @Do
  END
 END
  CLOSE  Tmp_Asygn
  DEALLOCATE  Tmp_Asygn
  SET NOCOUNT OFF
END
INSERT INTO #Asygn1 values (@NieobOd, @NieobDo)
SELECT
   * FROM #Asygn1
