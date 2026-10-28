Create  Function CDN.RokMiesiacToDateTime(@DokMiesiac Int)
Returns Datetime
As
Begin
  Declare @Result Datetime, @Rok Int, @Mc Int
  Set @Rok    = Floor(@DokMiesiac / 100)
 Set @Mc     = @DokMiesiac % 100
  Set @Result = Convert (Datetime, Str(@Rok,4)+'-'+Replace(Str(@Mc,2),' ','0')+'-01', 120)
 Return @Result
End
