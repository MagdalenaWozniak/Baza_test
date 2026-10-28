CREATE FUNCTION CDN.Text2TableVarchar ( @WieleId TEXT )
RETURNS @IdTable TABLE ( IdIdentity INT IDENTITY(1,1), NextIdVarchar NVARCHAR(255) )
AS
BEGIN
    -- tablica TrN_TrNId pierwotnych
    DECLARE
      @MaxNr   INT,
      @Nr   INT,
      @Znak   NVARCHAR(1),
      @KolejnyIdCHR  NVARCHAR(30)
    SELECT
      @Nr = 0,
      @KolejnyIdCHR = '',
      @MaxNr = DATALENGTH(@WieleId)
    IF @MaxNr = 0
      RETURN
    WHILE 1=1
      BEGIN
        SET @Nr = @Nr + 1
        IF @Nr > @MaxNr
          BREAK
        SET @Znak = SUBSTRING(@WieleId, @Nr, 1)
        IF @Znak <> ','
          SET @KolejnyIdCHR = @KolejnyIdCHR + @Znak
        IF @Znak = ',' OR @Nr = @MaxNr
          BEGIN
            INSERT INTO @IdTable ( NextIdVarchar ) SELECT @KolejnyIdChr
            SET @KolejnyIdCHR = ''
            IF @Nr = @MaxNr
              BREAK
          END
      END
  RETURN
END
