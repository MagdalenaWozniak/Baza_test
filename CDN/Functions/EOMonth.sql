Create Function CDN.EOMonth (@RokMies Int)
Returns Datetime
As
Begin
 Declare @DataOut Datetime
 Declare @Rok Int, @Miesiac Int, @DataStr Char(10)
 Set @Rok = Floor(@RokMies / 100)
 Set @Miesiac = @RokMies % 100
 Set @DataStr = Str(@Rok,4) + '-' + Replace(Str(@Miesiac,2), ' ', '0') + '-01'
 Set @DataOut = Convert (datetime, @DataStr, 120)
 Set @DataOut = DateAdd(month, 1, @DataOut)
 Set @DataOut = DateAdd(day, -1, @DataOut)
 Return @DataOut
End
