Create Function CDN.Czas (@od DateTime, @do DateTime)
Returns int
As
Begin
  If @od=@do Return 1440
  Return DATEDIFF(minute,@od,@do) + case when @od>@do then 1440 else 0 end
End
