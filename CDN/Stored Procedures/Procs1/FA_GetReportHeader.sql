CREATE PROCEDURE [CDN].[FA_GetReportHeader]
 @Identyfikator int = 0,
 @Wdr_Typ  int = 0,
 @Wdr_Rodzaj  int = 0,
 @Wdr_Waluta  int = 0
AS
BEGIN
 DECLARE
  @Fir_Tytul varchar(128),
  @Fir_Nazwa nvarchar(2052),
  --@Fir_Ulica varchar(64),
  --@Fir_NrBud varchar(64),
  --@Fir_NrLok varchar(64),
  --@Fir_Miasto varchar(64),
  --@Fir_Poczta varchar(64),
  --@Fir_Nip varchar(32),
  --@Fir_Regon varchar(32),
  --@Fir_NrGios varchar(32),
  @Fir_Mail varchar(256),
  @Fir_Opis varchar(512),
  --@Fir_FirJ varchar(16),
  @FirJ_Tytul  varchar(128),
  @FirJ_Nazwa  nvarchar(2052),
  --@FirJ_Ulica  varchar(64),
  --@FirJ_NrBud  varchar(64),
  --@FirJ_NrLok  varchar(64),
  --@FirJ_Miasto varchar(64),
  --@FirJ_Poczta varchar(64),
  --@FirJ_Nip  varchar(4),
  @FirJ_Mail  varchar(256),
  @Fir_PCID int,
  @Fir_PCJID int,
  @Met_Kasowa varchar(13),
  @Czy_Oswiadczenie int,
  @Ukryj_Oswiadczenie int,
  @Pod_Tytul  varchar(64),
  @Pod_Nazwa  nvarchar(598),
  @Pod_KorNazwa nvarchar(512),
  @Odb_Tytul  varchar(64),
  @Odb_Nazwa  nvarchar(512),
  @Odb_KorNazwa nvarchar(512),
  @Dok_TypDokumentu int,
  @Dok_Rodzaj    int,
  @Dok_Nazwa    varchar(64),
  @Dok_Numer    varchar(64),
  @Dok_DataWystawienia varchar(64),
  @Dok_DataOperacji  varchar(64),
  @Dok_Duplikat   varchar(64),
  @Dok_DataDuplikatu  varchar(64),
  @Dok_Opis    nvarchar(1024),
  @Dok_Waluta    varchar(8),
  @Dok_Rachunek   nvarchar(512),
  @Dok_Razem decimal(16,2),
  @Dok_Kurs    varchar(128),
  @Dok_OpisGotowka  varchar(64),
  @Dok_PowiazaniezPA  int,
  @Dok_TypNettoBrutto  varchar(32),
  @Dok_Kwota    decimal(16,2),
  @Dok_KwotaWal    decimal(16,2),
  @Dok_RazemDoZaplaty  varchar(128),
  @Dok_SlownieDoZaplaty varchar(1024),
  @Dok_Zaplacono   varchar(128),
  @Dok_PozostajeDoZaplaty varchar(128),
  @Dok_Wystawil   varchar(128),
  @Dok_Odebral   varchar(128),
  @Dok_Stopka    varchar(64),
  @Dok_StopkaKnf varchar(254),
  @Dok_Przyczyna   varchar(2048),
  @Dok_TypKor    int,
  @Dok_KorPrzed   varchar(32),
  @Dok_KorPo    varchar(32),
  @Dok_PaFaCzesciowe  int,
  @Dok_FVMarza int,
  @Dok_FZAL_Plat varchar(256),
  @Dok_Trojdtronna varchar(128),
  @Dok_Finalny int,
  @Dok_JPK nvarchar(3000),
  @Pod_Status int,
  @Pow_Id     int,
  @Pow_Numer    varchar(1024),
  @Pow_DataWystawienia varchar(64),
  @Pow_DataOperacji  varchar(64),
  @Pow_Kurs    varchar(128),
  @VAT    varchar(8),
  @VAT_KwotaNetto  decimal(16,2),
  @VAT_KwotaVat  decimal(16,2),
  @VAT_KwotaBrutto decimal(16,2),
  @VAT_NagNetto  varchar(32),
  @VAT_NagVAT   varchar(32),
  @VAT_NagBrutto  varchar(32),
  @Fpl_ID  int,
  @Tre_Tytul varchar(32),
  @Konf_Akcyza int
 SET @Konf_Akcyza = (SELECT Fir_Wartosc FROM CDN.FIRMA WHERE Fir_Numer = 2151)
 SET @Dok_StopkaKnf = (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=1992)
 IF @Identyfikator < 0 --jesli wysylane od razu id pieczatki (dla podgladu z formularza pieczatki)
 BEGIN
 SET @Fir_PCID = -@Identyfikator
 END
 ELSE
 BEGIN
 SELECT @Fir_PCID = TrN_PCID, @Fir_PCJID = TrN_PCJSID from CDN.TraNag Where TrN_TrNID = @Identyfikator
 END
 SELECT @Fir_Tytul = 'Sprzedawca:',
  @FirJ_Nazwa = Firm_String,
  @FirJ_Mail = Firm_Email + CASE WHEN Firm_URL <> '' THEN CHAR(13) + Firm_URL ELSE '' END,
  @Fir_Opis = Firm_Opis,
  @FirJ_Tytul = (CASE WHEN Jorg_String <> '' THEN char(13) + 'Jednostka organizacyjna:' ELSE '' END),
  @Fir_Nazwa = Jorg_String,
  @Fir_Mail = Jorg_Email + CASE WHEN Jorg_URL <> '' THEN CHAR(13) + Jorg_URL ELSE '' END
 from CDN.fnPieczatka(@Fir_PCID,@Fir_PCJID, @Wdr_Waluta)
 /*
 --DANE PIECZATKI
 SET @Fir_Nip = (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=1167)
 SELECT @Fir_FirJ = Fir_Wartosc From CDN.Firma  Where Fir_Numer=2246
 IF @Fir_FirJ = 1
 BEGIN
  SET @FirJ_NrBud  = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2260)
  SET @FirJ_NrLok  = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2261)
  SET @FirJ_NrBud  = (SELECT ' ' + CASE WHEN @Fir_NrBud <> '' AND @FirJ_NrLok <> '' THEN @FirJ_NrBud + '/' + @FirJ_NrLok WHEN @FirJ_NrBud <> '' AND @FirJ_NrLok = '' THEN @FirJ_NrBud ELSE @FirJ_NrLok END)
  SET @FirJ_Miasto = (SELECT CASE WHEN Fir_Wartosc <> '' THEN ' ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2262)
  SET @FirJ_Poczta = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2264)
  SET @FirJ_Ulica  = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc WHEN Fir_Wartosc='' AND @FirJ_Miasto <>'' THEN @FirJ_Miasto ELSE @FirJ_Poczta END From CDN.Firma  Where Fir_Numer=2259)
  SET @FirJ_Poczta = CASE WHEN @FirJ_Poczta <> '' THEN ' ' + @FirJ_Poczta ELSE @FirJ_Miasto END
  SET @FirJ_Miasto = CASE WHEN @FirJ_Miasto = @FirJ_Poczta AND @FirJ_Miasto <> '' THEN '' WHEN @FirJ_Miasto <> @FirJ_Poczta AND @FirJ_Miasto <> '' AND @FirJ_Miasto <> @FirJ_Ulica AND @FirJ_Poczta <> @FirJ_Ulica THEN ', ' + @FirJ_Miasto ELSE '' END
  SET @FirJ_Nip  = (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=2250)
  SET @FirJ_Tytul  = char(13) + 'Jednostka organizacyjna:'
  SET @FirJ_Nazwa  =
  /* NAZWA */
  (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=2247) +
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2248) +
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2249) +
  /* ADRES */
  CHAR(13) + @FirJ_Ulica + @FirJ_NrBud + @FirJ_Miasto +
  /* POCZTA */
  (SELECT CHAR(13) + Fir_Wartosc From CDN.Firma  Where Fir_Numer=2263) +
  @FirJ_Poczta +
  /* KRAJ */
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2253) +
  /* NIP */
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'NIP: ' + @FirJ_Nip + ' ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2251) +
  /* REGON */
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'REGON: ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2252) +
  /* NR GIOS */
  (SELECT CASE WHEN Fir_Wartosc = 1 THEN (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'Numer rejestrowy: ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1881) ELSE '' END From CDN.Firma  Where Fir_Numer=1879) +
  /* TELEFON */
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'tel: ' + Fir_Wartosc ELSE '' END From CDN.Firma Where Fir_Numer=2265)
  /* MAIL/WWW */
  SET @FirJ_Mail = (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=2266) + (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=3088)
  SET @Fir_Nip = ''
  SET @Fir_Regon = ''
 END
 ELSE
 BEGIN
  SET @Fir_Nip = (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'NIP: ' + @Fir_Nip + ' ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1101)
  SET @Fir_Regon = (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'REGON: ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1118)
  SET @Fir_NrGios = (SELECT CASE WHEN Fir_Wartosc = 1 THEN (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'Numer rejestrowy: ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1881) ELSE '' END From CDN.Firma  Where Fir_Numer=1879)
  END
  --DANE PIECZĄTKI--
  SET @Fir_NrBud  = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1150)
  SET @Fir_NrLok  = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1151)
  SET @Fir_NrBud  = (SELECT ' ' + CASE WHEN @Fir_NrBud <> '' AND @Fir_NrLok <> '' THEN @Fir_NrBud + '/' + @Fir_NrLok WHEN @Fir_NrBud <> '' AND @Fir_NrLok = '' THEN @Fir_NrBud ELSE @Fir_NrLok END)
  SET @Fir_Miasto = (SELECT CASE WHEN Fir_Wartosc <> '' THEN ' ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1152)
  SET @Fir_Poczta = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1154)
  SET @Fir_Ulica  = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc WHEN Fir_Wartosc='' AND @Fir_Miasto <>'' THEN @Fir_Miasto ELSE @Fir_Poczta END From CDN.Firma  Where Fir_Numer=1149)
  SET @Fir_Poczta = CASE WHEN @Fir_Poczta <> '' THEN ' ' + @Fir_Poczta ELSE @Fir_Miasto END
  SET @Fir_Miasto = CASE WHEN @Fir_Miasto = @Fir_Poczta AND @Fir_Miasto <> '' THEN '' WHEN @Fir_Miasto <> @Fir_Poczta AND @Fir_Miasto <> '' AND @Fir_Miasto <> @Fir_Ulica AND @Fir_Poczta <> @Fir_Ulica THEN ', ' + @Fir_Miasto ELSE '' END
  SET @Fir_Tytul  = 'Sprzedawca:'
  SET @Fir_Nazwa  =
  /* NAZWA */
  (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=1156) +
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1157) +
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2166) +
  /* ADRES */
  CHAR(13) + @Fir_Ulica + @Fir_NrBud + @Fir_Miasto +
  /* POCZTA */
  (SELECT CHAR(13) + Fir_Wartosc From CDN.Firma  Where Fir_Numer=1153) +
  @Fir_Poczta +
  /* KRAJ */
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1145) +
  /* NIP */
  @Fir_Nip +
  /* REGON */
  @Fir_Regon +
  /* Nr GIOS */
  ISNULL(@Fir_NrGios,'') +
  /* TELEFON */
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'tel: ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1155)
  /* MAIL/WWW */
  SET @Fir_Mail = (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=2221) + (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma Where Fir_Numer=3087)
  SELECT @Fir_Opis = Fir_Wartosc From CDN.Firma  Where Fir_Numer=1158
  */
  --METODA KASOWA
  SELECT @Met_Kasowa =
  CASE WHEN Fir_Wartosc = 1 THEN 'Metoda kasowa' ELSE '' END
  FROM CDN.Firma WHERE Fir_Numer = 1538
  --DANE Z BAZY
  SELECT @Czy_Oswiadczenie =  isNULL(CAST((SELECT MAX(S.AKCYZA) FROM
  (SELECT CASE WHEN SUM(R.ILOSC) < 200 THEN 0 ELSE 1 END as [AKCYZA]
  FROM(SELECT TRE.TrE_KodCN AS [CN],'kg' AS [JM], CASE WHEN TRE.TrE_Jm like '%kg%' THEN SUM(TRE.TrE_IloscJM) ELSE SUM(TRE.TrE_Ilosc * (1000/(TRE.Tre_AkcyzaJMPomPrzelicznikL/TRE.Tre_AkcyzaJMPomPrzelicznikM))) END AS [ILOSC]
  FROM CDN.TraElem TRE WHERE TRE.Tre_KodCN in (27010000,27020000,27040000) and TRE.tre_trnid = @Identyfikator
  GROUP BY TRE.TrE_KodCN, TRE.TrE_Jm) as R
  GROUP BY R.JM,R.CN) as S) as int),0)
  IF @Identyfikator > 0
  BEGIN
   SELECT
    --DANE PODMIOTU
    @Ukryj_Oswiadczenie = CASE WHEN TrN_UmowaWegiel = 1 OR TrN_ZwolnionyZAkcyzy = 0 OR @Czy_Oswiadczenie = 0 OR isNULL(TrN_FVMarza,0) = 1 OR TrN_TypDokumentu <> 302 OR @Konf_Akcyza = 0  THEN 1 ELSE '' END,
 @Pod_Status = TrN_Export,
    @Pod_Tytul = 'Nabywca:',
    @Pod_Nazwa =
    /* NAZWA */
    CASE WHEN TrN_PodNazwa1 <> '' THEN TrN_PodNazwa1 ELSE '' END  +
    CASE WHEN TrN_PodNazwa2 <> '' THEN CHAR(13) + TrN_PodNazwa2 ELSE '' END  +
    CASE WHEN TrN_PodNazwa3 <> '' THEN CHAR(13) + TrN_PodNazwa3 ELSE '' END  +
    /* ADRES */
    CHAR(13) + CASE WHEN TrN_PodUlica <> '' THEN TrN_PodUlica WHEN TrN_PodUlica='' AND TrN_PodMiasto <>'' THEN TrN_PodMiasto ELSE TrN_PodPoczta END +
    ' ' + CASE WHEN TrN_PodNrDomu <> '' AND TrN_PodNrLokalu <> '' THEN TrN_PodNrDomu + '/' + TrN_PodNrLokalu WHEN TrN_PodNrDomu <> '' AND TrN_PodNrLokalu = '' THEN TrN_PodNrDomu ELSE TrN_PodNrLokalu END +
    CASE WHEN TrN_PodPoczta <> TrN_PodUlica  AND TrN_PodMiasto <> TrN_PodUlica AND Trn_PodMiasto <> Trn_PodPoczta AND TrN_PodPoczta <> '' AND TrN_PodMiasto <> '' AND TrN_PodUlica <> '' THEN ', ' + TrN_PodMiasto ELSE '' END +
    /* POCZTA */
    CHAR(13) + TrN_PodKodPocztowy +
    CASE WHEN TrN_PodPoczta <> '' THEN ' ' + TrN_PodPoczta ELSE  ' ' + TrN_PodMiasto END +
    /* KRAJ */
    CASE WHEN TrN_PodKraj <> '' THEN CHAR(13) + TrN_PodKraj ELSE '' END +
    /* NIP */
    CASE WHEN TrN_PodNipE <> '' THEN CHAR(13) + 'NIP: ' + CASE WHEN TrN_PodNipKraj <> '' THEN TrN_PodNipKraj + ' ' + TrN_PodNipE ELSE TrN_PodNipE END ELSE '' END +
 /* PESEL */
 CASE WHEN @Ukryj_Oswiadczenie <> 1 AND TrN_Finalny = 1 AND Trn_Korekta = 0 THEN CHAR(13) + 'PESEL: ' + TrN_Pesel + CHAR(13) +
 /* DOK TOŻSAMOŚCI */
 'DOK. TOŻSAMOŚCI: ' + TrN_DokumentTozsamosci ELSE '' END,
    --DANE ODBIORCY
    @Odb_Tytul = 'Odbiorca:',
    @Odb_Nazwa =
    /* NAZWA */
    CASE WHEN TrN_OdbNazwa1 <> '' THEN TrN_OdbNazwa1 ELSE '' END  +
    CASE WHEN TrN_OdbNazwa2 <> '' THEN CHAR(13) + TrN_OdbNazwa2 ELSE '' END  +
    CASE WHEN TrN_OdbNazwa3 <> '' THEN CHAR(13) + TrN_OdbNazwa3 ELSE '' END  +
    /* ADRES */
    CHAR(13) + CASE WHEN TrN_OdbUlica <> '' THEN TrN_OdbUlica WHEN TrN_OdbUlica='' AND TrN_OdbMiasto <>'' THEN TrN_OdbMiasto ELSE TrN_OdbPoczta END +
    ' ' + CASE WHEN TrN_OdbNrDomu <> '' AND TrN_OdbNrLokalu <> '' THEN TrN_OdbNrDomu + '/' + TrN_OdbNrLokalu WHEN TrN_OdbNrDomu <> '' AND TrN_OdbNrLokalu = '' THEN TrN_OdbNrDomu ELSE TrN_OdbNrLokalu END +
    CASE WHEN TrN_OdbPoczta <> TrN_OdbUlica  AND TrN_OdbMiasto <> TrN_OdbUlica AND Trn_OdbMiasto <> Trn_OdbPoczta AND TrN_OdbPoczta <> '' AND TrN_OdbMiasto <> '' AND TrN_OdbUlica <> '' THEN ', ' + TrN_OdbMiasto ELSE '' END +
    /* POCZTA */
    CHAR(13) + TrN_OdbKodPocztowy +
    CASE WHEN TrN_OdbPoczta <> '' THEN ' ' + TrN_OdbPoczta ELSE ' ' + TrN_OdbMiasto END +
    /* KRAJ */
    CASE WHEN TrN_OdbKraj <> '' THEN CHAR(13) + TrN_OdbKraj ELSE '' END +
    /* NIP */
    CASE WHEN TrN_OdbNipE <> '' THEN CHAR(13) + 'NIP: ' + CASE WHEN TrN_OdbNipKraj <> '' THEN TrN_OdbNipKraj + ' ' + TrN_OdbNipE ELSE TrN_OdbNipE END ELSE '' END,
    --DANE DOKUMENTU
    @Dok_Finalny = TrN_Finalny,
 @Dok_TypKor = Trn_Korekta,
    @Dok_Waluta = CASE WHEN TrN_Waluta <> '' THEN TrN_Waluta ELSE 'PLN' END,
    @Dok_Typdokumentu = TrN_TypDokumentu,
 @Dok_Rodzaj    = Trn_Rodzaj,
    @Dok_Numer    = 'Numer dokumentu: ' + CASE WHEN TrN_Rodzaj=302100 AND TrN_NumerPelnyPrw <> '' THEN TrN_NumerPelnyPrw ELSE TrN_NumerPelny END,
    @Dok_DataWystawienia = 'Data wystawienia: ' + CAST(CONVERT(date,TrN_DataWys,120) as varchar),
    @Dok_DataOperacji  = CASE WHEN TrN_Rodzaj IN (302200,302202) THEN '' ELSE 'Data dostawy/wykonania usługi: ' + CASE WHEN (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 1999) = 2 AND Trn_Korekta = 0 THEN '     ' + CAST(RIGHT(CONVERT(VARCHAR(10), TrN_DataOpe, 105), 7) as varchar) ELSE CAST(CONVERT(date,TrN_DataOpe,120) as varchar) END END,
    @Pow_Id = Trn_ZwrId,
    @Dok_Opis    = CASE WHEN Trn_Opis <> '' THEN 'Opis: ' + TrN_Opis ELSE '' END,
    @Dok_Kurs    = CASE WHEN TrN_Waluta <> '' THEN 'Kurs przeliczenia: ' + CAST(Trn_KursM as varchar) + ' ' + @Dok_Waluta + ' = ' + CAST(TrN_KursL as varchar) + ' PLN' ELSE '' END,
    @Dok_TypNettoBrutto = CASE TrN_FVMarza WHEN 1 THEN CASE TrN_Waluta WHEN '' THEN '' ELSE ' [' + TrN_Waluta + ']' END ELSE CASE TrN_TypNB WHEN 1 THEN ' netto' ELSE ' brutto' END + CASE TrN_Waluta WHEN '' THEN '' ELSE ' ['+TrN_Waluta+']' END END,
    @Dok_Razem = Case @Dok_Waluta WHEN '' THEN TrN_RazemBrutto ELSE Trn_RazemBruttoWal END,
    @Dok_wystawil   = CASE TrN_Bufor WHEN 1 THEN TrN_OpeModNazwisko
       ELSE TrN_OpeZatwNazwisko END,
    @Dok_Odebral   = TrN_Odebral ,
    @Dok_Stopka    = CASE TrN_Bufor WHEN 1 THEN '(B) ' WHEN 0 THEN '' ELSE '(A) ' END + 'Wydrukowano przy pomocy programu Comarch ERP Optima',
 @Dok_JPK  = CASE WHEN EXISTS(SELECT TOP 1 KV7_Kod FROM CDN.DokKodyJPKV7 JOIN CDN.KodyJPKV7 ON DKV7_KV7ID = KV7_KV7ID WHERE DKV7_ParentID = @Identyfikator AND DKV7_ParentTyp = 1) THEN 'Kody JPK_V7 potrzebne do wprowadzania dokumentu do rejestru VAT sprzedaży: ' + STUFF(
 (
 SELECT   ', ' + KV7_Kod
 FROM CDN.DokKodyJPKV7 JOIN CDN.KodyJPKV7 ON DKV7_KV7ID = KV7_KV7ID WHERE DKV7_ParentID = @Identyfikator AND DKV7_ParentTyp = 1
 FOR XML PATH('')
 ) ,1,2,'' ) ELSE '' END,
    @Dok_FVMarza = ISNULL(Trn_FVMarza,0),
    @Dok_Przyczyna =CASE TrN_FVMarzaRodzaj WHEN 1 THEN 'Procedura marży dla biur podróży' +char(10)
 WHEN 2 THEN  'Procedura marży - towary używane' + char(10)
 WHEN 3 THEN  'Procedura marży - dzieła sztuki' + char(10)
 WHEN 4 THEN  'Procedura marży - przedmioty kolekcjonerskie i antyki' + char(10)
 ELSE '' END + CASE WHEN TrN_Korekta =0 THEN '' ELSE 'Przyczyna korekty: ' + TrN_KorektaZTytulu END,
    @Fpl_ID = TrN_FPlId,
    @Dok_PaFaCzesciowe = TrN_PAFACzesciowe,
    @Dok_Nazwa   = CASE
    WHEN TrN_Rodzaj IN (302000,302004,302006,302008, 302009,302090,302100,302200) THEN CASE @Wdr_Rodzaj WHEN 2 THEN (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 2169 /*Tytuł FA pozaunijnej*/) ELSE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 2167 /*Tytuł FA / FA UE*/)  END
    WHEN TrN_Rodzaj IN (302001,302002,302003,302005,302007,302010,302091,302092,302101,302102,302103,302011,302012,302202) THEN CASE @Wdr_Rodzaj WHEN 2 THEN (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 2169 /*Tytuł FA pozaunijnej*/) ELSE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 2167 /*Tytuł FA / FA UE*/) END + ' KOREKTA'
 WHEN TrN_Rodzaj IN (320000,320008,320009,320200) THEN 'Faktura Pro Forma'
    ELSE '' END
    FROM CDN.Tranag
    WHERE TrN_TrNID = @Identyfikator
    SET @Dok_DataDuplikatu = '';
    SET @Dok_PowiazaniezPA = isnull ( (Select TOP 1 TrN_TypDokumentu from CDN.TraNagRelacje JOIN CDN.TraNag ON Trr_FaId = TrN_TrNId WHERE TrR_TrNID= @Identyfikator AND TrR_TrNTyp = 302 AND TrN_TypDokumentu = 305),0 )
    DECLARE @PodNazwa varchar(598)
 SET @PodNazwa = @Pod_Nazwa
 IF @Ukryj_Oswiadczenie <> 1 AND @Dok_Finalny = 1 AND @Dok_TypKor = 0
  SET @PodNazwa = LEFT(@Pod_Nazwa,CHARINDEX ('PESEL: ',@Pod_Nazwa)-2)
 IF  @PodNazwa = @Odb_Nazwa
   BEGIN
    SET @Odb_Tytul = ''
    SET @Odb_Nazwa = ''
   END
    --PŁATNOŚCI Z PA
    IF @Dok_PowiazaniezPA = 305
  BEGIN
  IF @Dok_PaFaCzesciowe <> 1
   BEGIN
    SELECT
    @Dok_Kwota = SUM(Bzd_KwotaSys* BzD_Kierunek),
    @Dok_SlownieDoZaplaty = 'Słownie: ' + CDN.fn_Slownie(SUM(Bzd_KwotaSys* BzD_Kierunek),'','PL' ),
    @Dok_Zaplacono = 'Zapłacono: ' + replace(replace(convert(varchar,convert(Money, SUM(Bzd_KwotaRozSys* BzD_Kierunek)),1),',',' '), '.',',') + ' ' +@Dok_Waluta,
    @Dok_PozostajeDoZaplaty = CASE WHEN @Dok_Rodzaj=302100 THEN '' ELSE (CASE WHEN (SUM(Bzd_KwotaSys*BzD_Kierunek)-SUM(Bzd_KwotaRozSys*BzD_Kierunek)) >= 0 THEN 'Pozostaje do zapłaty: ' ELSE 'Pozostaje:' END + replace(replace(convert(varchar,convert(Money,ABS(SUM(Bzd_KwotaSys*BzD_Kierunek)-SUM(Bzd_KwotaRozSys*BzD_Kierunek))),1),',',' '), '.',',') + ' ' + @Dok_Waluta) END
    FROM CDN.BnkZdarzenia
    JOIN cdn.TraNagRelacje ON BZd_DokumentID=TrR_TrNId and TrR_TrNTyp = 305
    WHERE Bzd_DokumentTyp=1 AND trr_FaId = @Identyfikator
    OPTION (RECOMPILE)
    SET @Dok_RazemDoZaplaty = CASE WHEN @Dok_Kwota >= 0 THEN 'Razem do zapłaty: ' ELSE 'Razem do zwrotu: ' END + replace(replace(convert(varchar,convert(Money, ABS(@Dok_Kwota)),1),',',' '), '.',',') + ' ' +  @Dok_Waluta
    IF @Wdr_Typ = 1
   BEGIN
      SELECT
      @Dok_Zaplacono = 'Zapłacono: ' + replace(replace(convert(varchar,convert(Money, ISNULL(SUM(Bzd_KwotaRozSys* BzD_Kierunek),0.00)),1),',',' '), '.',',') + ' ' +@Dok_Waluta,
      @Dok_PozostajeDoZaplaty = CASE WHEN @Dok_Rodzaj=302100 THEN '' ELSE (CASE WHEN (@Dok_Kwota-SUM(Bzd_KwotaRozSys*BzD_Kierunek)) > 0 THEN 'Pozostaje do zapłaty: ' ELSE 'Pozostaje:' END + replace(replace(convert(varchar,convert(Money,ABS(@Dok_Kwota-ISNULL(SUM(Bzd_KwotaRozSys*BzD_Kierunek),0.00))),1),',',' '), '.',',') + ' ' + @Dok_Waluta) END
      FROM CDN.BnkZdarzenia
      JOIN cdn.TraNagRelacje ON BZd_DokumentID = TrR_TrNId AND TrR_TrNTyp = 305
      JOIN CDN.BnkRozRelacje ON BRR_ZDokID = Bzd_BZdID
      JOIN CDN.BnkZapisy  ON BZp_BZpID  = BRR_DDokID
      JOIN CDN.BnkRozKwoty ON BRR_BRKID  = BRK_BRKID
      WHERE BRR_ZDokTyp = 1 AND BRR_DDokTyp=2 AND ( BZp_ZapisAutomatyczny=1 or BRK_RozliczenieAutomatyczne=1 ) AND BzD_DokumentTyp =1 AND trr_FaId = @Identyfikator
      OPTION (RECOMPILE)
    END
    END
    /*RACHUNEK*/
    SELECT
    @Dok_Rachunek = (select BNa_Nazwa1 + CASE BRa_Waluta WHEN '' THEN ' [PLN]: ' + BRa_RachunekNr + (CASE WHEN @Pod_Status not in (0,5) AND BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) ELSE (' [' + BRa_Waluta + ']: ' + BRa_RachunekNr + CASE WHEN BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) END + CHAR(10) from CDN.BnkZdarzenia
    JOIN Cdn.BnkRachunki ON BZd_BRaID = BRa_BRaID
    JOIN Cdn.BnkNazwy  ON BRa_BNaID = Bna_BnaID
    JOIN Cdn.FormyPlatnosci on BZd_FPlId = Fpl_FplID
    JOIN cdn.TraNagRelacje ON BZd_DokumentID = TrR_TrNId AND TrR_TrNTyp = 305
    WHERE Bzd_DokumentTyp = 1 and BRa_Typ = 2 and TrR_FaId= @Identyfikator
    group by Bra_RachunekNr,BRa_Waluta,BNa_Nazwa1,BNa_Swift
    order by BRa_Waluta desc
    FOR XML PATH (''))
   END
