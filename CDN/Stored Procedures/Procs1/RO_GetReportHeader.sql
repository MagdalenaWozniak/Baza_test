CREATE PROCEDURE [CDN].[RO_GetReportHeader]
 @Identyfikator int = 0,
 @Wdr_Jednostka  int = 0
AS
BEGIN
 DECLARE
  @Fir_Tytul varchar(128),
  @Fir_Nazwa nvarchar(2052),
  @Fir_Mail varchar(256),
  @Fir_Opis varchar(512),
  @FirJ_Tytul  varchar(128),
  @FirJ_Nazwa  nvarchar(2052),
  @FirJ_Mail  varchar(256),
  @Fir_PCID int,
  @Fir_PCJID int,
  @Pod_Tytul  varchar(64),
  @Pod_Nazwa  nvarchar(512),
  @Odb_Tytul  varchar(64),
  @Odb_Nazwa  nvarchar(512),
  @Dok_Nazwa    varchar(64),
  @Dok_Numer    varchar(64),
  @Dok_NrZamowienia varchar(256),
  @Dok_DataWystawienia varchar(64),
  @Dok_DataOperacji  varchar(64),
  @Dok_Opis    nvarchar(1024),
  @Dok_Waluta    varchar(8),
  @Dok_Rachunek   nvarchar(512),
  @Dok_Razem decimal(16,2),
  @Dok_Kurs    varchar(128),
  @Dok_TypNettoBrutto  varchar(32),
  @Dok_RazemDoZaplaty  varchar(128),
  @Dok_SlownieDoZaplaty varchar(1024),
  @Dok_Wystawil   varchar(128),
  @Dok_Odebral   varchar(128),
  @Dok_Stopka    varchar(64),
  @Dok_StopkaKnf varchar(254),
  @Pod_Status int,
  @VAT    varchar(8),
  @VAT_KwotaNetto  decimal(16,2),
  @VAT_KwotaVat  decimal(16,2),
  @VAT_KwotaBrutto decimal(16,2),
  @VAT_NagNetto  varchar(32),
  @VAT_NagVAT   varchar(32),
  @VAT_NagBrutto  varchar(32),
  @Fpl_ID  int
 SET @Dok_StopkaKnf = (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=1992)
 --DANE PIECZATKI
 SELECT @Fir_PCID = TrN_PCID, @Fir_PCJID = TrN_PCJSID from CDN.TraNag Where TrN_TrNID = @Identyfikator
 SELECT @Fir_Tytul = 'Sprzedawca:',
  @FirJ_Nazwa = Firm_String,
  @FirJ_Mail = Firm_Email + CASE WHEN Firm_URL <> '' THEN CHAR(13) + Firm_URL ELSE '' END,
  @Fir_Opis = Firm_Opis,
  @FirJ_Tytul = (CASE WHEN Jorg_String <> '' THEN char(13) + 'Jednostka organizacyjna:' ELSE '' END),
  @Fir_Nazwa = Jorg_String,
  @Fir_Mail = Jorg_Email + CASE WHEN Jorg_URL <> '' THEN CHAR(13) + Jorg_URL ELSE '' END
 from CDN.fnPieczatka(@Fir_PCID,@Fir_PCJID, @Wdr_Jednostka)
 SELECT
    --DANE PODMIOTU
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
    CASE WHEN TrN_PodNipE <> '' THEN CHAR(13) + 'NIP: ' + CASE WHEN TrN_PodNipKraj <> '' THEN TrN_PodNipKraj + ' ' + TrN_PodNipE ELSE TrN_PodNipE END ELSE '' END,
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
 @Dok_Waluta = CASE WHEN TrN_Waluta <> '' THEN TrN_Waluta ELSE 'PLN' END,
    @Dok_Numer    = 'Numer dokumentu: ' + TrN_NumerPelny,
    @Dok_NrZamowienia = CASE WHEN TrN_NumerObcy <> '' THEN 'Nr zamówienia: ' + TrN_NumerObcy ELSE '' END,
 @Dok_DataWystawienia = 'Data wystawienia: ' + CAST(CONVERT(date,TrN_DataDok,120) as varchar),
    @Dok_DataOperacji  = 'Termin realizacji: '  + CAST(CONVERT(date,TrN_DataWys,120) as varchar),
    @Dok_Opis    = CASE WHEN Trn_Opis <> '' THEN 'Opis: ' + TrN_Opis ELSE '' END,
    @Dok_Kurs    = CASE WHEN TrN_Waluta <> '' THEN 'Kurs przeliczenia: ' + CAST(Trn_KursM as varchar) + ' ' + @Dok_Waluta + ' = ' + CAST(TrN_KursL as varchar) + ' PLN' ELSE '' END,
    @Dok_TypNettoBrutto = CASE TrN_TypNB WHEN 1 THEN ' netto' ELSE ' brutto' END + CASE TrN_Waluta WHEN '' THEN '' ELSE ' ['+TrN_Waluta+']' END,
    @Dok_Razem = Case @Dok_Waluta WHEN '' THEN TrN_RazemBrutto ELSE Trn_RazemBruttoWal END,
    @Dok_wystawil   = CASE TrN_Bufor WHEN 1 THEN TrN_OpeModNazwisko
       ELSE TrN_OpeZatwNazwisko END,
    @Dok_Odebral   = TrN_Odebral ,
    @Dok_Stopka    = CASE TrN_Bufor WHEN 1 THEN '(B) ' WHEN 0 THEN '' ELSE '(A) ' END + 'Wydrukowano przy pomocy programu Comarch ERP Optima',
    @Fpl_ID = TrN_FPlId,
    @Dok_Nazwa   = 'Rezerwacja Odbiorcy'
    FROM CDN.Tranag
    WHERE TrN_TrNID = @Identyfikator
    IF @Pod_Nazwa = @Odb_Nazwa
    BEGIN
     SET @Odb_Tytul = ''
     SET @Odb_Nazwa = ''
    END
