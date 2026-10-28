CREATE FUNCTION CDN.VATZD_Rodzaj( @Rejestr int, @Rodzaj int)
RETURNS int
AS
BEGIN
 declare @result int
 declare @TOWARY    int
 declare @TRWALE    int
 declare @REJESTR_ZAKUPOW int
 declare @REJESTR_SPRZEDAZY int
 set @TOWARY = 1
 set @TRWALE = 3
 set @REJESTR_ZAKUPOW = 1
 set @REJESTR_SPRZEDAZY = 2
 if @Rejestr = @REJESTR_ZAKUPOW
 begin
  select @result = case when @Rodzaj in (1,2,4,7) then @TOWARY else @TRWALE end
 end
 else
 begin
  select @result = @TOWARY
 end
 set @result =  IsNull(@result, 1)
 return @result
END
