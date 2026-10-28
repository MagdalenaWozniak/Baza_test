CREATE Function CDN.PracNieobecDni (@PnbId int)
Returns INT
As
Begin
  DECLARE @wynik INT
  SET @wynik = 0
  DECLARE @RozliczDni INT
  SET @RozliczDni = (SELECT Tnb_RozliczDni From CDN.TypNieobec JOIN CDN.PracNieobec on Pnb_TnbId = Tnb_TnbId WHERE Pnb_PnbId = @PnbId)
  DECLARE @OkresOd DATETIME
  DECLARE @OkresDo DATETIME
  SELECT @OkresOd = Pnb_OkresOd, @OkresDo = Pnb_OkresDo FROM CDN.PracNieobec WHERE Pnb_PnbId = @PnbId
  DECLARE @PrcId INT
  DECLARE @TypDnia INT
  DECLARE @dzien DATETIME
  DECLARE @KalId INT
  SET @dzien = @OkresOd
  SELECT @PrcId = Pnb_PraId FROM CDN.PracNieobec WHERE Pnb_PnbId = @PnbId
  SELECT @KalId = Pre_KalId FROM CDN.PracEtaty WHERE Pre_PraId = @PrcId AND @OkresOd BETWEEN Pre_DataOd AND Pre_DataDo
  WHILE @dzien <= @OkresDo
  BEGIN
     SET @TypDnia = CDN.TypDnia (@PrcId, @KalId, @dzien, 2)
     IF @TypDnia=1
        SET @wynik = @wynik + 1
     SET @dzien = @dzien + 1
  END
  Return @wynik
End