--PŁATNOŚCI Z FA
ELSE
BEGIN
/*W WALUCIE*/
IF @Dok_Waluta <> 'PLN'
BEGIN
SELECT
@Dok_KwotaWal = ISNULL(SUM(Bzd_Kwota * BzD_Kierunek),0),
@Dok_SlownieDoZaplaty = 'Słownie: ' + CDN.fn_Slownie(ISNULL(SUM(Bzd_Kwota * BzD_Kierunek ),0),@Dok_Waluta,'PL' ),
@Dok_Zaplacono = CASE WHEN ISNULL(SUM(Bzd_KwotaRoz* BzD_Kierunek),0)>=0 THEN 'Zapłacono: ' ELSE 'Zwrócono: ' END + replace(replace(convert(varchar,convert(Money, ISNULL(ABS(SUM(Bzd_KwotaRoz* BzD_Kierunek)),0)),1),',',' '), '.',',') + ' ' + @Dok_Waluta,
@Dok_PozostajeDoZaplaty = CASE WHEN @Dok_Rodzaj=302100 THEN '' ELSE (CASE WHEN (ISNULL(SUM(Bzd_Kwota*BzD_Kierunek)-SUM(Bzd_KwotaRoz*BzD_Kierunek),0)) > 0 THEN 'Pozostaje do zapłaty: ' ELSE 'Pozostaje:' END + replace(replace(convert(varchar,convert(Money,ABS(ISNULL(SUM(Bzd_Kwota*BzD_Kierunek)-SUM(Bzd_KwotaRoz*BzD_Kierunek),0))),1),',',' '), '.',',') + ' ' + @Dok_Waluta) END
FROM CDN.BnkZdarzenia
WHERE Bzd_DokumentTyp=1 AND BzD_Waluta <> '' AND Bzd_DokumentId = @Identyfikator
OPTION (RECOMPILE)
SET @Dok_RazemDoZaplaty = CASE WHEN ISNULL(@Dok_KwotaWal,0) >= 0 THEN 'Razem do zapłaty: ' ELSE 'Razem do zwrotu: ' END + replace(replace(convert(varchar,convert(Money, ABS(@Dok_KwotaWal)),1),',',' '), '.',',') + ' ' + @Dok_Waluta
SELECT
@Dok_Kwota = ISNULL(SUM(Bzd_Kwota * BzD_Kierunek),0),
@Dok_Zaplacono = CASE WHEN ISNULL(SUM(Bzd_KwotaRoz* BzD_Kierunek),0)>=0 THEN @Dok_Zaplacono ELSE REPLACE(@Dok_Zaplacono,'Zapłacono','Zwrócono') END + ISNULL('; ' +replace(replace(convert(varchar,convert(Money, ABS(SUM(Bzd_KwotaRoz* BzD_Kierunek))),1),',',' '), '.',',') + ' PLN',''),
@Dok_PozostajeDoZaplaty = CASE WHEN ISNULL(SUM(Bzd_Kwota*BzD_Kierunek)-SUM(Bzd_KwotaRoz*BzD_Kierunek),0) >=0 THEN @Dok_PozostajeDoZaplaty ELSE REPLACE(@Dok_PozostajeDoZaplaty,'do zapłaty','') END + ISNULL('; ' + CASE WHEN @Dok_Rodzaj=302100 THEN '' ELSE replace(replace(convert(varchar,convert(Money,ABS(SUM(Bzd_Kwota*BzD_Kierunek)-SUM(Bzd_KwotaRoz*BzD_Kierunek))),1),',',' '), '.',',') + ' ' + 'PLN' END,''),
@Dok_RazemDoZaplaty =  CASE WHEN ISNULL(SUM(Bzd_Kwota* BzD_Kierunek),0)>=0 THEN @Dok_RazemDoZaplaty ELSE REPLACE(@Dok_RazemDoZaplaty,'zapłaty','zwrotu') END + ISNULL('; ' + replace(replace(convert(varchar,convert(Money, ABS(SUM(BZd_Kwota* BzD_Kierunek))),1),',',' '), '.',',') + ' PLN',''),
@Dok_SlownieDoZaplaty = @Dok_SlownieDoZaplaty + ISNULL('; ' +CDN.fn_Slownie(SUM(Bzd_KwotaSys * BzD_Kierunek ),'','PL' ),'')
FROM CDN.BnkZdarzenia
WHERE Bzd_DokumentTyp=1 AND BzD_Waluta = '' AND Bzd_DokumentId = @Identyfikator
OPTION (RECOMPILE)
/*JEŚLI DUPLIKAT*/
IF @Wdr_Typ = 1
BEGIN
SELECT
@Dok_Zaplacono = CASE WHEN ISNULL(SUM(Bzp_KwotaRoz* BzD_Kierunek),0)>=0 THEN 'Zapłacono: ' ELSE 'Zwrócono: ' END + ISNULL(replace(replace(convert(varchar,convert(Money, ISNULL(ABS(SUM(Bzp_KwotaRoz * BzD_Kierunek)),0.00)),1),',',' '), '.',','),'0,00') + ' ' + @Dok_Waluta,
@Dok_PozostajeDoZaplaty = CASE WHEN @Dok_Rodzaj=302100 THEN '' ELSE (CASE WHEN ISNULL(@Dok_KwotaWal-SUM(Bzp_KwotaRoz*BzD_Kierunek),0) > 0 THEN 'Pozostaje do zapłaty: ' ELSE 'Pozostaje:' END + replace(replace(convert(varchar,convert(Money,ABS(@Dok_KwotaWal-ISNULL(SUM(Bzp_KwotaRoz*BzD_Kierunek),0.00))),1),',',' '), '.',',') + ' ' + @Dok_Waluta) END
FROM CDN.BnkZdarzenia
JOIN CDN.BnkRozRelacje ON BRR_ZDokID = Bzd_BZdID
JOIN CDN.BnkZapisy  ON BZp_BZpID  = BRR_DDokID
JOIN CDN.BnkRozKwoty ON BRR_BRKID  = BRK_BRKID
WHERE BRR_ZDokTyp = 1 AND BRR_DDokTyp=2 AND ( BZp_ZapisAutomatyczny=1 or BRK_RozliczenieAutomatyczne=1 ) AND BzD_DokumentTyp =1 AND Bzd_DokumentID = @Identyfikator AND BZd_Waluta <> ''
OPTION (RECOMPILE)
IF @Dok_FVMarza <> 1
BEGIN
SELECT
@Dok_Zaplacono = CASE WHEN ISNULL(SUM(Bzp_KwotaRoz* BzD_Kierunek),0)>=0 THEN @Dok_Zaplacono ELSE REPLACE(@Dok_Zaplacono,'Zapłacono','Zwrócono') END + CASE WHEN @Pod_Status IN (0,5) THEN ISNULL('; ' +replace(replace(convert(varchar,convert(Money, ISNULL(ABS(SUM(Bzp_KwotaRoz* BzD_Kierunek)),0.00)),1),',',' '), '.',',') + ' PLN','') ELSE '' END,
@Dok_PozostajeDoZaplaty = CASE WHEN ISNULL(@Dok_Kwota-SUM(Bzp_KwotaRoz*BzD_Kierunek),0) >=0 THEN @Dok_PozostajeDoZaplaty ELSE REPLACE(@Dok_PozostajeDoZaplaty,'do zapłaty','') END + CASE WHEN @Pod_Status IN (0,5) THEN ISNULL('; ' + CASE WHEN @Dok_Rodzaj=302100 THEN '' ELSE replace(replace(convert(varchar,convert(Money,ABS(@Dok_Kwota-ISNULL(SUM(Bzp_KwotaRoz*BzD_Kierunek),0.00))),1),',',' '), '.',',') + ' ' + 'PLN' END,'') ELSE '' END
FROM CDN.BnkZdarzenia
JOIN CDN.BnkRozRelacje ON BRR_ZDokID = Bzd_BZdID
JOIN CDN.BnkZapisy  ON BZp_BZpID  = BRR_DDokID
JOIN CDN.BnkRozKwoty ON BRR_BRKID  = BRK_BRKID
WHERE BRR_ZDokTyp = 1 AND BRR_DDokTyp=2 AND ( BZp_ZapisAutomatyczny=1 or BRK_RozliczenieAutomatyczne=1 ) AND BzD_DokumentTyp =1 AND Bzd_DokumentID = @Identyfikator AND BZd_Waluta = ''
OPTION (RECOMPILE)
END
END
END
/*W PLN*/
ELSE
BEGIN
SELECT
@Dok_Kwota = ISNULL(SUM(Bzd_KwotaSys * BzD_Kierunek),0),
@Dok_SlownieDoZaplaty = 'Słownie: ' + CDN.fn_Slownie(ISNULL(SUM(Bzd_KwotaSys * BzD_Kierunek ),0),'','PL' ),
@Dok_Zaplacono = CASE WHEN ISNULL(SUM(Bzd_KwotaRozSys* BzD_Kierunek),0)>=0 THEN 'Zapłacono: ' ELSE 'Zwrócono: ' END + replace(replace(convert(varchar,convert(Money, ABS(ISNULL(SUM(Bzd_KwotaRozSys* BzD_Kierunek),0))),1),',',' '), '.',',') + ' ' + @Dok_Waluta,
@Dok_PozostajeDoZaplaty = CASE WHEN @Dok_Rodzaj=302100 THEN '' ELSE (CASE WHEN (ISNULL(SUM(Bzd_KwotaSys*BzD_Kierunek)-SUM(Bzd_KwotaRozSys*BzD_Kierunek),0)) > 0 THEN 'Pozostaje do zapłaty: ' ELSE 'Pozostaje:' END + replace(replace(convert(varchar,convert(Money,ABS(ISNULL(SUM(Bzd_KwotaSys*BzD_Kierunek)-SUM(Bzd_KwotaRozSys*BzD_Kierunek),0))),1),',',' '), '.',',') + ' PLN') END
FROM CDN.BnkZdarzenia
WHERE Bzd_DokumentTyp=1 AND Bzd_DokumentId = @Identyfikator
OPTION (RECOMPILE)
SET @Dok_RazemDoZaplaty = CASE WHEN @Dok_Kwota >= 0 THEN 'Razem do zapłaty: ' ELSE 'Razem do zwrotu: ' END + replace(replace(convert(varchar,convert(Money, ABS(@Dok_Kwota)),1),',',' '), '.',',') + ' ' + @Dok_Waluta
/*Jeśli Duplikat*/
IF @Wdr_Typ = 1
BEGIN
SELECT
@Dok_Zaplacono = CASE WHEN ISNULL(SUM(Bzp_KwotaRozSys* BzD_Kierunek),0) >= 0 THEN 'Zapłacono: ' ELSE 'Zwrócono: ' END + replace(replace(convert(varchar,convert(Money, ISNULL(ABS(SUM(Bzp_KwotaRozSys* BzD_Kierunek)),0.00)),1),',',' '), '.',',') + ' ' + @Dok_Waluta,
@Dok_PozostajeDoZaplaty = CASE WHEN @Dok_Rodzaj=302100 THEN '' ELSE (CASE WHEN (ISNULL(@Dok_Kwota-SUM(Bzp_KwotaRozSys*BzD_Kierunek),0)) > 0 THEN 'Pozostaje do zapłaty: ' ELSE 'Pozostaje:' END + replace(replace(convert(varchar,convert(Money,ABS(@Dok_Kwota-ISNULL(SUM(Bzp_KwotaRozSys*BzD_Kierunek),0.00))),1),',',' '), '.',',') + ' PLN') END
FROM CDN.BnkZdarzenia
JOIN CDN.BnkRozRelacje ON BRR_ZDokID = Bzd_BZdID
JOIN CDN.BnkZapisy  ON BZp_BZpID  = BRR_DDokID
JOIN CDN.BnkRozKwoty ON BRR_BRKID  = BRK_BRKID
WHERE BRR_ZDokTyp = 1 AND BRR_DDokTyp=2 AND ( BZp_ZapisAutomatyczny=1 or BRK_RozliczenieAutomatyczne=1 ) AND BzD_DokumentTyp =1 AND Bzd_DokumentID = @Identyfikator
OPTION (RECOMPILE)
END
END
/*RACHUNEK*/
SELECT
@Dok_Rachunek = (select BNa_Nazwa1 + CASE BRa_Waluta WHEN '' THEN ' [PLN]: ' + BRa_RachunekNr + (CASE WHEN @Pod_Status not in (0,5) AND BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) ELSE (' ['+BRa_Waluta+']: ' + BRa_RachunekNr + CASE WHEN BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) END + CHAR(10) from CDN.BnkZdarzenia
JOIN Cdn.BnkRachunki ON BZd_BRaID = BRa_BRaID
JOIN Cdn.BnkNazwy  ON BRa_BNaID = Bna_BnaID
JOIN Cdn.FormyPlatnosci on BZd_FPlId = Fpl_FplID
WHERE Bzd_DokumentTyp = 1 and BRa_Typ = 2 and BZd_DokumentID = @Identyfikator
group by Bra_RachunekNr,BRa_Waluta,BNa_Nazwa1,BNa_Swift
order by BRa_Waluta desc
FOR XML PATH (''))
END
SET @Dok_OpisGotowka = '';
--KWOTY VAT
SELECT
@VAT = 'Suma: ',
@VAT_KwotaNetto  = SUM(TrV_Netto),
@VAT_KwotaVat  = SUM(TrV_VAT),
@VAT_KwotaBrutto = CASE @Dok_FVMarza WHEN 0 THEN SUM(TrV_Netto+TrV_VAT) ELSE SUM(TrV_NettoWal+TrV_VATWal) END
FROM CDN.TraVat
WHERE TrV_TrNID=@Identyfikator
Select
@Pow_Numer = 'Do dokumentu: ' + CASE WHEN TrN_Rodzaj=302100 AND TrN_NumerPelnyPrw <> '' THEN TrN_NumerPelnyPrw ELSE TrN_NumerPelny END,
@Pow_DataWystawienia = 'Wystawionego: ' + CAST(CONVERT(date,TrN_DataWys,120) as varchar),
@Pow_DataOperacji  = CASE WHEN TrN_Rodzaj IN (302200,302202) THEN '' ELSE 'Z datą dostawy/wykonania usługi: ' + CASE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 1999) WHEN 2 THEN '     ' + CAST(RIGHT(CONVERT(VARCHAR(10), TrN_DataOpe, 105), 7)  as varchar) ELSE CAST(CONVERT(date,TrN_DataOpe,120) as varchar) END END,
@Pow_Kurs    = CASE WHEN TrN_Waluta <> '' THEN 'Kurs przed korektą: ' + CAST(Trn_KursM as varchar) + ' ' + @Dok_Waluta + ' = ' + CAST(TrN_KursL as varchar) + ' PLN' ELSE '' END
from CDN.TraNag
where TrN_TrNID = @Pow_Id
--jeśli fazal (nie korekta)
IF @Dok_TypKor = 0 AND @Dok_Rodzaj = 302200
BEGIN
Select top 1
@Pow_DataOperacji ='Do dokumentu: ' + TrN_NumerPelny,
@Pow_DataWystawienia = 'Wystawionego: ' + CAST(CONVERT(date,TrN_DataWys,120) as varchar)
from CDN.TraNag
left join CDN.TraNagRelacje on TrN_TrNID = TrR_TrNId
WHERE TrR_FaId = @Identyfikator and TrN_TypDokumentu =320
END
--Jeśli FA z PA
IF @Pow_Id is NULL AND @Dok_Rodzaj = 302006
BEGIN
 SELECT @Pow_Numer = cdn.ListaPowiazanychPA(@Identyfikator)
 SELECT @Pow_Numer = CASE WHEN @Pow_Numer is NULL THEN '' ELSE CASE (LEN(@Pow_Numer) - LEN(REPLACE(@Pow_Numer, ',', ''))) WHEN 0 THEN 'Do paragonu: ' ELSE 'Do paragonów: ' END + @Pow_Numer END
