CREATE PROCEDURE CDN.ImportRaportKB
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@BRp_ImportRowId nvarchar(36),
@BRa_Symbol nvarchar(5),
@BRa_ImportRowId nvarchar(36),
@BRp_DataDok nvarchar(10),
@BRp_DataZam nvarchar(10),
@DDf_Symbol nvarchar(5),
@DDf_ImportRowID nvarchar(36),
@BRp_NumerPelny nvarchar(30),
@BRp_NumerNr int,
@BRp_NumerObcy nvarchar(256),
@przych decimal(15, 2),
@rozchod decimal(15, 2),
@saldo decimal(15, 2),
@przychodSys decimal(15, 2),
@rozchodSys decimal(15, 2),
@saldoSys decimal(15, 2),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
  DECLARE @BrpID INT
  SELECT @BRpID = IsNull(BRp_BRpID, 0) FROM cdn.BnkRaporty WHERE BRp_ImportRowId = @BRp_ImportRowId
  IF @BRpID <> 0
  BEGIN
    DECLARE @maPrawo INT
    EXEC CDN.GetOpeIntProp @ServerName, @ConfigDBName, @OpeID, @maPrawo OUTPUT
    IF @maPrawo <> 0
      SET @IdParam = @BRpID
    ELSE
      RAISERROR('##OPT33066##', 16, 1) --RAISERROR('Operator nie ma prawa do importu zapisów k/b do istniejących raportów.', 16, 1)
    RETURN
  END
 DECLARE @BRaId int,
  @BRa_DDfID int,
  @DDfId int,
  @schemat nvarchar(50),
  @DDfErr  nvarchar(50)
 SET @DDfId = NULL
 SET @schemat = NULL
 SET @BraId = NULL
 SELECT @BRaId = BRa_BRaId, @BRa_DDfID = BRa_DDfID
 FROM CDN.BnkRachunki
 WHERE BRa_Symbol = @BRa_Symbol
 IF @BRaId is NULL
  RAISERROR('##OPT33067##', 16, 1) --RAISERROR('Brak rejestru kasowego/bankowego w bazie dla tego raportu.', 16, 1)
 SET @DDfId = CDN.GetDDfIDFromRowIDOrSymbol(@DDf_ImportRowId, @DDf_Symbol);
 IF(@DDfId is NULL) OR (@DDfId = 0)
 BEGIN
    SELECT @DDfId = @BRa_DDfID, @DDf_Symbol=DDf_Symbol FROM CDN.DokDefinicje WHERE DDf_DDfID=@BRa_DDfID
    IF(@DDf_Symbol is NULL) OR (@DDf_Symbol = '')
   RAISERROR('##OPT33068##', 16, 1) --RAISERROR('Nieprawidłowy symbol dokumentu.', 16, 1)
  END
 SELECT @schemat = DDf_Numeracja
 FROM CDN.DokDefinicje
 WHERE @DDfId = DDf_DDfId
 IF @DDfId is NULL
 BEGIN
  SET @DDfErr = 'Brak definicji dokumentu ' + @DDf_Symbol + ' w bazie.'
  RAISERROR('##OPT33057##%%symbol%%=%s##', 16, 1, @DDf_Symbol) --RAISERROR(@DDfErr, 16, 1)
  RETURN
 END
 IF @schemat is NULL
 BEGIN
  RAISERROR('##OPT33070##', 16, 1) --RAISERROR('Nie znaleziono schematu numeracji w bazie', 16, 1)
  RETURN
 END
 INSERT INTO CDN.BnkRaporty
 (BRp_BRaID,
 BRp_DDfID,
 BRp_NumerNr,
 BRp_NumerString,
 BRp_NumerObcy,
 BRp_DataDok,
 BRp_DataZam,
 BRp_Zamkniety,
 BRp_SaldoBO,
 BRp_Przychody,
 BRp_Rozchody,
 BRp_SaldoBOSys,
 BRp_PrzychodySys,
 BRp_RoznicaKursowaSysMW,
 BRp_RozchodySys,
 BRp_ImportRowId,
 BRp_ImportAppId,
 BRp_OpeZalID,
 BRp_OpeZalKod,
 BRp_OpeZalNazwisko,
 BRp_StaZalId,
 BRp_TS_Zal,
 BRp_OpeModID,
 BRp_OpeModKod,
 BRp_OpeModNazwisko,
 BRp_StaModId,
 BRp_TS_Mod)
 VALUES
 (
 @BRaId,
 @DDfId,
 @BRp_NumerNr,
 CDN.GetDokNumString(@schemat, @BRp_NumerPelny),
 @BRp_NumerObcy,
 convert(datetime, @BRp_DataDok, 120),
 convert(datetime, @BRp_DataZam, 120),
 0,
 0,
 0,
 0,
 0,
 0,
 0,
 0,
 @BRp_ImportRowId,
 @ZrdId,
 @OpeId,
 @OpeModKod,
 @OpeModNazwisko,
 NULL,
 GETDATE(),
 @OpeId,
 @OpeModKod,
 @OpeModNazwisko,
 NULL,
 GETDATE()
 )
 SET @IdParam = SCOPE_IDENTITY()
 DECLARE @NumerDok NVARCHAR(256)
 SET @NumerDok = (SELECT BRp_NumerPelny FROM cdn.BnkRaporty WHERE BRp_BRpID = @IdParam)
 EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 1122, -- OptimaObjectType_RaportKB
   @ObiektSubTyp = 0,
   @ObiektID = @IdParam,
   @ObiektNazwa = @NumerDok,
   @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
   @Opis = ''
END
