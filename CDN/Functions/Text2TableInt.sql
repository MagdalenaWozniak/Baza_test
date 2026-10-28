CREATE FUNCTION CDN.Text2TableInt ( @WieleId TEXT )
RETURNS @IdTable TABLE ( IdIdentity INT IDENTITY(1,1), NextIdInt INT )
AS
BEGIN
    -- tablica TrN_TrNId pierwotnych
    DECLARE
      @MaxNr   INT,
      @Nr   INT,
      @Znak   NVARCHAR(1),
      @KolejnyIdCHR  NVARCHAR(30),
      @KolejnyIdINT  INT
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
        IF @Znak NOT IN ('0','1','2','3','4','5','6','7','8','9', ',', ' ','-')
          BEGIN
            -- komunikat o błędzie, że niedozwolony znak i break.
            -- na razie continue
            CONTINUE
          END
        IF @Znak = ' ' AND @Nr <> @MaxNr
          CONTINUE
        IF @Znak IN ('0','1','2','3','4','5','6','7','8','9','-')
          SET @KolejnyIdCHR = @KolejnyIdCHR + @Znak
        IF @Znak = ',' OR @Nr = @MaxNr
          BEGIN
            SET @KolejnyIdINT =  CONVERT(INT, @KolejnyIdCHR)
            IF @KolejnyIdINT <> 0
              BEGIN
                INSERT INTO @IdTable ( NextIdInt ) SELECT @KolejnyIdINT
                SET @KolejnyIdCHR = ''
               END
              IF @Nr = @MaxNr
                BREAK
          END
      END
  RETURN
END