END
--Faktura na czesc PA
IF @Dok_PaFaCzesciowe = 1
BEGIN
 SET @Dok_Zaplacono = ''
 SET @Dok_PozostajeDoZaplaty = ''
 SET @Dok_RazemDoZaplaty = 'Razem do zapłaty: ' + REPLACE(CAST(@VAT_KwotaBrutto as varchar),'.',',') + ' PLN'
 SET @Dok_SlownieDoZaplaty = 'Słownie: ' + CDN.fn_Slownie(@VAT_KwotaBrutto,'','PL' )
END
IF @Dok_TypKor = 7
BEGIN
SET @Dok_RazemDoZaplaty=''
SET @Dok_SlownieDoZaplaty=''
SET @Dok_Zaplacono =''
SET @Dok_PozostajeDoZaplaty=''
SET @Dok_Kurs = ''
SELECT
--DANE PODMIOTU Z FA
@Pod_KorNazwa =
/* NAZWA */
CASE WHEN TrN_PodNazwa1 <> '' THEN TrN_PodNazwa1 ELSE '' END  +
CASE WHEN TrN_PodNazwa2 <> '' THEN CHAR(13) + TrN_PodNazwa2 ELSE '' END  +
CASE WHEN TrN_PodNazwa3 <> '' THEN CHAR(13) + TrN_PodNazwa3 ELSE '' END  +
/* ADRES */
CHAR(13) + CASE WHEN TrN_PodUlica <> '' THEN TrN_PodUlica WHEN TrN_PodUlica='' AND TrN_PodMiasto <>'' THEN TrN_PodMiasto ELSE TrN_PodPoczta END +
' ' + CASE WHEN TrN_PodNrDomu <> '' AND TrN_PodNrLokalu <> '' THEN TrN_PodNrDomu + '/' + TrN_PodNrLokalu WHEN TrN_PodNrDomu <> '' AND TrN_PodNrLokalu = '' THEN TrN_PodNrDomu ELSE TrN_PodNrLokalu END +
CASE WHEN TrN_PodPoczta <> TrN_PodUlica  AND TrN_PodMiasto <> TrN_PodUlica AND Trn_PodMiasto <> Trn_PodPoczta AND TrN_PodPoczta <> '' AND TrN_PodMiasto <> '' AND TrN_PodUlica <> '' THEN ', ' + TrN_PodMiasto ELSE '' END +
/* POCZTA */
CHAR(13) + TrN_PodKodPocztowy +
CASE WHEN TrN_PodPoczta <> '' THEN ' ' + TrN_PodPoczta ELSE  ' ' + TrN_PodMiasto END +
/* KRAJ */
CASE WHEN TrN_PodKraj <> '' THEN CHAR(13) + TrN_PodKraj ELSE '' END +
/* NIP */
CASE WHEN TrN_PodNipE <> '' THEN CHAR(13) + 'NIP: ' + TrN_PodNipKraj + ' ' + TrN_PodNipE + CHAR(13) ELSE '' END,
--DANE ODBIORCY Z FA
@Odb_KorNazwa =
/* NAZWA */
CASE WHEN TrN_OdbNazwa1 <> '' THEN TrN_OdbNazwa1 ELSE '' END  +
CASE WHEN TrN_OdbNazwa2 <> '' THEN CHAR(13) + TrN_OdbNazwa2 ELSE '' END  +
CASE WHEN TrN_OdbNazwa3 <> '' THEN CHAR(13) + TrN_OdbNazwa3 ELSE '' END  +
/* ADRES */
CHAR(13) + CASE WHEN TrN_OdbUlica <> '' THEN TrN_OdbUlica WHEN TrN_OdbUlica='' AND TrN_OdbMiasto <>'' THEN TrN_OdbMiasto ELSE TrN_OdbPoczta END +
' ' + CASE WHEN TrN_OdbNrDomu <> '' AND TrN_OdbNrLokalu <> '' THEN TrN_OdbNrDomu + '/' + TrN_OdbNrLokalu WHEN TrN_OdbNrDomu <> '' AND TrN_OdbNrLokalu = '' THEN TrN_OdbNrDomu ELSE TrN_OdbNrLokalu END +
CASE WHEN TrN_OdbPoczta <> TrN_OdbUlica  AND TrN_OdbMiasto <> TrN_OdbUlica AND Trn_OdbMiasto <> Trn_OdbPoczta AND TrN_OdbPoczta <> '' AND TrN_OdbMiasto <> '' AND TrN_OdbUlica <> '' THEN ', ' + TrN_OdbMiasto ELSE '' END +
/* POCZTA */
CHAR(13) + TrN_OdbKodPocztowy +
CASE WHEN TrN_OdbPoczta <> '' THEN ' ' + TrN_OdbPoczta ELSE ' ' + TrN_OdbMiasto END +
/* KRAJ */
CASE WHEN TrN_OdbKraj <> '' THEN CHAR(13) + TrN_OdbKraj ELSE '' END +
/* NIP */
CASE WHEN TrN_OdbNipE <> '' THEN CHAR(13) + 'NIP: ' + TrN_OdbNipKraj + ' ' + TrN_OdbNipE + CHAR(13) ELSE '' END
FROM CDN.Tranag
WHERE TrN_TrNID = @Pow_Id
 IF @Pod_KorNazwa = @Odb_KorNazwa
 BEGIN
  SET @Odb_KorNazwa = ''
 END
 IF @Odb_KorNazwa <> @Odb_Nazwa OR @Pod_KorNazwa <> @Pod_Nazwa
 BEGIN
  SET @Odb_Tytul = 'Odbiorca:'
  SET @Dok_KorPrzed = 'Dane przed korektą '
  SET @Dok_KorPo = 'Dane po korekcie '
  IF @Odb_Nazwa = ''
  BEGIN
   SET @Odb_Nazwa = @Pod_Nazwa
  END
  IF @Odb_KorNazwa = ''
  BEGIN
   SET @Odb_KorNazwa = @Pod_KorNazwa
  END
 END