--KWOTY VAT
SELECT
@VAT = 'Suma: ',
@VAT_KwotaNetto  = SUM(TrV_Netto),
@VAT_KwotaVat  = SUM(TrV_VAT),
@VAT_KwotaBrutto = SUM(TrV_Netto+TrV_VAT)
FROM CDN.TraVat
WHERE TrV_TrNID=@Identyfikator
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
 --RACHUNEK
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
  SET @Dok_RazemDoZaplaty = 'Wartość: ' +  replace(replace(convert(varchar,convert(Money, ABS(@Dok_Razem)),1),',',' '), '.',',') + ' ' +@Dok_Waluta
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
SELECT TOP 1
(SELECT TOP 1 DAB_Wartosc from  [CDN].[DaneBinarne] where Dab_typ = 13 and DAB_TwAID=@Fir_PCID) [Fir_Logo],
 @Fir_Tytul    [Fir_Tytul],
 @Fir_Nazwa    [Fir_Nazwa],
 @Fir_Mail    [Fir_Mail],
 @Fir_Opis    [Fir_Opis],
 @FirJ_Tytul    [FirJ_Tytul],
 @FirJ_Nazwa    [FirJ_Nazwa],
 @FirJ_Mail    [FirJ_Mail],
 @Pod_Tytul    [Pod_Tytul],
 @Pod_Nazwa    [Pod_Nazwa],
 @Odb_Tytul    [Odb_Tytul],
 @Odb_Nazwa    [Odb_Nazwa],
 @Dok_Nazwa    [Dok_Nazwa],
 @Dok_Numer    [Dok_Numer],
 @Dok_NrZamowienia [Dok_NrZamowienia],
 @Dok_DataWystawienia [Dok_DataWystawienia],
 @Dok_DataOperacji  [Dok_DataOperacji],
 @Dok_Opis    [Dok_Opis],
 @Dok_Rachunek   [Dok_Rachunek],
 @Dok_Kurs    [Dok_Kurs],
 @Dok_TypNettoBrutto  [Dok_TypNettoBrutto],
 @Dok_RazemDoZaplaty  [Dok_RazemDoZaplaty],
 @Dok_SlownieDoZaplaty [Dok_SlownieDoZaplaty],
 @Dok_Wystawil   [Dok_Wystawil],
 @Dok_Odebral   [Dok_Odebral],
 @Dok_Stopka    [Dok_Stopka],
 @VAT     [VAT],
 @VAT_KwotaNetto   [VAT_KwotaNetto],
 @VAT_KwotaVat   [VAT_KwotaVat],
 @VAT_KwotaBrutto  [VAT_KwotaBrutto],
 @VAT_NagNetto   [VAT_NagNetto],
 @VAT_NagVAT    [VAT_NagVAT],
 @VAT_NagBrutto   [VAT_NagBrutto],
 @Dok_StopkaKnf [Dok_StopkaKnf]
RETURN 1;
END
