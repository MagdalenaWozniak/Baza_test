create function CDN.ListaPowiazanychPA  ( @ID int=0 )
returns varchar(2000)
as
begin
declare @wynik varchar(1000),@nrdok varchar(30)
set @wynik = ''
Declare paragony Cursor Local Fast_Forward For
select TrN_NumerPelny from cdn.TraNagRelacje join cdn.TraNag on TrR_FaId = TrN_TrNID
where trr_Fatyp=305 and trr_trnid = @ID
Open paragony
while 1=1
begin
 Fetch Next From paragony InTo @nrdok
    If @@Fetch_Status <> 0 Break
    if @wynik='' set @wynik = @nrdok
    else
     set @wynik =  @wynik + ', '+ @nrdok
end
 close paragony
 deallocate paragony
 return @wynik
end
