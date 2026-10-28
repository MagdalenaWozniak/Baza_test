CREATE FUNCTION CDN.EcodCustomerItems( @mode INT, @gln VARCHAR(13) )
RETURNS     NVARCHAR(175)
AS
BEGIN
 DECLARE @wynik NVARCHAR(175)
 IF @gln IS NULL RETURN ''
 IF LTRIM(RTRIM(@gln)) = '' RETURN ''
 IF @mode = 1   --@OrderedByGLN
  SET @wynik = @gln
 IF @mode = 2   --@OrderedByNIP
  Select  TOP 1 @wynik = Knt_NIP From cdn.Kontrahenci Where Knt_GLN = @gln
 IF @mode = 3   --@OrderedByAccountNumber
  Select TOP 1 @wynik = Knt_RachunekNr From cdn.Kontrahenci Where Knt_GLN = @gln
 IF @mode = 4   -- @OrderedByName
  Select TOP 1 @wynik = Cast(KnT_Nazwa1 + ' ' + KnT_Nazwa2  + ' ' + KnT_Nazwa3 As nvarchar(175)) From cdn.Kontrahenci Where Knt_GLN = @gln
 IF @mode = 5   --@OrderedByStreetAndNumber
  Select TOP 1 @wynik = Cast(KnT_Ulica  + ' ' + KnT_NrDomu  + (CASE LEN(KnT_NrLokalu) WHEN  0  THEN '' ELSE '/' + KnT_NrLokalu END ) As nvarchar(140)) From cdn.Kontrahenci Where Knt_GLN = @gln
 IF @mode = 6   --@OrderedByCityName
  Select TOP 1 @wynik = Cast(KnT_Miasto  As nvarchar(40)) From cdn.Kontrahenci  Where Knt_GLN = @gln
 IF @mode = 7   --@OrderedByPostalCode
  Select TOP 1 @wynik = Cast(KnT_KodPocztowy As nvarchar(9)) From cdn.Kontrahenci Where Knt_GLN = @gln
 IF @mode = 8   --@OrderedByCountry
  Select  TOP 1 @wynik = Knt_KrajISO From cdn.Kontrahenci Where Knt_GLN = @gln
 IF @wynik IS NULL
 BEGIN
  IF @mode = 8
   SET @wynik = 'PL'
  ELSE
   SET @wynik = ''
 END
 RETURN RTRIM(@wynik)
END
