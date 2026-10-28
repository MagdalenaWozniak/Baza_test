CREATE PROCEDURE CDN.DodajKorekteDoPZDlaNieokreslonejWartosci
  @TrN_TrNId_Zrd      INT,
  @TrN_Rodzaj_Doc     INT,
  @ServerCfgString    NVARCHAR(250),  -- nazwa serwera z bazą konfiguracyjną
  @BazaCfgString      NVARCHAR(250),  -- nazwa bazy konfiguracyjnej
  @TypDokMag          INT,
  @TypDokHandl        INT,
  @Seria              NVARCHAR(20)=''
AS
SET NOCOUNT ON
DECLARE
@TrEID INT,
@Lppow INT,
@IloscJM decimal(15, 4),
@WartoscNettoWal decimal(15, 2),
@WartoscBruttoWal decimal(15, 2),
@WartoscNetto decimal(15, 2),
@WartoscBrutto decimal(15, 2),
@TrNID INT,
@TrN_DDFId_Doc        INT,
@TrN_OpeZalId_Doc     INT,           -- Opertor zalogowany do programu, który wykonuje operację przekształcenia
@TrN_StaZalId_Doc     INT,           -- Sanowisko, z którego jest wykonywana operacja przekształcenia
@TrN_MagZrdId_Doc     INT,           -- TrN_MagZrdId dokumentu docelowego (może być null, jeśli @TrN_TrNId_Zrd IS NOT NULL )
@TrN_DataDok_Doc      DATETIME,      --
@TrN_DataDok_Ope      DATETIME,
@SeriaOperatora       NVARCHAR(5),
@RejestrOperatora     NVARCHAR(20),
@TrN_NumerString_Doc  NVARCHAR(31),
@TrN_NumerNr_Doc      INT,
@TrN_TrNId_Doc        INT,
@TypNB      INT,
@Komunikat            NVARCHAR(255),
@DataMin     datetime,
@NumerPelny     NVarchar(30) ,
@TypDokumentu    int
DECLARE @Roznice TABLE
    (
 Roz_LpPow int ,
 Roz_TwrId int ,
 Roz_IloscJM decimal(15, 4) ,
 Roz_WartoscNetto decimal(15, 2) ,
 Roz_WartoscBrutto decimal(15, 2) ,
 Roz_CenaWWD decimal(17, 4)  ,
 Roz_CenaT decimal(17, 4) ,
 Roz_WartoscNettoWal decimal(15, 2) ,
 Roz_WartoscBruttoWal decimal(15, 2) ,
 Roz_WartoscNettoRoznica decimal(15, 2) ,
 Roz_WartoscBruttoRoznica decimal(15, 2) ,
 Roz_WartoscNettoWalRoznica decimal(15, 2) ,
 Roz_WartoscBruttoWalRoznica decimal(15, 2)
 )
DECLARE @Wartosci TABLE
    (
 LpPow int ,
 WartoscNetto decimal(15, 2) ,
 WartoscBrutto decimal(15, 2) ,
 WartoscNettoWal decimal(15, 2) ,
 WartoscBruttoWal decimal(15, 2) ,
 CenaWWD decimal(17, 4),
 CenaT decimal(17, 4),
 lastID int
 )
DECLARE @TraElem TABLE
    (
 TrE_TrEID int,
 TrE_TrNId int,
 TrE_ZwrId int,
 TrE_TrEIdProd int,
 TrE_PdRId int,
 TrE_Lp int,
 TrE_LpPow int,
 TrE_LpPowRel int,
 TrE_TypDokumentu int,
 TrE_Aktywny tinyint,
 TrE_DataDok datetime,
 TrE_RabatPromocyjny decimal(15, 4),
 TrE_RabatKorekta decimal(15, 4),
 TrE_Promocje int,
 TrE_DataOpe datetime,
 TrE_PodmiotTyp smallint,
 TrE_PodID int,
 TrE_KatID int,
 TrE_TwrId int,
 TrE_MagId int,
 TrE_TwrNazwa nvarchar(255),
 TrE_TwrEAN nvarchar(40),
 TrE_TwrTyp tinyint,
 TrE_TwrKodDostawcy nvarchar(50),
 TrE_TwrNumerKat nvarchar(40),
 TrE_TwrKod nvarchar(50),
 TrE_TwrOpis nvarchar(1024),
 TrE_TwrSWW nvarchar(20),
 TrE_Stawka decimal(5, 2),
 TrE_Flaga smallint,
 TrE_Zrodlowa decimal(5, 2),
 TrE_TwCNumer int,
 TrE_TypNB tinyint,
 TrE_Cena0 decimal(17, 4),
 TrE_Rabat decimal(5, 2),
 TrE_CenaW decimal(17, 4),
 TrE_Waluta nvarchar(3),
 TrE_Kaucja tinyint,
 TrE_WyborDostaw tinyint,
 TrE_KursNumer int,
 TrE_KursL decimal(15, 4),
 TrE_KursM decimal(5, 0),
 TrE_CenaT decimal(17, 4),
 TrE_Ilosc decimal(15, 4),
 TrE_IloscKW decimal(15, 4),
 TrE_Jm nvarchar(20),
 TrE_JmZ nvarchar(20),
 TrE_JmCalkowite tinyint,
 TrE_JMPrzelicznikL decimal(15, 2),
 TrE_JMPrzelicznikM decimal(7, 0),
 TrE_IloscJM decimal(15, 4),
 TrE_IloscJMKW decimal(15, 4),
 TrE_WartoscNetto decimal(15, 2),
 TrE_WartoscBrutto decimal(15, 2),
 TrE_KosztUslugi decimal(15, 2),
 TrE_KosztKGO decimal(15, 2),
 TrE_Cena0WD decimal(17, 4),
 TrE_CenaWWD decimal(17, 4),
 TrE_WartoscNettoWal decimal(15, 2),
 TrE_WartoscBruttoWal decimal(15, 2),
 TrE_WartoscTymczasowa int,
 TrE_Atr1_DeAId int,
 TrE_Atr1_Kod nvarchar(20),
 TrE_Atr1_Wartosc nvarchar(100),
 TrE_Atr2_DeAId int,
 TrE_Atr2_Kod nvarchar(20),
 TrE_Atr2_Wartosc nvarchar(100),
 TrE_Atr3_DeAId int,
 TrE_Atr3_Kod nvarchar(20),
 TrE_Atr3_Wartosc nvarchar(100),
 TrE_Atr4_DeAId int,
 TrE_Atr4_Kod nvarchar(20),
 TrE_Atr4_Wartosc nvarchar(100),
 TrE_Atr5_DeAId int,
 TrE_Atr5_Kod nvarchar(20),
 TrE_Atr5_Wartosc nvarchar(100),
 TrE_Prog decimal(15, 2),
 TrE_UpustTyp tinyint,
 TrE_Upust decimal(15, 2),
 TrE_UpustKnt decimal(15, 2),
 TrE_UpustKntTyp tinyint,
 TrE_OstatniaKor int,
 TrE_CenaZCzteremaMiejscami tinyint,
 TrE_CenaTOld decimal(17, 4)
 )
