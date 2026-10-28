
--* gSkrypt.sOpis = $Tworzenie procedury CDN.DeklaracjaVAT7v21$
-->
CREATE FUNCTION [CDN].[DeklaracjaVAT7v21]( @Rok INT, @Miesiac INT, @Nieokreslony INT, @Typ INT, @CalyKwartal INT, @WliczacNP int, @ObliczPola int, @Stawka4 int)
RETURNS
  @Wyniki TABLE(VaN_VaNID INT, VaN_Lp INT, VaN_RokMies INT,VaN_DataZap DATETIME, VaN_Dokument VARCHAR(256), VaN_IdentKsieg VARCHAR(50), VaN_KntNazwa1 NVARCHAR(50),
  VaN_Kategoria VARCHAR(50), Netto DECIMAL(15,2), VAT DECIMAL(15,2), VaN_Rejestr NVARCHAR(20), VaN_Typ SMALLINT, VaN_DeklRokMies INT, Va7_RokMiesiac INT,
  VaN_KpRID INT, VaN_RycID INT, VaN_DekID INT, VaN_KntNipE VARCHAR(20), VaN_KntNipKraj VARCHAR(2), VaN_Pesel NVARCHAR(11),
  VaN_Export TINYINT, VaN_Finalny TINYINT, VaN_Rolnik TINYINT, VaN_Detal TINYINT, VaN_Fiskalna TINYINT, VaN_Wewnetrzna TINYINT, VaN_RozliczacVATUE TINYINT, VaN_PodatekVat TINYINT,
  VaT_RodzajZakupu SMALLINT, RodzajZakupu SMALLINT, VaT_Odliczenia SMALLINT, VaT_Flaga SMALLINT, VaT_Stawka DECIMAL(5,2), KodStawki varchar(3), VatZD tinyint, VaN_ZakID INT,
  
  
	-- first stage
	ZakBiezTrwOpodNetto decimal(15,2),
	ZakBiezTrwOpodVat decimal(15,2),
	ZakBiezTrwMieszNetto decimal(15,2),
	ZakBiezTrwMieszVat decimal(15,2),
	ZakBiezNierMieszNetto decimal(15,2),
	ZakBiezNierMieszVat decimal(15,2),
	ZakBiezTrw15MieszNetto decimal(15,2),
	ZakBiezTrw15MieszVat decimal(15,2),
	ZakBiezNi15MieszNetto decimal(15,2),
	ZakBiezNi15MieszVat decimal(15,2),
	ZakBiezInnOpodNetto decimal(15,2),
	ZakBiezInnOpodVat decimal(15,2),
	ZakBiezInnMieszNetto decimal(15,2),
	ZakBiezInnMieszVat decimal(15,2),

	SprzedazZwolniona decimal(15,2),
	TowaryUslugiPozaKrajem decimal(15,2),
	TowaryUslugiPozaKrajemA decimal(15,2),
	SprzedazNetto0 decimal(15,2),
	SprzedazNetto0_art129 decimal(15,2),
	SprzedazNetto3 decimal(15,2),
	SprzedazVat3 decimal(15,2),
	SprzedazNetto7 decimal(15,2),
	SprzedazVat7 decimal(15,2),
	SprzedazNetto22 decimal(15,2),
	SprzedazVat22 decimal(15,2),
	SprzedazWewnatrzWsp decimal(15,2),
	SprzedazNettoExport0 decimal(15,2),
	ZakupyWewnatrzWspNetto decimal(15,2),
	ZakupyWewnatrzWspVat decimal(15,2),
	ImportTowarowArt33aNetto decimal(15,2),
	ImportTowarowArt33aVAT decimal(15,2),
	ImportUslugNetto decimal(15,2),
	ImportUslugVat decimal(15,2),
	ImportUslugNettoA decimal(15,2),
	ImportUslugVatA decimal(15,2),
	DostawaKrajPlatnikNetto decimal(15,2),
	DostawaKrajPodatnikNabywcaNetto decimal(15,2),
	DostawaKrajPodatnikNabywcaVat decimal(15,2),
	DostawaUslugPodatnikNabywcaNetto decimal(15,2),
	DostawaUslugPodatnikNabywcaVat decimal(15,2),
	SwiadczenieUslugNetto decimal(15,2),
	SwiadczenieUslugVat decimal(15,2),
	WWNabycieSrTranspVat decimal(15,2)	
  )
