Create Function CDN.PlaceKsiegInfo (@Id Int, @Typ NVARCHAR(20), @Data DateTime=Null)
Returns NVARCHAR(1000)
As
 Begin
  Declare @Wynik NVARCHAR(1000)
  -- Dane historyczne pracownika
  If @Typ = 'PrcNazwisko'
   Select @Wynik = PRE_Nazwisko
    From CDN.PracEtaty
    Where PRE_PRAId = @Id AND @Data Between PRE_DataOd And PRE_DataDo
  If @Typ = 'PrcImię'
   Select @Wynik = PRE_Imie1
    From CDN.PracEtaty
    Where PRE_PRAId = @Id AND @Data Between PRE_DataOd And PRE_DataDo
  If @Typ = 'PrcKod'
   Select @Wynik = PRE_Kod
    From CDN.PracEtaty
    Where PRE_PRAId = @Id AND @Data Between PRE_DataOd And PRE_DataDo
  -- Lokalizacja
  If @Typ = 'LokKod'
   Select @Wynik = Lok_Kod From CDN.Dzialy Left Outer Join CDN.Lokalizacje On DZL_LokId = Lok_LokId Where DZL_DZLId = @Id
  -- Konto z lokalizacji
  If @Typ = 'LokKonto'
   Select @Wynik = Lok_Konto From CDN.Dzialy Left Outer Join CDN.Lokalizacje On DZL_LokId = Lok_LokId Where DZL_DZLId = @Id
  -- Scieżka do działu
  If @Typ = 'DzlSciezka'
   Begin
    Set @Wynik = ''
    While @Id Is Not Null
     If Exists (Select * From CDN.Dzialy Where DZL_DZLId = @Id)
      Select @Id = DZL_ParentId, @Wynik = DZL_Kod + '\' + @Wynik From CDN.Dzialy Where DZL_DZLId = @Id
     Else
      Set @Id = Null
    If @Wynik <> ''
     Set @Wynik = Substring(@Wynik, 1, Len(@Wynik)-1)
   End
  -- Scieżka do działu bez roota
  If @Typ = 'DzlSciezkaKrotka'
   Begin
    Declare @ParId Int
    Set @Wynik = ''
    While @Id Is Not Null
     If Exists (Select * From CDN.Dzialy Where DZL_DZLId = @Id And DZL_ParentId Is Not Null)
      Select @Id = DZL_ParentId, @Wynik = DZL_Kod + '\' + @Wynik From CDN.Dzialy Where DZL_DZLId = @Id
     Else
      Set @Id = Null
    If @Wynik <> ''
     Set @Wynik = Substring(@Wynik, 1, Len(@Wynik)-1)
   End
  -- Konto działu
  If @Typ = 'DzlKonto'
   Select @Wynik = DZL_Konto From CDN.Dzialy Where DZL_DZLId = @Id
  -- Ścieżka do projektu
  If @Typ = 'PrjSciezka'
   Begin
    Set @Wynik = ''
    While @Id Is Not Null
     If Exists (Select * From CDN.DefProjekty Where Prj_PrjId = @Id)
      Select @Id = Prj_ParentId, @Wynik = Prj_Kod + '\' + @Wynik From CDN.DefProjekty Where Prj_PrjId = @Id
     Else
      Set @Id = Null
    If @Wynik <> ''
     Set @Wynik = Substring(@Wynik, 1, Len(@Wynik)-1)
   End
  -- Konto projektu
  If @Typ = 'PrjKonto'
   Select @Wynik = PRJ_Konto From CDN.DefProjekty Where Prj_PrjId = @Id
  Return IsNull(@Wynik, '')
 End
