CREATE FUNCTION CDN.SFSlownikId(@jednostka nvarchar(50), @zestawienie nvarchar(50), @kod nvarchar(255))
RETURNS int
AS
BEGIN
 declare @Result int = -1;
 select @Result = id from CDN.SFSlownik() where jednostka = @jednostka  and  zestawienie = @zestawienie and kod =  @kod;
 return IsNull(@Result, -1)
END
