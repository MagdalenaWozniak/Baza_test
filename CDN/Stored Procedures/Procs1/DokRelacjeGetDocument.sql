CREATE PROCEDURE CDN.DokRelacjeGetDocument(@typDok INT, @dokId INT)
AS
BEGIN
	SET NOCOUNT OFF;
IF @typDok = 101
BEGIN
	SELECT TOP 1 EDN_NumerPelny As NumerDok,
	'EDK' As TypDok,
	''    As OpisDok,
	EdN_DataDok As DataDok,
	''  As PodmiotDok,
	''  As RodzajDok
	FROM cdn.EwidDodNag WHERE  EDN_EDNID = @dokId
	GOTO KONIEC
END
IF @typDok = 111  -- Potwierdzenie salda KH
BEGIN
	SELECT TOP 1
	KDN_NumerPelny As NumerDok,
	'PS-KH' As TypDok,
	CONVERT(NVARCHAR(255), KDN_Opis, 120) As OpisDok,
	KDN_DataDok As DataDok,
    CONVERT(NVARCHAR(20), KDN_KontoNazwa, 120) As PodmiotDok,
	''  As RodzajDok
	FROM cdn.KsiDokNag
	WHERE KDN_KDNId = @dokId
	GOTO KONIEC
END
IF @typDok = 112  -- Ponaglenie zapłaty KH
BEGIN
	SELECT TOP 1
	KDN_NumerPelny As NumerDok,
	'PZAP' As TypDok,
	CONVERT(NVARCHAR(255), KDN_Opis, 120) As OpisDok,
	KDN_DataDok As DataDok,
    CONVERT(NVARCHAR(20), KDN_KontoNazwa, 120) As PodmiotDok,
	''  As RodzajDok
	FROM cdn.KsiDokNag
	WHERE KDN_KDNId = @dokId
	GOTO KONIEC
END
IF @typDok = 113  -- Nota odsetkowa KH
BEGIN
	SELECT TOP 1
	KDN_NumerPelny As NumerDok,
	'NO-KH' As TypDok,
	CONVERT(NVARCHAR(255), KDN_Opis, 120) As OpisDok,
	KDN_DataDok As DataDok,
    CONVERT(NVARCHAR(20), KDN_KontoNazwa, 120) As PodmiotDok,
	''  As RodzajDok
	FROM cdn.KsiDokNag
	WHERE KDN_KDNId = @dokId
	GOTO KONIEC
END
IF @typDok = 114  -- Delegacje
BEGIN
	SELECT TOP 1
	DLN_NumerPelny As NumerDok,
	'DELEG' As TypDok,
	CONVERT(NVARCHAR(255), DLN_Opis, 120) As OpisDok,
	DLN_DataDok As DataDok,
    CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
	''  As RodzajDok
	FROM cdn.DlgNag
	LEFT OUTER JOIN cdn.PodmiotyView on DLN_PodmiotId = pod_podid and DLN_PodmiotTyp = pod_podmiottyp
	WHERE DLN_DLNId = @dokId
	GOTO KONIEC
END

IF @typDok = 221 OR @typDok = 1130 -- Nota odsetkowa KB
BEGIN
	SELECT TOP 1
	NON_NumerPelny As NumerDok,
	'NO-KB' As TypDok,
	CONVERT(NVARCHAR(255), NON_Uwagi, 120) As OpisDok,
	NON_DataDok As DataDok,
    CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
	''  As RodzajDok
	FROM cdn.NotyOdsNag
	LEFT OUTER JOIN cdn.PodmiotyView on NON_PodmiotID = pod_podid and NON_PodmiotTyp = pod_podmiottyp
	WHERE NON_NONId = @dokId
	GOTO KONIEC
END

