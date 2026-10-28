CREATE FUNCTION CDN.WartoscWymiaru(@opis nvarchar(4000))
RETURNS nvarchar(4000)
AS
BEGIN
 --declare @a int = charindex('/', reverse(@opis), 0);
 declare @a int = charindex('/', @opis, 0);
 declare @Result nvarchar(4000) = SubString(@opis, @a+1, len(@opis) - @a);
 return @Result
END
