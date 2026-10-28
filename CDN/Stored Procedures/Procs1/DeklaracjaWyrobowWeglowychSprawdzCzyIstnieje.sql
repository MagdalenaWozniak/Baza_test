CREATE PROCEDURE  CDN.DeklaracjaWyrobowWeglowychSprawdzCzyIstnieje
@ROK int,
@miesiac int,
@okres   int,
@ID   int
as
set nocount on
declare
@miesiackwartal int
CREATE TABLE #Miesiace(miesiac int)
insert into #Miesiace select @Miesiac
if @Okres = 1
begin
 if @miesiac in (3,6,9,12)
 begin
  insert into #Miesiace select @Miesiac -1
  insert into #Miesiace select @Miesiac -2
 end
 if @miesiac in (2,5,8,11)
 begin
  insert into #Miesiace select @Miesiac -1
  insert into #Miesiace select @Miesiac +1
 end
 if @miesiac in (1,4,7,10)
 begin
  insert into #Miesiace select @Miesiac +1
  insert into #Miesiace select @Miesiac +2
 end
end
if @miesiac in (3,6,9,12)
 set @miesiackwartal = @miesiac
if @miesiac in (2,5,8,11)
 set @miesiackwartal = @miesiac+1
if @miesiac in (1,4,7,10)
 set @miesiackwartal = @miesiac+2
set nocount off
if @Okres = 1
begin
select * from CDN.DeklNag
 where
 DkN_TypDeklar=401
 and DkN_RokMiesiac in (select (@ROK*100+miesiac) from #Miesiace)
 and DkN_Numer = 0 and DkN_DkNID != @ID
end
else
select DkN_TypDeklar from CDN.DeklNag
where
DkN_TypDeklar=401
and DkN_RokMiesiac in( (@ROK*100+@miesiac) )
 and DkN_Numer = 0 and DkN_DkNID != @ID
 union all
 select DkN_TypDeklar from CDN.DeklNag
 join cdn.DeklElem on  DkE_DkNID = dkn_dknid and DkE_Numer = 3004
where
DkN_TypDeklar=401 and ISNULL(DkE_WartoscL,0) = 1
and DkN_RokMiesiac in( (@ROK*100+@miesiackwartal) )
and DkN_Numer = 0 and DkN_DkNID != @ID
