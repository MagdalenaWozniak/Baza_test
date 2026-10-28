CREATE  PROCEDURE CDN.ImportDokDef
@OnlyNew int,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@DDf_ImportRowId nvarchar(36),
@DDf_Klasa nvarchar(50),
@DDf_Symbol nvarchar(5),
@DDf_Nazwa nvarchar(20),
@DDf_Numeracja nvarchar(50),
@DDf_SeriaOperatora tinyint,
@DDf_Nieaktywna tinyint,
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
 DECLARE @KlasaNumer int
 SET @KlasaNumer = CDN.GetKlasaNumer(@DDf_Klasa)
 SET @DDf_Nieaktywna = ISNULL(@DDf_Nieaktywna, 0);
 IF(
       (SELECT COUNT(*) FROM CDN.DokDefinicje WHERE @DDf_ImportRowID IS NOT NULL  AND DDf_ImportRowID=@DDf_ImportRowID) = 0
  AND
    (SELECT count(*) FROM CDN.DokDefinicje WHERE DDf_Symbol = @DDf_Symbol AND DDf_Numeracja = @DDf_Numeracja) = 0
   )
 BEGIN
  IF EXISTS (SELECT DDf_Symbol FROM CDN.DokDefinicje WHERE DDf_Symbol=@DDf_Symbol AND DDf_Nieaktywna = 0 AND @DDf_Nieaktywna = 0)
   RAISERROR('##OPT33086##', 16, 1) --RAISERROR('Jest aktywny schemat numeracji o takim symbolu. Nie można zaimportować schematu.', 16,1);
  INSERT INTO [CDN].[DokDefinicje]
  (
   DDf_Klasa,
   DDf_Symbol,
   DDf_Nazwa,
   DDf_Numeracja,
   DDf_SeriaOperatora,
   DDf_Nieaktywna,
   DDf_ImportRowId,
   DDf_TS_Zal,
   DDf_TS_Mod,
   DDf_OpeModID,
   DDf_OpeModKod,
   DDf_OpeModNazwisko,
   DDf_OpeZalID,
   DDf_OpeZalKod,
   DDf_OpeZalNazwisko,
   DDf_TS_Export,
   DDf_ImportAppId
  )
  VALUES
  (
   @KlasaNumer,
   @DDf_Symbol,
   @DDf_Nazwa,
   @DDf_Numeracja,
   @DDf_SeriaOperatora,
   @DDf_Nieaktywna,
   ISNULL(@DDf_ImportRowID, NewId()),
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
 ELSE
 BEGIN
  if(@OnlyNew <> 1)
  BEGIN
   SET @SlowID = NULL
   IF (SELECT COUNT(*) FROM CDN.DokDefinicje WHERE @DDf_ImportRowID IS NOT NULL AND DDf_ImportRowID=@DDf_ImportRowID) > 0
    SELECT @SlowID = DDf_DDfID FROM CDN.DokDefinicje WHERE DDf_ImportRowID = @DDf_ImportRowID
   ELSE IF (SELECT count(*) FROM CDN.DokDefinicje WHERE DDf_Symbol = @DDf_Symbol AND DDf_Numeracja = @DDf_Numeracja ) > 0
    SELECT @SlowID = DDf_DDfID FROM CDN.DokDefinicje WHERE DDf_Symbol = @DDf_Symbol AND DDf_Numeracja = @DDf_Numeracja
   IF @SlowID Is NOT NULL
    UPDATE CDN.DokDefinicje
    SET
    DDf_Klasa = @KlasaNumer,
    DDf_Symbol = @DDf_Symbol,
    DDf_Nazwa = @DDf_Nazwa,
    DDf_Numeracja = @DDf_Numeracja,
    DDf_SeriaOperatora = @DDf_SeriaOperatora,
    DDf_Nieaktywna = @DDf_Nieaktywna,
    DDf_TS_Mod = GETDATE(),
    DDf_OpeModId = @OpeId,
    DDf_OpeModKod = @OpeModKod,
    DDf_OpeModNazwisko = @OpeModNazwisko,
    DDf_ImportRowID = @DDf_ImportRowID
    WHERE DDf_DDfID = @SlowID
   SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
  END
  ELSE
   RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 END
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 4004, -- OptimaObjectType_DefinicjaDokumentu
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @DDf_Symbol,
    @OperacjaTyp = @OperationType,
    @Opis = '' --@DDf_Numeracja
END
