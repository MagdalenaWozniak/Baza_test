Create view CDN.BudzetView (
BuV_AccId,
BuV_OObId,
BuV_AccNumer,
BuV_AccNumerIdx,
BuV_AccNazwa,
BuV_PlanKwotaWn,
BuV_PlanKwotaMa,
BuV_RealKwotaWn,
BuV_RealKwotaMa,
BuV_PrzekKwotaWn,
BuV_PrzekKwotaMa )
As
Select Acc_AccId, Acc_OObId, Acc_Numer, Acc_NumerIdx,Acc_Nazwa,
Sum(case Acc_KontrolaBudzetu when 1 then BuE_Kwota else 0 end) as PlanKwotaWn,
Sum(case Acc_KontrolaBudzetu when 2 then BuE_Kwota else 0 end) as PlanKwotaMa,
(case Acc_KontrolaBudzetu when 1 then BuN_Kwota else 0 end) as RealKwotaWn,
(case Acc_KontrolaBudzetu when 2 then BuN_Kwota else 0 end) as RealKwotaMa,
(case Acc_KontrolaBudzetu when 1 then BuN_Kwota else 0 end) - Sum(case Acc_KontrolaBudzetu when 1 then BuE_Kwota else 0 end) as PrzekKwotaWn,
(case Acc_KontrolaBudzetu when 2 then BuN_Kwota else 0 end) - Sum(case Acc_KontrolaBudzetu when 2 then BuE_Kwota else 0 end) as PrzekKwotaMa
From CDN.Konta
join CDN.BudzetNag  on (Acc_AccId = BuN_AccId and Acc_KontrolaBudzetu<>0 and BuN_Korekta<>-1)
join CDN.BudzetElem on (BuN_BuNId = BuE_BuNId)
Group by Acc_AccId, Acc_OObId, Acc_Numer, Acc_NumerIdx,Acc_Nazwa,Acc_KontrolaBudzetu, BuN_Kwota
