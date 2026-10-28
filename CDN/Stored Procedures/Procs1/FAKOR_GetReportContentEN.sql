CREATE procedure [CDN].[FAKOR_GetReportContentEN]
 @Identyfikator int = 0,
 @Wdr_Typ  int = 0,
 @Wdr_Rodzaj int = 0,
 @Wdr_Waluta int = 0
AS
BEGIN
 DECLARE
  @Twr_Url    varchar(128),
  @DOK_Algorytm   int,
  @DOK_PodStatus   int,
  @DOK_PodStatusPrzed  int,
  @DOK_PodatnikVat  int,
  @DOK_PodatnikVatPrzed int,
  @Dok_DataOpe   datetime,
  @DOK_TypKor    int,
  @Dok_FVMarza   int,
  @Dok_Rodzaj    int,
  @Dok_Waluta    varchar(5),
  @Dok_Akcyza  int,
  @Konf_Akcyza int
 SELECT
  @DOK_Algorytm   = A.TrN_TypNB,
  @DOK_PodStatus   = A.TrN_Export,
  @DOK_PodatnikVat  = A.TrN_PodatekVat,
  @Dok_DataOpe   = A.TrN_DataOpe,
  @Dok_TypKor    = A.Trn_Korekta,
  @Dok_FVMarza   = ISNULL(A.TrN_FVMarza, 0),
  @Dok_Waluta    = A.Trn_Waluta,
  @DOK_PodStatusPrzed  = (SELECT P.Trn_Export  FROM cdn.tranag P WHERE P.TrN_TrnId = A.TrN_ZwrId),
  @DOK_PodatnikVatPrzed = (SELECT S.Trn_PodatekVat FROM cdn.tranag S WHERE S.TrN_TrnId = A.TrN_ZwrId),
  @Dok_Rodzaj    = A.TrN_Rodzaj,
  @Dok_Akcyza = ISNULL(TrN_ZwolnionyZAkcyzy,0)
 FROM CDN.TraNag A
 WHERE A.TrN_TrNId = @Identyfikator
 SET @Konf_Akcyza = (SELECT Fir_Wartosc FROM CDN.FIRMA WHERE Fir_Numer = 2151)
 IF @DOK_TypKor = 7
 BEGIN
  SELECT
   CAST(KOR.TrE_TwrNazwa as varchar(256)) [TrE_KorNazwa],
   CAST(CASE WHEN KOR.TrE_TwrSWW <> '' THEN KOR.TrE_TwrSWW ELSE ISNULL((SELECT KCN_Kod FROM CDN.Towary JOIN CDN.KodyCN ON Twr_KCNId = KCN_KCNId WHERE KOR.TrE_TwrId = Twr_TwrId),'') END as varchar(32))  [TrE_KorPKWiU],
   CAST(0 as varchar(32))     [Tre_KorIlosc],
   CAST(0 as varchar(32))     [Tre_KorCena],
   CAST(KOR.Tre_TwrOpis as varchar(1024)) [Tre_KorOpis],
   CAST('' as varchar(16))     [Tre_KorVAT],
   CAST(0 as decimal(10,2))    [Tre_KorWartosc],
   CAST(0 as decimal(16,2)) [Tre_KorFaWartoscAkcyzy],
   (SELECT Top 1
    CAST(ISNULL(Twr_Url,'') as varchar(128))
   FROM CDN.Towary
   WHERE
    Twr_TwrId = KOR.TrE_TwrId)   [TreKor_Url],
   FA.Tre_Lp [Tre_FaLp],
   CAST(FA.TrE_TwrNazwa as varchar(256)) [TrE_FaNazwa],
   CAST(CASE WHEN FA.Tre_TwrSww <> '' THEN FA.Tre_TwrSww ELSE ISNULL((SELECT KCN_Kod FROM CDN.Towary JOIN CDN.KodyCN ON Twr_KCNId = KCN_KCNId WHERE FA.TrE_TwrId = Twr_TwrId),'') END as varchar(32))  [TrE_FaPKWiU],
   CAST(0 as varchar(32))     [Tre_FaIlosc],
   CAST('Before Correction' as varchar(20)) [Tre_FaJM],
   CAST(0 as varchar(32))     [Tre_FaCena],
   CAST('After Correction' as varchar(16))  [Tre_FaVAT],
   CAST(0 as decimal(10,2))    [Tre_FaWartosc],
   CAST(0 as decimal(16,2)) [Tre_FaWartoscAkcyzyPrzed],
   CAST(FA.Tre_TwrOpis as varchar(1024)) [TrE_PoNazwa],
   CAST(0 as varchar(32))     [Tre_PoCena],
   CAST(0 as varchar(32))     [Tre_PoIlosc],
   CAST(0 as decimal(10,2))    [Tre_PoWartosc],
   CAST(0 as varchar(32))     [Tre_CenaWal],
   CAST('' as varchar(5))     [Tre_Waluta],
   CASE
    WHEN KOR.TrE_TwrNazwa = FA.TrE_TwrNazwa AND
      KOR.Tre_TwrOpis  = FA.Tre_TwrOpis AND
      KOR.TrE_TwrSWW  = FA.Tre_TwrSww  THEN
     0
    ELSE
     1
   END [Tre_KorPoz]
  FROM  CDN.TraElem KOR
  LEFT JOIN CDN.TraElem FA ON FA.TrE_TrEId = KOR.TrE_ZwrId
  WHERE KOR.TrE_TrNID = @Identyfikator
  OPTION (RECOMPILE)
  RETURN 0;
 END
    IF @DOK_TypKor = 6
 BEGIN
  SELECT
   CAST('' as varchar(256)) [TrE_KorNazwa],
   CAST(CASE
     WHEN TreZ_Waluta = '' THEN
      'PLN'
     ELSE
      TreZ_Waluta
    END
   as varchar(32))    [TrE_KorPKWiU],
   CAST(0 as varchar(32))  [Tre_KorIlosc],
   CAST(0 as varchar(32))  [Tre_KorCena],
   CAST('' as varchar(1024)) [Tre_KorOpis],
   CASE
    WHEN TreZ_Flaga = 1 THEN
     CAST('ZW' as varchar(16))
    WHEN TreZ_Flaga = 4 THEN
     CAST('NP' as varchar(16))
    ELSE
     CAST(TreZ_Stawka as varchar(15)) + '%'
   END [Tre_KorVAT],
   CAST(TreZ_Rabat as decimal(10,2)) [Tre_KorWartosc],
   CAST(0 as decimal(16,2)) [Tre_KorFaWartoscAkcyzy],
   CAST('' as varchar(128)) [TreKor_Url],
   0 [Tre_FaLp],
   CAST('' as varchar(256)) [TrE_FaNazwa],
   CAST('' as varchar(32))  [TrE_FaPKWiU],
   CAST(0 as varchar(32))  [Tre_FaIlosc],
   CAST('' as varchar(20))  [Tre_FaJM],
   CAST(0 as varchar(32))  [Tre_FaCena],
   CAST('' as varchar(16))  [Tre_FaVAT],
   CAST(TreZ_WartoscFaktur as decimal(10,2)) [Tre_FaWartosc],
   CAST(0 as decimal(16,2)) [Tre_FaWartoscAkcyzyPrzed],
   CAST('' as varchar(1024)) [TrE_PoNazwa],
   CAST(0 as varchar(32))  [Tre_PoCena],
   CAST(0 as varchar(32))  [Tre_PoIlosc],
   CAST(0 as decimal(10,2)) [Tre_PoWartosc],
   CAST(0 as varchar(32))  [Tre_CenaWal],
   CAST('' as varchar(5))  [Tre_Waluta],
   0 [Tre_KorPoz]
  FROM CDN.TraElemKorZbiorcza
  WHERE TreZ_TrNID = @Identyfikator
  ORDER BY TreZ_Stawka desc
  OPTION (RECOMPILE)
  RETURN 0;
 END
 SELECT
  /*DANE ELEMENTOW KOREKTA*/
  CAST('Correction: ' AS VARCHAR(256)) [TrE_KorNazwa],
  CAST(CASE
    WHEN @Dok_Rodzaj = 302202 THEN
     ''
    ELSE
     CASE WHEN KOR.TrE_TwrSWW <> '' THEN KOR.TrE_TwrSWW ELSE ISNULL((SELECT KCN_Kod FROM CDN.Towary JOIN CDN.KodyCN ON Twr_KCNId = KCN_KCNId WHERE KOR.TrE_TwrId = Twr_TwrId),'') END
   END
  AS VARCHAR(32)) [TrE_KorPKWiU],
  CAST(replace(rtrim(replace(replace( rtrim(replace(convert(varchar(32),(CASE
                     WHEN @DOK_TypKor <> 1 THEN
                      KOR.TrE_IloscJMKW
                     ELSE
                      KOR.TrE_IloscJM
                    END)),'0',' ')) , ' ' , '0' ),'.',' ')),' ',',')
  AS VARCHAR(32)) [Tre_KorIlosc],
  CAST( CASE
   WHEN @Dok_FVMarza = 0 THEN
    CASE
     WHEN @DOK_TypKor = 2 THEN
      CASE @Dok_Rodzaj WHEN 302202 THEN
       replace(replace(convert(varchar(20),convert(Money,KOR.TrE_WartoscNettoWal),1),',',' '), '.',',')
      ELSE
       (CASE
        WHEN KOR.Tre_CenaZCzteremaMiejscami = 0 THEN
         replace(replace(convert(varchar(20),convert(Money,(KOR.TrE_CenaWWD - KOR.Tre_Cena0WD)),1),',',' '), '.',',')
        ELSE
         replace(replace(convert(varchar(20),convert(Money,CAST((KOR.TrE_CenaWWD - KOR.Tre_Cena0WD) as decimal(16,4))),2),',',' '), '.',',')
       END)
      END
     WHEN @DOK_TypKor = 8 THEN
      CASE @Dok_Rodzaj WHEN 302202 THEN
       replace(replace(convert(varchar(20),convert(Money, -KOR.TrE_WartoscNetto),1),',',' '), '.',',')
      ELSE
       (CASE
        WHEN KOR.Tre_CenaZCzteremaMiejscami = 0 THEN
         replace(replace(convert(varchar(20),convert(Money,(KOR.TrE_CenaW - KOR.TrE_Cena0)),1),',',' '), '.',',')
        ELSE
         replace(replace(convert(varchar(20),convert(Money,CAST((KOR.TrE_CenaW - KOR.TrE_Cena0) as decimal(16,4))),2),',',' '), '.',',')
       END)
      END
     ELSE
      (CASE
       WHEN KOR.Tre_CenaZCzteremaMiejscami = 0 THEN
        replace(replace(convert(varchar(20),convert(Money,(KOR.TrE_CenaWWD)),1),',',' '), '.',',')
       ELSE replace(replace(convert(varchar(20),convert(Money,CAST((KOR.TrE_CenaWWD) as decimal(16,4))),2),',',' '), '.',',')
      END)
    END
   ELSE ''
   END
  as varchar(32)) [Tre_KorCena],
  CAST((CASE
    WHEN KOR.Tre_TwrOpis = '' THEN
     ''
    ELSE
     KOR.Tre_TwrOpis
    END)
  as varchar(1024)) [Tre_KorOpis],
  CASE
   WHEN @Dok_FVMarza = 0 AND @Dok_Rodzaj <> 302202 THEN
    CASE
     WHEN KOR.TrE_Flaga = 1 THEN
      CAST('ZW' as varchar(16))
     WHEN KOR.TrE_Flaga = 4 AND ((@DOK_PodStatus=5 and (@DOK_PodatnikVat=1 OR @Dok_DataOpe < CONVERT(DATETIME, '2015-07-01', 120))) OR @DOK_PodStatus in (8,9)) THEN
      CAST(char(45)+char(45)+char(45)+char(42) as varchar(16))
     WHEN KOR.TrE_Flaga = 4 AND ((@DOK_PodStatus<>5 OR (@DOK_PodatnikVat<>1 AND @Dok_DataOpe > CONVERT(DATETIME, '2015-07-01', 120))) AND @DOK_PodStatus not in (8,9))
      THEN CAST('NP' as varchar(16))
     ELSE CAST(CAST(KOR.TrE_Stawka as INT) as varchar(15)) + '%'
    END
   WHEN @Dok_FVMarza = 0 AND @Dok_Rodzaj = 302202 AND @DOK_TypKor = 8 THEN
    CAST(replace(replace(convert(varchar(20),convert(Money,(KOR.TrE_WartoscNetto - KOR.TrE_WartoscBrutto)),1),',',' '), '.',',')as varchar(16))
   WHEN @Dok_FVMarza = 0 AND @Dok_Rodzaj = 302202 AND @DOK_TypKor = 2 THEN
    CAST(replace(replace(convert(varchar(20),convert(Money,(KOR.TrE_WartoscBruttoWal-KOR.TrE_WartoscNettoWal)),1),',',' '), '.',',')as varchar(16))
   ELSE
    CAST('' as varchar(16))
  END [Tre_KorVAT],
  CASE
   WHEN @DOK_TypKor = 8 THEN
    CASE
     WHEN @Dok_Rodzaj = 302202 THEN
      CAST(-KOR.TrE_WartoscBrutto as decimal(10,2))
     ELSE
      CAST(CASE
        WHEN @DOK_Algorytm = 1 THEN
         KOR.TrE_WartoscNetto
        ELSE
         KOR.TrE_WartoscBrutto
       END
      as decimal(10,2))
    END
   ELSE
    CAST(CASE
      WHEN @DOK_Algorytm = 1 THEN
       KOR.TrE_WartoscNettoWal
      ELSE
       KOR.TrE_WartoscBruttoWal
     END
    as decimal(10,2))
  END [Tre_KorWartosc],
   CAST(CASE WHEN @Dok_Akcyza = 0 AND KOR.TrE_TypDokumentu = 302 AND KOR.TrE_AkcyzaStawka <> 0 AND @Dok_FVMarza <> 1 AND @Konf_Akcyza = 1 AND @DOK_TypKor = 1 THEN (SELECT KOR.TrE_AkcyzaOpal * KOR.TrE_AkcyzaStawka * KOR.TrE_Ilosc * KOR.Tre_AkcyzaJMPomPrzelicznikM / KOR.Tre_AkcyzaJMPomPrzelicznikL)
  ELSE
  0
  END as decimal (16,2)) [Tre_KorFaWartoscAkcyzy],
  (SELECT Top 1
   CAST(ISNULL(Twr_Url,'') as varchar(128))
  FROM CDN.Towary
  WHERE Twr_TwrId = KOR.TrE_TwrId) [TreKor_Url],
  /*DANE ELEMENTOW PRZED KOREKTA*/
  FA.Tre_Lp   [Tre_FaLp],
  CAST(KOR.TrE_TwrNazwa as varchar(256) ) [TrE_FaNazwa],
  CAST(CASE
    WHEN @Dok_Rodzaj = 302202 THEN
     ''
    ELSE
     CASE WHEN FA.Tre_TwrSww <> '' THEN FA.Tre_TwrSww ELSE ISNULL((SELECT KCN_Kod FROM CDN.Towary JOIN CDN.KodyCN ON Twr_KCNId = KCN_KCNId WHERE FA.TrE_TwrId = Twr_TwrId),'') END
    END
  AS VARCHAR(32) ) [TrE_FaPKWiU],
  CAST(CASE
    WHEN @Dok_Rodzaj = 302202 THEN
     NULL
    ELSE
     replace(rtrim(replace(replace( rtrim(replace(convert(varchar(32),(SELECT top 1 IloscJmOrg FROM CDN.TraElemKorekta(KOR.Tre_TreId))),'0',' ')) , ' ' , '0' ),'.',' ')),' ',',')
    END
  AS VARCHAR(32)) [Tre_FaIlosc],
  CAST(FA.Tre_JM   as varchar(20) ) [Tre_FaJM],
  CAST( CASE
    WHEN @Dok_FVMarza = 0 THEN
     CASE
      WHEN @DOK_TypKor = 8 THEN
       CASE
        WHEN @Dok_Rodzaj = 302202 THEN
         replace(replace(convert(varchar(20),convert(Money,(SELECT top 1
                 A.TrE_WartoscNetto  + SUM(IsNull(B.TrE_WartoscNetto,0))
               FROM CDN.TraElem A
               LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
                  ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
               WHERE A.TrE_TrEId = KOR.Tre_ZwrId
               GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm
             )),1),',',' '), '.',',')
        ELSE
         CASE
          WHEN FA.Tre_CenaZCzteremaMiejscami = 0 THEN
           replace(replace(convert(varchar(20),convert(Money,(SELECT top 1 CenaTOrg FROM CDN.TraElemKorekta(KOR.Tre_TreId))),1),',',' '), '.',',')
          ELSE
           replace(replace(convert(varchar(20),convert(Money,CAST((SELECT top 1 CenaTOrg FROM CDN.TraElemKorekta(KOR.Tre_TreId)) as decimal(16,4))),2),',',' '), '.',',')
         END
       END
      ELSE
       CASE
        WHEN @Dok_Rodzaj = 302202 THEN
         replace(replace(convert(varchar(20),convert(Money,(SELECT top 1
                 A.TrE_WartoscNettoWal  + SUM(IsNull(B.TrE_WartoscNettoWal,0))
               FROM CDN.TraElem A
               LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
                  ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
               WHERE A.TrE_TrEId = KOR.Tre_ZwrId
               GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm
             )),1),',',' '), '.',',')
        ELSE
         CASE
          WHEN FA.Tre_CenaZCzteremaMiejscami = 0 THEN
           replace(replace(convert(varchar(20),convert(Money,KOR.Tre_Cena0WD),1),',',' '), '.',',')
          ELSE
           replace(replace(convert(varchar(20),convert(Money,CAST(KOR.TrE_Cena0WD as decimal(18,4))),2),',',' '), '.',',')
         END
       END
     END
    ELSE
     ''
   END
  as varchar(32)) [Tre_FaCena],
  CASE
   WHEN @Dok_FVMarza = 0 AND @Dok_Rodzaj <> 302202 THEN
    CASE
     WHEN (SELECT top 1 FlagaVatOrg FROM CDN.TraElemKorekta(KOR.Tre_TreId)) = 1 THEN
      CAST('ZW' as varchar(16))
     WHEN ((SELECT top 1 FlagaVatOrg FROM CDN.TraElemKorekta(KOR.Tre_TreId)) = 4) AND ((@DOK_PodStatusPrzed=5 and (@DOK_PodatnikVatPrzed=1 OR @Dok_DataOpe < CONVERT(DATETIME, '2015-07-01', 120))) OR @DOK_PodStatusPrzed in (8,9)) THEN
      CAST(char(45)+char(45)+char(45)+char(42) as varchar(16))
     WHEN ((SELECT top 1 FlagaVatOrg FROM CDN.TraElemKorekta(KOR.Tre_TreId)) = 4) AND ((@DOK_PodStatusPrzed<>5 OR (@DOK_PodatnikVatPrzed<>1 AND @Dok_DataOpe > CONVERT(DATETIME, '2015-07-01', 120))) AND @DOK_PodStatusPrzed not in (8,9)) THEN
      CAST('NP' as varchar(16))
     ELSE
      CAST(CAST((SELECT top 1 StawkaVatOrg FROM CDN.TraElemKorekta(KOR.Tre_TreId)) as INT) as varchar(15)) + '%'
    END
   WHEN @Dok_FVMarza = 0 AND @Dok_Rodzaj = 302202 AND @DOK_TypKor = 8 THEN
    CAST(replace(replace(convert(varchar(20),convert(Money,(SELECT top 1
                (A.TrE_WartoscBrutto + SUM(IsNull(B.TrE_WartoscBrutto,0))) - (A.TrE_WartoscNetto  + SUM(IsNull(B.TrE_WartoscNetto,0)))
               FROM CDN.TraElem A
               LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
                  ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
               WHERE A.TrE_TrEId = KOR.Tre_ZwrId
               GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm
             )),1),',',' '), '.',',') as varchar(16))
   WHEN @Dok_FVMarza = 0 AND @Dok_Rodzaj = 302202 AND @DOK_TypKor <> 8 THEN
    CAST(replace(replace(convert(varchar(20),convert(Money,(SELECT top 1
                (A.TrE_WartoscBruttoWal + SUM(IsNull(B.TrE_WartoscBruttoWal,0)))-(A.TrE_WartoscNettoWal  + SUM(IsNull(B.TrE_WartoscNettoWal,0)))
               FROM CDN.TraElem A
               LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
                  ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
               WHERE A.TrE_TrEId = KOR.Tre_ZwrId
               GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm
 )),1),',',' '), '.',',') as varchar(16))
   ELSE
    CAST('' as varchar(16))
  END [Tre_FaVAT],
  CASE
   WHEN @DOK_TypKor = 8 THEN
  CASE
   WHEN @Dok_Rodzaj = 302202 THEN
    CAST((SELECT top 1
       A.TrE_WartoscBrutto + SUM(IsNull(B.TrE_WartoscBrutto,0))
      FROM CDN.TraElem A
      LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
         ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
      WHERE A.TrE_TrEId = KOR.Tre_ZwrId
      GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm)
    as decimal(10,2))
   ELSE
    CAST(( SELECT
       CASE
     WHEN @DOK_Algorytm = 1 THEN
      WartoscNOrg
     ELSE
      WartoscBOrg
       END
      FROM CDN.TraElemKorekta(KOR.Tre_TreId))
    as decimal(10,2))
  END
   ELSE
  CASE
   WHEN @Dok_Rodzaj = 302202 THEN
    CAST((SELECT top 1
       A.TrE_WartoscBruttoWal + SUM(IsNull(B.TrE_WartoscBruttoWal,0))
      FROM CDN.TraElem A
      LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
         ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
      WHERE A.TrE_TrEId = KOR.Tre_ZwrId
      GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm)
    as decimal(10,2))
   ELSE
    CAST(( SELECT
       CASE
     WHEN @DOK_Algorytm = 1 THEN
      WartoscNWalOrg
     ELSE
      WartoscBWalOrg
       END
      FROM CDN.TraElemKorekta(KOR.Tre_TreId))
    as decimal(10,2))
  END
  END [Tre_FaWartosc],
  CAST(CASE WHEN @Dok_Akcyza = 0 AND Fa.TrE_TypDokumentu = 302 AND FA.TrE_AkcyzaStawka <> 0 AND @Dok_FVMarza <> 1 AND @Konf_Akcyza = 1 AND @DOK_TypKor = 1 THEN (SELECT FA.TrE_AkcyzaOpal * FA.TrE_AkcyzaStawka * FA.TrE_Ilosc * FA.Tre_AkcyzaJMPomPrzelicznikM / FA.Tre_AkcyzaJMPomPrzelicznikL)
  ELSE
  0
  END as decimal (16,2)) [Tre_FaWartoscAkcyzyPrzed],
  CAST('After Correction: ' as varchar(256) ) [TrE_PoNazwa],
  /*DANE ELEMENTOW PO KOREKCIE*/
  CAST(CASE
    WHEN @Dok_FVMarza = 0 THEN
     CASE
      WHEN @Dok_TypKor = 8 THEN
       CASE
        WHEN @Dok_Rodzaj = 302202 THEN
         replace(replace(convert(varchar(20),convert(Money,(SELECT top 1
                 A.TrE_WartoscNetto  + SUM(IsNull(B.TrE_WartoscNetto,0)) - KOR.TrE_WartoscNetto
               FROM CDN.TraElem A
               LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
                  ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
               WHERE A.TrE_TrEId = KOR.Tre_ZwrId
               GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm
             )),1),',',' '), '.',',')
        ELSE
         CASE
          WHEN FA.Tre_CenaZCzteremaMiejscami = 0 THEN
           replace(replace(convert(varchar(20),convert(Money,KOR.TrE_CenaT),1),',',' '), '.',',')
          ELSE
           replace(replace(convert(varchar(20),convert(Money,CAST(KOR.TrE_CenaT as decimal(16,4))),2),',',' '), '.',',')
         END
       END
      WHEN @DOK_TypKor = 2 OR @Dok_TypKor = 3 THEN
       CASE
        WHEN @Dok_Rodzaj = 302202 THEN
         replace(replace(convert(varchar(20),convert(Money,(SELECT top 1
                 A.TrE_WartoscNettoWal  + SUM(IsNull(B.TrE_WartoscNettoWal,0)) + KOR.TrE_WartoscNettoWal
               FROM CDN.TraElem A
               LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
                  ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
               WHERE A.TrE_TrEId = KOR.Tre_ZwrId
               GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm
             )),1),',',' '), '.',',')
        ELSE
         CASE
          WHEN FA.Tre_CenaZCzteremaMiejscami = 0 THEN
           replace(replace(convert(varchar(20),convert(Money, ((SELECT CASE
                           WHEN @DOK_Algorytm = 1 THEN
                            WartoscNWalOrg + KOR.TrE_WartoscNettoWal
                           ELSE
                            WartoscBWalOrg + KOR.TrE_WartoscBruttoWal
                          END
                        FROM CDN.TraElemKorekta(KOR.Tre_TreId))/
           (SELECT top 1 CASE
               WHEN IloscJmOrg = 0 THEN
                1
               ELSE
                IloscJMOrg
              END
           FROM CDN.TraElemKorekta(KOR.Tre_TreId)))),1),',',' '), '.',',')
          ELSE
           replace(replace(convert(varchar(20),convert(Money,CAST( ((SELECT KOR.Tre_Cena0WD*IloscJMOrg + KOR.TrE_IloscJMKW * (KOR.TrE_CenaWWD - KOR.Tre_Cena0WD) FROM CDN.TraElemKorekta(KOR.Tre_TreId)) /
          (SELECT top 1 CASE IloscJmOrg WHEN 0 THEN 1 ELSE IloscJMOrg END FROM CDN.TraElemKorekta(KOR.Tre_TreId))) as decimal(16,4))),2),',',' '), '.',',')
         END
       END
      ELSE
       CASE
        WHEN FA.Tre_CenaZCzteremaMiejscami = 0 THEN
         replace(replace(convert(varchar(20),convert(Money,KOR.TrE_CenaWWD),1),',',' '), '.',',')
        ELSE
         replace(replace(convert(varchar(20),convert(Money,CAST(KOR.TrE_CenaWWD as decimal(16,4))),2),',',' '), '.',',')
       END
     END
    ELSE
     ''
   END
  as varchar(32)) [Tre_PoCena],
  CAST(replace(rtrim(replace(replace( rtrim(replace(convert(varchar(32),(CASE
                    WHEN @DOK_TypKor <> 1 THEN
                     (SELECT top 1
                      IloscJmOrg
                     FROM CDN.TraElemKorekta(KOR.Tre_TreId))
                    ELSE
                     (SELECT top 1
                      IloscJmOrg
                     FROM CDN.TraElemKorekta(KOR.Tre_TreId)) +
                     (CASE
                      WHEN @DOK_TypKor = 2 THEN
                       KOR.TrE_IloscJMKW
                      ELSE
                       KOR.TrE_IloscJM
                     END)
                    END)),'0',' ')) , ' ' , '0' ),'.',' ')),' ',',')
  as varchar(32)) [Tre_PoIlosc],
  CASE
   WHEN @DOK_TypKor = 8 THEN
    CASE
     WHEN @Dok_Rodzaj = 302202 THEN
      CAST((SELECT top 1
     A.TrE_WartoscBrutto + SUM(IsNull(B.TrE_WartoscBrutto,0)) - KOR.TrE_WartoscBrutto
    FROM CDN.TraElem A
    LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
       ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
    WHERE A.TrE_TrEId = KOR.Tre_ZwrId
    GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm)
         AS decimal(10,2))
     ELSE
      CAST(( SELECT CASE
           WHEN @DOK_Algorytm = 1 THEN
            WartoscNOrg + KOR.TrE_WartoscNetto
           ELSE
            WartoscBOrg + KOR.TrE_WartoscBrutto
          END
        FROM CDN.TraElemKorekta(KOR.Tre_TreId))
     as decimal(10,2))
    END
   ELSE
 CASE
  WHEN @Dok_Rodzaj = 302202 THEN
    CAST((SELECT top 1
       A.TrE_WartoscBruttoWal + SUM(IsNull(B.TrE_WartoscBruttoWal,0)) + KOR.TrE_WartoscBruttoWal
     FROM CDN.TraElem A
     LEFT OUTER JOIN (CDN.TraElem B JOIN CDN.TraNag  C ON B.TrE_TrNId = C.TrN_TrNId AND C.TrN_Korekta<>5 AND C.TrN_Bufor<>1 )
        ON A.TrE_TrEId = B.TrE_ZwrId AND (SELECT T.TrN_Bufor FROM CDN.TraNag T WHERE B.TrE_TrNId = T.TrN_TrNID)<>-1 AND B.TrE_TrEId < KOR.Tre_TreId
     WHERE A.TrE_TrEId = KOR.Tre_ZwrId
     GROUP BY A.TrE_TrEId, A.TrE_WartoscNetto, A.TrE_WartoscBrutto, A.TrE_WartoscNettoWal, A.TrE_WartoscBruttoWal, A.TrE_WartoscZakupu, A.TrE_Ilosc, A.TrE_IloscJm)
    AS decimal(10,2))
   ELSE
   CAST(( SELECT CASE
     WHEN @DOK_Algorytm = 1 THEN
      WartoscNWalOrg + KOR.TrE_WartoscNettoWal
     ELSE
      WartoscBWalOrg + KOR.TrE_WartoscBruttoWal
    END
     FROM CDN.TraElemKorekta(KOR.Tre_TreId))
      as decimal(10,2))
 END
  END [Tre_PoWartosc],
  CAST(CASE
    WHEN FA.Tre_CenaZCzteremaMiejscami = 0 THEN
     replace(replace(convert(varchar(20),convert(Money,KOR.Tre_Cena0WD),1),',',' '), '.',',')
    ELSE
     replace(replace(convert(varchar(20),convert(Money,CAST(KOR.TrE_Cena0WD as decimal(18,4))),2),',',' '), '.',',')
   END
  as varchar(32)) [Tre_CenaWal],
  CASE
   WHEN @DOK_TypKor=8 AND @Dok_Rodzaj=302202 THEN
    'PLN'
   ELSE
    @Dok_Waluta
  END [Tre_Waluta],
  0 [Tre_KorPoz]
 FROM CDN.TraElem KOR
 LEFT JOIN CDN.TraElem FA ON FA.TrE_TrEId = KOR.TrE_ZwrId
 WHERE KOR.TrE_TrNID = @Identyfikator
 Order by KOR.TrE_Lp
 OPTION (RECOMPILE)
 RETURN 1;
END
