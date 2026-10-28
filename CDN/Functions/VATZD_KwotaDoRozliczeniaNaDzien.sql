CREATE FUNCTION CDN.VATZD_KwotaDoRozliczeniaNaDzien( @BZdID int, @Typ INT, @TerminPlatnosci DateTime, @data DateTime, @McKw INT, @DknId INT)
RETURNS decimal(15,2)
AS
BEGIN
 DECLARE @result decimal(15,2)
 select @result = Sum(SumaKwotZdarzen) from
 CDN.VATZD_Zobowiazania(@data, @McKw, @Typ, @DknId, @BZdID, null)
 where Termin = @TerminPlatnosci
 RETURN @result
END
