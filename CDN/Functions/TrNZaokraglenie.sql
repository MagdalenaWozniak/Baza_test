CREATE Function CDN.TrNZaokraglenie (@TrNId Int, @Typ NVARCHAR(2))
Returns Decimal (15,2)
As
Begin
 Declare @Wynik Decimal(15,2)
 Set @Wynik = 0
 declare @kkw_TrNId int;
 if exists (select * from cdn.tranag where TrN_ZwrId = @TrNId and TrN_Anulowany = 0 and TrN_Korekta=8)
  select @kkw_TrNId = trn_trnid from cdn.tranag where TrN_ZwrId = @TrNId and TrN_Anulowany = 0 and TrN_Korekta=8;
 else
  set @kkw_TrNId = NULL;
 if @kkw_TrNId is null
 begin
  If(@Typ = 'N')
   Set @Wynik =
    (Select Sum(TrV_Netto) From CDN.TraVat  Where TrV_TrNId = @TrNId And (TrV_Typ=0 or TrV_Typ=2))
    -(Select Sum(TrE_WartoscNetto) From CDN.TraElem Where TrE_TrNId = @TrNId)
  Else If(@Typ = 'B')
   Set @Wynik =
    (Select Sum(TrV_Netto + TrV_Vat) From CDN.TraVat  Where TrV_TrNId = @TrNId And TrV_Typ=0)
    -(Select Sum(TrE_WartoscBrutto) From CDN.TraElem Where TrE_TrNId = @TrNId)
  Else If(@Typ = 'NW')
   Set @Wynik =
    (Select Sum(TrV_NettoWal) From CDN.TraVat  Where TrV_TrNId = @TrNId And TrV_Typ=0)
    -(Select Sum(TrE_WartoscNettoWal) From CDN.TraElem Where TrE_TrNId = @TrNId)
  Else If(@Typ = 'B')
   Set @Wynik =
    (Select Sum(TrV_NettoWal + TrV_VatWal) From CDN.TraVat  Where TrV_TrNId = @TrNId And TrV_Typ=0)
    -(Select Sum(TrE_WartoscBruttoWal) From CDN.TraElem Where TrE_TrNId = @TrNId)
 end
 else
 begin
  If(@Typ = 'N')
   Set @Wynik =
    (
     (Select Sum(TrV_Netto) From CDN.TraVat  Where TrV_TrNId = @TrNId And (TrV_Typ=0 or TrV_Typ=2))
     +
     (Select Sum(TrV_Netto) From CDN.TraVat  Where TrV_TrNId = @kkw_TrNId And (TrV_Typ=0 or TrV_Typ=2))
    )
   - (
     (Select Sum(TrE_WartoscNetto) From CDN.TraElem Where TrE_TrNId = @TrNId)
     +
     (Select Sum(TrE_WartoscNetto) From CDN.TraElem Where TrE_TrNId = @kkw_TrNId)
    )
  Else If(@Typ = 'B')
   Set @Wynik =
    (
     (Select Sum(TrV_Netto + TrV_Vat) From CDN.TraVat  Where TrV_TrNId = @TrNId And TrV_Typ=0)
     +
     (Select Sum(TrV_Netto + TrV_Vat) From CDN.TraVat  Where TrV_TrNId = @kkw_TrNId And TrV_Typ=0)
    )
   - (
     (Select Sum(TrE_WartoscBrutto) From CDN.TraElem Where TrE_TrNId = @TrNId)
     +
     (Select Sum(TrE_WartoscBrutto) From CDN.TraElem Where TrE_TrNId = @kkw_TrNId)
    )
  Else If(@Typ = 'NW')
   Set @Wynik =
    (
     (Select Sum(TrV_NettoWal) From CDN.TraVat  Where TrV_TrNId = @TrNId And TrV_Typ=0)
     +
     (Select Sum(TrV_NettoWal) From CDN.TraVat  Where TrV_TrNId = @kkw_TrNId And TrV_Typ=0)
    )
   -
    (
     (Select Sum(TrE_WartoscNettoWal) From CDN.TraElem Where TrE_TrNId = @TrNId)
     +
     (Select Sum(TrE_WartoscNettoWal) From CDN.TraElem Where TrE_TrNId = @kkw_TrNId)
    )
  Else If(@Typ = 'B')
   Set @Wynik =
    (
     (Select Sum(TrV_NettoWal + TrV_VatWal) From CDN.TraVat  Where TrV_TrNId = @TrNId And TrV_Typ=0)
     +
     (Select Sum(TrV_NettoWal + TrV_VatWal) From CDN.TraVat  Where TrV_TrNId = @kkw_TrNId And TrV_Typ=0)
    )
   -
    (
     (Select Sum(TrE_WartoscBruttoWal) From CDN.TraElem Where TrE_TrNId = @TrNId)
     +
     (Select Sum(TrE_WartoscBruttoWal) From CDN.TraElem Where TrE_TrNId = @kkw_TrNId)
    )
 end
 Return IsNull(@Wynik, 0)
End
