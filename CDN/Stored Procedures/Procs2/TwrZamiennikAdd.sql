CREATE PROCEDURE CDN.TwrZamiennikAdd
@kod        NVARCHAR(50),
@kodZam     NVARCHAR(50),
@lp   INT
  AS
BEGIN
    -- procedura dodaje do tabeli Zamienniki nowy rekord
    SET @kod = RTRIM(LTRIM(@kod))
    IF @kod IS NULL OR RTRIM(LTRIM(@kod))= ''
    BEGIN
  RETURN
    END
    IF @kodZam IS NULL OR RTRIM(LTRIM(@kodZam))= ''
    BEGIN
  RETURN
    END
    DECLARE @ZAM_TwrId INT, @ZAM_ZamTwrId INT, @ZAM_Lp INT
    SELECT @ZAM_TwrId    = Twr_TwrId FROM CDN.Towary WHERE Twr_Kod = @kod
    SELECT @ZAM_ZamTwrId = Twr_TwrId FROM CDN.Towary WHERE Twr_Kod = @kodZam
    IF @ZAM_TwrId       Is Null OR @ZAM_TwrId   = 0 RETURN
    IF @ZAM_ZamTwrId    Is Null OR @ZAM_ZamTwrId= 0 RETURN
 IF NOT EXISTS( SELECT * FROM CDN.Zamienniki WHERE ZAM_TwrId=@ZAM_TwrId AND ZAM_ZamTwrId=@ZAM_ZamTwrId )
  BEGIN
      IF( @lp Is NULL or @lp = 0 )
   BEGIN
    SELECT @ZAM_Lp = MAX(ZAM_Lp) FROM CDN.Zamienniki WHERE ZAM_TwrId=@ZAM_TwrId
    IF( @ZAM_Lp Is NULL ) SET @ZAM_Lp = 0;
    SET @ZAM_Lp = @ZAM_Lp + 1
   END
   ELSE
   BEGIN
    SET @ZAM_Lp = @Lp
   END
   INSERT INTO CDN.Zamienniki
   (
    ZAM_TwrId
    ,ZAM_ZamTwrId
    ,ZAM_Lp
      )
   VALUES
   (
    @ZAM_TwrId
    ,@ZAM_ZamTwrId
    ,@ZAM_Lp
      )
  END
END
