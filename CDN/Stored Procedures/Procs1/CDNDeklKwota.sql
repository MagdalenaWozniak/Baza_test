CREATE PROCEDURE CDN.CDNDeklKwota @KWOTA NVARCHAR(20), @WYNIK DECIMAL(15,2) OUTPUT
AS
SET NOCOUNT OFF
   DECLARE @l INT
   SET @l = LEN(@KWOTA)
   IF @l=0 OR @KWOTA is null
   BEGIN
      SET @WYNIK = CONVERT (DECIMAL(15,2), '0')
      RETURN
   END
   DECLARE @licznik NVARCHAR(10)
   DECLARE @mianownik NVARCHAR(2)
   DECLARE @skwota NVARCHAR(20)
   SET @licznik = SUBSTRING (@KWOTA, 1, @l-2)
   SET @mianownik = SUBSTRING (@KWOTA, @l-1, 2)
   SET @skwota = @licznik+'.'+@mianownik
   SET @WYNIK = CONVERT (DECIMAL(15,2), @skwota)
