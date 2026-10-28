CREATE PROCEDURE  [CDN].[DeklaracjaWyrobowWeglowych_ZestawienieDokumentow]
 @DkN_DkNID int,
@Okres int=0
as
set nocount on
declare @CzyKorekty int
declare @Miesiac int, @Rok int , @WartoscAkcyzy decimal(15,2), @RokMiesiac varchar(7)
select @Rok     = convert ( int , SUBSTRING( convert ( nvarchar(6),DkN_RokMiesiac), 1,4 ))  ,
       @Miesiac = convert ( int , SUBSTRING( convert ( nvarchar(6),DkN_RokMiesiac), 5,2 )) ,
       @RokMiesiac = SUBSTRING( convert ( nvarchar(6),DkN_RokMiesiac), 1,4 )+'/'+SUBSTRING( convert ( nvarchar(6),DkN_RokMiesiac), 5,2 )
from cdn.DeklNag where dkn_dknid = @DkN_DkNID
CREATE TABLE #Miesiace(miesiac int)
insert into #Miesiace select @Miesiac
if @Okres = 1
begin
 insert into #Miesiace select @Miesiac -1
 insert into #Miesiace select @Miesiac -2
end
select @Rok     = convert ( int , SUBSTRING( convert ( nvarchar(6),DkN_RokMiesiac), 1,4 ))  ,
       @Miesiac = convert ( int , SUBSTRING( convert ( nvarchar(6),DkN_RokMiesiac), 5,2 )) ,
       @RokMiesiac = SUBSTRING( convert ( nvarchar(6),DkN_RokMiesiac), 1,4 )+'/'+SUBSTRING( convert ( nvarchar(6),DkN_RokMiesiac), 5,2 )
from cdn.DeklNag where dkn_dknid = @DkN_DkNID
   set @CzyKorekty =0
select @CzyKorekty=DkE_WartoscL  from cdn.DeklElem where DkE_Numer = 304 and DkE_DkNID = @DkN_DkNID--Korekta
create table #typydanych ( typ int )
insert into #typydanych
select 306  from cdn.DeklElem where DkE_Numer = 300 and DkE_DkNID = @DkN_DkNID and DkE_WartoscL = 1
union
select 304  from cdn.DeklElem where DkE_Numer = 301 and DkE_DkNID = @DkN_DkNID and DkE_WartoscL = 1
union
select 305  from cdn.DeklElem where DkE_Numer = 302 and DkE_DkNID = @DkN_DkNID and DkE_WartoscL = 1
union
select 302  from cdn.DeklElem where DkE_Numer = 303 and DkE_DkNID = @DkN_DkNID and DkE_WartoscL = 1
select @WartoscAkcyzy = convert ( decimal(15,2), DkE_WartoscL ) from cdn.DeklElem
         where DkE_Numer = 200 and DkE_DkNID = @DkN_DkNID
set nocount off
select distinct
 TrN_TrNID,
 TrN_PodNazwa1,TrN_PodNazwa2,TrN_PodNazwa3,
 TrN_NumerPelny,
WartoscNetto= sum(TrE_WartoscNetto),TrN_DataDok,
WartoscAkcyzy= [CDN].[fnTrN_WartoscAkcyzy] ( TrN_TrNID ),
AKCWW_WartoscAkcyzy = @WartoscAkcyzy ,
TrN_Bufor,
RokMiesiac = @RokMiesiac
 from cdn.tranag
 join cdn.TraElem on TrE_TrNId = trn_trnid
 right join cdn.KodyCN on  TrE_KodCN = KCN_Kod
 left join CDN.TraNagRelacje REL2 ON TrN_TrNID = REL2.TrR_FaId AND REL2.TrR_TrNTyp = 305 AND TrN_TypDokumentu = 302
 where TrN_TypDokumentu IN (select typ from #typydanych )
and ((Year(TrN_dataope) = @ROK and MONTH(TrN_dataope) in (select miesiac from #Miesiace) and TrN_TypDokumentu =306) or (Year(TrN_datadok) = @ROK and MONTH(TrN_datadok) in (select miesiac from #Miesiace) and TrN_TypDokumentu != 306))
 and TrN_ZwolnionyZAkcyzy = 0  and TrE_AkcyzaOpal != 0
 and TrN_Korekta IN(0,@CzyKorekty) and trn_bufor != -1 AND REL2.TrR_TrNId is NULL
group by TrN_TrNID,TrN_NumerPelny,TrN_DataDok, TrN_PodNazwa1,TrN_PodNazwa2,TrN_PodNazwa3,TrN_Bufor
drop table #typydanych
