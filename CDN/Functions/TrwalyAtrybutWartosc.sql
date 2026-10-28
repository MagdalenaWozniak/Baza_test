CREATE  Function CDN.TrwalyAtrybutWartosc (@SrTId int, @AtrybutKod NVARCHAR(255))
Returns NVARCHAR(255)
As
Begin
 Declare @Wynik NVARCHAR(255)
 Set @Wynik = ''
 select @Wynik = SrA_WartoscTxt
 from
 CDN.TrwaleAtrybuty
  join CDN.DefAtrybuty on (DeA_DeAId=SrA_DeAId)
 where
 SrA_SrTId=@SrTId and DeA_Kod=@AtrybutKod
 if @wynik is null or @wynik=''
      return ''
    IF (SELECT DeA_Format FROM CDN.DefAtrybuty WHERE DeA_Typ=3 AND DeA_Kod=@AtrybutKod)=4 -- formatowanie atrybutu typu data
      SET @Wynik = CONVERT( NVARCHAR(10), CONVERT ( DATETIME, CAST(@wynik AS INT) - 36163, 120 ), 120 )
    Return @Wynik
End
