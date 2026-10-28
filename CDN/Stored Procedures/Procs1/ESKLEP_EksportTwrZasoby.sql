CREATE PROCEDURE [CDN].[ESKLEP_EksportTwrZasoby]
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu stanów towaru (0 - różnicowy, 1 - pełny)
AS
DECLARE
     @DataDzis      INT,
  @DataDzisPobierzZasoby DATETIME,
     @CechyPartii   INT,
     @TsC_TsCID INT,
     @TwrId     INT,
     @TsC_Cecha1_DeAId int,
     @TsC_Cecha2_DeAId int,
     @TsC_Cecha3_DeAId int,
     @TsC_Cecha4_DeAId int,
     @TsC_Cecha5_DeAId int,
     @TsC_Cecha6_DeAId int,
     @TsC_Cecha7_DeAId int,
     @TsC_Cecha8_DeAId int,
     @TsC_Cecha9_DeAId int,
     @TsC_Cecha10_DeAId int,
     @TsC_Cecha1_Wartosc nvarchar(255),
     @TsC_Cecha1_WarID int,
     @TsC_Cecha2_Wartosc nvarchar(255),
     @TsC_Cecha2_WarID int,
     @TsC_Cecha3_Wartosc nvarchar(255),
     @TsC_Cecha3_WarID int,
     @TsC_Cecha4_Wartosc nvarchar(255),
     @TsC_Cecha4_WarID int,
     @TsC_Cecha5_Wartosc nvarchar(255),
     @TsC_Cecha5_WarID int,
     @TsC_Cecha6_Wartosc nvarchar(255),
     @TsC_Cecha6_WarID int,
     @TsC_Cecha7_Wartosc nvarchar(255),
     @TsC_Cecha7_WarID int,
     @TsC_Cecha8_Wartosc nvarchar(255),
     @TsC_Cecha8_WarID int,
     @TsC_Cecha9_Wartosc nvarchar(255),
     @TsC_Cecha9_WarID int,
     @TsC_Cecha10_Wartosc nvarchar(255),
     @TsC_Cecha10_WarID int,
     @TsC_Cecha1_DeAIdTC int,
     @TsC_Cecha2_DeAIdTC int,
     @TsC_Cecha3_DeAIdTC int,
     @TsC_Cecha4_DeAIdTC int,
     @TsC_Cecha5_DeAIdTC int,
     @TsC_Cecha6_DeAIdTC int,
     @TsC_Cecha7_DeAIdTC int,
     @TsC_Cecha8_DeAIdTC int,
     @TsC_Cecha9_DeAIdTC int,
     @TsC_Cecha10_DeAIdTC int,
     @TsC_Cecha1_WarIDTC int,
     @TsC_Cecha2_WarIDTC int,
     @TsC_Cecha3_WarIDTC int,
     @TsC_Cecha4_WarIDTC int,
     @TsC_Cecha5_WarIDTC int,
     @TsC_Cecha6_WarIDTC int,
     @TsC_Cecha7_WarIDTC int,
     @TsC_Cecha8_WarIDTC int,
     @TsC_Cecha9_WarIDTC int,
     @TsC_Cecha10_WarIDTC int,
     @ESSID            int
-- sprawdzamy czy mamy wysylac zasoby dla tego sklepu
 if not exists (SELECT *
 FROM cdn.eSklepStanowiska
 WHERE ESS_IdISklep = @ID and ESS_ExpZasoby = 1)
  return
 SELECT
   @ESSID = ESS_ESSID,
   @DataDzis =  ESS_StanyNaDzien,
   @CechyPartii =  ESS_WyslijCechyPartii
 FROM cdn.eSklepStanowiska
 WHERE ESS_IdISklep = @ID
IF @DataDzis = 1
 SELECT @DataDzisPobierzZasoby = GETDATE()
ELSE
 SELECT @DataDzisPobierzZasoby = DATEADD(year, 1000, GETDATE())
