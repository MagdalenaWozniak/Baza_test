CREATE FUNCTION CDN.VATZD_KodStawkiVat( @VaZId int, @Rejestr int, @Flaga int, @Stawka decimal(15,2))
RETURNS nvarchar(3)
AS
BEGIN
 if @VaZId is not null
 begin
  select
   @Flaga = VaZ_Flaga,
   @Stawka= VaZ_Stawka
  from cdn.vatzd
  where VaZ_VaZId = @VaZId
 end
 declare @result nvarchar(3) = CDN.KodStawkiVat( @Rejestr, @Flaga, @Stawka);
 return @result
END
