CREATE FUNCTION CDN.PieczatkaFirmyWartosc(@firNumer INT, @pieczatkaId INT)
  RETURNS     NVARCHAR(512)
  AS
  BEGIN
  DECLARE @result NVARCHAR(512), @defaultValue NVARCHAR(512)
  SET @defaultValue = ''
  SET @result = ''
  IF @pieczatkaId = 0
  BEGIN
  SET @result = IsNull((SELECT Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = @firNumer), @defaultValue)
  GOTO KONIEC
  END
  IF @firNumer = 1101 SET @result = IsNull((SELECT PC_NipE     FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1145 SET @result = IsNull((SELECT PC_Kraj     FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1149 SET @result = IsNull((SELECT PC_Ulica    FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1150 SET @result = IsNull((SELECT PC_NrDomu   FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1151 SET @result = IsNull((SELECT PC_NrLokalu FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1152 SET @result = IsNull((SELECT PC_Miasto   FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1153 SET @result = IsNull((SELECT PC_KodP     FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1156 SET @result = IsNull((SELECT PC_Nazwa1   FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1157 SET @result = IsNull((SELECT PC_Nazwa2   FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1165 SET @result = IsNull((SELECT PC_ILNGLNWlasny FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1166 SET @result = IsNull((SELECT PC_ILNGLNCentrali FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1169
  BEGIN
 SET @result = (SELECT PC_NipKraj  FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId)
 IF @result IS NULL OR @result = '' SET @result = IsNull((SELECT PC_KrajISO FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  END
  IF @firNumer = 1171 SET @result = IsNull((SELECT PC_KRS_Sad   FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1172 SET @result = IsNull((SELECT PC_KRS_Numer   FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1173 SET @result = IsNull((SELECT PC_KRS_KapitalZak FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1174 SET @result = IsNull((SELECT PC_KRS_KapitalWpl FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 1881 SET @result = IsNull((SELECT PC_BDO   FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
  IF @firNumer = 2166 SET @result = IsNull((SELECT PC_Nazwa3   FROM cdn.Pieczatki WHERE PC_PCID = @pieczatkaId), @defaultValue)
KONIEC:
 RETURN @result
END
