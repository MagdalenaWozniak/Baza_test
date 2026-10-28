Create Function CDN.DateStr (@d DateTime)
Returns Char(10)
As
Begin
 Return Convert (Char(10), @d, 120)
End
