Create Function CDN.TimeStr (@d DateTime)
Returns Char(8)
As
Begin
 Return SubString(Convert (Char(19), @d, 120), 12, 8)
End
