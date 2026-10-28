Create Function CDN.DzialSciezka (@DziId Int)
Returns NVARCHAR(1000)
As
Begin
Declare @Wynik NVARCHAR(1000), @ParId Int
Set @Wynik = ''
While @DziId Is Not Null
 If Exists (Select * From CDN.Dzialy Where DZL_DZLId = @DziId)
  Select @DziId = DZL_ParentId, @Wynik = DZL_Kod + '\' + @Wynik From CDN.Dzialy Where DZL_DZLId = @DziId
 Else
  Set @DziId = Null
If @Wynik <> ''
 Set @Wynik = Substring(@Wynik, 1, Len(@Wynik)-1)
Return @Wynik
End
