CREATE Function CDN.TypDnia (@PrcId int, @KalId int, @dzien DATETIME, @typkalend int)
Returns INT
Begin
  DECLARE @ResTyp INT
  SET @ResTyp = 0
  IF @typkalend=3
     SET @ResTyp = ISNULL((SELECT 1 FROM CDN.PracPracaDni WHERE Ppr_PraId=@PrcId AND Ppr_Data = @dzien),-1)
  IF @typkalend=2 or @ResTyp<0
     SET @ResTyp = ISNULL((SELECT Ppl_TypDnia FROM CDN.PracPlanDni WHERE Ppl_PraId=@PrcId AND Ppl_Data = @dzien),-1)
  IF @typkalend=1 or @ResTyp<0
  IF @typkalend=1 or @ResTyp<0
  BEGIN
     IF EXISTS (SELECT 1 FROM CDN.KalendDni WHERE Kad_KalId=@KalId AND Kad_Data = @dzien)
        SET @ResTyp = (SELECT Kad_TypDnia FROM CDN.KalendDni WHERE Kad_KalId=@KalId AND Kad_Data = @dzien)
     ELSE
     BEGIN
        DECLARE @wolny INT
        SET @wolny = CDN.CzyDzienWolny2(@dzien)
        IF @wolny=0
           SET @ResTyp = 1
        ELSE
           SET @ResTyp = 0
     END
  END
  RETURN @ResTyp
End
