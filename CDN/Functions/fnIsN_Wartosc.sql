CREATE FUNCTION CDN.fnIsN_Wartosc ( @IsNId INT )
RETURNS DECIMAL(15,2)
AS
BEGIN
 DECLARE @Wynik Decimal(15,2)
 SELECT @Wynik=IsNull(Sum(IsE_Netto), 0) FROM CDN.IntrastatElem Where IsE_IsNId = @IsNId
 RETURN @Wynik
END
