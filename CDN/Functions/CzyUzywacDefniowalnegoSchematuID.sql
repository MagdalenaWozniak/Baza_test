CREATE FUNCTION CDN.CzyUzywacDefniowalnegoSchematuID (@DataDok DATETIME)
RETURNS INT
BEGIN
 DECLARE @DefiniowalnySchematID INT, @DefiniowalnySchematID_Data DATETIME, @DefiniowalnySchematID_DDfID INT;
 SELECT @DefiniowalnySchematID=ISNULL(CAST(Fir_Wartosc AS INT),0) FROM CDN.Firma WHERE Fir_Numer=2116
 SELECT @DefiniowalnySchematID_Data=CDN.FromClarionDate(Fir_Wartosc) FROM CDN.Firma WHERE Fir_Numer=2117
 SELECT @DefiniowalnySchematID_DDfID=ISNULL(CAST(Fir_Wartosc AS INT),0) FROM CDN.Firma WHERE Fir_Numer=2119
 IF( @DefiniowalnySchematID <> 0 AND DATEDIFF(day, @DefiniowalnySchematID_Data, @DataDok)>=0 AND @DefiniowalnySchematID_DDfID <> 0)
  RETURN @DefiniowalnySchematID_DDfID
 RETURN 0
END
