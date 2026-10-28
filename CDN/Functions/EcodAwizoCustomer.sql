CREATE  FUNCTION CDN.EcodAwizoCustomer( @mode INT, @podTyp INT, @podId INT)
RETURNS     nvarchar(175)
AS
BEGIN
 DECLARE @gln VARCHAR(13)
 IF @podTyp = 1
  SELECT TOP 1 @gln = Knt_GLN FROM cdn.Kontrahenci WHERE Knt_KntId = @podId
 IF @gln IS NULL RETURN ''
 IF LTRIM(RTRIM(@gln)) = '' RETURN ''
 RETURN CDN.EcodCustomerItems(@mode, @gln)
END
