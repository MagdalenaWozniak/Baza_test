CREATE procedure [CDN].[FA_GetPaymentTable]
/*2018_5_1162*/
 @Identyfikator int = 0
AS
BEGIN
DECLARE @Kor_Typ int,
  @Dok_Rodzaj int,
  @Dok_PAFACzesciowe int
SELECT  @Identyfikator = CASE WHEN Trn_Korekta = 7 THEN Trn_ZwrID ELSE Trn_TrnID END,
  @Kor_Typ = Trn_Korekta,
  @Dok_Rodzaj = Trn_Rodzaj,
  @Dok_PAFACzesciowe = TrN_PAFACzesciowe
FROM CDN.tranag where TrN_TrNId = @Identyfikator
 IF @Identyfikator < 0
 BEGIN
  SELECT
   CAST('gotówka' as varchar(64)) [Plt_Nazwa],
   CAST(CONVERT(date,GETDATE(),120) as varchar(10)) [Plt_Termin],
   CAST('0,00' as varchar(32)) + ' ' + CAST('PLN' as varchar(4)) [Plt_Kwota]
  RETURN 0;
 END
 DECLARE @Dok_PowiazaniezPA  int;
 SET @Dok_PowiazaniezPA = isnull ( (Select TOP 1 TrN_TypDokumentu from CDN.TraNagRelacje JOIN CDN.TraNag ON Trr_FaId = TrN_TrNId WHERE TrR_TrNID= @Identyfikator AND TrR_TrNTyp = 302 AND TrN_TypDokumentu = 305),0 )
 --Jeśli cześciowa z PA
 IF @Dok_PAFACzesciowe = 1
 BEGIN
 SELECT
   CAST('' as varchar(64)) [Plt_Nazwa],
   CAST('' as varchar(10)) [Plt_Termin],
   CAST('' as varchar(32)) [Plt_Kwota]
 RETURN 0
 END
 --Jeśli Pro-Forma
 IF @Dok_Rodzaj IN (320000,320008,320009,320200)
 BEGIN
SELECT
   CAST(CASE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 1998 /*Forma płatności*/)
  WHEN 2 THEN CASE FPl_Typ
     WHEN 1 THEN 'Gotówka'
     WHEN 2 THEN 'Przelew'
     WHEN 3 THEN 'Karta'
     ELSE 'Kompensata' END
  ELSE FPl_Nazwa END as varchar(64)) [Plt_Nazwa],
   CAST(CONVERT(date,TrN_Termin,120) as varchar(10)) [Plt_Termin],
   CAST('' as varchar(32)) [Plt_Kwota]
 FROM CDN.TRANAG
 JOIN CDN.FormyPlatnosci ON TrN_FPlId = FPl_FPlId
 WHERE TRN_TRNID = @Identyfikator
 END
 IF @Dok_PowiazaniezPA = 305 AND @Dok_Rodzaj NOT IN (320000,320008,320009,320200)
 BEGIN
  SELECT
   CAST(CASE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 1998 /*Forma płatności*/)
  WHEN 2 THEN CASE FPl_Typ
     WHEN 1 THEN 'Gotówka'
     WHEN 2 THEN 'Przelew'
     WHEN 3 THEN 'Karta'
     ELSE 'Kompensata' END
  ELSE FPl_Nazwa END as varchar(64)) [Plt_Nazwa],
   CAST(CONVERT(date,BZd_Termin,120) as varchar(10)) [Plt_Termin],
   CAST(CASE WHEN @Kor_Typ = 7 THEN char(45)+char(45)+char(45)
   ELSE replace(replace(convert(varchar(20),convert(Money,BZd_Kwota),1),',',' '), '.',',') +  CASE BZd_Waluta WHEN '' THEN ' PLN' ELSE ' ' + BZd_Waluta END END as varchar(32)) [Plt_Kwota]
  FROM CDN.BnkZdarzenia
  JOIN CDN.FormyPlatnosci ON BZd_FPlId = FPl_FPlId
  JOIN cdn.TraNagRelacje ON BZd_DokumentID=TrR_TrNId and TrR_TrNTyp = 305
  WHERE Bzd_DokumentTyp=1 AND trr_FaId = @Identyfikator
  ORDER BY Plt_Termin
  OPTION (RECOMPILE)
 END
 ELSE
 BEGIN
  SELECT
      CAST(CASE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 1998 /*Forma płatności*/)
  WHEN 2 THEN CASE FPl_Typ
     WHEN 1 THEN 'Gotówka'
     WHEN 2 THEN 'Przelew'
     WHEN 3 THEN 'Karta'
     ELSE 'Kompensata' END
  ELSE FPl_Nazwa END as varchar(64)) [Plt_Nazwa],
   CAST(CONVERT(date,BZd_Termin,120) as varchar(10)) [Plt_Termin],
   CAST(CASE WHEN @Kor_Typ = 7 THEN char(45)+char(45)+char(45)
   ELSE replace(replace(convert(varchar(20),convert(Money,BZd_Kwota),1),',',' '), '.',',') +  CASE BZd_Waluta WHEN '' THEN ' PLN' ELSE ' ' + BZd_Waluta END END as varchar(32)) [Plt_Kwota]
  FROM CDN.BnkZdarzenia JOIN CDN.FormyPlatnosci ON BZd_FPlId = FPl_FPlId
  WHERE  BZd_DokumentTyp=1 AND BZd_DokumentID=@Identyfikator
  ORDER BY Plt_Termin
  OPTION (RECOMPILE)
  RETURN 1;
 END
END
