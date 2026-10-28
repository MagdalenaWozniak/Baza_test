CREATE PROCEDURE CDN.ImportZak
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Zak_ImportRowId nvarchar(36),
@Zak_Symbol nvarchar(30),
@Zak_NazwaFirmy nvarchar(250),
@Zak_NipKraj varchar(2),
@Zak_NipE nvarchar(20),
@Zak_Regon varchar(20),
@Zak_NazwaZakladu nvarchar(250),
@Zak_Ulica nvarchar(40),
@Zak_NrDomu nvarchar(10),
@Zak_NrLokalu nvarchar(10),
@Zak_Miejscowosc nvarchar(40),
@Zak_Poczta nvarchar(40),
@Zak_KodPocztowy varchar(10),
@Zak_Nieaktywny tinyint,
--@Zak_Domyslny tinyint,
-- @Zak_Pierwszy tinyint,
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @OperationType INT
 SET @OperationType = 0
  IF((SELECT count(*)
    FROM CDN.Zaklady
    WHERE ((IsNull(@Zak_ImportRowId, '') <> '' AND  Zak_ImportRowId = @Zak_ImportRowId) OR Zak_Symbol = @Zak_Symbol)
        OR (IsNull(@Zak_ImportRowId, '') = '' AND Zak_Symbol = @Zak_Symbol)) = 0)
  BEGIN
    INSERT INTO CDN.Zaklady
    (
    Zak_ImportRowId,
    Zak_Symbol,
    Zak_NazwaFirmy,
    Zak_NipKraj,
    Zak_NipE,
    Zak_Regon,
    Zak_NazwaZakladu,
    Zak_Ulica,
    Zak_NrDomu,
    Zak_NrLokalu,
    Zak_Miejscowosc,
    Zak_Poczta,
    Zak_KodPocztowy,
    Zak_Nieaktywny,
    Zak_Domyslny,
    Zak_Pierwszy,
    Zak_TS_Zal,
    Zak_TS_Mod,
    Zak_OpeModID,
 Zak_OpeModKod,
 Zak_OpeModNazwisko,
    Zak_OpeZalID,
 Zak_OpeZalKod,
 Zak_OpeZalNazwisko,
    Zak_TS_Export,
    Zak_ImportAppId
    )
    VALUES
    (
    @Zak_ImportRowId,
    @Zak_Symbol,
    @Zak_NazwaFirmy,
    @Zak_NipKraj,
    @Zak_NipE,
    @Zak_Regon,
    @Zak_NazwaZakladu,
    @Zak_Ulica,
    @Zak_NrDomu,
    @Zak_NrLokalu,
    @Zak_Miejscowosc,
    @Zak_Poczta,
    @Zak_KodPocztowy,
    @Zak_Nieaktywny,
    0, -- @Zak_Domyslny,
    0, -- @Zak_Pierwszy,
    GETDATE(),
    GETDATE(),
    @OpeId,
 @OpeModKod,
 @OpeModNazwisko,
    @OpeId,
 @OpeModKod,
 @OpeModNazwisko,
    GETDATE(),
    @ZrdId
    )
 SELECT @SlowID = SCOPE_IDENTITY()
 SET @OperationType = 1 -- OptimaOperationType_Dodanie
  END
  ELSE IF(@OnlyNew <> 1)
  BEGIN
 SELECT @SlowID = Zak_ZakID FROM CDN.Zaklady
  WHERE (IsNull(@Zak_ImportRowId, '') <> '' AND  Zak_ImportRowId = @Zak_ImportRowId)
   OR (IsNull(@Zak_ImportRowId, '') = '' AND Zak_Symbol = @Zak_Symbol)
    UPDATE CDN.Zaklady
    SET
    Zak_ImportRowId = @Zak_ImportRowId,
    Zak_Symbol = @Zak_Symbol,
    Zak_NazwaFirmy = @Zak_NazwaFirmy,
    Zak_NipKraj = @Zak_NipKraj,
    Zak_NipE = @Zak_NipE,
    Zak_Regon = @Zak_Regon,
    Zak_NazwaZakladu = @Zak_NazwaZakladu,
    Zak_Ulica = @Zak_Ulica,
    Zak_NrDomu = @Zak_NrDomu,
    Zak_NrLokalu = @Zak_NrLokalu,
    Zak_Miejscowosc = @Zak_Miejscowosc,
    Zak_Poczta = @Zak_Poczta,
    Zak_KodPocztowy = @Zak_KodPocztowy,
    Zak_Nieaktywny = @Zak_Nieaktywny,
    Zak_Domyslny = 0, --@Zak_Domyslny,
    Zak_Pierwszy = 0, --@Zak_Pierwszy,
    Zak_TS_Mod = GETDATE(),
    Zak_OpeModId = @OpeId,
 Zak_OpeModKod = @OpeModKod,
 Zak_OpeModNazwisko = @OpeModNazwisko
    WHERE Zak_ZakID = @SlowID
 SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
  END
  ELSE
 RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1152, -- OptimaObjectType_Zaklad
    @ObiektSubTyp = 1,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Zak_Symbol,
    @OperacjaTyp = @OperationType,
    @Opis = ''
END