select @TypNB = TrN_TypNB from cdn.TraNag where TrN_TrNID = @TrN_TrNId_Zrd
insert into @Wartosci
SELECT
TrE_LpPow AS LpPow,SUM(TrE_WartoscNetto) AS WartoscNetto,
SUM(TrE_WartoscBrutto) AS WartoscBrutto,SUM(TrE_WartoscNettoWal) AS WartoscNettoWal,
SUM(TrE_WartoscBruttoWal) AS WartoscBruttoWal,max(TrE_CenaWWD) AS CenaWWD,max(TrE_CenaT) AS CenaT, MAX(TrE_TrEId)
FROM CDN.TraNagRelacje
JOIN CDN.TraElem A ON TrE_TrNId = Trr_TrNId
WHERE Trr_FaId = @TrN_TrNId_Zrd AND Trr_TrNTyp = @TypDokMag AND Trr_FaTyp = @TypDokHandl
GROUP BY A.TrE_lppow
update a set CenaWWD = TrE_CenaWWD, CenaT = TrE_CenaT from @Wartosci a join cdn.TraElem on lastID = TrE_TrEID
if @TypNB = 2
INSERT INTO @Roznice
SELECT A.TrE_LpPow,
A.TrE_TwrId,
A.TrE_IloscJM,
A.TrE_WartoscNetto,
A.TrE_WartoscBrutto,
A.TrE_CenaWWD,
A.TrE_CenaT,
A.TrE_WartoscNettoWal,
A.TrE_WartoscBruttoWal,
A.TrE_WartoscNetto-WartoscNetto,
A.TrE_WartoscBrutto -WartoscBrutto,
A.TrE_WartoscNettoWal-WartoscNettoWal,
A.TrE_WartoscBruttoWal -WartoscBruttoWal
FROM CDN.TraElem AS A
JOIN
(SELECT
* from @Wartosci) AS B  ON A.TrE_lppow = B.LpPow
WHERE TrE_TrNId = @TrN_TrNId_Zrd AND ( A.TrE_WartoscBrutto<>B.WartoscBrutto OR A.TrE_CenaWWD <> B.CenaWWD  OR A.TrE_CenaT <> B.CenaT)
else
INSERT INTO @Roznice
SELECT A.TrE_LpPow,
A.TrE_TwrId,
A.TrE_IloscJM,
A.TrE_WartoscNetto,
A.TrE_WartoscBrutto,
A.TrE_CenaWWD,
A.TrE_CenaT,
A.TrE_WartoscNettoWal,
A.TrE_WartoscBruttoWal,
A.TrE_WartoscNetto-WartoscNetto,
A.TrE_WartoscBrutto -WartoscBrutto,
A.TrE_WartoscNettoWal-WartoscNettoWal,
A.TrE_WartoscBruttoWal -WartoscBruttoWal
FROM CDN.TraElem AS A
JOIN
(SELECT
* from @Wartosci) AS B  ON A.TrE_lppow = B.LpPow
WHERE TrE_TrNId = @TrN_TrNId_Zrd AND (A.TrE_WartoscNetto <> B.WartoscNetto  OR A.TrE_CenaWWD <> B.CenaWWD OR A.TrE_CenaT <> B.CenaT)
if (select count(Roz_LpPow) from @Roznice) = 0
return
insert into @TraElem
 SELECT
 A.TrE_TrEID,
 A.TrE_TrNId,
 A.TrE_TrEId,
 A.TrE_TrEIdProd,
 A.TrE_PdRId,
 A.TrE_Lp,
 A.TrE_LpPow,
 A.TrE_LpPowRel,
 A.TrE_TypDokumentu,
 A.TrE_Aktywny,
 case when B.TrE_DataOpe > A.TrE_DataOpe then B.TrE_DataOpe else A.TrE_DataOpe END,
 A.TrE_RabatPromocyjny,
 A.TrE_RabatKorekta,
 A.TrE_Promocje,
 case when B.TrE_DataOpe > A.TrE_DataOpe then B.TrE_DataOpe else A.TrE_DataOpe END,
 A.TrE_PodmiotTyp,
 A.TrE_PodID,
 A.TrE_KatID,
 A.TrE_TwrId,
 A.TrE_MagId,
 A.TrE_TwrNazwa,
 A.TrE_TwrEAN,
 A.TrE_TwrTyp,
 A.TrE_TwrKodDostawcy,
 A.TrE_TwrNumerKat,
 A.TrE_TwrKod,
 A.TrE_TwrOpis,
 A.TrE_TwrSWW,
 B.TrE_Stawka,
 B.TrE_Flaga,
 B.TrE_Zrodlowa,
 A.TrE_TwCNumer,
 A.TrE_TypNB,
 A.TrE_CenaW,--korekta sprawdzic
    case when A.TrE_CenaWWD = 0 then 0 else case when round(100.0 * (1-B.TrE_CenaWWD / A.TrE_CenaWWD),02) > 100 then 100 else case when round(100.0 * (1-B.TrE_CenaWWD / A.TrE_CenaWWD),02) < -999.99  then -999.99 else round(100.0 * (1-B.TrE_CenaWWD / A.TrE_CenaWWD),02) end end end, -- wyliczyc
 B.TrE_CenaW,
 B.TrE_Waluta,
 A.TrE_Kaucja,
 A.TrE_WyborDostaw,
 B.TrE_KursNumer,
 B.TrE_KursL,
 B.TrE_KursM,
 B.TrE_CenaT,
 0,--TrE_Ilosc,
 A.TrE_Ilosc,--TrE_IloscKW,
 A.TrE_Jm,
 A.TrE_JmZ,
 A.TrE_JmCalkowite,
 A.TrE_JMPrzelicznikL,
 A.TrE_JMPrzelicznikM,
 0,--TrE_IloscJM,
 A.TrE_IloscJM,--TrE_IloscJMKW,
 0, --TrE_WartoscNetto,
 0, --TrE_WartoscBrutto,
 0, --TrE_kosztUslugi
 B.TrE_KosztKGO,
 A.TrE_CenaWWD,
 B.TrE_CenaWWD,
 0, --TrE_WartoscNettoWal,
 0, --TrE_WartoscBruttoWal,
 A.TrE_WartoscTymczasowa,
 A.TrE_Atr1_DeAId,
 A.TrE_Atr1_Kod,
 A.TrE_Atr1_Wartosc,
 A.TrE_Atr2_DeAId,
 A.TrE_Atr2_Kod,
 A.TrE_Atr2_Wartosc,
 A.TrE_Atr3_DeAId,
 A.TrE_Atr3_Kod,
 A.TrE_Atr3_Wartosc,
 A.TrE_Atr4_DeAId,
 A.TrE_Atr4_Kod,
 A.TrE_Atr4_Wartosc,
 A.TrE_Atr5_DeAId,
 A.TrE_Atr5_Kod,
 A.TrE_Atr5_Wartosc,
 A.TrE_Prog,
 A.TrE_UpustTyp,
 A.TrE_Upust,
 A.TrE_UpustKnt,
 A.TrE_UpustKntTyp,
 0,
 A.TrE_CenaZCzteremaMiejscami,
 A.TrE_CenaT
