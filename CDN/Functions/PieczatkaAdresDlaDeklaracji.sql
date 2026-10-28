CREATE FUNCTION CDN.PieczatkaAdresDlaDeklaracji(
  @Miasto   NVARCHAR(40),
  @Ulica   NVARCHAR(40),
  @NrDomu   NVARCHAR(10),
  @NrLokalu  NVARCHAR(10),
  @KodP   VARCHAR(10),
  @Poczta   NVARCHAR(40))
RETURNS NVARCHAR(256)
AS
BEGIN
 DECLARE @retVal NVARCHAR(256)
 SELECT @retVal = ''
 IF @Ulica<>''
 BEGIN
  IF @Poczta<>@Miasto
   SELECT @retVal = @KodP + ' ' + @Poczta + ' ' + @Miasto + ' ' + @Ulica
  ELSE
   SELECT @retVal = @KodP + ' ' + @Poczta + ' ' + @Ulica
 END
 ELSE
 BEGIN
  IF @Poczta<>@Miasto
   SELECT @retVal = @KodP + ' ' + @Poczta + ' ' + @Miasto
  ELSE
   SELECT @retVal = @KodP + ' ' + @Poczta
 END
 IF @NrDomu<>'' OR @NrLokalu<>''
 BEGIN
  IF @NrLokalu<>''
   SELECT @retVal = @retVal + ' ' + @NrDomu + '/' + @NrLokalu
  ELSE
   SELECT @retVal = @retVal + ' ' + @NrDomu
 END
 RETURN @retVal
END
