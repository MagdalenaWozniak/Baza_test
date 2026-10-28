Create view CDN.TwrUpusty as
select  Tpr_TwrTyp as Twu_TwrTyp,
 Tpr_TwrFirma as Twu_TwrFirma,
 Tpr_TwrNumer as Twu_TwrNumer,
 Tpr_TwrLp as Twu_TwrLp,
 Tpr_Prog as Twu_PRog,
 Tpr_Wartosc as TwU_Upust
from cdn.Twrpromocje
join Cdn.PrmKarty on tpr_prmId=Prm_Id
where prm_typ=3
