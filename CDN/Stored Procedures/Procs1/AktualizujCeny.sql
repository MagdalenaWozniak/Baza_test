CREATE PROCEDURE [CDN].[AktualizujCeny]
@ID INT
AS
BEGIN
DECLARE
 @TrN_Rodzaj int,
 @TrN_TypDokumentu int,
 @TrN_Bufor int,
 @TrN_Waluta     NVARCHAR(3),
 @TrN_KursNumer INT,
 @TrN_KursL     DECIMAL(15,4),
 @TrN_KursM     DECIMAL(5,0),
 @WalutaSys NVARCHAR(3),
 @TrN_AktualizacjaCenyZakKor TINYINT,
 @TrN_Korekta TINYINT,
 @TrN_TypNB INT,
 @TrN_OpeModID INT,
 @TrN_OpeModKod VARCHAR(20),
 @TrN_OpeModNazwisko NVARCHAR(50),
 @TrN_StaModID INT,
 @Aktualizuj_CenaZ_MMOL TINYINT,
 @Aktualizuj_Cena_Zak_Po_Kor TINYINT,
 @Aktualizuj_Cena_Zak_Po_Kor_Typ TINYINT,
 @TrN_WalutaGraniczna     NVARCHAR(3),
 @TrN_ZwrId INT,
  --log
 @fromParam NVARCHAR(1024),
 @whereParam NVARCHAR(1024)
 SELECT TOP 1 @Aktualizuj_Cena_Zak_Po_Kor = CONVERT(TINYINT, ISNULL(Fir_Wartosc,0)) FROM cdn.Firma WHERE Fir_Numer = 2235
 SELECT TOP 1 @Aktualizuj_Cena_Zak_Po_Kor_Typ = CONVERT(TINYINT, ISNULL(Fir_Wartosc,0)) FROM cdn.Firma WHERE Fir_Numer = 2236
 SELECT @TrN_WalutaGraniczna = ''
SELECT @WalutaSys = SUBSTRING(Fir_Wartosc,1,3) FROM cdn.Firma WHERE Fir_Numer = 3
SELECT @TrN_Rodzaj  = TrN_Rodzaj, @TrN_TypDokumentu = TrN_TypDokumentu, @TrN_Bufor = TrN_Bufor, @TrN_Waluta = TrN_Waluta, @TrN_KursL=TrN_KursL, @TrN_KursM= TrN_KursM ,
@TrN_KursNumer = TrN_KursNumer, @TrN_TypNB = TrN_TypNB, @TrN_OpeModID = TrN_OpeModID , @TrN_OpeModKod = TrN_OpeModKod, @TrN_OpeModNazwisko = TrN_OpeModNazwisko, @TrN_StaModID =TrN_StaModID,@TrN_AktualizacjaCenyZakKor = TrN_AktualizacjaCenyZakKor,@TrN_Korekta = TrN_Korekta,@TrN_ZwrId = TrN_ZwrId FROM CDN.TraNag WHERE TrN_TrNId  = @ID
  IF @TrN_Rodzaj = 312010
          SELECT TOP 1 @Aktualizuj_CenaZ_MMOL = CONVERT(TINYINT, ISNULL(Fir_Wartosc,0)) FROM cdn.Firma WHERE Fir_Numer = 1758
        -- Rodzaj marży: 0 = "od stu", 1 = "w stu"
        IF ( @TrN_TypDokumentu IN ( 310, 303, 307, 301, 317, 313 ) OR ( @TrN_Rodzaj = 312010 AND @Aktualizuj_CenaZ_MMOL = 1 ) )
          AND @TrN_Bufor IN ( 0 )
          begin
  -- symbol waluty systemowej
  IF ( @TrN_Waluta = '' OR @TrN_Waluta = @WalutaSys ) AND @TrN_KursL=1 AND @TrN_KursM = 1
          SET @TrN_Waluta = @WalutaSys
 --IF (@TrN_Rodzaj = 301004 AND @TrN_Bufor = 0) OR (@TrN_Rodzaj = 307000 AND @TrN_Bufor=0)
