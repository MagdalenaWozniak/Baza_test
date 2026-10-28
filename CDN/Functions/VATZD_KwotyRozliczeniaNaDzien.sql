CREATE FUNCTION CDN.VATZD_KwotyRozliczeniaNaDzien( @BZdId int, @Typ INT, @TerminPlatnosci DateTime, @data DateTime, @McKw INT, @DknId INT )
RETURNS @Result TABLE( BZdId      int,
      VaNId      int,
      KwotaDoRozliczeniaNaDzien Decimal(15,2),
      KwotaRozliczonaNaDzien  Decimal(15,2) )
AS
BEGIN
 insert into @result
 select @BZdId, VaNId, Sum(IsNull(SumaKwotZdarzen,0)), Sum(IsNull(SumaKwotRozliczen,0)) from CDN.VATZD_Zobowiazania(@data, @McKw, @Typ, @DknId, @BZdId, null) where Termin = @TerminPlatnosci
 group by VaNId
 return
END
