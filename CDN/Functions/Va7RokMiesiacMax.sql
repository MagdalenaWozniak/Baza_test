CREATE FUNCTION CDN.Va7RokMiesiacMax(@vanid int)
returns VARCHAR(7)
AS
BEGIN
 DECLARE @Wynik VARCHAR(7)
 SELECT @Wynik = ISNULL(CAST(MAX(Va7_RokMiesiac) AS VARCHAR(6)),'NIE') FROM CDN.VatTab7 WHERE Va7_VanID=@vanid
 IF @Wynik <> 'NIE'
  SET @Wynik = SUBSTRING(@Wynik, 1, 4) + '-' +  SUBSTRING(@Wynik, 5, 2)
 return @Wynik
END
