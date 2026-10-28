Create Function CDN.DateTimeStr (@d DateTime)
Returns Char(19)
As
Begin
 Return Convert (Char(19), @d, 120)
End
