CREATE  Function CDN.WartoscAtrybutuDokumentu (@IDZrodla NVARCHAR(3), @DokId int, @AtrybutKod NVARCHAR(255))
Returns NVARCHAR(255)
As
Begin
 Declare @Wynik NVARCHAR(255)
 Set @Wynik   = ''
 Set @IDZrodla = UPPER(@IDZrodla)
 if @IDZrodla='VAT'
  begin
   select @Wynik = case when DeA_Format=2 then cast(DAt_WartoscDecimal as NVARCHAR(255)) else DAt_WartoscTxt end
   from
   CDN.DokAtrybuty
   join CDN.DefAtrybuty on (DeA_DeAId=DAt_DeAId)
   where
   DAt_VaNID=@DokId and DeA_Kod=@AtrybutKod
  end
 else if @IDZrodla='TRN'
  begin
   select @Wynik = case when DeA_Format=2 then cast(DAt_WartoscDecimal as NVARCHAR(255)) else DAt_WartoscTxt end
   from
   CDN.DokAtrybuty
   join CDN.DefAtrybuty on (DeA_DeAId=DAt_DeAId)
   where
   DAt_TrNID=@DokId and DeA_Kod=@AtrybutKod
  end
 if @wynik is null or @wynik=''
  return ''
 IF (SELECT DeA_Format FROM CDN.DefAtrybuty WHERE DeA_Typ=4 AND DeA_Kod=@AtrybutKod)=4 -- formatowanie atrybutu typu data
  SET @Wynik = CONVERT( NVARCHAR(10), CONVERT ( DATETIME, CAST(@wynik AS INT) - 36163, 120 ), 120 )
 Return @Wynik
End
