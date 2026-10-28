create function CDN.ListaPowiazanychPACount  ( @ID int=0 )
returns int
as
begin
declare @wynik int
select @wynik= Count(TrN_TrNID) from cdn.TraNagRelacje join cdn.TraNag on TrR_FaId = TrN_TrNID
where trr_Fatyp=305 and trr_trnid = @ID
 return isnull(@wynik,0)
end
