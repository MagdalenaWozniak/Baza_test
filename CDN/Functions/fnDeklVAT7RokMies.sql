create FUNCTION CDN.fnDeklVAT7RokMies (@TrNId INT, @Typ VARCHAR(2))
RETURNS NVARCHAR(255)
AS
BEGIN
  DECLARE
  @RetVal NVARCHAR(255),
  @Export INT,
  @Medialny INT,
  @DataOpe DATETIME,
  @DataWys DATETIME,
  @DataDok DATETIME,
  @DataPtwTaxFree DATETIME,
  @DataZmiany DATETIME
  SET @DataZmiany = '2014-01-01'
  select @Export = TrN_Export, @Medialny = isnull(Knt_Medialny,0),@DataOpe =TrN_DataOpe,@DataWys = TrN_DataWys,@DataDok = TrN_DataDok,@DataPtwTaxFree = trn_DataPtwTaxFree from cdn.TraNag
  left join cdn.Kontrahenci on TrN_PodID = Knt_KntId and TrN_PodmiotTyp = 1 where TrN_TrNID = @TrNId
  SET @RetVal = ''
  if (@Typ = 'TF')
  begin
            SET @RetVal = case WHEN @DataPtwTaxFree IS NULL THEN SUBSTRING(CONVERT(VARCHAR(10), @DataWys, 120), 1, 7)
                                      WHEN DATEADD(m, 10, CDN.EOMonth(YEAR(@DataOpe)*100+MONTH(@DataOpe)) ) >= @DataPtwTaxFree THEN SUBSTRING(CONVERT(VARCHAR(10), @DataPtwTaxFree, 120), 1, 7)
                           ELSE 'Nie'
                     END
  end
  if (@Typ = 'FZ')
  begin
      if (@DataZmiany > @DataOpe)
            SET @RetVal = SUBSTRING(REPLACE(CONVERT(varchar(10), @DataDok, 120), '-', ''), 1, 6)
      else
            if(@Export in (3,4) or @Medialny = 1)
                  if (@DataDok > @DataWys)
                        SET @RetVal = SUBSTRING(REPLACE(CONVERT(varchar(10), @DataDok, 120), '-', ''), 1, 6)
                  else
                        SET @RetVal = SUBSTRING(REPLACE(CONVERT(varchar(10), @DataWys, 120), '-', ''), 1, 6)
            else
                  if (@DataDok > @DataOpe)
                        SET @RetVal = SUBSTRING(REPLACE(CONVERT(varchar(10), @DataDok, 120), '-', ''), 1, 6)
                  else
                        SET @RetVal = SUBSTRING(REPLACE(CONVERT(varchar(10), @DataOpe, 120), '-', ''), 1, 6)
  end
  if (@Typ = 'FS')
  begin
  DECLARE @Zmiana2020 INT
  SELECT @Zmiana2020 = 0
  IF @DataOpe >= CONVERT(DATETIME, '2020-07-01' , 120)
  BEGIN
   DECLARE @MaParagon INT
   SELECT @MaParagon = CASE WHEN EXISTS(SELECT * FROM cdn.TraNagRelacje join CDN.TraNag on (TrR_TrNId = TrN_TrNID) where TrR_FaId = @TrNId and trr_trntyp = 305 and trr_fatyp=302) THEN 1 ELSE 0 END
   IF @MaParagon = 1
   BEGIN
    DECLARE @KodFPID INT
    SELECT @KodFPID = KV7_KV7ID from cdn.KodyJPKV7 WHERE kv7_Kod = 'FP'
    DECLARE @MaKodFP INT
    SELECT @MaKodFP = CASE WHEN EXISTS(SELECT * FROM cdn.DokKodyJPKV7 WHERE DKV7_KV7ID = @KodFPID AND DKV7_ParentTyp = 1 AND DKV7_ParentID = @TrNId) THEN 1 ELSE 0 END
    IF @MaKodFP = 1
    BEGIN
     SELECT @Zmiana2020 = 1
    END
   END
  END
  IF @Zmiana2020 = 1
   SET @RetVal = SUBSTRING(REPLACE(CONVERT(varchar(10), @DataWys, 120), '-', ''), 1, 6)
  ELSE
  BEGIN
   if (@DataZmiany > @DataOpe)
    SET @RetVal = SUBSTRING(REPLACE(CONVERT(varchar(10), @DataWys, 120), '-', ''), 1, 6)
   else
    if(@Export in (3,4) or @Medialny = 1)
     SET @RetVal = SUBSTRING(REPLACE(CONVERT(varchar(10), @DataWys, 120), '-', ''), 1, 6)
    else
     SET @RetVal = SUBSTRING(REPLACE(CONVERT(varchar(10), @DataOpe, 120), '-', ''), 1, 6)
  END
  end
  RETURN @RetVal
END
