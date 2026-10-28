CREATE PROCEDURE CDN.SrTDodajAktualizujDokumentPT
@TypAkcji     SMALLINT,
@SrTID      INT,
@DataOpe     DATETIME,
@OpeID      INT,
@StaID      INT,
@DataOd      DATETIME,
@DataDo      DATETIME,
@PrcID2      INT,
@PrcImieNazwisko2 NVARCHAR(255),
@MUNazwa2     NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @stTyp INT
 DECLARE @stGrupa VARCHAR(20)
 DECLARE @stLp INT
 DECLARE @stKatID INT
 DECLARE @stKategoria VARCHAR(50)
 DECLARE @SrT_WBudowie TINYINT
 DECLARE @NewSrHID INT
 DECLARE @SrH_Numer NVARCHAR(256)
 DECLARE @SrH_Kategoria NVARCHAR(256)
 SELECT @stTyp = SrT_Typ, @stGrupa = SrT_Grupa, @stLp = SrT_Lp, @stKatID = SrT_KatID, @stKategoria = SrT_Kategoria, @SrT_WBudowie = SrT_WBudowie
  FROM cdn.Trwale WHERE SrT_SrTID = @SrTID
 DECLARE
  @SrH_KwotaKoszt Decimal (15, 2),
 @SrH_KwotaBilan Decimal (15, 2),
 @SrH_KwotaUm Decimal (15, 2),
 @SrH_KwotaAm Decimal (15, 2)
  Set @SrH_KwotaKoszt = 0
  Set @SrH_KwotaBilan = 0
  Set @SrH_KwotaUm    = 0
  Set @SrH_KwotaAm    = 0
  If @SrT_WBudowie = 0
    Select
    @SrH_KwotaKoszt = IsNull( Sum (SrH_KwotaKoszt), 0),
    @SrH_KwotaBilan = IsNull( Sum (SrH_KwotaBilan), 0),
    @SrH_KwotaUm    = IsNull( Sum (SrH_KwotaUm), 0),
    @SrH_KwotaAm    = IsNull( Sum (SrH_KwotaAm), 0)
    From CDN.TrwaleHist Where SrH_SrTId = @SrTID And Not (SrH_TypDokumentu=6 OR SrH_Rodzaj<>0) AND SrH_DataOpe <= @DataOpe
  Else
    Select
    @SrH_KwotaKoszt = IsNull( Sum (SrTP_Kwota), 0),
    @SrH_KwotaBilan = IsNull( Sum (SrTP_Kwota), 0)
    From CDN.TrwalePowiazania Where SrTP_SrTId = @SrTID AND SrTP_DataDok <= @DataOpe
 DECLARE
 @PrcID1 INT,
 @PrcImieNazwisko1 NVARCHAR(255),
 @MUNazwa1 NVARCHAR(255),
 @Opis NVARCHAR(255)
 IF (@PrcID2 <> 0 AND @PrcID2 Is Not NULL) OR (@PrcImieNazwisko2 <> '' AND @PrcImieNazwisko2 Is Not NULL)
  SELECT /* TOP 1 */ @PrcID1 = SrOO_PrcID, @PrcImieNazwisko1 = SrOO_PrcImieNazwisko FROM CDN.TrwaleOsobyOdpowiedzialne
   WHERE SrOO_SrTID = @SrTID AND DATEDIFF(day, SrOO_DataDo, @DataOd) = 1 -- ORDER BY SrOO_DataDo DESC
 IF (@MUNazwa2 <> '' AND @MUNazwa2 Is Not NULL)
  SELECT /* TOP 1 */ @MUNazwa1 = SrMU_Nazwa FROM CDN.TrwaleMiejscaUzytkowania
   WHERE SrMU_SrTID = @SrTID AND DATEDIFF(day, SrMU_DataDo, @DataOd) = 1 -- ORDER BY SrMU_DataDo DESC
 DECLARE @DataOdOpis NVARCHAR(20)
 IF Year(@DataOd)>1900
 BEGIN
  DECLARE @yyyy VARCHAR(4)
  SET @yyyy = convert(varchar(4), YEAR(@DataOd), 0)
  DECLARE @mm VARCHAR(2)
  SET @mm = convert(varchar(2), MONTH(@DataOd), 0)
  IF LEN(@mm)=1
   SET @mm = '0' + @mm
  DECLARE @dd VARCHAR(2)
  SET @dd = convert(varchar(2), DAY(@DataOd), 0)
  IF LEN(@dd)=1
   SET @dd = '0' + @dd
  SET @DataOdOpis = @yyyy + '-' + @mm + '-' + @dd
 END
 IF @TypAkcji = 1 OR (@TypAkcji = 0 AND ((@PrcID2 Is Not Null AND @PrcID2 <> 0) OR (@PrcImieNazwisko2 Is Not Null AND @PrcImieNazwisko2 <> '')) AND (@MUNazwa2 = '' OR @MUNazwa2 Is NULL))
  SET @Opis = 'Zmiana osoby odpowiedzialnej'
 IF @TypAkcji = 2 OR (@TypAkcji = 0 AND ((@PrcID2 Is Null OR @PrcID2 = 0) AND (@PrcImieNazwisko2 Is Null OR @PrcImieNazwisko2 = '')) AND (@MUNazwa2 <> '' AND @MUNazwa2 Is Not NULL))
  SET @Opis = 'Zmiana miejsca użytkowania'
 IF @TypAkcji = 3 OR (@TypAkcji = 0 AND ((@PrcID2 Is Not Null AND @PrcID2 <> 0) OR (@PrcImieNazwisko2 Is Not Null AND @PrcImieNazwisko2 <> '')) AND (@MUNazwa2 <> '' AND @MUNazwa2 Is Not NULL))
  SET @Opis = 'Zmiana osoby odpowiedzialnej i miejsca użytkowania'
 IF Year(@DataOd)>1900
 BEGIN
  SET @Opis = @Opis + ' od dnia ' + @DataOdOpis
 END
  IF @TypAkcji = 0
  BEGIN
  DECLARE @DocLp VARCHAR(10)
  SELECT @DocLp = CONVERT(VARCHAR(10), ((SELECT COUNT(*) FROM cdn.TrwaleHist srh WHERE srh.SrH_SrTID = @SrTID AND srh.SrH_TypDokumentu = 6) + 1), 0)
  SELECT @SrH_Numer = 'PT/'+@stGrupa+'/'+CONVERT(VARCHAR(10), @stLp, 0)+'/'+@DocLp
  INSERT INTO cdn.TrwaleHist
  (SrH_SrTID, SrH_Typ, SrH_TypDokumentu, SrH_Rodzaj, SrH_DataOpe, SrH_Grupa, SrH_Numer,
   SrH_KwotaKoszt, SrH_KwotaBilan, SrH_KwotaUm, SrH_KwotaAm,
   SrH_KatID, SrH_Kategoria,
   SrH_Metoda, SrH_MetodaBil, SrH_Stawka, SrH_StawkaBil, SrH_Wspolczynnik, SrH_WspolczynnikBil, SrH_Ulga,
   SrH_KPRId, SrH_DekId, SrH_PreDekID,
   SrH_DataPrzekazaniaOd, SrH_DataPrzekazaniaDo,
   SrH_PrcID1, SrH_PrcImieNazwisko1, SrH_MiejsceUzytkowania1, SrH_PrcID2, SrH_PrcImieNazwisko2, SrH_MiejsceUzytkowania2,
   SrH_Opis,
   SrH_OpeZalID, SrH_OpeZalKod, SrH_OpeZalNazwisko, SrH_StaZalId, SrH_TS_Zal, SrH_OpeModID,SrH_OpeModKod,SrH_OpeModNazwisko, SrH_StaModId, SrH_TS_Mod)
   VALUES
   (@SrTID, @stTyp, 6, 0, @DataOpe, @stGrupa,
   @SrH_Numer,
   @SrH_KwotaKoszt, @SrH_KwotaBilan, @SrH_KwotaUm, @SrH_KwotaAm,
   @stKatID, @stKategoria,
   0, 0, 0, 0, 0, 0, 0,
   NULL, NULL, NULL,
   @DataOd, @DataDo, @PrcID1, @PrcImieNazwisko1, @MUNazwa1, @PrcID2, @PrcImieNazwisko2, @MUNazwa2,
   @Opis,
   @OpeID, @OpeModKod, @OpeModNazwisko, @StaID, GETDATE(), @OpeID, @OpeModKod, @OpeModNazwisko, @StaID, GETDATE())
  SELECT @NewSrHID = SCOPE_IDENTITY()
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1007, -- OptimaObjectType_DokumentST
    @ObiektSubTyp = 6, -- PT
    @ObiektID = @NewSrHID,
    @ObiektNazwa = @SrH_Numer,
    @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
    @Opis = ''
  END
  ELSE
  BEGIN
   IF @TypAkcji = 1
    UPDATE cdn.TrwaleHist
     SET
     SrH_PrcID1 = @PrcID1, SrH_PrcImieNazwisko1 = @PrcImieNazwisko1, SrH_MiejsceUzytkowania1 = @MUNazwa1,
     SrH_PrcID2 = @PrcID2, SrH_PrcImieNazwisko2 = @PrcImieNazwisko2, SrH_MiejsceUzytkowania2 = NULL,
     SrH_KwotaKoszt = @SrH_KwotaKoszt, SrH_KwotaBilan = @SrH_KwotaBilan, SrH_KwotaUm = @SrH_KwotaUm, SrH_KwotaAm = @SrH_KwotaAm,
     SrH_Opis = CASE WHEN (
                ((@PrcID1 Is Not Null OR @PrcImieNazwisko1 Is Not Null OR @PrcID2 Is Not Null OR @PrcImieNazwisko2 Is Not Null) AND
                 (SrH_PrcID1 Is Null AND SrH_PrcImieNazwisko1 Is Null AND SrH_PrcID2 Is Null AND SrH_PrcImieNazwisko2 Is Null)) OR
                ((@PrcID1 Is Null AND @PrcImieNazwisko1 Is Null AND @PrcID2 Is Null AND @PrcImieNazwisko2 Is Null) AND
                 (SrH_PrcID1 Is Not Null OR SrH_PrcImieNazwisko1 Is Not Null OR SrH_PrcID2 Is Not Null OR SrH_PrcImieNazwisko2 Is Not Null)) OR
                ((@MUNazwa1 Is Not Null OR @MUNazwa2 Is Not Null) AND (SrH_MiejsceUzytkowania1 Is Null AND SrH_MiejsceUzytkowania2 Is Null)) OR
                ((SrH_MiejsceUzytkowania1 Is Not Null OR SrH_MiejsceUzytkowania2 Is Not Null) AND (@MUNazwa1 Is Null AND @MUNazwa2 Is Null))
                )
                THEN @Opis ELSE SrH_Opis END
     WHERE SrH_SrTID = @SrTID AND SrH_TypDokumentu = 6 AND
      (SrH_DataPrzekazaniaOd = @DataOd OR SrH_DataPrzekazaniaOd Is Null AND @DataOd Is Null) AND
      (SrH_DataPrzekazaniaDo = @DataDo OR SrH_DataPrzekazaniaDo Is Null AND @DataDo Is Null)
   IF @TypAkcji = 2
    UPDATE cdn.TrwaleHist
     SET
     SrH_PrcID1 = @PrcID1, SrH_PrcImieNazwisko1 = @PrcImieNazwisko1, SrH_MiejsceUzytkowania1 = @MUNazwa1,
     SrH_PrcID2 = NULL, SrH_PrcImieNazwisko2 = NULL, SrH_MiejsceUzytkowania2 = @MUNazwa2,
     SrH_KwotaKoszt = @SrH_KwotaKoszt, SrH_KwotaBilan = @SrH_KwotaBilan, SrH_KwotaUm = @SrH_KwotaUm, SrH_KwotaAm = @SrH_KwotaAm,
     SrH_Opis = CASE WHEN (
                ((@PrcID1 Is Not Null OR @PrcImieNazwisko1 Is Not Null OR @PrcID2 Is Not Null OR @PrcImieNazwisko2 Is Not Null) AND
                 (SrH_PrcID1 Is Null AND SrH_PrcImieNazwisko1 Is Null AND SrH_PrcID2 Is Null AND SrH_PrcImieNazwisko2 Is Null)) OR
                ((@PrcID1 Is Null AND @PrcImieNazwisko1 Is Null AND @PrcID2 Is Null AND @PrcImieNazwisko2 Is Null) AND
                 (SrH_PrcID1 Is Not Null OR SrH_PrcImieNazwisko1 Is Not Null OR SrH_PrcID2 Is Not Null OR SrH_PrcImieNazwisko2 Is Not Null)) OR
                ((@MUNazwa1 Is Not Null OR @MUNazwa2 Is Not Null) AND (SrH_MiejsceUzytkowania1 Is Null AND SrH_MiejsceUzytkowania2 Is Null)) OR
                ((SrH_MiejsceUzytkowania1 Is Not Null OR SrH_MiejsceUzytkowania2 Is Not Null) AND (@MUNazwa1 Is Null AND @MUNazwa2 Is Null))
                )
                THEN @Opis ELSE SrH_Opis END
     WHERE SrH_SrTID = @SrTID AND SrH_TypDokumentu = 6 AND
      (SrH_DataPrzekazaniaOd = @DataOd OR SrH_DataPrzekazaniaOd Is Null AND @DataOd Is Null) AND
      (SrH_DataPrzekazaniaDo = @DataDo OR SrH_DataPrzekazaniaDo Is Null AND @DataDo Is Null)
   IF @TypAkcji = 3
    UPDATE cdn.TrwaleHist
     SET
     SrH_PrcID1 = @PrcID1, SrH_PrcImieNazwisko1 = @PrcImieNazwisko1, SrH_MiejsceUzytkowania1 = @MUNazwa1,
     SrH_PrcID2 = @PrcID2, SrH_PrcImieNazwisko2 = @PrcImieNazwisko2, SrH_MiejsceUzytkowania2 = @MUNazwa2,
     SrH_KwotaKoszt = @SrH_KwotaKoszt, SrH_KwotaBilan = @SrH_KwotaBilan, SrH_KwotaUm = @SrH_KwotaUm, SrH_KwotaAm = @SrH_KwotaAm,
     SrH_Opis = CASE WHEN (
                (SrH_PrcID1 Is Null AND SrH_PrcImieNazwisko1 Is Null AND (@PrcID1 Is Not Null OR @PrcImieNazwisko1 Is Not Null)) OR
                (SrH_PrcID2 Is Null AND SrH_PrcImieNazwisko2 Is Null AND (@PrcID2 Is Not Null OR @PrcImieNazwisko2 Is Not Null)) OR
                (SrH_MiejsceUzytkowania1 Is Null AND @MUNazwa1 Is Not Null) OR
                (SrH_MiejsceUzytkowania2 Is Null AND @MUNazwa2 Is Not Null)
                )
                THEN @Opis ELSE SrH_Opis END
     WHERE SrH_SrTID = @SrTID AND SrH_TypDokumentu = 6 AND
      (SrH_DataPrzekazaniaOd = @DataOd OR SrH_DataPrzekazaniaOd Is Null AND @DataOd Is Null) AND
      (SrH_DataPrzekazaniaDo = @DataDo OR SrH_DataPrzekazaniaDo Is Null AND @DataDo Is Null)
   IF @TypAkcji = 1 OR @TypAkcji = 2 OR @TypAkcji = 3
   BEGIN
    CREATE TABLE #SrHIDs (SrHID INT)
    INSERT INTO #SrHIDs (SrHID) SELECT SrH_SrHID FROM cdn.TrwaleHist WHERE SrH_SrTID = @SrTID AND SrH_TypDokumentu = 6 AND
     (SrH_DataPrzekazaniaOd = @DataOd OR SrH_DataPrzekazaniaOd Is Null AND @DataOd Is Null) AND
     (SrH_DataPrzekazaniaDo = @DataDo OR SrH_DataPrzekazaniaDo Is Null AND @DataDo Is Null)
    DECLARE @whereParam  NVARCHAR(256)
    SELECT @whereParam = 'SrH_SrHID IN (SELECT SrHID FROM #SrHIDs)'
    EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1007', @ObiektSubTyp = 'SrH_TypDokumentu', @ObiektID = 'SrH_SrHID', @ObiektNazwa = 'SrH_Numer',
         @OperacjaTyp = 2, @Opis = '''''', @From = 'cdn.TrwaleHist', @Where = @whereParam
    DROP TABLE #SrHIDs
   END
  END
  SET NOCOUNT OFF
END
