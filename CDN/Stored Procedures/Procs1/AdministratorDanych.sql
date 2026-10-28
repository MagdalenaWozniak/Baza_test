CREATE PROCEDURE [CDN].[AdministratorDanych]
AS
BEGIN
 DECLARE
  @Fir_Tytul varchar(128),
  @Fir_Nazwa nvarchar(2048),
  @Fir_Ulica varchar(64),
  @Fir_NrBud varchar(64),
  @Fir_NrLok varchar(64),
  @Fir_Miasto varchar(64),
  @Fir_Poczta varchar(64),
  @Fir_Nip varchar(32),
  @Fir_Regon varchar(32),
  @Fir_Mail varchar(256),
  @Fir_Opis varchar(512),
  @Fir_FirJ varchar(16),
  @FirJ_Tytul  varchar(128),
  @FirJ_Nazwa  nvarchar(2048),
  @FirJ_Ulica  varchar(64),
  @FirJ_NrBud  varchar(64),
  @FirJ_NrLok  varchar(64),
  @FirJ_Miasto varchar(64),
  @FirJ_Poczta varchar(64),
  @FirJ_Nip  varchar(4),
  @FirJ_Mail  varchar(256)
 BEGIN
  SET @Fir_Nip = ''
  SET @Fir_Regon = ''
  END
  --DANE PIECZĄTKI--
  SET @Fir_NrBud  = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=3133)
  SET @Fir_NrLok  = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=3134)
  SET @Fir_NrBud  = (SELECT ' ' + CASE WHEN @Fir_NrBud <> '' AND @Fir_NrLok <> '' THEN @Fir_NrBud + '/' + @Fir_NrLok WHEN @Fir_NrBud <> '' AND @Fir_NrLok = '' THEN @Fir_NrBud ELSE @Fir_NrLok END)
  SET @Fir_Miasto = (SELECT CASE WHEN Fir_Wartosc <> '' THEN ' ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=3129)
  SET @Fir_Poczta = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=3130)
  SET @Fir_Ulica  = (SELECT CASE WHEN Fir_Wartosc <> '' THEN Fir_Wartosc WHEN Fir_Wartosc='' AND @Fir_Miasto <>'' THEN @Fir_Miasto ELSE @Fir_Poczta END From CDN.Firma  Where Fir_Numer=3132)
  SET @Fir_Poczta = CASE WHEN @Fir_Poczta <> '' THEN ' ' + @Fir_Poczta ELSE @Fir_Miasto END
  SET @Fir_Miasto = CASE WHEN @Fir_Miasto = @Fir_Poczta AND @Fir_Miasto <> '' THEN '' WHEN @Fir_Miasto <> @Fir_Poczta AND @Fir_Miasto <> '' AND @Fir_Miasto <> @Fir_Ulica AND @Fir_Poczta <> @Fir_Ulica THEN ', ' + @Fir_Miasto ELSE '' END
  SET @Fir_Tytul  = 'Administrator danych osobowych:'
  SET @Fir_Nazwa  =
  /* NAZWA */
  (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=3127) +
  --(SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1157) +
  --(SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=2166) +
  /* ADRES */
  CHAR(13) + @Fir_Ulica + @Fir_NrBud + @Fir_Miasto +
  /* POCZTA */
  (SELECT CHAR(13) + Fir_Wartosc From CDN.Firma  Where Fir_Numer=3131) +
  @Fir_Poczta +
  /* KRAJ */
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=3128) +
  /* NIP */
  @Fir_Nip +
  /* REGON */
  @Fir_Regon +
  /* TELEFON */
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'tel: ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=3135)
  /* MAIL/WWW */
  SET @Fir_Mail = (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=3136)
  SET @Fir_Opis = ''
  SET @FirJ_Tytul  = ''
  SET @FirJ_Nazwa = ''
  SET @FirJ_Mail = ''
SELECT TOP 1
 (SELECT TOP 1 DAB_Wartosc from  [CDN].[DaneBinarne] where Dab_typ = 13) [Fir_Logo],
 @Fir_Tytul    [Fir_Tytul],
 @Fir_Nazwa    [Fir_Nazwa],
 @Fir_Mail    [Fir_Mail],
 @Fir_Opis    [Fir_Opis],
 @FirJ_Tytul    [FirJ_Tytul],
 @FirJ_Nazwa    [FirJ_Nazwa],
 @FirJ_Mail    [FirJ_Mail]
RETURN 1;
END
