CREATE PROCEDURE CDN.GrupyKont_KontaDoSynchronizacji @GKNID  INT, @Grupa NVARCHAR(50) = NULL
AS
 SET NOCOUNT ON
 DECLARE @OObId     INT
 if OBJECT_ID('tempdb..#grupy_kont') is not null
  drop table #grupy_kont;
 if OBJECT_ID('tempdb..#grupy_kont_cross') is not null
  drop table #grupy_kont_cross;
 create table #grupy_kont
 (
  AccNumerGrupa  nvarchar(50) not null,
  AccAnalitykaGrupa nvarchar(50) not null
 );
 CREATE NONCLUSTERED INDEX grupy_kont_index ON #grupy_kont
 (
  AccNumerGrupa ASC,
  AccAnalitykaGrupa ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY];
 create table #grupy_kont_cross
 (
  AccWzorzec  nvarchar(50) not null,
  AccNumer  nvarchar(50) not null
 );
 CREATE NONCLUSTERED INDEX grupy_kont_cross_index ON #grupy_kont_cross
 (
  AccNumer ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY];
 if Exists(
  select * from
  CDN.GrupyKontElem
  join CDN.Konta A on (A.Acc_AccId = GKE_AccId)
  join CDN.Konta B on (A.Acc_OObId = B.Acc_OObId and B.Acc_NumerIdx like A.Acc_NumerIdx + '.%' )
  where
  GKE_GKNID = @GKNID
  and A.Acc_NumerIdx = @Grupa
 )
 begin
  select Top 1 @OObId = Acc_OObId from CDN.GrupyKontElem join CDN.Konta on (Acc_AccId = GKE_AccId)
  where GKE_GKNID = @GKNID
  insert #grupy_kont
  select G.Acc_NumerIdx as AccNumerGrupa,
    SUBSTRING(A.Acc_NumerIdx, len(G.Acc_NumerIdx)+2, len(A.Acc_NumerIdx)) as AccAnalitykaGrupa
  from
  CDN.GrupyKontElem join CDN.Konta as G on (G.Acc_AccId = GKE_AccId)
  left outer join CDN.Konta A on (A.Acc_OObId = G.Acc_OObId and A.Acc_NumerIdx like G.Acc_NumerIdx+'.%' or A.Acc_NumerIdx = G.Acc_NumerIdx)
  where
  --G.Acc_NumerIdx <> A.Acc_NumerIdx
  --and
  GKE_GKNID = @GKNID
  order by A.Acc_NumerIdx asc;
  if (IsNull(@Grupa, '') = '')
  begin
   insert into #grupy_kont_cross
   select distinct A.AccNumerGrupa + '.' + A.AccAnalitykaGrupa as AccWzorzec, B.AccNumerGrupa + '.' + A.AccAnalitykaGrupa as AccNumer
   from #grupy_kont A cross join #grupy_kont B
   where IsNull(A.AccAnalitykaGrupa, '')<>'' and A.AccNumerGrupa <> B.AccNumerGrupa;
  end
  else
  begin
   insert into #grupy_kont_cross
   select distinct A.AccNumerGrupa + '.' + A.AccAnalitykaGrupa as AccWzorzec, B.AccNumerGrupa + '.' + A.AccAnalitykaGrupa as AccNumer
   from #grupy_kont A cross join #grupy_kont B
   where A.AccNumerGrupa = @Grupa and IsNull(A.AccAnalitykaGrupa, '')<>'' and A.AccNumerGrupa <> B.AccNumerGrupa;
  end
 end
 drop table #grupy_kont;
 --drop table #grupy_kont_cross;
 SET NOCOUNT OFF
 select AccWzorzec, AccNumer from #grupy_kont_cross
 left outer join CDN.Konta on (Acc_OObId = @OObId and AccNumer = Acc_NumerIdx)
 where Acc_AccId is Null
 order by AccNumer asc
