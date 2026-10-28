CREATE PROCEDURE CDN.RozpinanieDokumentow
@TylkoAnulowanie  AS INT,
@TrnID            AS INT,
@TrnRodzaj        AS INT,
@TrnFaId          AS INT
AS
BEGIN
/* @TylkoAnulowanie=0   -  bez anulowania dokumentów, tylko rozpinanie i zmiana rodzaju
   @TylkoAnulowanie=1   -  anulowanie dokumentów i rozpinanie powiązanych
   @TylkoAnulowanie=2   -  O!O anulowanie dokumentów handlowych i magazynowych (O!O)
   @TylkoAnulowanie=4   -  O!O anulowanie tylko FA (PA i WZ zostają)
*/
   IF @TrnFaId = 0
 SET @TrnFaId = CDN.TraNagRelacjeFaId (@TrNId, @TrnRodzaj/1000, 0)
   IF @TrnFaId = 0
 SET @TrnFaId = CDN.TraNagRelacjeFaId (@TrNId, @TrnRodzaj/1000, 1)
 BEGIN TRAN;
 SET NOCOUNT ON;
 DECLARE @IdPow          INT
 DECLARE @RodzajPF       INT
 DECLARE @Wynik          INT
 DECLARE @Err         INT
 DECLARE @IdFZFRR        INT
 DECLARE @RodzajFZFRR    INT
 SET @Err = 0
 IF @TylkoAnulowanie=0 --tylko rozpinanie (kasowanie w buforze)
 BEGIN
  EXEC CDN.RozepnijPowiazaniaPrzedKasowaniem @TrnID, @TrnRodzaj, @TrnFaId
    END -- END  @TylkoAnulowanie=0 --tylko rozpinanie (kasowanie w buforze)
 ELSE
    BEGIN   -- anulowanie
  IF CDN.FzDoFrr(@TrnID, @TrnRodzaj) > 0
  BEGIN
   Exec CDN.AnulowanieFzDoFrr @TylkoAnulowanie, @TrnID, @TrnRodzaj, @TrnFaId
   SET @Err = @@ERROR
   GOTO KONIEC
  END
  ELSE
  BEGIN
   if @TrnRodzaj in (350001,350002,350003)
   begin
    if exists (select TrR_TrNId from cdn.TraNagRelacje where TrR_TrNTyp = 301 and TrR_FaId = @TrnID)
    begin
     select @IdFZFRR = TrR_TrNId,@RodzajFZFRR = trn_rodzaj from cdn.TraNagRelacje join cdn.TraNag on TrN_TrNID = trr_trnid where TrR_TrNTyp = 301 and TrR_FaId = @TrnID
     EXEC CDN.AnulowanieDokumentu @TylkoAnulowanie, @IdFZFRR, @RodzajFZFRR, @TrnFaId
    end
   end
   if exists(select * from cdn.tranag where trn_trnid = @TrnID and trn_korekta = 8)
   begin
    declare @zwrid int,@KursNumer int, @kursl decimal (15,4),@kursm decimal (15,4),@OpeModID int,@DataKur datetime
    select @zwrid = trn_trnid,@KursNumer = TrN_KursNumer, @kursl = trn_kursl,@kursm = trn_kursm,@OpeModID = TrN_OpeModID,@DataKur = TrN_DataKur from cdn.tranag
    where trn_trnid = (select trn_zwrid from cdn.tranag where trn_trnid= @TrnID)
    exec CDN.KorektaKursuWalutKB 1, @zwrid, @KursNumer, @DataKur, @kursl, @kursm, @OpeModID, @TrnID
    SET @Err = @@ERROR
   end
     IF @Err = 0
     begin
      create table #ROZDFA (ROZDTrNId int)
   insert into #ROZDFA(ROZDTrNId)
   select distinct tre_trnid from cdn.traelem
   left join  CDN.TraSElem on Trs_TrEId = tre_treid
   WHERE TRS_TrEIdWydania in (select tre_treid from cdn.traelem WHERE Tre_TrNId = @TrnID)
   EXEC CDN.AnulowanieDokumentu @TylkoAnulowanie, @TrnID, @TrnRodzaj, @TrnFaId
   SET @Err = @@ERROR
   -- ustawiamy status na RO jak trzeba
   DECLARE @ROZDTrNId int
   DECLARE dok CURSOR LOCAL FAST_FORWARD FOR
   select  ROZDTrNId from #ROZDFA
   OPEN dok
   WHILE 1=1
   BEGIN
              FETCH NEXT FROM dok INTO @ROZDTrNId
              IF @@FETCH_STATUS <> 0 BREAK
      EXECUTE cdn.UstawStatusRezerwacji_New @ROZDTrNId,0
            END
   CLOSE dok
   DEALLOCATE dok
     END
     GOTO KONIEC
  END
 END
 KONIEC:
 SET NOCOUNT OFF;
 IF @@TRANCOUNT <> 0
 BEGIN
  IF @Err <> 0
   ROLLBACK TRAN
  ELSE
   COMMIT TRAN
 END
 SELECT 0   -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
 RETURN
END -- end PROCEDURE
