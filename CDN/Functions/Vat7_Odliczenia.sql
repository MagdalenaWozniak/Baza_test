CREATE FUNCTION CDN.Vat7_Odliczenia(@Value int, @T1 int,@T2 int=null,@T3 int=null)
RETURNS decimal(15,2)
AS
BEGIN
 declare @Result decimal(15,2) = 0.00;
 if @Value = @T1 or @Value = @T2 or @Value = @T3
  set @Result = 1.00;
 else
  set @Result = 0.00;
 return @Result
END
