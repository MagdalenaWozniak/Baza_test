CREATE FUNCTION cdn.CzyRozliczenieUkryte(
@KBP  TINYINT,
@OpeID  INT,
@BRKID  INT
)
  RETURNS INT
  AS
  BEGIN
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
 DECLARE @retVal INT
 SET @retVal = 0
 DECLARE @LBRaID INT
 DECLARE @LObiekt INT
 DECLARE @PBRaID INT
 DECLARE @PObiekt INT
 SELECT
  @LBRaID = BRK_LBraID, @PBRaID = BRK_PBraID,
  @LObiekt = CASE WHEN BRK_LDokTyp=1 THEN @ObiektZakazuDoKas_Zdarzenie ELSE @ObiektZakazuDoKas_Zapis END,
  @PObiekt = CASE WHEN BRK_PDokTyp=1 THEN @ObiektZakazuDoKas_Zdarzenie ELSE @ObiektZakazuDoKas_Zapis END
  FROM cdn.BnkRozKwoty WHERE BRK_BRKID = @BRKID
 IF @KBP = 0
   SET @retVal = CASE WHEN (cdn.ZakazDoRachunku(@LBRaID, @OpeID) = 1 AND cdn.ZakazDoRachunku(@PBRaID, @OpeID) = 1) THEN 1 ELSE 0 END
 ELSE
   SET @retVal = CASE WHEN (cdn.ZakazDoRachunkuPlus(@LBRaID, @OpeID, @LObiekt, @Akcja) = 1 AND cdn.ZakazDoRachunkuPlus(@PBRaID, @OpeID, @LObiekt, @Akcja) = 1) THEN 1 ELSE 0 END
    RETURN  @retVal
  END
