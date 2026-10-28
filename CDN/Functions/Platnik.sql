create function CDN.Platnik (@DokId INT, @Typ INT)
returns varchar(20)
as
begin
declare @Result nvarchar(20)
if @Typ = 2 --rejestr vat
begin
set @Result =
isnull((
select case when count(distinct Pod_Kod) > 1 then '*' else
 (select distinct Pod_Kod from CDN.PodmiotyView join CDN.BnKZdarzenia on Pod_PodmiotTyp = BZd_PodmiotTyp and Pod_PodId = BZd_PodmiotID
   where BZd_DokumentID = VaN_VaNID and BZd_DokumentTyp = 2)
end
from CDN.BnkZdarzenia join CDN.VatNag on BZd_DokumentID = VaN_VaNID and BZd_DokumentTyp = 2
       join CDN.PodmiotyView on Pod_PodmiotTyp = BZd_PodmiotTyp and Pod_PodId = BZd_PodmiotID
group by VaN_VaNID
having VaN_VaNID = @DokId
), '')
end
else if @Typ = 12  --ewidencja dodatkowa
begin
set @Result =
isnull((
select case when count(distinct Pod_Kod) > 1 then '*' else
 (select distinct Pod_Kod from CDN.PodmiotyView join CDN.BnKZdarzenia on Pod_PodmiotTyp = BZd_PodmiotTyp and Pod_PodId = BZd_PodmiotID
   where BZd_DokumentID = EDN_EDNID and BZd_DokumentTyp = 12)
end
from CDN.BnkZdarzenia join CDN.EwidDodNag on BZd_DokumentID = EDN_EDNID and BZd_DokumentTyp = 12
       join CDN.PodmiotyView on Pod_PodmiotTyp = BZd_PodmiotTyp and Pod_PodId = BZd_PodmiotID
group by EDN_EDNID
having EDN_EDNID = @DokId
), '')
end
return @Result
end
