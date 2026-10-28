Create Function CDN.IdentKsiPos (@IdentKsieg NVARCHAR(50))
Returns Int
With SchemaBinding
As
Begin
 Declare @L Int, @Pos Int
 Set @L = 1
 Set @Pos = 0
Set @Pos = Case
 When SubString(@IdentKsieg, 2, 1) = '/' Then 2
 When SubString(@IdentKsieg, 3, 1) = '/' Then 3
 When SubString(@IdentKsieg, 4, 1) = '/' Then 4
 When SubString(@IdentKsieg, 5, 1) = '/' Then 5
 When SubString(@IdentKsieg, 6, 1) = '/' Then 6
 When SubString(@IdentKsieg, 7, 1) = '/' Then 7
 Else 0 End
 Return Case When @Pos <> 0 And IsNumeric (Substring(@IdentKsieg, 1, @Pos-1)) <> 0 Then @Pos-1 Else 0 End
End
