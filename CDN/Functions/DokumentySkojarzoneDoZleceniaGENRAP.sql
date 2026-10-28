CREATE function [CDN].[DokumentySkojarzoneDoZleceniaGENRAP]  ( @ID int=0 )
returns varchar(2000)
as
begin
declare @wynik varchar(1000),@nrdok varchar(30), @crm INT, @srs INT, @obd INT
set @wynik = ''
SET @crm = 700
SET @obd = 750
SET @srs = 900
Declare dokumenty Cursor Local Fast_Forward For
 SELECT TrN_NumerPelny
 From cdn.TraNag left outer join cdn.podmiotyview on trn_podid = pod_podid and trn_podmiottyp = pod_podmiottyp
 Where TrN_TrNId in (SELECT cdn.DokRelacje.DoR_DokumentId FROM cdn.DokRelacje WHERE DoR_ParentTyp=@srs AND DoR_ParentId=@id AND DoR_DokumentTyp <> @crm and DoR_Flaga =255) and TrN_TypDokumentu in (302,305)
Open dokumenty
while 1=1
begin
Fetch Next From dokumenty InTo @nrdok
    If @@Fetch_Status <> 0 Break
    if @wynik='' set @wynik = @nrdok
    else
     set @wynik =  @wynik + ', '+ @nrdok
end
close dokumenty
deallocate dokumenty
return @wynik
end
