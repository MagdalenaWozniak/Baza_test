CREATE FUNCTION CDN.DopasujDoZamawiacPo(@ilosc decimal(15,4), @zamawiajPo decimal(15,4), @niePrzekraczaj int)
RETURNS DECIMAL(15,4)
AS
BEGIN
    DECLARE @wynik DECIMAL(15,4)
    IF @zamawiajPo = 0
    BEGIN
        SET @wynik = @ilosc
        GOTO KONIEC
    END
    IF @niePrzekraczaj <= 0 AND @ilosc < @zamawiajPo
    BEGIN
        SET @wynik = 0
        GOTO KONIEC
    END
    --SET @wynik = @ilosc % @zamawiajPo
    SET @wynik = CDN.ModuloDecimal4(@ilosc, @zamawiajPo)
    IF @wynik = 0
        BEGIN
            SET @wynik = @ilosc
        END
    ELSE
        BEGIN
            SET @wynik = @ilosc + (@zamawiajPo - @wynik)
            IF @niePrzekraczaj <= 0 AND @wynik > @zamawiajPo
                SET @wynik = @wynik - @zamawiajPo
        END
KONIEC:
    IF @wynik Is Null
        SET @wynik = 0
    RETURN @wynik
END
