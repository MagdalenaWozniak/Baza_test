CREATE FUNCTION CDN.VatPrzedKorekta( @TrnID INT, @TrnOrgID INT, @mode INT)
RETURNS @TraVat TABLE (
 TrV_Stawka NUMERIC(5,2),
 TrV_Flaga SMALLINT,
 TrV_Netto NUMERIC(15,2),
 TrV_Basis NUMERIC(15,2),
 TrV_Vat NUMERIC(15,2),
 TrV_Brutto NUMERIC(15,2)
 )
AS
BEGIN
 DECLARE fakturaPrevious CURSOR FOR
 SELECT @TrnOrgID
 UNION
 SELECT TrN_TrNId
 FROM cdn.TraNag
 WHERE  TrN_Bufor<>-1 AND TrN_ZwrId = @TrnOrgID AND ((@mode = 0 AND TrN_TrNId < @TrnID  ) OR (@mode = 1 AND TrN_TrNId <= @TrnID))
 DECLARE @faId  INT
        DECLARE @StawkaVatOrg DECIMAL(5,2),
   @FlagaVatOrg SMALLINT,
   @ZrodlowaOrg NUMERIC(5,2),
            @Netto   NUMERIC(15,2),
            @Vat   NUMERIC(15,2),
            @Basis   NUMERIC(15,2),
            @Brutto   NUMERIC(15,2)
 OPEN fakturaPrevious
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM fakturaPrevious INTO @faId
  IF @@FETCH_STATUS <> 0  BREAK
  DECLARE fakturaTraVat CURSOR FOR
  SELECT  TrV_Stawka,
    TrV_Flaga,
    TrV_Netto,
    TrV_Vat,
    CASE TrV_Flaga
     WHEN 1 THEN 0.00
     WHEN 4 THEN 0.00
      ELSE
     IsNull(TrV_Netto,0.00)
    END As TrV_Basis,
    TrV_Netto + TrV_Vat As TrV_Brutto
  FROM cdn.TraVat WHERE TrV_TrnId = @faId AND TrV_Typ = 0
  OPEN fakturaTraVat
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM fakturaTraVat INTO @StawkaVatOrg, @FlagaVatOrg, @Netto, @Vat, @Basis, @Brutto
   IF @@FETCH_STATUS <> 0  BREAK
   IF NOT EXISTS(SELECT * FROM @TraVat WHERE TrV_Stawka = @StawkaVatOrg AND TrV_Flaga = @FlagaVatOrg)
    INSERT INTO @TraVat(TrV_Stawka, TrV_Flaga, TrV_Netto, TrV_Basis, TrV_Vat, TrV_Brutto)
    VALUES(@StawkaVatOrg, @FlagaVatOrg, @Netto, @Basis, @Vat, @Brutto)
   ELSE
    UPDATE @TraVat SET TrV_Netto = TrV_Netto + @Netto,
        TrV_Basis = TrV_Basis + @Basis,
        TrV_Vat  = TrV_Vat + @Vat,
        TrV_Brutto = TrV_Brutto+ @Brutto
    WHERE TrV_Stawka = @StawkaVatOrg AND TrV_Flaga = @FlagaVatOrg
  END
  CLOSE fakturaTraVat
  DEALLOCATE fakturaTraVat
 END
 CLOSE fakturaPrevious
 DEALLOCATE fakturaPrevious
 RETURN
END
