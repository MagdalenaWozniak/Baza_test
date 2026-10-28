create view cdn.SerwisanciView
(SrW_Id, SrW_Typ, SrW_Kod, SrW_Nazwisko, SrW_Imie, SrW_Telefon, SrW_Telefon2)
as
select
  Ope_OpeID,
  8,
  Ope_kod,
  Ope_Nazwisko,
         '',
   '',
         ''
from [SRV1].[CDN_KNF_ONE].cdn.operatorzy
union all
select
  Pod_PodId,
  Pod_PodmiotTyp,
  Pod_Kod,
  Pod_Nazwa1,
  Pod_Nazwa2,
        Pod_Telefon1,
        Pod_Telefon2
from cdn.podmiotyview where pod_podmiottyp IN (3,4)