END
  --Korekta Kursu Waluty
  IF @Dok_TypKor = 8
  BEGIN
   SET @Dok_TypNettoBrutto =  replace(@Dok_TypNettoBrutto,' ['+@Dok_Waluta+']',' [PLN]')
  END
  ELSE
  BEGIN
   SET @Pow_Kurs = ''
  END
--Fa Zal
IF @Dok_Rodzaj = 302200
BEGIN
SELECT @Dok_FZAL_Plat = 'Zaliczki otrzymano w dniach: ' + (SELECT CAST(CONVERT(date,BZp_DataDok,120) as varchar) + ', '
FROM CDN.BnkZdarzenia
JOIN CDN.BnkRozRelacje ON BRR_ZDokID = Bzd_BZdID AND BRR_ZDokTyp = 1
JOIN CDN.BnkZapisy  ON BZp_BZpID  = BRR_DDokID
WHERE Bzd_DokumentTyp=1 AND Bzd_DokumentId = @Identyfikator
FOR XML PATH (''))
OPTION (RECOMPILE)
END
 END
 ELSE
 BEGIN
 --DANE PRZYKŁADOWE
  SELECT
   @Pod_Tytul = 'Nabywca:',
   @Pod_Nazwa    = 'Przykładowy Nabywca' + CHAR(13) + 'ul.Przykłady 1/12' + CHAR(13) + '11-111, Miasto_1' + char(13) + 'NIP: 111-11-111-11',
   @Odb_Tytul = 'Odbiorca:',
   @Odb_Nazwa = 'Przykładowy Odbiorca' + CHAR(13) + 'ul.Przykładowa 3a' + CHAR(13) + '22-222, Miasto_2' + char(13) + 'NIP: 222-22-222-22',
   @Dok_Nazwa    = (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 2167 /*Tytuł FA / FA UE*/),
   @Dok_Numer    = 'Numer dokumentu: FAKOR/1/' + CAST(YEAR(GETDATE()) as varchar),
   @Dok_DataWystawienia = 'Data wystawienia: ' + CASE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 1999) WHEN 2 THEN CAST(RIGHT(CONVERT(VARCHAR(10), GETDATE(), 105), 7) as varchar) ELSE CAST(CONVERT(date,GETDATE(),120) as varchar) END,
   @Dok_DataOperacji  = 'Data dostawy/wykonania usługi: ' + CASE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 1999) WHEN 2 THEN CAST(RIGHT(CONVERT(VARCHAR(10), GETDATE(), 105), 7) as varchar) ELSE CAST(CONVERT(date,GETDATE(),120) as varchar) END,
   @Dok_DataDuplikatu  = '',
   @Dok_Opis    = 'Opis: Przykładowy opis dokumentu',
   @Dok_Rachunek = 'Nr rachunku PLN: 11-111111-1111111',
   @Dok_Kurs    = '',
   @Dok_OpisGotowka  = '',
   @Dok_TypNettoBrutto = 'netto',
   @Dok_RazemDoZaplaty  = 'Razem do zapłaty: 0,00',
   @Dok_SlownieDoZaplaty = 'Słownie: zero PLN 00/100',
   @Dok_Zaplacono   = 'Zapłacono: 0,00 PLN',
   @Dok_PozostajeDoZaplaty = 'Pozostaje do zapłaty: 0,00 PLN',
   @Dok_Wystawil   = 'Operator wystawiający dokument',
   @Dok_Odebral   = '',
   @Dok_Stopka    = 'Wydrukowano przy pomocy programu Comarch ERP Optima',
   @VAT    = 'Suma:',
   @VAT_KwotaNetto  = 0,
   @VAT_KwotaVat  = 0,
   @VAT_KwotaBrutto = 0
 END
 --Jeśli Trójstronna
 IF @Dok_TypKor = 0 AND @Pod_Status=4
 BEGIN
  SET @Dok_Trojdtronna = 'VAT: Faktura WE uproszczona na mocy artykułu 141 dyrektywy 2006/112/WE'
 END
 --JEŚLI VAT UE LUB POZAUNIJNA
 IF @Dok_Waluta <> 'PLN'
 BEGIN
  SET @VAT_NagNetto = 'Wartość netto' + CHAR(13) + '[PLN]'
  SET @VAT_NagVAT  = 'Kwota VAT' + CHAR(13) + '[PLN]'
  SET @VAT_NagBrutto = 'Wartość brutto' + CHAR(13) + '[PLN]'
 END
 ELSE
 BEGIN
   SET @VAT_NagNetto = 'Wartość netto'
   SET @VAT_NagVAT  = 'Kwota VAT'
   SET @VAT_NagBrutto = 'Wartość brutto'
 END
