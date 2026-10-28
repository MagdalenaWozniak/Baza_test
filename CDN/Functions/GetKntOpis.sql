CREATE FUNCTION CDN.GetKntOpis(@kntId int, @dokumentId int, @operatorId int)
RETURNS nvarchar(max)
AS
BEGIN
 DECLARE @opis nvarchar(max);
 SELECT @opis = Knt_Opis FROM CDN.Kontrahenci WHERE Knt_KntId = @kntId
 IF @opis IS NULL OR LEN(@opis) = 0
  SET @opis = 'Nie ma dodatkowych informacji o tym kontrahencie.
Kliknij, aby wprowadzić opis na karcie kontrahenta.'
 RETURN @opis
END