FROM CDN.TraNagRelacje
JOIN CDN.TraElem A ON A.TrE_TrNId = Trr_TrNId
JOIN CDN.TraNag  ON A.TrE_TrNId = TrN_TrNId
JOIN CDN.TraElem B ON B.TrE_TrNId = Trr_FAId and B.tre_lppow = A.TrE_lppow
WHERE Trr_FaId = @TrN_TrNId_Zrd AND Trr_TrNTyp = @TypDokMag AND Trr_fatyp = @TypDokHandl AND TrN_Korekta = 0
UPDATE A SET  A.TrE_IloscJMKW = A.TrE_IloscJMKW + IloscJM,TrE_OstatniaKor = OstKor
FROM @TraElem A
JOIN (SELECT MAX(TrE_TrEID) as OstKor, TrE_ZwrID as ZwrID,SUM(TrE_IloscJM) as IloscJM FROM CDN.TraElem
join cdn.TraNag on TrE_TrNId = TrN_TrNID
WHERE TrE_ZwrID IN (SELECT TrE_TrEID FROM @TraElem) and TrN_Bufor = 0
GROUP BY TrE_ZwrID) as B ON B.ZwrID = A.TrE_TrEID
delete from @TraElem where TrE_IloscJMKW = 0
UPDATE A SET
A.TrE_Cena0WD = case when A.TrE_OstatniaKor = 0 then A.TrE_Cena0WD else  B.TrE_CenaWWD end,
A.TrE_Cena0 = case when A.TrE_OstatniaKor = 0 then  A.TrE_Cena0 else  B.TrE_CenaW end,
A.TrE_Rabat = case when B.TrE_CenaWWD = 0 then 0 else
  case when round(100.0 * (1-A.TrE_CenaWWD / B.TrE_CenaWWD),02) > 100 then 100 else case when round(100.0 * (1-A.TrE_CenaWWD / B.TrE_CenaWWD),02) < -999.99  then -999.99 else round(100.0 * (1-A.TrE_CenaWWD / B.TrE_CenaWWD),02) end end end -- wyliczyc
FROM @TraElem A
join CDN.Traelem B ON A.TrE_OstatniaKor = B.TrE_TrEID
WHERE A.TrE_OstatniaKor> 0
  DECLARE T CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrE_TrEID,TrE_Lppow,TrE_IloscJMKW FROM @TraElem ORDER BY TrE_TrEID
    OPEN T
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM T INTO @TrEID,@Lppow,@IloscJM
        IF @@FETCH_STATUS <> 0 BREAK
     SELECT @WartoscNettoWal =  0,
            @WartoscBruttoWal =  0,
            @WartoscNetto =  0,
            @WartoscBrutto =  0
 IF EXISTS (SELECT TrE_Lppow FROM @TraElem WHERE TrE_Lppow = @Lppow AND TrE_TrEID > @TrEID AND TrE_WartoscNettoWal = 0 AND TrE_WartoscBruttoWal = 0 AND TrE_WartoscNetto = 0 AND TrE_WartoscBrutto = 0)
 BEGIN
     SELECT @WartoscNettoWal =  round(Roz_WartoscNettoWalRoznica/Roz_IloscJM,2),
            @WartoscBruttoWal =  round(Roz_WartoscBruttoWalRoznica/Roz_IloscJM,2),
            @WartoscNetto =  round(Roz_WartoscNettoRoznica/Roz_IloscJM,2),
            @WartoscBrutto =  round(Roz_WartoscBruttoRoznica/Roz_IloscJM,2)
     FROM @Roznice
     WHERE  Roz_LpPow = @Lppow
    /* UPDATE @TraElem SET
            TrE_WartoscNettoWal = @WartoscNettoWal*@IloscJM ,
            TrE_WartoscBruttoWal = @WartoscBruttoWal*@IloscJM,
            TrE_WartoscNetto = @WartoscNetto*@IloscJM,
            TrE_WartoscBrutto = @WartoscBrutto*@IloscJM
     WHERE  TrE_TrEID = @TrEID
     UPDATE @Roznice SET
            Roz_IloscJM = Roz_IloscJM - @IloscJM,
            Roz_WartoscNettoWalRoznica = Roz_WartoscNettoWalRoznica - @WartoscNettoWal*@IloscJM ,
            Roz_WartoscBruttoWalRoznica = Roz_WartoscBruttoWalRoznica - @WartoscBruttoWal*@IloscJM ,
            Roz_WartoscNettoRoznica = Roz_WartoscNettoRoznica - @WartoscNetto*@IloscJM ,
            Roz_WartoscBruttoRoznica = Roz_WartoscBruttoRoznica - @WartoscBrutto*@IloscJM
     WHERE  Roz_LpPow = @Lppow      */
     UPDATE @TraElem SET
            TrE_WartoscNettoWal = round(@WartoscNettoWal*@IloscJM,2) ,
            TrE_WartoscBruttoWal = round(@WartoscBruttoWal*@IloscJM,2),
            TrE_WartoscNetto = round(@WartoscNetto*@IloscJM,2),
            TrE_WartoscBrutto = round(@WartoscBrutto*@IloscJM,2)
     WHERE  TrE_TrEID = @TrEID
     UPDATE @Roznice SET
            Roz_IloscJM = Roz_IloscJM - @IloscJM,
            Roz_WartoscNettoWalRoznica = Roz_WartoscNettoWalRoznica - round(@WartoscNettoWal*@IloscJM,2) ,
            Roz_WartoscBruttoWalRoznica = Roz_WartoscBruttoWalRoznica - round(@WartoscBruttoWal*@IloscJM,2) ,
            Roz_WartoscNettoRoznica = Roz_WartoscNettoRoznica - round(@WartoscNetto*@IloscJM,2) ,
            Roz_WartoscBruttoRoznica = Roz_WartoscBruttoRoznica - round(@WartoscBrutto*@IloscJM,2)
     WHERE  Roz_LpPow = @Lppow
 END
 ELSE
 BEGIN
     SELECT @WartoscNettoWal =  Roz_WartoscNettoWalRoznica,
            @WartoscBruttoWal =  Roz_WartoscBruttoWalRoznica,
            @WartoscNetto =  Roz_WartoscNettoRoznica,
            @WartoscBrutto =  Roz_WartoscBruttoRoznica
     FROM @Roznice
     WHERE Roz_LpPow = @Lppow
     UPDATE @TraElem SET
            TrE_WartoscNettoWal = @WartoscNettoWal,
            TrE_WartoscBruttoWal = @WartoscBruttoWal,
            TrE_WartoscNetto = @WartoscNetto,
            TrE_WartoscBrutto = @WartoscBrutto
     WHERE  TrE_TrEID = @TrEID
     UPDATE @Roznice SET
            Roz_WartoscNettoWalRoznica = 0,
            Roz_WartoscBruttoWalRoznica = 0,
            Roz_WartoscNettoRoznica = 0,
            Roz_WartoscBruttoRoznica = 0
     WHERE  Roz_LpPow = @Lppow
 END
      END
    CLOSE T
  DEALLOCATE T
