Create Function CDN.IdentKsiStr (@IdentKsieg NVARCHAR(50), @IdentKsiegNumeracja NVARCHAR(50))
Returns NVARCHAR(50)
With SchemaBinding
As
Begin
 IF(LEN(ISNULL(@IdentKsieg,''))=0)
 RETURN '';
 IF( LEN(ISNULL(@IdentKsiegNumeracja, '')) > 0 )
 return CDN.GetDokNumString(@IdentKsiegNumeracja, @IdentKsieg);
 Declare @Pos Int
 Set @Pos = CDN.IdentKsiPos (@IdentKsieg)
 Return  Case When @Pos <> 0 Then Substring(@IdentKsieg, @Pos + 2, LEN(@IdentKsieg) -  @Pos - 1) Else @IdentKsieg End
End
