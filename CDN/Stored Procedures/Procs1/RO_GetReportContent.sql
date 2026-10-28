CREATE PROCEDURE [CDN].[RO_GetReportContent]
 @Identyfikator int = 0
AS
BEGIN
 DECLARE @Twr_Url    varchar(128),
   @DOK_Algorytm   int,
   @DOK_PodStatus   int,
   @DOK_PodatnikVat  int,
   @Dok_DataOpe   datetime
 SELECT @DOK_Algorytm = TrN_TypNB,
  @DOK_PodStatus = TrN_Export,
  @DOK_PodatnikVat = TrN_PodatekVat,
  @Dok_DataOpe = TrN_DataOpe
 From CDN.TraNag
 where TrN_TrNID = @Identyfikator
 SELECT
  Tre_Lp   [Tre_Lp],
  CAST(TrE_TwrNazwa as varchar(256)) [TrE_Nazwa],
  CAST(TrE_TwrSWW as varchar(32) ) [TrE_PKWiU],
  CAST(replace(rtrim(replace(replace( rtrim(replace(convert(varchar(32),TrE_IloscJM),'0',' ')) , ' ' , '0' ),'.',' ')),' ',',') as varchar(32)) [Tre_Ilosc],
  CAST(Tre_JM as varchar(20) ) [Tre_JM],
  CAST(CASE Tre_CenaZCzteremaMiejscami WHEN 0 THEN replace(replace(convert(varchar(20),convert(Money,TrE_CenaWWD),1),',',' '), '.',',')
  ELSE replace(replace(convert(varchar(20),convert(Money,CAST(TrE_CenaWWD as decimal(16,4))),2),',',' '), '.',',') END as varchar(32)) [Tre_Cena],
  CAST((CASE Tre_TwrOpis WHEN '' THEN '' ELSE Tre_TwrOpis END) as varchar(1024)) [Tre_Opis],
  CASE WHEN TrE_Flaga = 1 THEN CAST('ZW' as varchar(16))
  WHEN TrE_Flaga = 4 AND ((@DOK_PodStatus=5 and (@DOK_PodatnikVat=1 OR @Dok_DataOpe < CONVERT(DATETIME, '2015-07-01', 120))) OR @DOK_PodStatus in (8,9)) THEN CAST(char(45)+char(45)+char(45)+char(42) as varchar(16))
  WHEN TrE_Flaga = 4 AND ((@DOK_PodStatus<>5 OR (@DOK_PodatnikVat<>1 AND @Dok_DataOpe > CONVERT(DATETIME, '2015-07-01', 120))) AND @DOK_PodStatus not in (8,9)) THEN CAST('NP' as varchar(16))
  ELSE CAST(CAST(TrE_Stawka as INT) as varchar(15)) + '%' END [Tre_VAT],
  CAST(CASE @DOK_Algorytm WHEN 1 THEN TrE_WartoscNettoWal ELSE TrE_WartoscBruttoWal END as decimal(16,2)) [Tre_Wartosc],
  (SELECT Top 1 CAST(ISNULL(Twr_Url,'') as varchar(128)) From CDN.Towary where Twr_TwrId = TrE_TwrId) [Tre_Url]
 FROM CDN.TraElem
 WHERE TrE_TrNId = @Identyfikator
 ORDER BY Tre_Lp
 OPTION (RECOMPILE)
 RETURN 1;
END
