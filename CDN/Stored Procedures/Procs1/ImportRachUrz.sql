CREATE PROCEDURE CDN.ImportRachUrz
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@TypRach int,
@BNa_Numer nvarchar(20),
@BNa_ImportRowId nvarchar(36),
@URa_RachunekNr nvarchar(51),
@URa_IBAN smallint,
@Urz_ImportRowId nvarchar(36),
@Urz_Typ smallint,
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
SET NOCOUNT ON
BEGIN
 DECLARE @BNa_Id int
 DECLARE @URa_Lp int
 SET @Warnings = ''
 IF(@BNa_ImportRowId is not NULL OR @BNa_Numer is not NULL)
 BEGIN
  SET @BNa_Id = NULL
  SELECT @BNa_Id = BNa_BNaId
  FROM CDN.BnkNazwy
  WHERE BNa_ImportRowId = @BNa_ImportRowId
  IF @BNa_Id is NULL
   SELECT @BNa_Id = BNa_BNaId
   FROM CDN.BnkNazwy
   WHERE BNa_Numer = @BNa_Numer
  IF (@BNa_Id is NULL)
   --SET @Warnings = 'Brak banku ' + IsNull(@BNa_Numer, '') + ' w bazie docelowej. Bank nie został zaimportowany.\'
   SET @Warnings = '##OPT33198##%%nrb%%=' +  IsNull(@BNa_Numer, '') + '##\';
 END
  IF @TypRach > 100
    SELECT @URa_Lp = @TypRach % 100
  ELSE
    SELECT @URa_Lp = CASE WHEN @TypRach <= 4 THEN @TypRach WHEN @TypRach >= 5 AND @TypRach <= 8 THEN @TypRach - 4 ELSE 1 END
 --DECLARE @Zmiana INT
 --SET @Zmiana = 0
 IF((SELECT count(*)
  FROM CDN.UrzRachunki
  WHERE URa_UrzId = @SlowId and URa_Lp = @URa_Lp)=0)
 BEGIN
  INSERT INTO CDN.UrzRachunki
  (
  URa_UrzId,
  URa_Lp,
  URa_BNaId,
  URa_RachunekNr,
  URa_IBAN
  )
  VALUES
  (
  @SlowId,
  @URa_Lp,
  @BNa_Id,
  @URa_RachunekNr,
  @URa_IBAN
  )
  --SET @Zmiana = 1
 END
 ELSE IF (@OnlyNew <> 1)
 BEGIN
  UPDATE CDN.UrzRachunki
  SET
  URa_UrzId = @SlowId,
  URa_Lp = @URa_Lp,
  URa_BNaId = @BNa_Id,
  URa_RachunekNr = @URa_RachunekNr,
  URa_IBAN = @URa_IBAN
  WHERE URa_UrzId = @SlowId and URa_Lp = @URa_Lp
  --SET @Zmiana = 1
 END
 /*
 IF @Zmiana = 1
 BEGIN
  DECLARE @Urz_Akronim NVARCHAR(32)
  DECLARE @Urz_Nazwa1 NVARCHAR(256)
  SELECT @Urz_Akronim = Urz_Akronim, @Urz_Nazwa1 = Urz_Nazwa1 FROM cdn.Urzedy WHERE Urz_UrzID = @SlowID
  DECLARE @Opis NVARCHAR(256)
  SELECT @Opis = @Urz_Nazwa1 + ' PR - dodanie rachunku'
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1105, -- OptimaObjectType_Urzad
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Urz_Akronim,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = '' -- @Opis
 END
 */
END
