CREATE PROCEDURE CDN.EcodInvoiceSummaryXml
@TrnID            AS INT
AS
BEGIN
 Declare @TotalLines  nvarchar(15),
 @TotalNetAmount   DECIMAL(15,4),
 @TotalTaxableBasis  DECIMAL(15,4),
 @TotalTaxAmount   DECIMAL(15,4),
 @TotalGrossAmount  DECIMAL(15,4),
 @PreviousTotalNetAmount   DECIMAL(15,4),
 @PreviousTotalTaxableBasis  DECIMAL(15,4),
 @PreviousTotalTaxAmount   DECIMAL(15,4),
 @PreviousTotalGrossAmount  DECIMAL(15,4),
 @CorrectionTotalNetAmount  DECIMAL(15,2),
 @CorrectionTotalTaxableBasis DECIMAL(15,2),
 @CorrectionTotalTaxAmount  DECIMAL(15,2),
 @CorrectionTotalGrossAmount  DECIMAL(15,2),
 @GrossAmountInWords  nvarchar(350),
 @TaxRate    DECIMAL(5,2),
 @TaxFlaga    SMALLINT,
 @TaxCategoryCode  nvarchar(2),
 @TaxAmount    DECIMAL(15,4),
 @TaxableAmount   DECIMAL(15,4),
 @TaxableBasis   DECIMAL(15,4),
 @GrossAmount   DECIMAL(15,4),
 @PreviousTaxRate   DECIMAL(5,2),
 @PreviousTaxFlaga   INT,
 @PreviousTaxCategoryCode nvarchar(2),
 @PreviousTaxAmount  DECIMAL(15,4),
 @PreviousTaxableAmount DECIMAL(15,4),
 --@PreviousTaxableBasis DECIMAL(15,2),
 --@PreviousGrossAmount DECIMAL(15,2),
 @CorrectionTaxAmount  DECIMAL(15,2),
 @CorrectionTaxableAmount DECIMAL(15,2),
 --@CorrectionTaxableBasis  DECIMAL(15,2),
 --@CorrectionGrossAmount  DECIMAL(15,2),
 @TrnZwrId INT,
 @Korekta INT
 SELECT @TrnZwrId = IsNull(TrN_ZwrId, 0), @Korekta = IsNull(TrN_Korekta, 0) FROM CDN.TraNag WHERE TrN_TrNID = @TrnID
 Select
  @TotalLines = Str(Count(*))
 From cdn.TraElem
 Where TrE_TrNId = @TrnID
 IF @TrnZwrId > 0   -- KOREKTA FAKTURY
 BEGIN
  SELECT
   @TotalTaxAmount = Sum(IsNull(CAST( (CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) * faKor.TrE_CenaT * faKor.TrE_Stawka/100) AS DECIMAL(15,4) ),0)),
   @TotalNetAmount = Sum(IsNull(CAST( (CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) * faKor.TrE_CenaT) AS DECIMAL(15,4) ),0)),
   @PreviousTotalTaxAmount =    Sum(IsNull(CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW), @Korekta, 5) As DECIMAL(15,4)),0)),
   @PreviousTotalNetAmount =    Sum(IsNull(CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW), @Korekta, 6) As DECIMAL(15,4)),0)),
   @PreviousTotalTaxableBasis = Sum(IsNull(CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW), @Korekta, 7) As DECIMAL(15,4)),0))
   From cdn.TraElem faKor
   Where faKor.TrE_TrnId = @TrnID
  SELECT
   @TotalTaxableBasis = Sum(IsNull(CAST( (CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) * faKor.TrE_CenaT) AS DECIMAL(15,2) ), 0) )
   From cdn.TraElem faKor
   Where faKor.TrE_TrnId = @TrnID
   AND faKor.TrE_Flaga NOT IN (1,4)
  SET @TotalGrossAmount = @TotalNetAmount + @TotalTaxAmount
  SET @GrossAmountInWords = CDN.EcodSlownie(@TotalGrossAmount)
  SET @PreviousTotalGrossAmount = @PreviousTotalNetAmount + @PreviousTotalTaxAmount
  SET @CorrectionTotalNetAmount = @TotalNetAmount - @PreviousTotalNetAmount
  SET @CorrectionTotalTaxableBasis= @TotalTaxableBasis- @PreviousTotalTaxableBasis
  SET @CorrectionTotalTaxAmount = @TotalTaxAmount - @PreviousTotalTaxAmount
  SET @CorrectionTotalGrossAmount = @TotalGrossAmount - @PreviousTotalGrossAmount
  IF @Korekta = 0
   SET @GrossAmountInWords = CDN.EcodSlownie(@TotalGrossAmount)
  ELSE
   SET @GrossAmountInWords = CDN.EcodSlownie(@CorrectionTotalGrossAmount)
  -- kursor po stawkach VAT po korekcie
  IF @Korekta = 3 -- korekta stawki VAT
  BEGIN
   DECLARE fakturaKorektaVat CURSOR FOR
   SELECT  distinct
    faKor.TrE_Stawka As TaxRate,
    faKor.TrE_Flaga  As TaxFlaga,
    Sum(IsNull(CAST( (CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) * faKor.TrE_CenaT * faKor.TrE_Stawka/100) AS DECIMAL(15,4) ),0)) As TaxAmount,
    Sum(IsNull(CAST( (CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) * faKor.TrE_CenaT) AS DECIMAL(15,4) ),0)) As TaxableAmount,
    CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,@Korekta, 3) As PreviousTaxRate,
    CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,@Korekta, 4) As INT) As PreviousTaxFlaga,
    Sum(IsNull(CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId, faKor.TrE_IloscJM, @Korekta, 5) As DECIMAL(15,4)),0)) As PreviousTaxAmount,
    Sum(IsNull(CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId, faKor.TrE_IloscJM, @Korekta, 6) As DECIMAL(15,4)),0)) As PreviousNetAmount
    From cdn.TraElem faKor
    Where faKor.TrE_TrnId = @TrnID
    GROUP BY faKor.TrE_Stawka, faKor.TrE_Flaga, CDN.EcodPrzedKorekta(faKor.TrE_TrEId, 0, @Korekta, 3), CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,  @Korekta, 4) As INT)
  END
  ELSE
  BEGIN
   IF @Korekta = 1 or @Korekta = 2 -- korekta ilości lub wartosci
   BEGIN
    DECLARE fakturaKorektaVat CURSOR FOR
    SELECT  distinct
     faKor.TrE_Stawka As TaxRate,
     faKor.TrE_Flaga  As TaxFlaga,
     Sum(IsNull(CAST( (CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) * faKor.TrE_CenaT * faKor.TrE_Stawka/100) AS DECIMAL(15,4) ),0)) As TaxAmount,
     Sum(IsNull(CAST( (CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW) * faKor.TrE_CenaT) AS DECIMAL(15,4) ),0)) As TaxableAmount,
     CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,@Korekta, 3) As PreviousTaxRate,
     CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,@Korekta, 4) As INT) As PreviousTaxFlaga,
     Sum(IsNull(CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW), @Korekta, 5) As DECIMAL(15,4)),0)) As PreviousTaxAmount,
     Sum(IsNull(CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,CDN.EcodIloscPoKorekcie(faKor.TrE_TrEId, @Korekta, faKor.TrE_IloscJM, faKor.TrE_IloscJMKW), @Korekta, 6) As DECIMAL(15,4)),0)) As PreviousNetAmount
     From cdn.TraElem faKor
     Where faKor.TrE_TrnId = @TrnID
     GROUP BY faKor.TrE_Stawka, faKor.TrE_Flaga, CDN.EcodPrzedKorekta(faKor.TrE_TrEId, 0, @Korekta, 3), CAST(CDN.EcodPrzedKorekta(faKor.TrE_TrEId,0,  @Korekta, 4) As INT)
   END
   ELSE
   BEGIN
    DECLARE fakturaTraVat CURSOR FOR
    SELECT A.TrV_Stawka As TaxRate,
     A.TrV_Flaga As TaxFlaga,
     CDN.EcodTaxCategoryCode(A.TrV_Stawka, A.TrV_Flaga, @TrnID) As TaxCategoryCode,
     A.TrV_Vat  As TaxAmount,
     A.TrV_Basis As TaxableBasis,
     A.TrV_Netto As TaxableAmount,
     A.TrV_Brutto As GrossAmount
    FROM CDN.VatPrzedKorekta(@TrnID, @TrnZwrId, 1)  A
    JOIN  CDN.VatPrzedKorekta(0, @TrnID, 0)    B    --aby byly tylko te stawki, ktore sa na korekcie
    ON A.TrV_Stawka = B.TrV_Stawka AND A.TrV_Flaga = B.TrV_Flaga
   END
  END
 END
 ELSE   -- ZWYKŁA FAKTURA
 BEGIN
  SELECT
   @TotalNetAmount  = Sum(IsNull(TrV_Netto,0)),
   @TotalTaxableBasis = Sum(IsNull(TrV_Basis,0)),
   @TotalTaxAmount  = Sum(IsNull(TrV_Vat,0)),
   @TotalGrossAmount = Sum(IsNull(TrV_Brutto,0)),
   @GrossAmountInWords = CDN.EcodSlownie(Sum(IsNull(TrV_Brutto,0)))
  FROM
   CDN.VatPrzedKorekta(0, @TrnID, 1)
  -- kursor po stawkach VAT
  DECLARE fakturaTraVat CURSOR FOR
  SELECT TrV_Stawka As TaxRate,
    TrV_Flaga As TaxFlaga,
    CDN.EcodTaxCategoryCode(TrV_Stawka, TrV_Flaga, @TrnID) As TaxCategoryCode,
    TrV_Vat  As TaxAmount,
    TrV_Basis As TaxableBasis,
    TrV_Netto As TaxableAmount,
    TrV_Brutto As GrossAmount
  FROM  CDN.VatPrzedKorekta(0, @TrnID, 1)
 END
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice-Summary', '', -1)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TotalLines',   LTrim(IsNull(@TotalLines,0)), 0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TotalNetAmount',  LTrim(Str(IsNull(Round(@TotalNetAmount,2),0),15,2)), 0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TotalTaxableBasis', LTrim(Str(IsNull(Round(@TotalTaxableBasis,2),0),15,2)), 0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TotalTaxAmount',  LTrim(Str(IsNull(Round(@TotalTaxAmount,2),0),15,2)), 0)
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TotalGrossAmount', LTrim(Str(IsNull(Round(@TotalGrossAmount,2),0),15,2)), 0)
        -- tu korekta BEGIN
  IF @TrnZwrId > 0   -- KOREKTA FAKTURY
  BEGIN
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTotalNetAmount',  LTrim(Str(IsNull(Round(@PreviousTotalNetAmount,2),0),15,2)), 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTotalTaxableBasis', LTrim(Str(IsNull(Round(@PreviousTotalTaxableBasis,2),0),15,2)), 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTotalTaxAmount',  LTrim(Str(IsNull(Round(@PreviousTotalTaxAmount,2),0),15,2)), 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTotalGrossAmount', LTrim(Str(IsNull(Round(@PreviousTotalGrossAmount,2),0),15,2)), 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionTotalNetAmount', LTrim(Str(IsNull(@CorrectionTotalNetAmount,0),15,2)), 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionTotalTaxableBasis',LTrim(Str(IsNull(@CorrectionTotalTaxableBasis,0),15,2)), 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionTotalTaxAmount', LTrim(Str(IsNull(@CorrectionTotalTaxAmount,0),15,2)), 0)
   INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionTotalGrossAmount', LTrim(Str(IsNull(@CorrectionTotalGrossAmount,0),15,2)), 0)
  END
        -- tu korekta END
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('GrossAmountInWords', LTrim(@GrossAmountInWords), 11) --CDATA
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Tax-Summary', '', -1)
  -- KOREKTA STAWKI VAT
  IF @Korekta = 1 or @Korekta = 2 or @Korekta = 3-- korekta stawki VAT
  BEGIN
   OPEN fakturaKorektaVat
   WHILE 1=1
   BEGIN
    FETCH NEXT FROM fakturaKorektaVat INTO @TaxRate, @TaxFlaga,
              @TaxAmount, @TaxableAmount,
              @PreviousTaxRate, @PreviousTaxFlaga,
              @PreviousTaxAmount, @PreviousTaxableAmount
    IF @@FETCH_STATUS <> 0  BREAK
    SET @TaxCategoryCode = CDN.EcodTaxCategoryCode(@TaxRate, @TaxFlaga, @TrnID)
    IF @TaxFlaga = 1 OR @TaxFlaga = 4  -- zwolniona lub nie podlega
     SET @TaxableBasis = 0
    ELSE
     SET @TaxableBasis = @TaxableAmount
    SET @GrossAmount =  @TaxAmount + @TaxableAmount
    SET @PreviousTaxCategoryCode = CDN.EcodTaxCategoryCode(@PreviousTaxRate, @PreviousTaxFlaga, @TrnID)
    --IF @PreviousTaxFlaga = 1 OR @PreviousTaxFlaga = 4  -- zwolniona lub nie podlega
    -- SET @PreviousTaxableBasis = 0
    --ELSE
    -- SET @PreviousTaxableBasis = @PreviousTaxableAmount
    --SET @PreviousGrossAmount =  @PreviousTaxAmount + @PreviousTaxableAmount
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Tax-Summary-Line', '', -1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxRate',   LTrim(Str(@TaxRate,5,2)),  0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxCategoryCode', @TaxCategoryCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxAmount',   LTrim(Str(@TaxAmount,15,2)), 0)
    -- INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxableBasis',  LTrim(Str(@TaxableBasis,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxableAmount',  LTrim(Str(@TaxableAmount,15,2)),0)
    -- INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('GrossAmount',  LTrim(Str(@GrossAmount,15,2)), 0)
     SET @CorrectionTaxAmount = @TaxAmount - @PreviousTaxAmount
     SET @CorrectionTaxableAmount= @TaxableAmount- @PreviousTaxableAmount
    --  SET @CorrectionTaxableBasis = @TaxableBasis - @PreviousTaxableBasis
     --SET @CorrectionGrossAmount = @GrossAmount - @PreviousGrossAmount
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTaxRate',   LTrim(Str(@PreviousTaxRate,5,2)),  0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTaxCategoryCode', @PreviousTaxCategoryCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTaxAmount',   LTrim(Str(@PreviousTaxAmount,15,2)), 0)
     --INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTaxableBasis',  LTrim(Str(@PreviousTaxableBasis,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousTaxableAmount',  LTrim(Str(@PreviousTaxableAmount,15,2)),0)
     --INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PreviousGrossAmount',  LTrim(Str(@PreviousGrossAmount,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionTaxAmount',  LTrim(Str(@CorrectionTaxAmount,15,2)),  0)
     --INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionTaxableBasis',  LTrim(Str(@CorrectionTaxableBasis,15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionTaxableAmount', LTrim(Str(@CorrectionTaxableAmount,15,2)), 0)
     --INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('CorrectionGrossAmount',  LTrim(Str(@CorrectionGrossAmount,15,2)), 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Tax-Summary-Line', '', 1)
   END
   CLOSE fakturaKorektaVat
   DEALLOCATE fakturaKorektaVat
  END
  ELSE --
  BEGIN
   OPEN fakturaTraVat
   WHILE 1=1
   BEGIN
    FETCH NEXT FROM fakturaTraVat INTO @TaxRate, @TaxFlaga, @TaxCategoryCode,
             @TaxAmount, @TaxableAmount,
             @TaxableBasis,
             @GrossAmount
    IF @@FETCH_STATUS <> 0  BREAK
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Tax-Summary-Line', '', -1)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxRate',   LTrim(Str(@TaxRate,5,2)),  0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxCategoryCode', @TaxCategoryCode, 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxAmount',   LTrim(Str(Round(@TaxAmount,2),15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxableBasis',  LTrim(Str(Round(@TaxableBasis,2),15,2)), 0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('TaxableAmount',  LTrim(Str(Round(@TaxableAmount,2),15,2)),0)
     INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('GrossAmount',  LTrim(Str(Round(@GrossAmount,2),15,2)), 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Tax-Summary-Line', '', 1)
   END
   CLOSE fakturaTraVat
   DEALLOCATE fakturaTraVat
  END
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Tax-Summary', '', 1)
 INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Invoice-Summary', '', 1)
END
