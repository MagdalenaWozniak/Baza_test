CREATE FUNCTION CDN.fn_RozwinMakraElixirO (@Prymityw VARCHAR(35), @Data DATETIME, @NrDok VARCHAR(35), @DokTyp SMALLINT, @DokID INT, @PodTyp SMALLINT, @PodID INT, @PodKod VARCHAR(20), @BZdID INT, @KatOpis VARCHAR(50))
Returns VARCHAR(35)
AS
BEGIN
 SET @Prymityw = REPLACE(@Prymityw, '@DokumentyRozliczające', '')
 IF @Prymityw = ''
  RETURN ''
 DECLARE @retVal VARCHAR(256)
 SELECT @retVal = @Prymityw
 DECLARE @pdt DATETIME
 DECLARE @bdt DATETIME
 DECLARE @ndt DATETIME
 SET @pdt = @Data - 1
 SET @bdt = @Data
 SET @ndt = @Data + 1
 DECLARE @spd VARCHAR(10)
 DECLARE @sbd VARCHAR(10)
 DECLARE @snd VARCHAR(10)
 SET @spd = CONVERT(VARCHAR(10), @pdt, 120)
 SET @sbd = CONVERT(VARCHAR(10), @bdt, 120)
 SET @snd = CONVERT(VARCHAR(10), @ndt, 120)
 DECLARE @lpy INT
 DECLARE @lpm INT
 SELECT @lpy = YEAR(@bdt)
 SELECT @lpm = MONTH(@bdt) - 1
 IF @lpm < 1
 BEGIN
  SELECT @lpm = 12
  SELECT @lpy = @lpy - 1
 END
 DECLARE @spy VARCHAR(4)
 DECLARE @spm VARCHAR(7)
 SELECT @spy = CONVERT(VARCHAR(4), @lpy, 0)
 IF @lpm < 10
  SELECT @spm = '0' + CONVERT(VARCHAR(1), @lpm, 0)
 ELSE
  SELECT @spm = CONVERT(VARCHAR(2), @lpm, 0)
 SELECT @spm = @spm + '/' + @spy
 SELECT @lpy = YEAR(@bdt) - 1
 SELECT @spy = CONVERT(VARCHAR(4), @lpy, 0)
 DECLARE @lby INT
 DECLARE @lbm INT
 SELECT @lby = YEAR(@bdt)
 SELECT @lbm = MONTH(@bdt)
 DECLARE @sbm VARCHAR(7)
 SELECT @sbm = CONVERT(VARCHAR(2), @lbm, 0)
 IF @lbm < 10
 BEGIN
  SELECT @sbm = '0' + @sbm
 END
 DECLARE @sby VARCHAR(4)
 SELECT @sby = CONVERT(VARCHAR(4), @lby, 0)
 SELECT @sbm = @sbm + '/' + @sby
 DECLARE @lny INT
 DECLARE @lnm INT
 SELECT @lny = YEAR(@bdt)
 SELECT @lnm = MONTH(@bdt) + 1
 IF @lnm > 12
 BEGIN
  SELECT @lnm = 1
  SELECT @lny = @lny + 1
 END
 DECLARE @sny VARCHAR(4)
 SELECT @sny = CONVERT(VARCHAR(4), @lny, 0)
 DECLARE @snm VARCHAR(7)
 IF @lnm < 10
  SELECT @snm = '0' + CONVERT(VARCHAR(1), @lnm, 0)
 ELSE
  SELECT @snm = CONVERT(VARCHAR(2), @lnm, 0)
 SELECT @snm = @snm + '/' + @sny
 SELECT @lny = YEAR(@bdt) + 1
 SELECT @sny = CONVERT(VARCHAR(4), @lny, 0)
 DECLARE @spq VARCHAR(20)
 SET @spq = ''
 DECLARE @sbq VARCHAR(20)
 SET @sbq = ''
 DECLARE @snq VARCHAR(20)
 SET @snq = ''
 IF @lbm BETWEEN 1 AND 3
 BEGIN
  SELECT @spq = 'IV kw. ' + CONVERT(VARCHAR(4), @lpy)
  SELECT @sbq = 'I kw. ' + CONVERT(VARCHAR(4), @lby)
  SELECT @snq = 'II kw. ' + CONVERT(VARCHAR(4), @lby)
 END
 IF @lbm BETWEEN 4 AND 6
 BEGIN
  SELECT @spq = 'I kw. ' + CONVERT(VARCHAR(4), @lby)
  SELECT @sbq = 'II kw. ' + CONVERT(VARCHAR(4), @lby)
  SELECT @snq = 'III kw. ' + CONVERT(VARCHAR(4), @lby)
 END
 IF @lbm BETWEEN 7 AND 9
 BEGIN
  SELECT @spq = 'II kw. ' + CONVERT(VARCHAR(4), @lby)
  SELECT @sbq = 'III kw. ' + CONVERT(VARCHAR(4), @lby)
  SELECT @snq = 'IV kw. ' + CONVERT(VARCHAR(4), @lby)
 END
 IF @lbm BETWEEN 10 AND 12
 BEGIN
  SELECT @spq = 'III kw. ' + CONVERT(VARCHAR(4), @lby)
  SELECT @sbq = 'IV kw. ' + CONVERT(VARCHAR(4), @lby)
  SELECT @snq = 'I kw. ' + CONVERT(VARCHAR(4), @lny)
 END
 SELECT @retVal = @Prymityw
 SELECT @retVal = REPLACE(@retVal, '@DOC', @NrDok)
 SELECT @retVal = REPLACE(@retVal, '@PD', @spd)
 SELECT @retVal = REPLACE(@retVal, '@BD', @sbd)
 SELECT @retVal = REPLACE(@retVal, '@ND', @snd)
 SELECT @retVal = REPLACE(@retVal, '@DATA', @sbd)
 SELECT @retVal = REPLACE(@retVal, '@PM', @spm)
 SELECT @retVal = REPLACE(@retVal, '@BM', @sbm)
 SELECT @retVal = REPLACE(@retVal, '@NM', @snm)
 SELECT @retVal = REPLACE(@retVal, '@MC', CONVERT(VARCHAR(7), @lbm, 0))
 SELECT @retVal = REPLACE(@retVal, '@PK', @spq)
 SELECT @retVal = REPLACE(@retVal, '@BK', @sbq)
 SELECT @retVal = REPLACE(@retVal, '@NK', @snq)
 SELECT @retVal = REPLACE(@retVal, '@PR', @spy)
 SELECT @retVal = REPLACE(@retVal, '@BR', @sby)
 SELECT @retVal = REPLACE(@retVal, '@NR', @sny)
 SELECT @retVal = REPLACE(@retVal, '@ROK', @sby)
 DECLARE @lplNazwa NVARCHAR(128)
 IF @DokTyp = 8 AND @DokID <> 0
  SELECT TOP 1 @lplNazwa = LPL_Nazwa FROM CDN.Wyplaty JOIN CDN.ListyPlac ON LPL_LPLID = WPL_LPLID WHERE WPL_WPLID = @DokID
 ELSE
  SET @lplNazwa = ''
 SELECT @retVal = REPLACE(@retVal, '@OPISLP', @lplNazwa)
 DECLARE @PodTypStr NVARCHAR(20)
 SELECT @PodTypStr = CASE @PodTyp WHEN 1 THEN 'Kontrahent' WHEN 2 THEN 'Bank' WHEN 3 THEN 'Pracownik/Wspólnik' WHEN 5 THEN 'Urząd' ELSE '' END
 SELECT @retVal = REPLACE(@retVal, '@PodmiotTyp', @PodTypStr)
 SELECT @retVal = REPLACE(@retVal, '@PodmiotID', CONVERT(VARCHAR(3), @PodID, 0))
 SELECT @retVal = REPLACE(@retVal, '@PodmiotKod', @PodKod)
 IF CHARINDEX('@PodmiotNazwa', @retVal) > 0
 BEGIN
    DECLARE @PodmiotNazwa1 NVARCHAR(50)
    DECLARE @PodmiotNazwa2 NVARCHAR(50)
    DECLARE @PodmiotNazwa3 NVARCHAR(50)
  SELECT TOP 1 @PodmiotNazwa1 = Pod_Nazwa1, @PodmiotNazwa2 = Pod_Nazwa2, @PodmiotNazwa3 = Pod_Nazwa3 FROM CDN.PodmiotyView WHERE Pod_PodmiotTyp = @PodTyp AND Pod_PodID = @PodID
  SELECT @retVal = REPLACE(@retVal, '@PodmiotNazwa1', @PodmiotNazwa1)
  SELECT @retVal = REPLACE(@retVal, '@PodmiotNazwa2', @PodmiotNazwa2)
  SELECT @retVal = REPLACE(@retVal, '@PodmiotNazwa3', @PodmiotNazwa3)
 END
 IF @BZdID<>'0'
    SELECT @retVal = REPLACE(@retVal, '@ZdarzenieID', CONVERT(VARCHAR(10), @BZdID, 0))
 SELECT @retVal = REPLACE(@retVal, '@KategoriaOpis', @KatOpis)
 RETURN SUBSTRING(@retVal, 1, 35)
END
