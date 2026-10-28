CREATE FUNCTION CDN.TraVatKat (@TrNId INT)
RETURNS @TraVatKat TABLE (
 TrV_Stawka NUMERIC(5,2),
 TrV_Flaga SMALLINT,
 TrV_Netto NUMERIC(15,2),
 TrV_Vat NUMERIC(15,2),
 TrV_Brutto NUMERIC(15,2),
 TrV_KatID INT,
 TrV_NettoWal NUMERIC(15,2),
 TrV_VatWal NUMERIC(15,2),
 TrV_BruttoWal NUMERIC(15,2),
 TrV_Rodzaj INT,
 TrV_Typ TINYINT
 )
AS
BEGIN
  DECLARE @TypNB SMALLINT, @Korekta SMALLINT, @TrEId INT
  DECLARE @StawkaVat NUMERIC(5,2),    @FlagaVat SMALLINT
  DECLARE @StawkaVatOrg DECIMAL(5,2), @FlagaVatOrg  SMALLINT
  DECLARE @Netto NUMERIC(15,2), @Brutto NUMERIC(15,2), @Vat NUMERIC(15,2)
  DECLARE @NettoWal NUMERIC(15,2), @BruttoWal NUMERIC(15,2), @VatWal NUMERIC(15,2)
  DECLARE @KatID INT, @KatIDOrg INT, @TwrTyp INT, @VatTyp INT
  DECLARE @Licznik Int
  Declare @TrN_TrNID Int
  --Pobranie danych z nagłówka faktury
  SELECT @TypNB = TrN_TypNB, @Korekta = TrN_Korekta
   FROM CDN.TraNag WHERE TrN_TrNId = @TrNId
  --Akcja zależna jest od rodzaju faktury - inny sposób liczenia Vat dla korekty Vat
  IF @Korekta = 5 or @Korekta = 6
 BEGIN
        INSERT INTO @TraVatKat(TrV_Stawka, TrV_Flaga,TrV_KatID, TrV_Rodzaj, TrV_Typ, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
        SELECT TrV_Stawka, TrV_Flaga, NULL, 1, 1, SUM(TrV_Netto), SUM(TrV_Vat), SUM(TrV_Netto+TrV_Vat), SUM(TrV_NettoWal), SUM(TrV_VatWal), SUM(TrV_NettoWal+TrV_VatWal)
        FROM CDN.TraVat Where TrV_TrNId = @TrNId
        GROUP BY TrV_Stawka, TrV_Flaga
     END
  ELSE
  IF @Korekta <> 3 -- Faktura nie jest korektą Vat
     BEGIN
        INSERT INTO @TraVatKat(TrV_Stawka, TrV_Flaga,TrV_KatID, TrV_Rodzaj, TrV_Typ, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
        SELECT  TrE_Stawka,
                TrE_Flaga,
                TrE_KatID,
                Twr_Typ,
                --Track 115713 Case When TrN_Rodzaj In (302200, 302202) Then 1 Else 0 End,
                0,
                SUM(TrE_WartoscNetto),
                0,
                SUM(TrE_WartoscBrutto),
                SUM(TrE_WartoscNettoWal),
                0,
                SUM(TrE_WartoscBruttoWal)
        FROM CDN.TraNag
             JOIN CDN.TraElem ON TrN_TrNId = TrE_TrNId
             JOIN CDN.Towary ON TrE_TwrId = Twr_TwrId
        WHERE TrN_TrNId = @TrnId And TrE_Kaucja = 0
        GROUP BY TrN_TrNId, TrN_Rodzaj, TrE_Stawka, TrE_Flaga,TrE_KatID, Twr_Typ
        INSERT INTO @TraVatKat(TrV_Stawka, TrV_Flaga,TrV_KatID, TrV_Rodzaj, TrV_Typ, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
        SELECT  TrV_Stawka, TrV_Flaga, NULL, 1, 1, SUM(TrV_Netto), SUM(TrV_Vat), SUM(TrV_Netto+TrV_Vat), SUM(TrV_NettoWal), SUM(TrV_VatWal), SUM(TrV_NettoWal+TrV_VatWal)
        FROM CDN.TraVat
  LEFT OUTER JOIN CDN.TraNag ON TrV_TrNID = TrN_TrNID
  Where TrV_TrNId = @TrNId And TrV_Typ = 1 And
   exists(select TrR_TrRId
   from CDN.TraNagRelacje
   where TrR_TrNId = @TrNId and TrR_FaTyp = 320)
        GROUP BY TrV_Stawka, TrV_Flaga
  Select @TrN_TrNID = TrN_TrNID From CDN.TraNag Where TrN_ZwrId = @TrNId And TrN_Korekta = 8 And TrN_Bufor = 0 And TrN_Rodzaj NOT IN (306061, 306071, 306072 )
  IF @TrN_TrNID IS NOT NULL
  BEGIN
   INSERT INTO @TraVatKat(TrV_Stawka, TrV_Flaga,TrV_KatID, TrV_Rodzaj, TrV_Typ, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
   SELECT  TrE_Stawka,
     TrE_Flaga,
     TrE_KatID,
     Twr_Typ,
     0,
     SUM(TrE_WartoscNetto),
     0,
     SUM(TrE_WartoscBrutto),
     SUM(TrE_WartoscNettoWal),
     0,
     SUM(TrE_WartoscBruttoWal)
   FROM CDN.TraNag
     JOIN CDN.TraElem ON TrN_TrNId = TrE_TrNId
     JOIN CDN.Towary ON TrE_TwrId = Twr_TwrId
   WHERE TrN_TrNId = @TrN_TrNID And TrE_Kaucja = 0
   GROUP BY TrN_TrNId, TrN_Rodzaj, TrE_Stawka, TrE_Flaga,TrE_KatID, Twr_Typ
  END
     END
  ELSE  -- Faktura jest korektą Vat
    BEGIN
      --Kursor elementów faktury korygującej
      DECLARE ElementyVat CURSOR LOCAL FAST_FORWARD FOR
        SELECT TrE_TrEId, TrE_Stawka, TrE_Flaga, TrE_KatID, Twr_Typ
        FROM CDN.TraElem JOIN CDN.Towary ON TrE_TwrId = Twr_TwrId
        WHERE TrE_TrNId = @TrNId And TrE_Kaucja = 0
      OPEN ElementyVat
      WHILE 1 = 1
        BEGIN
          FETCH NEXT FROM ElementyVat INTO @TrEId, @StawkaVat, @FlagaVat, @KatID, @TwrTyp
          IF @@FETCH_STATUS <> 0 BREAK
          SELECT
            @Netto        = WartoscNOrg,
            @Brutto       = WartoscBOrg,
            @NettoWal     = WartoscNWalOrg,
            @BruttoWal    = WartoscBWalOrg,
            @StawkaVatOrg = StawkaVatOrg,
            @FlagaVatOrg  = FlagaVatOrg
          FROM CDN.TraElemKorekta(@TrEId)
          -- Odjęcie wartości faktury przed korektą
          IF NOT EXISTS(SELECT * FROM @TraVatKat WHERE TrV_Stawka = @StawkaVatOrg AND TrV_Flaga = @FlagaVatOrg AND IsNull(TrV_KatId,0) = IsNull(@KatId,0) AND TrV_Rodzaj = @TwrTyp)
            INSERT INTO @TraVatKat(TrV_Stawka, TrV_Flaga, TrV_KatId, TrV_Rodzaj, TrV_Typ, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
            VALUES(@StawkaVatOrg, @FlagaVatOrg, @KatId, @TwrTyp, 0, - @Netto, 0, - @Brutto, - @NettoWal, 0, - @BruttoWal)
          ELSE
            UPDATE @TraVatKat SET TrV_Netto = TrV_Netto - @Netto, TrV_Brutto = TrV_Brutto - @Brutto, TrV_NettoWal = TrV_NettoWal - @NettoWal, TrV_BruttoWal = TrV_BruttoWal - @BruttoWal
            WHERE TrV_Stawka = @StawkaVatOrg AND TrV_Flaga = @FlagaVatOrg AND IsNull(TrV_KatId,0) = IsNull(@KatId,0) AND TrV_Rodzaj = @TwrTyp
          -- Dodanie wartości faktury po korekcie
          IF NOT EXISTS(SELECT * FROM @TraVatKat WHERE TrV_Stawka = @StawkaVat AND TrV_Flaga = @FlagaVat AND IsNull(TrV_KatId,0) = IsNull(@KatId,0) AND TrV_Rodzaj = @TwrTyp)
            INSERT INTO @TraVatKat(TrV_Stawka, TrV_Flaga, TrV_KatId, TrV_Rodzaj, TrV_Typ, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
            VALUES(@StawkaVat, @FlagaVat, @KatId, @TwrTyp, 0, @Netto, 0, @Brutto, @NettoWal, 0, @BruttoWal)
          ELSE
            UPDATE @TraVatKat SET TrV_Netto = TrV_Netto + @Netto, TrV_Brutto = TrV_Brutto + @Brutto, TrV_NettoWal = TrV_NettoWal + @NettoWal, TrV_BruttoWal = TrV_BruttoWal + @BruttoWal
            WHERE TrV_Stawka = @StawkaVat AND TrV_Flaga = @FlagaVat AND IsNull(TrV_KatId,0) = IsNull(@KatId,0) AND TrV_Rodzaj = @TwrTyp
        END
      CLOSE ElementyVat
    END
        -- Aktualizacja Vat'u
      IF @TypNB = 1 -- faktura od netto
       BEGIN
         UPDATE @TraVatKat SET TrV_Vat = TrV_Netto * TrV_Stawka / 100, TrV_VatWal = TrV_NettoWal * TrV_Stawka / 100 Where TrV_Typ=0
         UPDATE @TraVatKat SET TrV_Brutto = TrV_Netto + TrV_Vat, TrV_BruttoWal = TrV_NettoWal + TrV_VatWal Where TrV_Typ=0
       END
      ELSE -- faktura od brutto
       BEGIN
         UPDATE @TraVatKat SET TrV_Vat = TrV_Brutto * TrV_Stawka / ( 100 + TrV_Stawka) , TrV_VatWal = TrV_BruttoWal * TrV_Stawka / ( 100 + TrV_Stawka)  Where TrV_Typ=0
         UPDATE @TraVatKat SET TrV_Netto = TrV_Brutto - TrV_Vat, TrV_NettoWal = TrV_BruttoWal - TrV_VatWal Where TrV_Typ=0
       END
-- Tutaj wyrównujemy ewentualną różnicę wynikającą ze zliczenia Vat jako sumy pozycji
  Declare roznica Cursor Local Fast_Forward For
   Select
    Case When a.TrV_Stawka   Is Not Null Then a.TrV_Stawka   Else b.TrV_Stawka   End,
    Case When a.TrV_Flaga    Is Not Null Then a.TrV_Flaga    Else b.TrV_Flaga    End,
    IsNull(a.TrV_Netto,0)  - IsNull(b.TrV_Netto,0),
    IsNull(a.TrV_Vat,0)    - IsNull(b.TrV_Vat,0),
    IsNull(a.TrV_Brutto,0) - IsNull(b.TrV_Brutto,0),
    IsNull(a.TrV_NettoWal,0)  - IsNull(b.TrV_NettoWal,0),
    IsNull(a.TrV_VatWal,0)    - IsNull(b.TrV_VatWal,0),
    IsNull(a.TrV_BruttoWal,0) - IsNull(b.TrV_BruttoWal,0)
   From
    (Select
 TrV_Stawka,
 TrV_Flaga,
 Sum(TrV_Netto) As TrV_Netto,
 Sum(TrV_Vat) As TrV_Vat,
 Sum(TrV_Brutto) As TrV_Brutto ,
 Sum(TrV_NettoWal) As TrV_NettoWal,
 Sum(TrV_VatWal) As TrV_VatWal,
 Sum(TrV_BruttoWal) As TrV_BruttoWal
 From CDN.fnTraVat(@TrNId) Group By TrV_Stawka, TrV_Flaga) As a
   Full Outer Join
    (Select
 TrV_Stawka,
 TrV_Flaga,
 Sum(TrV_Netto)     As TrV_Netto,
 Sum(TrV_Vat)       As TrV_Vat,
 Sum(TrV_Brutto)    As TrV_Brutto,
 Sum(TrV_NettoWal)  As TrV_NettoWal,
 Sum(TrV_VatWal)    As TrV_VatWal,
 Sum(TrV_BruttoWal) As TrV_BruttoWal
 From @TraVatKat            Group By TrV_Stawka, TrV_Flaga) As b
   On a.TrV_Stawka = b.TrV_Stawka And a.TrV_Flaga = b.TrV_Flaga
   Where
    IsNull(a.TrV_Netto,0)     <> IsNull(b.TrV_Netto,0)    Or
    IsNull(a.TrV_Vat,0)       <> IsNull(b.TrV_Vat,0)      Or
    IsNull(a.TrV_Brutto,0)    <> IsNull(b.TrV_Brutto,0)   Or
    IsNull(a.TrV_NettoWal,0)  <> IsNull(b.TrV_NettoWal,0) Or
    IsNull(a.TrV_VatWal,0)    <> IsNull(b.TrV_VatWal,0)   Or
    IsNull(a.TrV_BruttoWal,0) <> IsNull(b.TrV_BruttoWal,0)
  Open roznica
  While 1=1
   Begin
    Fetch Next From roznica InTo @StawkaVat, @FlagaVat, @Netto, @Vat, @Brutto, @NettoWal, @VatWal, @BruttoWal
    If @@Fetch_Status<>0 Break
    Select @licznik = Count(*) From @TraVatKat Where TrV_Stawka = @StawkaVat And TrV_Flaga = @FlagaVat
    If @Licznik = 0
      Insert InTo @TraVatKat(TrV_Stawka, TrV_Flaga, TrV_Rodzaj, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal )
      Values(@StawkaVat, @FlagaVat, 1, @Netto, @Vat, @Brutto, @NettoWal, @VatWal, @BruttoWal)
    Else If @Licznik = 1
      Update @TraVatKat
      Set TrV_Netto = TrV_Netto + @Netto, TrV_Vat = TrV_Vat + @Vat, TrV_Brutto = TrV_Brutto + @Brutto, TrV_NettoWal = TrV_NettoWal + @NettoWal, TrV_VatWal = TrV_VatWal + @VatWal, TrV_BruttoWal = TrV_BruttoWal + @BruttoWal
      Where TrV_Stawka = @StawkaVat And TrV_Flaga = @FlagaVat
 Else If @Licznik > 1 AND @TrN_TrNID IS NOT NULL
  With cte AS (
   SELECT TOP(1) * FROM @TraVatKat
   WHERE TrV_Stawka = @StawkaVat And TrV_Flaga = @FlagaVat
   )
      Update cte
      Set TrV_Netto = TrV_Netto + @Netto, TrV_Vat = TrV_Vat + @Vat, TrV_Brutto = TrV_Brutto + @Brutto, TrV_NettoWal = TrV_NettoWal + @NettoWal, TrV_VatWal = TrV_VatWal + @VatWal, TrV_BruttoWal = TrV_BruttoWal + @BruttoWal
    Else
     Begin
      Select Top 1 @KatId = TrV_KatId, @TwrTyp = TrV_Rodzaj, @VatTyp = TrV_Typ From @TraVatKat Where TrV_Stawka = @StawkaVat And TrV_Flaga = @FlagaVat Order By TrV_Typ, TrV_Netto Desc
      Update @TraVatKat
      Set TrV_Netto = TrV_Netto + @Netto, TrV_Vat = TrV_Vat + @Vat, TrV_Brutto = TrV_Brutto + @Brutto, TrV_NettoWal = TrV_NettoWal + @NettoWal, TrV_VatWal = TrV_VatWal + @VatWal, TrV_BruttoWal = TrV_BruttoWal + @BruttoWal
      Where TrV_Stawka = @StawkaVat And TrV_Flaga = @FlagaVat And IsNull(TrV_KatId,0) = IsNull(@KatId,0) And TrV_Rodzaj = @TwrTyp And TrV_Typ = @VatTyp
     End
   End
  Close roznica
  Deallocate roznica
  RETURN
END
