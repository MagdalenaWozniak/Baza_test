Create Function CDN.IdentKsiNr (@IdentKsieg NVARCHAR(50), @IdentKsiegNumeracja NVARCHAR(50))
Returns Int
With SchemaBinding
As
Begin
 IF(LEN(ISNULL(@IdentKsieg,''))=0)
 RETURN 0;
 IF( LEN(ISNULL(@IdentKsiegNumeracja, '')) > 0 )
 return CDN.GetDokNumber(@IdentKsiegNumeracja, @IdentKsieg);
 Return Cast (Substring(@IdentKsieg, 1, CDN.IdentKsiPos (@IdentKsieg)) As Int)
End