AS
BEGIN
	declare @REJESTR_ZAKUPOW	int = 1;
	declare @REJESTR_SPRZEDAZY	int = 2;
	
	--declare @WliczacNP tinyint = 1;

	declare @RodzajTowary            tinyint = 1;
	declare @RodzajInne              tinyint = 2;
	declare @RodzajTrwale            tinyint = 3;
	declare @RodzajUslugi            tinyint = 4;
	declare @RodzajNoweSrTran        tinyint = 5;
	declare @RodzajNieruchomosci     tinyint = 6;
	declare @RodzajPaliwo            tinyint = 7;

	declare @Nie			tinyint = 0;
	declare @Tak			tinyint = 1;
	declare @Warunkowo		tinyint = 2;

	declare @kntKraj				tinyint = 0;
	declare @kntPozaUnijny			tinyint = 1;
	declare @kntPozaUnZwrot			tinyint = 2;
	declare @kntWewnUnijny			tinyint = 3;
	declare @kntWewnUnTroj			tinyint = 4;
	declare @kntNiePodatnik			tinyint = 5;
	declare @kntPozaTerytorialny	tinyint = 6;
	declare @kntPozaTerytorialnyNP  tinyint = 7;
	declare @kntWewnUnNabywca       tinyint = 8;
	declare @kntPozaUnNabywca		tinyint = 9;

	
	

	DECLARE @RokMiesMin INT, @RokMiesMax INT
	IF @CalyKwartal = 0
	BEGIN
		SET @RokMiesMin = 100 * @Rok + @Miesiac
		SET @RokMiesMax = 100 * @Rok + @Miesiac
	END
	ELSE
	BEGIN
		SET @RokMiesMax = 100 * @Rok + (@Miesiac + (3-@Miesiac%3)%3)
		SET @RokMiesMin = @RokMiesMax - 2
		IF(@Rok = 2004)
		BEGIN
			IF @Miesiac IN (1,2,3,4)
			BEGIN
				SET @RokMiesMin = 200401;
				SET @RokMiesMax = 200404;
			END
			ELSE IF @Miesiac IN (5,6)
			BEGIN
				SET @RokMiesMin = 200405;
				SET @RokMiesMax = 200406;
			END
		END
	END
	
	DECLARE @MetodyRozliczVAT TABLE ( _Metoda INT, _Okres INT PRIMARY KEY )
	INSERT INTO @MetodyRozliczVAT(_Metoda, _Okres)
	SELECT CAST(CFW_Wartosc AS INT) AS _Metoda, YEAR (CFK_OkresOd)*100 + MONTH(CFK_OkresOd) AS _Okres
	FROM CDN.CfgWartosci left outer join CDN.CfgKlucze ON (CFW_CfkId = CFK_CfkId)
	WHERE CFK_Nazwa = 'Metoda rozliczania VAT'
	ORDER BY YEAR (CFK_OkresOd)*100 + MONTH (CFK_OkresOd)
	
	IF @Nieokreslony = 1
		INSERT INTO @Wyniki
		SELECT VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
		VaN_Kategoria, SUM(VaT_NettoDoVAT) AS Netto, SUM(VaT_VatDoVAT) AS VAT, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies, VaN_DeklRokMies,
		VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
		VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
		VaT_RodzajZakupu, 0, VaT_Odliczenia, VaT_Flaga, VaT_Stawka, CDN.KodStawkiVat( VaN_Typ, VaT_Flaga, VaT_Stawka), 0, VaN_ZakID,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    
		FROM CDN.VatNag 
		left outer join (CDN.DokKodyJPKV7 join CDN.KodyJPKV7 on (DKV7_KV7ID = KV7_KV7ID and KV7_Kod in ('FP', 'ZakupVAT_Marza'))) on (VaN_VaNID = DKV7_ParentID and DKV7_ParentTyp=2)
		INNER JOIN CDN.VatTab ON VaN_VaNID = VaT_VaNID		
		WHERE DKV7_DKV7ID is null and VaN_RozliczacVat7 = 0 AND VaN_Typ = @Typ
		GROUP BY VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
		VaN_Kategoria, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies,
		VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
		VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
		VaT_RodzajZakupu, VaT_Odliczenia, VaT_Flaga, VaT_Stawka, CDN.KodStawkiVat( VaN_Typ, VaT_Flaga, VaT_Stawka), VaN_ZakID
	ELSE
		INSERT INTO @Wyniki
		SELECT VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
		VaN_Kategoria, SUM(Va7_Netto) AS Netto, SUM(Va7_Vat) AS VAT, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies, Va7_RokMiesiac,
		VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
		VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
		Va7_RodzajZakupu, 0, Va7_Odliczenia, Va7_Flaga, Va7_Stawka, CDN.KodStawkiVat( VaN_Typ, Va7_Flaga, Va7_Stawka), 0, VaN_ZakID,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		FROM CDN.VatNag
		left outer join (CDN.DokKodyJPKV7 join CDN.KodyJPKV7 on (DKV7_KV7ID = KV7_KV7ID and KV7_Kod in ('FP', 'ZakupVAT_Marza'))) on (VaN_VaNID = DKV7_ParentID and DKV7_ParentTyp=2)
		INNER JOIN CDN.VatTab7 ON VaN_VaNID = Va7_VaNID
		left outer join CDN.UjemnyVat_Marza_Tab() ujemnaMarza on VaN_VaNID = ujemnaMarza.VaNId		
		INNER JOIN @MetodyRozliczVAT AS Konfig ON Konfig._Okres = (SELECT TOP 1 _Okres FROM @MetodyRozliczVAT temp 			
	    WHERE temp._Okres <= YEAR(VaN_DataZap)*100 + MONTH(VaN_DataZap) ORDER BY _Okres Desc)
		WHERE DKV7_DKV7ID is null and VaN_Typ = @Typ AND VaN_RozliczacVat7 = 1 AND VaN_Wewnetrzna = 0 AND (VaN_MetodaKasowa = 1 or _Metoda = 2) AND
		( 
		(VaN_DataZap >= CONVERT(DATETIME, '2013-01-01', 120) OR (VaN_Typ=2 AND VaN_DataZap < CONVERT(DATETIME, '2013-01-01', 120)))
		AND Va7_RokMiesiac BETWEEN @RokMiesMin AND @RokMiesMax
		)
		and ujemnaMarza.VaNId is null
		GROUP BY VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
		VaN_Kategoria, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies, Va7_RokMiesiac,
		VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
		VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
		Va7_RodzajZakupu, Va7_Odliczenia, Va7_Flaga, Va7_Stawka, CDN.KodStawkiVat( VaN_Typ, Va7_Flaga, Va7_Stawka), VaN_ZakID
		  
		UNION
		SELECT VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
		VaN_Kategoria, SUM(VaT_NettoDoVAT) AS Netto, SUM(VaT_VatDoVAT) AS VAT, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies, VaN_DeklRokMies,
		VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
		VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
		VaT_RodzajZakupu, 0, VaT_Odliczenia, VaT_Flaga, VaT_Stawka, CDN.KodStawkiVat( VaN_Typ, VaT_Flaga, VaT_Stawka), 0, VaN_ZakID,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		FROM CDN.VatNag
		left outer join (CDN.DokKodyJPKV7 join CDN.KodyJPKV7 on (DKV7_KV7ID = KV7_KV7ID and KV7_Kod in ('FP', 'ZakupVAT_Marza'))) on (VaN_VaNID = DKV7_ParentID and DKV7_ParentTyp=2)
		INNER JOIN CDN.VatTab ON VaN_VaNID = VaT_VaNID
		left outer join CDN.UjemnyVat_Marza_Tab() ujemnaMarza on VaN_VaNID = ujemnaMarza.VaNId
		INNER JOIN @MetodyRozliczVAT AS Konfig ON Konfig._Okres = (SELECT TOP 1 _Okres FROM @MetodyRozliczVAT temp WHERE temp._Okres <= YEAR(VaN_DataZap)*100 + MONTH(VaN_DataZap) ORDER BY _Okres Desc)
		
		WHERE DKV7_DKV7ID is null and VaN_Typ = @Typ AND VaN_RozliczacVat7 = 1 AND
		(
		(VaN_DeklRokMies BETWEEN @RokMiesMin AND @RokMiesMax AND (VaN_Wewnetrzna = 0 AND VaN_MetodaKasowa = 0 AND _Metoda=1 OR VaN_Wewnetrzna = 1))
		OR
		(_Metoda=2 AND VaN_Typ = 1 AND VaN_Wewnetrzna = 0 AND VaN_DataZap < CONVERT(DATETIME, '2013-01-01', 120) AND VaN_DeklRokMiesKasa BETWEEN @RokMiesMin AND @RokMiesMax)
		)
		and ujemnaMarza.VaNId is null
		GROUP BY VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
		VaN_Kategoria, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies,
		VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
		VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
		VaT_RodzajZakupu, VaT_Odliczenia, VaT_Flaga, VaT_Stawka, CDN.KodStawkiVat( VaN_Typ, VaT_Flaga, VaT_Stawka), VaN_ZakID
		update @Wyniki set VatZD = 1 where VaN_VaNID in (
		select DkE_WartoscL from cdn.DeklElem join cdn.DeklNag on (DkN_DkNId = DkE_DkNId)
		where
		DkN_TypDeklar = 402 and DkE_Numer = 1 and DkE_WartoscL <> 0
		)

		
	update @Wyniki set VatZD = 1 where VaN_VaNID in (
	select Distinct VaZ_VaNId_ZK from cdn.DeklNag join CDN.VatZD on (DkN_DkNId = VaZ_DkNId)
	where
	DkN_TypDeklar = 402 and VaZ_VaNId_ZK is Not Null
	)

	if @ObliczPola <> 0
	begin
		update @Wyniki 
		set RodzajZakupu = Case When VaT_RodzajZakupu In (3, 5, 6) And IsNull(Netto,0) < 15000.00 And VaT_Odliczenia = 2 And VaN_RokMies >= 200506 Then -VaT_RodzajZakupu Else VaT_RodzajZakupu End
		
		update @Wyniki 
		set ZakBiezTrwOpodNetto = case when VaT_Odliczenia = @Tak and RodzajZakupu in(@RodzajTrwale, @RodzajNoweSrTran, @RodzajNieruchomosci) then Netto else 0 end,
			ZakBiezTrwOpodVat = case when VaT_Odliczenia = @Tak and RodzajZakupu in(@RodzajTrwale, @RodzajNoweSrTran, @RodzajNieruchomosci) then Vat else 0 end,
			ZakBiezTrwMieszNetto = case when VaT_Odliczenia = @Warunkowo and RodzajZakupu in(@RodzajTrwale, @RodzajNoweSrTran) then Netto else 0 end,
			ZakBiezTrwMieszVat = case when VaT_Odliczenia = @Warunkowo and RodzajZakupu in(@RodzajTrwale, @RodzajNoweSrTran) then Vat else 0 end,
			ZakBiezNierMieszNetto = case when VaT_Odliczenia = @Warunkowo and RodzajZakupu = @RodzajNieruchomosci then Netto else 0 end,
			ZakBiezNierMieszVat = case when VaT_Odliczenia = @Warunkowo and RodzajZakupu = @RodzajNieruchomosci then Vat else 0 end,
			ZakBiezTrw15MieszNetto = case when VaT_Odliczenia = @Warunkowo and RodzajZakupu in(-@RodzajTrwale, -@RodzajNoweSrTran) then Netto else 0 end,
			ZakBiezTrw15MieszVat = case when VaT_Odliczenia = @Warunkowo and RodzajZakupu in(-@RodzajTrwale, -@RodzajNoweSrTran) then Vat else 0 end,
			ZakBiezNi15MieszNetto = case when VaT_Odliczenia = @Warunkowo and RodzajZakupu = -@RodzajNieruchomosci then Netto else 0 end,
			ZakBiezNi15MieszVat = case when VaT_Odliczenia = @Warunkowo and RodzajZakupu = -@RodzajNieruchomosci then Vat else 0 end,
			
			ZakBiezInnOpodNetto = case when VaT_Odliczenia = @Tak and VaT_RodzajZakupu in (@RodzajTowary, @RodzajInne, @RodzajUslugi, @RodzajPaliwo) then Netto else 0 end,
			ZakBiezInnOpodVat = case when VaT_Odliczenia = @Tak and VaT_RodzajZakupu in (@RodzajTowary, @RodzajInne, @RodzajUslugi, @RodzajPaliwo) then Vat else 0 end,
			ZakBiezInnMieszNetto = case when VaT_Odliczenia = @Warunkowo and VaT_RodzajZakupu in (@RodzajTowary, @RodzajInne, @RodzajUslugi, @RodzajPaliwo) then Netto else 0 end,
			ZakBiezInnMieszVat = case when VaT_Odliczenia = @Warunkowo and VaT_RodzajZakupu in (@RodzajTowary, @RodzajInne, @RodzajUslugi, @RodzajPaliwo) then Vat else 0 end
		where VaN_Typ = @REJESTR_ZAKUPOW

	 
		update @Wyniki 
		set SprzedazZwolniona =
		case when	KodStawki = 'ZW' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0
				or	KodStawki = 'ZW' and VaN_Export = @kntKraj 
				or	KodStawki = 'ZW' and VaN_Export = @kntPozaTerytorialnyNP
				or  @WliczacNP <> 0  and KodStawki = 'NP' and VaN_Export = @kntKraj then Netto else 0 end,

		TowaryUslugiPozaKrajem = 
		case when	VaN_Export = @kntPozaTerytorialny
				or	VaN_Export = @kntPozaTerytorialnyNP and KodStawki = 'NP'
				or	VaN_Export = @kntWewnUnijny and KodStawki = 'NP' and VaT_RodzajZakupu = @RodzajUslugi and VaN_Wewnetrzna = 0
				or	VaN_Export = @kntWewnUnTroj and KodStawki = 'NP' and VaT_RodzajZakupu = @RodzajUslugi and VaN_Wewnetrzna = 0
				or	VaN_Export = @kntWewnUnNabywca and KodStawki = 'NP' and VaT_RodzajZakupu = @RodzajUslugi and VaN_Wewnetrzna = 0
				or	VaN_Export = @kntPozaUnNabywca and KodStawki = 'NP' and VaT_RodzajZakupu = @RodzajUslugi and VaN_Wewnetrzna = 0 then Netto else 0 end,

		TowaryUslugiPozaKrajemA = 
		case when	VaN_Export = @kntPozaTerytorialny and VaN_RozliczacVATUE <> 0 and VaT_RodzajZakupu = @RodzajUslugi
				or	VaN_Export = @kntPozaTerytorialnyNP and VaN_RozliczacVATUE <> 0 and VaT_RodzajZakupu = @RodzajUslugi and KodStawki = 'NP'
				or	VaN_Export = @kntWewnUnijny and VaN_RozliczacVATUE <> 0 and VaT_RodzajZakupu = @RodzajUslugi and KodStawki = 'NP' and VaN_Wewnetrzna = 0
				or	VaN_Export = @kntWewnUnTroj and VaN_RozliczacVATUE <> 0 and VaT_RodzajZakupu = @RodzajUslugi and KodStawki = 'NP' and VaN_Wewnetrzna = 0
				or	VaN_Export = @kntWewnUnNabywca and VaN_RozliczacVATUE <> 0 and VaT_RodzajZakupu = @RodzajUslugi and KodStawki = 'NP' and VaN_Wewnetrzna = 0
				or	VaN_Export = @kntPozaUnNabywca and VaN_RozliczacVATUE <> 0 and VaT_RodzajZakupu = @RodzajUslugi and KodStawki = 'NP' and VaN_Wewnetrzna = 0 then Netto else 0 end,

		SprzedazNetto0 = 		
		case when	KodStawki = '0%' and VaN_Export = @kntKraj
				or	KodStawki = '0%' and VaN_Export = @kntPozaTerytorialnyNP
				or	KodStawki = '0%' and VaN_Export = @kntNiePodatnik and VaN_Wewnetrzna = 0
				or	KodStawki = '0%' and VaN_Export = @kntPozaUnZwrot and VaN_Wewnetrzna = 0 then Netto else 0 end,

		SprzedazNetto0_art129 = 
		case when KodStawki = '0%' and VaN_Export = @kntPozaUnZwrot and VaN_Wewnetrzna = 0 then Netto else 0 end,

		SprzedazNetto3 = 
		case when	KodStawki = '3%' and VaN_Export = @kntKraj 
				or	KodStawki = '3%' and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '3%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 
				or	KodStawki = '5%' and VaN_Export = @kntKraj 
				or	KodStawki = '5%' and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '5%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 then Netto else 0 end,

		SprzedazVat3 = 		
		case when	KodStawki = '3%' and VaN_Export = @kntKraj 
				or	KodStawki = '3%' and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '3%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 
				or	KodStawki = '5%' and VaN_Export = @kntKraj 
				or	KodStawki = '5%' and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '5%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 then Vat else 0 end,

		SprzedazNetto7 = 		
		case when	
					KodStawki = '4%' and @Stawka4 <> 0 and VaN_Export = @kntKraj 
				or	KodStawki = '4%' and @Stawka4 <> 0 and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '4%' and @Stawka4 <> 0 and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 		
				or  KodStawki = '7%' and VaN_Export = @kntKraj 
				or	KodStawki = '7%' and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '7%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 
				or	KodStawki = '8%' and VaN_Export = @kntKraj 
				or	KodStawki = '8%' and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '8%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 then Netto else 0 end,

		SprzedazVat7 = 
		case when	
					KodStawki = '4%' and @Stawka4 <> 0 and VaN_Export = @kntKraj 
				or	KodStawki = '4%' and @Stawka4 <> 0 and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '4%' and @Stawka4 <> 0 and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 		
				or  KodStawki = '7%' and VaN_Export = @kntKraj 
				or	KodStawki = '7%' and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '7%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 
				or	KodStawki = '8%' and VaN_Export = @kntKraj 
				or	KodStawki = '8%' and VaN_Export = @kntPozaTerytorialnyNP 
				or	KodStawki = '8%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 then Vat else 0 end,

		SprzedazNetto22 = 
		case when	KodStawki = '22%' and VaN_Export = @kntKraj
				or	KodStawki = '22%' and VaN_Export = @kntPozaTerytorialnyNP
				or	KodStawki = '22%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0
				or	KodStawki = '23%' and VaN_Export = @kntKraj
				or	KodStawki = '23%' and VaN_Export = @kntPozaTerytorialnyNP
				or	KodStawki = '23%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 then Netto else 0 end,

		SprzedazVat22 = 
		case when	KodStawki = '22%' and VaN_Export = @kntKraj
				or	KodStawki = '22%' and VaN_Export = @kntPozaTerytorialnyNP
				or	KodStawki = '22%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0
				or	KodStawki = '23%' and VaN_Export = @kntKraj
				or	KodStawki = '23%' and VaN_Export = @kntPozaTerytorialnyNP
				or	KodStawki = '23%' and VaN_Export <> @kntPozaTerytorialny and VaN_Wewnetrzna = 0 then Vat else 0 end,


		SprzedazWewnatrzWsp = 
		case when	KodStawki = '0%' and VaN_Wewnetrzna = 0 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntWewnUnijny
				or	KodStawki = '0%' and VaN_Wewnetrzna = 0 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntWewnUnTroj
				or	KodStawki = '0%' and VaN_Wewnetrzna = 0 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntWewnUnNabywca then Netto else 0 end,

		SprzedazNettoExport0 = 
		case when KodStawki = '0%' and VaN_Wewnetrzna = 0 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntPozaUnijny then Netto else 0 end,

		ZakupyWewnatrzWspNetto = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntWewnUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntWewnUnTroj then Netto else 0 end,

		ZakupyWewnatrzWspVat = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntWewnUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntWewnUnTroj then Vat else 0 end,

		ImportTowarowArt33aNetto = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajTowary and VaN_Export = @kntPozaUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajTowary and VaN_Export = @kntPozaUnZwrot
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajNoweSrTran and VaN_Export = @kntPozaUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajNoweSrTran and VaN_Export = @kntPozaUnZwrot then Netto else 0 end,

		ImportTowarowArt33aVAT = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajTowary and VaN_Export = @kntPozaUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajTowary and VaN_Export = @kntPozaUnZwrot
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajNoweSrTran and VaN_Export = @kntPozaUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajNoweSrTran and VaN_Export = @kntPozaUnZwrot then Vat else 0 end,

		ImportUslugNetto = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajUslugi and VaN_Export = @kntPozaUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajUslugi and VaN_Export = @kntPozaUnZwrot  then Netto else 0 end,

		ImportUslugVat = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajUslugi and VaN_Export = @kntPozaUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajUslugi and VaN_Export = @kntPozaUnZwrot  then Vat else 0 end,

		ImportUslugNettoA = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajUslugi and VaN_Export = @kntWewnUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajUslugi and VaN_Export = @kntWewnUnTroj then Netto else 0 end,

		ImportUslugVatA = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajUslugi and VaN_Export = @kntWewnUnijny
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu = @RodzajUslugi and VaN_Export = @kntWewnUnTroj then Vat else 0 end,

		DostawaKrajPlatnikNetto = 
		case when VaN_Wewnetrzna = 0 and KodStawki = 'NP'and VaN_Export = @kntNiePodatnik and VaN_PodatekVat <> 0 then Netto else 0 end,

		DostawaKrajPodatnikNabywcaNetto = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntWewnUnNabywca
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntPozaUnNabywca then Netto else 0 end,

		DostawaKrajPodatnikNabywcaVat = 
		case when	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntWewnUnNabywca
				or	VaN_Wewnetrzna = 1 and VaT_RodzajZakupu <> @RodzajUslugi and VaN_Export = @kntPozaUnNabywca then Vat else 0 end,

		DostawaUslugPodatnikNabywcaNetto = 
		case when VaN_Wewnetrzna = 1 and VaN_Export = @kntNiePodatnik  and VaN_PodatekVat <> 0 then Netto else 0 end,

		DostawaUslugPodatnikNabywcaVat = 
		case when VaN_Wewnetrzna = 1 and VaN_Export = @kntNiePodatnik  and VaN_PodatekVat <> 0 then Vat else 0 end,

		SwiadczenieUslugNetto = 
		case when VaN_Wewnetrzna = 1 and VaN_Export = @kntNiePodatnik  and VaN_PodatekVat <> 0 and VaT_RodzajZakupu = @RodzajUslugi then Netto else 0 end,

		SwiadczenieUslugVat = 
		case when VaN_Wewnetrzna = 1 and VaN_Export = @kntNiePodatnik  and VaN_PodatekVat <> 0 and VaT_RodzajZakupu = @RodzajUslugi then Vat else 0 end,
		
		
		WWNabycieSrTranspVat = 
		case when	VaN_Wewnetrzna=1 and VaT_RodzajZakupu = @RodzajNoweSrTran and VaN_Export = @kntWewnUnijny 
				or	VaN_Wewnetrzna=1 and VaT_RodzajZakupu = @RodzajNoweSrTran and VaN_Export = @kntWewnUnTroj then Vat else 0 end
		where VaN_Typ = @REJESTR_SPRZEDAZY
		
	end
 
 
  
	RETURN
END
