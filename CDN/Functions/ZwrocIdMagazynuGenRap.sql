CREATE  FUNCTION CDN.ZwrocIdMagazynuGenRap ( @MagKod NVARCHAR(20))
 RETURNS     INT
AS
BEGIN
 DECLARE  @MagId INT
 IF @MagKod = '<wszystkie>'
  SELECT @MagId = 0
ELSE
  SELECT @MagId = Mag_MagID FROM CDN.Magazyny WHERE Mag_Symbol = @MagKod
  RETURN @MagId
END
