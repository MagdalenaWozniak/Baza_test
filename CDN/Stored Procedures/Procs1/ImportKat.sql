CREATE PROCEDURE CDN.ImportKat
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Kat_ImportRowId nvarchar(36),
@Kat_KodOgolny nvarchar(20),
@Kat_KodSzczegol nvarchar(20),
@Kat_Poziom smallint,
@Kat_Typ smallint,
@Kat_Opis nvarchar(50),
@Kat_Stawka decimal(5,2),
@Kat_Flaga smallint,
@Kat_KolumnaKPIR tinyint,
@Kat_KolumnaRycz tinyint,
@Kat_Odliczenia smallint,
@Kat_PodzielOdliczenia tinyint,
@Kat_PodzielOdliczeniaProcent decimal(5,2),
@Kat_RodzajZakupu smallint,
@Kat_Fiskalny tinyint,
@Kat_Detal tinyint,
@Kat_Budzet decimal(15,2),
@Kat_Nieaktywny tinyint,
@Kat_ElixirO1 nvarchar(35),
@Kat_ElixirO2 nvarchar(35),
@Kat_ElixirO3 nvarchar(35),
@Kat_ElixirO4 nvarchar(35),
@Kat_KontoSegmentWN nvarchar(50),
@Kat_KontoSegmentMA nvarchar(50),
@Kat_KsiegujWKoszty tinyint,
@Kat_KsiegujWKosztyProcent decimal(5,2),
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
 IF @Kat_PodzielOdliczeniaProcent Is Null
  SET @Kat_PodzielOdliczeniaProcent = 50
 IF @Kat_KsiegujWKoszty Is Null
  SET @Kat_KsiegujWKoszty = 0
 IF @Kat_KsiegujWKosztyProcent Is Null
  SET @Kat_KsiegujWKosztyProcent = 75
  IF((SELECT count(*)
    FROM CDN.Kategorie
    WHERE (IsNull(@Kat_ImportRowId, '') <> '' AND  Kat_ImportRowId = @Kat_ImportRowId)
        OR (IsNull(@Kat_ImportRowId, '') = '' AND Kat_KodSzczegol = @Kat_KodSzczegol)) = 0)
  BEGIN
    INSERT INTO CDN.Kategorie
    (
    Kat_ImportRowId,
    Kat_KodOgolny,
    Kat_KodSzczegol,
    Kat_Poziom,
    Kat_Typ,
    Kat_Opis,
    Kat_Stawka,
    Kat_Flaga,
    Kat_KolumnaKPIR,
    Kat_KolumnaRycz,
    Kat_Odliczenia,
    Kat_PodzielOdliczenia,
    Kat_PodzielOdliczeniaProcent,
    Kat_RodzajZakupu,
    Kat_Fiskalny,
    Kat_Detal,
    Kat_Budzet,
    Kat_Nieaktywny,
    Kat_ElixirO1,
    Kat_ElixirO2,
    Kat_ElixirO3,
    Kat_ElixirO4,
    Kat_KontoSegmentWN,
    Kat_KontoSegmentMA,
    Kat_KsiegujWKoszty,
    Kat_KsiegujWKosztyProcent,
    Kat_TS_Zal,
    Kat_TS_Mod,
    Kat_Udzial,
    Kat_Kwota,
    Kat_Zrodlowa,
    Kat_OpeModID,
 Kat_OpeModKod,
 Kat_OpeModNazwisko,
    Kat_OpeZalID,
 Kat_OpeZalKod,
 Kat_OpeZalNazwisko,
    Kat_TS_Export,
    Kat_ImportAppId
    )
    VALUES
    (
    @Kat_ImportRowId,
    @Kat_KodOgolny,
    @Kat_KodSzczegol,
    @Kat_Poziom,
    @Kat_Typ,
    @Kat_Opis,
    @Kat_Stawka,
    @Kat_Flaga,
    @Kat_KolumnaKPIR,
    @Kat_KolumnaRycz,
    @Kat_Odliczenia,
    @Kat_PodzielOdliczenia,
    @Kat_PodzielOdliczeniaProcent,
    @Kat_RodzajZakupu,
    @Kat_Fiskalny,
    @Kat_Detal,
    @Kat_Budzet,
    @Kat_Nieaktywny,
    @Kat_ElixirO1,
    @Kat_ElixirO2,
    @Kat_ElixirO3,
    @Kat_ElixirO4,
    @Kat_KontoSegmentWN,
    @Kat_KontoSegmentMA,
    @Kat_KsiegujWKoszty,
    @Kat_KsiegujWKosztyProcent,
    GETDATE(),
    GETDATE(),
    0,
    0,
    0,
    @OpeId,
 @OpeModKod,
 @OpeModNazwisko,
    @OpeId,
 @OpeModKod,
 @OpeModNazwisko,
    GETDATE(),
    @ZrdId
    )
 SET @SlowId = SCOPE_IDENTITY()
 SET @OperationType = 1 -- OptimaOperationType_Dodanie
  END
  ELSE IF(@OnlyNew <> 1)
  BEGIN
    DECLARE @OLD_WN nvarchar(50), @OLD_MA nvarchar(50)
    SELECT @SlowID = Kat_KatID, @OLD_WN = Kat_KontoSegmentWN, @OLD_MA = Kat_KontoSegmentMA
    FROM CDN.Kategorie
    WHERE (IsNull(@Kat_ImportRowId, '') <> '' AND  Kat_ImportRowId = @Kat_ImportRowId)
        OR (IsNull(@Kat_ImportRowId, '') = '' AND Kat_KodSzczegol = @Kat_KodSzczegol)
    UPDATE CDN.Kategorie
    SET
    Kat_ImportRowId = @Kat_ImportRowId,
    Kat_KodOgolny = @Kat_KodOgolny,
    Kat_KodSzczegol = @Kat_KodSzczegol,
    Kat_Poziom = @Kat_Poziom,
    Kat_Typ = @Kat_Typ,
    Kat_Opis = @Kat_Opis,
    Kat_Stawka = @Kat_Stawka,
    Kat_Flaga = @Kat_Flaga,
    Kat_KolumnaKPIR = @Kat_KolumnaKPIR,
    Kat_KolumnaRycz = @Kat_KolumnaRycz,
    Kat_Odliczenia = @Kat_Odliczenia,
    Kat_PodzielOdliczenia = @Kat_PodzielOdliczenia,
    Kat_PodzielOdliczeniaProcent = @Kat_PodzielOdliczeniaProcent,
    Kat_RodzajZakupu = @Kat_RodzajZakupu,
    Kat_Fiskalny = @Kat_Fiskalny,
    Kat_Detal = @Kat_Detal,
    Kat_Budzet = @Kat_Budzet,
    Kat_Nieaktywny = @Kat_Nieaktywny,
    Kat_ElixirO1 = @Kat_ElixirO1,
    Kat_ElixirO2 = @Kat_ElixirO2,
    Kat_ElixirO3 = @Kat_ElixirO3,
    Kat_ElixirO4 = @Kat_ElixirO4,
    Kat_KontoSegmentWN = case when len(@OLD_WN) > 0 then @OLD_WN else @Kat_KontoSegmentWN end,
    Kat_KontoSegmentMA = case when len(@OLD_MA) > 0 then @OLD_MA else @Kat_KontoSegmentMA end,
    Kat_KsiegujWKoszty = @Kat_KsiegujWKoszty,
    Kat_KsiegujWKosztyProcent = @Kat_KsiegujWKosztyProcent,
    Kat_TS_Mod = GETDATE(),
    Kat_OpeModId = @OpeId,
 Kat_OpeModKod = @OpeModKod,
 Kat_OpeModNazwisko = @OpeModNazwisko
    WHERE Kat_KatID = @SlowID
 SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
  END
  ELSE
 RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 4008, -- OptimaObjectType_Kategoria
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @Kat_KodSzczegol,
    @OperacjaTyp = @OperationType,
    @Opis = '' --@Kat_Opis
END
