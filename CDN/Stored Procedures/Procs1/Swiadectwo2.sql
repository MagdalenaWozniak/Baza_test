CREATE PROCEDURE [CDN].[Swiadectwo2] @IdPrac INT, @Okres_Od DATETIME, @Okres_Do DATETIME, @Typ INT
AS
SET NOCOUNT ON
DECLARE @Od DATETIME
DECLARE @Do DATETIME
DECLARE @poprzOd DATETIME
DECLARE @poprzDo DATETIME
DECLARE @Dni INT
DECLARE @Licznosc INT
DECLARE @Opis Nvarchar(253)
CREATE TABLE #OjcowRodz(
 Tmp_Prcid INT,
 Tmp_Od DATETIME,
 Tmp_Do DATETIME,
 Tmp_Dni INT,
 Tmp_Czesci INT,
 Tmp_Opis Nvarchar(253)
 )
IF @Typ = 1
BEGIN
DECLARE Tmp_OjcowRodz CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 Pnb_OkresOd,
 Pnb_OkresDo,
 DATEDIFF(dd,Pnb_OkresOd,PNB_OkresDo)+1,
 0,
 case when isnull(RDZ_RdzId,0) <> 0 then '('+rtrim(ltrim(RDZ_Imie)) +' '+rtrim(ltrim(RDZ_Nazwisko))+')' else
 case when len(PNB_Dziecko) > 0 then '('+rtrim(ltrim(PNB_Dziecko))+')' else '' end end
 FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 left join CDN.Rodzina on PNB_RdzId = RDZ_RdzId
 WHERE TNB_PdzId = 327 and @IdPrac = PNB_PraId and (PNB_Tryb = 0 or PNB_Tryb = 2) and (Pnb_OkresOd between @Okres_Od and @Okres_Do
 or Pnb_OkresDo between @Okres_Od and @Okres_Do or @Okres_Od between Pnb_OkresOd and Pnb_OkresDo)
  OPEN Tmp_OjcowRodz
  WHILE 1=1
  BEGIN
      --SET @poprzOd = @Od
      --SET @poprzDo = @Do
      FETCH NEXT FROM Tmp_OjcowRodz INTO @IdPrac, @Od, @Do, @Dni,@Licznosc, @Opis
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      --IF (@Od<>@poprzDo+1 or ISNULL(@poprzDo,0)=0)
      SET @Licznosc = 1
   BEGIN
       INSERT INTO #OjcowRodz values (@IdPrac, @Od, @Do, @Dni, @Licznosc, @Opis)
      END
      END
  END
 CLOSE Tmp_OjcowRodz
 DEALLOCATE Tmp_OjcowRodz
END
IF @Typ = 2
BEGIN
DECLARE Tmp_OjcowRodz CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 Pnb_OkresOd,
 Pnb_OkresDo,
 DATEDIFF(dd,Pnb_OkresOd,PNB_OkresDo)+1,
 0,
 case when isnull(RDZ_RdzId,0) <> 0 then '('+rtrim(ltrim(RDZ_Imie)) +' '+rtrim(ltrim(RDZ_Nazwisko))+')' else
 case when len(PNB_Dziecko) > 0 then '('+rtrim(ltrim(PNB_Dziecko))+')' else '' end end
 FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 left join CDN.Rodzina on PNB_RdzId = RDZ_RdzId
 WHERE TNB_PdzId = 319 and @IdPrac = PNB_PraId and (PNB_Tryb = 0 or PNB_Tryb = 2) and (Pnb_OkresOd between @Okres_Od and @Okres_Do
 or Pnb_OkresDo between @Okres_Od and @Okres_Do or @Okres_Od between Pnb_OkresOd and Pnb_OkresDo)
  OPEN Tmp_OjcowRodz
  WHILE 1=1
  BEGIN
      --SET @poprzOd = @Od
      --SET @poprzDo = @Do
      FETCH NEXT FROM Tmp_OjcowRodz INTO @IdPrac, @Od, @Do, @Dni,@Licznosc, @Opis
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      --IF (@Od<>@poprzDo+1 or ISNULL(@poprzDo,0)=0)
      SET @Licznosc = 1
   BEGIN
       INSERT INTO #OjcowRodz values (@IdPrac, @Od, @Do, @Dni, @Licznosc, @Opis)
      END
      END
  END
 CLOSE Tmp_OjcowRodz
 DEALLOCATE Tmp_OjcowRodz
END
IF @Typ = 3
BEGIN
DECLARE Tmp_OjcowRodz CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT
 @IdPrac,
 Pnb_OkresOd,
 Pnb_OkresDo,
 DATEDIFF(dd,Pnb_OkresOd,PNB_OkresDo)+1,
 0,
 case when isnull(RDZ_RdzId,0) <> 0 then '('+rtrim(ltrim(RDZ_Imie)) +' '+rtrim(ltrim(RDZ_Nazwisko))+')' else
 case when len(PNB_Dziecko) > 0 then '('+rtrim(ltrim(PNB_Dziecko))+')' else '' end end
 FROM CDN.PracNieobec join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 left join CDN.Rodzina on PNB_RdzId = RDZ_RdzId
 WHERE TNB_PdzId in (121,122) and @IdPrac = PNB_PraId and (PNB_Tryb = 0 or PNB_Tryb = 2) and (Pnb_OkresOd between @Okres_Od and @Okres_Do
 or Pnb_OkresDo between @Okres_Od and @Okres_Do or @Okres_Od between Pnb_OkresOd and Pnb_OkresDo)
  OPEN Tmp_OjcowRodz
  WHILE 1=1
  BEGIN
      --SET @poprzOd = @Od
      --SET @poprzDo = @Do
      FETCH NEXT FROM Tmp_OjcowRodz INTO @IdPrac, @Od, @Do, @Dni,@Licznosc, @Opis
      IF @@FETCH_STATUS <> 0 BREAK
      BEGIN
      --IF (@Od<>@poprzDo+1 or ISNULL(@poprzDo,0)=0)
      SET @Licznosc = 1
   BEGIN
       INSERT INTO #OjcowRodz values (@IdPrac, @Od, @Do, @Dni, @Licznosc, @Opis)
      END
      END
  END
 CLOSE Tmp_OjcowRodz
 DEALLOCATE Tmp_OjcowRodz
END
-- SELECT  * FROM #OjcowRodz order by Tmp_Od
 SELECT  isnull(max(Tmp_Prcid),0) as Tmp_Prcid, isnull(sum(Tmp_Dni),0) as Tmp_Dni,isnull(sum(Tmp_Czesci),0) as Tmp_Czesci, max(rtrim(ltrim(Tmp_Opis))) as Tmp_Opis FROM #OjcowRodz group by Tmp_Opis
