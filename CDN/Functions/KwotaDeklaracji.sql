Create Function CDN.KwotaDeklaracji (@DkNId Int)
Returns Decimal (15,2)
As
Begin
  Declare @Wynik      Decimal(15,2)
  Declare @Numer      Int
  Declare @Kwartalnie Int
  Declare @Rok        Int
  Declare @Miesiac    Int
  Declare @MM_OD      Int
  Declare @Finalna    Int
  Declare @TypDeklar  Int
  Declare @PraID   Int
  Declare @Wersja     Int
  Declare @Typ        Int
  Declare @RokMiesiac Int
 Set @Wynik = 0.00
 SELECT  @RokMiesiac = DkN_RokMiesiac,
                @Rok        = (DkN_RokMiesiac-DkN_RokMiesiac%100) / 100,
    @Miesiac    = DkN_RokMiesiac%100,
    @Numer      = DkN_Numer,
    @Finalna = DkN_Finalna,
    @TypDeklar = DkN_TypDeklar,
                @Wersja     = DkN_Wersja,
    @PraID  = DkN_PraID
 FROM  CDN.DeklNag
 WHERE
    DkN_DkNID = @DkNId
 -- nie jest to VAT-7, PIT-28, PIT-36, PIT-36L, CIT-8, VAT-9M lub nie ma korekt, liczymy w starym dobrym szybkim stylu
 IF @TypDeklar NOT IN(1, 2, 4, 8, 12, 20, 15, 16, 17, 43, 401, 402, 403, 404) Or @TypDeklar NOT IN(402, 403) and @Numer = 0 and @Finalna = 1
  Begin
   select @Typ = DkE_WartoscL from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 10000
            if (@TypDeklar = 1)  -- VAT7D
                begin
     if (@Wersja between 10 and 20 and @Typ = 1)
     begin
      if exists(select * from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 14700 and DkE_WartoscL <> 0.00 )
       begin
        select @Wynik = DkE_WartoscL from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 14700
       end
      else
       begin
        select @Wynik = -1*DkE_WartoscL from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 15100
       end
     end
     else
     begin
      set @Wynik = CDN.KwotaKsiegDekl (@DkNId, 14700) - CDN.KwotaKsiegDekl (@DkNId, 15100)
     end
                end
            else
                begin
           Select @Wynik = Sum(-BZd_Kierunek * BZd_KwotaSys) From CDN.BnkZdarzenia Where BZd_DokumentTyp = 6 And BZd_DokumentId = @DkNId
                end
    Return IsNull(@Wynik,0)
  End
 IF @TypDeklar=43
  BEGIN
   select @Wynik =   DkE_WartoscL from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 14700
   Return IsNull(@Wynik,0)
  END
 IF @TypDeklar=401
  BEGIN
   select @Wynik =   DkE_WartoscL from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 202
   Return IsNull(@Wynik,0)
  END
 IF @TypDeklar=402 or @TypDeklar=403
   BEGIN
  If @TypDeklar=402 and @RokMiesiac >= 201507
   BEGIN
    select @Wynik =   sum(DkE_WartoscL) from CDN.DeklElem where DkE_DkNID = @DkNId and (DkE_Numer = 116 or DkE_Numer = 111)
   END
  ELSE
   BEGIN
    select @Wynik =   DkE_WartoscL from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 116
   END
  Return IsNull(@Wynik,0)
   END
 IF @TypDeklar=1 -- vat-7
        Begin
            select @Typ = DkE_WartoscL from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 10000
            if (@TypDeklar = 1 and @Wersja >= 10 and @Typ = 1)  -- VAT7D
                begin
                    if exists(select * from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 14700 and DkE_WartoscL <> 0.00 )
                        begin
                            select @Wynik = DkE_WartoscL from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 14700
                        end
                    else
                        begin
                            select @Wynik = -1*DkE_WartoscL from CDN.DeklElem where DkE_DkNID = @DkNId and DkE_Numer = 15100
                        end
                end
            else
                begin
                  set @Wynik = CDN.KwotaKsiegDekl (@DkNId, 14700)- CDN.KwotaKsiegDekl (@DkNId, 15100)
                end
       End
   Else -- korekta pit-28, PIT-36, PIT-36L, CIT-8
  IF @PraID IS NULL
   Begin
    Select @Wynik = Sum(-BZd_Kierunek * BZd_KwotaSys)
    From CDN.BnkZdarzenia left join  CDN.DeklNag ON (BZd_DokumentId=DkN_DkNID)
    Where
       DkN_RokMiesiac = (100*@Rok+@Miesiac)
       and DkN_Numer between 0 and @Numer
       and DkN_TypDeklar = @TypDeklar
       and BZd_DokumentTyp = 6
   end
  else
   Begin
    Select @Wynik = Sum(-BZd_Kierunek * BZd_KwotaSys)
    From CDN.BnkZdarzenia left join  CDN.DeklNag ON (BZd_DokumentId=DkN_DkNID)
    Where
       DkN_RokMiesiac = (100*@Rok+@Miesiac)
       and DkN_Numer between 0 and @Numer
       and DkN_TypDeklar = @TypDeklar
       and BZd_DokumentTyp = 6
       and DkN_PraID = @PraID -- jeżeli pit-28 to trzeba jeszcze wziąć pod uwagę właściciela
   End
 Return IsNull(@Wynik,0)
End
