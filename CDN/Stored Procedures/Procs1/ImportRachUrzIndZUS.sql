CREATE PROCEDURE CDN.ImportRachUrzIndZUS
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@BNa_ImportRowId nvarchar(36),
@BNa_Numer nvarchar(20),
@URa_RachunekNr nvarchar(51),
@URa_IBAN smallint,
@Pra_ImportRowId nvarchar(36),
@Pra_Kod nvarchar(20),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
SET NOCOUNT ON
BEGIN
 DECLARE @BNa_Id int
 DECLARE @Pra_Id int
 SET @Warnings = ''
 SET @BNa_Id = NULL
 IF(@BNa_ImportRowId is not NULL OR @BNa_Numer is not NULL)
 BEGIN
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
 SET @Pra_Id = NULL
 IF(@Pra_ImportRowId is not NULL OR @Pra_Kod is not NULL)
 BEGIN
  SELECT @Pra_Id = Pra_PraId
  FROM CDN.PracKod
  WHERE PRA_ImportRowId = @Pra_ImportRowId
  IF @Pra_Id is NULL
   SELECT @Pra_Id = Pra_PraId
   FROM CDN.PracKod
   WHERE Pra_Kod = @Pra_Kod
  IF (@Pra_Id is NULL)
   -- SET @Warnings = 'Brak pracownika ' + IsNull(@Pra_Kod, '') + ' w bazie docelowej. Pracownik nie został zaimportowany.\'
   SET @Warnings = '##OPT33199##%%kod%%=' +  IsNull(@Pra_Kod, '') + '##\';
 END
 --DECLARE @Zmiana INT
 --SET @Zmiana = 0
 IF((SELECT count(*)
  FROM CDN.UrzRachunki
  WHERE URa_UrzId = @SlowId AND URa_Lp = 0 AND (@Pra_Id Is Null AND URa_PraID Is Null OR @Pra_Id Is NOT Null AND URa_PraID = @Pra_ID))=0)
 BEGIN
  INSERT INTO CDN.UrzRachunki
  (
  URa_UrzId,
  URa_Lp,
  URa_BNaId,
  URa_RachunekNr,
  URa_IBAN,
  URa_PraID
  )
  VALUES
  (
  @SlowId,
  0,
  @BNa_Id,
  @URa_RachunekNr,
  @URa_IBAN,
  @Pra_Id
  )
  --SET @Zmiana = 1
 END
 ELSE IF (@OnlyNew <> 1)
 BEGIN
  UPDATE CDN.UrzRachunki
  SET
  URa_BNaId = @BNa_Id,
  URa_RachunekNr = @URa_RachunekNr,
  URa_IBAN = @URa_IBAN
  WHERE URa_UrzId = @SlowId AND URa_Lp = 0 AND (@Pra_Id Is Null AND URa_PraID Is Null OR @Pra_Id Is NOT Null AND URa_PraID = @Pra_ID)
  --SET @Zmiana = 1
 END
 /*
 IF @Zmiana = 1
 BEGIN
  DECLARE @Urz_Kod NVARCHAR(32)
  DECLARE @Urz_Nazwa1 NVARCHAR(256)
  SELECT @Urz_Kod = Urz_Kod, @Urz_Nazwa1 = Urz_Nazwa1 FROM cdn.Urzedy WHERE Urz_UrzID = @SlowID
  DECLARE @Opis NVARCHAR(256)
  SELECT @Opis = @Urz_Nazwa1 + ' PR - dodanie rachunku'
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1105, -- OptimaObjectType_Urzad
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Urz_Kod,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = @Opis
 END
 */
END
