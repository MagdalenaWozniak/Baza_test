CREATE FUNCTION CDN.KodWymiaru(@opis nvarchar(4000))
RETURNS nvarchar(4000)
AS
BEGIN
  declare @a int = 0;--charindex('<', @opis, 0);
  declare @b int = charindex('/', @opis, 0);
 declare @Result nvarchar(4000) = SubString(@opis, @a+1, @b - @a - 1);
 return @Result
END
