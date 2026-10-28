create function cdn.PlatnosciZFA(@swaluta nvarchar(10) , @id int )
returns nvarchar (200)
as
begin
declare @wynik nvarchar(200)
select
@wynik = isnull (
(SELECT
 convert ( nvarchar(15),SUM(
 case when Rtrim(bzd_waluta)='' then
   convert ( decimal(15,2),(Bzd_KwotaRoz/"Tra"."trn_KursL") * "Tra"."trn_KursM" )
   else Bzd_KwotaRoz end *  BzD_Kierunek
 ) )+';'+
 CDN.fn_Slownie(SUM(
   case when Rtrim(bzd_waluta)='' then
   convert ( decimal(15,2),(Bzd_Kwota/"Tra"."trn_KursL") * "Tra"."trn_KursM" )
   else Bzd_Kwota end *  BzD_Kierunek
  ),@swaluta ,'PL' ) +';'+
 convert ( nvarchar(15),SUM(
   case when Rtrim(bzd_waluta)='' then
   convert ( decimal(15,2),(Bzd_Kwota/"Tra"."trn_KursL") * "Tra"."trn_KursM" )
   else Bzd_Kwota end *  BzD_Kierunek
 ) )
 FROM CDN.BnkZdarzenia
 join cdn.TraNag as Tra on Bzd_DokumentTyp=1 and
 Bzd_DokumentId = Tra.TrN_TrNID
 WHERE
Tra.Trn_TrnID = "TraNag"."TrN_TrNID" )
, '0.0;Zero '+ @swaluta +' 00/100;0.0' )
from cdn.TraNag TraNag where
"TraNag"."TrN_TrNID" = @id
return @wynik
end
