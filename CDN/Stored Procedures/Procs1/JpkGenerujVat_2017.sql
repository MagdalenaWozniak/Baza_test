CREATE PROCEDURE CDN.JpkGenerujVat_2017
@JpkNagId int,
@JpkTyp int,
@ZakresDat tinyint,
@DataOd DateTime, 
@DataDo DateTime, 
@Waluta varchar(3),
@UwzglednijStawke_0 int,
@RozliczacVatNaliczonyBezSprzedazy int,
@UwzgledniacSprzedazNiePodlegajacaVat int,
@Wspolczynnik decimal(7,4),
@result int OUTPUT
AS

	declare @REJESTR_ZAKUPOW	int = 1;
	declare @REJESTR_SPRZEDAZY	int = 2;
	
	insert into CDN.JpkVAT (
		JpNId,
		VaNId,
		Typ,
		VatZd, 
		RokMiesiac,
		Lp,
		DataZakupu,
		DataSprzedazy,
		DataWystawienia,
		DataWplywu,
		Dokument,
		NIP,
		Kontrahent,
		Adres,

		K_10,K_11,K_12,K_13,K_14,K_15,K_16,K_17,K_18,K_19,K_20,K_21,K_22,K_23,K_24,K_25,K_26,K_27,K_28,K_29,K_30,K_31,K_32,K_33,K_34,K_35,K_36,K_37,K_38,K_39,
		K_43,K_44,K_45,K_46,K_47,K_48,K_49, K_50

	)
	select @JpkNagId, V.VaN_VaNId, V.VaN_Typ, 0, V7.Va7_RokMiesiac,
	0 as Lp,

	convert(Date,V.VaN_DataWys), 
	convert(Date,V.VaN_DataOpe), 
	convert(Date,V.VaN_DataWys), 
	convert(Date,V.VaN_DataZap), 

	V.VaN_Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)),

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3), 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta),


	SprzedazZwolniona, --10
	TowaryUslugiPozaKrajem,		--11
	TowaryUslugiPozaKrajemA,	--12
	SprzedazNetto0,				--13
	SprzedazNetto0_art129,		--14
	SprzedazNetto3,				--15
	SprzedazVat3,
	SprzedazNetto7,
	SprzedazVat7,
	SprzedazNetto22,
	SprzedazVat22,
	SprzedazWewnatrzWsp,
	SprzedazNettoExport0,
	ZakupyWewnatrzWspNetto,
	ZakupyWewnatrzWspVat,
	ImportTowarowArt33aNetto,
	ImportTowarowArt33aVAT,
	ImportUslugNetto,
	ImportUslugVat,
	ImportUslugNettoA,
	ImportUslugVatA,				--30
	DostawaKrajPlatnikNetto,		--31
	DostawaKrajPodatnikNabywcaNetto,--32
	DostawaKrajPodatnikNabywcaVat,	--33
	DostawaUslugPodatnikNabywcaNetto,--34
	DostawaUslugPodatnikNabywcaVat,	--35
	--SpisZNaturyVat,			36
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'PODATEK OD SPISU'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'PODATEK OD SPISU')) end,
	--ZwrotKwotyNazakupKas		37,	
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'ZWROT ZA KASĘ FISKAL'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'ZWROT ZA KASĘ FISKAL')) end,
	
	-- 38,
	WWNabycieSrTranspVat,	
	-- 39
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'WEWN.NAB.PALIW SILN.'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'WEWN.NAB.PALIW SILN.')) end,
	
	ZakupyTrwaleNetto,		-- 43
	ZakupyTrwaleVat,		-- 44
	ZakupyInneNetto,		-- 45
	ZakupyInneVat,			-- 46
	--47
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'KOREKTA ŚR. TRWAŁYCH'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'KOREKTA ŚR. TRWAŁYCH')) end,
	--48
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'KOREKTA POZ. NABYĆ'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'KOREKTA POZ. NABYĆ')) end,
	--49
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'VAT-ZD ZAKUP NIEZAPŁ'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'VAT-ZD ZAKUP NIEZAPŁ')) end,
	--50
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'VAT-ZD ZAKUP ZAPŁAC.'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'VAT-ZD ZAKUP ZAPŁAC.')) end

	from CDN.RejestrVat_DeklaracjaVAT7_OdDo(@DataOd, @DataDo ,0, @REJESTR_ZAKUPOW,0,@UwzgledniacSprzedazNiePodlegajacaVat, @UwzglednijStawke_0, 1, @Wspolczynnik) V7 join Cdn.VatNag V on (V.VaN_VaNId = V7.VaN_VaNId)
	where V7.VatZD = 0
	

	union All

	select @JpkNagId, V.VaN_VaNId, V.VaN_Typ, 0, V7.Va7_RokMiesiac,	
	0 as Lp,

	convert(Date,V.VaN_DataWys), 
	convert(Date,V.VaN_DataOpe), 
	convert(Date,V.VaN_DataWys), 
	convert(Date,V.VaN_DataZap), 
	
	V.VaN_Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)),

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP, 	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3), 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta),

	SprzedazZwolniona, --10
	TowaryUslugiPozaKrajem, 
	TowaryUslugiPozaKrajemA,
	SprzedazNetto0,
	SprzedazNetto0_art129,
	SprzedazNetto3,
	SprzedazVat3,
	SprzedazNetto7,
	SprzedazVat7,
	SprzedazNetto22,
	SprzedazVat22,
	SprzedazWewnatrzWsp,
	SprzedazNettoExport0,
	ZakupyWewnatrzWspNetto,
	ZakupyWewnatrzWspVat,
	ImportTowarowArt33aNetto,
	ImportTowarowArt33aVAT,
	ImportUslugNetto,
	ImportUslugVat,
	ImportUslugNettoA,
	ImportUslugVatA,
	DostawaKrajPlatnikNetto,
	DostawaKrajPodatnikNabywcaNetto,
	DostawaKrajPodatnikNabywcaVat,
	DostawaUslugPodatnikNabywcaNetto,
	DostawaUslugPodatnikNabywcaVat,
	--SpisZNaturyVat,			36
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'PODATEK OD SPISU'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'PODATEK OD SPISU')) end,
	--ZwrotKwotyNazakupKas		37,	
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'ZWROT ZA KASĘ FISKAL'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'ZWROT ZA KASĘ FISKAL')) end,
	
	-- WWNabycieSrTranspVat,	 38
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'WEWN.NABYCIE ŚR.TRAN'), '') = '' then WWNabycieSrTranspVat else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'WEWN.NABYCIE ŚR.TRAN')) end,
	-- 39
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'WEWN.NAB.PALIW SILN.'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'WEWN.NAB.PALIW SILN.')) end,
	--43
	ZakupyTrwaleNetto,
	--44
	ZakupyTrwaleVat,
	--45
	ZakupyInneNetto,
	--46
	ZakupyInneVat,
	--47
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'KOREKTA ŚR. TRWAŁYCH'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'KOREKTA ŚR. TRWAŁYCH')) end,
	--48
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'KOREKTA POZ. NABYĆ'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'KOREKTA POZ. NABYĆ')) end,
	--49
	0, --CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId_2017(V.VaN_VaNId, @Wspolczynnik, 1)
	--50
	0  --CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId_2017(V.VaN_VaNId, @Wspolczynnik, 2)

	from CDN.RejestrVat_DeklaracjaVAT7_OdDo(@DataOd, @DataDo ,0, @REJESTR_SPRZEDAZY,0, @UwzgledniacSprzedazNiePodlegajacaVat, @UwzglednijStawke_0, 1, @Wspolczynnik) V7 join Cdn.VatNag V on (V.VaN_VaNId = V7.VaN_VaNId)
	

	-- dodanie faktur z atrybutami
	declare @rmOd int = 100 * year(@DataOd) + month(@DataOd);
	declare @rmDo int = 100 * year(@DataDo) + month(@DataDo);
	
	insert into CDN.JpkVAT (
		JpNId,
		VaNId,
		Typ,
		VatZd,
		RokMiesiac,
		Lp,
		DataZakupu,
		DataSprzedazy,
		DataWystawienia,
		DataWplywu,
		Dokument,
		NIP,
		Kontrahent,
		Adres,
		-- 15..20(6)
		K_15,K_16,K_17,K_18,K_19,K_20,
		-- 23..30(8)
		K_23,K_24,K_25,K_26,K_27,K_28,K_29,K_30,
		-- 32..35(4)
		K_32,K_33,K_34,K_35,
		K_36, K_37, K_38, K_39, 
		K_43, K_44, K_45, K_46, K_47, K_48, K_49, K_50
	)
	select VA.JpNId,VA.VaNId,VA.Typ,VA.VatZd,VA.RokMiesiac,VA.Lp,VA.DataZakupu,VA.DataSprzedazy,VA.DataWystawienia,VA.DataWplywu,VA.Dokument,VA.NIP,VA.Kontrahent,VA.Adres,
	0,0,0,0,0,0,	-- 15..20(6)
	0,0,0,0,0,0,0,0,-- 23..30(8)
	0,0,0,0,-- 32..35(4)
	--36 spisZNaturyVat:
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'PODATEK OD SPISU'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'PODATEK OD SPISU')) end,

	--37 zwrotKwotyNazakupKas
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'ZWROT ZA KASĘ FISKAL'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'ZWROT ZA KASĘ FISKAL')) end,

	--38
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'WEWN.NABYCIE ŚR.TRAN'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'WEWN.NABYCIE ŚR.TRAN')) end,
	--39
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'WEWN.NAB.PALIW SILN.'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'WEWN.NAB.PALIW SILN.')) end,

	0,	-- 43
	0,	-- 44
	0,	-- 45
	0,	-- 46

	--47 ZakupyInneVat
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'KOREKTA ŚR. TRWAŁYCH'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'KOREKTA ŚR. TRWAŁYCH')) end,

	--48 KorektaTrwaleVat
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'KOREKTA POZ. NABYĆ'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'KOREKTA POZ. NABYĆ')) end,

	--49
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'VAT-ZD ZAKUP NIEZAPŁ'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'VAT-ZD ZAKUP NIEZAPŁ')) end,
	--50
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'VAT-ZD ZAKUP ZAPŁAC.'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'VAT-ZD ZAKUP ZAPŁAC.')) end


	from (
	select 
	@JpkNagId as JpNId, 
	V.VaN_VaNId as VaNId, 
	V.VaN_Typ as Typ, 
	0 as VatZd, 
	V.VaN_DeklRokMies as RokMiesiac,
	0 as Lp, 

	convert(Date,V.VaN_DataWys) as DataZakupu, 
	convert(Date,V.VaN_DataOpe) as DataSprzedazy, 
	convert(Date,V.VaN_DataWys) as DataWystawienia, 
	convert(Date,V.VaN_DataZap) as DataWplywu, 

	V.VaN_Dokument as Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)) as Dokument,

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres
	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'KOREKTA ŚR. TRWAŁYCH'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo
	
	union
	select 
	@JpkNagId as JpNId, 
	V.VaN_VaNId as VaNId, 
	V.VaN_Typ as Typ, 
	0 as VatZd, 
	V.VaN_DeklRokMies as RokMiesiac,
	0 as Lp, 

	convert(Date,V.VaN_DataWys) as DataZakupu, 
	convert(Date,V.VaN_DataOpe) as DataSprzedazy, 
	convert(Date,V.VaN_DataWys) as DataWystawienia, 
	convert(Date,V.VaN_DataZap) as DataWplywu, 

	V.VaN_Dokument as Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)) as Dokument,

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres
	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'KOREKTA POZ. NABYĆ'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo

	union
	select 
	@JpkNagId as JpNId, 
	V.VaN_VaNId as VaNId, 
	V.VaN_Typ as Typ, 
	0 as VatZd, 
	V.VaN_DeklRokMies as RokMiesiac,
	0 as Lp, 

	convert(Date,V.VaN_DataWys) as DataZakupu, 
	convert(Date,V.VaN_DataOpe) as DataSprzedazy, 
	convert(Date,V.VaN_DataWys) as DataWystawienia, 
	convert(Date,V.VaN_DataZap) as DataWplywu, 

	V.VaN_Dokument as Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)) as Dokument,

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres
	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'PODATEK OD SPISU'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo

	union
	select 
	@JpkNagId as JpNId, 
	V.VaN_VaNId as VaNId, 
	V.VaN_Typ as Typ, 
	0 as VatZd, 
	V.VaN_DeklRokMies as RokMiesiac,
	0 as Lp, 

	convert(Date,V.VaN_DataWys) as DataZakupu, 
	convert(Date,V.VaN_DataOpe) as DataSprzedazy, 
	convert(Date,V.VaN_DataWys) as DataWystawienia, 
	convert(Date,V.VaN_DataZap) as DataWplywu, 

	V.VaN_Dokument as Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)) as Dokument,

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres
	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'ZWROT ZA KASĘ FISKAL'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo

	union
	select 
	@JpkNagId as JpNId, 
	V.VaN_VaNId as VaNId, 
	V.VaN_Typ as Typ, 
	0 as VatZd, 
	V.VaN_DeklRokMies as RokMiesiac,
	0 as Lp, 

	convert(Date,V.VaN_DataWys) as DataZakupu, 
	convert(Date,V.VaN_DataOpe) as DataSprzedazy, 
	convert(Date,V.VaN_DataWys) as DataWystawienia, 
	convert(Date,V.VaN_DataZap) as DataWplywu, 

	V.VaN_Dokument as Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)) as Dokument,

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres
	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'WEWN.NAB.PALIW SILN.'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo


	union
	select 
	@JpkNagId as JpNId, 
	V.VaN_VaNId as VaNId, 
	V.VaN_Typ as Typ, 
	0 as VatZd, 
	V.VaN_DeklRokMies as RokMiesiac,
	0 as Lp, 

	convert(Date,V.VaN_DataWys) as DataZakupu, 
	convert(Date,V.VaN_DataOpe) as DataSprzedazy, 
	convert(Date,V.VaN_DataWys) as DataWystawienia, 
	convert(Date,V.VaN_DataZap) as DataWplywu, 

	V.VaN_Dokument as Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)) as Dokument,

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres
	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'WEWN.NABYCIE ŚR.TRAN'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo

	union
	select 
	@JpkNagId as JpNId, 
	V.VaN_VaNId as VaNId, 
	V.VaN_Typ as Typ, 
	0 as VatZd, 
	V.VaN_DeklRokMies as RokMiesiac,
	0 as Lp, 

	convert(Date,V.VaN_DataWys) as DataZakupu, 
	convert(Date,V.VaN_DataOpe) as DataSprzedazy, 
	convert(Date,V.VaN_DataWys) as DataWystawienia, 
	convert(Date,V.VaN_DataZap) as DataWplywu, 

	V.VaN_Dokument as Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)) as Dokument,

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres
	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'VAT-ZD ZAKUP NIEZAPŁ'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo

	union
	select 
	@JpkNagId as JpNId, 
	V.VaN_VaNId as VaNId, 
	V.VaN_Typ as Typ, 
	0 as VatZd, 
	V.VaN_DeklRokMies as RokMiesiac,
	0 as Lp, 

	convert(Date,V.VaN_DataWys) as DataZakupu, 
	convert(Date,V.VaN_DataOpe) as DataSprzedazy, 
	convert(Date,V.VaN_DataWys) as DataWystawienia, 
	convert(Date,V.VaN_DataZap) as DataWplywu, 

	V.VaN_Dokument as Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)) as Dokument,

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres
	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'VAT-ZD ZAKUP ZAPŁAC.'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo

	) VA left outer join CDN.JpkVat JV on (JV.JpNId = @JpkNagId and VA.VaNId = JV.VaNId) where JV.JpNId is NULL;

	-- VAT ZD
	
	insert into CDN.JpkVAT (
		JpNId,
		VaNId,
		Typ,
		VatZd,
		RokMiesiac,
		Lp,
		DataZakupu,
		DataSprzedazy,
		DataWystawienia,
		DataWplywu,
		Dokument,
		NIP,
		Kontrahent,
		Adres,
		-- 15..20(6)
		K_15,K_16,K_17,K_18,K_19,K_20,
		-- 23..30(8)
		K_23,K_24,K_25,K_26,K_27,K_28,K_29,K_30,
		-- 32..35(4)
		K_32,K_33,K_34,K_35,
		K_36, K_37, K_39,
		K_43, K_44, K_45, K_46, K_47, K_48, K_49, K_50
	)		
	select 
	VA.JpNId,VA.VaNId,VA.Typ,VA.VatZd,VA.RokMiesiac,VA.Lp,VA.DataZakupu,VA.DataSprzedazy,VA.DataWystawienia,VA.DataWplywu,VA.Dokument,VA.NIP,VA.Kontrahent,VA.Adres,

	0,0,0,0,0,0,	-- 15..20(6)
	0,0,0,0,0,0,0,0,-- 23..30(8)
	0,0,0,0,-- 32..35(4)

	--36 spisZNaturyVat:
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'PODATEK OD SPISU'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'PODATEK OD SPISU')) end,

	--37 zwrotKwotyNazakupKas
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'ZWROT ZA KASĘ FISKAL'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'ZWROT ZA KASĘ FISKAL')) end,
	--39
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'WEWN.NAB.PALIW SILN.'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'WEWN.NAB.PALIW SILN.')) end,
	0, --43
	0, --44
	0, --45
	0, --46
	--47 ZakupyInneVat
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'KOREKTA ŚR. TRWAŁYCH'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'KOREKTA ŚR. TRWAŁYCH')) end,

	--48 KorektaTrwaleVat
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'KOREKTA POZ. NABYĆ'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'KOREKTA POZ. NABYĆ')) end,

	--49 korektaVatZd
	0, --CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId_2017(V.VaN_VaNId, @Wspolczynnik, 1)
	--50
	0  --CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId_2017(V.VaN_VaNId, @Wspolczynnik, 2)
	from 
	(
	select 
	@JpkNagId as JpNId, 
	V.VaN_VaNId as VaNId, 
	V.VaN_Typ as Typ, 
	1 as VatZd, 
	V.VaN_DeklRokMies as RokMiesiac,
	0 as Lp, 

	convert(Date,V.VaN_DataWys) as DataZakupu, 
	convert(Date,V.VaN_DataOpe) as DataSprzedazy, 
	convert(Date,V.VaN_DataWys) as DataWystawienia, 
	convert(Date,V.VaN_DataZap) as DataWplywu, 

	V.VaN_Dokument as Dokument,
	--replace(V.VaN_Dokument, char(31), char(32)) as Dokument,

	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP(V.VaN_KntNipKraj, V.VaN_KntNipE) else 'BRAK' end as NIP,	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres

	from CDN.VatNag V
	join CDN.VATZD_ZapisyKorekcyjne(@DataOd, @DataDo) VZD on V.VaN_VaNID = VZD.VaNId
	) VA left outer join CDN.JpkVat JV on (JV.JpNId = @JpkNagId and VA.VaNId = JV.VaNId) where JV.JpNId is NULL;
	

	update CDN.JpkVat Set VatZd = 1, 
	K_49 = CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId_2017(@DataOd, @DataDo, VaNId, @Wspolczynnik, 1),	
	K_50 = CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId_2017(@DataOd, @DataDo, VaNId, @Wspolczynnik, 2)	
	where JpNId = @JpkNagId and VaNId in (Select VaNId from CDN.VATZD_ZapisyKorekcyjne(@DataOd, @DataDo));
	
	-- usunięcie duplikatów
	
	WITH CTE AS(
	SELECT	RN = ROW_NUMBER() OVER(PARTITION BY VaNID ORDER BY VaNID)
	FROM CDN.JpkVAT where JpNId = @JpkNagId
	)
	DELETE FROM CTE WHERE RN > 1


	if @RozliczacVatNaliczonyBezSprzedazy = 0
	begin
		if not exists(select * FROM CDN.JpkVAT where Typ = 2 and JpNId = @JpkNagId)
			delete from CDN.JpkVAT where JpNId = @JpkNagId;
	end



	-- numery dokumentów
	update cdn.JpkVAT set Dokument = CDN.NumerDokumentuVatDlaJpk(VaNId) where JpNId=@JpkNagId;

	-- nazwa kontrahenta

	update JS set Kontrahent = 'SPRZEDAŻ PARAGONOWA'
	from 
	cdn.jpkvat JS join cdn.vatnag on (van_vanid = JS.vanid)
	where
	van_trnid=-1 and Typ = @REJESTR_SPRZEDAZY and JpNId=@JpkNagId and IsNull(Kontrahent, '') = ''
	
	update JS set Adres = 'SPRZEDAŻ PARAGONOWA'
	from 
	cdn.jpkvat JS join cdn.vatnag on (van_vanid = JS.vanid)
	where
	van_trnid=-1 and Typ = @REJESTR_SPRZEDAZY and JpNId=@JpkNagId and IsNull(Adres, '') = ''


	update cdn.JpkVAT set Kontrahent = 'BRAK'
	where 
	JpNId=@JpkNagId and IsNull(Kontrahent, '') = '';

	-- adres kontrahenta
	update cdn.JpkVAT set Adres = 'BRAK'
	where 
	JpNId=@JpkNagId and IsNull(Adres, '') = '';

	

	select @result = count(*) from  CDN.JpkVat where JpNId = @JpkNagId;

	return
