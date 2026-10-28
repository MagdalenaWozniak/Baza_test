CREATE FUNCTION cdn.NumerDokumentuRozliczenia(
@KBP    TINYINT,
@BlokPrac   TINYINT,
@BlokTylkoWynagr TINYINT,
@OpeID    INT,
@BRKID    INT,
@LP     TINYINT
)
  RETURNS NVARCHAR(256)
  AS
  BEGIN
 DECLARE @NoInfo VARCHAR(3)
 SET @NoInfo = '-' + '--'
 DECLARE @e_op_TypDokumentuKB_Zdarzenie INT
 SET @e_op_TypDokumentuKB_Zdarzenie = 1
 DECLARE @e_op_TypDokumentuKB_Zapis INT
 SET @e_op_TypDokumentuKB_Zapis = 2
 DECLARE @e_op_TypPodmiotuPracownik INT
 SET @e_op_TypPodmiotuPracownik = 3
 DECLARE @e_op_TypPodmiotuWspolnik INT
 SET @e_op_TypPodmiotuWspolnik = 4
   DECLARE @AkcjaZakazuDoKas_Podglad INT
 SET @AkcjaZakazuDoKas_Podglad = 2
 DECLARE @ObiektZakazuDoKas_Rejestr INT
 SET @ObiektZakazuDoKas_Rejestr = 1
 DECLARE @ObiektZakazuDoKas_Raport INT
 SET @ObiektZakazuDoKas_Raport = 2
 DECLARE @ObiektZakazuDoKas_Zdarzenie INT
 SET @ObiektZakazuDoKas_Zdarzenie = 3
 DECLARE @ObiektZakazuDoKas_Zapis INT
 SET @ObiektZakazuDoKas_Zapis = 4
 DECLARE @Akcja INT
 SET @Akcja = @AkcjaZakazuDoKas_Podglad
 DECLARE @retVal NVARCHAR(256)
 SET @retVal = @NoInfo
 DECLARE @LBRaID INT
 DECLARE @PBRaID INT
 DECLARE @LObiekt INT
 DECLARE @PObiekt INT
 DECLARE @LDokTyp INT
 DECLARE @PDokTyp INT
 DECLARE @LDokID INT
 DECLARE @PDokID INT
 DECLARE @LPodTyp INT
 DECLARE @PPodTyp INT
 DECLARE @LWynag TINYINT
 DECLARE @PWynag TINYINT
 DECLARE @LNumer NVARCHAR(256)
 DECLARE @PNumer NVARCHAR(256)
 SELECT
  @LBRaID = BRK_LBraID, @PBRaID = BRK_PBraID,
  @LObiekt = CASE WHEN BRK_LDokTyp=1 THEN @ObiektZakazuDoKas_Zdarzenie ELSE @ObiektZakazuDoKas_Zapis END,
  @PObiekt = CASE WHEN BRK_PDokTyp=1 THEN @ObiektZakazuDoKas_Zdarzenie ELSE @ObiektZakazuDoKas_Zapis END,
  @LDokTyp = BRK_LDokTyp, @PDokTyp = BRK_PDokTyp, @LDokID = BRK_LDokID, @PDokID = BRK_PDokID,
  @LPodTyp = BRK_LPodTyp, @PPodTyp = BRK_PPodTyp, @LWynag = BRK_LWynagrodzenie, @PWynag = BRK_PWynagrodzenie,
  @LNumer = BRK_LNumer, @PNumer = BRK_PNumer
  FROM cdn.BnkRozKwoty WHERE BRK_BRKID = @BRKID
 IF @BlokPrac <> 0
 BEGIN
  IF @LPodTyp=@e_op_TypPodmiotuPracownik OR @LPodTyp=@e_op_TypPodmiotuWspolnik
   SET @LNumer = @NoInfo
  IF @PPodTyp=@e_op_TypPodmiotuPracownik OR @PPodTyp=@e_op_TypPodmiotuWspolnik
   SET @PNumer = @NoInfo
 END
 IF @BlokTylkoWynagr <> 0
 BEGIN
  IF @LWynag<>0
   SET @LNumer = @NoInfo
  IF @PWynag<>0
   SET @PNumer = @NoInfo
 END
 DECLARE @LP2 INT
 SET @LP2 = 0
 DECLARE @LNumerDisp NVARCHAR(256)
 DECLARE @PNumerDisp NVARCHAR(256)
 IF @LDokTyp <> @PDokTyp
 BEGIN
   IF @LDokTyp = @e_op_TypDokumentuKB_Zdarzenie
   BEGIN
     SET @LNumerDisp = @LNumer
     SET @PNumerDisp = @PNumer
     SET @LP2 = 1
   END
   ELSE
   BEGIN
     SET @LNumerDisp = @PNumer
     SET @PNumerDisp = @LNumer
     SET @LP2 = -1
   END
 END
 ELSE
 BEGIN
   DECLARE @Kierunek INT
   IF @LDokTyp = @e_op_TypDokumentuKB_Zdarzenie
   BEGIN
     SELECT @Kierunek = IsNull(BZd_Kierunek, 0) FROM cdn.BnkZdarzenia WHERE BZd_BZdID = @LDokID
     IF @Kierunek < 0 -- Lewy to rozchód
     BEGIN
       SET @LNumerDisp = @LNumer
       SET @PNumerDisp = @PNumer
       SET @LP2 = 1
     END
     ELSE   -- Lewy to przychód
     BEGIN
       SET @LNumerDisp = @PNumer
       SET @PNumerDisp = @LNumer
       SET @LP2 = -1
     END
   END
   ELSE
   BEGIN
     SELECT @Kierunek = IsNull(BZp_Kierunek, 0) FROM cdn.BnkZapisy WHERE BZp_BZpID = @LDokID
     IF @Kierunek < 0 -- Lewy to rozchód
     BEGIN
       SET @LNumerDisp = @LNumer
       SET @PNumerDisp = @PNumer
       SET @LP2 = 1
     END
     ELSE   -- Lewy to przychód
     BEGIN
       SET @LNumerDisp = @PNumer
       SET @PNumerDisp = @LNumer
       SET @LP2 = -1
     END
   END
 END
  DECLARE @zakazL INT
  DECLARE @zakazP INT
 IF @KBP = 0
    BEGIN
      IF @LP2 = 1
   BEGIN
     SELECT @zakazL = COUNT(*) FROM cdn.BnkRachZakazy WHERE BRZ_OpeID = @OpeID AND BRZ_BRaID = @LBRaID
     SELECT @zakazP = COUNT(*) FROM cdn.BnkRachZakazy WHERE BRZ_OpeID = @OpeID AND BRZ_BRaID = @PBRaID
   END
   ELSE IF @LP2 = -1
   BEGIN
     SELECT @zakazP = COUNT(*) FROM cdn.BnkRachZakazy WHERE BRZ_OpeID = @OpeID AND BRZ_BRaID = @LBRaID
     SELECT @zakazL = COUNT(*) FROM cdn.BnkRachZakazy WHERE BRZ_OpeID = @OpeID AND BRZ_BRaID = @PBRaID
   END
   ELSE
   BEGIN
     SELECT @zakazL = COUNT(*) FROM cdn.BnkRachZakazy WHERE BRZ_OpeID = @OpeID AND BRZ_BRaID = @LBRaID
     SELECT @zakazP = COUNT(*) FROM cdn.BnkRachZakazy WHERE BRZ_OpeID = @OpeID AND BRZ_BRaID = @PBRaID
   END
    END
 ELSE
 BEGIN
   SET @zakazL = 0
   SET @zakazP = 0
   DECLARE @zakazTmpL INT
    DECLARE @zakazTmpP INT
   SELECT @zakazTmpL = cdn.ZakazDoRachunkuPlus(@LBRaID, @OpeID, @LObiekt, @Akcja)
   SELECT @zakazTmpP = cdn.ZakazDoRachunkuPlus(@PBRaID, @OpeID, @PObiekt, @Akcja)
   IF @zakazTmpL <> 0
   BEGIN
     IF @LP2 = 1
       SET @zakazL = 1
     ELSE IF @LP2 = -1
       SET @zakazP = 1
     ELSE
     BEGIN
       SET @zakazL = 1
       SET @zakazP = 1
     END
   END
   IF @zakazTmpP <> 0
   BEGIN
     IF @LP2 = 1
       SET @zakazP = 1
     ELSE IF @LP2 = -1
       SET @zakazL = 1
     ELSE
     BEGIN
       SET @zakazL = 1
       SET @zakazP = 1
     END
   END
 END
 IF @zakazL <> 0
   SET @LNumerDisp = @NoInfo
 IF @zakazP <> 0
   SET @PNumerDisp = @NoInfo
 IF @LP = 1
   SET @retVal = @LNumerDisp
 ELSE
   SET @retVal = @PNumerDisp
    RETURN  @retVal
  END
