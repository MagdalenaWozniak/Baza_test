CREATE Function [CDN].[OfertaWartoscKontrahenta] (@OfDId int, @KntId int, @Col int)
 Returns decimal(15,2)
Begin
 Declare @wynik decimal(15,2)
 SELECT @wynik= SUM(case
         when @Col =0 then ISNULL(CDN.OfertyElemCeny.OfC_WartoscNetto ,CDN.OfertyElem.OfC_WartoscNetto)
         when @Col =1 then ISNULL(CDN.OfertyElemCeny.OfC_WartoscBrutto, CDN.OfertyElem.OfC_WartoscBrutto)
         when @Col =2 then ISNULL(CDN.OfertyElemCeny.OfC_WartoscNettoWal, CDN.OfertyElem.OfC_WartoscNettoWal)
         when @Col =3 then ISNULL(CDN.OfertyElemCeny.OfC_WartoscBruttoWal, CDN.OfertyElem.OfC_WartoscBruttoWal)
         else 0
        end
        )
 FROM         CDN.OfertyElem LEFT OUTER JOIN
        CDN.OfertyElemCeny ON CDN.OfertyElem.OfL_OfLId = CDN.OfertyElemCeny.OfC_OfLId
 WHERE     CDN.OfertyElem.OfL_OfDId = @OfDId AND (CDN.OfertyElemCeny.OfC_KntId = @KntId OR CDN.OfertyElemCeny.OfC_KntId IS NULL)
 Return @wynik
END
