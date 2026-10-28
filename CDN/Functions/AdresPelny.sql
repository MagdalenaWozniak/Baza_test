CREATE FUNCTION CDN.AdresPelny
(
@Miasto NVARCHAR(256),
@Ulica  NVARCHAR(256),
@NrDomu NVARCHAR(16),
@NrLokalu NVARCHAR(16),
@KodP NVARCHAR(16),
@Poczta NVARCHAR(256)
)
RETURNS NVARCHAR(1024)
AS
BEGIN
 IF @Poczta = ''
  SET @Poczta = @Miasto
 DECLARE @nrDomLok NVARCHAR(33)
 IF @NrDomu = '' AND @NrLokalu = ''
  SET @nrDomLok = ''
 ELSE IF @NrDomu <> '' AND @NrLokalu = ''
  SET @nrDomLok = ' ' + @NrDomu
 ELSE
  SET @nrDomLok = ' ' + @NrDomu + '/' + @NrLokalu
 declare @left nvarchar(512) = ''
 declare @right nvarchar(512) = RTRIM(LTRIM(@KodP + ' ' + @Poczta))
 declare @d nvarchar(2) = ''
 IF @Ulica = ''
  set @left = RTRIM(LTRIM(@Miasto + @NrDomLok))
 else
 BEGIN
  set @left = RTRIM(LTRIM(@Ulica + @NrDomLok))
  IF RTRIM(LTRIM(@Poczta)) != RTRIM(LTRIM(@Miasto)) and RTRIM(LTRIM(@Miasto))<> ''
   IF @left <> ''
    set @left = RTRIM(LTRIM(@Miasto)) +  ' ' + @left
   ELSE
       set @left = RTRIM(LTRIM(@Miasto))
 END
 if @left <> '' and @right <> ''
  set @d = ', '
 else
  set @d = ' '
 declare @result nvarchar(1024) = @left + @d + @right;
 set @result = replace(@result, char(31), '');
 RETURN RTRIM(LTRIM(@result))
END
