CREATE FUNCTION CDN.Text2TableDecimal ( @WieleId TEXT )
RETURNS @IdTable TABLE ( IdIdentity INT IDENTITY(1,1), NextIdDecimal DECIMAL(20,4) )
AS
BEGIN
    -- tablica TrN_TrNId pierwotnych
    DECLARE
      @MaxNr   INT,
      @Nr   INT,
      @Znak   NVARCHAR(1),
      @KolejnyIdCHR  NVARCHAR(30),
      @KolejnyIdDecimal DECIMAL(20,4)
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
        IF @Znak NOT IN ('0','1','2','3','4','5','6','7','8','9',',','.',' ','-')
          BEGIN
            -- komunikat o błędzie, że niedozwolony znak i break.
            -- na razie continue
            CONTINUE
          END
        IF @Znak = ' ' AND @Nr <> @MaxNr
          CONTINUE
        IF @Znak IN ('0','1','2','3','4','5','6','7','8','9','.','-')
          SET @KolejnyIdCHR = @KolejnyIdCHR + @Znak
        IF @Znak = ',' OR @Nr = @MaxNr
          BEGIN
            SET @KolejnyIdDecimal =  CONVERT(DECIMAL(20,4), @KolejnyIdCHR)
              BEGIN
                INSERT INTO @IdTable ( NextIdDecimal ) SELECT @KolejnyIdDecimal
                SET @KolejnyIdCHR = ''
               END
              IF @Nr = @MaxNr
                BREAK
          END
      END
  RETURN
END
