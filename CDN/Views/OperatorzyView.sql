create view cdn.OperatorzyView
(OPE_OpeID, OPE_Kod, OPE_Nazwisko)
as
select
  Ope_OpeID,
  Ope_Kod,
  Ope_Nazwisko
from [SRV1].[CDN_KNF_ONE].cdn.operatorzy