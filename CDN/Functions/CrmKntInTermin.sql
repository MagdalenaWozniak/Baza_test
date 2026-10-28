CREATE FUNCTION cdn.CrmKntInTermin(
      @FcKId  INT,
      @DataSp DATETIME)
  RETURNS     INT
  AS
BEGIN
    DECLARE @od tinyint, @do tinyint
    SET @od = 0
    SET @do = 0
    DECLARE @TerminOd datetime, @TerminDo datetime
    SET @TerminOd  = @DataSp
    SET @TerminDo  = @DataSp
 SELECT DISTINCT @od=FcK_ObowiazujeOd, @do=FcK_ObowiazujeDo, @TerminOd=FcK_TerminOd, @TerminDo=FcK_TerminDo
 FROM cdn.FaCyklKnt
 WHERE FCK_FcKId = @FcKId
    IF @od = 1 AND DATEDIFF(day, @TerminOd, @DataSp) < 0
  RETURN 1  --'Termin obowiązywania umowy nie rozpoczął się!'
    IF @do = 1 AND DATEDIFF(day, @TerminDo, @DataSp) > 0
  RETURN 2  -- 'Termin obowiązywania umowy już minął!'
    RETURN 0;
END
