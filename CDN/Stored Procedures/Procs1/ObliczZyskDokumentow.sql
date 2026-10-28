CREATE PROCEDURE [CDN].[ObliczZyskDokumentow]
@TrNId_List           TEXT,
@SymulacjaMarzyRodzaj INT, --0 -brak, 1 -MarzaWgOstatniejCenyZakupu 2- MarzaWgSredniejCenyZasobow
@MarzaMetodaWStu      INT,
@Tryb                 INT
AS
SET NOCOUNT ON
DECLARE @WartoscNetto DECIMAL(15,2)
DECLARE @WartoscNettoLocal DECIMAL(15,2)
DECLARE @WartoscZakupu DECIMAL(15,2)
DECLARE @WartoscZakupuLocal DECIMAL(15,2)
DECLARE @Marza DECIMAL(15,2)
DECLARE @ProcentMarzy DECIMAL(15,2)
DECLARE @IleDok INT
DECLARE @IleDokPoliczonych INT
DECLARE @IleDokDoWyliczenia INT
DECLARE @TrNID TABLE ( TrNId INT)
INSERT INTO @TrNID SELECT NextIdInt FROM  CDN.Text2TableInt ( @TrNId_List )
select @IleDok = count(*) from @TrNID
DECLARE @TrNID_ok TABLE ( TrNId INT)
INSERT INTO @TrNID_ok
SELECT TrNId FROM @TrNID JOIN CDN.TraNag ON TrNId = TrN_TrNId
WHERE
TrN_Korekta = 0 and TrN_Rodzaj NOT IN (302200, 302100,305100)
and TrN_Bufor != -1
DECLARE @TrNID_DokZWartZakupuZWZ TABLE ( TrNId INT)
INSERT INTO @TrNID_DokZWartZakupuZWZ
SELECT TrNId FROM @TrNID_ok
JOIN CDN.TraNag ON TrNId = TrN_TrNId
WHERE TrN_Bufor = 0 and (TrN_TypDokumentu in( 306,314)
or  (TrN_TypDokumentu = 302 and TrN_TrSTyp = 2) or
 (TrN_TypDokumentu = 305 and TrN_TrSTyp = 2) or
 (TrN_Rodzaj = 302004) or
 (TrN_Rodzaj =305004)
)
SELECT @IleDokPoliczonych = count(*) from @TrNID_DokZWartZakupuZWZ
DECLARE @TrNID_DokKtoreDoPrzeliczenia1 TABLE ( TrNId INT)
INSERT INTO @TrNID_DokKtoreDoPrzeliczenia1
SELECT TrNId FROM @TrNID_ok
EXCEPT
SELECT TrNId FROM @TrNID_DokZWartZakupuZWZ
DECLARE @TrNID_DokZWartZakupu TABLE ( TrNId INT)
INSERT INTO @TrNID_DokZWartZakupu
SELECT TrNId FROM @TrNID_ok JOIN CDN.TraNag ON TrNId = TrN_TrNId
WHERE TrN_WartoscZakupu > 0  and TrN_TrNID not in (select TrNId from @TrNID_DokZWartZakupuZWZ)
select @IleDokPoliczonych = @IleDokPoliczonych + count(*) from @TrNID_DokZWartZakupu
DECLARE @TrNID_DokKtoreDoPrzeliczenia TABLE ( TrNId INT)
INSERT INTO @TrNID_DokKtoreDoPrzeliczenia
SELECT TrNId FROM @TrNID_DokKtoreDoPrzeliczenia1
EXCEPT
SELECT TrNId FROM @TrNID_DokZWartZakupu
select @IleDokDoWyliczenia = count(*) from @TrNID_DokKtoreDoPrzeliczenia
DECLARE @TrNID_DokKtoreDoKorekt TABLE ( TrNId INT)
IF @SymulacjaMarzyRodzaj = 0
BEGIN
INSERT INTO @TrNID_DokKtoreDoKorekt
SELECT TrNId FROM @TrNID_ok
EXCEPT
SELECT TrNId FROM @TrNID_DokKtoreDoPrzeliczenia
DELETE FROM @TrNID_DokKtoreDoPrzeliczenia
select @IleDokDoWyliczenia = 0
END
ELSE
BEGIN
INSERT INTO @TrNID_DokKtoreDoKorekt
SELECT TrNId FROM @TrNID_ok
END
SELECT @WartoscNetto =  ISNULL(SUM(TrV_Netto),0)  FROM cdn.TraVat
WHERE Trv_Typ != 1  AND TrV_TrNID in (SELECT TrNId FROM @TrNID_DokZWartZakupu)
SELECT @WartoscNetto =  @WartoscNetto + ISNULL(SUM(TrV_Netto),0)  FROM cdn.TraVat
WHERE Trv_Typ != 1  AND TrV_TrNID in (SELECT TrNId FROM @TrNID_DokZWartZakupuZWZ)
SELECT @WartoscNetto =  @WartoscNetto + ISNULL(SUM(TrV_Netto),0)  FROM cdn.TraVat
WHERE Trv_Typ != 1  AND TrV_TrNID in (SELECT TrNId FROM @TrNID_DokKtoreDoPrzeliczenia)
SELECT @WartoscZakupu =  ISNULL(SUM(TrE_WartoscZakupu),0)  FROM cdn.TraElem
JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
WHERE Tre_Kaucja != 1  AND TrE_TrNID in (SELECT TrNId FROM @TrNID_DokZWartZakupuZWZ)
SELECT @WartoscZakupu =  @WartoscZakupu+ ISNULL(SUM(TrE_WartoscZakupu),0)  FROM cdn.TraElem
JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
WHERE Tre_Kaucja != 1  AND TrE_TrNID in (SELECT TrNId FROM @TrNID_DokZWartZakupu)
SELECT @WartoscZakupu = @WartoscZakupu + ISNULL(SUM(case when TrE_TwrTyp = 0 then  TrE_KosztUslugi ELSE tre_WartoscNetto END ),0)
FROM CDN.TraElem WHERE TrE_UslugaZlozonaId > 0 AND TrE_UslugaZlozonaId IN
(SELECT TrE_TrEID FROM cdn.TraElem
JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
WHERE Tre_Kaucja != 1 AND TrE_Uslugazlozona = 1
AND TrE_TrNID in (SELECT TrNId FROM @TrNID_DokZWartZakupu))
AND TrE_WartoscZakupu = 0
SELECT @WartoscZakupu = @WartoscZakupu + ISNULL(SUM(case when TrE_TwrTyp = 0 then  TrE_KosztUslugi ELSE tre_WartoscNetto END ),0)
FROM CDN.TraElem WHERE TrE_UslugaZlozonaId > 0 AND TrE_UslugaZlozonaId IN
(SELECT TrE_TrEID FROM cdn.TraElem
JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
WHERE Tre_Kaucja != 1 AND TrE_Uslugazlozona = 1
AND TrE_TrNID in (SELECT TrNId FROM @TrNID_DokKtoreDoPrzeliczenia))
SELECT @WartoscZakupu = @WartoscZakupu +
ISNULL(
SUM(
case when TrE_WartoscZakupu = 0 and TrE_TwrTyp = 1   then
case when TrE_WartoscZakupuwylicz = 0 and TrE_TwrTyp = 1   then
case when @SymulacjaMarzyRodzaj = 0 then 0
when @SymulacjaMarzyRodzaj = 2 AND ISNULL(SumaIlosc,0) != 0 then ISNULL(SumaWartosc/SumaIlosc,0) * TrE_Ilosc
ELSE OstatniaCenaZakupu * TrE_Ilosc
END
ELSE TrE_WartoscZakupuwylicz END
ELSE TrE_WartoscZakupu END
)
,0)
FROM
(SELECT TrE_Ilosc, TrE_WartoscZakupu,TrE_WartoscZakupuwylicz, TrE_TwrTyp,
(SELECT ROUND(ISNULL(TwC_Wartosc,0)*(Twr_KursL/Twr_KursM),case when Twr_CenaZCzteremaMiejscami = 1 then 4 ELSE 2 END)  FROM cdn.TwrCeny JOIN cdn.towary ON twc_twrid=twr_twrid WHERE TwC_TwrId = TrE_TwrId AND TwC_TwCNumer = 1 ) as OstatniaCenaZakupu,
(SELECT SUM(TwZ_Wartosc) FROM cdn.TwrZasoby  WHERE Twz_TwrId = TrE_TwrId) as SumaWartosc ,
(SELECT SUM(TwZ_Ilosc) FROM cdn.TwrZasoby  WHERE Twz_TwrId = TrE_TwrId) as SumaIlosc
FROM cdn.TraElem
JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
WHERE Tre_Kaucja != 1 AND Tre_Kaucja != 2 AND TrE_Uslugazlozona != 1 AND TrE_TrEID in (
SELECT TrE_TreID FROM CDN.TraElem where TrE_TrNID in  (SELECT TrNId FROM @TrNID_DokKtoreDoPrzeliczenia)
union all
select distinct TrE_TrEId from CDN.TraElem where TrE_TrNID in (SELECT TrNId FROM @TrNID_DokZWartZakupu)
AND TrE_WartoscZakupu = 0
)) a
IF (@Tryb != 0)
BEGIN
SET @WartoscNettoLocal = 0
SET @WartoscZakupuLocal = 0
SELECT @WartoscZakupuLocal = ISNULL(SUM(tre_wartosczakupu),0) FROM cdn.TraNag JOIN cdn.traelem ON tre_trnid = trn_trnid
JOIN
(
SELECT trn_trnid as trnid, TrR_FaId as  FaId FROM cdn.TraNag
JOIN cdn.TraNagRelacje ON TrR_TrNId = TrN_TrNID AND TrR_TrNTyp = 306 AND  TrN_TrNID < TrR_FaId
WHERE TrR_FaId in (SELECT TrNId FROM @TrNID_DokKtoreDoKorekt)  ) a ON trn_zwrid = trnid AND TrN_TrNID < FaId
WHERE TrN_Rodzaj in (306061,306071,306072)
AND TrE_TwrId in (SELECT tre_twrid FROM cdn.Traelem WHERE TrE_TrNId in (SELECT TrNId FROM @TrNID_DokKtoreDoKorekt))
SET @WartoscZakupu = @WartoscZakupu + @WartoscZakupuLocal
END
IF (@Tryb= 1)
BEGIN
SET @WartoscNettoLocal = 0
SET @WartoscZakupuLocal = 0
SELECT @WartoscNettoLocal = ISNULL(SUM(TrN_RazemNetto),0),@WartoscZakupuLocal = ISNULL(SUM(TrN_WartoscZakupu),0)
FROM CDN.TraNag WHERE TrN_ZwrId in ( SELECT TrNId FROM @TrNID_DokKtoreDoKorekt ) AND TrN_Bufor = 0 AND TrN_Rodzaj NOT IN (306061,306071,306072) AND TrN_TrNID > TrN_ZwrId
SET @WartoscZakupu = @WartoscZakupu + @WartoscZakupuLocal
SET @WartoscNetto = @WartoscNetto + @WartoscNettoLocal
END
IF (@Tryb = 2)
BEGIN
SET @WartoscNettoLocal = 0
SET @WartoscZakupuLocal = 0
SELECT @WartoscNettoLocal = ISNULL(SUM(TrN_RazemNetto),0) ,@WartoscZakupuLocal = ISNULL(SUM(TrN_WartoscZakupu),0)  FROM
(
SELECT TrN_RazemNetto,TrN_WartoscZakupu FROM CDN.TraNag
WHERE TrN_ZwrId in ( SELECT TrNId FROM @TrNID_DokKtoreDoKorekt ) AND TrN_Bufor = 0 AND TrN_Rodzaj in (306061,306071,306072) AND TrN_TrNID > TrN_ZwrId
union all
SELECT 0,TrN_WartoscZakupu FROM CDN.TraNag
JOIN CDN.TraNagRelacje ON TrR_FaId = TrN_ZwrID AND TrR_FaTyp = 304
WHERE  TrR_TrNId in ( SELECT TrNId FROM @TrNID_DokKtoreDoKorekt ) AND TrN_Rodzaj in (306061,306071,306072)
union all
SELECT TrN_RazemNetto,TrN_WartoscZakupu FROM CDN.TraNag
JOIN CDN.TraNagRelacje ON TrR_FaId = TrN_ZwrID AND TrR_FaTyp = 306
WHERE  TrR_TrNId in ( SELECT TrNId FROM @TrNID_DokKtoreDoKorekt ) AND TrN_Rodzaj in (306061,306071,306072) AND TrN_TrNID > TrR_TrNId
) as A
SET @WartoscZakupu = @WartoscZakupu + @WartoscZakupuLocal
SET @WartoscNetto = @WartoscNetto + @WartoscNettoLocal
END
IF (@Tryb = 3)
BEGIN
SET @WartoscNettoLocal = 0
SET @WartoscZakupuLocal = 0
SELECT @WartoscNettoLocal = ISNULL(SUM(trn_razemnetto),0) ,@WartoscZakupuLocal = ISNULL(SUM(trn_wartosczakupu),0)  FROM
(
SELECT TrN_RazemNetto,TrN_WartoscZakupu FROM CDN.TraNag
WHERE TrN_ZwrId in ( SELECT TrNId FROM @TrNID_DokKtoreDoKorekt ) AND TrN_Bufor = 0 AND TrN_TrNID > TrN_ZwrId
union all
SELECT 0,-kor.TrE_WartoscZakupu FROM CDN.TraElem Kor  JOIN CDN.TraNag ON Kor.TrE_TrNId = TrN_TrNID   JOIN CDN.TraElem Org ON Kor.TrE_ZwrId = Org.TrE_TrEID
WHERE TrN_ZwrId in ( SELECT TrNId FROM @TrNID_DokKtoreDoKorekt )   AND TrN_Bufor = 0 AND Org.TrE_UslugaZlozona = 1 AND trn_trnid > trn_zwrid
union all
SELECT 0,trn_wartosczakupu FROM CDN.TraNag
JOIN CDN.TraNagRelacje ON TrR_FaId = TrN_ZwrID AND TrR_FaTyp = 304 left JOIN cdn.dokrelacje ON DoR_DokumentTyp = TrR_FaTyp AND DoR_DokumentId = TrR_FaId
WHERE  TrR_TrNId in ( SELECT TrNId FROM @TrNID_DokKtoreDoKorekt ) AND DoR_DoRId is null
union all
SELECT trn_razemnetto,trn_wartosczakupu FROM CDN.TraNag
JOIN CDN.TraNagRelacje ON TrR_FaId = TrN_ZwrID AND TrR_FaTyp = 306
WHERE  TrR_TrNId in ( SELECT TrNId FROM @TrNID_DokKtoreDoKorekt )  AND TrN_Rodzaj in (306061,306071,306072) AND TrN_TrNID > TrR_TrNId
) as A
SET @WartoscZakupu = @WartoscZakupu + @WartoscZakupuLocal
SET @WartoscNetto = @WartoscNetto + @WartoscNettoLocal
END
SET @Marza = @WartoscNetto - @WartoscZakupu;
IF (@WartoscZakupu = 0 AND @WartoscNetto != 0)
SET @ProcentMarzy = 100;
ELSE
BEGIN
IF (@WartoscNetto = 0 AND @WartoscZakupu = 0)
SET @ProcentMarzy = 0;
ELSE
BEGIN
IF (@MarzaMetodaWStu = 0)
SET @ProcentMarzy = (@WartoscNetto/@WartoscZakupu-1)*100;
ELSE
IF (@WartoscNetto = 0)
SET @ProcentMarzy = 0;
ELSE
SET @ProcentMarzy = (1 - @WartoscZakupu/@WartoscNetto)*100;
END
END
SELECT @IleDok as IloscDok ,@IleDokPoliczonych+@IleDokDoWyliczenia as IloscDokObliczonych,  @WartoscZakupu as Koszt ,@WartoscNetto as WartoscNetto,@Marza as Marza, @ProcentMarzy as ProcentMarzy
