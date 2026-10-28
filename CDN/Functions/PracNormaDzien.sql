CREATE Function CDN.PracNormaDzien (@PrcId int, @KalId int, @dzien DATETIME)
Returns DATETIME
Begin
  DECLARE @norma DATETIME
  SET @norma = 0
  DECLARE @Czas DATETIME
  DECLARE @DoGodziny DATETIME
  DECLARE @WliczStrefeDoCzasu INT
  IF EXISTS (SELECT 1 FROM CDN.PracPlanDni WHERE Ppl_PraId=@PrcId AND Ppl_Data = @dzien)
  BEGIN
 SELECT @norma = @norma + CASE Dst_UwzglCzasPracy WHEN 1 THEN  (Pgl_DoGodziny - Pgl_OdGodziny) ELSE 0 END  FROM CDN.PracPlanDni join cdn.pracplandnigodz on ppl_pplid = pgl_pplid  JOIN CDN.DefinicjeStref ON PGL_Strefa = Dst_DstId WHERE Ppl_PraId=@PrcId AND Ppl_Data = @dzien
  END
  ELSE IF EXISTS (SELECT 1 FROM CDN.KalendDni WHERE Kad_Kalid=@KalId AND Kad_Data = @dzien)
  BEGIN
 SELECT @norma = @norma + CASE Dst_UwzglCzasPracy WHEN 1 THEN  (Kdg_DoGodziny - Kdg_OdGodziny) ELSE 0 END  FROM CDN.KalendDni join cdn.kalenddnigodz on kad_kadid = kdg_kadid JOIN CDN.DefinicjeStref ON Kdg_Strefa = Dst_DstId WHERE Kad_Kalid=@KalId AND Kad_Data = @dzien
  END
  ELSE
  BEGIN
     DECLARE @TypDnia INT
     SET @TypDnia = CDN.TypDnia (@PrcId , @KalId , @dzien,2)
     IF @TypDnia = 1 or @TypDnia = 0
       SELECT @norma = CASE Kal_NormaKalendarz WHEN 0 THEN Kal_NormaDobowa ELSE CONVERT (DATETIME, '1900-01-01 08:00:00.000', 120) END FROM CDN.Kalendarze WHERE Kal_Kalid=@KalId
  END
  RETURN @norma
End
