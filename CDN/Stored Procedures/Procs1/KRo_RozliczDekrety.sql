CREATE    PROCEDURE CDN.KRo_RozliczDekrety
@LockResource int,
@SrcDokID    int,
@SrcDokTyp   int,
@SrcDokStrona int,
@DstDokID    int,
@DstDokTyp   int,
@DstDokStrona int,
@Kwota   decimal(15,2),
@DateType  int,
@ToDay   NVARCHAR(10),
@KompensataId int,
@BRKId   int
AS
 SET NOCOUNT ON
 declare @SrcKRoID  int
 declare @DstKRoID  int
 declare @dtToDay DateTime
 set @dtToDay = convert(DateTime, @ToDay, 120)
 if @SrcDokTyp = 1 -- dekument: Dekret
 begin
  select @SrcKRoID = KRo_KRoID from CDN.KsiRozrachunki where KRo_DeEID = @SrcDokID --and KRo_Strona = @SrcDokStrona
 end
 else
 if @SrcDokTyp = 2 -- dekument: bilans otwarcia
 begin
  select @SrcKRoID = KRo_KRoID from CDN.KsiRozrachunki where KRo_BOEID = @SrcDokID --and KRo_Strona = @SrcDokStrona
 end
 if @DstDokTyp = 1 -- dekument: Dekret
 begin
  select @DstKRoID = KRo_KRoID from CDN.KsiRozrachunki where KRo_DeEID = @DstDokID --and KRo_Strona = @DstDokStrona
 end
 else
 if @DstDokTyp = 2 -- dekument: bilans otwarcia
 begin
  select @DstKRoID = KRo_KRoID from CDN.KsiRozrachunki where KRo_BOEID = @DstDokID --and KRo_Strona = @DstDokStrona
 end
 if @SrcKRoID is not NULL and @DstKRoID is not NULL
 begin
  BEGIN TRANSACTION
  exec CDN.KRo_Rozlicz @LockResource, @SrcKRoID, @DstKRoID, @Kwota, @DateType, @dtToDay, @BRKId
  if @@TranCount<>0 COMMIT
  exec CDN.KRo_AktualizujStatusRozrachunku @SrcDokTyp, @SrcDokID
  exec CDN.KRo_AktualizujStatusRozrachunku @DstDokTyp, @DstDokID
  --if @SrcDokTyp = 1
  --begin
   --update CDN.DekretyElem Set DeE_DokumentId = @SrcKRoID where DeE_DokumentTyp = 44 and DeE_DeEID = @SrcDokID
   --if @KompensataId <> 0 and exists(select * from CDN.DekretyElem where DeE_DokumentTyp = 44 and DeE_DeEID = @SrcDokID)
   -- update CDN.DekretyElem Set DeE_DokumentId = @SrcKRoID where DeE_DokumentTyp = 50 and DeE_DeEID = @KompensataId
  --end
  --if @DstDokTyp = 1
  --begin
   --update CDN.DekretyElem Set DeE_DokumentId = @DstKRoID where DeE_DokumentTyp = 44 and DeE_DeEID = @DstDokID
   --if @KompensataId <> 0 and exists(select * from CDN.DekretyElem where DeE_DokumentTyp = 44 and DeE_DeEID = @DstDokID)
   -- update CDN.DekretyElem Set DeE_DokumentId = @DstKRoID where DeE_DokumentTyp = 50 and DeE_DeEID = @KompensataId
  --end
 end
 else
 begin
  exec CDN.RiseOptimaException 32524
 end
  SET NOCOUNT OFF
