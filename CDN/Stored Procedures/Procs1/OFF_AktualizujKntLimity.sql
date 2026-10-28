CREATE PROCEDURE CDN.OFF_AktualizujKntLimity
    @Knt_GIDNumerChr                 nvarchar(11),
    @Knt_LimitKredytuWal             nvarchar(3),
    @Knt_LimitKredytuChr             nvarchar(19),
    @Knt_LimitKredytuWykorzystanyChr nvarchar(19)
AS
  SET NOCOUNT ON
 DECLARE
    @Knt_GIDFirma                 INT,
    @Knt_GIDTyp                   SMALLINT,
    @Knt_GIDNumer                 INT,
    @Knt_GIDLp                    SMALLINT,
    @Knt_LimitKredytu             DECIMAL(15,2),
    @Knt_LimitKredytuWykorzystany DECIMAL(15,2),
    @Knt_KntId                    INT,
    @Knt_Ts_Export                DATETIME
 SELECT
    @Knt_GIDFirma                   = 0,
    @Knt_GIDTyp                     = 0,
    @Knt_GIDNumer                   = CONVERT(INT, @Knt_GIDNumerChr),
    @Knt_GIDLp                      = 0,
    @Knt_LimitKredytu               = CONVERT(DECIMAL(15,2),REPLACE(@Knt_LimitKredytuChr,',','.')),
    @Knt_LimitKredytuWykorzystany   = CONVERT(DECIMAL(15,2),REPLACE(@Knt_LimitKredytuWykorzystanyChr,',','.'))
 SELECT @Knt_KntId = Knt_KntId,@Knt_Ts_Export = Knt_Ts_Export FROM Cdn.Kontrahenci
   WHERE Knt_GIDTyp   = @Knt_GIDTyp
     AND Knt_GIDNumer = @Knt_GIDNumer
  IF @Knt_KntId IS NOT NULL
    BEGIN
       UPDATE Cdn.Kontrahenci  SET
                   Knt_LimitKredytuWal          = @Knt_LimitKredytuWal,
                   Knt_LimitKredytu             = @Knt_LimitKredytu,
                   Knt_LimitKredytuWykorzystany = @Knt_LimitKredytuWykorzystany,
                   Knt_Ts_Export                = @Knt_Ts_Export
              WHERE Knt_GIDNumer                 = @Knt_GIDNumer
    END
  SET NOCOUNT OFF
