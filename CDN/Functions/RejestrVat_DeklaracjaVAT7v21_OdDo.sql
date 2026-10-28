
--* gSkrypt.sOpis = $Tworzenie funkcji CDN.RejestrVat_DeklaracjaVAT7v21_OdDo$
-->
CREATE FUNCTION [CDN].[RejestrVat_DeklaracjaVAT7v21_OdDo]( @DataOd DateTime, @DataDo DateTime, @Nieokreslony INT, @Typ INT, @CalyKwartal INT, @WliczacNP int, @UwzglednijStawke_0 int, @ObliczPola int, @Wspolczynnik decimal(7,4))
RETURNS --- deklaracja tabelki z wynikami
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
		
		SpisZNaturyVat decimal(15,2),	-- 
		ZwrotKwotyNazakupKas decimal(15,2),		
		WWNabycieSrTranspVat decimal(15,2),		-- 38
		
		-- secound stage
		ZakupyTrwaleNetto  decimal(15,2),		-- 42
		ZakupyTrwaleVat  decimal(15,2),			-- 43
		ZakupyInneNetto decimal(15,2),			-- 44
		ZakupyInneVat decimal(15,2),			-- 45
		
		KorektaTrwaleVat decimal(15,2),			-- 46
		KorektaInneVat decimal(15,2),			-- 47
		KorektaPodatku89b decimal(15,2),		-- 48
		KorektaPodatku89b_u4 decimal(15,2)
		)
