Create view CDN.KnTUpusty as
select  Kpr_KntTyp as KnU_KntTyp,
 Kpr_KntFirma as Knu_KntFirma,
 Kpr_KntNumer as Knu_KntNumer,
 Tpr_Id  as Knu_KntLp, --!!!
 Tpr_TwrTyp as Knu_TwgTyp,
 Tpr_TwrFirma as Knu_TwgFirma,
 Tpr_TwrNumer as Knu_TwgNumer,
 Tpr_TwrLp as Knu_TwgLp,
 Tpr_Wartosc as KnU_Upust,
 '' as KnU_UpustWzor,
 Tpr_Waluta as KnU_Symbol,
 0 as KnU_NrKursu,
 TPR_FlagaNb as KnU_FlagaNB,
 Tpr_Notatki as KnU_Notatki
from cdn.Twrpromocje
join Cdn.PrmKarty on tpr_prmId=Prm_Id
join cdn.KntPromocje on Kpr_PRmId = Prm_Id
where prm_typ=4
