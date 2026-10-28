CREATE  PROCEDURE [CDN].[DaneOsobowePrzedstawiciela]
 @Identyfikator int = 0
AS
BEGIN
 DECLARE
  @Nazwisko varchar(64),
  @Przed_Nazwisko nvarchar(40),
  @Adres varchar(64),
  @Przed_Adres nvarchar(496),
  @Kontakt varchar(64),
  @Przed_Kontakt nvarchar(220),
  @Stopka varchar(64)
  --DANE Z BAZY
  IF @Identyfikator <> 0
  BEGIN
   SELECT
    --NAZWISKO PRZEDSTAWICIELA
    @Nazwisko = 'Imię i nazwisko:',
 @Przed_Nazwisko=
    /* NAZWISKO */
    CASE WHEN KnO_Nazwisko <> '' THEN KnO_Nazwisko ELSE '' END,
 --ADRES
 @Adres = 'Adres:',
 @Przed_Adres=
 /* ADRES */
    LTRIM(CASE WHEN KnO_Ulica <> '' THEN KnO_Ulica WHEN KnO_Ulica='' AND KnO_Miasto <>'' THEN KnO_Miasto ELSE KnO_Poczta END +
    CASE WHEN KnO_NrDomu <> '' AND KnO_NrLokalu <> '' THEN ' ' + KnO_NrDomu + '/' + KnO_NrLokalu WHEN KnO_NrDomu <> '' AND KnO_NrLokalu = '' THEN ' ' + KnO_NrDomu WHEN KnO_NrDomu = '' AND KnO_NrLokalu <> '' THEN ' ' + KnO_NrLokalu ELSE '' END +
    CASE WHEN KnO_Poczta <> KnO_Ulica  AND KnO_Miasto <> KnO_Ulica AND KnO_Miasto <> KnO_Poczta AND KnO_Poczta <> '' AND KnO_Miasto <> '' AND KnO_Ulica <> '' THEN ', ' + KnO_Miasto ELSE '' END +
    CASE WHEN (KnO_Miasto <> '' OR KnO_Poczta <> '') OR (KnO_Ulica <> '' AND KnO_KodPocztowy <> '') THEN + ', ' ELSE '' END +
 /* POCZTA */
  + KnO_KodPocztowy +
    CASE WHEN KnO_KodPocztowy <> '' THEN
 CASE WHEN KnO_Poczta <> '' THEN + ' ' + KnO_Poczta ELSE + ' ' + KnO_Miasto  END
 ELSE CASE WHEN KnO_Poczta <> '' THEN + KnO_Poczta ELSE + KnO_Miasto END END) +
    /* ADRES2 */
 CASE WHEN KnO_Adres2 <> '' THEN CHAR(13) + KnO_Adres2 ELSE '' END +
 /* WOJEWÓDZTWO */
 CASE WHEN KnO_Wojewodztwo <> '' THEN CHAR(13) + KnO_Wojewodztwo ELSE '' END +
 /* KRAJ */
    CASE WHEN KnO_Kraj <> '' THEN CHAR(13) + KnO_Kraj ELSE '' END ,
 --DANE KONTAKTOWE
 @Kontakt = 'Dane kontaktowe:',
 @Przed_Kontakt =
 CASE WHEN (KnO_Telefon <> '' OR KnO_GSM <> '' OR KnO_TelefonSms <> '') THEN
 + 'Telefon:' +
 CHAR(9) + ltrim(
 CASE WHEN KnO_Telefon <> '' THEN + '     ' + KnO_Telefon  ELSE '' END +
 CASE WHEN KnO_GSM <> '' THEN + '     ' + KnO_GSM  ELSE '' END +
 CASE WHEN KnO_TelefonSms <> '' THEN + '     ' + KnO_TelefonSms ELSE '' END
 )
 ELSE '' END +
  /* EMAIL */
 CASE WHEN (KnO_Telefon <> '' OR KnO_GSM <> '' OR KnO_TelefonSms <> '') THEN
 CASE WHEN KnO_Email <> '' THEN CHAR(13) + 'E-mail: ' + CHAR(9) + KnO_Email ELSE '' END
 ELSE CASE WHEN KnO_Email <> '' THEN 'E-mail: ' + CHAR(9) + KnO_Email ELSE '' END END
 FROM CDN.KntOsoby
    WHERE KnO_KnOId = @Identyfikator
 -- STOPKA
 SELECT
 @Stopka = 'Wydrukowano przy pomocy programu Comarch ERP Optima'
  END
SELECT TOP 1
 (SELECT TOP 1 DAB_Wartosc from  [CDN].[DaneBinarne] where Dab_typ = 13) [Fir_Logo],
 @Nazwisko     [Nawisko],
 @Przed_Nazwisko  [Przed_Nazwisko],
 @Adres       [Adres],
 @Przed_Adres     [Przed_Adres],
 @Kontakt     [Kontakt],
 @Przed_Kontakt [Przed_Kontakt],
 @Stopka    [Stopka]
RETURN 1;
END