CREATE TABLE #tmpRecordSet1(
TsC_TsCID INT,
TsC_TrSID INT,
TwrID INT,
ilosc decimal(15,2),
TsC_Cecha1_DeAId int NOT NULL,
TsC_Cecha1_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha1_WarID int NOT NULL,
TsC_Cecha2_DeAId int NOT NULL,
TsC_Cecha2_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha2_WarID int NOT NULL,
TsC_Cecha3_DeAId int NOT NULL,
TsC_Cecha3_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha3_WarID int NOT NULL,
TsC_Cecha4_DeAId int NOT NULL,
TsC_Cecha4_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha4_WarID int NOT NULL,
TsC_Cecha5_DeAId int NOT NULL,
TsC_Cecha5_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha5_WarID int NOT NULL,
TsC_Cecha6_DeAId int NOT NULL,
TsC_Cecha6_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha6_WarID int NOT NULL,
TsC_Cecha7_DeAId int NOT NULL,
TsC_Cecha7_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha7_WarID int NOT NULL,
TsC_Cecha8_DeAId int NOT NULL,
TsC_Cecha8_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha8_WarID int NOT NULL,
TsC_Cecha9_DeAId int NOT NULL,
TsC_Cecha9_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha9_WarID int NOT NULL,
TsC_Cecha10_DeAId int NOT NULL,
TsC_Cecha10_Wartosc nvarchar(255) NOT NULL,
TsC_Cecha10_WarID int NOT NULL,
)
CREATE TABLE #tmpRecordSet2(
TwA_DeAId INT,TwA_TwrId int
)
CREATE TABLE #tmpRecordSet3(
DAEId INT,
DeAId INT,
Wartosc nvarchar(255)
)
   if  @CechyPartii = 1
    begin
   insert into #tmpRecordSet2
   select distinct TwA_DeAId,TwA_TwrId
   from cdn.twratrybuty
   join cdn.DefAtrybuty on TwA_DeAId = DeA_DeAId
   where TwA_CzyPrzenosicNaDostawy = 1 and DeA_Format = 3 and Twa_ESklep = 1
   insert into #tmpRecordSet3
   select distinct  DAE_DAEId  ,TwA_DeAId ,DAE_Wartosc from cdn.twratrybuty
   join cdn.DefAtrybuty on TwA_DeAId = DeA_DeAId
   join cdn.DefAtrElem on DeA_DeAId = DAE_DeAId
   where TwA_CzyPrzenosicNaDostawy = 1 and DeA_Format = 3 and Twa_ESklep = 1
   insert into #tmpRecordSet1
   select TsC_TsCID, TsC_TrSID ,TwZ_TwrId,TwZ_Ilosc,
  TsC_Cecha1_DeAId ,
  TsC_Cecha1_Wartosc ,0,
  TsC_Cecha2_DeAId ,
  TsC_Cecha2_Wartosc ,0,
  TsC_Cecha3_DeAId ,
  TsC_Cecha3_Wartosc ,0,
  TsC_Cecha4_DeAId ,
  TsC_Cecha4_Wartosc ,0,
  TsC_Cecha5_DeAId ,
  TsC_Cecha5_Wartosc ,0,
  TsC_Cecha6_DeAId ,
    TsC_Cecha6_Wartosc ,0,
   TsC_Cecha7_DeAId ,
  TsC_Cecha7_Wartosc ,0,
  TsC_Cecha8_DeAId ,
  TsC_Cecha8_Wartosc ,0,
  TsC_Cecha9_DeAId ,
  TsC_Cecha9_Wartosc ,0,
  TsC_Cecha10_DeAId ,
  TsC_Cecha10_Wartosc ,0
  from cdn.TwrZasoby
   join cdn.TraSElem on TrS_TrSID = TwZ_TrSIdDost
   join cdn.TraSElemCechy on TrS_TrSID = TsC_TrSID
   where  TwZ_TwrId in
   (
   select twr_twrid
   from Cdn.towary
   LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
   LEFT JOIN (SELECT * from Cdn.TwrIlosci
   JOIN (
  SELECT X.twi_data AS DATA, X.twi_twiid AS Twiid
  FROM cdn.twrilosci X where X.twi_twiid = CDN.TwrIlosciID ( X.twi_twrid, 0, GETDATE() )
  ) B ON  TwIId= TwI_TwIId) A ON A.TwI_TwrId = Twr_TwrID AND A.TwI_MagId is NULL
   WHERE  Twes_Udostepnij =1  AND Twr_NieAktywny = 0 AND TwI_Ilosc is not null and TwI_Ilosc > 0
   )
  DECLARE T CURSOR LOCAL FAST_FORWARD FOR
    SELECT
  TsC_TsCID,
  TwrID,
  TsC_Cecha1_DeAId ,
  TsC_Cecha2_DeAId ,
  TsC_Cecha3_DeAId ,
  TsC_Cecha4_DeAId ,
  TsC_Cecha5_DeAId ,
  TsC_Cecha6_DeAId ,
   TsC_Cecha7_DeAId ,
  TsC_Cecha8_DeAId ,
  TsC_Cecha9_DeAId ,
  TsC_Cecha10_DeAId,
  TsC_Cecha1_Wartosc ,
  TsC_Cecha1_WarID ,
  TsC_Cecha2_Wartosc ,
  TsC_Cecha2_WarID ,
  TsC_Cecha3_Wartosc ,
  TsC_Cecha3_WarID ,
  TsC_Cecha4_Wartosc ,
  TsC_Cecha4_WarID ,
  TsC_Cecha5_Wartosc ,
  TsC_Cecha5_WarID ,
  TsC_Cecha6_Wartosc ,
  TsC_Cecha6_WarID ,
  TsC_Cecha7_Wartosc ,
  TsC_Cecha7_WarID ,
  TsC_Cecha8_Wartosc ,
  TsC_Cecha8_WarID ,
  TsC_Cecha9_Wartosc ,
  TsC_Cecha9_WarID ,
  TsC_Cecha10_Wartosc ,
  TsC_Cecha10_WarID   FROM #tmpRecordSet1
    OPEN T
   WHILE 1=1
   BEGIN
  FETCH NEXT FROM T INTO  @TsC_TsCID,
     @TwrId,
     @TsC_Cecha1_DeAId ,
     @TsC_Cecha2_DeAId ,
     @TsC_Cecha3_DeAId ,
     @TsC_Cecha4_DeAId ,
     @TsC_Cecha5_DeAId ,
     @TsC_Cecha6_DeAId ,
     @TsC_Cecha7_DeAId ,
     @TsC_Cecha8_DeAId ,
     @TsC_Cecha9_DeAId ,
     @TsC_Cecha10_DeAId,
     @TsC_Cecha1_Wartosc ,
     @TsC_Cecha1_WarID ,
     @TsC_Cecha2_Wartosc ,
     @TsC_Cecha2_WarID ,
     @TsC_Cecha3_Wartosc ,
     @TsC_Cecha3_WarID ,
     @TsC_Cecha4_Wartosc ,
     @TsC_Cecha4_WarID ,
     @TsC_Cecha5_Wartosc ,
     @TsC_Cecha5_WarID ,
     @TsC_Cecha6_Wartosc ,
     @TsC_Cecha6_WarID ,
     @TsC_Cecha7_Wartosc ,
     @TsC_Cecha7_WarID ,
     @TsC_Cecha8_Wartosc ,
     @TsC_Cecha8_WarID ,
     @TsC_Cecha9_Wartosc ,
     @TsC_Cecha9_WarID ,
     @TsC_Cecha10_Wartosc ,
     @TsC_Cecha10_WarID
  IF @@FETCH_STATUS <> 0 BREAK
  if @TsC_Cecha1_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha1_DeAId = 0
  else
   select @TsC_Cecha1_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha1_DeAId = DeAId and @TsC_Cecha1_Wartosc = Wartosc
  if @TsC_Cecha2_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha2_DeAId = 0
  else
   select @TsC_Cecha2_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha2_DeAId = DeAId and  @TsC_Cecha2_Wartosc = Wartosc
  if @TsC_Cecha3_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha3_DeAId = 0
  else
   select @TsC_Cecha3_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha3_DeAId = DeAId and  @TsC_Cecha3_Wartosc = Wartosc
  if @TsC_Cecha4_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha4_DeAId = 0
  else
   select @TsC_Cecha4_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha4_DeAId = DeAId and  @TsC_Cecha4_Wartosc = Wartosc
  if @TsC_Cecha5_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha5_DeAId = 0
  else
   select @TsC_Cecha5_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha5_DeAId = DeAId and  @TsC_Cecha5_Wartosc = Wartosc
  if @TsC_Cecha6_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha6_DeAId = 0
  else
   select @TsC_Cecha6_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha6_DeAId = DeAId and  @TsC_Cecha6_Wartosc = Wartosc
  if @TsC_Cecha7_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha7_DeAId = 0
  else
   select @TsC_Cecha7_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha7_DeAId = DeAId and  @TsC_Cecha7_Wartosc = Wartosc
  if @TsC_Cecha8_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha8_DeAId = 0
  else
   select @TsC_Cecha8_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha8_DeAId = DeAId and  @TsC_Cecha8_Wartosc = Wartosc
  if @TsC_Cecha9_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha9_DeAId = 0
  else
   select @TsC_Cecha9_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha9_DeAId = DeAId and  @TsC_Cecha9_Wartosc = Wartosc
  if @TsC_Cecha10_DeAId not in (select TwA_DeAId  from #tmpRecordSet2 where TwA_TwrId = @TwrId)
   set @TsC_Cecha10_DeAId = 0
  else
   select @TsC_Cecha10_WarID = DAEId from  #tmpRecordSet3 where @TsC_Cecha10_DeAId = DeAId and  @TsC_Cecha10_Wartosc = Wartosc
  select   @TsC_Cecha1_DeAIdTC = 0,
     @TsC_Cecha2_DeAIdTC = 0,
     @TsC_Cecha3_DeAIdTC = 0,
     @TsC_Cecha4_DeAIdTC = 0,
     @TsC_Cecha5_DeAIdTC = 0,
     @TsC_Cecha6_DeAIdTC = 0,
     @TsC_Cecha7_DeAIdTC = 0,
     @TsC_Cecha8_DeAIdTC = 0,
     @TsC_Cecha9_DeAIdTC = 0,
     @TsC_Cecha10_DeAIdTC = 0
   if @TsC_Cecha1_DeAId > 0
  select @TsC_Cecha1_DeAIdTC = @TsC_Cecha1_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha1_WarID
   if @TsC_Cecha2_DeAId > 0
  if @TsC_Cecha1_DeAIdTC > 0
   select @TsC_Cecha2_DeAIdTC = @TsC_Cecha2_DeAId,@TsC_Cecha2_WarIDTC = @TsC_Cecha2_WarID
  else
   select @TsC_Cecha1_DeAIdTC = @TsC_Cecha2_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha2_WarID
   if @TsC_Cecha3_DeAId > 0
  if @TsC_Cecha2_DeAIdTC > 0
    select @TsC_Cecha3_DeAIdTC = @TsC_Cecha3_DeAId,@TsC_Cecha3_WarIDTC = @TsC_Cecha3_WarID
  else
    if @TsC_Cecha1_DeAIdTC > 0
    select @TsC_Cecha2_DeAIdTC = @TsC_Cecha3_DeAId,@TsC_Cecha2_WarIDTC = @TsC_Cecha3_WarID
    else
    select @TsC_Cecha1_DeAIdTC = @TsC_Cecha3_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha3_WarID
   if @TsC_Cecha4_DeAId > 0
    if @TsC_Cecha3_DeAIdTC > 0
   select @TsC_Cecha4_DeAIdTC = @TsC_Cecha4_DeAId,@TsC_Cecha4_WarIDTC = @TsC_Cecha4_WarID
    else
   if @TsC_Cecha2_DeAIdTC > 0
    select @TsC_Cecha3_DeAIdTC = @TsC_Cecha4_DeAId,@TsC_Cecha3_WarIDTC = @TsC_Cecha4_WarID
   else
     if @TsC_Cecha1_DeAIdTC > 0
     select @TsC_Cecha2_DeAIdTC = @TsC_Cecha4_DeAId,@TsC_Cecha2_WarIDTC = @TsC_Cecha4_WarID
     else
     select @TsC_Cecha1_DeAIdTC = @TsC_Cecha4_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha4_WarID
    if @TsC_Cecha5_DeAId > 0
  if @TsC_Cecha4_DeAIdTC > 0
   select @TsC_Cecha5_DeAIdTC = @TsC_Cecha5_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha5_WarID
  else
     if @TsC_Cecha3_DeAIdTC > 0
    select @TsC_Cecha4_DeAIdTC = @TsC_Cecha5_DeAId,@TsC_Cecha4_WarIDTC = @TsC_Cecha5_WarID
     else
    if @TsC_Cecha2_DeAIdTC > 0
     select @TsC_Cecha3_DeAIdTC = @TsC_Cecha5_DeAId,@TsC_Cecha3_WarIDTC = @TsC_Cecha5_WarID
    else
   if @TsC_Cecha1_DeAIdTC > 0
   select @TsC_Cecha2_DeAIdTC = @TsC_Cecha5_DeAId,@TsC_Cecha2_WarIDTC = @TsC_Cecha5_WarID
   else
   select @TsC_Cecha1_DeAIdTC = @TsC_Cecha5_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha5_WarID
    if @TsC_Cecha6_DeAId > 0
  if @TsC_Cecha5_DeAIdTC > 0
   select @TsC_Cecha6_DeAIdTC = @TsC_Cecha6_DeAId,@TsC_Cecha6_WarIDTC = @TsC_Cecha6_WarID
  else
   if @TsC_Cecha4_DeAIdTC > 0
    select @TsC_Cecha5_DeAIdTC = @TsC_Cecha6_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha6_WarID
   else
   if @TsC_Cecha3_DeAIdTC > 0
     select @TsC_Cecha4_DeAIdTC = @TsC_Cecha6_DeAId,@TsC_Cecha4_WarIDTC = @TsC_Cecha6_WarID
   else
     if @TsC_Cecha2_DeAIdTC > 0
   select @TsC_Cecha3_DeAIdTC = @TsC_Cecha6_DeAId,@TsC_Cecha3_WarIDTC = @TsC_Cecha6_WarID
     else
    if @TsC_Cecha1_DeAIdTC > 0
    select @TsC_Cecha2_DeAIdTC = @TsC_Cecha6_DeAId,@TsC_Cecha2_WarIDTC = @TsC_Cecha6_WarID
    else
    select @TsC_Cecha1_DeAIdTC = @TsC_Cecha6_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha6_WarID
    if @TsC_Cecha7_DeAId > 0
  if @TsC_Cecha6_DeAIdTC > 0
   select @TsC_Cecha7_DeAIdTC = @TsC_Cecha7_DeAId,@TsC_Cecha7_WarIDTC = @TsC_Cecha7_WarID
  else
   if @TsC_Cecha5_DeAIdTC > 0
    select @TsC_Cecha5_DeAIdTC = @TsC_Cecha7_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha7_WarID
   else
    if @TsC_Cecha4_DeAIdTC > 0
     select @TsC_Cecha5_DeAIdTC = @TsC_Cecha7_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha7_WarID
    else
    if @TsC_Cecha3_DeAIdTC > 0
   select @TsC_Cecha4_DeAIdTC = @TsC_Cecha7_DeAId,@TsC_Cecha4_WarIDTC = @TsC_Cecha7_WarID
    else
   if @TsC_Cecha2_DeAIdTC > 0
    select @TsC_Cecha3_DeAIdTC = @TsC_Cecha7_DeAId,@TsC_Cecha3_WarIDTC = @TsC_Cecha7_WarID
   else
     if @TsC_Cecha1_DeAIdTC > 0
     select @TsC_Cecha2_DeAIdTC = @TsC_Cecha7_DeAId,@TsC_Cecha2_WarIDTC = @TsC_Cecha7_WarID
     else
     select @TsC_Cecha1_DeAIdTC = @TsC_Cecha7_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha7_WarID
    if @TsC_Cecha8_DeAId > 0
     if @TsC_Cecha7_DeAIdTC > 0
   select @TsC_Cecha8_DeAIdTC = @TsC_Cecha8_DeAId,@TsC_Cecha8_WarIDTC = @TsC_Cecha8_WarID
  else
   if @TsC_Cecha6_DeAIdTC > 0
    select @TsC_Cecha7_DeAIdTC = @TsC_Cecha8_DeAId,@TsC_Cecha7_WarIDTC = @TsC_Cecha8_WarID
   else
    if @TsC_Cecha5_DeAIdTC > 0
     select @TsC_Cecha5_DeAIdTC = @TsC_Cecha8_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha8_WarID
    else
     if @TsC_Cecha4_DeAIdTC > 0
   select @TsC_Cecha5_DeAIdTC = @TsC_Cecha8_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha8_WarID
     else
     if @TsC_Cecha3_DeAIdTC > 0
    select @TsC_Cecha4_DeAIdTC = @TsC_Cecha8_DeAId,@TsC_Cecha4_WarIDTC = @TsC_Cecha8_WarID
     else
    if @TsC_Cecha2_DeAIdTC > 0
     select @TsC_Cecha3_DeAIdTC = @TsC_Cecha8_DeAId,@TsC_Cecha3_WarIDTC = @TsC_Cecha8_WarID
    else
      if @TsC_Cecha1_DeAIdTC > 0
      select @TsC_Cecha2_DeAIdTC = @TsC_Cecha8_DeAId,@TsC_Cecha2_WarIDTC = @TsC_Cecha8_WarID
      else
      select @TsC_Cecha1_DeAIdTC = @TsC_Cecha8_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha8_WarID
    if @TsC_Cecha9_DeAId > 0
     if @TsC_Cecha8_DeAIdTC > 0
   select @TsC_Cecha9_DeAIdTC = @TsC_Cecha9_DeAId,@TsC_Cecha9_WarIDTC = @TsC_Cecha9_WarID
  else
   if @TsC_Cecha7_DeAIdTC > 0
    select @TsC_Cecha8_DeAIdTC = @TsC_Cecha9_DeAId,@TsC_Cecha8_WarIDTC = @TsC_Cecha9_WarID
   else
    if @TsC_Cecha6_DeAIdTC > 0
     select @TsC_Cecha7_DeAIdTC = @TsC_Cecha9_DeAId,@TsC_Cecha7_WarIDTC = @TsC_Cecha9_WarID
    else
     if @TsC_Cecha5_DeAIdTC > 0
   select @TsC_Cecha5_DeAIdTC = @TsC_Cecha9_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha9_WarID
     else
   if @TsC_Cecha4_DeAIdTC > 0
    select @TsC_Cecha5_DeAIdTC = @TsC_Cecha9_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha9_WarID
   else
      if @TsC_Cecha3_DeAIdTC > 0
     select @TsC_Cecha4_DeAIdTC = @TsC_Cecha9_DeAId,@TsC_Cecha4_WarIDTC = @TsC_Cecha9_WarID
      else
     if @TsC_Cecha2_DeAIdTC > 0
      select @TsC_Cecha3_DeAIdTC = @TsC_Cecha9_DeAId,@TsC_Cecha3_WarIDTC = @TsC_Cecha9_WarID
     else
    if @TsC_Cecha1_DeAIdTC > 0
    select @TsC_Cecha2_DeAIdTC = @TsC_Cecha9_DeAId,@TsC_Cecha2_WarIDTC = @TsC_Cecha9_WarID
    else
    select @TsC_Cecha1_DeAIdTC = @TsC_Cecha9_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha9_WarID
    if @TsC_Cecha10_DeAId > 0
  if @TsC_Cecha9_DeAIdTC > 0
   select @TsC_Cecha10_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha10_WarIDTC = @TsC_Cecha10_WarID
  else
   if @TsC_Cecha8_DeAIdTC > 0
    select @TsC_Cecha9_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha9_WarIDTC = @TsC_Cecha10_WarID
   else
    if @TsC_Cecha7_DeAIdTC > 0
     select @TsC_Cecha8_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha8_WarIDTC = @TsC_Cecha10_WarID
    else
     if @TsC_Cecha6_DeAIdTC > 0
   select @TsC_Cecha7_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha7_WarIDTC = @TsC_Cecha10_WarID
     else
   if @TsC_Cecha5_DeAIdTC > 0
    select @TsC_Cecha5_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha10_WarID
   else
    if @TsC_Cecha4_DeAIdTC > 0
     select @TsC_Cecha5_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha5_WarIDTC = @TsC_Cecha10_WarID
    else
    if @TsC_Cecha3_DeAIdTC > 0
      select @TsC_Cecha4_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha4_WarIDTC = @TsC_Cecha10_WarID
    else
      if @TsC_Cecha2_DeAIdTC > 0
    select @TsC_Cecha3_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha3_WarIDTC = @TsC_Cecha10_WarID
      else
     if @TsC_Cecha1_DeAIdTC > 0
     select @TsC_Cecha2_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha2_WarIDTC = @TsC_Cecha10_WarID
     else
     select @TsC_Cecha1_DeAIdTC = @TsC_Cecha10_DeAId,@TsC_Cecha1_WarIDTC = @TsC_Cecha10_WarID
  update  #tmpRecordSet1 set
   TsC_Cecha1_DeAId  = @TsC_Cecha1_DeAIdTC, TsC_Cecha1_WarID = case when @TsC_Cecha1_DeAIdTC = 0 then 0 else @TsC_Cecha1_WarIDTC  end,
   TsC_Cecha2_DeAId  = @TsC_Cecha2_DeAIdTC, TsC_Cecha2_WarID = case when @TsC_Cecha2_DeAIdTC = 0 then 0 else @TsC_Cecha2_WarIDTC  end,
   TsC_Cecha3_DeAId  = @TsC_Cecha3_DeAIdTC, TsC_Cecha3_WarID = case when @TsC_Cecha3_DeAIdTC = 0 then 0 else @TsC_Cecha3_WarIDTC  end,
   TsC_Cecha4_DeAId  = @TsC_Cecha4_DeAIdTC, TsC_Cecha4_WarID = case when @TsC_Cecha4_DeAIdTC = 0 then 0 else @TsC_Cecha4_WarIDTC  end,
   TsC_Cecha5_DeAId  = @TsC_Cecha5_DeAIdTC, TsC_Cecha5_WarID = case when @TsC_Cecha5_DeAIdTC = 0 then 0 else @TsC_Cecha5_WarIDTC  end,
   TsC_Cecha6_DeAId  = @TsC_Cecha6_DeAIdTC, TsC_Cecha6_WarID = case when @TsC_Cecha6_DeAIdTC = 0 then 0 else @TsC_Cecha6_WarIDTC  end,
   TsC_Cecha7_DeAId  = @TsC_Cecha7_DeAIdTC, TsC_Cecha7_WarID = case when @TsC_Cecha7_DeAIdTC = 0 then 0 else @TsC_Cecha7_WarIDTC  end,
   TsC_Cecha8_DeAId  = @TsC_Cecha8_DeAIdTC, TsC_Cecha8_WarID = case when @TsC_Cecha8_DeAIdTC = 0 then 0 else @TsC_Cecha8_WarIDTC  end,
   TsC_Cecha9_DeAId  = @TsC_Cecha9_DeAIdTC, TsC_Cecha9_WarID = case when @TsC_Cecha9_DeAIdTC = 0 then 0 else @TsC_Cecha9_WarIDTC  end,
   TsC_Cecha10_DeAId  = @TsC_Cecha10_DeAIdTC, TsC_Cecha10_WarID = case when @TsC_Cecha10_DeAIdTC = 0 then 0 else @TsC_Cecha10_WarIDTC  end
  where   TsC_TsCID = @TsC_TsCID
   END
    CLOSE T
  DEALLOCATE T
  delete from #tmpRecordSet1 where
  TsC_Cecha1_DeAId  = 0 and
   TsC_Cecha2_DeAId  = 0 and
   TsC_Cecha3_DeAId  = 0 and
   TsC_Cecha4_DeAId  = 0 and
   TsC_Cecha5_DeAId  = 0 and
   TsC_Cecha6_DeAId  = 0 and
   TsC_Cecha7_DeAId  = 0 and
   TsC_Cecha8_DeAId  = 0 and
   TsC_Cecha9_DeAId  = 0 and
   TsC_Cecha10_DeAId  = 0
   end
   delete from #tmpRecordSet1 where TsC_Cecha1_DeAId > 0 and TsC_Cecha1_WarID = 0
   delete from #tmpRecordSet1 where TsC_Cecha2_DeAId > 0 and TsC_Cecha2_WarID = 0
   delete from #tmpRecordSet1 where TsC_Cecha3_DeAId > 0 and TsC_Cecha3_WarID = 0
   delete from #tmpRecordSet1 where TsC_Cecha4_DeAId > 0 and TsC_Cecha4_WarID = 0
   delete from #tmpRecordSet1 where TsC_Cecha5_DeAId > 0 and TsC_Cecha5_WarID = 0
   delete from #tmpRecordSet1 where TsC_Cecha6_DeAId > 0 and TsC_Cecha6_WarID = 0
   delete from #tmpRecordSet1 where TsC_Cecha7_DeAId > 0 and TsC_Cecha7_WarID = 0
   delete from #tmpRecordSet1 where TsC_Cecha8_DeAId > 0 and TsC_Cecha8_WarID = 0
   delete from #tmpRecordSet1 where TsC_Cecha9_DeAId > 0 and TsC_Cecha9_WarID = 0
   delete from #tmpRecordSet1 where TsC_Cecha10_DeAId > 0 and TsC_Cecha10_WarID = 0
SELECT
 Twr_TwrId AS '@TwrID',
 sum(case when ISNULL(A.TwI_Ilosc,-1) - ISNULL(A.TwI_Rezerwacje,-2) < 0 then 0 else ISNULL(A.TwI_Ilosc,0) - ISNULL(A.TwI_Rezerwacje,0) end) AS '@Ilosc',
 (
  select
   TwZ_TwrId as '@TwrID',TwZ_TrSIdDost as '@DostawaID',Ilosc as '@Ilosc',
   TsC_Cecha1_DeAId as  '@C1ID',TsC_Cecha1_WarID as  '@C1Wartosc',
   TsC_Cecha2_DeAId as  '@C2ID',TsC_Cecha2_WarID as  '@C2Wartosc',
   TsC_Cecha3_DeAId as  '@C3ID',TsC_Cecha3_WarID as  '@C3Wartosc',
   TsC_Cecha4_DeAId as  '@C4ID',TsC_Cecha4_WarID as  '@C4Wartosc',
   TsC_Cecha5_DeAId as  '@C5ID',TsC_Cecha5_WarID as  '@C5Wartosc',
   TsC_Cecha6_DeAId as  '@C6ID',TsC_Cecha6_WarID as  '@C6Wartosc',
   TsC_Cecha7_DeAId as  '@C7ID',TsC_Cecha7_WarID as  '@C7Wartosc',
   TsC_Cecha8_DeAId as  '@C8ID',TsC_Cecha8_WarID as  '@C8Wartosc',
   TsC_Cecha9_DeAId as  '@C9ID',TsC_Cecha9_WarID as  '@C9Wartosc',
   TsC_Cecha10_DeAId as  '@C10ID',TsC_Cecha10_WarID as  '@C10Wartosc'
  from cdn.TwrZasoby
    join cdn.TraSElem on TrS_TrSID = TwZ_TrSIdDost
    join #tmpRecordSet1 on TrS_TrSID = TsC_TrSID
  where TwZ_TwrId = Twr_TwrId
   and TwZ_MagId in(select ESM_Magid from cdn.esklepmagazyny WHERE ESM_ESSId = @ESSID)
   and TwZ_Data <= GETDATE()
  FOR XML PATH('ZSC'), ROOT('ZSBC'),TYPE
 )
FROM
 Cdn.towary
 LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
 LEFT JOIN
 (
  SELECT
   TwI_TwrId,
   TwI_Ilosc,
   TwI_Rezerwacje,
   ROW_NUMBER () OVER (PARTITION BY TwI_TwrId, TwI_MagId ORDER BY TwI_Data DESC) rn
 FROM CDN.TwrIlosci
 WHERE TwI_Data <= @DataDzisPobierzZasoby
   AND TwI_MagId IN (select ESM_Magid from cdn.esklepmagazyny WHERE ESM_ESSId = @ESSID)
 ) A ON A.TwI_TwrId = Twr_TwrId AND A.rn = 1
WHERE
 Twes_Udostepnij = 1  AND Twr_NieAktywny = 0
group by Twr_TwrId
FOR XML PATH('ZSB'), ROOT ('ZSBI')
