create  Function CDN.TraKwoty (@TraId Int, @Typ NVARCHAR(4), @Stawka Numeric(5,2), @Flaga Smallint)
Returns Numeric(15,2)
As
Begin
  Declare @Kwota Numeric(15,2), @TrEId Int, @TrNId Int, @Zaokraglenie Decimal(15,2)
  Set @Kwota = 0
  If @Typ = 'PN'
    Begin
      --Select @TrNId = TrE_TrNId, @Kwota = IsNull(Sum(TrE_WartoscNetto),0) From CDN.TraElem
      --Where (TrE_Stawka = @Stawka Or @Stawka Is Null) And (TrE_Flaga = @Flaga Or @Flaga Is Null)
      --And TrE_TrEId = @TraId
      --Group By TrE_TrNId
  Select @TrNId = TrNId, @Kwota = IsNull(Sum(TrE_WartoscNetto),0) From
  (
   select TrE_TrNId as TrNId, TrE_WartoscNetto from CDN.TraElem
   Where (TrE_Stawka = @Stawka Or @Stawka Is Null) And (TrE_Flaga = @Flaga Or @Flaga Is Null)
   And TrE_TrEId = @TraId
      union all
   Select TrN_ZwrId as TrNId, TrE_WartoscNetto From CDN.TraElem join CDN.TraNag on TrE_TrNId = TrN_TrNid
   Where (TrE_Stawka = @Stawka Or @Stawka Is Null) And (TrE_Flaga = @Flaga Or @Flaga Is Null)
   and TrN_Anulowany = 0 and TrN_Korekta = 8 and TrE_ZwrId = @TraId
  ) fa group by TrNId;
  Set @Zaokraglenie = CDN.TrNZaokraglenie (@TrNId, 'N')
  If (@Zaokraglenie <> 0)
  Begin
   Select @TrEId = Min(TrE_TrEId) From CDN.TraElem Where TrE_TrNId = @TrNId
   If @TrEId = @TraId
    Set @Kwota = @Kwota + @Zaokraglenie
  End
    End
  If @Typ = 'PNW'
    Begin
      Select @TrNId = TrE_TrNId, @Kwota = IsNull(Sum(TrE_WartoscNettoWal),0) From CDN.TraElem
      Where (TrE_Stawka = @Stawka Or @Stawka Is Null) And (TrE_Flaga = @Flaga Or @Flaga Is Null)
      And TrE_TrEId = @TraId
      Group By TrE_TrNId
      Set @Zaokraglenie = CDN.TrNZaokraglenie (@TrNId, 'NW')
      If (@Zaokraglenie <> 0)
        Begin
          Select @TrEId = Min(TrE_TrEId) From CDN.TraElem Where TrE_TrNId = @TrNId
          If @TrEId = @TraId
            Set @Kwota = @Kwota + @Zaokraglenie
        End
    End
  If @Typ = 'PB'
    Begin
      --Select @TrNId = TrE_TrNId, @Kwota = IsNull(Sum(TrE_WartoscBrutto),0) From CDN.TraElem
      --Where (TrE_Stawka = @Stawka Or @Stawka Is Null) And (TrE_Flaga = @Flaga Or @Flaga Is Null)
      --And TrE_TrEId = @TraId
      --Group By TrE_TrNId
  Select @TrNId = TrNId, @Kwota = IsNull(Sum(TrE_WartoscBrutto),0) From
  (
  select TrE_TrNId as TrNId, TrE_WartoscBrutto from CDN.TraElem
  Where (TrE_Stawka = @Stawka Or @Stawka Is Null) And (TrE_Flaga = @Flaga Or @Flaga Is Null)
  And TrE_TrEId = @TraId
     union all
  Select TrN_ZwrId as TrNId, TrE_WartoscBrutto From CDN.TraElem join CDN.TraNag on TrE_TrNId = TrN_TrNid
  Where (TrE_Stawka = @Stawka Or @Stawka Is Null) And (TrE_Flaga = @Flaga Or @Flaga Is Null)
  and TrN_Anulowany = 0 and TrN_Korekta = 8 and TrE_ZwrId = @TraId
  ) fa group by TrNId;
  Set @Zaokraglenie = CDN.TrNZaokraglenie (@TrNId, 'B')
  If (@Zaokraglenie <> 0)
  Begin
   Select @TrEId = Min(TrE_TrEId) From CDN.TraElem Where TrE_TrNId = @TrNId
   If @TrEId = @TraId
    Set @Kwota = @Kwota + @Zaokraglenie
  End
    End
  If @Typ = 'PBW'
    Begin
      Select @TrNId = TrE_TrNId, @Kwota = IsNull(Sum(TrE_WartoscBruttoWal),0) From CDN.TraElem
      Where (TrE_Stawka = @Stawka Or @Stawka Is Null) And (TrE_Flaga = @Flaga Or @Flaga Is Null)
      And TrE_TrEId = @TraId
      Group By TrE_TrNId
      Set @Zaokraglenie = CDN.TrNZaokraglenie (@TrNId, 'BW')
      If (@Zaokraglenie <> 0)
        Begin
          Select @TrEId = Min(TrE_TrEId) From CDN.TraElem Where TrE_TrNId = @TrNId
          If @TrEId = @TraId
            Set @Kwota = @Kwota + @Zaokraglenie
        End
    End
  If @Typ = 'PV'
      Select @Kwota = CDN.TraKwoty (@TraId, 'PB', @Stawka, @Flaga) - CDN.TraKwoty (@TraId, 'PN', @Stawka, @Flaga)
  If @Typ = 'PVW'
      Select @Kwota = CDN.TraKwoty (@TraId, 'PBW', @Stawka, @Flaga) - CDN.TraKwoty (@TraId, 'PNW', @Stawka, @Flaga)
  If @Typ = 'N'
    Select @Kwota = Sum(TrV_Netto)  From CDN.fnTraVat(@TraId)
    Where (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null)
  If @Typ = 'NW'
    Select @Kwota = Sum(TrV_NettoWal)  From CDN.fnTraVat(@TraId)
    Where (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null)
  If @Typ = 'B'
    Select @Kwota = Sum(TrV_Brutto) From CDN.fnTraVat(@TraId)
    Where (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null)
  If @Typ = 'BW'
    Select @Kwota = Sum(TrV_BruttoWal) From CDN.fnTraVat(@TraId)
    Where (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null)
  If @Typ = 'V'
    Select @Kwota = Sum(TrV_Vat)    From CDN.fnTraVat(@TraId)
    Where (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null)
  If @Typ = 'VW'
    Select @Kwota = Sum(TrV_VatWal)    From CDN.fnTraVat(@TraId)
    Where (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null)
  If @Typ = 'ZPN'
    Select @Kwota = Sum(CDN.TraKwoty (ZalE.TrE_TrEId, 'PN', @Stawka, @Flaga))
    From CDN.TraElem ZalE
    Join CDN.TraNag ZalN On ZalE.TrE_TrNId = ZalN.TrN_TrNId
    JOIN CDN.TraNagRelacje REL2 On ZalN.TrN_TrNId = REL2.TrR_TrNId AND REL2.Trr_Flaga=1
    Join CDN.TraNag PFN On PFN.TrN_TrNId = REL2.TrR_FaId
    JOIN CDN.TraNagRelacje REL On PFN.TrN_TrNId = REL.TrR_TrNId
    Join CDN.TraElem FinE On FinE.TrE_TrNId = REL.TrR_FaId And FinE.TrE_LpPow = ZalE.TrE_LpPow
    Where FinE.TrE_TrEId = @TraId
  If @Typ = 'ZPNW'
    Select @Kwota = Sum(CDN.TraKwoty (ZalE.TrE_TrEId, 'PNW', @Stawka, @Flaga))
    From CDN.TraElem ZalE
    Join CDN.TraNag ZalN On ZalE.TrE_TrNId = ZalN.TrN_TrNId
    JOIN CDN.TraNagRelacje REL2 On ZalN.TrN_TrNId = REL2.TrR_TrNId AND REL2.Trr_Flaga=1
    Join CDN.TraNag PFN On PFN.TrN_TrNId = REL2.TrR_FaId
    JOIN CDN.TraNagRelacje REL On PFN.TrN_TrNId = REL.TrR_TrNId
    Join CDN.TraElem FinE On FinE.TrE_TrNId = REL.TrR_FaId And FinE.TrE_LpPow = ZalE.TrE_LpPow
    Where FinE.TrE_TrEId = @TraId
  If @Typ = 'ZPB'
    Select @Kwota = Sum(CDN.TraKwoty (ZalE.TrE_TrEId, 'PB', @Stawka, @Flaga))
    From CDN.TraElem ZalE
    Join CDN.TraNag ZalN On ZalE.TrE_TrNId = ZalN.TrN_TrNId
    JOIN CDN.TraNagRelacje REL2 On ZalN.TrN_TrNId = REL2.TrR_TrNId AND REL2.Trr_Flaga=1
    Join CDN.TraNag PFN On PFN.TrN_TrNId = REL2.TrR_FaId
    JOIN CDN.TraNagRelacje REL On PFN.TrN_TrNId = REL.TrR_TrNId
    Join CDN.TraElem FinE On FinE.TrE_TrNId = REL.TrR_FaId And FinE.TrE_LpPow = ZalE.TrE_LpPow
    Where FinE.TrE_TrEId = @TraId
  If @Typ = 'ZPBW'
    Select @Kwota = Sum(CDN.TraKwoty (ZalE.TrE_TrEId, 'PBW', @Stawka, @Flaga))
    From CDN.TraElem ZalE
    Join CDN.TraNag ZalN On ZalE.TrE_TrNId = ZalN.TrN_TrNId
    JOIN CDN.TraNagRelacje REL2 On ZalN.TrN_TrNId = REL2.TrR_TrNId AND REL2.Trr_Flaga=1
    Join CDN.TraNag PFN On PFN.TrN_TrNId = REL2.TrR_FaId
    JOIN CDN.TraNagRelacje REL On PFN.TrN_TrNId = REL.TrR_TrNId
    Join CDN.TraElem FinE On FinE.TrE_TrNId = REL.TrR_FaId And FinE.TrE_LpPow = ZalE.TrE_LpPow
    Where FinE.TrE_TrEId = @TraId
  If @Typ = 'ZPV'
    Select @Kwota = Sum(CDN.TraKwoty (ZalE.TrE_TrEId, 'PV', @Stawka, @Flaga))
    From CDN.TraElem ZalE
    Join CDN.TraNag ZalN On ZalE.TrE_TrNId = ZalN.TrN_TrNId
    JOIN CDN.TraNagRelacje REL2 On ZalN.TrN_TrNId = REL2.TrR_TrNId AND REL2.Trr_Flaga=1
    Join CDN.TraNag PFN On PFN.TrN_TrNId = REL2.TrR_FaId
    JOIN CDN.TraNagRelacje REL On PFN.TrN_TrNId = REL.TrR_TrNId
    Join CDN.TraElem FinE On FinE.TrE_TrNId = REL.TrR_FaId And FinE.TrE_LpPow = ZalE.TrE_LpPow
    Where FinE.TrE_TrEId = @TraId
  If @Typ = 'ZPVW'
    Select @Kwota = Sum(CDN.TraKwoty (ZalE.TrE_TrEId, 'PVW', @Stawka, @Flaga))
    From CDN.TraElem ZalE
    Join CDN.TraNag ZalN On ZalE.TrE_TrNId = ZalN.TrN_TrNId
    JOIN CDN.TraNagRelacje REL2 On ZalN.TrN_TrNId = REL2.TrR_TrNId AND REL2.Trr_Flaga=1
    Join CDN.TraNag PFN On PFN.TrN_TrNId = REL2.TrR_FaId
    JOIN CDN.TraNagRelacje REL On PFN.TrN_TrNId = REL.TrR_TrNId
    Join CDN.TraElem FinE On FinE.TrE_TrNId = REL.TrR_FaId And FinE.TrE_LpPow = ZalE.TrE_LpPow
    Where FinE.TrE_TrEId = @TraId
  If @Typ = 'ZN'
    Select @Kwota = Sum(-TrV_Netto)  From CDN.TraVat
    Where TrV_TrNId = @TraId And (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null) And TrV_Typ=1
  If @Typ = 'ZNW'
    Select @Kwota = Sum(-TrV_NettoWal)  From CDN.TraVat
    Where TrV_TrNId = @TraId And (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null) And TrV_Typ=1
  If @Typ = 'ZB'
    Select @Kwota = Sum(-TrV_Netto-TrV_Vat)  From CDN.TraVat
    Where TrV_TrNId = @TraId And (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null) And TrV_Typ=1
  If @Typ = 'ZBW'
    Select @Kwota = Sum(-TrV_NettoWal-TrV_VatWal)  From CDN.TraVat
    Where TrV_TrNId = @TraId And (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null) And TrV_Typ=1
  If @Typ = 'ZV'
    Select @Kwota = Sum(-TrV_Vat)  From CDN.TraVat
    Where TrV_TrNId = @TraId And (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null) And TrV_Typ=1
  If @Typ = 'ZVW'
    Select @Kwota = Sum(-TrV_VatWal)  From CDN.TraVat
    Where TrV_TrNId = @TraId And (TrV_Stawka = @Stawka Or @Stawka Is Null) And (TrV_Flaga = @Flaga Or @Flaga Is Null) And TrV_Typ=1
  Return IsNull(@Kwota,0)
End
