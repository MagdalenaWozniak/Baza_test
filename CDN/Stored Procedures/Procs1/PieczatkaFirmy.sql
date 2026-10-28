CREATE PROCEDURE [CDN].[PieczatkaFirmy]
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
  SET @Fir_Tytul  = 'Administrator danych osobowych:'
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
  /* TELEFON */
  (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + 'tel: ' + Fir_Wartosc ELSE '' END From CDN.Firma  Where Fir_Numer=1155)
  /* MAIL/WWW */
  SET @Fir_Mail = (SELECT Fir_Wartosc From CDN.Firma  Where Fir_Numer=2221) + (SELECT CASE WHEN Fir_Wartosc <> '' THEN CHAR(13) + Fir_Wartosc ELSE '' END From CDN.Firma Where Fir_Numer=3087)
  SELECT @Fir_Opis = Fir_Wartosc From CDN.Firma  Where Fir_Numer=1158
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
