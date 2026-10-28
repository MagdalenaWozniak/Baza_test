create view cdn.DokDefinicjeView
(DDfV_DDfID, DDfV_Klasa, DDfV_Symbol, DDfV_Nazwa, DDfV_Nieaktywna, DDfV_Numeracja,
DDfV_SeriaOperatora, DDfV_KierunekOrg, DDfV_TS_Export, DDfV_ImportAppId, DDfV_ImportRowId,
DDfV_OpeZalID, DDfV_StaZalId, DDfV_TS_Zal, DDfV_OpeModID, DDfV_StaModId, DDfV_TS_Mod)
AS
SELECT
DDf_DDfID, DDf_Klasa, DDf_Symbol, DDf_Nazwa, DDf_Nieaktywna, DDf_Numeracja,
DDf_SeriaOperatora, DDf_KierunekOrg, DDf_TS_Export, DDf_ImportAppId, DDf_ImportRowId,
DDf_OpeZalID, DDf_StaZalId, DDf_TS_Zal, DDf_OpeModID, DDf_StaModId, DDf_TS_Mod
from cdn.DokDefinicje
UNION ALL
SELECT
DDf_DDfID, DDf_Klasa, DDf_Symbol, DDf_Nazwa, DDf_Nieaktywna, DDf_Numeracja,
DDf_SeriaOperatora, DDf_KierunekOrg, DDf_TS_Export, DDf_ImportAppId, DDf_ImportRowId,
DDf_OpeZalID, DDf_StaZalId, DDf_TS_Zal, DDf_OpeModID, DDf_StaModId, DDf_TS_Mod
from [SRV1].[CDN_KNF_ONE].cdn.DokDefinicje