CREATE Function CDN.DetalZestawienie
(
  @Data                Char(10),    -- Data w postaci stringowej
  @Ident               Int,         -- Id operatora lub Id stanowiska
  @TypRaportu          TinyInt,     -- 1 - zestawienie operatora, 2 - zestawienie stanowiska
  @Ope_Kasa            NVARCHAR(20)  -- akronim kasy przypisanej do operatora
)
Returns @DetZestawienie Table
(
  DZe_FPlId       Int,
  DZe_FPlNumer    Int,
  DZe_FPlDetNazwa NVARCHAR(20),     -- nazwy form płatności z DETAL-u
  DZe_BZdKwotaSys Decimal(15,2),   -- dokumenty wg form platnosci
  DZe_BZpKwotaSys Decimal(15,2)    -- Kwota zapisów z dnia z podziałem na typy (gotówka, przelew, karta)
 )
As
Begin
 Declare @DataDT           DateTime      -- data skonwertowana do DateTime
 Declare @i                Int           -- do pętli dla 5-ciu form płatności
 Declare @i2               Int           -- do odnalezienia wiersza dla raportu i typu
 Declare @FPlId            Int           -- Id z formy płatności z DETAL-u
 Declare @FPlNazwa         NVARCHAR(20)   -- Nazwa formy płatności
 Declare @FPlTyp           Int           -- Typ formy płatności
 Declare @FPlBRaId         Int           -- Id Rachunku (rejestru) skojarzonego z formą płatności lub z operatora
 Declare @BZdKwota         Decimal(15,2) -- kwota ze zdarzeń KB
 Declare @BZpKwota         Decimal(15,2) -- kwota z zapisów KB
declare @DetZestawienieTmp Table
(
  DZe_FPlId       Int,
  DZe_FPlNumer    Int,
  DZe_FPlDetNazwa NVARCHAR(20),     -- nazwy form płatności z DETAL-u
  DZe_FPlTyp      Int,             -- typ formy płatności (gotówka, przelew, karta)
  DZe_FPlBRaId    Int,             -- Id rachunku (bezpośrednio z formy płatności lub domyślny operatora)
  DZe_BZdKwotaSys Decimal(15,2),   -- dokumenty wg form platnosci
  DZe_BZpKwotaSys Decimal(15,2)    -- Kwota zapisów z dnia z podziałem na typy (gotówka, przelew, karta)
 )
 -- data DateTime
 Set @DataDT = Convert (DateTime, @Data, 120)
 -- pętla po formach płatności z detalu
 Set @i = 0
 While @i <= 5
  Begin
   Set @i = @i + 1
   -- Id koeljnych form płatności dla DETAL-u
   Set @FPlId = 0
   Select
     @FPlId = IsNull(Case When IsNumeric(Fir_Wartosc) = 1 Then Cast (Fir_Wartosc As Int) Else 0 End, 0)
    From CDN.Firma
    Where Fir_Numer = 1600 + @i
   -- jeśli nie wypełniona, to dalej
   If @FPlId = 0 Continue
   -- nazwa formy płatności
   Set @FPlNazwa = ''
   Select
     @FPlNazwa = IsNull(Cast (Fir_Wartosc As NVARCHAR(20)), '')
    From CDN.Firma
    Where Fir_Numer = 1605 + @i
   Select
      @FPlTyp = FPl_Typ
    From cdn.FormyPlatnosci WHERE FPl_FPlId = @FPlId
   -- Id rachunku (rejestru) dla danej formy płatnosci
   Set @FPlBraId = null
   -- bezośrednio z formy płatności
   Select
     @FPlBraId = FPl_BRaId
   From CDN.FormyPlatnosci
   Where FPl_FPlId = @FPlId
   -- Jeśli nie istnieje (wybrany -domyślny-, to Id rachunku (rejestru) z domyślnego rejestru operatora
   If @FPlBraId Is null
     Select TOP 1
       @FPlBraId = Bra_BRaId
     From CDN.BnkRachunki
     Where BRa_Akronim = @Ope_Kasa
   -- Jeśli nie istnieje, to 0 (nie będą liczone kwoty zapisów dla takiej formy płatności)
   IF @FPlBraId IS null
     Select
        @FPlBraId = 0
   -- zdarzenia (Dokumenty)
   -- kwota operatora (filtr na operatora)
   If @TypRaportu = 1
    Select @BZdKwota = IsNull( Sum(BZd_Kierunek * BZd_KwotaSys), 0)
     From CDN.BnkZdarzenia
     Where BZd_DataDok = @DataDT And BZd_OpeModId = @Ident And BZd_FPlId = @FPlId
   -- kwota stanowiska (filtr na stanowisko)
   Else If @TypRaportu = 2
    Select @BZdKwota = IsNull( Sum(BZd_Kierunek * BZd_KwotaSys), 0)
     From CDN.BnkZdarzenia
     Where BZd_DataDok = @DataDT And BZd_StaModId = @Ident And BZd_FPlId = @FPlId
   -- kwota formy płatności będzie na pewno w nowym wierszu. Kwoty z zapisów i z raportów będą w nowym wierszu lub w wierszu istniejący (o takim samym tymie i rejestrze)
   Insert InTo @DetZestawienieTmp Values (@FPlId, @i, @FPlNazwa, @FPlTyp, @FPlBraId, @BZdKwota, 0 )
   -- Zapisy (Dokumenty)
   Set @BZpKwota = 0
   If @TypRaportu = 1
    Select @BZpKwota = IsNull( Sum(BZp_Kierunek * BZp_KwotaSys) , 0)
     From CDN.BnkZapisy
     Where BZp_DataDok = @DataDT And BZp_OpeModId = @Ident And BZp_BRaId = @FPlBRaId And BZp_Typ = @FPlTyp
   Else If @TypRaportu = 2
    Select @BZpKwota = IsNull( Sum(BZp_Kierunek * BZp_KwotaSys) , 0)
     From CDN.BnkZapisy
     Where BZp_DataDok = @DataDT And BZp_StaModId = @Ident And BZp_BRaId = @FPlBRaId And BZp_Typ = @FPlTyp
   SELECT TOP 1
     @i2 = DZe_FPlNumer
   FROM @DetZestawienieTmp
   WHERE DZe_FPlTyp   = @FPlTyp
     AND DZe_FPlBraId = @FPlBRaId
   ORDER BY DZe_FPlNumer
   IF @I2 IS NOT NULL
     Update @DetZestawienieTmp Set
       DZe_BZpKwotaSys = @BZpKwota
     Where DZe_FPlNumer = @i2
  End  -- koniec pętli While po formach płatności
   -- Suma Końcowa
   Insert InTo @DetZestawienieTmp ( DZe_FPlId, DZe_FPlNumer, DZe_FPlDetNazwa, DZe_FPLTyp, DZe_FPlBRaId,     DZe_BZdKwotaSys,      DZe_BZpKwotaSys )
      Select                             0,            6,             'Suma',          0,            0, SUM(DZe_BZdKwotaSys), SUM(DZe_BZpKwotaSys)
       From @DetZestawienieTmp
   -- Zestawienie końcowe
   INSERT INTO @DetZestawienie ( DZe_FPlId, DZe_FPlNumer, DZe_FPlDetNazwa, DZe_BZdKwotaSys, DZe_BZpKwotaSys )
    SELECT                       DZe_FPlId, DZe_FPlNumer, DZe_FPlDetNazwa, DZe_BZdKwotaSys, DZe_BZpKwotaSys
   FROM @DetZestawienieTmp
   ORDER BY DZe_FPlNumer
 Return
End
