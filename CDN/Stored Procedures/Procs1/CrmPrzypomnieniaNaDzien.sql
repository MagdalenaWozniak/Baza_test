CREATE PROCEDURE [CDN].[CrmPrzypomnieniaNaDzien]
    @OpiekunTyp AS INT,
    @OpiekunId  AS INT,
    @Date  AS DATETIME,
    @BazId AS INT
AS
BEGIN
	Declare @Dzis as datetime, @jutro as datetime, @jutroPrzypom as datetime;
	SET @Dzis = getdate();
	SET @jutro = cdn.DateOnly(DateAdd(d,1, getdate()))
	SET @jutroPrzypom = dateadd(d,1, getdate())
    SELECT DISTINCT
        CRK_CRKId AS Id
        ,null AS SrZId
		,ISNULL(CRC_TerminOd, CRK_TerminOd) AS TerminOd
        ,ISNULL(CRC_TerminDo, CRK_TerminDo) AS TerminDo
        ,CASE isnull(CRK_Temat, '') WHEN '' THEN CRK_NumerPelny ELSE CRK_Temat END AS Temat
        ,CRK_Opis AS Opis
        ,ISNULL(CRC_CzasPrzypomnienia, CRK_CzasPrzypomnienia) AS CzasPrzypomnienia
        ,'CRM' AS Typ
        ,@bazid  AS BazId
        ,@bazid  AS SrcBazId
        ,Pod_Kod AS Kontrahent
        ,isnull(CrC_CrCId, 0) AS ZadanieCykliczne
    FROM CDN.CRMKontakty
        JOIN CDN.CrmUczestnicy ON CrU_CrkId = CrK_CrKId
        LEFT JOIN CDN.CrmKontaktyCykl ON CrC_CrKId = CrK_CrKId AND CRC_Bufor = 1 AND CRC_Aktywny = 1
        JOIN CDN.PodmiotyView ON Pod_PodId = CrK_PodId AND Pod_PodmiotTyp = CrK_PodmiotTyp
    WHERE CRK_Zadanie = 1
        AND CrU_PodmiotTyp = @opiekunTyp
        AND CrU_PodmiotId = @opiekunId
		AND CRK_Przypomnienie = 1
		AND CRK_Bufor = 1
		AND (	(CRC_CRCID IS NULL     AND CRK_CzasPrzypomnienia < @jutroPrzypom)
			OR  (CRC_CRCID IS NOT NULL AND CRC_CzasPrzypomnienia < @jutroPrzypom) )

    UNION ALL
    SELECT SrY_SrYId AS Id
        ,SrZ_SrZId AS SrZId
        ,SrY_TerminOd AS TerminOd
        ,SrY_TerminOd AS TerminDo
        ,SrY_TwrNazwa AS Temat
        ,'' AS Opis
        ,SrY_CzasPrzypomnienia AS CzasPrzypomnienia
        ,'SRS' AS Typ
        ,@bazid  AS BazId
        ,@bazid  AS SrcBazId
        ,Pod_Kod AS Kontrahent
		,0 AS ZadanieCykliczne
     FROM CDN.SrsCzynnosci
        JOIN CDN.SrsZlecenia ON SrY_SrZId = SrZ_SrZId
        JOIN CDN.PodmiotyView ON Pod_PodId = SrZ_PodmiotId AND  Pod_PodmiotTyp = SrZ_PodmiotTyp
    WHERE SrY_Przypomnienie = 1
        AND SrY_Zakonczona = 0
        AND SrY_SerwisantTyp = @OpiekunTyp
        AND SrY_SerwisantID = @OpiekunId
        AND SrY_CzasPrzypomnienia < @jutro

    UNION ALL
    SELECT SrW_SrWId AS Id
        ,SrW_SrWId AS SrZId
        ,SrW_DataKolejnego AS TerminOd
        ,SrW_DataKolejnego AS TerminDo
        ,SrW_Nazwa AS Temat
        ,SrW_Opis AS Opis
        ,SrW_CzasPrzypomnienia AS CzasPrzypomnienia
        ,'SRW' AS Typ
        ,@bazid  AS BazId
        ,@bazid  AS SrcBazId
        ,Pod_Kod AS Kontrahent
		,0 AS ZadanieCykliczne
    FROM CDN.SrsCyklNag
        JOIN CDN.PodmiotyView ON Pod_PodId = SrW_PodmiotId AND  Pod_PodmiotTyp = SrW_PodmiotTyp
    WHERE SrW_Przypomnienie = 1
      AND SrW_CzasPrzypomnienia < dateadd(d,1, getdate())

    UNION ALL
    SELECT FcN_FcNId AS Id
        ,FcN_FcNId AS SrZId
        ,FCN_DataKolejnegoGen AS TerminOd
        ,FCN_DataKolejnegoGen AS TerminDo
        ,FcN_Nazwa AS Temat
        ,'' AS Opis
        ,FcN_CzasPrzypomnienia AS CzasPrzypomnienia
        ,'FAC' AS Typ
        ,@bazid  AS BazId
        ,@bazid  AS SrcBazId
        ,'' AS Kontrahent
		,0 AS ZadanieCykliczne
    FROM CDN.FaCyklNag
    WHERE
		FcN_Przypomnienie = 1 AND
		FcN_CzasPrzypomnienia < getdate() AND
		FcN_Nieaktywny=0

    UNION ALL
    SELECT DnPr_DnPrId AS Id
        ,DNV_DonID AS SrZId
        ,DnE_TerminOd AS TerminOd
        ,DnE_TerminDo AS TerminDo
        ,DnE_Nazwa AS Temat
        ,'' AS Opis
        ,DnE_CzasPrzypomnienia AS CzasPrzypomnienia
		,'SEK' + LTrim(RTrim(Str(DnV_Typ)))
        ,@bazid AS BazId
        ,case DnV_Typ when 2 then 0 else @bazid end AS SrcBazId
        ,'' AS Kontrahent
		,0 AS ZadanieCykliczne
    FROM CDN.DokNagProcesEtapyView
		JOIN cdn.DokNagEtapyView on DnE_Typ = DnPr_Typ and DnE_DnPrID = DnPr_DnPrId and DnE_OpeID = @OpiekunId
		JOIN cdn.DokNagView  on DnPr_Typ = DnV_Typ and DnPr_DoNId = DnV_DoNId and DnPr_Lp = DnV_EtapBiezacyLp
    WHERE DnE_Przypomnienie = 1
        AND DnE_Wykonany = 0
        -- AND DNV_OpiekunTyp = @OpiekunTyp
        -- AND DNV_OpiekunID = @OpiekunId
		AND DnE_OpeID = @OpiekunId
        AND DnE_CzasPrzypomnienia < dateadd(d,1, getdate())

    ORDER BY TerminOd
END
