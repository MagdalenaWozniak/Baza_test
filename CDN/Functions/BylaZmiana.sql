create function cdn.BylaZmiana(@PreId int, @prevPreId int)
returns int
as
begin
 declare @BylaZmiana int
 set @BylaZmiana = 0
 select @BylaZmiana = cdn.BylaZmianaPRE(@PreId, @prevPreId)
 if @BylaZmiana = 0
  select @BylaZmiana = cdn.BylaZmianaADR(@PreId, @prevPreId)
 if @BylaZmiana = 0
  select @BylaZmiana = cdn.BylaZmianaHDK(@PreId, @prevPreId)
 if @BylaZmiana = 0
 begin
  select top 1 @BylaZmiana =
   isnull((select 1 from (
    select
     MilitaryBookID = A.PRE_HDKWojNrKsiaz
    from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_PreId = @prevPreId
     where (A.PRE_PreId = @PreId and A.PRE_PreId = @prevPreId)
     or (A.PRE_PreId = @PreId and A.PRE_PreId > @prevPreId and (A.PRE_HDKWojNrKsiaz <> B.PRE_HDKWojNrKsiaz))
   ) as OtherInformations), '')
 end
 return @BylaZmiana
end