DELETE FROM @TraElem WHERE TrE_WartoscNettoWal = 0 AND TrE_WartoscBruttoWal = 0 AND TrE_WartoscNetto = 0 AND TrE_WartoscBrutto = 0 AND TrE_Cena0WD = TrE_CenaWWD AND TrE_CenaT = TrE_CenaTOld
--SELECT * from @Roznice
--SELECT * from @TraElem
--trn_ddfid,trn_zwrid,TrN_FaId (id FZ), TrN_NumerNr,TrN_NumerString,TrN_korekta = 2, TrN_Rodzaj = 307006, TrN_ImportRowId
SELECT @TrN_OpeZalId_Doc = TrN_OpeZalId,
       @TrN_StaZalId_Doc = TrN_StaZalId,
       @TrN_DataDok_Doc = TrN_DataWys,
    @TrN_DataDok_Ope = TrN_DataOpe
       FROM CDN.TraNag WHERE TrN_TrNId = @TrN_TrNId_Zrd
SET @TrN_DDFId_Doc = CDN.DomyslnaDefinicja(@TrN_Rodzaj_Doc)
  IF ( SELECT TOP 1 DDf_SeriaOperatora FROM cdn.DokDefinicje WHERE DDF_DDFId = @TrN_DDFId_Doc ) = 1
    EXEC CDN.SeriaOperatora @ServerCfgString, @BazaCfgString, @TrN_OpeZalId_Doc, @SeriaOperatora OUTPUT, @RejestrOperatora OUTPUT
  SET @SeriaOperatora = ISNULL(@SeriaOperatora, '')
  if @Seria <> '' and @SeriaOperatora = ''
  SET @SeriaOperatora = @Seria
  DECLARE T CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrN_TrNID,TrN_MagZrdId FROM CDN.TraNagRelacje
    JOIN CDN.TraNag A ON TrN_TrNId = Trr_TrNId
     WHERE Trr_FaId = @TrN_TrNId_Zrd AND Trr_TrNTyp = @TypDokMag AND Trr_FaTyp = @TypDokHandl ORDER BY TrN_TrNID
    OPEN T
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM T INTO @TrNID,@TrN_MagZrdId_Doc
        IF @@FETCH_STATUS <> 0 BREAK
        IF EXISTS (SELECT TrE_TrEId FROM @TraElem WHERE TrE_TrNID = @TrNId )
        BEGIN
        select   @TrN_DataDok_Doc = case when B.TrN_DataWys > A.TrN_DataWys then B.TrN_DataWys else A.TrN_DataWys END,
           @TrN_DataDok_Ope = case when B.TrN_DataOpe > A.TrN_DataOpe then B.TrN_DataOpe else A.TrN_Dataope END
        FROM CDN.TraNag A
          LEFT JOIN CDN.TraNagRelacje ON Trr_TrNId = A.TrN_TrNID AND Trr_TrNTyp = @TypDokMag AND Trr_fatyp = @TypDokHandl
          LEFT JOIN CDN.TraNag B ON B.TrN_TrNId = Trr_FAId
          WHERE A.TrN_TrNId = @TrNId
  SET @DataMin = 0
        SELECT @DataMin = TrN_DataOpe FROM CDN.TraNag
          WHERE TrN_TrNID=(SELECT ISNULL(MAX(TrN_TrNID),0) FROM CDN.TraNag WHERE TrN_Korekta <> 4 AND TrN_ZwrID=@trnid AND TrN_Bufor<>-1 AND TrN_Rodzaj not in (306061,306071,306072) and trn_Korekta != 7)
        if @TrN_DataDok_Ope < @DataMin
         set @TrN_DataDok_Ope = @DataMin
  SET @DataMin = 0
        SELECT @DataMin = TrN_DataWys FROM CDN.TraNag
          WHERE TrN_TrNID=(SELECT ISNULL(MAX(TrN_TrNID),0) FROM CDN.TraNag WHERE TrN_Korekta <> 4 AND TrN_ZwrID=@trnid AND TrN_Bufor<>-1 AND TrN_Rodzaj not in (306061,306071,306072) and trn_Korekta != 7)
        if @TrN_DataDok_Doc < @DataMin
         set @TrN_DataDok_Doc = @DataMin
        SET @TrN_NumerString_Doc = CDN.NumerString
    (
       @TrN_Rodzaj_Doc,
       @TrN_OpeZalId_Doc,
       @TrN_StaZalId_Doc,
       @TrN_MagZrdId_Doc,
       @TrN_DataDok_Doc,
       @SeriaOperatora,
 default,
 default,
 default
    )
  SET @Komunikat = CDN.SprawdzNumerString ( @TrN_DDFId_Doc, @TrN_NumerString_Doc )
    IF @Komunikat <> '' GOTO KOMUNIKAT
  SELECT @TrN_NumerNr_Doc = ISNULL(MAX(TrN_NumerNr),0) + 1 FROM cdn.TraNag WHERE TrN_NumerString = @TrN_NumerString_Doc
   --SELECT * from @TraElem WHERE TrE_TrNID = @TrNId
   INSERT INTO CDN.TraNag
           (TrN_RelTrNId
           ,TrN_FVMarza
           ,TrN_DDfId
           ,TrN_TypDokumentu
           ,TrN_ZwrId
           ,TrN_FaId
           ,TrN_NumerNr
           ,TrN_NumerString
           ,TrN_Bufor
           ,TrN_Anulowany
           ,TrN_VaNId
           ,TrN_DataDok
           ,TrN_DataWys
           ,TrN_DataOpe
           ,TrN_NumerObcy
           ,TrN_DataKur
           ,TrN_NumerPelnyPrw
           ,TrN_TaxFreePotwierdzony
           ,TrN_Korekta
           ,TrN_Fiskalna
           ,TrN_FiskalnaErr
           ,TrN_StatusInt
           ,TrN_RabatPromocyjny
           ,TrN_RabatKorekta
           ,TrN_Detal
           ,TrN_Rodzaj
           ,TrN_PodmiotTyp
           ,TrN_PodID
           ,TrN_PodNazwa1
           ,TrN_PodNazwa2
           ,TrN_PodNazwa3
           ,TrN_PodKraj
           ,TrN_PodWojewodztwo
           ,TrN_PodPowiat
           ,TrN_PodGmina
           ,TrN_PodUlica
           ,TrN_PodNrDomu
           ,TrN_PodNrLokalu
           ,TrN_PodMiasto
           ,TrN_PodKodPocztowy
           ,TrN_PodPoczta
           ,TrN_PodAdres2
           ,TrN_PodNipKraj
           ,TrN_PodNipE
           ,TrN_PodmiotGLN
           ,TrN_Finalny
           ,TrN_Export
           ,TrN_OdbiorcaTyp
           ,TrN_OdbID
           ,TrN_OdbNazwa1
           ,TrN_OdbNazwa2
           ,TrN_OdbNazwa3
           ,TrN_OdbKraj
           ,TrN_OdbWojewodztwo
           ,TrN_OdbPowiat
           ,TrN_OdbGmina
           ,TrN_OdbUlica
           ,TrN_OdbNrDomu
           ,TrN_OdbNrLokalu
           ,TrN_OdbMiasto
           ,TrN_OdbKodPocztowy
           ,TrN_OdbPoczta
           ,TrN_OdbAdres2
           ,TrN_OdbNipKraj
           ,TrN_OdbNipE
           ,TrN_OdbiorcaGLN
           ,TrN_OdbiorcaDocTyp
           ,TrN_OdbDocID
           ,TrN_OdbTelefon
           ,TrN_OdbEmail
           ,TrN_KatID
           ,TrN_Kategoria
           ,TrN_FPlId
           ,TrN_Termin
           ,TrN_TerminZwrotuKaucji
           ,TrN_RazemNetto
           ,TrN_RazemVAT
           ,TrN_RazemBrutto
           ,TrN_RazemNettoWal
           ,TrN_RazemVATWal
           ,TrN_RazemBruttoWal
           ,TrN_Waluta
           ,TrN_KursNumer
           ,TrN_KursL
           ,TrN_KursM
           ,TrN_PlatElemWalSys
           ,TrN_VatDlaDokWal
           ,TrN_PlatKaucje
           ,TrN_PodmiotZalTyp
           ,TrN_PodZalId
           ,TrN_BlokadaPlatnosci
           ,TrN_MagZrdId
           ,TrN_MagDocId
           ,TrN_TypNB
           ,TrN_Rabat
           ,TrN_Odebral
           ,TrN_Opis
           ,TrN_ZwroconoCalaIlosc
           ,TrN_NotaKorPrzed
           ,TrN_NotaKorPo
           ,TrN_TrSTyp
           ,TrN_DekId
           ,TrN_TS_Export
           ,TrN_OpeZalID
     ,TrN_OpeZalKod
     ,TrN_OpeZalNazwisko
           ,TrN_StaZalId
           ,TrN_TS_Zal
           ,TrN_OpeModID
     ,TrN_OpeModKod
     ,TrN_OpeModNazwisko
           ,TrN_StaModId
           ,TrN_TS_Mod
           ,TrN_GIDTyp
           ,TrN_GIDFirma
           ,TrN_GIDNumer
           ,TrN_GIDLp
           ,TrN_OFFPrawoDoFAPA
           ,TrN_OFFPrawoDoAnulowania
           ,TrN_OFFExportMag
           ,TrN_Centrala
           ,TrN_KodTransakcji
           ,TrN_IsNId
           ,TrN_DataTransportu
           ,TrN_KodKraju
           ,TrN_DabId
           ,TrN_DataEFaktura
           ,TrN_OpeWysylajacy
           ,TrN_EFakturaGUID
           ,TrN_DataPtwTaxFree
           ,TrN_PreDekID
           ,TrN_TrybNettoVAT
           ,TrN_NieOkreslonaWartoscKor
     ,TrN_PodatekVat
     ,TrN_ZakID
     ,TrN_OpeZatwID
     ,TrN_OpeZatwKod
     ,TrN_OpeZatwNazwisko
           ,TrN_TS_Zatw
     ,TrN_PCId
     ,TrN_PCJSID)
     SELECT
           A.TrN_RelTrNId
           ,A.TrN_FVMarza
           ,@TrN_DDFId_Doc
           ,CONVERT(INT, @TrN_Rodzaj_Doc/1000)
           ,A.TrN_TrNId
           ,A.TrN_FaId
           ,@TrN_NumerNr_Doc
           ,@TrN_NumerString_Doc
           ,A.TrN_Bufor
           ,A.TrN_Anulowany
           ,A.TrN_VaNId
           ,@TrN_DataDok_Doc
           ,@TrN_DataDok_Doc
           ,@TrN_DataDok_Ope
           ,B.TrN_NumerObcy
           ,B.TrN_DataKur
           ,B.TrN_NumerPelnyPrw
           ,A.TrN_TaxFreePotwierdzony
           ,2
           ,A.TrN_Fiskalna
           ,A.TrN_FiskalnaErr
           ,A.TrN_StatusInt
           ,B.TrN_RabatPromocyjny
           ,B.TrN_RabatKorekta
           ,B.TrN_Detal
           ,@TrN_Rodzaj_Doc
           ,B.TrN_PodmiotTyp
           ,B.TrN_PodID
           ,B.TrN_PodNazwa1
           ,B.TrN_PodNazwa2
           ,B.TrN_PodNazwa3
           ,B.TrN_PodKraj
           ,B.TrN_PodWojewodztwo
           ,B.TrN_PodPowiat
           ,B.TrN_PodGmina
           ,B.TrN_PodUlica
           ,B.TrN_PodNrDomu
           ,B.TrN_PodNrLokalu
           ,B.TrN_PodMiasto
           ,B.TrN_PodKodPocztowy
           ,B.TrN_PodPoczta
           ,B.TrN_PodAdres2
           ,B.TrN_PodNipKraj
           ,B.TrN_PodNipE
           ,B.TrN_PodmiotGLN
           ,B.TrN_Finalny
           ,B.TrN_Export
           ,B.TrN_OdbiorcaTyp
           ,B.TrN_OdbID
           ,B.TrN_OdbNazwa1
           ,B.TrN_OdbNazwa2
           ,B.TrN_OdbNazwa3
           ,B.TrN_OdbKraj
           ,B.TrN_OdbWojewodztwo
           ,B.TrN_OdbPowiat
           ,B.TrN_OdbGmina
           ,B.TrN_OdbUlica
           ,B.TrN_OdbNrDomu
           ,B.TrN_OdbNrLokalu
           ,B.TrN_OdbMiasto
           ,B.TrN_OdbKodPocztowy
           ,B.TrN_OdbPoczta
           ,B.TrN_OdbAdres2
           ,B.TrN_OdbNipKraj
           ,B.TrN_OdbNipE
           ,B.TrN_OdbiorcaGLN
           ,B.TrN_OdbiorcaDocTyp
           ,B.TrN_OdbDocID
           ,B.TrN_OdbTelefon
           ,B.TrN_OdbEmail
           ,A.TrN_KatID
           ,A.TrN_Kategoria
           ,A.TrN_FPlId
           ,A.TrN_Termin
           ,A.TrN_TerminZwrotuKaucji
           ,B.TrN_RazemNetto
           ,B.TrN_RazemVAT
           ,B.TrN_RazemBrutto
           ,B.TrN_RazemNettoWal
           ,B.TrN_RazemVATWal
           ,B.TrN_RazemBruttoWal
           ,B.TrN_Waluta
           ,B.TrN_KursNumer
           ,B.TrN_KursL
           ,B.TrN_KursM
           ,B.TrN_PlatElemWalSys
           ,B.TrN_VatDlaDokWal
           ,B.TrN_PlatKaucje
           ,B.TrN_PodmiotZalTyp
           ,B.TrN_PodZalId
           ,A.TrN_BlokadaPlatnosci
           ,A.TrN_MagZrdId
           ,A.TrN_MagDocId
           ,A.TrN_TypNB
           ,0
           ,B.TrN_Odebral
           ,B.TrN_Opis
           ,B.TrN_ZwroconoCalaIlosc
           ,B.TrN_NotaKorPrzed
           ,B.TrN_NotaKorPo
           ,A.TrN_TrSTyp
           ,B.TrN_DekId
           ,B.TrN_TS_Export
           ,B.TrN_OpeZalID
     ,B.TrN_OpeZalKod
     ,B.TrN_OpeZalNazwisko
           ,B.TrN_StaZalId
           ,B.TrN_TS_Zal
           ,B.TrN_OpeModID
     ,B.TrN_OpeModKod
     ,B.TrN_OpeModNazwisko
           ,B.TrN_StaModId
           ,B.TrN_TS_Mod
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,A.TrN_OFFPrawoDoFAPA
           ,A.TrN_OFFPrawoDoAnulowania
           ,A.TrN_OFFExportMag
           ,A.TrN_Centrala
           ,B.TrN_KodTransakcji
           ,B.TrN_IsNId
           ,B.TrN_DataTransportu
           ,B.TrN_KodKraju
           ,B.TrN_DabId
           ,B.TrN_DataEFaktura
           ,B.TrN_OpeWysylajacy
           ,B.TrN_EFakturaGUID
           ,A.TrN_DataPtwTaxFree
           ,B.TrN_PreDekID
           ,B.TrN_TrybNettoVAT
           ,1
     ,B.TrN_PodatekVat
     ,B.TrN_ZakID
     ,B.TrN_OpeZatwID
     ,B.TrN_OpeZatwKod
     ,case when B.TrN_OpeZatwNazwisko = '' then B.TrN_OpeZatwKod else B.TrN_OpeZatwNazwisko end
           ,B.TrN_TS_Zatw
     ,B.TrN_PCId
     ,B.TrN_PCJSID
          FROM CDN.TraNag A
          LEFT JOIN CDN.TraNagRelacje ON Trr_TrNId = A.TrN_TrNID AND Trr_TrNTyp = @TypDokMag AND Trr_fatyp = @TypDokHandl
          LEFT JOIN CDN.TraNag B ON B.TrN_TrNId = Trr_FAId
          WHERE A.TrN_TrNId = @TrNId
          SET @TrN_TrNId_Doc = SCOPE_IDENTITY()
    --logi
    select @NumerPelny = TrN_numerPelny,@TypDokumentu = trn_typdokumentu from cdn.tranag where trn_trnid = @TrN_TrNId_Doc
    exec [CDN].[RejestrOperacjiDodaj] @TypDokumentu,0, @TrN_TrNId_Doc, @NumerPelny, 1, ''
                INSERT INTO CDN.TraNagRelacje
                            (TrR_TrNTyp
                            ,TrR_TrNId
                            ,TrR_FaTyp
                            ,TrR_FaId
                            ,TrR_Flaga)
                   VALUES
                           (CONVERT(INT, @TrN_Rodzaj_Doc/1000)
                           ,@TrN_TrNId_Doc
                           ,0
                           ,@TrN_TrNId_Zrd
                           ,0
                           )
             --   dodajemy atrybuty
   IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1823 and Fir_Wartosc = '1' and CONVERT(INT, @TrN_Rodzaj_Doc/1000) IN (306, 307))
    BEGIN
      INSERT INTO CDN.DokAtrybuty
        (
        DAt_DeAId,
        DAt_Kod,
        DAt_WartoscTxt,
        DAt_TrNId
         )
      SELECT
         DAt_DeAId,
         DAt_Kod,
         DAt_WartoscTxt,
         @TrN_TrNId_Doc
      FROM CDN.DokAtrybuty
      WHERE DaT_TrNId = @TrN_TrNId_Zrd
    END
    INSERT INTO CDN.TraElem
           (TrE_TrNId
           ,TrE_ZwrId
           ,TrE_TrEIdProd
           ,TrE_PdRId
           ,TrE_Lp
           ,TrE_LpPow
           ,TrE_LpPowRel
           ,TrE_TypDokumentu
           ,TrE_Aktywny
           ,TrE_DataDok
           ,TrE_RabatPromocyjny
           ,TrE_RabatKorekta
           ,TrE_Promocje
           ,TrE_DataOpe
           ,TrE_PodmiotTyp
           ,TrE_PodID
           ,TrE_KatID
           ,TrE_TwrId
           ,TrE_MagId
           ,TrE_TwrNazwa
           ,TrE_TwrEAN
           ,TrE_TwrTyp
           ,TrE_TwrKodDostawcy
           ,TrE_TwrNumerKat
           ,TrE_TwrKod
           ,TrE_TwrOpis
           ,TrE_TwrSWW
           ,TrE_Stawka
           ,TrE_Flaga
           ,TrE_Zrodlowa
           ,TrE_TwCNumer
           ,TrE_TypNB
           ,TrE_Cena0
           ,TrE_Rabat
           ,TrE_CenaW
           ,TrE_Waluta
           ,TrE_Kaucja
           ,TrE_WyborDostaw
           ,TrE_KursNumer
           ,TrE_KursL
           ,TrE_KursM
           ,TrE_CenaT
           ,TrE_Ilosc
           ,TrE_IloscKW
           ,TrE_Jm
           ,TrE_JmZ
           ,TrE_JmCalkowite
           ,TrE_JMPrzelicznikL
           ,TrE_JMPrzelicznikM
           ,TrE_IloscJM
           ,TrE_IloscJMKW
           ,TrE_WartoscNetto
           ,TrE_WartoscBrutto
           ,TrE_KosztUslugi
           ,TrE_KosztKGO
           ,TrE_WartoscZakupuWylicz
           ,TrE_Cena0WD
           ,TrE_CenaWWD
           ,TrE_WartoscNettoWal
           ,TrE_WartoscBruttoWal
           ,TrE_WartoscTymczasowa
           ,TrE_Atr1_DeAId
           ,TrE_Atr1_Kod
           ,TrE_Atr1_Wartosc
           ,TrE_Atr2_DeAId
           ,TrE_Atr2_Kod
           ,TrE_Atr2_Wartosc
           ,TrE_Atr3_DeAId
           ,TrE_Atr3_Kod
           ,TrE_Atr3_Wartosc
           ,TrE_Atr4_DeAId
           ,TrE_Atr4_Kod
           ,TrE_Atr4_Wartosc
           ,TrE_Atr5_DeAId
           ,TrE_Atr5_Kod
           ,TrE_Atr5_Wartosc
           ,TrE_Prog
           ,TrE_UpustTyp
           ,TrE_Upust
           ,TrE_UpustKnt
           ,TrE_UpustKntTyp
           ,TrE_CenaZCzteremaMiejscami)
     select
           @TrN_TrNId_Doc
           ,TrE_TrEId
           ,TrE_TrEIdProd
           ,TrE_PdRId
           ,TrE_Lp
           ,TrE_LpPow
           ,TrE_LpPowRel
           ,TrE_TypDokumentu
           ,TrE_Aktywny
           ,@TrN_DataDok_Doc
           ,TrE_RabatPromocyjny
           ,TrE_RabatKorekta
           ,TrE_Promocje
           ,@TrN_DataDok_Ope
           ,TrE_PodmiotTyp
           ,TrE_PodID
           ,TrE_KatID
           ,TrE_TwrId
           ,TrE_MagId
           ,TrE_TwrNazwa
           ,TrE_TwrEAN
           ,TrE_TwrTyp
           ,TrE_TwrKodDostawcy
           ,TrE_TwrNumerKat
           ,TrE_TwrKod
           ,TrE_TwrOpis
           ,TrE_TwrSWW
           ,TrE_Stawka
           ,TrE_Flaga
           ,TrE_Zrodlowa
           ,TrE_TwCNumer
           ,TrE_TypNB
           ,TrE_Cena0
           ,TrE_Rabat
           ,TrE_CenaW
           ,TrE_Waluta
           ,TrE_Kaucja
           ,0
           ,TrE_KursNumer
           ,TrE_KursL
           ,TrE_KursM
           ,TrE_CenaT
           ,TrE_Ilosc
           ,TrE_IloscKW
           ,TrE_Jm
           ,TrE_JmZ
           ,TrE_JmCalkowite
           ,TrE_JMPrzelicznikL
           ,TrE_JMPrzelicznikM
           ,TrE_IloscJM
           ,TrE_IloscJMKW
   ,CASE
    WHEN TrE_TypNB=1  THEN   TrE_WartoscNetto
    WHEN TrE_TypNB=2 THEN   TrE_WartoscBrutto    - ROUND(TrE_WartoscBrutto    * TrE_Stawka / (100+TrE_Stawka),2) END
           --,TrE_WartoscNetto
           --,TrE_WartoscBrutto
           ,CASE
    WHEN TrE_TypNB=1  THEN   ROUND(TrE_WartoscNetto * (100 + TrE_Stawka )/100, 2)
    WHEN TrE_TypNB=2 THEN   TrE_WartoscBrutto END
           ,0--TrE_KosztUslugi
           ,TrE_KosztKGO
           ,0
           ,TrE_Cena0WD
           ,TrE_CenaWWD
           --,TrE_WartoscNettoWal
           , CASE
    WHEN TrE_TypNB=1 THEN          TrE_WartoscNettoWal
    WHEN TrE_TypNB=2 THEN          TrE_WartoscBruttoWal    - ROUND( TrE_WartoscBruttoWal * TrE_Stawka/(100+TrE_Stawka),2) END
           --,TrE_WartoscBruttoWal
           ,CASE
    WHEN TrE_TypNB=1  THEN   ROUND(TrE_WartoscNettoWal * (100 + TrE_Stawka )/100, 2)
    WHEN TrE_TypNB=2 THEN   TrE_WartoscBruttoWal END
           ,TrE_WartoscTymczasowa
           ,TrE_Atr1_DeAId
           ,TrE_Atr1_Kod
           ,TrE_Atr1_Wartosc
           ,TrE_Atr2_DeAId
           ,TrE_Atr2_Kod
           ,TrE_Atr2_Wartosc
           ,TrE_Atr3_DeAId
           ,TrE_Atr3_Kod
           ,TrE_Atr3_Wartosc
           ,TrE_Atr4_DeAId
           ,TrE_Atr4_Kod
           ,TrE_Atr4_Wartosc
           ,TrE_Atr5_DeAId
           ,TrE_Atr5_Kod
           ,TrE_Atr5_Wartosc
           ,TrE_Prog
           ,TrE_UpustTyp
           ,TrE_Upust
           ,TrE_UpustKnt
           ,TrE_UpustKntTyp
     ,TrE_CenaZCzteremaMiejscami
 FROM @traelem WHERE TrE_TrNID = @TrNId
 INSERT INTO [CDN].[TraElemAtr]
           ([TrA_TrEId]
           ,[TrA_Lp]
           ,[TrA_DeAId]
           ,[TrA_Kod]
           ,[TrA_Wartosc]
           ,[TrA_ESklep])
 select
     B.tre_treid,
           TrA_Lp,
           TrA_DeAId,
           TrA_Kod,
           TrA_Wartosc,
           TrA_ESklep
    FROM cdn.TraElemAtr
    left join @traelem A on TrA_TrEId = a.TrE_TrEID
    left join cdn.traelem B on B.TrE_ZwrId = a.TrE_TrEID
    where  B.TrE_TrNId = @TrN_TrNId_Doc and A.TrE_TrNID = @TrNId
 DELETE FROM CDN.TraVat WHERE TrV_TrNId = @TrN_TrNId_Doc
