Create View CDN.KontaAnView
As
Select
 Anl.Acc_OObId As Acc_OObId,
 Anl.Acc_AccId As Acc_AccId,
 Syn.Acc_AccId As Acc_ParId,
 (Anl.Acc_Poziom-Syn.Acc_Poziom+1) As Acc_Poziom
From CDN.Konta Anl Join CDN.Konta Syn On Anl.Acc_OObId = Syn.Acc_OObId And (Anl.Acc_NumerIdx = Syn.Acc_NumerIdx Or Anl.Acc_NumerIdx Like Syn.Acc_NumerIdx + '.%')
