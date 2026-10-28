Create Function CDN.AddTime (@from DateTime, @minutes int)
Returns DATETIME
As
Begin
  DECLARE @Zero DATETIME
  SET @Zero = CONVERT(datetime, '1899-12-30 00:00:00.000', 120)
  Return DATEADD(minute,(DATEDIFF(minute,@Zero,@From)+@minutes) % 1440,@Zero)
End