IF @Dok_FVMarza = 1 AND @Dok_Waluta <> 'PLN'
 BEGIN
  SET @VAT_NagNetto = 'Wartość netto'
  SET @VAT_NagVAT  = 'Kwota VAT' + case @Dok_FVMarza WHEN 1 THEN  CHAR(13) + '[PLN]' ELSE '' END
  SET @VAT_NagBrutto = 'Wartość brutto' + case @Dok_FVMarza WHEN 1 THEN ' [' + @Dok_Waluta + ']' ELSE '' END
 END
 --FPF
 IF @Dok_Rodzaj IN (320000,320008,320009,320200)
 BEGIN
 SELECT
  @Dok_Rachunek = (select BNa_Nazwa1 + CASE BRa_Waluta WHEN '' THEN ' [PLN]: ' + BRa_RachunekNr + (CASE WHEN @Pod_Status not in (0,5) AND BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) ELSE (' ['+BRa_Waluta+']: ' + BRa_RachunekNr + CASE WHEN BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) END + CHAR(10)
  FROM Cdn.FormyPlatnosci
  JOIN Cdn.BnkRachunki ON Fpl_BraId=BRa_BraId
  JOIN Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID
  WHERE fpl_fplID = @Fpl_ID and @Dok_Waluta = 'PLN' and FPl_Typ = 2 and BRa_Typ = 2
  union all
  select BNa_Nazwa1 + CASE BRa_Waluta WHEN '' THEN ' [PLN]: ' + BRa_RachunekNr + (CASE WHEN BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) ELSE (' [' + BRa_Waluta + ']: ' + BRa_RachunekNr + CASE WHEN BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) END + CHAR(10)
  from CDN.FormyPlatnWaluty
  join Cdn.FormyPlatnosci on fpw_fplid = fpl_fplid
  JOIN Cdn.BnkRachunki ON Fpw_BraId=BRa_BraId
  JOIN Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID
  where fpl_fplID = @Fpl_ID and BRa_Waluta = @Dok_Waluta and FPl_Typ = 2 and BRa_Typ = 2)
  SET @Dok_Zaplacono = ''
  SET @Dok_PozostajeDoZaplaty = ''
  SET @Dok_RazemDoZaplaty = 'Razem do zapłaty: ' +  replace(replace(convert(varchar,convert(Money, ABS(@Dok_Razem)),1),',',' '), '.',',') + ' ' +@Dok_Waluta
  SET @Dok_SlownieDoZaplaty = 'Słownie: ' + CDN.fn_Slownie(@Dok_Razem,@Dok_Waluta,'PL' )
  IF @Dok_Rachunek IS NULL
 BEGIN
   SET @Dok_Rachunek = (select top 1 BNa_Nazwa1 + CASE BRa_Waluta WHEN '' THEN ' [PLN]: ' + BRa_RachunekNr + (CASE WHEN @Pod_Status not in (0,5) AND BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) ELSE (' ['+BRa_Waluta+']: ' + BRa_RachunekNr + CASE WHEN BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) END + CHAR(10)
   FROM Cdn.FormyPlatnosci
   JOIN Cdn.BnkRachunki ON Fpl_BraId=BRa_BraId
   JOIN Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID
   WHERE fpl_fplID = @Fpl_ID and FPl_Typ = 2 and BRa_Typ = 2)
 END
  IF @Dok_Rachunek IS NULL
 BEGIN
 declare @SysSrv nvarchar(200), @SysKnf nvarchar(200), @OpeKasa nvarchar(200),@OpeBank nvarchar(200)
 SELECT @SysSrv = SYS_Wartosc from CDN.SystemCDN WHERE SYS_ID=1001
 SELECT @SysKnf = SYS_Wartosc from CDN.SystemCDN WHERE SYS_ID=1002
 exec CDN.DomyslnaKasaBankOperatora @SysSrv, @SysKnf, 1, @OpeKasa OUTPUT, @OpeBank OUTPUT
 SET @Dok_Rachunek = (Select BNa_Nazwa1 + CASE BRa_Waluta WHEN '' THEN ' [PLN]: ' + BRa_RachunekNr + (CASE WHEN 0 not in (0,5) AND BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END)
 ELSE (' ['+BRa_Waluta+']: ' + BRa_RachunekNr + CASE WHEN BnA_Swift <> '' THEN ', SWIFT: ' + BnA_Swift ELSE '' END) END + CHAR(10) from CDN.BnkRachunki
 JOIN Cdn.BnkNazwy ON BRa_BNaID=Bna_BnaID Where BRa_Akronim = @OpeBank)
 END
 END
 --JEŚLI DUPLIKAT
 IF @Wdr_Typ = 1
 BEGIN
  SET @Dok_Duplikat  = 'DUPLIKAT'
  SET @Dok_DataDuplikatu = 'Data wydrukowania duplikatu:' --+ CAST(CONVERT(date,GETDATE(),120) as varchar)
 END
 SET @Tre_Tytul = CAST(CASE (select Fir_Wartosc from CDN.Firma Where Fir_Numer = 1995 /*Kolumna Towar*/)
  WHEN 2 /*Kod*/ THEN 'Kod towaru'
  WHEN 3 /*Nr Katalogowy*/ THEN 'Nr katalogowy'
  WHEN 4 /*EAN*/ THEN 'Kod EAN'
  WHEN 5 /*Kod i Nr Katalogowy*/ THEN  'Kod towaru / Nr katalogowy'
  WHEN 6 /*Kod i EAN*/ THEN 'Kod towaru / Kod EAN '
  WHEN 7 /*Nr katalogowy i Kod*/ THEN 'Nr katalogowy / Kod towaru'
  WHEN 8 /*EAN i Kod*/ THEN 'Kod EAN / Kod towaru'
  WHEN 9 /*Nazwa i Nr Katalogowy*/ THEN 'Nazwa towaru / Nr katalogowy'
  WHEN 10 /*Nr Katalogowy i Nazwa*/ THEN 'Nr katalogowy / Nazwa towaru'
  WHEN 11 /*Kod i Nazwa*/ THEN 'Kod towaru / Nazwa towaru'
  ELSE 'Nazwa towaru/usługi' END as varchar(256))