IF @typDok = 222 OR @typDok = 223  OR  @typDok = 1134  -- Potwierdzenie salda KB
BEGIN
	SELECT TOP 1
	BDN_NumerPelny As NumerDok,
	CASE BDN_Typ WHEN 222 THEN 'PON' WHEN 223 THEN 'NO' WHEN 1134 THEN 'PS-KB' ELSE '' END As TypDok,
	CONVERT(NVARCHAR(255), BDN_Uwagi, 120) As OpisDok,
	BDN_DataDok As DataDok,
    CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
	''  As RodzajDok
	FROM CDN.BnkDokNag
	LEFT OUTER JOIN cdn.PodmiotyView on BDN_PodmiotID = pod_podid and BDN_PodmiotTyp = pod_podmiottyp
	WHERE BDN_BDNId = @dokId
	GOTO KONIEC
END



	IF @typDok = 700 --  e_OP_KlasaCRM
	BEGIN
		SELECT TOP 1 CrK_NumerPelny As NumerDok,
               'CRM' As TypDok,
               CASE CONVERT(NVARCHAR(255),CRK_Temat) WHEN '' THEN CONVERT(NVARCHAR(255),CRK_Opis) ELSE CONVERT(NVARCHAR(255),CRK_Temat) END As OpisDok,
               CONVERT(VARCHAR(10), CrK_DataDok, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
               CASE CRK_Zadanie WHEN 1 THEN 'Z' ELSE 'K' END As RodzajDok
               FROM cdn.CrmKontakty left outer join cdn.podmiotyview on crk_podid = pod_podid and crk_podmiottyp = pod_podmiottyp Where CrK_CrKId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 710 --  e_OP_KlasaAnkieta
	BEGIN
		SELECT TOP 1 AnkAnN_NumerPelny As NumerDok,
               'ANK' As TypDok,
               CASE CONVERT(NVARCHAR(255),AnKAnN_Nazwa) WHEN '' THEN CONVERT(NVARCHAR(255),AnKAnN_Opis) ELSE CONVERT(NVARCHAR(255),AnKAnN_Nazwa) END As OpisDok,
               CONVERT(VARCHAR(10), AnKAnN_DataDok, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
               ''  As RodzajDok
               FROM cdn.AnkAnkietyNag left outer join cdn.podmiotyview on AnkAnN_podid = pod_podid and AnkAnN_PodmiotTyp = Pod_PodmiotTyp Where AnkAnN_AnkAnNId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 714 --  e_OP_KlasaWzorzecAnkiety
	BEGIN
		SELECT TOP 1 AnkWaN_Kod As NumerDok,
               'WZ_ANK' As TypDok,
               CONVERT(NVARCHAR(255),AnkWaN_Nazwa) As OpisDok,
               CONVERT(VARCHAR(10), AnkWaN_TS_Zal, 120) As DataDok,
               '' As PodmiotDok,
               '' As RodzajDok
               FROM cdn.AnkWzorzecAnkietyNag WHERE AnkWaN_AnkWaNId = @dokId
		GOTO KONIEC
	END


	IF @typDok = 750 --  e_OP_KlasaSEK
	BEGIN
		SELECT TOP 1 DNV_NumerPelny As NumerDok,
               'OBD'  As TypDok,
               CONVERT(NVARCHAR(255), DnV_Tytul) As OpisDok,
               CONVERT(VARCHAR(10), DnV_DataDok, 120) As DataDok,
			   cdn.DokNagKontrahent(DnV_Typ, DnV_DoNID) As PodmiotDok,
		       '' As RodzajDok
               FROM cdn.DokNagView Where DnV_Typ = 1 AND DnV_DoNId = @dokId

		GOTO KONIEC
	END

	IF @typDok = 752 --  archiwum wydruków
	BEGIN
		SELECT TOP 1 'wydruk' As NumerDok,
               'RPT'  As TypDok,
               WdKE_PrnFileName As OpisDok,
               WdKE_PrnDate As DataDok,
               ''		As PodmiotDok,
			   LTRIM(RTRIM(Str(WdKE_Flaga))) As RodzajDok
               FROM cdn.WdrKopieElektroniczne Where WdKE_WdKEId = @dokId

		GOTO KONIEC
	END
	IF @typDok = 800 --  e_op_KlasaOferta
	BEGIN
		SELECT TOP 1 OfD_NumerPelny As NumerDok,
				'OFERTA' As TypDok,
				CONVERT(NVARCHAR(255), OfD_Nazwa) As OpisDok,
				CONVERT(VARCHAR(10), OfD_DataDok, 120) As DataDok,
				(SELECT TOP 1 Pod_Kod FROM  cdn.PodmiotyView LEFT OUTER JOIN cdn.OfertyKnt ON OfK_PodID = Pod_PodId and OfK_PodmiotTyp = Pod_PodmiotTyp WHERE OfK_OfDId = OfD_OfDID)  As PodmiotDok,
				''  As RodzajDok
				FROM cdn.OfertyDok
				LEFT OUTER JOIN cdn.OfertyKnt ON OfD_OfDID = OfK_OfDId
				LEFT OUTER JOIN cdn.PodmiotyView ON OfK_PodID = Pod_PodId and OfK_PodmiotTyp = Pod_PodmiotTyp
				WHERE OfD_OfDID = @dokId
		GOTO KONIEC
	END

	IF @typDok = 900 --  e_op_KlasaSerwis
	BEGIN
		SELECT TOP 1 SrZ_NumerPelny As NumerDok,
               'SRW' As TypDok,
               CONVERT(NVARCHAR(255), SrZ_Opis) As OpisDok,
               CONVERT(VARCHAR(10), SrZ_DataDok, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
	''  As RodzajDok
               FROM cdn.SrsZlecenia left outer join cdn.podmiotyview on srz_podmiotid = pod_podid and srz_podmiottyp = pod_podmiottyp Where SrZ_SrZId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 904 --  urządzenie serwisowe
	BEGIN
		SELECT TOP 1 SrU_Kod As NumerDok,
               'SRU' As TypDok,
               CONVERT(NVARCHAR(255), SrU_Nazwa) As OpisDok,
               '' As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
				''  As RodzajDok
		FROM cdn.SrsUrzadzenia LEFT OUTER JOIN cdn.PodmiotyView ON SrU_PodmiotId = Pod_PodId and SrU_PodmiotTyp = Pod_PodmiotTyp
		WHERE SrU_SrUId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 999   -- e_op_KlasaRejestrVat   ! 999
	BEGIN
		SELECT TOP 1 VaN_Dokument As NumerDok,
               'VAT' As TypDok,
               '' As OpisDok,
               CONVERT(VARCHAR(10), VaN_DataZap, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
				''  As RodzajDok
               From cdn.VATNag left outer join cdn.podmiotyview on van_podid = pod_podid and van_podmiottyp = pod_podmiottyp Where VaN_VaNId = @dokId
		GOTO KONIEC
	END
	IF @typDok IN (1000, 1001)
	BEGIN
		SELECT TOP 1
		case DKB_NumerPelny when '' then DKB_Numer else DKB_NumerPelny end  As NumerDok,
		case DKB_TypDokumentuKB when 2 then case DKB_Kierunek when -1 then 'ZKB-KW' else 'ZKB-KP' end
		when 1 then 'PP' end As TypDok,
		DkB_DataDok As DataDok,
		DkB_Opis As OpisDok,
		''  As PodmiotDok,
		''  As RodzajDok
		FROM cdn.DokumentyKBView
		WHERE ( Dkb_TypDokumentuKB=2 or @typDok<>1000) AND --Dok ZKB
			  ( Dkb_TypDokumentuKB=1 or @typDok<>1001) AND --Dok PP
	    		Dkb_DkbId = @dokId
		GOTO KONIEC
	END
IF @typDok = 1002
BEGIN
	SELECT BDN_NumerPelny As NumerDok,
	case BDN_Typ when 222 then 'PON' when 223 then 'NO' else '' end As TypDok,
	BdN_DataDok As DataDok,
	BdN_Uwagi As OpisDok,
    CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
	''  As RodzajDok
	FROM cdn.BnkDokNag
	LEFT OUTER JOIN cdn.PodmiotyView on BdN_PodmiotID = Pod_PodId and BdN_PodmiotTyp = Pod_PodmiotTyp
	WHERE BDN_BDNId  = @dokId
	AND  ( (BDN_Typ = 222) or --PO
    		(BDN_Typ = 223)   )  --NO
	GOTO KONIEC
END

	IF @typDok = 1003 --  e_op_KlasaEwidencjaDodatkowa
	BEGIN
		SELECT TOP 1 EDN_NumerPelny As NumerDok,
               'EwD' As TypDok,
               '' As OpisDok,
               CONVERT(VARCHAR(10), EDN_DataDok, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
				''  As RodzajDok
               FROM cdn.EwidDodNag LEFT OUTER JOIN cdn.PodmiotyView on EDN_podid = Pod_PodId and EDN_podmiottyp = Pod_PodmiotTyp Where EDN_EDNId = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1004 --  e_op_KlasaSrodkiTrwale
	BEGIN
		SELECT TOP 1 SrT_NrInwent As NumerDok,
               'ŚrT' As TypDok,
               CONVERT(NVARCHAR(255),SrT_Nazwa) As OpisDok,
               CONVERT(VARCHAR(10), SrT_DataZak, 120) As DataDok,
               '' As PodmiotDok,
				''  As RodzajDok
               From cdn.Trwale
               Where SrT_SrTId = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1005 --  e_op_KlasaWyposazenie
	BEGIN
		SELECT TOP 1 Wyp_NrInwent As NumerDok,
               'Wyp' As TypDok,
               CONVERT(NVARCHAR(255),Wyp_Nazwa) As OpisDok,
               CONVERT(VARCHAR(10), Wyp_DataZak, 120) As DataDok,
               '' As PodmiotDok,
				''  As RodzajDok
               From cdn.Wyposazenie
               Where Wyp_WypId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 1006 --  e_op_KlasaPolecenieKsiegowania
	BEGIN
		SELECT TOP 1 DeN_Dokument As NumerDok,
               'PK' As TypDok,
               CONVERT(NVARCHAR(255),DeN_Kategoria) As OpisDok,
               CONVERT(VARCHAR(10), DeN_DataDok, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
				''  As RodzajDok
               From cdn.DekretyNag left outer join cdn.podmiotyview on DeN_PodmiotId = Pod_PodId and DeN_podmiottyp = pod_podmiottyp
               Where DeN_DeNId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 1007 --  e_op_KlasaDokumentSrodkaTrwalego
	BEGIN
		SELECT TOP 1 SrH_Numer As NumerDok,
               'DŚrT' As TypDok,
               '' As OpisDok,
               CONVERT(VARCHAR(10), SrH_DataOpe, 120) As DataDok,
               '' As PodmiotDok,
				''  As RodzajDok
               From cdn.TrwaleHist
               Where SrH_SrHId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 1008 --  e_op_KlasaZapisKPIR
	BEGIN
		SELECT TOP 1 KPR_Dokument As NumerDok,
               'KPiR' As TypDok,
               CONVERT(NVARCHAR(255), KPR_Kategoria) As OpisDok,
               CONVERT(VARCHAR(10), KPR_DataOpe, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
				''  As RodzajDok
               From cdn.ZapisyKPR left outer join cdn.podmiotyview on KPR_PodId = Pod_PodId and KPR_PodmiotTyp = Pod_PodmiotTyp
               Where KPR_KPRId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 1009 --  e_op_KlasaZapisEwidencjiRycz
	BEGIN
		SELECT TOP 1 RYC_Dokument As NumerDok,
               'RYCZ' As TypDok,
               CONVERT(NVARCHAR(255), RYC_Kategoria) As OpisDok,
               CONVERT(VARCHAR(10), RYC_DataWpi, 120) As DataDok,
               '' As PodmiotDok,
				''  As RodzajDok
               From cdn.Ryczalt
               Where Ryc_RycId = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1102 --  bank
	BEGIN
		SELECT TOP 1 Pod_Kod As NumerDok,
               'KNT' As TypDok,
               CONVERT(NVARCHAR(255), Pod_Nazwa1) As OpisDok,
               '' As DataDok,
               Pod_Kod As PodmiotDok,
				''  As RodzajDok
               From cdn.PodmiotyView
               Where Pod_PodmiotTyp = 2 AND Pod_PodId = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1103 --  karta kontrahenta
	BEGIN
		SELECT TOP 1 Pod_Kod As NumerDok,
               'KNT' As TypDok,
               CONVERT(NVARCHAR(255), Pod_Nazwa1) As OpisDok,
               '' As DataDok,
               Pod_Kod As PodmiotDok,
				''  As RodzajDok
               From cdn.PodmiotyView
               Where Pod_PodmiotTyp = 1 AND Pod_PodId = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1105 --  urząd
	BEGIN
		SELECT TOP 1 Pod_Kod As NumerDok,
               'KNT' As TypDok,
               CONVERT(NVARCHAR(255), Pod_Nazwa1) As OpisDok,
               '' As DataDok,
               Pod_Kod As PodmiotDok,
				''  As RodzajDok
               From cdn.PodmiotyView
               Where Pod_PodmiotTyp = 5 AND Pod_PodId = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1119 --  zgody marketingowe
	BEGIN
		SELECT TOP 1
			   (SELECT TOP 1 RZT_Tytul FROM cdn.RejestracjaZgodTresc WHERE RZT_RZTId = PRZ_TrescZgodyId) As NumerDok,
               'ZGM' As TypDok,
			   (SELECT TOP 1 RZK_Nazwa FROM cdn.RejestracjaZgodKategorie WHERE RZK_RZKID IN (SELECT RZT_RZKID FROM cdn.RejestracjaZgodTresc WHERE RZT_RZTId = PRZ_TrescZgodyId)) As OpisDok,
               PRZ_DataWyrazenia As DataDok,
               PRZ_Akronim As PodmiotDok,
			   ''  As RodzajDok
               FROM cdn.PodmiotRejestracjaZgod
               WHERE PRZ_PRZID = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1172 --  treści zgód marketingowych
	BEGIN
		SELECT TOP 1
			   RZT_Tytul As NumerDok,
               'ZGMT' As TypDok,
			   RZT_Tresc As OpisDok,
               RZT_ObowiazujeOd As DataDok,
               N'' As PodmiotDok,
			   ''  As RodzajDok
               FROM cdn.RejestracjaZgodTresc
               WHERE RZT_RZTId = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1800 --  rejestr upoważnień
	BEGIN
		SELECT TOP 1
			   RUP_Opis As NumerDok,
               'RUP' As TypDok,
			   '' As OpisDok,
               RUP_DataNadania As DataDok,
               (SELECT TOP 1 POD_Kod FROM cdn.PodmiotyView WHERE Pod_PodmiotTyp = RUP_PodmiotTyp AND Pod_PodId = RUP_PodID) As PodmiotDok,
			   ''  As RodzajDok
               FROM cdn.RejestrUpowaznien
               WHERE RUP_RUPid = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1801 --  rejestr naruszeń
	BEGIN
		SELECT TOP 1
			   RUN_CharakterNaruszenia As NumerDok,
               'RUN' As TypDok,
			   '' As OpisDok,
               RUN_DataNaruszenia As DataDok,
               (SELECT TOP 1 POD_Kod FROM cdn.PodmiotyView WHERE Pod_PodmiotTyp = RUN_PodmiotTyp AND Pod_PodId = RUN_PodID) As PodmiotDok,
			   ''  As RodzajDok
               FROM cdn.RejestrNaruszen
               WHERE RUN_runid = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1802 --  rejestr czynności
	BEGIN
		SELECT TOP 1
			   RUC_Nazwa As NumerDok,
               'RUC' As TypDok,
			   ''   As OpisDok,
               RUC_PlanowanyTermin As DataDok,
               ''  As PodmiotDok,
			   ''  As RodzajDok
               FROM cdn.RejestrCzynnosci
               WHERE RUC_RUCiD = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1114 --  karta przedstawiciela
	BEGIN
		SELECT TOP 1 Pod_Kod As NumerDok,
               'KNT' As TypDok,
			   (SELECT TOP 1 KnO_Nazwisko FROM cdn.KntOsoby WHERE KnO_KnOId = @dokId) As OpisDok,
               '' As DataDok,
               Pod_Kod As PodmiotDok,
				''  As RodzajDok
               From cdn.PodmiotyView
               Where Pod_PodmiotTyp = 1 AND Pod_PodId IN (SELECT TOP 1 KnO_KntId FROM cdn.KntOsoby WHERE KnO_KnOId = @dokId)
		GOTO KONIEC
	END
	IF @typDok = 1122    -- raport kasowo-bankowy
	BEGIN
		SELECT TOP 1
		BRP_NumerPelny As NumerDok,
		'RKB' As TypDok,
		CONVERT(NVARCHAR(255), BRP_NumerObcy, 120) As OpisDok,
		BRP_DataDok As DataDok,
		''  As PodmiotDok,
		''  As RodzajDok
		FROM cdn.BnkRaporty
		WHERE BRP_BRPID = @dokId
		GOTO KONIEC
	END
	IF @typDok = 1145  -- Kompensaty
	BEGIN
		SELECT TOP 1
		KPN_NumerPelny As NumerDok,
		'KOMP' As TypDok,
		CONVERT(NVARCHAR(255), KPN_Opis, 120) As OpisDok,
		KPN_DataDok As DataDok,
		CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
		''  As RodzajDok
		FROM cdn.KompensatyNag
		LEFT OUTER JOIN cdn.PodmiotyView on KPN_PodmiotId = pod_podid and KPN_PodmiotTyp = pod_podmiottyp
		WHERE KPN_KPNId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 24000 --  pracownik
	BEGIN
            SELECT TOP 1 PRE_Kod As NumerDok,
               'PRC' As TypDok,
               PRE_Imie1 + ' ' + PRE_Imie2 + ' ' + PRE_Nazwisko As OpisDok,
               '' As DataDok,
               PRE_Kod As PodmiotDok,
               ''  As RodzajDok
               From cdn.PracEtaty
               WHERE PRE_PreId =  @dokId
		GOTO KONIEC
	END

	IF @typDok = 24100 --  wypłata
	BEGIN
		SELECT TOP 1 WPL_NumerPelny As NumerDok,
               'WPL' As TypDok,
               CONVERT(NVARCHAR(255), WPL_Nazwa) As OpisDok,
               CONVERT(VARCHAR(10), WPL_DataDok, 120) As DataDok,
               PrA_Kod As PodmiotDok,
				''  As RodzajDok
               FROM cdn.Wyplaty LEFT OUTER JOIN CDN.PracKod ON WPL_PraId = PRA_PraId
               WHERE  WPL_WPLId = @dokId
		GOTO KONIEC
	END


	IF @typDok = 24200 --  umowa
	BEGIN
		SELECT TOP 1 UMW_NumerPelny As NumerDok,
               'UMW' As TypDok,
               CONVERT(NVARCHAR(255), UMW_Tytul) As OpisDok,
               CONVERT(VARCHAR(10), UMW_DataDok, 120) As DataDok,
               PrA_Kod As PodmiotDok,
				''  As RodzajDok
               FROM cdn.Umowy LEFT OUTER JOIN CDN.PracKod ON UMW_PraId = PRA_PraId
               WHERE  UMW_UMWId = @dokId
		GOTO KONIEC
	END

	IF @typDok = 24300 --  lista płac
	BEGIN
				SELECT TOP 1 LPL_NumerPelny As NumerDok,
               'LPL' As TypDok,
               CONVERT(NVARCHAR(255), LPL_Nazwa) As OpisDok,
               CONVERT(VARCHAR(10), LPL_DataDok, 120) As DataDok,
               '' As PodmiotDok,
			   ''  As RodzajDok
               FROM cdn.ListyPlac
               WHERE  LPL_LPLId = @dokId
		GOTO KONIEC
	END


	IF @typDok > 30000 AND @typDok < 30402  --  VAT-7 i inne deklaracje
	BEGIN
		SELECT TOP 1 Str(DKN_RokMiesiac/100) + '-' + LTRIM(Str(DKN_RokMiesiac%100)) As NumerDok,
               'DKL' As TypDok,
               CDN.KsiegTypZrodla('DkN', DkN_DkNId)  As OpisDok,
               CONVERT(VARCHAR(10), DKN_Data, 120) As DataDok,
                ''  As PodmiotDok,
				''  As RodzajDok
               FROM cdn.DeklNag WHERE DkN_DkNID = @dokId
		GOTO KONIEC
	END

	IF @typDok = 351
  BEGIN
    SELECT TOP 1 Sent_NumerPelny As NumerDok,
    'SN' As TypDok,
    CONVERT(NVARCHAR(255), 'Zgłoszenie SENT, kod CN: ' + Sent_KodCN) As OpisDok,
    CONVERT(VARCHAR(10), Sent_DataDok, 120) As DataDok,
    CONVERT(NVARCHAR(20), Sent_PodNazwa)  As PodmiotDok,
    ''  As RodzajDok
    FROM cdn.SentZgloszenia WHERE  Sent_SentID = @dokId
    GOTO KONIEC
  END

	IF @typDok = 370 -- SendIt - zlecenie nadania przesyłki
	BEGIN
		SELECT TOP 1 SZL_NumerPelny As NumerDok,
              'ZNP' As TypDok,
              CONVERT(NVARCHAR(255),SZL_Uwagi) As OpisDok,
              CONVERT(VARCHAR(10), SZL_DataDok, 120) As DataDok,
              CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
			 ''  As RodzajDok
              From cdn.[SenditZleceniePrzesylki] LEFT OUTER JOIN cdn.PodmiotyView on [SZL_OdbID] = pod_podid AND [SZL_OdbiorcaTyp] = pod_podmiottyp
              Where SZL_SZLID = @dokId
		GOTO KONIEC
	END
	-- HaMag
	IF @typDok > 299 AND @typDok < 500
	BEGIN
		SELECT TOP 1 TrN_NumerPelny As NumerDok,
              CDN.TypDokumentu(TrN_TypDokumentu) As TypDok,
              CONVERT(NVARCHAR(255),TrN_Opis) As OpisDok,
              CONVERT(VARCHAR(10), TrN_DataDok, 120) As DataDok,
              CONVERT(NVARCHAR(20), Pod_Kod) As PodmiotDok,
			 ''  As RodzajDok
              From cdn.TraNag left outer join cdn.podmiotyview on trn_podid = pod_podid and trn_podmiottyp = pod_podmiottyp
              Where TrN_TrNId = @dokId
		GOTO KONIEC
	END

	SELECT '' As NumerDok,
           '' As TypDok,
           '' As OpisDok,
           '' As DataDok,
           '' As PodmiotDok,
           '' As RodzajDok

KONIEC:
	SET NOCOUNT OFF;
END
