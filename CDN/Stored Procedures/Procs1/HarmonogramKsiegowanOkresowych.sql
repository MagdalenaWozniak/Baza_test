Create Procedure CDN.HarmonogramKsiegowanOkresowych
 @CurrentDate DateTime,
 @filter   nvarchar(3000)
AS
 Set NOCOUNT ON
 CREATE TABLE #Result (
 TreeKey      INT,
 ParentTreeKey    INT,
 OkNId      INT,
 OkEId      INT,
 OkHId      INT,
 Kategoria     NVARCHAR(255),
 Symbol      NVARCHAR(255),
 Lp       INT,
 KontoWn      NVARCHAR(255),
 KontoMa      NVARCHAR(255),
 Data      DATETIME,
 KwotaCalosc     DECIMAL(15,2),
 KwotaHarmonogramu   DECIMAL(15,2),
 SumaKwotHarmonogramu  DECIMAL(15,2),
 KwotaZaksięgowana   DECIMAL(15,2),
 SumaKwotZaksiegowanych  DECIMAL(15,2),
 DoRozksiegowaniaWgPlanu  DECIMAL(15,2),
 DoRozksiegowania   DECIMAL(15,2),
 Odchylenie     DECIMAL(15,2),
 )
 Insert Into #Result (
  TreeKey,
  ParentTreeKey,
  OkNId,
  OkEId,
  OkHId,
  Kategoria,
  Symbol,
  Lp,
  KontoWn,
  KontoMa,
  Data,
  KwotaCalosc,
  KwotaHarmonogramu,
  SumaKwotHarmonogramu,
  KwotaZaksięgowana,
  SumaKwotZaksiegowanych,
  DoRozksiegowaniaWgPlanu,
  DoRozksiegowania,
  Odchylenie)
 (
  select NULL, OkN_OkNId, OkN_OkNId, OkE_OkEId, OkH_OkHId, OkE_Kategoria, OkN_Symbol, OkE_Lp, OkE_KontoWn, OkE_KontoMa, OkH_Data, OkE_KwotaWartosc, OkH_Kwota,
  CDN.KwotaHarmonogramu(2, OkE_OkEId, OkH_Data) as SumaKwotHarmonogramu,
  CDN.KwotaHarmonogramu(1, OkE_OkEId, OkH_Data) as KwotaZaksięgowana,
  CDN.KwotaHarmonogramu(3, OkE_OkEId, OkH_Data) as SumaKwotZaksiegowanych,
  OkE_KwotaWartosc - CDN.KwotaHarmonogramu(2, OkE_OkEId, OkH_Data) as DoRozksiegowaniaWgPlanu,
  OkE_KwotaWartosc - CDN.KwotaHarmonogramu(3, OkE_OkEId, OkH_Data) as DoRozksiegowania,
  case when (CDN.KwotaHarmonogramu(1, OkE_OkEId, OkH_Data) - OkH_Kwota) <> 0.00 then  (CDN.KwotaHarmonogramu(1, OkE_OkEId, OkH_Data) - OkH_Kwota) else NULL end as Odchylenie
  from CDN.OkresoweElem join CDN.OkresoweNag on (OkE_OkNId = OkN_OkNId) left outer join CDN.OkresoweHarmonogram OH on (OkH_OkEId = OkE_OkEId)
  where OkN_ZakresDat<>0 and OkN_Harmonogram<>0
  --where OkN_ZakresDat<>0 and OkN_Harmonogram<>0 and OkN_DataOd <= @CurrentDate and OkN_DataDo >= @CurrentDate
 )
 Insert Into #Result (
  TreeKey,ParentTreeKey,OkNId,OkEId,OkHId,Symbol,Lp,KontoWn,KontoMa, Data,
  KwotaCalosc,KwotaHarmonogramu,SumaKwotHarmonogramu,KwotaZaksięgowana,SumaKwotZaksiegowanych,DoRozksiegowaniaWgPlanu,DoRozksiegowania,Odchylenie)
 (
  select OkNId, NULL, OkNId, NULL, NULL, Symbol, NULL, NULL, NULL, NULL,
  CDN.KwotaHarmonogramu(5, OkNId, NULL), NULL,NULL, NULL, CDN.KwotaHarmonogramu(6, OkNId, NULL), NULL, CDN.KwotaHarmonogramu(5, OkNId, NULL)-CDN.KwotaHarmonogramu(6, OkNId, NULL), NULL
  from #Result
  group by OkNId, Symbol
 )
 -- generujemy drugi poziom drzewka dla Lp
 declare @maxId   int
 begin
  declare @Parent    int
  declare @OkNId    int
  declare @OkEId    int
  declare @Lp     int
  declare @Kategoria   nvarchar(255)
  declare @Symbol    nvarchar(255)
  declare @KontoWn   nvarchar(255)
  declare @KontoMa   nvarchar(255)
  declare @KwotaCalosc  decimal(15,2)
  declare @Odchylenie   decimal(15,2)
  declare @SumaHarmonogramu decimal(15,2)
  select  @maxId = max(TreeKey) from #Result where TreeKey is not null
  declare idGenerator Cursor Local Fast_Forward For select distinct OkNId, OkEId, Lp, Kategoria, Symbol, KontoWn, KontoMa, KwotaCalosc from #Result where Lp Is Not Null
  Open idGenerator
  While 1=1
  Begin
   Fetch Next From idGenerator InTo @OkNId, @OkEId, @Lp, @Kategoria, @Symbol, @KontoWn, @KontoMa, @KwotaCalosc
   If @@Fetch_Status<> 0 Break
   set @maxId=@maxId + 1
   select @Odchylenie  = sum(Odchylenie)   from #Result where OkNId=@OkNId and Lp = @Lp and Odchylenie is Not NULL
   select @SumaHarmonogramu= sum(KwotaHarmonogramu) from #Result where OkNId=@OkNId and Lp = @Lp and KwotaHarmonogramu is Not NULL
   set @Odchylenie = IsNull(@Odchylenie, 0.00)
   update #Result set ParentTreeKey = @maxId, KontoWn=NULL, KontoMa=NULL where OkNId=@OkNId and Lp = @Lp
   select Top 1 @Parent = TreeKey from #Result where Symbol = @Symbol and Lp Is NULL
   Insert Into #Result (
    TreeKey,ParentTreeKey,OkNId,OkEId,OkHId, Kategoria, Symbol,Lp,KontoWn,KontoMa, Data,
    KwotaCalosc,KwotaHarmonogramu,SumaKwotHarmonogramu,KwotaZaksięgowana,SumaKwotZaksiegowanych,DoRozksiegowaniaWgPlanu,DoRozksiegowania,Odchylenie)
   values (
   @maxId, @Parent, @OkNId, @OkEId, NULL, @Kategoria, @Symbol, @Lp,  @KontoWn, @KontoMa, NULL,
   @KwotaCalosc,
   @SumaHarmonogramu,
   NULL,
   CDN.KwotaHarmonogramu(4, @OkEId, NULL),
   CDN.KwotaHarmonogramu(4, @OkEId, NULL),
   @KwotaCalosc - @SumaHarmonogramu,
   @KwotaCalosc-CDN.KwotaHarmonogramu(4, @OkEId, NULL),
   @Odchylenie
   )
  End
  Close idGenerator
  Deallocate idGenerator
 end
 -- aktualizacja rootów
 Update #Result set KwotaZaksięgowana = (select sum(IsNull(KwotaZaksięgowana, 0.00)) from #Result as R where R.ParentTreeKey=#Result.TreeKey) where #Result.ParentTreeKey Is NULL
 Update #Result set Odchylenie = (select sum(IsNull(Odchylenie, 0.00)) from #Result as R where R.ParentTreeKey=#Result.TreeKey) where #Result.ParentTreeKey Is NULL
 Update #Result set DoRozksiegowaniaWgPlanu = (select sum(DoRozksiegowaniaWgPlanu) from #Result as R where R.DoRozksiegowaniaWgPlanu is not null and R.ParentTreeKey=#Result.TreeKey and (R.KontoWn is not null or R.KontoMa is not null)) where #Result.ParentTreeKey Is NULL
 Update #Result set KwotaHarmonogramu = CDN.KwotaHarmonogramu(5, OkNId, NULL) where #Result.ParentTreeKey Is NULL
 Update #Result set Symbol = ltrim(Str(Lp)) + ' ' + IsNull(Kategoria, '') where ParentTreeKey Is not null
 -- trzeba wygenerować uniqalne id dla TreeKey = null
 begin
  declare @okhId int
  select @maxId = max(TreeKey) from #Result where TreeKey is not null
  declare idGenerator Cursor Local Fast_Forward For Select OkHId From #Result where TreeKey is null
  Open idGenerator
  While 1=1
  Begin
   Fetch Next From idGenerator InTo @okhId
   If @@Fetch_Status<> 0 Break
   set @maxId=@maxId + 1
   update #Result set TreeKey = @maxId, Symbol = Str(Year(Data)) + '-' +case when Month(Data) < 10 then '0'+ltrim(str(Month(Data))) else ltrim(str(Month(Data))) end where OkHId=@okhId
  End
  Close idGenerator
  Deallocate idGenerator
 end
 declare @resultSQL nvarchar(3100)
 set @resultSQL  = 'select * from #Result ' +@filter+ ' order by Symbol, Lp, Data '
 EXECUTE sp_executesql @resultSQL
 drop table #Result
 SET NOCOUNT OFF