--exec CDN.AktualizujCeny 1
if @TrN_Korekta =2 or @TrN_Korekta =5
BEGIN
  if @Aktualizuj_Cena_Zak_Po_Kor = 1 and @TrN_AktualizacjaCenyZakKor = 1 and @Aktualizuj_Cena_Zak_Po_Kor_Typ = 2
  BEGIN
   if @TrN_Korekta =5
    SELECT @TrN_WalutaGraniczna = @TrN_Waluta
    FROM CDN.TwrCeny JOIN (select top 10000 TrE_TwrID,TrE_CenaWWD,TrE_JMPrzelicznikM,TrE_JMPrzelicznikL,TrE_CenaW,TrE_Stawka,TrE_Ilosc,TrE_TypNB,TrE_WartoscNetto,TrE_IloscJMKW FROM CDN.TraElem
    where TrE_TrNId = @Id  and (TrE_WartoscNettoWal != 0 or TrE_WartoscBruttoWal != 0 or TrE_Cena0WD != TrE_CenaWWD) order by tre_treid desc) as A ON TwC_TwrID = TrE_TwrID AND TwC_TwCNumer = 1   --WHERE   TrE_Ilosc >0
   UPDATE CDN.TwrCeny SET TwC_WartoscZakOld = case when @TrN_Rodzaj = 307006 then TwC_WartoscZakOld else TwC_Wartosc end,TwC_DokID=@ID,TwC_Wartosc =  CASE
       WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND TrE_TypNB = 1 AND TwC_Typ = 1 THEN round(TrE_CenaWWD  * ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ) + round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND TrE_TypNB = 1 AND TwC_Typ = 2 THEN round(( TrE_CenaWWD + ROUND( TrE_CenaWWD * TrE_Stawka / 100, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ) ) * (  TrE_JMPrzelicznikM / TrE_JMPrzelicznikL )+ round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND TrE_TypNB = 2 AND TwC_Typ = 1 THEN round((TrE_CenaWWD  - ROUND( TrE_CenaWWD * TrE_Stawka / ( 100+TrE_Stawka), case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ) ) *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL )+ round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND TrE_TypNB = 2 AND TwC_Typ = 2 THEN round(TrE_CenaWWD   *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL )+ round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
        WHEN TrE_TypNB = 1 AND TwC_Typ = 1 THEN round(TrE_CenaWWD  * ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN TrE_TypNB = 1 AND TwC_Typ = 2 THEN round(( TrE_CenaWWD + ROUND( TrE_CenaWWD * TrE_Stawka / 100, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ) ) * (  TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN TrE_TypNB = 2 AND TwC_Typ = 1 THEN round((TrE_CenaWWD  - ROUND( TrE_CenaWWD * TrE_Stawka / ( 100+TrE_Stawka), case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ) ) *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN TrE_TypNB = 2 AND TwC_Typ = 2 THEN round(TrE_CenaWWD   *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
      END,
        TwC_Waluta = @TrN_Waluta
     FROM CDN.TwrCeny
     join CDN.Towary on TwC_TwrID = Twr_TwrId
     JOIN (select top 10000 TrE_TwrID,TrE_CenaWWD,TrE_JMPrzelicznikM,TrE_JMPrzelicznikL,TrE_CenaW,TrE_Stawka,TrE_Ilosc,TrE_TypNB,TrE_WartoscNetto,TrE_IloscJMKW FROM CDN.TraElem
     where TrE_TrNId = @Id  and (TrE_WartoscNettoWal != 0 or TrE_WartoscBruttoWal != 0 or TrE_Cena0WD != TrE_CenaWWD) order by tre_treid desc) as A ON TwC_TwrID = TrE_TwrID AND TwC_TwCNumer = 1   --WHERE   TrE_Ilosc >0
   UPDATE CDN.Towary SET
     TwR_WalutaZakOld         = TwR_Waluta,
              Twr_KursLZakOld          = TwR_KursL,
              Twr_KursMZakOld          = TwR_KursM,
              TwR_KosztUslugiOld =  Twr_KosztUslugi,
     Twr_Waluta         = @TrN_Waluta,
              Twr_KursNumer      = @Trn_KursNumer,
              Twr_KursL          = @TrN_KursL,
              Twr_KursM          = @TrN_KursM,
              Twr_OpeModID    = @TrN_OpeModID,
     Twr_OpeModKod    = @TrN_OpeModKod,
     Twr_OpeModNazwisko    = @TrN_OpeModNazwisko,
              Twr_StaModId    = @TrN_StaModID,
              Twr_KosztUslugi    = ISNULL(CASE WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaT + round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
                    WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaT   - ROUND ( TrE_CenaT   * TrE_Stawka / (100 + TrE_Stawka) , 2 ) + round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaT
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaT   - ROUND ( TrE_CenaT   * TrE_Stawka / (100 + TrE_Stawka) , case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 2 THEN  Twr_KosztUslugi END,0),
              Twr_KosztUslugiWal = ISNULL(CASE WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaWWD + round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
                    WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaWWD  - ROUND ( TrE_CenaWWD * TrE_Stawka / (100 + TrE_Stawka) , 2 ) + round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaWWD
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaWWD  - ROUND ( TrE_CenaWWD * TrE_Stawka / (100 + TrE_Stawka) , case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 2 THEN  Twr_KosztUslugiWal
                    END,0)
              FROM CDN.Towary JOIN (select top 10000 TrE_TwrID,TrE_CenaT,TrE_Stawka,TrE_CenaWWD,TrE_Ilosc,TrE_WartoscNetto,TrE_IloscJMKW FROM CDN.TraElem
              where TrE_TrNId = @Id  and (TrE_WartoscNettoWal != 0 or TrE_WartoscBruttoWal != 0 or TrE_Cena0WD != TrE_CenaWWD) order by tre_treid desc) as A ON Twr_TwrId = TrE_TwrId   -- WHERE   TrE_Ilosc >0
   --log
     SELECT @fromParam = 'CDN.Towary JOIN (select top 10000 TrE_TwrID,TrE_CenaT,TrE_Stawka,TrE_CenaWWD,TrE_Ilosc,TrE_WartoscNetto,TrE_IloscJMKW FROM CDN.TraElem
     where TrE_TrNId = '+ CONVERT(VARCHAR(15), @Id)+'  and (TrE_WartoscNettoWal != 0 or TrE_WartoscBruttoWal != 0 or TrE_Cena0WD != TrE_CenaWWD) order by tre_treid desc) as A ON Twr_TwrId = TrE_TwrId
     join CDN.TwrCeny ON TwC_TwrID = TrE_TwrID AND TwC_TwCNumer = 1 '
     SELECT @whereParam = 'TwC_WartoscZakOld != TwC_Wartosc'
   exec cdn.RejestrOperacjiDodajEx @ObiektTyp = '1106', @ObiektSubTyp = '0', @ObiektID = 'twr_twrid', @ObiektNazwa = 'twr_kod',
     @OperacjaTyp = 2, @Opis = '''Aktualizacja ceny zakupu''', @From = @fromParam, @Where = @whereParam
  END
  if @Aktualizuj_Cena_Zak_Po_Kor = 1 and @Aktualizuj_Cena_Zak_Po_Kor_Typ = 1
  BEGIN
   if @TrN_Korekta =5
    SELECT @TrN_WalutaGraniczna = @TrN_Waluta
    FROM CDN.TwrCeny JOIN (select top 10000 TrE_TwrID,TrE_CenaWWD,TrE_JMPrzelicznikM,TrE_JMPrzelicznikL,TrE_CenaW,TrE_Stawka,TrE_Ilosc,TrE_TypNB,TrE_WartoscNetto,TrE_IloscJMKW FROM CDN.TraElem
    where TrE_TrNId = @Id  and (TrE_WartoscNettoWal != 0 or TrE_WartoscBruttoWal != 0 or TrE_Cena0WD != TrE_CenaWWD) order by tre_treid desc) as A ON TwC_TwrID = TrE_TwrID AND TwC_TwCNumer = 1   --WHERE   TrE_Ilosc >0
   UPDATE CDN.TwrCeny SET TwC_WartoscZakOld = TwC_Wartosc,TwC_DokID=@ID,TwC_Wartosc =  CASE
       WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND TrE_TypNB = 1 AND TwC_Typ = 1 THEN round(TrE_CenaWWD  * ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ) + round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND TrE_TypNB = 1 AND TwC_Typ = 2 THEN round(( TrE_CenaWWD + ROUND( TrE_CenaWWD * TrE_Stawka / 100, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ) ) * (  TrE_JMPrzelicznikM / TrE_JMPrzelicznikL )+ round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND TrE_TypNB = 2 AND TwC_Typ = 1 THEN round((TrE_CenaWWD  - ROUND( TrE_CenaWWD * TrE_Stawka / ( 100+TrE_Stawka), case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end  ) ) *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL )+ round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND TrE_TypNB = 2 AND TwC_Typ = 2 THEN round(TrE_CenaWWD   *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL )+ round(TrE_WartoscNetto/TrE_IloscJMKW,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
        WHEN TrE_TypNB = 1 AND TwC_Typ = 1 THEN round(TrE_CenaWWD  * ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN TrE_TypNB = 1 AND TwC_Typ = 2 THEN round(( TrE_CenaWWD + ROUND( TrE_CenaWWD * TrE_Stawka / 100, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ) ) * (  TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN TrE_TypNB = 2 AND TwC_Typ = 1 THEN round((TrE_CenaWWD  - ROUND( TrE_CenaWWD * TrE_Stawka / ( 100+TrE_Stawka), case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ) ) *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
       WHEN TrE_TypNB = 2 AND TwC_Typ = 2 THEN round(TrE_CenaWWD   *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
      END,
        TwC_Waluta = @TrN_Waluta
     FROM CDN.TwrCeny
     join CDN.Towary on TwC_TwrID = Twr_TwrId
     JOIN (select top 10000 TrE_TwrID,TrE_CenaWWD,TrE_JMPrzelicznikM,TrE_JMPrzelicznikL,TrE_CenaW,TrE_Stawka,TrE_Ilosc,TrE_TypNB,TrE_ZwrID,TrE_WartoscNetto,TrE_IloscJMKW FROM CDN.TraElem
     where TrE_TrNId = @Id  and (TrE_WartoscNettoWal != 0 or TrE_WartoscBruttoWal != 0 or TrE_Cena0WD != TrE_CenaWWD) order by tre_treid desc) as A ON TwC_TwrID = TrE_TwrID AND TwC_TwCNumer = 1
     join (select max(trs_trsid) as trsid,TrS_TwrId as TwrId from cdn.TraSElem
     left join cdn.TraElem on TrE_TrEID = TrS_TrEId
     left join cdn.TraNag on TrE_TrNId = TrN_TrNID where TrS_Typ in(1,4) and CONVERT (int, TrS_Rodzaj/1000) in (307,313,301,310,303,317) and TrN_Bufor = 0   and TrN_Korekta = 0
     group by TrS_TwrId) as B ON TwC_TwrID = TwrId
     join cdn.TraSElem on trsid = trs_trsid
     where TrE_ZwrID = trs_treid
   UPDATE CDN.Towary SET
              TwR_WalutaZakOld         = TwR_Waluta,
              Twr_KursLZakOld          = TwR_KursL,
              Twr_KursMZakOld          = TwR_KursM,
              Twr_Waluta         = @TrN_Waluta,
              Twr_KursNumer      = @Trn_KursNumer,
              Twr_KursL          = @TrN_KursL,
              Twr_KursM          = @TrN_KursM,
              Twr_OpeModID    = @TrN_OpeModID,
     Twr_OpeModKod    = @TrN_OpeModKod,
     Twr_OpeModNazwisko    = @TrN_OpeModNazwisko,
              Twr_StaModId    = @TrN_StaModID/*,
              Twr_KosztUslugi    = ISNULL(CASE WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaT + round(TrE_WartoscNetto/TrE_IloscJMKW,2)
                    WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaT   - ROUND ( TrE_CenaT   * TrE_Stawka / (100 + TrE_Stawka) , 2 ) + round(TrE_WartoscNetto/TrE_IloscJMKW,2)
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaT
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaT   - ROUND ( TrE_CenaT   * TrE_Stawka / (100 + TrE_Stawka) , 2 )
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 2 THEN  Twr_KosztUslugi END,0),
              Twr_KosztUslugiWal = ISNULL(CASE WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaT + round(TrE_WartoscNetto/TrE_IloscJMKW,2)
                    WHEN @TrN_Korekta =5 And @TrN_TypDokumentu =301 AND Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaT   - ROUND ( TrE_CenaT   * TrE_Stawka / (100 + TrE_Stawka) , 2 ) + round(TrE_WartoscNetto/TrE_IloscJMKW,2)
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaWWD
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaWWD  - ROUND ( TrE_CenaWWD * TrE_Stawka / (100 + TrE_Stawka) , 2 )
                    WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 2 THEN  Twr_KosztUslugiWal
                    END,0)
                                        */
              FROM CDN.Towary JOIN (select top 10000 TrE_TwrID,TrE_CenaT,TrE_Stawka,TrE_CenaWWD,TrE_Ilosc,TrE_ZwrID,TrE_WartoscNetto,TrE_IloscJMKW FROM CDN.TraElem
               where TrE_TrNId = @Id  and (TrE_WartoscNettoWal != 0 or TrE_WartoscBruttoWal != 0 or TrE_Cena0WD != TrE_CenaWWD) order by tre_treid desc) as A ON Twr_TwrId = TrE_TwrId
              join (select max(trs_trsid) as trsid,TrS_TwrId as TwrId from cdn.TraSElem
  left join cdn.TraElem on TrE_TrEID = TrS_TrEId
  left join cdn.TraNag on TrE_TrNId = TrN_TrNID where TrS_Typ in(1,4) and CONVERT (int, TrS_Rodzaj/1000) in (307,313,301,310,303,317) and TrN_Bufor = 0   and TrN_Korekta = 0
  group by TrS_TwrId) as B ON Twr_TwrID = TwrId
  join cdn.TraSElem on trsid = trs_trsid
  where TrE_ZwrID = trs_treid and Twr_Typ = 1
  --log
  SELECT @fromParam = 'CDN.Towary JOIN (select top 10000 TrE_TwrID,TrE_CenaT,TrE_Stawka,TrE_CenaWWD,TrE_Ilosc,TrE_ZwrID,TrE_WartoscNetto,TrE_IloscJMKW FROM CDN.TraElem
       where TrE_TrNId = '+ CONVERT(VARCHAR(15), @Id)+'   and (TrE_WartoscNettoWal != 0 or TrE_WartoscBruttoWal != 0 or TrE_Cena0WD != TrE_CenaWWD) order by tre_treid desc) as A ON Twr_TwrId = TrE_TwrId
       join (select max(trs_trsid) as trsid,TrS_TwrId as TwrId from cdn.TraSElem
       left join cdn.TraElem on TrE_TrEID = TrS_TrEId
       left join cdn.TraNag on TrE_TrNId = TrN_TrNID where TrS_Typ in(1,4) and CONVERT (int, TrS_Rodzaj/1000) in (307,313,301,310,303,317) and TrN_Bufor = 0   and TrN_Korekta = 0
       group by TrS_TwrId) as B ON Twr_TwrID = TwrId
       join CDN.TwrCeny ON TwC_TwrID = TrE_TwrID AND TwC_TwCNumer = 1
       join cdn.TraSElem on trsid = trs_trsid '
  SELECT @whereParam = 'TrE_ZwrID = trs_treid and Twr_Typ = 1 and TwC_WartoscZakOld != TwC_Wartosc'
  exec cdn.RejestrOperacjiDodajEx @ObiektTyp = '1106', @ObiektSubTyp = '0', @ObiektID = 'twr_twrid', @ObiektNazwa = 'twr_kod',
        @OperacjaTyp = 2, @Opis = '''Aktualizacja ceny zakupu''', @From = @fromParam, @Where = @whereParam
  END
END
ELSE
BEGIN
    UPDATE CDN.TwrCeny SET TwC_WartoscZakOld = TwC_Wartosc,TwC_DokID=@ID,TwC_Wartosc =  CASE WHEN TrE_TypNB = 1 AND TwC_Typ = 1 THEN round(TrE_CenaWWD  * ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
                 WHEN TrE_TypNB = 1 AND TwC_Typ = 2 THEN round(( TrE_CenaWWD + ROUND( TrE_CenaWWD * TrE_Stawka / 100, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ) ) * (  TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
                 WHEN TrE_TypNB = 2 AND TwC_Typ = 1 THEN round((TrE_CenaWWD  - ROUND( TrE_CenaWWD * TrE_Stawka / ( 100+TrE_Stawka), case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end ) ) *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
                 WHEN TrE_TypNB = 2 AND TwC_Typ = 2 THEN round(TrE_CenaWWD   *  ( TrE_JMPrzelicznikM / TrE_JMPrzelicznikL ),case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
                END,
               TwC_Waluta = @TrN_Waluta
            --FROM CDN.TwrCeny JOIN CDN.TraElem ON TwC_TwrID = TrE_TwrID AND TwC_TwCNumer = 1 WHERE TrE_TrNId = @Id AND TrE_Ilosc >0
            FROM CDN.TwrCeny
   join CDN.Towary on TwC_TwrID = Twr_TwrId
   JOIN (select top 10000 TrE_TwrID,TrE_CenaWWD,TrE_JMPrzelicznikM,TrE_JMPrzelicznikL,TrE_CenaW,TrE_Stawka,TrE_Ilosc,TrE_TypNB FROM CDN.TraElem
            where TrE_TrNId = @Id order by tre_treid desc) as A ON TwC_TwrID = TrE_TwrID AND TwC_TwCNumer = 1   WHERE   TrE_Ilosc >0
    UPDATE CDN.Towary SET
              TwR_WalutaZakOld         = TwR_Waluta,
              Twr_KursLZakOld          = TwR_KursL,
              Twr_KursMZakOld          = TwR_KursM,
              TwR_KosztUslugiOld =  Twr_KosztUslugi,
              Twr_Waluta         = @TrN_Waluta,
              Twr_KursNumer      = @Trn_KursNumer,
              Twr_KursL          = @TrN_KursL,
              Twr_KursM          = @TrN_KursM,
              Twr_OpeModID    = @TrN_OpeModID,
     Twr_OpeModKod    = @TrN_OpeModKod,
     Twr_OpeModNazwisko    = @TrN_OpeModNazwisko,
              Twr_StaModId    = @TrN_StaModID,
                                       Twr_KosztUslugi    = ISNULL(CASE WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaT
                                                                        WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaT   - ROUND ( TrE_CenaT   * TrE_Stawka / (100 + TrE_Stawka) , case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
                                                                        WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 2 THEN  Twr_KosztUslugi END,0),
                                       Twr_KosztUslugiWal = ISNULL(CASE WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 1 THEN TrE_CenaWWD
                                                                        WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 1 AND @TrN_TypNB = 2 THEN TrE_CenaWWD  - ROUND ( TrE_CenaWWD * TrE_Stawka / (100 + TrE_Stawka) , case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end )
                                                                        WHEN Twr_Typ = 0 AND Twr_KosztUslugiTyp = 2 THEN  Twr_KosztUslugiWal
                                                                        END,0)
                                       --FROM CDN.Towary JOIN CDN.TraElem ON Twr_TwrId = TrE_TwrId  AND TrE_TrNId = @Id WHERE TrE_Ilosc >0
                                       FROM CDN.Towary JOIN (select top 10000 TrE_TwrID,TrE_CenaT,TrE_Stawka,TrE_CenaWWD,TrE_Ilosc FROM CDN.TraElem
                                       where TrE_TrNId = @Id order by tre_treid desc) as A ON Twr_TwrId = TrE_TwrId    WHERE   TrE_Ilosc >0
 --log
 SELECT @fromParam = 'CDN.Towary JOIN (select top 10000 TrE_TwrID,TrE_CenaT,TrE_Stawka,TrE_CenaWWD,TrE_Ilosc FROM CDN.TraElem
       where TrE_TrNId = '+ CONVERT(VARCHAR(15), @Id)+'  order by tre_treid desc) as A ON Twr_TwrId = TrE_TwrId join CDN.TwrCeny ON TwC_TwrID = TrE_TwrID AND TwC_TwCNumer = 1   '
 SELECT @whereParam = 'TrE_Ilosc >0 and TwC_WartoscZakOld != TwC_Wartosc'
 exec cdn.RejestrOperacjiDodajEx @ObiektTyp = '1106', @ObiektSubTyp = '0', @ObiektID = 'twr_twrid', @ObiektNazwa = 'twr_kod',
        @OperacjaTyp = 2, @Opis = '''Aktualizacja ceny zakupu''', @From = @fromParam, @Where = @whereParam
-- END
END
if @TrN_Korekta =5
 begin
  if @TrN_WalutaGraniczna = ''
   SELECT @TrN_Waluta=TrN_Waluta from cdn.tranag where TrN_TrNId = @TrN_ZwrId
    end
BEGIN
  UPDATE CDN.TwrCeny SET TwC_Marza =
  CASE
    WHEN  TwC_Typ =2
    THEN
      CASE WHEN
                (((TwC_Wartosc - ROUND(TwC_Wartosc * Twr_Stawka / ( 100 + Twr_Stawka), 2 )) /
                 (SELECT C.TwC_Wartosc * Twr_KursL/Twr_KursM FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1)  )-1) * 100  > 99999.99 THEN 99999.99
           WHEN
                (((TwC_Wartosc - ROUND(TwC_Wartosc * Twr_Stawka / ( 100 + Twr_Stawka), 2 )) /
                 (SELECT C.TwC_Wartosc * Twr_KursL/Twr_KursM FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1)  )-1) * 100  < -99999.99 THEN -99999.99
           ELSE
                (((TwC_Wartosc - ROUND(TwC_Wartosc * Twr_Stawka / ( 100 + Twr_Stawka), 2 )) /
                (SELECT C.TwC_Wartosc * Twr_KursL/Twr_KursM FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1)  )-1) * 100
       END
  ELSE
      CASE WHEN
                ((TwC_Wartosc / (SELECT C.TwC_Wartosc* Twr_KursL/Twr_KursM FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1))-1) * 100 > 99999.99 THEN 99999.99
           WHEN
                ((TwC_Wartosc / (SELECT C.TwC_Wartosc* Twr_KursL/Twr_KursM FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1))-1) * 100 < -99999.99 THEN -99999.99
           ELSE
                ((TwC_Wartosc / (SELECT C.TwC_Wartosc* Twr_KursL/Twr_KursM FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1))-1) * 100
      END
  END
FROM CDN.Towary JOIN CDN.TraElem ON TwR_TwrID = TrE_TwrID JOIN CDN.TwrCeny ON Twr_TwrId = TwC_TwrId
WHERE TwC_TwcNumer <> 1 AND TwC_Aktualizacja = 0 AND TrE_TrNid = @Id  AND 0<>(SELECT B.TwC_Wartosc FROM CDN.TwrCeny B WHERE B.TwC_TwrId = TrE_TwrId AND B.TwC_TwCNumer = 1)
AND (TwC_Waluta = @WalutaSys)
 UPDATE CDN.TwrCeny SET TwC_Marza =
  CASE
    WHEN  TwC_Typ =2
    THEN
      CASE WHEN
                (((TwC_Wartosc - ROUND(TwC_Wartosc * Twr_Stawka / ( 100 + Twr_Stawka), 2 )) /
                 (SELECT C.TwC_Wartosc FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1)  )-1) * 100  > 99999.99 THEN 99999.99
           WHEN
                (((TwC_Wartosc - ROUND(TwC_Wartosc * Twr_Stawka / ( 100 + Twr_Stawka), 2 )) /
                 (SELECT C.TwC_Wartosc FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1)  )-1) * 100  < -99999.99 THEN -99999.99
           ELSE
                (((TwC_Wartosc - ROUND(TwC_Wartosc * Twr_Stawka / ( 100 + Twr_Stawka), 2 )) /
                (SELECT C.TwC_Wartosc FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1)  )-1) * 100
       END
  ELSE
      CASE WHEN
                ((TwC_Wartosc / (SELECT C.TwC_Wartosc FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1))-1) * 100 > 99999.99 THEN 99999.99
           WHEN
                ((TwC_Wartosc / (SELECT C.TwC_Wartosc FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1))-1) * 100 < -99999.99 THEN -99999.99
           ELSE
                ((TwC_Wartosc / (SELECT C.TwC_Wartosc FROM CDN.TwrCeny C WHERE C.TwC_TwrId = Twr_TwrId AND C.TwC_TwCNumer = 1))-1) * 100
      END
  END
FROM CDN.Towary JOIN CDN.TraElem ON TwR_TwrID = TrE_TwrID JOIN CDN.TwrCeny ON Twr_TwrId = TwC_TwrId
WHERE TwC_TwcNumer <> 1 AND TwC_Aktualizacja = 0 AND TrE_TrNid = @Id  AND 0<>(SELECT B.TwC_Wartosc FROM CDN.TwrCeny B WHERE B.TwC_TwrId = TrE_TwrId AND B.TwC_TwCNumer = 1)
AND (TwC_Waluta = @TrN_Waluta)
UPDATE CDN.TwrCeny SET TwC_MarzaWStu =
 CASE
      WHEN TwC_Marza = -100 THEN 100
      WHEN TwC_Wartosc = 0 THEN -100
      ELSE 100 * TwC_Marza / ( 100 + TwC_Marza ) END
FROM CDN.TraElem JOIN CDN.TwrCeny ON TwC_TwrID = TrE_TwrID WHERE TwC_TwcNumer <> 1 AND TwC_Aktualizacja = 0 AND TrE_TrNid = @Id
AND (TwC_Waluta = @WalutaSys or TwC_Waluta = @TrN_Waluta)
END
END
END
