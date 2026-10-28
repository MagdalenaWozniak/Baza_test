CREATE FUNCTION CDN.StatusRozliczeniaPR(@WartoscWPliku INT, @PodmiotTyp INT, @PodmiotID INT, @DataDok DATETIME)
RETURNS INT
AS
BEGIN
 DECLARE @ConfPRUstPlatNiePodl INT
 SELECT @ConfPRUstPlatNiePodl = CONVERT(INT, Fir_Wartosc, 0) FROM cdn.Firma WHERE Fir_Numer = 1874
 SELECT @ConfPRUstPlatNiePodl = IsNull(@ConfPRUstPlatNiePodl, 0)
 IF @ConfPRUstPlatNiePodl = 1
  RETURN 0
 DECLARE @RetVal INT
 SET @RetVal = 1
 DECLARE @ConfPRStatImpPlatWgPliku INT
 SET @ConfPRStatImpPlatWgPliku = 0
 IF @WartoscWPliku Is Not Null
 BEGIN
  SELECT @ConfPRStatImpPlatWgPliku = CONVERT(INT, Fir_Wartosc, 0) FROM cdn.Firma WHERE Fir_Numer = 3086
  SELECT @ConfPRStatImpPlatWgPliku = IsNull(@ConfPRStatImpPlatWgPliku, 0)
 END
    IF @WartoscWPliku Is Not Null AND @ConfPRStatImpPlatWgPliku = 1
  SET @RetVal = (CASE WHEN @WartoscWPliku > 1 THEN 1 ELSE @WartoscWPliku END)
 ELSE
    BEGIN
      DECLARE @NieRozl INT
      SET @NieRozl = 0
      IF @PodmiotTyp = 1
        Select Top 1 @NieRozl = Knt_NieRozliczac From CDN.Kontrahenci Where Knt_KntID = @PodmiotID
      ELSE IF @PodmiotTyp = 2
        Select Top 1 @NieRozl = BNa_NieRozliczac From CDN.BnkNazwy Where BNa_BNaId = @PodmiotID
      ELSE IF @PodmiotTyp = 3
        --Select Top 1 @NieRozl = PRE_NieRozliczac From CDN.PracEtaty Where PRE_PRAID = @PodmiotID And PRE_DataDo = Convert(DateTime, '2999-12-31', 120)
  Select Top 1 @NieRozl = PRE_NieRozliczac From CDN.PracEtaty Where PRE_PRAID = @PodmiotID And @DataDok BETWEEN PRE_DataOd AND PRE_DataDo
      ELSE IF @PodmiotTyp = 5
        Select Top 1 @NieRozl = Urz_NieRozliczac From CDN.Urzedy Where Urz_UrzID = @PodmiotID
      IF IsNull(@NieRozl, 0) <> 0
        SET @RetVal = 0
   ELSE
     SET @RetVal = 1
    END
 RETURN @RetVal
END