INSERT INTO CDN.TraVat ( TrV_TrNId, TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, TrV_Netto, TrV_VAT, TrV_NettoWal, TrV_VATWal, TrV_Typ )
  SELECT                @TrN_TrNId_Doc, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa,         0,       0,            0,          0,       0
    FROM CDN.TraElem
    WHERE TrE_TrNId = @TrN_TrNId_Doc
    GROUP BY TrE_Stawka, TrE_Flaga, TrE_Zrodlowa
UPDATE CDN.TraVat SET
  TrV_Netto    = Netto,
  TrV_VAT      = VAT,
  TrV_NettoWal = NettoWal,
  TrV_VATWal   = VATWal
FROM
( SELECT
  @TrN_TrNId_Doc   AS TrNId,
  TrE_Stawka   AS Stawka,
  TrE_Flaga    AS Flaga,
  TrE_Zrodlowa AS Zrodlowa,
  CASE
    WHEN TrN_TypNB=1  THEN   SUM(TrE_WartoscNetto)
    WHEN TrN_TypNB=2 THEN   SUM(TrE_WartoscBrutto)    - ROUND(SUM(TrE_WartoscBrutto)    * TrE_Stawka / (100+TrE_Stawka),2)
  END AS Netto,
  CASE
    WHEN TrN_TypNB=1 THEN ROUND(SUM(TrE_WartoscNetto)     * TrE_Stawka/100,2)
    WHEN TrN_TypNB=2 THEN ROUND(SUM(TrE_WartoscBrutto)    * TrE_Stawka/(100+TrE_Stawka),2)
  END AS VAT,
  CASE
    WHEN TrN_TypNB=1 THEN          SUM(TrE_WartoscNettoWal)
    WHEN TrN_TypNB=2 THEN          SUM(TrE_WartoscBruttoWal)    - ROUND( SUM(TrE_WartoscBruttoWal) * TrE_Stawka/(100+TrE_Stawka),2)
  END AS NettoWal,
  CASE
    WHEN TrN_TypNB=1 THEN ROUND(SUM(TrE_WartoscNettoWal) * (100+TrE_Stawka)/100, 2) - SUM(TrE_WartoscNettoWal)
    WHEN TrN_TypNB=2 THEN ROUND(SUM(TrE_WartoscBruttoWal) * TrE_Stawka/(100+TrE_Stawka),2)
    WHEN TrE_Stawka =0 THEN 0
  END AS VATWal
  FROM CDN.TraElem JOIN CDN.TraNag ON TrN_TrNId=TrE_TrNId
  WHERE TrN_TrNId = @TrN_TrNId_Doc
  GROUP BY TrN_TypNB, TrN_KursL, TrN_KursM, TrN_PlatElemWalSys, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa
 ) AS TraVATTmp
