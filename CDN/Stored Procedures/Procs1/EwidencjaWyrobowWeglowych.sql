CREATE PROCEDURE [CDN].[EwidencjaWyrobowWeglowych]
@TypDok TEXT,
@PodID INT,
@PodTyp INT,
@Bufor INT,
@MagID INT,
@OpeID INT,
@TwrID INT,
@Pomijaj INT,
@CzyFinalnyWegiel INT,
@CzyZwolniony INT,
@CzyOpodatkowany INT,
@DataOd DateTime,
@DataDo DateTime,
@KtoraZakladka INT
AS
SET NOCOUNT ON
SELECT *
INTO #TypDok
FROM CDN.Text2TableInt(@TypDok)
IF @KtoraZakladka = 1
BEGIN
 DELETE FROM #TypDok WHERE NextIdInt in (303,307)
END
IF @KtoraZakladka = 2
BEGIN
 DELETE FROM #TypDok WHERE NextIdInt in (304,306,302)
END
declare  @CZyFS int
set @CZyFS = 0
if exists (SELECT * FROM #TypDok WHERE NextIdInt in (302))
 set @CZyFS = 1
CREATE TABLE   #IDPomin(ID INT, SUMA DECIMAL(15,4) )
IF @Pomijaj = 1
INSERT INTO #IDPomin(ID,SUMA)
SELECT
 WZ.TrN_TrNID,
 SUM(CONVERT(DECIMAL(15,4), ROUND(TrE_Ilosc * TrE_AkcyzaJMPomPrzelicznikM/TrE_AkcyzaJMPomPrzelicznikL,4)))
FROM CDN.TraElem
JOIN CDN.TraNag WZ ON TrE_TrNId = WZ.TrN_TrNID
--LEFT JOIN CDN.TraNagRelacje REL ON WZ.TrN_TrNID = REL.TrR_FaId AND REL.TrR_TrNTyp IN (306) AND REL.TrR_FaTyp IN (302)
--LEFT JOIN CDN.TraNag FA ON FA.TrN_TrNID =  REL.TrR_TrNId
LEFT JOIN CDN.TraNagRelacje REL2 ON WZ.TrN_TrNID = REL2.TrR_FaId AND REL2.TrR_TrNTyp IN (302) AND REL2.TrR_FaTyp IN (306)
WHERE WZ.TrN_ZwolnionyZAkcyzy = 1 AND TrE_AkcyzaOpal != 0
AND  WZ.Trn_TypDokumentu IN (SELECT NextIdInt FROM #TypDok )
AND (Tre_TwrID = @TwrID OR @TwrID=0)
AND (WZ.TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID AND @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID AND @PodTyp = 1 ) AND WZ.TrN_PodmiotTyp = @PodTyp OR @PodTyp = 0)
AND (WZ.TrN_Bufor = @Bufor OR @Bufor=2)
AND (WZ.TrN_OpeZalID = @OpeID OR @OpeID = 0)
AND (WZ.TrN_MagZrdID = @MagID  OR @MagID = 0)
AND WZ.TrN_DataOpe BETWEEN @DataOd AND @DataDo
AND WZ.TrN_Bufor <> -1 AND WZ.TrN_Korekta in (0,1)
AND (REL2.TrR_TrNId is NULL or (@CZyFS = 0 ))
group by  WZ.TrN_TrNID
SELECT
 WZ.TrN_Bufor as Bufor ,
 WZ.TrN_TypDokumentu as TypDokumentu,
 WZ.TrN_MagZrdId,
 WZ.TrN_NumerPelny as NrDokDost,
 convert(varchar(20),WZ.TrN_DataDok,23) as DataWyst,
  convert(varchar(20),WZ.TrN_AkcyzaDataRozpoczeciaPrzem,23) as DataWys,
 --case when ISNULL(FA.TrN_TypDokumentu,0) = 306 then FA.TrN_DataOpe else WZ.TrN_DataOpe END as DataWyd,
    case when  SUBSTRING(
        (
            SELECT top 1 FA.TrN_DataOpe
            FROM CDN.TraNagRelacje REL
   LEFT JOIN CDN.TraNag FA ON FA.TrN_TrNID =  REL.TrR_TrNId
   LEFT JOIN CDN.TraElem FAElem ON FAElem.TrE_TrNID =  REL.TrR_TrNId
            WHERE WZ.TrN_TrNID = REL.TrR_FaId and fAElem.TrE_Lppow = WZElem.tre_lppow AND REL.TrR_TrNTyp IN (306) AND REL.TrR_FaTyp IN (302) and FA.TrN_Korekta = 0
            ORDER BY FA.trn_trnid
            FOR XML PATH ('')
        ), 2, 1000) IS null then  convert(varchar(20), WZ.TrN_DataOpe,23) else
 SUBSTRING(
        (
        SELECT ','+convert(varchar(20), x.TrN_DataOpe,23)  AS [text()] from (
  SELECT distinct FA.TrN_DataOpe
            FROM CDN.TraNagRelacje REL
            LEFT JOIN CDN.TraNag FA ON FA.TrN_TrNID =  REL.TrR_TrNId
   LEFT JOIN CDN.TraElem FAElem ON FAElem.TrE_TrNID =  REL.TrR_TrNId
            WHERE WZ.TrN_TrNID = REL.TrR_FaId and fAElem.TrE_Lppow = WZElem.tre_lppow AND REL.TrR_TrNTyp IN (306) AND REL.TrR_FaTyp IN (302) and FA.TrN_Korekta = 0
            ) as x
   ORDER BY x.TrN_DataOpe
            FOR XML PATH ('')
        ), 2, 1000) end as DataWyd,
   '' as  DataWydEnter,
 WZ.TrN_PodNazwa1 + ' ' + WZ.TrN_PodKodPocztowy + ' ' + WZ.TrN_PodMiasto + ' ' + WZ.TrN_PodUlica + ' ' + WZ.TrN_PodNrDomu + case when WZ.TrN_PodNrLokalu <> '' then '/'+WZ.TrN_PodNrLokalu else '' END as DaneOdbiorcy,
 --FA.TrN_NumerPelny as NrDokFa,
 TrE_TwrId, TrE_TwrNazwa,
 TrE_KodCN,
 case when WZ.TrN_ZwolnionyZAkcyzy = 1 then CONVERT(DECIMAL(15,4),ROUND(TrE_Ilosc * TrE_AkcyzaJMPomPrzelicznikM/TrE_AkcyzaJMPomPrzelicznikL,4))*1000 else 0 END as IloscAkcyza,
 TrE_Akcyza_Wartosc,
 WZ.TrN_AkcyzaMiejsceOdbioru as Odbior,
 CONVERT(varchar(20),WZ.TrN_AkcyzaDataOdbioruOd,102  ) + case when WZ.TrN_AkcyzaDataOdbioruOd <> WZ.TrN_AkcyzaDataOdbioruDo then '-'+CONVERT(varchar(20),WZ.TrN_AkcyzaDataOdbioruDo,102  ) else '' END as ZakresOdbioru,
 WZ.TrN_AkcyzaMiejsceOdbioru as DataOdbioru,
 TrE_Jm,
 WZ.trn_trnid as TrNId,
 TrE_TrEID as TrEID,
 WZ.TrN_Korekta as Korekta,
 TrE_TwrId as twr_twrid,
 WZ.TrN_NumerString as NrDokDostNumerString,
 WZ.TrN_NumerNr as NrDokDostNumerNr,
 --ISNULL(FA.TrN_NumerString,'') as NrDokFaNumerString,ISNULL(FA.TrN_NumerNr,0) as NrDokFaNumerNr,
 case when WZ.TrN_ZwolnionyZAkcyzy = 1 then CONVERT(DECIMAL(15,4),ROUND(TrE_Ilosc * TrE_AkcyzaJMPomPrzelicznikM/TrE_AkcyzaJMPomPrzelicznikL,4)) else 0 END as IloscAkcyza1000KG,
 case when WZ.TrN_ZwolnionyZAkcyzy = 0 then CONVERT(DECIMAL(15,4),ROUND(TrE_Ilosc * TrE_AkcyzaJMPomPrzelicznikM/TrE_AkcyzaJMPomPrzelicznikL,4))*1000 else 0 END as IloscAkcyzaNieZwolniony,
 case when WZ.TrN_ZwolnionyZAkcyzy = 0 then CONVERT(DECIMAL(15,4),ROUND(TrE_Ilosc * TrE_AkcyzaJMPomPrzelicznikM/TrE_AkcyzaJMPomPrzelicznikL,4)) else 0 END as IloscAkcyza1000KGNieZwolniony
FROM cdn.TraElem WZElem
JOIN cdn.TraNag WZ ON TrE_TrNId = WZ.TrN_TrNID
--LEFT JOIN CDN.TraNagRelacje REL ON WZ.TrN_TrNID = REL.TrR_FaId AND REL.TrR_TrNTyp IN (306) AND REL.TrR_FaTyp IN (302)
--LEFT JOIN CDN.TraNag FA ON FA.TrN_TrNID =  REL.TrR_TrNId
LEFT JOIN CDN.TraNagRelacje REL2 ON WZ.TrN_TrNID = REL2.TrR_FaId AND REL2.TrR_TrNTyp IN (302) AND REL2.TrR_FaTyp IN (306)
WHERE ((WZ.TrN_ZwolnionyZAkcyzy = 1 AND @CzyZwolniony = 1) OR (@CzyOpodatkowany = 1 AND WZ.TrN_ZwolnionyZAkcyzy=0))
AND TrE_AkcyzaOpal != 0
AND  WZ.Trn_TypDokumentu IN (SELECT NextIdInt FROM #TypDok )
AND (Tre_TwrID = @TwrID OR @TwrID=0)
AND (WZ.TrN_PodID IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID AND @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID AND @PodTyp = 1 ) AND WZ.TrN_PodmiotTyp = @PodTyp OR @PodTyp = 0)
AND (WZ.TrN_Bufor = @Bufor OR @Bufor=2)
AND (WZ.TrN_OpeZalID = @OpeID OR @OpeID = 0)
AND (WZ.TrN_MagZrdID = @MagID  OR @MagID = 0)
AND WZ.TrN_DataOpe BETWEEN @DataOd AND @DataDo
AND WZ.TrN_Bufor <> -1 AND WZ.TrN_Korekta IN (0,1)
AND (REL2.TrR_TrNId is NULL or (@CZyFS = 0 ))
AND WZ.TrN_TrNID not IN (SELECT ID FROM #IDPomin WHERE ABS(SUMA) <= 0.2)
ORDER BY WZ.TrN_DataDok
SET NOCOUNT OFF
