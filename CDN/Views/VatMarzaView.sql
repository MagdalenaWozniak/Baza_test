create view cdn.VatMarzaView
as
select
Van_VaNID as VMP_VaNID,
VaN_VanOrgID as VMP_VanOrgID,
Vat_VatID as VMP_VatID,
case when VaN_VanOrgID is null then VaN_VaNID else VaN_VanOrgID end as VMP_MrzaGrupa,
case when VaN_VanOrgID is null and not (VaT_Stawka =0 and VaT_Flaga = 4) then VaT_NettoDoVAT else null end as VMP_NettoInne,
case when VaN_VanOrgID is null and not (VaT_Stawka =0 and VaT_Flaga = 4) then VaT_VATDoVAT else null end as VMP_VatInne,
case when VaN_VanOrgID is null and not (VaT_Stawka =0 and VaT_Flaga = 4) then VaT_Stawka else null end as VMP_StawkaInne,
case when VaN_VanOrgID is null and not (VaT_Stawka =0 and VaT_Flaga = 4) then VaT_Flaga else null end as VMP_FlagaInne,
case when VaN_VanOrgID is null and not (VaT_Stawka =0 and VaT_Flaga = 4) then null else VaT_NettoDoVAT end as VMP_NettoMarza,
case when VaN_VanOrgID is null and not (VaT_Stawka =0 and VaT_Flaga = 4) then null else VaT_VATDoVAT end as VMP_VatMarza,
case when VaN_VanOrgID is null and not (VaT_Stawka =0 and VaT_Flaga = 4) then null else VaT_Stawka end as VMP_StawkaMarza,
case when VaN_VanOrgID is null and not (VaT_Stawka =0 and VaT_Flaga = 4) then null else VaT_Flaga end as VMP_FlagaMarza
from cdn.VatNag join CDN.VatTab on Vat_VaNID = VaN_VaNID
