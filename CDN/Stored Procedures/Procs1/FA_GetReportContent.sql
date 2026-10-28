CREATE procedure [CDN].[FA_GetReportContent]
/*2019_0_329*/
 @Identyfikator int = 0,
 @Wdr_Typ  int = 0,
 @Wdr_Rodzaj int = 0,
 @Wdr_Waluta int = 0
AS
BEGIN
 DECLARE @Twr_Url    varchar(128),
   @DOK_Algorytm   int,
   @DOK_PodStatus   int,
   @DOK_PodatnikVat  int,
   @Dok_DataOpe   datetime,
   @Dok_FVMarza int,
   @Dok_Typ int,
   @Dok_Rodzaj int,
   @Dok_Akcyza int,
   @Konf_Akcyza int,
   @Kod_CN varchar(8)
  SET @Konf_Akcyza = (SELECT Fir_Wartosc FROM CDN.FIRMA WHERE Fir_Numer = 2151)
  IF @Identyfikator < 0
 BEGIN
  SELECT
  1 [Tre_Lp],
  CAST('Przykładowy Towar 1' as varchar(264) ) [TrE_Nazwa],
  CAST('10.51.11.0'  as varchar(32) ) [TrE_PKWiU],
  CAST(1 as varchar(32)) [Tre_Ilosc],
  CAST('szt'   as varchar(20) ) [Tre_JM],
  CAST('0,0000' as varchar(32)) [Tre_Cena],
  CAST('Przykładowy Opis Towaru ' as varchar(1024)) [Tre_Opis],
  CAST('23' as varchar(15)) + '%' [Tre_VAT],
  CAST(0.00 as decimal(16,2)) [Tre_Wartosc],
  CAST('www.comarch.pl' as varchar(128)) [Tre_Url],
  0 [Dok_FVMarza],
  CAST(0 as decimal(16,2)) [WartoscAkcyzy],
  CAST('' as varchar(32)) [PrzeliczenieKG],
  CAST('' as varchar(2)) [JednostkaKg],
  CAST('' as varchar(512)) [Tre_Akcyza]
  UNION ALL
  SELECT
  2 [Tre_Lp],
  CAST('Przykładowy Towar 2' as varchar(264) ) [TrE_Nazwa],
  CAST(''  as varchar(32) ) [TrE_PKWiU],
  CAST(1 as varchar(32)) [Tre_Ilosc],
  CAST('opak.'   as varchar(20) ) [Tre_JM],
  CAST('0,00' as varchar(32)) [Tre_Cena],
  CAST('' as varchar(256)) [Tre_Opis],
  CAST('8' as varchar(15)) + '%' [Tre_VAT],
  CAST(0.00 as decimal(16,2)) [Tre_Wartosc],
  CAST('www.comarch.pl' as varchar(128)) [Tre_Url],
  0 [Dok_FVMarza],
  CAST(0 as decimal(16,2)) [WartoscAkcyzy],
  CAST('' as varchar(32)) [PrzeliczenieKG],
  CAST('' as varchar(2)) [JednostkaKg],
  CAST('' as varchar(512)) [Tre_Akcyza]
  RETURN 0;
 END
 SELECT @DOK_Algorytm = TrN_TypNB,
  @DOK_PodStatus = TrN_Export,
  @DOK_PodatnikVat = TrN_PodatekVat,
  @Dok_DataOpe = TrN_DataOpe,
  @Dok_FVMarza = ISNULL(TrN_FVMarza,0),
  @Dok_Typ = TrN_TypDokumentu,
  @Dok_Rodzaj = TrN_Rodzaj,
  @Dok_Akcyza = ISNULL(TrN_ZwolnionyZAkcyzy,0)
 From CDN.TraNag
 where TrN_TrNID = @Identyfikator
  SELECT
  Tre_Lp   [Tre_Lp],
  CAST(CASE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 1995 /*Kolumna Towar*/)
  WHEN 2 /*Kod*/ THEN TrE_TwrKod
  WHEN 3 /*Nr Katalogowy*/ THEN TrE_TwrNumerKat
  WHEN 4 /*EAN*/ THEN TrE_TwrEAN
  WHEN 5 /*Kod i Nr Katalogowy*/ THEN  TrE_TwrKod + '; ' + TrE_TwrNumerKat
  WHEN 6 /*Kod i EAN*/ THEN TrE_TwrKod + '; ' + TrE_TwrEAN
  WHEN 7 /*Nr katalogowy i Kod*/ THEN TrE_TwrNumerKat + '; ' + TrE_TwrKod
  WHEN 8 /*EAN i Kod*/ THEN TrE_TwrEAN + '; ' + TrE_TwrKod
  WHEN 9 /*Nazwa i Nr Katalogowy*/ THEN TrE_TwrNazwa + '; ' + TrE_TwrNumerKat
  WHEN 10 /*Nr Katalogowy i Nazwa*/ THEN TrE_TwrNumerKat + '; ' + TrE_TwrNazwa
  WHEN 11 /*Kod i Nazwa*/ THEN TrE_TwrKod + '; ' + TrE_TwrNazwa
  ELSE TrE_TwrNazwa  END
  + CASE WHEN isNULL(TrE_KodCN,'') = '' OR TrE_AkcyzaOpal = 0 OR @Dok_Akcyza = 0 OR @Dok_FVMarza = 1 OR @Dok_Rodzaj = 302200 OR @Dok_Typ <> 302 OR @Konf_Akcyza = 0 THEN '' ELSE '; CN' + SUBSTRING(TrE_KodCN,1,4) END as varchar(256)) [TrE_Nazwa],
  CAST(CASE WHEN @Dok_Typ=320 AND @Wdr_Rodzaj=0 THEN CASE @DOK_Algorytm WHEN 1 THEN ' netto' ELSE ' brutto' END ELSE
  CASE WHEN isNULL(TrE_KodCN,'') = '' OR TrE_AkcyzaOpal = 0 OR @Dok_Akcyza = 0 OR @Dok_FVMarza = 1 OR @Dok_Rodzaj = 302200 OR @Dok_Typ <> 302 OR @Konf_Akcyza = 0 THEN
  CASE WHEN TrE_TwrSWW <> '' THEN TrE_TwrSWW ELSE ISNULL((SELECT KCN_Kod FROM CDN.Towary JOIN CDN.KodyCN ON Twr_KCNId = KCN_KCNId WHERE TrE_TwrId = Twr_TwrId),'') END ELSE CASE WHEN TrE_TwrSWW <> '' THEN TrE_TwrSWW ELSE SUBSTRING(TrE_KodCN,1,4) END END END as varchar(32) ) [TrE_PKWiU],
  CAST(replace(rtrim(replace(replace( rtrim(replace(convert(varchar(32),TrE_IloscJM),'0',' ')) , ' ' , '0' ),'.',' ')),' ',',') as varchar(32)) [Tre_Ilosc],
  CAST(Tre_JM as varchar(20) ) [Tre_JM],
  CASE WHEN @Dok_FVMarza = 0 THEN
  CAST(CASE Tre_CenaZCzteremaMiejscami WHEN 0 THEN replace(replace(convert(varchar(20),convert(Money,TrE_CenaWWD),1),',',' '), '.',',')
  ELSE replace(replace(convert(varchar(20),convert(Money,CAST(TrE_CenaWWD as decimal(16,4))),2),',',' '), '.',',') END as varchar(32))
  ELSE CAST('' as varchar(32)) END [Tre_Cena],
  CAST((CASE Tre_TwrOpis WHEN '' THEN '' ELSE Tre_TwrOpis END) as varchar(1024)) [Tre_Opis],
  CASE WHEN @Dok_FVMarza = 0 THEN
  CASE WHEN TrE_Flaga = 1 THEN CAST('ZW' as varchar(16))
  WHEN TrE_Flaga = 4 AND ((@DOK_PodStatus=5 and (@DOK_PodatnikVat=1 OR @Dok_DataOpe < CONVERT(DATETIME, '2015-07-01', 120))) OR @DOK_PodStatus in (8,9)) THEN CAST(char(45)+char(45)+char(45)+char(42) as varchar(16))
  WHEN TrE_Flaga = 4 AND ((@DOK_PodStatus<>5 OR (@DOK_PodatnikVat<>1 AND @Dok_DataOpe > CONVERT(DATETIME, '2015-07-01', 120))) AND @DOK_PodStatus not in (8,9)) THEN CAST('NP' as varchar(16))
  ELSE CAST(CAST(TrE_Stawka as INT) as varchar(15)) + '%' END
  ELSE CAST('' as varchar(16)) END [Tre_VAT],
  CAST(CASE @DOK_Algorytm WHEN 1 THEN TrE_WartoscNettoWal ELSE TrE_WartoscBruttoWal END as decimal(16,2)) [Tre_Wartosc],
  (SELECT Top 1 CAST(ISNULL(Twr_Url,'') as varchar(128)) From CDN.Towary where Twr_TwrId = TrE_TwrId) [Tre_Url],
  @Dok_FVMarza [Dok_FVMarza],
  CAST(CASE WHEN @Dok_Akcyza = 0 AND TrE_TypDokumentu = 302 AND TrE_AkcyzaStawka <> 0 AND @Dok_FVMarza <> 1 AND @Konf_Akcyza = 1 THEN (SELECT TrE_AkcyzaOpal * TrE_AkcyzaStawka * TrE_Ilosc * Tre_AkcyzaJMPomPrzelicznikM / Tre_AkcyzaJMPomPrzelicznikL)
  ELSE
  0
  END as decimal (16,2)) [WartoscAkcyzy],
  CAST(CASE WHEN @Dok_Akcyza <> 0 AND TrE_AkcyzaOpal <> 0 AND TrE_Jm <> 'kg' AND @Dok_FVMarza <> 1 AND @Dok_Typ = 302 AND @Konf_Akcyza = 1 THEN (SELECT replace(rtrim(replace(replace( rtrim(replace(convert(varchar(32),ROUND((1000 / (Tre_AkcyzaJMPomPrzelicznikL / Tre_AkcyzaJMPomPrzelicznikM) * TrE_Ilosc),4)),'0',' ')) , ' ' , '0' ),'.',' ')),' ',','))
  ELSE
  ''
  END as varchar(32)) [PrzeliczenieKG],
  CAST (CASE WHEN exists(SELECT TrE_Jm WHERE Tre_Jm like '%kg%') OR @Dok_Akcyza = 0 OR TrE_AkcyzaOpal = 0 OR @Dok_FVMarza = 1 OR @Dok_Typ <> 302 OR @Konf_Akcyza = 0 THEN ''
  ELSE
  'kg'
  END as varchar(2)) [JednostkaKg],
  CAST(CASE
   WHEN TrE_AkcyzaOpal = 0 OR @Dok_Akcyza = 0 OR @Dok_FVMarza = 1 OR @Dok_Typ <> 302 OR @Konf_Akcyza = 0 THEN
    ''
   ELSE
   'Przeznaczenie: ' + TrE_Akcyza_Wartosc
  END as varchar(512)) [Tre_Akcyza]
 FROM CDN.TraElem
 WHERE TrE_TrNId = @Identyfikator and TrE_Kaucja = 0
 ORDER BY Tre_Lp
 OPTION (RECOMPILE)
 RETURN 1;
END
