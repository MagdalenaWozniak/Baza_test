CREATE FUNCTION CDN.JpkCodesOnVatNag()
RETURNS @Result TABLE( 

    VaNId       int,
	GTU_01 int,
	GTU_02 int,
	GTU_03 int,
	GTU_04 int,
	GTU_05 int,
	GTU_06 int,
	GTU_07 int,
	GTU_08 int,
	GTU_09 int,
	GTU_10 int,
	GTU_11 int,
	GTU_12 int,
	GTU_13 int,
	SW int,
	EE int,
	TP int,
	TT_WNT int,
	TT_D int,
	MR_T int,
	MR_UZ int,
	I_42 int,
	I_63 int,
	B_SPV int,
	B_SPV_DOSTAWA int,
	B_MPV_PROWIZJA int,
	MPP int,
	IMP int,
	RO int,
	WEW int,
	FP int,
	VAT_RR int,
	MK int,
	ZakupVAT_Marza int,
	Uniqueifier INT NOT NULL IDENTITY(1,1),
	PRIMARY KEY (Vanid, ZakupVAT_Marza, RO,  Uniqueifier))

AS
BEGIN
	
	insert into @Result
	select 
	VaN_VaNID, 

	case when GTU_01.VaNId is not null then 1 else 0 end,
	case when GTU_02.VaNId is not null then 1 else 0 end,
	case when GTU_03.VaNId is not null then 1 else 0 end,
	case when GTU_04.VaNId is not null then 1 else 0 end,
	case when GTU_05.VaNId is not null then 1 else 0 end,
	case when GTU_06.VaNId is not null then 1 else 0 end,
	case when GTU_07.VaNId is not null then 1 else 0 end,
	case when GTU_08.VaNId is not null then 1 else 0 end,
	case when GTU_09.VaNId is not null then 1 else 0 end,
	case when GTU_10.VaNId is not null then 1 else 0 end,
	case when GTU_11.VaNId is not null then 1 else 0 end,
	case when GTU_12.VaNId is not null then 1 else 0 end,
	case when GTU_13.VaNId is not null then 1 else 0 end,
	case when SW.VaNId is not null then 1 else 0 end,
	case when EE.VaNId is not null then 1 else 0 end,
	case when TP.VaNId is not null then 1 else 0 end,
	case when TT_WNT.VaNId is not null then 1 else 0 end,
	case when TT_D.VaNId is not null then 1 else 0 end,
	case when MR_T.VaNId is not null then 1 else 0 end,
	case when MR_UZ.VaNId is not null then 1 else 0 end,
	case when I_42.VaNId is not null then 1 else 0 end,
	case when I_63.VaNId is not null then 1 else 0 end,
	case when B_SPV.VaNId is not null then 1 else 0 end,
	case when B_SPV_DOSTAWA.VaNId is not null then 1 else 0 end,
	case when B_MPV_PROWIZJA.VaNId is not null then 1 else 0 end,
	case when MPP.VaNId is not null then 1 else 0 end,
	case when IMP.VaNId is not null then 1 else 0 end,
	case when RO.VaNId is not null then 1 else 0 end,
	case when WEW.VaNId is not null then 1 else 0 end,
	case when FP.VaNId is not null then 1 else 0 end,
	case when VAT_RR.VaNId is not null then 1 else 0 end,
	case when MK.VaNId is not null then 1 else 0 end,
	case when ZakupVAT_Marza.VaNId is not null then 1 else 0 end

	
	from CDN.vatNag 
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_01') GTU_01 on (GTU_01.VaNId = VaN_VaNID)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_02') GTU_02 on (GTU_02.VaNId = VaN_VaNID)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_03') GTU_03 on (GTU_03.VaNId = VaN_VaNID)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_04') GTU_04 on (GTU_04.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_05') GTU_05 on (GTU_05.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_06') GTU_06 on (GTU_06.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_07') GTU_07 on (GTU_07.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_08') GTU_08 on (GTU_08.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_09') GTU_09 on (GTU_09.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_10') GTU_10 on (GTU_10.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_11') GTU_11 on (GTU_11.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_12') GTU_12 on (GTU_12.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('GTU_13') GTU_13 on (GTU_13.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('SW') SW on (SW.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('EE') EE on (EE.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('TP') TP on (TP.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('TT_WNT') TT_WNT on (TT_WNT.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('TT_D') TT_D on (TT_D.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('MR_T') MR_T on (MR_T.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('MR_UZ') MR_UZ on (MR_UZ.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('I_42') I_42 on (I_42.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('I_63') I_63 on (I_63.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('B_SPV') B_SPV on (B_SPV.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('B_SPV_DOSTAWA') B_SPV_DOSTAWA on (B_SPV_DOSTAWA.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('B_MPV_PROWIZJA') B_MPV_PROWIZJA on (B_MPV_PROWIZJA.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('MPP') MPP on (MPP.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('IMP') IMP on (IMP.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('RO') RO on (RO.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('WEW') WEW on (WEW.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('FP') FP on (FP.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('VAT_RR') VAT_RR on (VAT_RR.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('MK') MK on (MK.VaNId = VaN_VaNId)
	left outer join CDN.JpkCodeExistOnVatNag_Tab('ZakupVAT_Marza') ZakupVAT_Marza on (ZakupVAT_Marza.VaNId = VaN_VaNId)
	
	return;
END
