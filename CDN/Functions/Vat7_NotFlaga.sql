CREATE FUNCTION CDN.Vat7_NotFlaga(@Value int, @T1 int,@T2 int=null,@T3 int=null)
RETURNS decimal(15,2)
AS
BEGIN
 declare @Result decimal(15,2) = 0.00;
 if @Value <> @T1 and @Value <> @T2 and @Value <> @T3
  set @Result = 1.00;
 else
  set @Result = 0.00;
 return @Result
END
