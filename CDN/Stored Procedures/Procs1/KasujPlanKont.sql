Create Procedure CDN.KasujPlanKont
 @TypOperacji Int,
 @OkresObrachunkowyId Int,
 @OperatorId Int
AS
 Set NOCOUNT ON
 Declare @PreviosusOkresObrachunkowy INT
 Declare @SQL nvarchar(1024)
 Declare @DataOd DateTime
 Declare @DataDo DateTime
 set @PreviosusOkresObrachunkowy = NULL
 if IsNull(@OkresObrachunkowyId, 0) = 0
 BEGIN
  exec CDN.RiseOptimaException 32526
  SET NOCOUNT OFF
  RETURN
 END
 if Not Exists(select * from cdn.OkresyObrach where OOb_OObId = @OkresObrachunkowyId)
 BEGIN
  declare @OkresObrachunkowyIdAsString varchar(15) = rtrim(ltrim(str(@OkresObrachunkowyId)));
  exec CDN.RiseOptimaException 32527, 's1', @OkresObrachunkowyIdAsString
  SET NOCOUNT OFF
  RETURN
 END
 if @TypOperacji <= 0 or @TypOperacji > 4
 BEGIN
  exec CDN.RiseOptimaException 32528
  SET NOCOUNT OFF
  RETURN
 END
 if @TypOperacji = 1
 BEGIN
  if not exists( select top 1 previosOObId.* from
      cdn.OkresyObrach currentOOb
      join cdn.OkresyObrach previosOObId on (currentOOb.OOb_OObID = @OkresObrachunkowyId and currentOOb.OOb_DataOtw > previosOObId.OOb_DataOtw)
      order by previosOObId.OOb_DataOtw desc )
  BEGIN
   exec CDN.RiseOptimaException 26107
   SET NOCOUNT OFF
   RETURN
  END
 END
 CREATE TABLE #AccToDelete (
 AccId  INT,
 NumerIdx NVARCHAR(255),
 Numer  NVARCHAR(255),
 Poziom  INT
 )
 CREATE INDEX AccToDelete_Index_AccId ON #AccToDelete(AccId)
 CREATE TABLE #Result (
 AccId  INT,
 NumerIdx NVARCHAR(255),
 Numer  NVARCHAR(255),
 Error  INT,
 ErrorMsg NVARCHAR(1024)
 )
 if @TypOperacji = 1 or @TypOperacji = 3
 BEGIN
  select top 1 @PreviosusOkresObrachunkowy = previosOObId.OOb_OObID from
  cdn.OkresyObrach currentOOb
  join cdn.OkresyObrach previosOObId on (currentOOb.OOb_OObID = @OkresObrachunkowyId and currentOOb.OOb_DataOtw > previosOObId.OOb_DataOtw)
  order by previosOObId.OOb_DataOtw desc
  if @PreviosusOkresObrachunkowy is not NULL
  BEGIN
   select @DataOd = OOb_DataOtw , @DataDo = OOb_DataKoncowa from CDN.OkresyObrach where  OOb_OObId = @PreviosusOkresObrachunkowy
   CREATE TABLE #OiS (
   AccId  INT,
   NumerIdx NVARCHAR(255),
   BoWn  NUMERIC(15,2),
   BoMa  NUMERIC(15,2),
   ObrotyWn NUMERIC(15,2),
   ObrotyMa NUMERIC(15,2),
   ObrotyTotWn NUMERIC(15,2),
   ObrotyTotMa NUMERIC(15,2),
   SaldoWn  NUMERIC(15,2),
   SaldoMa  NUMERIC(15,2),
   PrstSaldoWn NUMERIC(15,2),
   PrstSaldoMa NUMERIC(15,2),
   Numer  NVARCHAR(255),
   Nazwa  NVARCHAR(255),
   Nazwa2  NVARCHAR(255),
   Poziom  INT,
   ParId  INT,
   Analityka INT
   )
   CREATE INDEX OiS_Index_AccId ON #OiS(AccId)
   CREATE INDEX OiS_Index_SaldoWn ON #OiS(AccId)
   CREATE INDEX OiS_Index_SaldoMa ON #OiS(AccId)
   set @SQL = 'Acc_OObId='+cast(@PreviosusOkresObrachunkowy as nvarchar(5))+ ' and 1=1 and 1=1 and 1=1 and 1=1'
   Insert #OiS execute CDN.ObrotySalda @DataOd, @DataDo, 1, @PreviosusOkresObrachunkowy, 0, 0, 0, @SQL, default, 0, default, 0
   insert into #AccToDelete (AccId,  NumerIdx, Numer, Poziom)
   (
   select Distinct ToDelete.Acc_AccId, ToDelete.Acc_NumerIdx, ToDelete.Acc_Numer, ToDelete.Acc_AccId from
   #OiS
   join CDN.Konta as AccSaldo on (AccSaldo.Acc_AccId = AccId)
   join CDN.Konta as ToDelete on (ToDelete.Acc_AccId = AccSaldo.Acc_NextAccId)
   where AccSaldo.Acc_SlownikId is not null and (SaldoWn is NULL and SaldoMa is NULL or SaldoWn = 0 and SaldoMa = 0)
   )
   drop table #OiS
  END
 END
 if @TypOperacji = 2 or @TypOperacji = 3
 BEGIN
  insert into #AccToDelete (AccId,  NumerIdx, Numer, Poziom)
  (
   select Acc_AccId, Acc_NumerIdx, Acc_Numer, Acc_Poziom from CDN.Konta
   where
   Acc_OObId = @OkresObrachunkowyId and Acc_NieAktywne <> 0
  )
 END
 if @TypOperacji = 4
 BEGIN
  insert into #AccToDelete (AccId,  NumerIdx, Numer, Poziom)
  (
   select Acc_AccId, Acc_NumerIdx, Acc_Numer, Acc_Poziom from CDN.Konta
   where
   Acc_OObId = @OkresObrachunkowyId
  )
 END
 Declare @AccId Int, @AccNumerIdx NVARCHAR(255), @AccNumer NVARCHAR(255), @AccPoziom Int, @ErrorMsg NVARCHAR(1024)
 Declare KontaDoUsuniecia Cursor Local Fast_Forward For
 Select distinct AccId,NumerIdx,Numer,Poziom From #AccToDelete left outer join CDN.KontaZakazy on (AcZ_OpeId=@OperatorId and AcZ_AccId = AccId)
 where AcZ_AccId is Null
 order by Poziom desc
 Open KontaDoUsuniecia
 While 1=1
 Begin
  Fetch Next From KontaDoUsuniecia InTo @AccId, @AccNumerIdx, @AccNumer, @AccPoziom
  If @@Fetch_Status<> 0 Break
  BEGIN TRY
   BEGIN TRANSACTION
   delete from CDN.Konta where Acc_AccId = @AccId
   Insert Into #Result (AccId, NumerIdx, Numer, Error, ErrorMsg) Values(@AccId, @AccNumerIdx, @AccNumer, 0, NULL)
   COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
   set @ErrorMsg = SubString(ERROR_MESSAGE(), 0, 1024)
   ROLLBACK TRANSACTION
   Insert Into #Result (AccId, NumerIdx, Numer, Error, ErrorMsg) Values(@AccId, @AccNumerIdx, @AccNumer, 1, @ErrorMsg)
  END CATCH
 End
 Close KontaDoUsuniecia
 Deallocate KontaDoUsuniecia
 select * from #Result order by NumerIdx asc
 drop table #AccToDelete
 drop table #Result
 SET NOCOUNT OFF
