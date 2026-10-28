CREATE Function CDN.PracNieobecDniOkres (@OD DATETIME, @DO DATETIME, @PrcId INT)
Returns INT
As
Begin
  DECLARE @wynik INT
  SET @wynik = 0
  DECLARE @TypDnia INT
  DECLARE @dzien DATETIME
  DECLARE @KalId INT
  SET @dzien = @OD
  SELECT @KalId = Pre_KalId FROM CDN.PracEtaty WHERE Pre_PraId = @PrcId AND @OD BETWEEN Pre_DataOd AND Pre_DataDo
  WHILE @dzien <= @DO
  BEGIN
     SET @TypDnia = CDN.TypDnia (@PrcId, @KalId, @dzien, 2)
     IF @TypDnia=1
        SET @wynik = @wynik + 1
     SET @dzien = @dzien + 1
  END
  Return @wynik
End
