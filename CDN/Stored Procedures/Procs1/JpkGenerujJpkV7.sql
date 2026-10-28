CREATE PROCEDURE CDN.JpkGenerujJpkV7
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
@DkNId int,
@pojedynczeParagony int,
@result int OUTPUT
AS

	
	declare @REJESTR_ZAKUPOW	int = 1;
	declare @REJESTR_SPRZEDAZY	int = 2;
	declare @DEKLARACJA			int = 3;

	insert into CDN.JpkV7 (
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
		KodKrajuNadaniaTIN,
		NIP,
		Kontrahent,
		Adres,
		SprzedazVAT_Marza,
		K_10,K_11,K_12,K_13,K_14,K_15,K_16,K_17,K_18,K_19,K_20,K_21,K_22,K_23,K_24,K_25,K_26,K_27,K_28,K_29,K_30,K_31,K_32,K_33,K_34,K_35,K_36,
		K_40,K_41,K_42,K_43,K_44,K_45,K_46, K_47

	)
	select @JpkNagId, V.VaN_VaNId, V.VaN_Typ, 0, V7.Va7_RokMiesiac,
	0 as Lp,

	convert(Date,V.VaN_DataWys), 
	convert(Date,V.VaN_DataOpe), 
	convert(Date,V.VaN_DataWys), 
	convert(Date,V.VaN_DataZap), 

	V.VaN_Dokument,
	V.VaN_KntNipKraj,
	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP('', V.VaN_KntNipE) else 'BRAK' end as NIP,
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3), 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta),

	0,									-- SprzedazVAT_Marza
	SprzedazZwolniona,					--10
	TowaryUslugiPozaKrajem,				--11
	TowaryUslugiPozaKrajemA,			--12
	SprzedazNetto0,						--13
	SprzedazNetto0_art129,				--14
	SprzedazNetto3,						--15
	SprzedazVat3,						--16
	SprzedazNetto7,						--17
	SprzedazVat7,						--18
	SprzedazNetto22,					--19
	SprzedazVat22,						--20
	SprzedazWewnatrzWsp,				--21
	SprzedazNettoExport0,				--22
	ZakupyWewnatrzWspNetto,				--23
	ZakupyWewnatrzWspVat,				--24
	ImportTowarowArt33aNetto,			--25
	ImportTowarowArt33aVAT,				--26
	ImportUslugNetto,					--27
	ImportUslugVat,						--28
	ImportUslugNettoA,					--29
	ImportUslugVatA,					--30
	DostawaKrajPodatnikNabywcaNetto,	--31
	DostawaKrajPodatnikNabywcaVat,		--32
	0, --33
	0, --34
	WWNabycieSrTranspVat,				--35
	0, --36
					
	ZakupyTrwaleNetto,		-- 40
	ZakupyTrwaleVat,		-- 41
	ZakupyInneNetto,		-- 42
	ZakupyInneVat,			-- 43
	
	0,		--44	
	0,		--45	
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'VAT-ZD ZAKUP NIEZAPŁ'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'VAT-ZD ZAKUP NIEZAPŁ')) end,		--46	
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'VAT-ZD ZAKUP ZAPŁAC.'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', V.VaN_VaNId,'VAT-ZD ZAKUP ZAPŁAC.')) end		--47	
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
	V.VaN_KntNipKraj,
	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP('', V.VaN_KntNipE) else 'BRAK' end as NIP, 	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3), 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta),
	 
	CDN.SprzedazVAT_Marza(V.VaN_VaNId), --SprzedazVAT_Marza
	SprzedazZwolniona,					--10
	TowaryUslugiPozaKrajem,				--11
	TowaryUslugiPozaKrajemA,			--12
	SprzedazNetto0,						--13
	SprzedazNetto0_art129,				--14
	SprzedazNetto3,						--15
	SprzedazVat3,						--16
	SprzedazNetto7,						--17
	SprzedazVat7,						--18
	SprzedazNetto22,					--19
	SprzedazVat22,						--20
	SprzedazWewnatrzWsp,				--21
	SprzedazNettoExport0,				--22
	ZakupyWewnatrzWspNetto,				--23
	ZakupyWewnatrzWspVat,				--24
	ImportTowarowArt33aNetto,			--25
	ImportTowarowArt33aVAT,				--26
	ImportUslugNetto,					--27
	ImportUslugVat,						--28
	ImportUslugNettoA,					--29
	ImportUslugVatA,					--30
	DostawaKrajPodatnikNabywcaNetto,	--31
	DostawaKrajPodatnikNabywcaVat,		--32
	0,									--33
	0,									--34
	WWNabycieSrTranspVat,				--35
	0,									--36
	
	ZakupyTrwaleNetto,		-- 40
	ZakupyTrwaleVat,		-- 41
	ZakupyInneNetto,		-- 42
	ZakupyInneVat,			-- 43
	
	0,		--44	
	0,		--45	
	0,		--46	
	0		--47

	from CDN.RejestrVat_DeklaracjaVAT7_OdDo(@DataOd, @DataDo ,0, @REJESTR_SPRZEDAZY,0, @UwzgledniacSprzedazNiePodlegajacaVat, @UwzglednijStawke_0, 1, @Wspolczynnik) V7 join Cdn.VatNag V on (V.VaN_VaNId = V7.VaN_VaNId)
	

	-- dodanie faktur z atrybutami
	declare @rmOd int = 100 * year(@DataOd) + month(@DataOd);
	declare @rmDo int = 100 * year(@DataDo) + month(@DataDo);
	

	
	insert into CDN.JpkV7 (
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
		KodKrajuNadaniaTIN,
		NIP,
		Kontrahent,
		Adres,		
		K_15,K_16,K_17,K_18,K_19,K_20,K_21,K_22,
		K_23,K_24,K_25,K_26,K_27,K_28,K_29,K_30,K_31,K_32,	-- 23..32(10)		
		K_33,K_34,K_35,K_36, 
		K_40, K_41, K_42, K_43, K_44, K_45,
		K_46, K_47
	)
	select VA.JpNId,VA.VaNId,VA.Typ,VA.VatZd,VA.RokMiesiac,VA.Lp,VA.DataZakupu,VA.DataSprzedazy,VA.DataWystawienia,VA.DataWplywu,VA.Dokument,VA.KodKraju, VA.NIP,VA.Kontrahent,VA.Adres,

	0,--15
	0,--16
	0,--17
	0,--18
	0,--19
	0,--20	
	0,--21
	0,--22
	0,--23
	0,--24
	0,--25
	0,--26
	0,--27
	0,--28
	0,--29
	0,--30
	0,--31			
	0,--32	
	0,--33																																																						--35
	0,--34	
	0,--35
	0,--36

	0,		--40
	0,		--41
	0,		--42
	0,		--43	
	0,		--44	
	0,		--45	
	--46, 47
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'VAT-ZD ZAKUP NIEZAPŁ'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'VAT-ZD ZAKUP NIEZAPŁ')) end,	
	case when IsNUll(CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'VAT-ZD ZAKUP ZAPŁAC.'), '') = '' then NULL else convert(decimal(15,2),CDN.WartoscAtrybutuDokumentu('VAT', VA.VaNId,'VAT-ZD ZAKUP ZAPŁAC.')) end

	from (
	select @JpkNagId as JpNId, 
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
	V.VaN_KntNipKraj as KodKraju, 
	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP('', V.VaN_KntNipE) else 'BRAK' end as NIP, 	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres



	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'VAT-ZD ZAKUP NIEZAPŁ'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo

	union
	select @JpkNagId as JpNId, 
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
	V.VaN_KntNipKraj as KodKraju, 
	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP('', V.VaN_KntNipE) else 'BRAK' end as NIP, 	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres


	from CDN.VatNag V
	where IsNuLL(CDN.WartoscAtrybutuDokumentu('VAT', van_vanid,'VAT-ZD ZAKUP ZAPŁAC.'), '') <> ''
	and VaN_DeklRokMies between @rmOd and @rmDo

	) VA left outer join CDN.JpkV7 JV on (JV.JpNId = @JpkNagId and VA.VaNId = JV.VaNId) where JV.JpNId is NULL;


	-- VAT ZD
	
	insert into CDN.JpkV7 (
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
		KodKrajuNadaniaTIN,
		NIP,
		Kontrahent,
		Adres,
		KorektaPodstawyOpodt,
		K_15,K_16,K_17,K_18,K_19,K_20,						-- 15..20(6)		
		K_23,K_24,K_25,K_26,K_27,K_28,K_29,K_30,K_31,K_32,	-- 23..32(10)		
		K_33,K_34,K_35,K_36, 

		K_40, K_41, K_42, K_43, K_44, K_45, K_46, K_47
	)		
	select 
	VA.JpNId,VA.VaNId,VA.Typ,VA.VatZd,VA.RokMiesiac,VA.Lp,VA.DataZakupu,VA.DataSprzedazy,VA.DataWystawienia,VA.DataWplywu,VA.Dokument,VA.KodKraju,VA.NIP,VA.Kontrahent,VA.Adres,
	1, --KorektaPodstawyOpodt
	0,0,0,0,0,0,			-- 15..20(6)
	0,0,0,0,0,0,0,0,0,0,	-- 23..32(10)

	0,			--33
	0,	--34
	0,																																																						--35
	0,	--36

	0,		-- 40
	0,		-- 41
	0,		-- 42
	0,		-- 43
	
	0,		--44	
	0,		--45	
	0,		--46
	0		--47
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
	V.VaN_KntNipKraj as KodKraju,
	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP('', V.VaN_KntNipE) else 'BRAK' end as NIP,	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres

	from CDN.VatNag V
	join CDN.VATZD_ZapisyKorekcyjne(@DataOd, @DataDo) VZD on V.VaN_VaNID = VZD.VaNId
	) VA left outer join CDN.JpkV7 JV on (JV.JpNId = @JpkNagId and VA.VaNId = JV.VaNId) where JV.JpNId is NULL;
	


	update CDN.JpkV7 Set 
	VatZd = 1,
	KorektaPodstawyOpodt = 1,
	K_46 = CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId_2017(@DataOd, @DataDo, VaNId, @Wspolczynnik, 1),	
	K_47 = CDN.VATZD_ZapisKorekcyjnyKwotaVatFromId_2017(@DataOd, @DataDo, VaNId, @Wspolczynnik, 2)	
	where JpNId = @JpkNagId and VaNId in (Select VaNId from CDN.VATZD_ZapisyKorekcyjneEx(@DataOd, @DataDo));
	
	-- usunięcie duplikatów
	
	WITH CTE AS(
	SELECT	RN = ROW_NUMBER() OVER(PARTITION BY VaNID ORDER BY VaNID)
	FROM CDN.JpkV7 where JpNId = @JpkNagId
	)
	DELETE FROM CTE WHERE RN > 1


	if @RozliczacVatNaliczonyBezSprzedazy = 0
	begin
		if not exists(select * FROM CDN.JpkV7 where Typ = 2 and JpNId = @JpkNagId)
			delete from CDN.JpkV7 where JpNId = @JpkNagId;
	end

	-- numery dokumentów

	--update cdn.JpkV7 set Dokument = CDN.NumerDokumentuVatDlaJpk(VaNId) where JpNId=@JpkNagId;


	declare @FullNumebers TABLE (	vanid int,dokument varchar(256),id INT NOT NULL IDENTITY(1,1));
	declare @SingleNumebers TABLE (	vanid int,dokument varchar(256),id INT NOT NULL IDENTITY(1,1));
	

	insert into @SingleNumebers 
	select distinct VaNId, Dokument from (
		
	--1
	Select VaNId, C.VaN_Dokument as Dokument 
	From CDN.JpkV7
	join CDN.VatNag A on (VaNId = A.VaN_VaNID)
	Join CDN.VatNag B On A.VaN_VaNOrgId  = B.VaN_VaNId
	Join CDN.VatNag C On C.VaN_ZbVaNId = B.VaN_VaNId
	Where JpNId = @JpkNagId and C.VaN_Wewnetrzna = 0 and A.VaN_Wewnetrzna <> 0 and A.VaN_Rodzaj<> 8

	--2
	union all 
	Select VaNId, C.VaN_Dokument as Dokument 
	From CDN.JpkV7
	join CDN.VatNag A on (VaNId = A.VaN_VaNID)
	Join CDN.VatNag B On A.VaN_VaNOrgId  = B.VaN_VaNId
	Join CDN.VatNag C On C.VaN_VaNId  = B.VaN_VaNOrgId
	Where JpNId = @JpkNagId and C.VaN_Wewnetrzna = 0 and A.VaN_Wewnetrzna <> 0 and A.VaN_Rodzaj<> 8

	--3
	Union All 
	Select VaNId, A.VaN_Dokument as Dokument 
	From 
	CDN.VatNag A
	join CDN.JpkV7 on (A.VaN_ZbVaNId = VaNId)
	join CDN.VatNag B on (B.VaN_VaNID = VaNId)
	Where JpNId = @JpkNagId and A.VaN_wewnetrzna = 0 and B.VaN_Wewnetrzna <> 0 and B.VaN_Rodzaj<> 8
			
	--4
	Union All 
	select VaNId, A.VaN_Dokument as Dokument 
	from 
	cdn.vatnag A 
	join cdn.vatnag B on (B.VaN_VaNOrgId = A.VaN_VaNId)
	join CDN.JpkV7 on (B.VaN_VaNId = VaNId)
	where JpNId = @JpkNagId and A.VaN_Wewnetrzna = 0 and B.VaN_Wewnetrzna <> 0 and B.VaN_Rodzaj<> 8

	--5
    Union All 
    select VaNId, A.VaN_Dokument as Dokument 
    from cdn.vatnag A 
    join cdn.vatnag B on (B.VaN_VaNOrgId = A.VaN_VaNId)
    join cdn.vatnag C on (C.VaN_VaNOrgId = B.VaN_VaNId)
	join CDN.JpkV7 on (C.VaN_VaNId = VaNId)
    where JpNId = @JpkNagId and A.VaN_Wewnetrzna = 0 and C.VaN_Wewnetrzna <> 0 and C.VaN_Rodzaj<> 8

	--6
	Union All 
	Select VaNId, 
	Case When TrN_NumerObcy <> '' Then TrN_NumerObcy Else TrN_NumerPelny End as Dokument
	From CDN.JpkV7  
	join CDN.TraNag on (TrN_VaNId=VaNId)
	join CDN.VatNag B on (B.VaN_VaNID = VaNId)
	where JpNId = @JpkNagId and B.VaN_Wewnetrzna <> 0 and B.VaN_Rodzaj<> 8
	) D	

	;with cte(vanid,dokument,rn)
	as
	(
	  select vanid, dokument, rn=ROW_NUMBER() over (PARTITION by vanid order by id)
	  from @SingleNumebers
	)
	,cte2(vanid,dokument,rn)
	as
	(
	select vanid, convert(varchar(max),dokument), 1 from cte where rn=1
	union all
	select cte2.vanid, convert(varchar(max),cte2.dokument+', '+cte.dokument), cte2.rn+1
	from cte2
	inner join cte on cte.vanid = cte2.vanid and cte.rn=cte2.rn+1
	)

	insert into @FullNumebers
	select distinct VaNId, Dokument from (

	select vanid, max(dokument) as Dokument from cte2 group by vanid

	union all
	Select VaNId, A.VaN_Dokument as Dokument 
	From CDN.JpkV7
	join CDN.VatNag A on (VaNId = A.VaN_VaNID)
	Where JpNId = @JpkNagId and A.VaN_Wewnetrzna = 0 

	union all
	Select VaNId, A.VaN_Dokument as Dokument 
	From CDN.JpkV7
	join CDN.VatNag A on (VaNId = A.VaN_VaNID)
	Where JpNId = @JpkNagId and A.VaN_Rodzaj = 8
	) d
	option (maxrecursion 0);


	update V7 set V7.Dokument = fn.dokument
	from
	CDN.JpkV7 V7 join @FullNumebers fn on (fn.vanid = V7.VanID)
	where
	JpNId = @JpkNagId

	-- end of numery dokumentow



	--Zakup VAT Marza
	/*
	delete from JS
	from 
	cdn.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid)
	where
	JpNId=@JpkNagId and CDN.JpkCodeExistOnVatNag(van_vanid, 'ZakupVAT_Marza') <> 0
	*/
	delete from JS
	from 
	cdn.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid)
	join CDN.JpkCodesOnVatNag() jc on (VaN_VaNID = jc.VaNId)
	where
	JpNId=@JpkNagId and jc.ZakupVAT_Marza <> 0
	


	insert into CDN.JpkV7 (
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
		KodKrajuNadaniaTIN,
		NIP,
		Kontrahent,
		Adres,		
		K_15,K_16,K_17,K_18,K_19,K_20,K_21,K_22,K_23,K_24,K_25,K_26,K_27,K_28,K_29,K_30,K_31,K_32,K_33,K_34,K_35,K_36, 
		K_40, K_41, K_42, K_43, K_44, K_45,K_46, K_47,
		SprzedazVAT_Marza, ZakupVAT_Marza
	)

	select @JpkNagId as JpNId, 
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
	V.VaN_KntNipKraj as KodKraju, 
	case when IsNull(V.VaN_KntNipE, '') <> '' then CDN.NIP('', V.VaN_KntNipE) else 'BRAK' end as NIP, 	
	CDN.NazwaFirmy(V.VaN_KntNazwa1, V.VaN_KntNazwa2, V.VaN_KntNazwa3) as Kontrahent, 
	CDN.AdresPelny(V.VaN_KntMiasto, V.VaN_KntUlica, V.VaN_KntNrDomu,V.VaN_KntNrLokalu,V.VaN_KntKodPocztowy, V.VaN_KntPoczta) as Adres,

	0,--15
	0,--16
	0,--17
	0,--18
	0,--19
	0,--20	
	0,--21
	0,--22
	0,--23
	0,--24
	0,--25
	0,--26
	0,--27
	0,--28
	0,--29
	0,--30
	0,--31
	0,--32	
	0,--33																																										
	0,--34	
	0,--35
	0,--36
	0,		--40
	0,		--41
	0,		--42
	0,		--43	
	0,		--44	
	0,		--45	
	0,		--46	
	0,		--47
	0,		--SprzedazVAT_Marza
	VaN_RazemBruttoDoVAT
	--from CDN.VatNag V
	from CDN.VatNag V join CDN.JpkCodesOnVatNag() jc on (V.VaN_VaNID = jc.VaNId)
	where 
	VaN_RozliczacVat7 = 1 and VaN_DeklRokMies between @rmOd and @rmDo and jc.ZakupVAT_Marza <> 0

	-- paragony

	insert into CDN.JpkV7 (
	JpNId,
	Typ,
	VatZd, 
	VaNId,
	RokMiesiac,
	Lp,
	TypDokumentu,
	Kontrahent,
	Dokument,
	DataWystawienia,
	DataSprzedazy,
	SprzedazVAT_Marza,
	ZakupVAT_Marza,
	K_10, K_11, K_12, K_13, K_14, 
	K_15,K_16,K_17,K_18,K_19,K_20,K_21,K_22,K_23,K_24,K_25,K_26,K_27,K_28,K_29,K_30,K_31,K_32,K_33,K_34,K_35,K_36, 
	K_40, K_41, K_42, K_43, K_44, K_45, K_46, K_47)
	
	select 
	JpNId,@REJESTR_SPRZEDAZY,0 as VatZd, NULL as VaNId, @rmDo, 0 as LP, 'RO' as TypDokumentu,'Raport okresowy sprzedaży zafiskalizowanej' as Kontrahent,'Detal - dokument zbiorczy sprzedaży' as Dokument,
	@DataDo as DataWystawienia, 
	@DataDo as DataSprzedazy, 
	sum(SprzedazVAT_Marza),sum(ZakupVAT_Marza),
	sum(K_10),sum(K_11),sum(K_12),sum(K_13),sum(K_14),sum(K_15),sum(K_16),sum(K_17),sum(K_18),sum(K_19),sum(K_20),sum(K_21),sum(K_22),sum(K_23),sum(K_24),sum(K_25),sum(K_26),sum(K_27),sum(K_28),sum(K_29),sum(K_30),sum(K_31),sum(K_32),sum(K_33),sum(K_34),sum(K_35),sum(K_36),
	sum(K_40),sum(K_41),sum(K_42),sum(K_43),sum(K_44),sum(K_45),sum(K_46),sum(K_47)
	from 
	(
		-- tak się rozpoznaje pojedyncze paragony, informacja od Jakuba Gnata.
		select JS.* from CDN.JpkV7 JS join CDN.VatNag on (VaNID = VaN_VaNId)
		where JpNId=@JpkNagId and Typ = @REJESTR_SPRZEDAZY and VaN_TrNID = -1 and VaN_Dokument NOT LIKE 'Detal __ z%' and exists (select Trn_VaNId from CDN.TraNag where TrN_VaNId = JS.VaNId and trn_typdokumentu = 305 group by Trn_VaNId having COUNT(Trn_VaNId)=1)
		union all 
		select JS.* from CDN.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid)
		where JpNId=@JpkNagId and VaN_Typ = @REJESTR_SPRZEDAZY and VaN_Rodzaj = 10		
		union all 
		select JS.* from CDN.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid) join CDN.JpkCodesOnVatNag() jc on (VaN_VaNID = jc.VaNId)
		where JpNId=@JpkNagId and van_trnid is NULL and VaN_Typ = @REJESTR_SPRZEDAZY and VaN_Rodzaj = 0 and jc.RO = 1

		/*
		select JS.* from CDN.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid)
		where JpNId=@JpkNagId and van_trnid is NULL and VaN_Typ = @REJESTR_SPRZEDAZY and VaN_Rodzaj = 0 and CDN.JpkCodeExistOnVatNag(van_vanid, 'RO') = 1
		*/
	) j
	group by JpNId

	-- tak się rozpoznaje pojedyncze paragony, informacja od Jakuba Gnata.
	delete from JS from cdn.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid)
	where JpNId=@JpkNagId and Typ = @REJESTR_SPRZEDAZY and VaN_TrNID = -1 and VaN_Dokument NOT LIKE 'Detal __ z%' and exists (select Trn_VaNId from CDN.TraNag where TrN_VaNId = JS.VaNId and trn_typdokumentu = 305 group by Trn_VaNId having COUNT(Trn_VaNId)=1)

	delete from JS from cdn.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid)
	where JpNId=@JpkNagId and Typ = @REJESTR_SPRZEDAZY and VaN_Rodzaj=10
	
	delete from JS from cdn.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid) join CDN.JpkCodesOnVatNag() jc on (VaN_VaNID = jc.VaNId)
	where JpNId=@JpkNagId and van_trnid is NULL and VaN_Typ = @REJESTR_SPRZEDAZY and VaN_Rodzaj = 0 and jc.RO = 1
	/*
	delete from JS from cdn.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid)
	where JpNId=@JpkNagId and van_trnid is NULL and VaN_Typ = @REJESTR_SPRZEDAZY and VaN_Rodzaj = 0 and CDN.JpkCodeExistOnVatNag(van_vanid, 'RO') = 1
	*/
	-- nazwa kontrahenta

	update JS set Kontrahent = 'SPRZEDAŻ PARAGONOWA'
	from 
	cdn.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid)
	where
	van_trnid=-1 and Typ = @REJESTR_SPRZEDAZY and JpNId=@JpkNagId and IsNull(Kontrahent, '') = ''
	
	update JS set Adres = 'SPRZEDAŻ PARAGONOWA'
	from 
	cdn.JpkV7 JS join cdn.vatnag on (van_vanid = JS.vanid)
	where
	van_trnid=-1 and Typ = @REJESTR_SPRZEDAZY and JpNId=@JpkNagId and IsNull(Adres, '') = ''


	declare @dknIdBuffer int = @DkNId;
	if @DkNId = 0
		select @DkNId = DkN_DkNId from CDN.DeklNag  where DkN_TypDeklar=1 and DkN_Finalna=1 and DkN_RokMiesiac = (100 * year(@DataOd) + month(@DataOd)); 
		
	if @DkNId <> 0
	begin

		declare @deklValue decimal = 0;

		select  @deklValue = CDN.KwotaKsiegDekl (@DkNId, 12000) --33
		if @deklValue <> 0
			insert into CDN.JpkV7 (JpNId,DkNId,Typ,VatZd,RokMiesiac,Lp,DataZakupu,DataSprzedazy,DataWystawienia,DataWplywu, Dokument, K_33) 
			values(@JpkNagId, @DkNId, @REJESTR_SPRZEDAZY, 0, 100*year(@DataDo) + month(@DataDo), 0, @DataDo, @DataDo, @DataDo, @DataDo, 'DEKLARACJA_POLE_33', @deklValue)

		select  @deklValue = CDN.KwotaKsiegDekl (@DkNId, 12005) --34
		if @deklValue <> 0
			insert into CDN.JpkV7 (JpNId,DkNId,Typ,VatZd,RokMiesiac,Lp,DataZakupu,DataSprzedazy,DataWystawienia,DataWplywu, Dokument, K_34) 
			values(@JpkNagId, @DkNId, @REJESTR_SPRZEDAZY, 0, 100*year(@DataDo) + month(@DataDo), 0, @DataDo, @DataDo, @DataDo, @DataDo, 'DEKLARACJA_POLE_34', @deklValue)

		select  @deklValue = CDN.KwotaKsiegDekl (@DkNId, 12011) --36
		if @deklValue <> 0
			insert into CDN.JpkV7 (JpNId,DkNId,Typ,VatZd,RokMiesiac,Lp,DataZakupu,DataSprzedazy,DataWystawienia,DataWplywu, Dokument, K_36) 
			values(@JpkNagId, @DkNId, @REJESTR_SPRZEDAZY, 0, 100*year(@DataDo) + month(@DataDo), 0, @DataDo, @DataDo, @DataDo, @DataDo, 'DEKLARACJA_POLE_36', @deklValue)

		select  @deklValue = CDN.KwotaKsiegDekl (@DkNId, 12470) --44
		if @deklValue <> 0
			insert into CDN.JpkV7 (JpNId,DkNId,Typ,VatZd,RokMiesiac,Lp,DataZakupu,DataSprzedazy,DataWystawienia,DataWplywu, Dokument, DokumentZakupu, K_44) 
			values(@JpkNagId, @DkNId, @REJESTR_ZAKUPOW, 0, 100*year(@DataDo) + month(@DataDo), 0, @DataDo, @DataDo, @DataDo, @DataDo, 'DEKLARACJA_POLE_44', 'WEW', @deklValue)

		select  @deklValue = CDN.KwotaKsiegDekl (@DkNId, 12480) --45
		if @deklValue <> 0
			insert into CDN.JpkV7 (JpNId,DkNId,Typ,VatZd,RokMiesiac,Lp,DataZakupu,DataSprzedazy,DataWystawienia,DataWplywu, Dokument, DokumentZakupu, K_45) 
			values(@JpkNagId, @DkNId, @REJESTR_ZAKUPOW, 0,100*year(@DataDo) + month(@DataDo), 0, @DataDo, @DataDo, @DataDo, @DataDo, 'DEKLARACJA_POLE_45', 'WEW', @deklValue)

		set @DkNId = @dknIdBuffer
	end


	if @DkNId <> 0
	begin
			declare @rokMiesiac int = 100*year(@DataDo) + month(@DataDo);
			declare @kwotaDoZwrotuCheckBox decimal(15,2) = CDN.KwotaKsiegDekl(@DkNId,15101);
			declare @kwotaDoZwrotu decimal(15,2) = CDN.KwotaKsiegDekl(@DkNId,15102);
			declare @P_55 int = case when @kwotaDoZwrotuCheckBox <> 0 then case when @kwotaDoZwrotu=1 then 1 else 0 end else 0 end;
			declare @P_56 int = case when @kwotaDoZwrotuCheckBox <> 0 then case when @kwotaDoZwrotu=2 then 1 else 0 end else 0 end;
			declare @P_57 int = case when @kwotaDoZwrotuCheckBox <> 0 then case when @kwotaDoZwrotu=3 then 1 else 0 end else 0 end;
			declare @P_58 int = case when @kwotaDoZwrotuCheckBox <> 0 then case when @kwotaDoZwrotu=4 then 1 else 0 end else 0 end;
			declare @P_61 nvarchar(max); select @P_61 = DkE_WartoscTekst from cdn.deklelem where DkE_DkNID = @DkNId and Dke_Numer = 15116 

			declare @ordzu nvarchar(max)
			select @ordzu = DkE_WartoscTekst from CDN.DeklElem where DkE_DkNID = @DkNId and  DkE_Numer = 15320

			insert into CDN.JpkV7 (JpNId,DkNId,Typ,VatZd,RokMiesiac,Lp,DataZakupu,DataSprzedazy,DataWystawienia,DataWplywu, Dokument,
			P_10,P_11,P_12,P_13,P_14,P_15,P_16,P_17,P_18,P_19,P_20,P_21,P_22,P_23,P_24,P_25,
			P_26,P_27,P_28,P_29,P_30,P_31,P_32,P_33,P_34,P_35,P_36,P_37,P_38,P_39,P_40,P_41,
			P_42,P_43,P_44,P_45,P_46,P_47,P_48,P_49,P_50,P_51,P_52,P_53,P_54,P_55,P_56,P_57,
			P_58,P_59,P_60,P_61,P_62,P_63,P_64,P_65,P_66,P_67,P_68,P_69,P_ORDZU) 

			values(@JpkNagId, @DkNId, @DEKLARACJA, 0, @rokMiesiac, 0, @DataDo, @DataDo, @DataDo, @DataDo, 'DEKLARACJA',
			CDN.KwotaKsiegDekl(@DkNId,10500),		--P_10
			CDN.KwotaKsiegDekl(@DkNId,10550),		--P_11
			CDN.KwotaKsiegDekl(@DkNId,10510),		--P_12
			CDN.KwotaKsiegDekl(@DkNId,10700),		--P_13
			CDN.KwotaKsiegDekl(@DkNId,10705),		--P_14
			CDN.KwotaKsiegDekl(@DkNId,10710),		--P_15
			CDN.KwotaKsiegDekl(@DkNId,10720),		--P_16
			CDN.KwotaKsiegDekl(@DkNId,11400),		--P_17
			CDN.KwotaKsiegDekl(@DkNId,11500),		--P_18
			CDN.KwotaKsiegDekl(@DkNId,11600),		--P_19
			CDN.KwotaKsiegDekl(@DkNId,11700),		--P_20
			CDN.KwotaKsiegDekl(@DkNId,11710),		--P_21
			CDN.KwotaKsiegDekl(@DkNId,10600),		--P_22
			CDN.KwotaKsiegDekl(@DkNId,11730),		--P_23
			CDN.KwotaKsiegDekl(@DkNId,11740),		--P_24
			CDN.KwotaKsiegDekl(@DkNId,11742),		--P_25
			CDN.KwotaKsiegDekl(@DkNId,11744),		--P_26
			CDN.KwotaKsiegDekl(@DkNId,11750),		--P_27
			CDN.KwotaKsiegDekl(@DkNId,11760),		--P_28
			CDN.KwotaKsiegDekl(@DkNId,11762),		--P_29
			CDN.KwotaKsiegDekl(@DkNId,11764),		--P_30
			CDN.KwotaKsiegDekl(@DkNId,11780),		--P_31
			CDN.KwotaKsiegDekl(@DkNId,11781),		--P_32
			CDN.KwotaKsiegDekl(@DkNId,12000),		--P_33
			CDN.KwotaKsiegDekl(@DkNId,12005),		--P_34
			CDN.KwotaKsiegDekl(@DkNId,12010),		--P_35
			CDN.KwotaKsiegDekl(@DkNId,12011),		--P_36
			CDN.KwotaKsiegDekl(@DkNId,12150),		--P_37
			CDN.KwotaKsiegDekl(@DkNId,12200),		--P_38
			CDN.KwotaKsiegDekl(@DkNId,12300),		--P_39
			CDN.KwotaKsiegDekl(@DkNId,12410),		--P_40
			CDN.KwotaKsiegDekl(@DkNId,12420),		--P_41
			CDN.KwotaKsiegDekl(@DkNId,12430),		--P_42
			CDN.KwotaKsiegDekl(@DkNId,12440),		--P_43
			CDN.KwotaKsiegDekl(@DkNId,12470),		--P_44
			CDN.KwotaKsiegDekl(@DkNId,12480),		--P_45
			CDN.KwotaKsiegDekl(@DkNId,12482),		--P_46
			CDN.KwotaKsiegDekl(@DkNId,12483),		--P_47
			CDN.KwotaKsiegDekl(@DkNId,14300),		--P_48
			CDN.KwotaKsiegDekl(@DkNId,14500),		--P_49
			CDN.KwotaKsiegDekl(@DkNId,14600),		--P_50
			CDN.KwotaKsiegDekl(@DkNId,14700),		--P_51
			CDN.KwotaKsiegDekl(@DkNId,14900),		--P_52
			CDN.KwotaKsiegDekl(@DkNId,15000),		--P_53
			CDN.KwotaKsiegDekl(@DkNId,15100),		--P_54
			@P_55,									--P_55
			@P_56,									--P_56
			@P_57,									--P_57
			@P_58,									--P_58
			CDN.KwotaKsiegDekl(@DkNId,15112),		--P_59
			CDN.KwotaKsiegDekl(@DkNId,15114),		--P_60
			@P_61,									--P_61
			CDN.KwotaKsiegDekl(@DkNId,15200),		--P_62
			CDN.KwotaKsiegDekl(@DkNId,15220),		--P_63
			CDN.KwotaKsiegDekl(@DkNId,15230),		--P_64
			CDN.KwotaKsiegDekl(@DkNId,15240),		--P_65
			CDN.KwotaKsiegDekl(@DkNId,15250),		--P_66
			CDN.KwotaKsiegDekl(@DkNId,15251),		--P_67
			CDN.KwotaKsiegDekl(@DkNId,15252),		--P_68
			CDN.KwotaKsiegDekl(@DkNId,15253),		--P_69
			@ordzu)									--P_ORDZU
	end


	update cdn.JpkV7 set Kontrahent = 'BRAK'
	where 
	JpNId=@JpkNagId and IsNull(Kontrahent, '') = '';

	-- adres kontrahenta
	update cdn.JpkV7 set Adres = 'BRAK'
	where 
	JpNId=@JpkNagId and IsNull(Adres, '') = '';
	

	--kody JPK
	/*
	update CDN.JpkV7 Set 

	TypDokumentu =	case	when CDN.JpkCodeExistOnVatNag(VaNId, 'FP')=1 then 'FP' 
							when CDN.JpkCodeExistOnVatNag(VaNId, 'RO')=1 then 'RO' 
							when CDN.JpkCodeExistOnVatNag(VaNId, 'WEW')=1 then 'WEW' 
					end	,

	DokumentZakupu =case	when CDN.JpkCodeExistOnVatNag(VaNId, 'MK')=1 then 'MK' 
							when CDN.JpkCodeExistOnVatNag(VaNId, 'VAT_RR')=1 then 'VAT_RR' 
							when CDN.JpkCodeExistOnVatNag(VaNId, 'WEW')=1 or IsNull(K_44, 0) <> 0 or IsNull(K_45, 0) <> 0 then 'WEW' 
					end,

	GTU_01 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_01'),
	GTU_02 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_02'),
	GTU_03 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_03'),
	GTU_04 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_04'),
	GTU_05 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_05'),
	GTU_06 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_06'),
	GTU_07 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_07'),
	GTU_08 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_08'),
	GTU_09 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_09'),
	GTU_10 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_10'),
	GTU_11 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_11'),
	GTU_12 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_12'),
	GTU_13 = CDN.JpkCodeExistOnVatNag(VaNId, 'GTU_13'),
	SW = CDN.JpkCodeExistOnVatNag(VaNId, 'SW'),
	EE = CDN.JpkCodeExistOnVatNag(VaNId, 'EE'),
	TP = CDN.JpkCodeExistOnVatNag(VaNId, 'TP'),
	TT_WNT = CDN.JpkCodeExistOnVatNag(VaNId, 'TT_WNT'),
	TT_D = CDN.JpkCodeExistOnVatNag(VaNId, 'TT_D'),
	MR_T = CDN.JpkCodeExistOnVatNag(VaNId, 'MR_T'),
	MR_UZ = CDN.JpkCodeExistOnVatNag(VaNId, 'MR_UZ'),
	I_42 = CDN.JpkCodeExistOnVatNag(VaNId, 'I_42'),
	I_63 = CDN.JpkCodeExistOnVatNag(VaNId, 'I_63'),
	B_SPV = CDN.JpkCodeExistOnVatNag(VaNId, 'B_SPV'),
	B_SPV_DOSTAWA = CDN.JpkCodeExistOnVatNag(VaNId, 'B_SPV_DOSTAWA'),
	B_MPV_PROWIZJA = CDN.JpkCodeExistOnVatNag(VaNId, 'B_MPV_PROWIZJA'),
	MPP = CDN.JpkCodeExistOnVatNag(VaNId, 'MPP'),
	IMP = CDN.JpkCodeExistOnVatNag(VaNId, 'IMP')
	where JpNId = @JpkNagId and VaNId is not null;
	*/

	update JV7 Set 

	TypDokumentu =	case	when jc.FP=1 then 'FP' 
							when jc.RO=1 then 'RO' 
							when jc.WEW=1 then 'WEW' 
					end	,

	DokumentZakupu =case	when jc.MK=1 then 'MK' 
							when jc.VAT_RR=1 then 'VAT_RR' 
							when jc.WEW=1 or IsNull(K_44, 0) <> 0 or IsNull(K_45, 0) <> 0 then 'WEW' 
					end,

	GTU_01 = jc.GTU_01,
	GTU_02 = jc.GTU_02,
	GTU_03 = jc.GTU_03,
	GTU_04 = jc.GTU_04,
	GTU_05 = jc.GTU_05,
	GTU_06 = jc.GTU_06,
	GTU_07 = jc.GTU_07,
	GTU_08 = jc.GTU_08,
	GTU_09 = jc.GTU_09,
	GTU_10 = jc.GTU_10,
	GTU_11 = jc.GTU_11,
	GTU_12 = jc.GTU_12,
	GTU_13 = jc.GTU_13,
	SW = jc.SW,
	EE = jc.EE,
	TP = jc.TP,
	TT_WNT = jc.TT_WNT,
	TT_D = jc.TT_D,
	MR_T = jc.MR_T,
	MR_UZ = jc.MR_UZ,
	I_42 = jc.I_42,
	I_63 = jc.I_63,
	B_SPV = jc.B_SPV,
	B_SPV_DOSTAWA = jc.B_SPV_DOSTAWA,
	B_MPV_PROWIZJA = jc.B_MPV_PROWIZJA,
	MPP = jc.MPP,
	IMP = jc.IMP
	from CDN.JpkV7 JV7 join CDN.JpkCodesOnVatNag() jc on (JV7.VaNID = jc.VaNId)
	where JV7.JpNId = @JpkNagId and JV7.VaNId is not null;


	select @result = count(*) from  CDN.JpkV7 where JpNId = @JpkNagId;

	return

