CREATE PROCEDURE CDN.ImportAtr
@OnlyNew int,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@DeA_Typ tinyint,
@DeA_Kod nvarchar(20),
@DeA_Nazwa nvarchar(40),
@DeA_ImportRowId nvarchar(36),
@DeA_Format smallint,
@DeA_Zalezny tinyint,
@DeA_CzykopiowacFa tinyint,
@DeA_CzykopiowacDoVat tinyint,
@DeA_CzyKod tinyint,
@DeA_CzyPrzenosic tinyint,
@DeA_CzyDrukowac tinyint,
@DeA_CzyPrzenosicNaDostawy tinyint,
@DeA_CzyObowiązkowyDostawy tinyint,
@DeA_JPKDostepnyFA tinyint,
@DeA_JPKDostepnyVAT tinyint,
@DeA_JPKDostepnyFAVAT tinyint,
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
 IF (@DeA_Typ=4 AND EXISTS(SELECT * FROM CDN.DefAtrybuty WHERE Dea_Kod=@Dea_Kod AND Dea_Typ=5 ) )
 BEGIN
  SELECT @SlowId = Dea_DeaID FROM CDN.DefAtrybuty WHERE Dea_Kod=@Dea_Kod AND Dea_Typ=5
  RETURN
 END
 IF( (SELECT count(*)
  FROM CDN.DefAtrybuty
  WHERE (IsNull(@DeA_ImportRowId, '') <> '' AND  DeA_ImportRowId = @DeA_ImportRowId)
    OR (IsNull(@DeA_ImportRowId, '') = '' AND DeA_Kod = @DeA_Kod)) = 0 )
 BEGIN
  INSERT INTO CDN.DefAtrybuty
  (
   DeA_Typ,
   DeA_Kod,
   DeA_Nazwa,
   DeA_ImportRowId,
   DeA_Format,
   DeA_Zalezny,
   DeA_CzykopiowacFa,
   DeA_CzykopiowacDoVat,
   DeA_CzyKod,
   DeA_CzyPrzenosic,
   DeA_CzyDrukowac,
   DeA_CzyPrzenosicNaDostawy,
   DeA_CzyObowiazkowyDostawy,
   DeA_JPKDostepnyFA,
   DeA_JPKDostepnyVAT,
   DeA_JPKDostepnyFAVAT,
   DeA_OpeZalID,
   DeA_OpeZalKod,
   DeA_OpeZalNazwisko,
   DeA_StaZalId,
   DeA_TS_Zal,
   DeA_OpeModID,
   DeA_OpeModKod,
   DeA_OpeModNazwisko,
   DeA_StaModId,
   DeA_TS_Mod,
   DeA_TS_Export,
   DeA_ImportAppId
  )
  VALUES
  (
   @DeA_Typ,
   @DeA_Kod,
   @DeA_Nazwa,
   @DeA_ImportRowId,
   @DeA_Format,
   @DeA_Zalezny,
   @DeA_CzykopiowacFa,
   @DeA_CzykopiowacDoVat,
   @DeA_CzyKod,
   @DeA_CzyPrzenosic,
   @DeA_CzyDrukowac,
   @DeA_CzyPrzenosicNaDostawy,
   @DeA_CzyObowiązkowyDostawy,
   ISNULL(@DeA_JPKDostepnyFA,0),
   ISNULL(@DeA_JPKDostepnyVAT,0),
   ISNULL(@DeA_JPKDostepnyFAVAT,0),
   @OpeId,  --DeA_OpeZalID,
   @OpeModKod,
   @OpeModNazwisko,
   NULL,  --DeA_StaZalId,
   GETDATE(), --DeA_TS_Zal,
   @OpeId,  --DeA_OpeModID,
   @OpeModKod,
   @OpeModNazwisko,
   NULL,  --DeA_StaModId,
   GETDATE(), --DeA_TS_Mod,
   GETDATE(),
   @ZrdId
  )
  SET @SlowId = SCOPE_IDENTITY()
  SET @OperationType = 1 -- OptimaOperationType_Dodanie
 END
 ELSE
 BEGIN
  IF(@OnlyNew <> 1)
  BEGIN
   SELECT @SlowId = DeA_DeAId FROM CDN.DefAtrybuty WHERE DeA_ImportRowId = @DeA_ImportRowId
   IF EXISTS(SELECT *
      FROM CDN.DokAtrybuty
      WHERE DAt_DeAId = @SlowId)
    OR
    EXISTS(SELECT *
      FROM CDN.KntAtrybuty
       WHERE KNa_DeAId = @SlowId)
   BEGIN
    SELECT @SlowId = DeA_DeAId FROM CDN.DefAtrybuty WHERE (IsNull(@DeA_ImportRowId, '') <> '' AND  DeA_ImportRowId = @DeA_ImportRowId) OR (IsNull(@DeA_ImportRowId, '') = '' AND DeA_Kod = @DeA_Kod)
    UPDATE CDN.DefAtrybuty
    SET
    DeA_Kod = @DeA_Kod,
    DeA_Nazwa = @DeA_Nazwa,
    DeA_Zalezny = @DeA_Zalezny,
    DeA_CzykopiowacFa = @DeA_CzykopiowacFa,
    DeA_CzykopiowacDoVat = @DeA_CzykopiowacDoVat,
    DeA_CzyKod = @DeA_CzyKod,
    DeA_CzyPrzenosic = @DeA_CzyPrzenosic,
    DeA_CzyDrukowac = @DeA_CzyDrukowac,
    DeA_JPKDostepnyFA = ISNULL(@DeA_JPKDostepnyFA,0),
    DeA_JPKDostepnyVAT = ISNULL(@DeA_JPKDostepnyVAT,0),
    DeA_JPKDostepnyFAVAT = ISNULL(@DeA_JPKDostepnyFAVAT,0),
    DeA_OpeModID = @OpeId,
    DeA_OpeModKod = @OpeModKod,
    DeA_OpeModNazwisko = @OpeModNazwisko,
    DeA_StaModId = NULL,
    DeA_TS_Mod = GETDATE()
    WHERE DeA_DeAId = @SlowId
   END
   ELSE
   BEGIN
    SELECT @SlowId = DeA_DeAId FROM CDN.DefAtrybuty WHERE (IsNull(@DeA_ImportRowId, '') <> '' AND  DeA_ImportRowId = @DeA_ImportRowId) OR (IsNull(@DeA_ImportRowId, '') = '' AND DeA_Kod = @DeA_Kod)
    UPDATE CDN.DefAtrybuty
    SET
    DeA_Kod = @DeA_Kod,
    DeA_Nazwa = @DeA_Nazwa,
    DeA_Format = @DeA_Format,
    DeA_Zalezny = @DeA_Zalezny,
    DeA_CzykopiowacFa = @DeA_CzykopiowacFa,
    DeA_CzykopiowacDoVat = @DeA_CzykopiowacDoVat,
    DeA_CzyKod = @DeA_CzyKod,
    DeA_CzyPrzenosic = @DeA_CzyPrzenosic,
    DeA_CzyDrukowac = @DeA_CzyDrukowac,
    DeA_JPKDostepnyFA = ISNULL(@DeA_JPKDostepnyFA,0),
    DeA_JPKDostepnyVAT = ISNULL(@DeA_JPKDostepnyVAT,0),
    DeA_JPKDostepnyFAVAT = ISNULL(@DeA_JPKDostepnyFAVAT,0),
    DeA_OpeModID = @OpeId,
    DeA_OpeModKod = @OpeModKod,
    DeA_OpeModNazwisko = @OpeModNazwisko,
    DeA_StaModId = NULL,
    DeA_TS_Mod = GETDATE()
    WHERE DeA_DeAId = @SlowId
   END
   SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
  END
  ELSE
   RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 END
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 24207, -- OptimaObjectType_DefAtrybut
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @DeA_Kod,
    @OperacjaTyp = @OperationType,
    @Opis = ''
END
