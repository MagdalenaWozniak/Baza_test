CREATE FUNCTION CDN.SaldoRejestruKB(@BRaID INT, @Data DATETIME, @BZpID DECIMAL(15,2), @AutoBZp VARCHAR(MAX))
RETURNS DECIMAL(15,2)
AS
BEGIN
 DECLARE @saldo DECIMAL(15,2)
 SET @saldo = 0
 -- Musimy pominąć zapisy automatyczne związane z dokumentem, które za moment zostaną usunięte (onSave managera płatności) w związku z przegenerowaniem
 DECLARE @tblArray TABLE(
    ElementID   int IDENTITY(1,1),  -- Array index
    Element     int     -- Array element contents
  )
 DECLARE @Index      smallint,
   @Start      smallint
    -- Loop through source string and add elements to destination table array
    --
  WHILE LEN(@AutoBZp) > 0
  BEGIN
    SET @Index = CHARINDEX(',', @AutoBZp)
    IF @Index = 0
    BEGIN
      INSERT INTO @tblArray (Element) VALUES(LTRIM(RTRIM(@AutoBZp)))
      BREAK
    END
    ELSE
    BEGIN
      INSERT INTO @tblArray (Element) VALUES (LTRIM(RTRIM(SUBSTRING(@AutoBZp, 1,@Index - 1))))
      SET @Start = @Index + 1
      SET @AutoBZp = SUBSTRING(@AutoBZp, @Start , LEN(@AutoBZp) - @Start + 1)
    END
  END
 DECLARE @Waluta VARCHAR(3)
 SELECT @Waluta = BRa_Waluta FROM cdn.BnkRachunki WHERE BRa_BRaID = @BRaID
 IF @Waluta <> ''
 BEGIN
 SELECT @saldo = IsNull(BRa_SaldoBO, 0) FROM cdn.BnkRachunki WHERE BRa_BRaID = @BRaID
 SELECT @saldo = @saldo + IsNull(SUM(BZp_Kierunek * BZp_Kwota), 0) FROM cdn.BnkZapisy WHERE BZp_BRaID = @BRaID AND BZp_DataDok <= @Data
    AND BZp_BZpID <> @BZpID AND NOT EXISTS (SELECT * FROM @tblArray WHERE Element = BZp_BZpID)
 END
 ELSE
 BEGIN
 SELECT @saldo = IsNull(BRa_SaldoBOSys, 0) FROM cdn.BnkRachunki WHERE BRa_BRaID = @BRaID
 SELECT @saldo = @saldo + IsNull(SUM(BZp_Kierunek * BZp_KwotaSys), 0) FROM cdn.BnkZapisy WHERE BZp_BRaID = @BRaID AND BZp_DataDok <= @Data
    AND BZp_BZpID <> @BZpID AND NOT EXISTS (SELECT * FROM @tblArray WHERE Element = BZp_BZpID)
 END
 RETURN @saldo
END