JOIN CDN.TraVAT ON TrV_TrNId = TrNId AND TrV_Stawka = Stawka AND TrV_Flaga = Flaga AND TrV_Zrodlowa = Zrodlowa
-- update wartości do nagłówka na podstawie tabelki VAT
UPDATE CDN.TraNag SET
  TrN_RazemNetto     = ISNULL(TrV_Netto,0),
  TrN_RazemVAT       = ISNULL(TrV_Vat,0),
  TrN_RazemBrutto    = ISNULL(TrV_Brutto,0),
  TrN_RazemNettoWal  = ISNULL(TrV_NettoWal,0),
  TrN_RazemVATWal    = ISNULL(TrV_VatWal,0),
  TrN_RazemBruttoWal = ISNULL(TrV_BruttoWal,0)
FROM CDN.TraNag LEFT OUTER JOIN
( SELECT
    TrV_TrNId     = TrV_TrNId,
    TrV_Netto     = SUM(TrV_Netto),
    TrV_Vat       = SUM(TrV_Vat),
    TrV_Brutto    = SUM(TrV_Netto + TrV_Vat),
    TrV_NettoWal  = SUM(TrV_NettoWal),
    TrV_VatWal    = SUM(TrV_VatWal),
    TrV_BruttoWal = SUM(TrV_NettoWal + TrV_VatWal)
  FROM CDN.TraVat
  WHERE TrV_TrNId = @TrN_TrNId_Doc
  GROUP BY TrV_TrNId
) AS TraVatTmp ON TrN_TrNId = TrV_TrNId
WHERE TrN_TrNId = @TrN_TrNId_Doc
        -- EXEC CDN.AktualizujTraVATTraNag @TrN_TrNId_Doc
   exec cdn.DodajKorekteDoPWP @TrN_TrNId_Doc, @ServerCfgString,@BazaCfgString
        END
      END
    CLOSE T
  DEALLOCATE T
KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
SET NOCOUNT OFF