SELECT TOP 1
(SELECT TOP 1 DAB_Wartosc from  [CDN].[DaneBinarne] where Dab_typ = 13 and DAB_TwAID=@Fir_PCID) [Fir_Logo],
 @Fir_Tytul    [Fir_Tytul],
 @Fir_Nazwa    [Fir_Nazwa],
 @Fir_Mail    [Fir_Mail],
 @Fir_Opis    [Fir_Opis],
 @FirJ_Tytul    [FirJ_Tytul],
 @FirJ_Nazwa    [FirJ_Nazwa],
 @FirJ_Mail    [FirJ_Mail],
 @Met_Kasowa   [Met_Kasowa],
 @Ukryj_Oswiadczenie [Ukryj_Oswiadczenie],
 @Pod_Tytul    [Pod_Tytul],
 @Pod_Nazwa    [Pod_Nazwa],
 @Odb_Tytul    [Odb_Tytul],
 @Odb_Nazwa    [Odb_Nazwa],
 @Dok_Nazwa    [Dok_Nazwa],
 @Dok_Numer    [Dok_Numer],
 @Dok_TypDokumentu [Dok_TypDokumentu],
 @Dok_DataWystawienia [Dok_DataWystawienia],
 @Dok_DataOperacji  [Dok_DataOperacji],
 @Dok_Duplikat   [Dok_Duplikat],
 @Dok_DataDuplikatu  [Dok_DataDuplikatu],
 @Dok_Opis    [Dok_Opis],
 @Dok_Rachunek   [Dok_Rachunek],
 @Dok_Kurs    [Dok_Kurs],
 @Dok_OpisGotowka  [Dok_OpisGotowka],
 @Dok_TypNettoBrutto  [Dok_TypNettoBrutto],
 @Dok_RazemDoZaplaty  [Dok_RazemDoZaplaty],
 @Dok_SlownieDoZaplaty [Dok_SlownieDoZaplaty],
 @Dok_Zaplacono   [Dok_Zaplacono],
 @Dok_PozostajeDoZaplaty [Dok_PozostajeDoZaplaty],
 @Dok_Wystawil   [Dok_Wystawil],
 @Dok_Odebral   [Dok_Odebral],
 @Dok_Stopka    [Dok_Stopka],
 @Pow_Numer    [Pow_Numer],
 @Pow_DataWystawienia [Pow_DataWystawienia],
 @Pow_DataOperacji  [Pow_DataOperacji],
 @Pow_Kurs    [Pow_Kurs],
 @Dok_TypKor    [Dok_TypKor],
 @Dok_Przyczyna   [Pow_Przyczyna],
 @Dok_Trojdtronna [Dok_Trojstronna],
 @Dok_JPK [Dok_JPK],
 @VAT     [VAT],
 @VAT_KwotaNetto   [VAT_KwotaNetto],
 @VAT_KwotaVat   [VAT_KwotaVat],
 @VAT_KwotaBrutto  [VAT_KwotaBrutto],
 @VAT_NagNetto   [VAT_NagNetto],
 @VAT_NagVAT    [VAT_NagVAT],
 @VAT_NagBrutto   [VAT_NagBrutto],
 @Pod_KorNazwa   [Pod_KorNazwa],
 @Odb_KorNazwa   [Odb_KorNazwa],
 @Dok_KorPrzed   [Dok_KorPrzed],
 @Dok_KorPo    [Dok_KorPo],
 @Dok_FZAL_Plat [Dok_FZalPlat],
 @Dok_StopkaKnf [Dok_StopkaKnf],
 @Tre_Tytul [Tre_Tytul]
RETURN 1;
END
