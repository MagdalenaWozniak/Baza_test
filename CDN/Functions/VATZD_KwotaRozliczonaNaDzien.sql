CREATE FUNCTION CDN.VATZD_KwotaRozliczonaNaDzien( @BZdId int, @Typ INT, @TerminPlatnosci DateTime, @data DateTime, @McKw INT, @DknId INT)
RETURNS decimal(15,2)
AS
BEGIN
 DECLARE @result decimal(15,2)
 select @result = Sum(SumaKwotRozliczen) from
 CDN.VATZD_Zobowiazania(@data, @McKw, @Typ, @DknId, @BZdId, null)
 where Termin = @TerminPlatnosci
 RETURN @result
END
