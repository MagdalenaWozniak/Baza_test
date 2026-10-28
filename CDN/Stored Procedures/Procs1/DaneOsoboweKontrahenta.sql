CREATE  PROCEDURE [CDN].[DaneOsoboweKontrahenta]
 @Identyfikator int = 0
AS
BEGIN
 DECLARE
  @Nazwa  varchar(64),
  @Kon_Nazwa nvarchar(450),
  @Adres varchar(64),
  @Kon_Adres nvarchar(260),
  @Kor_Adres varchar(64),
  @Kon_Kor_Adres nvarchar(180),
  @Kontakt varchar(64),
  @Kon_Kontakt nvarchar(510),
  @Inne varchar(64),
  @Kon_Inne nvarchar(320),
  @Rachunek varchar(64),
  @Kon_Rachunek nvarchar (51),
  @Stopka varchar(64)
    --DANE Z BAZY
  IF @Identyfikator <> 0
  BEGIN
   SELECT
    --NAZWA KONTRAHENTA
    @Nazwa = 'Nazwa:',
    @Kon_Nazwa=
    /* NAZWA */
    CASE WHEN Knt_Nazwa1 <> '' THEN Knt_Nazwa1 ELSE '' END  +
    CASE WHEN Knt_Nazwa2 <> '' THEN CHAR(13) + Knt_Nazwa2 ELSE '' END  +
    CASE WHEN Knt_Nazwa3 <> '' THEN CHAR(13) + Knt_Nazwa3 ELSE '' END  +
    /* NIP */
    CASE WHEN Knt_NipE <> '' THEN CHAR(13) + 'NIP: ' + CHAR(9) + CASE Knt_NipKraj WHEN '' THEN '' ELSE Knt_NipKraj + ' ' END + Knt_NipE ELSE '' END +
 /* REGON */
 CASE WHEN Knt_Regon <> '' THEN CHAR(13) + 'REGON: ' + CHAR(9) + Knt_Regon ELSE '' END +
 /* PESEL */
 CASE WHEN Knt_Pesel <> '' THEN CHAR(13) + 'PESEL: ' + CHAR(9) + Knt_Pesel ELSE '' END ,
 @Adres = 'Adres:',
 @Kon_Adres=
 /* ADRES */
    LTRIM(CASE WHEN Knt_Ulica <> '' THEN Knt_Ulica WHEN Knt_Ulica='' AND Knt_Miasto <>'' THEN Knt_Miasto ELSE Knt_Poczta END +
    CASE WHEN Knt_NrDomu <> '' AND Knt_NrLokalu <> '' THEN ' ' + Knt_NrDomu + '/' + Knt_NrLokalu WHEN Knt_NrDomu <> '' AND Knt_NrLokalu = '' THEN ' ' + Knt_NrDomu WHEN Knt_NrDomu = '' AND Knt_NrLokalu <> '' THEN ' ' + Knt_NrLokalu ELSE '' END +
    CASE WHEN Knt_Poczta <> Knt_Ulica  AND Knt_Miasto <> Knt_Ulica AND Knt_Miasto <> Knt_Poczta AND Knt_Poczta <> '' AND Knt_Miasto <> '' AND Knt_Ulica <> '' THEN ', ' + Knt_Miasto ELSE '' END +
    CASE WHEN (Knt_Miasto <> '' OR Knt_Poczta <> '') OR (Knt_Ulica <> '' AND Knt_KodPocztowy <> '') THEN + ', ' ELSE '' END +
 /* POCZTA */
  + Knt_KodPocztowy +
    CASE WHEN Knt_Kodpocztowy <> '' THEN
 CASE WHEN Knt_Poczta <> '' THEN + ' ' + Knt_Poczta ELSE + ' ' + Knt_Miasto  END
 ELSE CASE WHEN Knt_Poczta <> '' THEN + Knt_Poczta ELSE + Knt_Miasto END END) +
    /* ADRES2 */
 CASE WHEN Knt_Adres2 <> '' THEN CHAR(13) + Knt_Adres2 ELSE '' END +
 /* WOJEWÓDZTWO */
 CASE WHEN Knt_Wojewodztwo <> '' THEN CHAR(13) + Knt_Wojewodztwo ELSE '' END +
 /* KRAJ */
    CASE WHEN Knt_Kraj <> '' THEN CHAR(13) + Knt_Kraj ELSE '' END ,
 --ADRES KORESPONDENCYJNY KONTRAHENTA
 @Kor_Adres = 'Adres korespondencyjny:',
 @Kon_Kor_Adres=
 /* ADRES */
    LTRIM(CASE WHEN isNULL(Knt_KorUlica,'') <> '' THEN Knt_KorUlica WHEN isNULL(Knt_KorUlica,'') = '' AND isNULL(Knt_KorMiasto,'') <> '' THEN Knt_KorMiasto ELSE isNULL(Knt_KorPoczta,'') END +
    CASE WHEN isNULL(Knt_KorNrDomu,'') <> '' AND isNULL(Knt_KorNrLokalu,'') <> '' THEN ' ' + Knt_KorNrDomu + '/' + Knt_KorNrLokalu WHEN isNULL(Knt_KorNrDomu,'') <> '' AND isNULL(Knt_KorNrLokalu,'') = '' THEN ' ' + Knt_KorNrDomu WHEN isNULL(Knt_KorNrDomu,'') = '' AND isNULL(Knt_KorNrLokalu,'') <> '' THEN ' ' + Knt_KorNrLokalu ELSE '' END +
    CASE WHEN isNULL(Knt_KorPoczta,'') <> isNULL(Knt_KorUlica,'')  AND isNULL(Knt_KorMiasto,'') <> isNULL(Knt_KorUlica,'') AND isNULL(Knt_KorMiasto,'') <> isNULL(Knt_KorPoczta,'') AND isNULL(Knt_KorPoczta,'') <> '' AND isNULL(Knt_KorMiasto,'') <> '' AND isNULL(Knt_KorUlica,'') <> '' THEN ', ' + Knt_KorMiasto ELSE '' END +
    CASE WHEN (isNULL(Knt_KorMiasto,'') <> '' OR isNULL(Knt_KorPoczta,'') <> '') OR (isNULL(Knt_KorUlica,'') <> '' AND isNULL(Knt_KorKodPocztowy,'') <> '') THEN + ', ' ELSE '' END
    /* POCZTA */
  + isNULL(Knt_KorKodPocztowy,'') +
    CASE WHEN isNULL(Knt_KorKodPocztowy,'') <> '' THEN
 CASE WHEN isNULL(Knt_KorPoczta,'') <> '' THEN ' ' + Knt_KorPoczta ELSE  ' ' + isNULL(Knt_KorMiasto,'') END
 ELSE CASE WHEN isNULL(Knt_KorPoczta,'') <> '' THEN + Knt_KorPoczta ELSE + isNULL(Knt_KorMiasto,'') END END) +
    /* KRAJ */
    CASE WHEN isNULL(Knt_KorKraj,'') <> '' THEN CHAR(13) + Knt_KorKraj ELSE '' END,
    --DANE KONTAKTOWE
 @Kontakt = 'Dane kontaktowe:',
 @Kon_Kontakt =
 CASE WHEN (Knt_Telefon1 <> '' OR Knt_Telefon2 <> '' OR Knt_TelefonSms <> '') THEN
 + 'Telefon:' +
 CHAR(9) + ltrim(
 CASE WHEN Knt_Telefon1 <> '' THEN + '     ' + Knt_Telefon1  ELSE '' END +
 CASE WHEN Knt_Telefon2 <> '' THEN + '     ' + Knt_Telefon2  ELSE '' END +
 CASE WHEN Knt_TelefonSms <> '' THEN + '     ' + Knt_TelefonSms ELSE '' END
 )
 ELSE '' END +
 /* FAX */
 CASE WHEN Knt_Fax <> '' THEN CHAR(13) + 'FAX: ' + CHAR(9) + Knt_Fax ELSE '' END +
 /* EMAIL */
 CASE WHEN Knt_Email <> '' THEN CHAR(13) + 'E-mail: ' + CHAR(9) + Knt_Email ELSE '' END +
 /* URL */
 CASE WHEN Knt_URL <> '' THEN CHAR(13) + 'URL: ' + CHAR(9) + Knt_URL ELSE '' END,
 --INNE DANE
 @Inne = 'Inne:',
 @Kon_inne =
    CASE WHEN Knt_GLN <> '0000000000000'AND Knt_GLN <> '' AND isNULL(Knt_LoginComarchCloud,'') <> '' THEN 'GLN: ' + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + Knt_GLN WHEN Knt_GLN <> '0000000000000' AND Knt_GLN <> '' AND isNULL(Knt_LoginComarchCloud,'') = '' THEN 'GLN: ' + CHAR(9) + Knt_GLN ELSE '' END +
    CASE WHEN isNULL(Knt_LoginComarchCloud,'') <> '' AND Knt_GLN <> '0000000000000' AND Knt_GLN <> '' THEN CHAR(13) + 'Konto Comarch Cloud: ' + CHAR(9) + Knt_LoginComarchCloud WHEN isNULL(Knt_LoginComarchCloud,'') <> '' AND (Knt_GLN = '0000000000000' OR Knt_GLN = '') THEN 'Konto Comarch Cloud: ' + ' ' + Knt_LoginComarchCloud ELSE '' END
 FROM CDN.Kontrahenci
    WHERE Knt_KntId = @Identyfikator
 --RACHUNEK
 SELECT
 @Rachunek = 'Rachunki bankowe: ',
 @Kon_Rachunek = (select TOP 1 SPL_RachunekNr from CDN.SchematPlatnosci left join CDN.BnkNazwy on SPL_BnaId = BNa_BNaId where SPL_PodmiotTyp = 1 AND SPL_PodmiotID = @Identyfikator)
 -- STOPKA
 SELECT
 @Stopka = 'Wydrukowano przy pomocy programu Comarch ERP Optima'
  END
SELECT TOP 1
 (SELECT TOP 1 DAB_Wartosc from  [CDN].[DaneBinarne] where Dab_typ = 13) [Fir_Logo],
 @Nazwa    [Nazwa],
 @Kon_Nazwa  [Kon_Nazwa],
 @Adres       [Adres],
 @Kon_Adres     [Kon_Adres],
 @Kor_Adres    [Kor_Adres],
 @Kon_Kor_Adres  [Kon_Kor_Adres],
 @Kontakt     [Kontakt],
 @Kon_Kontakt [Kon_Kontakt],
 @Inne        [Inne],
 @Kon_Inne    [Kon_Inne],
 @Rachunek    [Rachunek],
 @Kon_Rachunek [Kon_Rachunek],
 @Stopka    [Stopka]
RETURN 1;
END