AS
begin

	declare @REJESTR_ZAKUPOW	int = 1;
	declare @REJESTR_SPRZEDAZY	int = 2;

	declare @RokMiesMin int = 100 * Year(@DataOd) + Month(@DataOd);
	declare @RokMiesMax int = 100 * Year(@DataDo) + Month(@DataDo);
	declare @rokMiesiac int = @RokMiesMin;
	declare @y int = Year(@DataOd);
	declare @m int = Month(@DataOd);
	
	set @Wspolczynnik = @Wspolczynnik / 100.00
	
	
	
	while (@rokMiesiac <= @RokMiesMax)
	begin
		
		set @y = @rokMiesiac / 100;
		set @m = @rokMiesiac % 100;

		-- inserty rĂłwĹĽniÄ… siÄ™ tylko klauzula where
		if @Typ = @REJESTR_ZAKUPOW		
			insert into @Wyniki (
			VaN_VaNID, 
			VaN_Lp , 
			VaN_RokMies ,
			VaN_DataZap , 
			VaN_Dokument , 
			VaN_IdentKsieg, 
			VaN_KntNazwa1 ,
			VaN_Kategoria, 
			Netto, 
			VAT, 
			VaN_Rejestr, 
			VaN_Typ, 
			VaN_DeklRokMies, 
			Va7_RokMiesiac,
			VaN_KpRID, 
			VaN_RycID, 
			VaN_DekID , 
			VaN_KntNipE, 
			VaN_KntNipKraj, 
			VaN_Pesel,
			VaN_Export, 
			VaN_Finalny, 
			VaN_Rolnik , 
			VaN_Detal, 
			VaN_Fiskalna, 
			VaN_Wewnetrzna, 
			VaN_RozliczacVATUE, 
			VaN_PodatekVat, 
			VaT_RodzajZakupu, 
			RodzajZakupu , 
			VaT_Odliczenia , 
			VaT_Flaga , 
			VaT_Stawka, 
			KodStawki, 
			VatZD, 
			VaN_ZakID,

			--first stage
			ZakBiezTrwOpodNetto,
			ZakBiezTrwOpodVat,
			ZakBiezTrwMieszNetto,
			ZakBiezTrwMieszVat,
			ZakBiezNierMieszNetto,
			ZakBiezNierMieszVat,
			ZakBiezTrw15MieszNetto,
			ZakBiezTrw15MieszVat,
			ZakBiezNi15MieszNetto,
			ZakBiezNi15MieszVat,
			ZakBiezInnOpodNetto,
			ZakBiezInnOpodVat,
			ZakBiezInnMieszNetto,
			ZakBiezInnMieszVat,
			SprzedazZwolniona,
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
			SwiadczenieUslugNetto,
			SwiadczenieUslugVat,
			
			SpisZNaturyVat,			-- 0
			ZwrotKwotyNazakupKas,	-- 0
					
			WWNabycieSrTranspVat,
						
			
			--secound stage
			ZakupyTrwaleNetto,
			ZakupyTrwaleVat,
			ZakupyInneNetto,
			ZakupyInneVat,
			
			KorektaTrwaleVat,
			KorektaInneVat,
			KorektaPodatku89b,
			KorektaPodatku89b_u4
					
			)
			select 
			VaN_VaNID, 
			VaN_Lp , 
			VaN_RokMies ,
			VaN_DataZap , 
			VaN_Dokument , 
			VaN_IdentKsieg, 
			VaN_KntNazwa1 ,
			VaN_Kategoria, 
			Sum(IsNull(Netto,0)), 
			Sum(IsNull(VAT,0)), 
			VaN_Rejestr, 
			VaN_Typ, 
			VaN_DeklRokMies, 
			Va7_RokMiesiac,
			VaN_KpRID, 
			VaN_RycID, 
			VaN_DekID , 
			VaN_KntNipE, 
			VaN_KntNipKraj, 
			VaN_Pesel,
			VaN_Export, 
			VaN_Finalny, 
			VaN_Rolnik , 
			VaN_Detal, 
			VaN_Fiskalna, 
			VaN_Wewnetrzna, 
			VaN_RozliczacVATUE, 
			VaN_PodatekVat, 
			0, 	--VaT_RodzajZakupu, 
			0, 	--RodzajZakupu , 
			0, 	--VaT_Odliczenia , 
			0, 	--VaT_Flaga , 
			0, 	--VaT_Stawka, 
			'', --KodStawki, 
			VatZD, 
			VaN_ZakID,

			--first stage
			Sum(ZakBiezTrwOpodNetto),
			sum(ZakBiezTrwOpodVat),
			sum(ZakBiezTrwMieszNetto),
			sum(ZakBiezTrwMieszVat),
			sum(ZakBiezNierMieszNetto),
			sum(ZakBiezNierMieszVat),
			sum(ZakBiezTrw15MieszNetto),
			sum(ZakBiezTrw15MieszVat),
			sum(ZakBiezNi15MieszNetto),
			sum(ZakBiezNi15MieszVat),
			sum(ZakBiezInnOpodNetto),
			sum(ZakBiezInnOpodVat),
			sum(ZakBiezInnMieszNetto),
			sum(ZakBiezInnMieszVat),
			sum(SprzedazZwolniona),
			sum(TowaryUslugiPozaKrajem),
			sum(TowaryUslugiPozaKrajemA),
			sum(SprzedazNetto0),
			sum(SprzedazNetto0_art129),
			sum(SprzedazNetto3),
			sum(SprzedazVat3),
			sum(SprzedazNetto7),
			sum(SprzedazVat7),
			sum(SprzedazNetto22),
			sum(SprzedazVat22),
			sum(SprzedazWewnatrzWsp),
			sum(SprzedazNettoExport0),
			sum(ZakupyWewnatrzWspNetto),
			sum(ZakupyWewnatrzWspVat),
			sum(ImportTowarowArt33aNetto),
			sum(ImportTowarowArt33aVAT),
			sum(ImportUslugNetto),
			sum(ImportUslugVat),
			sum(ImportUslugNettoA),
			sum(ImportUslugVatA),
			sum(DostawaKrajPlatnikNetto),
			sum(DostawaKrajPodatnikNabywcaNetto),
			sum(DostawaKrajPodatnikNabywcaVat),
			sum(DostawaUslugPodatnikNabywcaNetto),
			sum(DostawaUslugPodatnikNabywcaVat),

			sum(SwiadczenieUslugNetto),
			sum(SwiadczenieUslugVat),
						
			--SpisZNaturyVat
			0,
			-- ZwrotKwotyNazakupKas
			0,		
			sum(WWNabycieSrTranspVat),
			
			--secound stage
			
			--ZakupyTrwaleNetto,	42
			sum(ZakBiezTrwOpodNetto) + @Wspolczynnik * sum(ZakBiezTrwMieszNetto + ZakBiezNierMieszNetto + ZakBiezTrw15MieszNetto + ZakBiezNi15MieszNetto),
			--ZakupyTrwaleVat		43
			sum(ZakBiezTrwOpodVat) + @Wspolczynnik * sum(ZakBiezTrwMieszVat + ZakBiezNierMieszVat + ZakBiezTrw15MieszVat + ZakBiezNi15MieszVat),
			
			--ZakupyInneNetto		44
			sum(ZakBiezInnOpodNetto) + @Wspolczynnik * sum(ZakBiezInnMieszNetto),
			
			--ZakupyInneVat			45
			sum(ZakBiezInnOpodVat) + @Wspolczynnik * sum(ZakBiezInnMieszVat),
			
			--KorektaTrwaleVat,		46
			0, 
			--KorektaInneVat,		47
			0, 
			--KorektaPodatku89b,	48
			0, 
			--KorektaPodatku89b_u4
			0
					
			from CDN.DeklaracjaVAT7v21(@y, @m, @Nieokreslony,@Typ,@CalyKwartal, @WliczacNP, @ObliczPola, 1)		
			where VaN_Typ = @REJESTR_ZAKUPOW and VaT_Odliczenia <> 0 and VaT_Flaga <> 4 and VaT_Flaga <> 1 and (@UwzglednijStawke_0 <> 0 or @UwzglednijStawke_0 = 0 and VaT_Stawka <> 0)
			--where VaN_Typ = @REJESTR_ZAKUPOW and VatZD = 0 and VaT_Odliczenia <> 0 and VaT_Flaga <> 4 and VaT_Flaga <> 1 and (@UwzglednijStawke_0 <> 0 or @UwzglednijStawke_0 = 0 and VaT_Stawka <> 0)
			group by
			VaN_VaNID, 
			VaN_Lp, 
			VaN_RokMies ,
			VaN_DataZap , 
			VaN_Dokument , 
			VaN_IdentKsieg, 
			VaN_KntNazwa1 ,
			VaN_Kategoria, 
			VaN_Rejestr, 
			VaN_Typ, 
			VaN_DeklRokMies, 
			Va7_RokMiesiac,
			VaN_KpRID, 
			VaN_RycID, 
			VaN_DekID , 
			VaN_KntNipE, 
			VaN_KntNipKraj, 
			VaN_Pesel,
			VaN_Export, 
			VaN_Finalny, 
			VaN_Rolnik , 
			VaN_Detal, 
			VaN_Fiskalna, 
			VaN_Wewnetrzna, 
			VaN_RozliczacVATUE, 
			VaN_PodatekVat, 
			VatZD, 
			VaN_ZakID;
			
		else
			insert into @Wyniki (
			VaN_VaNID, 
			VaN_Lp , 
			VaN_RokMies ,
			VaN_DataZap , 
			VaN_Dokument , 
			VaN_IdentKsieg, 
			VaN_KntNazwa1 ,
			VaN_Kategoria, 
			Netto, 
			VAT, 
			VaN_Rejestr, 
			VaN_Typ, 
			VaN_DeklRokMies, 
			Va7_RokMiesiac,
			VaN_KpRID, 
			VaN_RycID, 
			VaN_DekID , 
			VaN_KntNipE, 
			VaN_KntNipKraj, 
			VaN_Pesel,
			VaN_Export, 
			VaN_Finalny, 
			VaN_Rolnik , 
			VaN_Detal, 
			VaN_Fiskalna, 
			VaN_Wewnetrzna, 
			VaN_RozliczacVATUE, 
			VaN_PodatekVat, 
			VaT_RodzajZakupu, 
			RodzajZakupu , 
			VaT_Odliczenia , 
			VaT_Flaga , 
			VaT_Stawka, 
			KodStawki, 
			VatZD, 
			VaN_ZakID,

			--first stage
			ZakBiezTrwOpodNetto,
			ZakBiezTrwOpodVat,
			ZakBiezTrwMieszNetto,
			ZakBiezTrwMieszVat,
			ZakBiezNierMieszNetto,
			ZakBiezNierMieszVat,
			ZakBiezTrw15MieszNetto,
			ZakBiezTrw15MieszVat,
			ZakBiezNi15MieszNetto,
			ZakBiezNi15MieszVat,
			ZakBiezInnOpodNetto,
			ZakBiezInnOpodVat,
			ZakBiezInnMieszNetto,
			ZakBiezInnMieszVat,
			SprzedazZwolniona,
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
			
			SwiadczenieUslugNetto,
			SwiadczenieUslugVat,
			
			
			SpisZNaturyVat,			-- 0
			ZwrotKwotyNazakupKas,	-- 0
					
			WWNabycieSrTranspVat,
			
			
			
			--secound stage
			ZakupyTrwaleNetto,
			ZakupyTrwaleVat,
			ZakupyInneNetto,
			ZakupyInneVat,
			
			KorektaTrwaleVat,
			KorektaInneVat,
			KorektaPodatku89b,
			KorektaPodatku89b_u4
					
			)
			select 
			VaN_VaNID, 
			VaN_Lp , 
			VaN_RokMies ,
			VaN_DataZap , 
			VaN_Dokument , 
			VaN_IdentKsieg, 
			VaN_KntNazwa1 ,
			VaN_Kategoria, 
			Sum(IsNull(Netto,0)), 
			Sum(IsNull(VAT,0)), 
			VaN_Rejestr, 
			VaN_Typ, 
			VaN_DeklRokMies, 
			Va7_RokMiesiac,
			VaN_KpRID, 
			VaN_RycID, 
			VaN_DekID , 
			VaN_KntNipE, 
			VaN_KntNipKraj, 
			VaN_Pesel,
			VaN_Export, 
			VaN_Finalny, 
			VaN_Rolnik , 
			VaN_Detal, 
			VaN_Fiskalna, 
			VaN_Wewnetrzna, 
			VaN_RozliczacVATUE, 
			VaN_PodatekVat, 
			0, 	--VaT_RodzajZakupu, 
			0, 	--RodzajZakupu , 
			0, 	--VaT_Odliczenia , 
			0, 	--VaT_Flaga , 
			0, 	--VaT_Stawka, 
			'', --KodStawki, 
			VatZD, 
			VaN_ZakID,

			--first stage
			Sum(ZakBiezTrwOpodNetto),
			sum(ZakBiezTrwOpodVat),
			sum(ZakBiezTrwMieszNetto),
			sum(ZakBiezTrwMieszVat),
			sum(ZakBiezNierMieszNetto),
			sum(ZakBiezNierMieszVat),
			sum(ZakBiezTrw15MieszNetto),
			sum(ZakBiezTrw15MieszVat),
			sum(ZakBiezNi15MieszNetto),
			sum(ZakBiezNi15MieszVat),
			sum(ZakBiezInnOpodNetto),
			sum(ZakBiezInnOpodVat),
			sum(ZakBiezInnMieszNetto),
			sum(ZakBiezInnMieszVat),
			sum(SprzedazZwolniona),
			sum(TowaryUslugiPozaKrajem),
			sum(TowaryUslugiPozaKrajemA),
			sum(SprzedazNetto0),
			sum(SprzedazNetto0_art129),
			sum(SprzedazNetto3),
			sum(SprzedazVat3),
			sum(SprzedazNetto7),
			sum(SprzedazVat7),
			sum(SprzedazNetto22),
			sum(SprzedazVat22),
			sum(SprzedazWewnatrzWsp),
			sum(SprzedazNettoExport0),
			sum(ZakupyWewnatrzWspNetto),
			sum(ZakupyWewnatrzWspVat),
			sum(ImportTowarowArt33aNetto),
			sum(ImportTowarowArt33aVAT),
			sum(ImportUslugNetto),
			sum(ImportUslugVat),
			sum(ImportUslugNettoA),
			sum(ImportUslugVatA),
			sum(DostawaKrajPlatnikNetto),
			sum(DostawaKrajPodatnikNabywcaNetto),
			sum(DostawaKrajPodatnikNabywcaVat),
			sum(DostawaUslugPodatnikNabywcaNetto),
			sum(DostawaUslugPodatnikNabywcaVat),
			
			sum(SwiadczenieUslugNetto),
			sum(SwiadczenieUslugVat),
			
			--SpisZNaturyVat
			0,
			-- ZwrotKwotyNazakupKas
			0,		
			sum(WWNabycieSrTranspVat),
			--secound stage
			
			--ZakupyTrwaleNetto,
			sum(ZakBiezTrwOpodNetto) + @Wspolczynnik * sum(ZakBiezTrwMieszNetto + ZakBiezNierMieszNetto + ZakBiezTrw15MieszNetto + ZakBiezNi15MieszNetto),
			--ZakupyTrwaleVat
			sum(ZakBiezTrwOpodVat) + @Wspolczynnik * sum(ZakBiezTrwMieszVat + ZakBiezNierMieszVat + ZakBiezTrw15MieszVat + ZakBiezNi15MieszVat),
			
			--ZakupyInneNetto
			sum(ZakBiezInnOpodNetto) + @Wspolczynnik * sum(ZakBiezInnMieszNetto),
			
			--ZakupyInneVat
			sum(ZakBiezInnOpodVat) + @Wspolczynnik * sum(ZakBiezInnMieszVat),
			
			--KorektaTrwaleVat,
			0, 
			--KorektaInneVat,
			0, 
			--KorektaPodatku89b,
			0, 
			--KorektaPodatku89b_u4
			0
					
			from CDN.DeklaracjaVAT7v21(@y, @m, @Nieokreslony,@Typ,@CalyKwartal, @WliczacNP, @ObliczPola, 1)		
			where VaN_Typ = @REJESTR_SPRZEDAZY and VatZD = 0
			group by
			VaN_VaNID, 
			VaN_Lp, 
			VaN_RokMies ,
			VaN_DataZap , 
			VaN_Dokument , 
			VaN_IdentKsieg, 
			VaN_KntNazwa1 ,
			VaN_Kategoria, 
			VaN_Rejestr, 
			VaN_Typ, 
			VaN_DeklRokMies, 
			Va7_RokMiesiac,
			VaN_KpRID, 
			VaN_RycID, 
			VaN_DekID , 
			VaN_KntNipE, 
			VaN_KntNipKraj, 
			VaN_Pesel,
			VaN_Export, 
			VaN_Finalny, 
			VaN_Rolnik , 
			VaN_Detal, 
			VaN_Fiskalna, 
			VaN_Wewnetrzna, 
			VaN_RozliczacVATUE, 
			VaN_PodatekVat, 
			VatZD, 
			VaN_ZakID
			
		
		if (@m = 12)
		begin
			set @y = @y + 1;
			set @m = 1;
		end
		set @rokMiesiac = @rokMiesiac + 1
		
		
	end;

	-- usuniÄ™cie duplikatĂłw
	WITH CTE AS(
	SELECT	VaN_VaNID, RN = ROW_NUMBER() OVER(PARTITION BY VaN_VaNID, VaT_Odliczenia, VaT_Flaga, VaT_Stawka, VatZD ORDER BY VaN_VaNID)
	FROM @Wyniki
	)
	DELETE FROM CTE WHERE RN > 1

return 
end
