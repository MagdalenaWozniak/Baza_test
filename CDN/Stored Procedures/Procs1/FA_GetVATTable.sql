CREATE procedure [CDN].[FA_GetVATTable]
/*2018_5_1080*/
 @Identyfikator int = 0,
 @Tryb int = 0 /*na potrzeby FA_Koncowej*/
AS
BEGIN
 DECLARE
 @DOK_Algorytm   int,
 @DOK_PodStatus   int,
 @DOK_PodatnikVat  int,
 @Dok_DataOpe   datetime,
 @Dok_FVMarza int
 IF @Identyfikator < 0
 BEGIN
  SELECT
   CAST(23 as varchar(16)) + '%' [VAT_Stawka],
   CAST(0.00 as decimal(16,2)) [VAT_KwotaNetto],
   CAST(0.00 as decimal(16,2)) [VAT_KwotaVAT],
   CAST(0.00 as decimal(16,2)) [VAT_KwotaBrutto],
   0 [VAT_OO]
  UNION ALL
  SELECT
   CAST(8 as varchar(16)) + '%' [VAT_Stawka],
   CAST(0.00 as decimal(16,2)) [VAT_KwotaNetto],
   CAST(0.00 as decimal(16,2)) [VAT_KwotaVAT],
   CAST(0.00 as decimal(16,2)) [VAT_KwotaBrutto],
   0 [VAT_OO]
   RETURN 0;
 END
 SELECT @DOK_PodStatus = TrN_Export,
  @DOK_PodatnikVat = TrN_PodatekVat,
  @Dok_DataOpe = TrN_DataOpe,
  @Dok_FVMarza = ISNULL(Trn_FVMarza,0)
 From CDN.TraNag
 where TrN_TrNID = @Identyfikator
 IF @Dok_FVMarza = 0
  BEGIN
  SELECT
   CASE WHEN TrV_Flaga = 1 THEN CAST('ZW' as varchar(16))
   WHEN TrV_Flaga = 4 AND ((@DOK_PodStatus=5 and (@DOK_PodatnikVat=1 OR @Dok_DataOpe < CONVERT(DATETIME, '2015-07-01', 120))) OR @DOK_PodStatus in (8,9)) THEN char(45)+char(45)+char(45)+char(42)
   WHEN TrV_Flaga = 4 AND ((@DOK_PodStatus<>5 OR (@DOK_PodatnikVat<>1 AND @Dok_DataOpe > CONVERT(DATETIME, '2015-07-01', 120))) AND @DOK_PodStatus not in (8,9)) THEN 'NP'
   ELSE CAST(CAST(TrV_Stawka as INT) as varchar(16)) + '%' END [VAT_Stawka],
   CAST(SUM(TrV_Netto) as decimal(16,2)) [VAT_KwotaNetto],
   CAST(SUM(TrV_VAT) as decimal(16,2)) [VAT_KwotaVAT],
   CAST(SUM(TrV_Netto+TrV_VAT) as decimal(16,2)) [VAT_KwotaBrutto],
   CASE WHEN TrV_Flaga = 4 AND ((@DOK_PodStatus=5 and (@DOK_PodatnikVat=1 OR @Dok_DataOpe < CONVERT(DATETIME, '2015-07-01', 120))) OR @DOK_PodStatus in (8,9)) THEN 1
   ELSE 0 END [VAT_OO]
  FROM     CDN.TraVat
  WHERE  TrV_TrNID=@Identyfikator AND (@Tryb = 0 OR (@Tryb=1 AND TrV_Netto > 0))
  GROUP BY TrV_Stawka,TrV_Flaga
  ORDER BY TrV_Stawka desc, VAT_Stawka desc
  OPTION (RECOMPILE)
 END
 ELSE
 BEGIN
 SELECT
    CAST(8 as varchar(16)) [VAT_Stawka],
    CAST(0.00 as decimal(16,2)) [VAT_KwotaNetto],
    CAST(0.00 as decimal(16,2)) [VAT_KwotaVAT],
    CAST(0.00 as decimal(16,2)) [VAT_KwotaBrutto],
    0 [VAT_OO] WHERE 1=0
 END
 RETURN 1;
END
