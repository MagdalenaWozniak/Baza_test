CREATE PROCEDURE CDN.ImportPrzedstaw
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@KnO_Nazwisko nvarchar(40),
@KnO_Imie nvarchar(20),
@KnO_Tytul nvarchar(20),
@KnO_Plec tinyint,
@KnO_Kraj nvarchar(40),
@KnO_Wojewodztwo nvarchar(40),
@KnO_Powiat nvarchar(40),
@KnO_Gmina nvarchar(40),
@KnO_Ulica nvarchar(40),
@KnO_NrDomu nvarchar(10),
@KnO_NrLokalu nvarchar(10),
@KnO_Miasto nvarchar(40),
@KnO_KodPocztowy nvarchar(10),
@KnO_Poczta nvarchar(40),
@KnO_Adres2 nvarchar(256),
@KnO_Telefon nvarchar(20),
@KnO_Gsm nvarchar(20),
@KnO_EMail nvarchar(40),
@KnO_Domyslny tinyint,
@KnO_Informacje tinyint,
@KnO_Mailing tinyint,
@KnO_Nieaktywny tinyint,
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
  IF @KnO_Mailing Is Null
    SET @KnO_Mailing = 1
 INSERT
 INTO CDN.KntOsoby (
      KnO_KntId,
      KnO_Tytul,
      KnO_Plec,
      KnO_Nazwisko,
      KnO_Kraj,
      KnO_Wojewodztwo,
      KnO_Powiat,
      KnO_Gmina,
      KnO_Ulica,
      KnO_NrDomu,
      KnO_NrLokalu,
      KnO_Miasto,
      KnO_KodPocztowy,
      KnO_Poczta,
      KnO_Adres2,
      KnO_Telefon,
      KnO_GSM,
      KnO_Email,
      KnO_Informacje,
      KnO_Domyslny,
     KnO_Mailing,
     KnO_Nieaktywny)
  VALUES(
   @SlowId,
      @KnO_Tytul,
      @KnO_Plec,
      @KnO_Nazwisko,
      @KnO_Kraj,
      @KnO_Wojewodztwo,
      @KnO_Powiat,
      @KnO_Gmina,
      @KnO_Ulica,
      @KnO_NrDomu,
      @KnO_NrLokalu,
      @KnO_Miasto,
      @KnO_KodPocztowy,
      @KnO_Poczta,
      @KnO_Adres2,
      @KnO_Telefon,
      @KnO_GSM,
      @KnO_Email,
      @KnO_Informacje,
      @KnO_Domyslny,
     @KnO_Mailing,
     @KnO_Nieaktywny)
  IF(@KnO_Domyslny = 1)
  BEGIN
   UPDATE CDN.Kontrahenci
   SET
   Knt_OsTytul = isnull(@KnO_Tytul, ''),
   Knt_OsPlec = @KnO_Plec,
   Knt_OsNazwisko = isnull(@KnO_Nazwisko, ''),
   Knt_OsKraj = @KnO_Kraj,
   Knt_OsWojewodztwo = @KnO_Wojewodztwo,
   Knt_OsPowiat = @KnO_Powiat,
   Knt_OsGmina = @KnO_Gmina,
   Knt_OsUlica = @KnO_Ulica,
   Knt_OsNrDomu = @KnO_NrDomu,
   Knt_OsNrLokalu = @KnO_NrLokalu,
   Knt_OsMiasto = @KnO_Miasto,
   Knt_OsKodPocztowy = @KnO_KodPocztowy,
   Knt_OsPoczta = @KnO_Poczta,
   Knt_OsAdres2 = @KnO_Adres2,
   Knt_OsTelefon = @KnO_Telefon,
   Knt_OsGSM = @KnO_Gsm,
   Knt_OsEmail = @KnO_EMail
   WHERE Knt_KntId = @SlowId
  END
  /*
    UPDATE CDN.KntOsoby
  SET  KnO_KntId = (SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_ImportRowId = @Knt_ImportRowId),
   KnO_Tytul = @KnO_Tytul,
      KnO_Plec = @KnO_Plec,
      KnO_Nazwisko = @KnO_Nazwisko,
      KnO_Kraj = @KnO_Kraj,
      KnO_Wojewodztwo = @KnO_Wojewodztwo,
      KnO_Powiat = @KnO_Powiat,
      KnO_Gmina = @KnO_Gmina,
      KnO_Ulica = @KnO_Ulica,
      KnO_NrDomu = @KnO_NrDomu,
      KnO_NrLokalu = @KnO_NrLokalu,
      KnO_Miasto = @KnO_Miasto,
      KnO_KodPocztowy = @KnO_KodPocztowy,
      KnO_Poczta = @KnO_Poczta,
      KnO_Adres2 = @KnO_Adres2,
      KnO_Telefon = @KnO_Telefon,
      KnO_GSM = @KnO_GSM,
      KnO_Email = @KnO_Email,
      KnO_Informacje = @KnO_Informacje,
      KnO_Domyslny = @KnO_Domyslny
  WHERE Kno_KnoId = @Kno_KnoId
  */
  /*
 EXEC CDN.RejestrOperacjiZapiszKontrahenta
   @ID = @SlowID,
   @Kod = '',
   @TypOperacji = 2
  */
END
