CREATE FUNCTION CDN.ModuloDecimal4(@n decimal(15,4), @d decimal(15,4))
RETURNS DECIMAL(15,4)
AS
BEGIN
    DECLARE @wynik DECIMAL(15,4)
    --SET @wynik = @n % @d
    SET @wynik = @n - @d * CAST(@n/@d AS INT) - CASE WHEN @d < 0 THEN @d ELSE 0 END
    RETURN @wynik
END
