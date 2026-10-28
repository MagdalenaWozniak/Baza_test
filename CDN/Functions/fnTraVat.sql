CREATE FUNCTION CDN.fnTraVat (@TrNId INT)
RETURNS @TraVat TABLE (
 TrV_Stawka NUMERIC(5,2),
 TrV_Flaga SMALLINT,
 TrV_Zrodlowa NUMERIC(5,2),
 TrV_Netto NUMERIC(15,2),
 TrV_Vat NUMERIC(15,2),
 TrV_Brutto NUMERIC(15,2),
 TrV_NettoWal NUMERIC(15,2),
 TrV_VatWal NUMERIC(15,2),
 TrV_BruttoWal NUMERIC(15,2)
 )
AS
BEGIN
Declare @TypDokumentu Int
Select @TypDokumentu = TrN_TypDokumentu From CDN.TraNag Where TrN_TrNId = @TrNId
If @TypDokumentu In (310, 303, 304, 312, 317, 318)
 Begin
  DECLARE @TypNB SMALLINT
  DECLARE @Korekta SMALLINT
  --Pobranie danych z nagłówka faktury
  SELECT @TypNB = TrN_TypNB, @Korekta = TrN_Korekta FROM CDN.TraNag WHERE TrN_TrNId = @TrNId
  --Akcja zależna jest od rodzaju faktury - inny sposób liczenia Vat dla korekty Vat
  IF @Korekta <> 3 -- Faktura nie jest korektą Vat
        INSERT INTO @TraVat(TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
        SELECT TrE_Stawka, TrE_Flaga, TrE_Zrodlowa, SUM(TrE_WartoscNetto), 0, SUM(TrE_WartoscBrutto), SUM(TrE_WartoscNettoWal), 0, SUM(TrE_WartoscBruttoWal)
        FROM CDN.TraElem WHERE TrE_TrNId = @TrnId
        GROUP BY TrE_TrNId, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa
        ORDER BY TrE_Flaga, TrE_Stawka, TrE_Zrodlowa
  ELSE  -- Faktura jest korektą Vat
    BEGIN
      DECLARE @TrEId        INT
      DECLARE @StawkaVat NUMERIC(5,2)
      DECLARE @FlagaVat SMALLINT
      DECLARE @Zrodlowa NUMERIC(5,2)
      DECLARE @Netto NUMERIC(15,2)
      DECLARE @Brutto NUMERIC(15,2)
      DECLARE @NettoWal NUMERIC(15,2)
      DECLARE @BruttoWal NUMERIC(15,2)
      DECLARE @StawkaVatOrg DECIMAL(5,2)
      DECLARE @FlagaVatOrg  SMALLINT
      DECLARE @ZrodlowaOrg NUMERIC(5,2)
      --Kursor elementów faktury korygującej
      DECLARE ElementyVat CURSOR LOCAL FAST_FORWARD FOR
        SELECT TrE_TrEId, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa
        FROM CDN.TraElem WHERE TrE_TrNId = @TrNId
      OPEN ElementyVat
      WHILE 1 = 1
        BEGIN
          FETCH NEXT FROM ElementyVat INTO @TrEId, @StawkaVat, @FlagaVat, @Zrodlowa
          IF @@FETCH_STATUS <> 0 BREAK
          SELECT
            @Netto        = WartoscNOrg,
            @Brutto       = WartoscBOrg,
            @NettoWal     = WartoscNWalOrg,
            @BruttoWal    = WartoscBWalOrg,
            @StawkaVatOrg = StawkaVatOrg,
            @FlagaVatOrg  = FlagaVatOrg,
            @ZrodlowaOrg  = ZrodlowaOrg
          FROM CDN.TraElemKorekta(@TrEId)
          -- Odjęcie wartości faktury przed korektą
          IF NOT EXISTS(SELECT * FROM @TraVat WHERE TrV_Stawka = @StawkaVatOrg AND TrV_Flaga = @FlagaVatOrg AND TrV_Zrodlowa = @ZrodlowaOrg)
            INSERT INTO @TraVat(TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
            VALUES(@StawkaVatOrg, @FlagaVatOrg, @ZrodlowaOrg, - @Netto, 0, - @Brutto, - @NettoWal, 0, - @BruttoWal)
          ELSE
            UPDATE @TraVat SET TrV_Netto = TrV_Netto - @Netto, TrV_Brutto = TrV_Brutto - @Brutto, TrV_NettoWal = TrV_NettoWal - @NettoWal, TrV_BruttoWal = TrV_BruttoWal - @BruttoWal
            WHERE TrV_Stawka = @StawkaVatOrg AND TrV_Flaga = @FlagaVatOrg AND TrV_Zrodlowa = @ZrodlowaOrg
          -- Dodanie wartości faktury po korekcie
          IF NOT EXISTS(SELECT * FROM @TraVat WHERE TrV_Stawka = @StawkaVat AND TrV_Flaga = @FlagaVat AND TrV_Zrodlowa = @Zrodlowa)
            INSERT INTO @TraVat(TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
            VALUES(@StawkaVat, @FlagaVat, @Zrodlowa, @Netto, 0, @Brutto, @NettoWal, 0, @BruttoWal)
          ELSE
            UPDATE @TraVat SET TrV_Netto = TrV_Netto + @Netto, TrV_Brutto = TrV_Brutto + @Brutto, TrV_NettoWal = TrV_NettoWal + @NettoWal, TrV_BruttoWal = TrV_BruttoWal + @BruttoWal
            WHERE TrV_Stawka = @StawkaVat AND TrV_Flaga = @FlagaVat AND TrV_Zrodlowa = @Zrodlowa
        END
      CLOSE ElementyVat
    END
        -- Aktualizacja Vat'u
      IF @TypNB = 1 -- faktura od netto
       BEGIN
        UPDATE @TraVat SET TrV_Vat = TrV_Netto * TrV_Stawka / 100, TrV_VatWal = TrV_NettoWal * TrV_Stawka / 100
        UPDATE @TraVat SET TrV_Brutto = TrV_Netto + TrV_Vat, TrV_BruttoWal = TrV_NettoWal + TrV_VatWal
       END
      ELSE -- faktura od brutto
       BEGIN
        UPDATE @TraVat SET TrV_Vat = TrV_Brutto * TrV_Stawka / ( 100 + TrV_Stawka) , TrV_VatWal = TrV_BruttoWal * TrV_Stawka / ( 100 + TrV_Stawka)
        UPDATE @TraVat SET TrV_Netto = TrV_Brutto - TrV_Vat, TrV_NettoWal = TrV_BruttoWal - TrV_VatWal
       END
 End
Else
 Begin
  INSERT INTO @TraVat(TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
  SELECT TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, SUM(TrV_Netto), SUM(TrV_Vat), SUM(TrV_Netto+TrV_Vat), SUM(TrV_NettoWal), SUM(TrV_VatWal), SUM(TrV_NettoWal+TrV_VatWal)
  FROM CDN.TraVat WHERE TrV_TrNId = @TrnId
  GROUP BY TrV_TrNId, TrV_Stawka, TrV_Flaga, TrV_Zrodlowa
  ORDER BY TrV_Flaga, TrV_Stawka, TrV_Zrodlowa
  Declare @TrN_TrNID Int
  Select @TrN_TrNID = TrN_TrNID From CDN.TraNag Where TrN_ZwrId = @TrNId And TrN_Korekta = 8 and TrN_Bufor = 0 And TrN_Rodzaj NOT IN (306061, 306071, 306072 )
 IF @TrN_TrNID IS NOT NULL
 BEGIN
 INSERT INTO @TraVat(TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, TrV_Netto, TrV_Vat, TrV_Brutto, TrV_NettoWal, TrV_VatWal, TrV_BruttoWal)
  SELECT TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, SUM(TrV_Netto), SUM(TrV_Vat), SUM(TrV_Netto+TrV_Vat), SUM(TrV_NettoWal), SUM(TrV_VatWal), SUM(TrV_NettoWal+TrV_VatWal)
  FROM CDN.TraVat WHERE TrV_TrNId = @TrN_TrNID
  GROUP BY TrV_TrNId, TrV_Stawka, TrV_Flaga, TrV_Zrodlowa
  ORDER BY TrV_Flaga, TrV_Stawka, TrV_Zrodlowa
 END
 End
  RETURN
END
