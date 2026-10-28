-- SELECT GetDate()
-- SELECT * FROM cdn.TwrIlosci WHERE TwI_TwrId = 1
-- EXEC CDN.RaportBrakow 1, 0, '2009-08-12 00:00:00.000', '', 1, 1, 1
-- SELECT Convert(DECIMAL(20,4), 994.0000000000000)
CREATE  PROCEDURE CDN.RaportBrakow
    @OpeId INT,
    @MagId INT,
    @TwrGrupaId  INT,
    @DataZasobu  DATETIME,
    @DostawcaId  INT,
 @UwzgledniajRezerwacje TINYINT,
 @UwzgledniajZamowienia TINYINT,
 @UwzgledniajStanyTowarow TINYINT,
 @RodzajNormatywu TINYINT,
 @TypAlgorytmu TINYINT,
    @SprzedazOd  DATETIME,
    @SprzedazDo  DATETIME,
 @NiePobierajListyBrakow TINYINT,
    @TowaryId    TEXT,
    @WybraneROId TEXT
AS
BEGIN
  SET NOCOUNT ON
 -- Notowania walut
  DECLARE
  @TylkoWgId     INT,
  @TwGNumer      INT,
  @NrCeny        INT,
  @WalutaKoncowa    NVARCHAR(3),
  @sqltxt   NVARCHAR(1024),
  @FullKnfName      NVARCHAR(512),
  @WalOstrzegaj     NVARCHAR(3),
  @TrN_DataDokChar  NVARCHAR(25),
  @KursLWalutaKoncowa                DECIMAL(15,4),
  @KursMWalutaKoncowa                DECIMAL(5,0)
--pobranie notowania
 SELECT @TrN_DataDokChar    = CONVERT(NVARCHAR(25), @DataZasobu, 102)
 SET @FullKnfName = CDN.GetFullKnfName()
 SELECT @TrN_DataDokChar    = CONVERT(NVARCHAR(25), @DataZasobu, 102)
 -- 1 = "Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)"
 IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 )
  SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540
 ELSE
  SELECT @WalOstrzegaj=1
 SET @sqltxt = 'EXEC ' + @FullKnfName + '.CDN.PobierzNotowania '''', 2,'''+ @TrN_DataDokChar+''','+ @WalOstrzegaj+''
 CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta NVARCHAR(3) PRIMARY KEY, KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
 INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
 EXEC sp_executesql @sqltxt
 IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849) SELECT @WalutaKoncowa = '' ELSE SELECT @WalutaKoncowa = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849
 IF @WalutaKoncowa = ''
  SELECT @KursLWalutaKoncowa = 1, @KursMWalutaKoncowa =1
 ELSE
  SELECT @KursLWalutaKoncowa = KursL, @KursMWalutaKoncowa =KursM FROM #Notowania WHERE Waluta = @WalutaKoncowa
    DECLARE @opeZakazCenZak INT;
 SET @opeZakazCenZak = 0;
 SET @sqltxt  = ' SELECT TOP 1 Ope_ZakazCenyZak FROM ' + @FullKnfName + '.CDN.Operatorzy WHERE Ope_OpeId = ' + CONVERT(NVARCHAR(20), @OpeId)
         -- przerzucenie wyniku do zmiennej poprzez tabelę tymczasową
    CREATE TABLE #Ope (OpeParam INT)
    INSERT #Ope EXEC sp_executeSQL @sqltxt
    SELECT TOP 1  @opeZakazCenZak = OpeParam  FROM #Ope
    DROP TABLE #Ope
 IF @DostawcaId Is NULL SET @DostawcaId = 0
 IF DATALENGTH(@TowaryId) = 0
  SET @TylkoWgId = 0
 ELSE
  SET @TylkoWgId = 1
 CREATE TABLE #RaportBrakow (
     ID     INT NOT NULL PRIMARY KEY,
     Kod    NVARCHAR(50) NOT NULL,
     Nazwa    NVARCHAR(255) NOT NULL,
     EAN    NVARCHAR(40) NOT NULL,
     [Status]   NVARCHAR(3) NOT NULL,
     NumerKat   NVARCHAR(40) NOT NULL,
  DostawcaID   INT NOT NULL,
  Dostawca   NVARCHAR(20) NOT NULL,
  KodDostawcy  NVARCHAR(50) NOT NULL,
     Ilosc    DECIMAL(20,4) NOT NULL,
     Rezerwacje   DECIMAL(20,4) NOT NULL,
     UwzgRezerwacje  DECIMAL(20,4) NOT NULL,
     Zamowienia   DECIMAL(20,4) NOT NULL,
     UwzgZamowienia  DECIMAL(20,4) NOT NULL,
     Braki    DECIMAL(20,4) NOT NULL,
     BrakiPozostale  DECIMAL(20,4) NOT NULL,
     IloscSprzedana  DECIMAL(20,4) NOT NULL,
     IloscZamawiana  DECIMAL(20,4) NOT NULL,
     IloscZamawianaJM DECIMAL(20,4) NOT NULL,
  JMZam    NVARCHAR(20) NOT NULL,
  JM     NVARCHAR(20) NOT NULL,
  --JMZ    NVARCHAR(20) NOT NULL,
  --JMPrzelicznikL  DECIMAL(15,2) NOT NULL,
  --JMPrzelicznikM  DECIMAL(7,0) NOT NULL,
  JMCalkowite  TINYINT NOT NULL,
  CenaNettoWal  DECIMAL(20,4) NOT NULL,
  CenaNettoWalDisp NVARCHAR(20) NOT NULL,
  WalutaSymbol  NVARCHAR(3) NOT NULL,
  KursL    DECIMAL(15,4) NOT NULL,
  KursM    DECIMAL(5,0) NOT NULL,
  CenaNetto   DECIMAL(20,4) NOT NULL,
  WartoscNetto  DECIMAL(20,2) NOT NULL,
  WartoscNettoDisp NVARCHAR(20) NOT NULL,
  BrakKursuWaluty TINYINT NOT NULL,
  IloscMin           DECIMAL (15,4) NOT NULL,
  IloscMinJM         NVARCHAR (20)   NOT NULL ,
  IloscMax           DECIMAL (15,4) NOT NULL ,
  IloscMaxJM         NVARCHAR (20)   NOT NULL ,
  IloscZam           DECIMAL (15,4) NOT NULL ,
  IloscZamJM         NVARCHAR (20)   NOT NULL,
  ZaokraglajDo       SMALLINT,
  CenaZCzteremaMiejscami SMALLINT
 )
 IF @magId = 0
 BEGIN
  INSERT INTO #RaportBrakow
  SELECT Twr_TwrId,Twr_Kod,Twr_Nazwa ,Twr_EAN,
   CASE WHEN (Twr_Typ = 0 AND Twr_Produkt = 0 AND Twr_Kaucja = 0) THEN 'UP' WHEN (Twr_Typ = 0 AND Twr_Produkt = 1 AND Twr_Kaucja = 0) THEN 'UZ' WHEN (Twr_Typ = 1 AND Twr_Produkt = 0 AND Twr_Kaucja = 0) THEN 'TP' WHEN (Twr_Typ = 1 AND Twr_Produkt = 1 AND Twr_Kaucja = 0) THEN 'TZ' WHEN (Twr_Typ = 0 AND Twr_Produkt = 0 AND Twr_Kaucja = 1) THEN 'UPO' WHEN (Twr_Typ = 0 AND Twr_Produkt = 1 AND Twr_Kaucja = 1) THEN 'UZO' WHEN (Twr_Typ = 1 AND Twr_Produkt = 0 AND Twr_Kaucja = 1) THEN 'TPO' WHEN (Twr_Typ = 1 AND Twr_Produkt = 1 AND Twr_Kaucja = 1) THEN 'TZO' END,
   Twr_NumerKat,
   IsNull(Twr_KntId,0),
   IsNull((SELECT TOP 1 Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntId = Twr_KntId),''), --Dostawca
   Twr_KodDostawcy,
   Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Ilosc FROM cdn.TwrIlosci WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId Is Null ORDER BY TwI_Data DESC), 0)), -- ilosc
   Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Rezerwacje FROM cdn.TwrIlosci WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId Is Null ORDER BY TwI_Data DESC), 0)), -- Rezerwacje
   CASE WHEN @UwzgledniajRezerwacje=1 THEN
    Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Rezerwacje FROM cdn.TwrIlosci WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId Is Null ORDER BY TwI_Data DESC), 0))
   ELSE 0 END, --  UwzgRezerwacje
   Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Zamowienia FROM cdn.TwrIlosci WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId Is Null ORDER BY TwI_Data DESC), 0)), -- Zamowienia
   CASE WHEN @UwzgledniajZamowienia=1 THEN
    Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Zamowienia FROM cdn.TwrIlosci WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId Is Null ORDER BY TwI_Data DESC), 0))
   ELSE 0 END, -- UwzgZamowienia
   Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Braki FROM cdn.TwrIlosci WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId Is Null ORDER BY TwI_Data DESC), 0)), --  Braki
   0, -- BrakiPozostale
   CASE WHEN @TypAlgorytmu=1 THEN cdn.IloscSprzedana(Twr_TwrId, @MagId, @SprzedazOd, @SprzedazDo)
    WHEN @TypAlgorytmu=2 THEN cdn.IloscNaWybranychRezerwacjach(Twr_TwrId, @MagId, @WybraneROId)
   ELSE 0 END, --IloscSprzedana
   0, -- IloscZamawiana,
   0, -- IloscZamawianaJM,
   CASE Twr_IloscZam
    WHEN  0  THEN Twr_JM
    ELSE Twr_IloscZamJM
   END,  --ZamJM
   Twr_JM, -- JM,
   --Twr_JMZ, -- JMZ,
   --Twr_JMPrzelicznikL,
   --Twr_JMPrzelicznikM,
   Twr_JMCalkowite,
   TwC_Wartosc, -- CenaNettoWal,
   '0', -- CenaNettoWalDisp
   TwC_Waluta,  -- Waluta,
   CASE WHEN N.Brak = 1 THEN 1
   ELSE IsNull(N.KursL,1) END, --KursL
   CASE WHEN N.Brak = 1 THEN 1
   ELSE IsNull(N.KursM,1) END, -- KursM
   CASE WHEN N.Brak = 1 OR N.KursL IS NULL OR N.KursM IS NULL OR N.KursL = 0 OR N.KursM = 0 THEN 0
   ELSE
    Round( TwC_Wartosc * (N.KursL / N.KursM ), case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
   END, -- CenaNetto
   0,  -- WartoscNetto
   '0', -- WartoscNettoDisp
   IsNull(N.Brak, 0),  -- BrakKursuWaluty
   Twr_IloscMin,
   Twr_IloscMinJM,
   Twr_IloscMax,
   Twr_IloscMaxJM,
   Twr_IloscZam,
   Twr_IloscZamJM,
   case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end,
   Twr_CenaZCzteremaMiejscami
   FROM cdn.Towary
   JOIN cdn.TwrCeny ON TwC_TwrId = Twr_TwrId AND TwC_TwCNumer = 1
   LEFT OUTER JOIN #Notowania N ON N.Waluta = TwC_Waluta
   WHERE Twr_Typ = 1 AND Twr_Nieaktywny = 0
   AND (@NiePobierajListyBrakow=0 OR TwR_TwRId=-1)
   AND (@TylkoWgId=1 OR @DostawcaId=0 OR TwR_KntId = @DostawcaId)
   AND (@TylkoWgId=1 OR @TwrGrupaId=-1 OR (Twr_GidNumer IN (SELECT GidNumer FROM CDN.TwrInTwG(@TwrGrupaId))))
   AND (@TylkoWgId=0 OR TwR_TwRId IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TowaryId)))
 END
 ELSE
 BEGIN
  INSERT INTO #RaportBrakow
  SELECT Twr_TwrId,Twr_Kod,Twr_Nazwa ,Twr_EAN,
   CASE WHEN (Twr_Typ = 0 AND Twr_Produkt = 0 AND Twr_Kaucja = 0) THEN 'UP' WHEN (Twr_Typ = 0 AND Twr_Produkt = 1 AND Twr_Kaucja = 0) THEN 'UZ' WHEN (Twr_Typ = 1 AND Twr_Produkt = 0 AND Twr_Kaucja = 0) THEN 'TP' WHEN (Twr_Typ = 1 AND Twr_Produkt = 1 AND Twr_Kaucja = 0) THEN 'TZ' WHEN (Twr_Typ = 0 AND Twr_Produkt = 0 AND Twr_Kaucja = 1) THEN 'UPO' WHEN (Twr_Typ = 0 AND Twr_Produkt = 1 AND Twr_Kaucja = 1) THEN 'UZO' WHEN (Twr_Typ = 1 AND Twr_Produkt = 0 AND Twr_Kaucja = 1) THEN 'TPO' WHEN (Twr_Typ = 1 AND Twr_Produkt = 1 AND Twr_Kaucja = 1) THEN 'TZO' END,
   Twr_NumerKat,
   IsNull(Twr_KntId,0),
   IsNull((SELECT TOP 1 Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntId = Twr_KntId),''), --Dostawca
   Twr_KodDostawcy,
   Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Ilosc FROM cdn.TwrIlosci LEFT OUTER JOIN cdn.Magazyny ON Mag_MagId = TwI_MagId WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId = @MagId ORDER BY TwI_Data DESC), 0)), -- ilosc
   Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Rezerwacje FROM cdn.TwrIlosci LEFT OUTER JOIN cdn.Magazyny ON Mag_MagId = TwI_MagId WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId = @MagId ORDER BY TwI_Data DESC), 0)), -- Rezerwacje
   CASE WHEN @UwzgledniajRezerwacje=1 THEN
    Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Rezerwacje FROM cdn.TwrIlosci LEFT OUTER JOIN cdn.Magazyny ON Mag_MagId = TwI_MagId WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId = @MagId ORDER BY TwI_Data DESC), 0))
   ELSE 0 END, --  UwzgRezerwacje
   Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Zamowienia FROM cdn.TwrIlosci LEFT OUTER JOIN cdn.Magazyny ON Mag_MagId = TwI_MagId WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId = @MagId ORDER BY TwI_Data DESC), 0)), -- Zamowienia
   CASE WHEN @UwzgledniajZamowienia=1 THEN
    Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Zamowienia FROM cdn.TwrIlosci LEFT OUTER JOIN cdn.Magazyny ON Mag_MagId = TwI_MagId WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId = @MagId ORDER BY TwI_Data DESC), 0))
   ELSE 0 END, -- UwzgZamowienia
   Convert( DECIMAL(20,4), IsNull((SELECT TOP 1 TwI_Braki FROM cdn.TwrIlosci LEFT OUTER JOIN cdn.Magazyny ON Mag_MagId = TwI_MagId WHERE TwI_TwrId = Twr_TwrId AND TwI_Data <= @DataZasobu AND TwI_MagId = @MagId ORDER BY TwI_Data DESC), 0)), --  Braki
   0, -- BrakiPozostale
   CASE WHEN @TypAlgorytmu=1 THEN cdn.IloscSprzedana(Twr_TwrId, @MagId, @SprzedazOd, @SprzedazDo)
    WHEN @TypAlgorytmu=2 THEN cdn.IloscNaWybranychRezerwacjach(Twr_TwrId, @MagId, @WybraneROId)
   ELSE 0 END, --IloscSprzedana
   0, -- IloscZamawiana,
   0, -- IloscZamawianaJM,
   CASE Twr_IloscZam
    WHEN  0  THEN Twr_JM
    ELSE Twr_IloscZamJM
   END,  --ZamJM
   Twr_JM, -- JM,
   --Twr_JMZ, -- JMZ,
   --Twr_JMPrzelicznikL,
   --Twr_JMPrzelicznikM,
   Twr_JMCalkowite,
   TwC_Wartosc, -- CenaNettoWal,
   '0', -- CenaNettoWalDisp
   TwC_Waluta,  -- Waluta,
   CASE WHEN N.Brak = 1 THEN 1
   ELSE IsNull(N.KursL,1) END, --KursL
   CASE WHEN N.Brak = 1 THEN 1
   ELSE IsNull(N.KursM,1) END, -- KursM
   CASE WHEN N.Brak = 1 OR N.KursL IS NULL OR N.KursM IS NULL OR N.KursL = 0 OR N.KursM = 0 THEN 0
   ELSE
    Round( TwC_Wartosc * (N.KursL / N.KursM ), case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
   END, -- CenaNetto
   0,  -- WartoscNetto
   '0', -- WartoscNettoDisp
   IsNull(N.Brak, 0),  -- BrakKursuWaluty
   Twr_IloscMin,
   Twr_IloscMinJM,
   Twr_IloscMax,
   Twr_IloscMaxJM,
   Twr_IloscZam,
   Twr_IloscZamJM,
   case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end,
   Twr_CenaZCzteremaMiejscami
   FROM cdn.Towary
   JOIN cdn.TwrCeny ON TwC_TwrId = Twr_TwrId AND TwC_TwCNumer = 1
   LEFT OUTER JOIN #Notowania N ON N.Waluta = TwC_Waluta
   WHERE Twr_Typ = 1 AND Twr_Nieaktywny = 0
   AND (@NiePobierajListyBrakow=0 OR TwR_TwRId=-1)
   AND (@TylkoWgId=1 OR @DostawcaId=0 OR TwR_KntId = @DostawcaId)
   AND (@TylkoWgId=1 OR @TwrGrupaId=-1 OR (Twr_GidNumer IN (SELECT GidNumer FROM CDN.TwrInTwG(@TwrGrupaId))))
   AND (@TylkoWgId=0 OR TwR_TwRId IN (SELECT NextIdInt FROM CDN.Text2TableInt(@TowaryId)))
  END
  --SELECT * FROM #RaportBrakow
  IF @TylkoWgId = 1  -- dodawanie towaru do raportu przez użytkownika
  BEGIN
   UPDATE #RaportBrakow  SET IloscZamawiana = 1 FROM  #RaportBrakow
   -- dopasuj ilość zamawianą do zamawiać po
   UPDATE #RaportBrakow SET
    IloscZamawianaJM = cdn.DopasujDoZamawiacPo(cdn.PrzeliczIloscJMDlaTowaru(T.Twr_TwrId, IloscZamawiana, JM, JMZam),  T.Twr_IloscZam, 1)
   FROM #RaportBrakow
   JOIN  cdn.Towary T ON ID = T.Twr_TwrId
   WHERE IloscZamawiana > 0
  END
  ELSE
  BEGIN
   -- ustal ilość zamawianą w jednostkach podstawowych
   IF @TypAlgorytmu > 0
    DELETE #RaportBrakow WHERE IloscSprzedana <= 0
   UPDATE #RaportBrakow SET
     IloscZamawiana = CASE @TypAlgorytmu
         WHEN 1 THEN  IloscSprzedana - (Ilosc + UwzgZamowienia)
         WHEN 2 THEN CASE WHEN @UwzgledniajStanyTowarow = 0 THEN IloscSprzedana - UwzgZamowienia
            ELSE IloscSprzedana - (Ilosc + UwzgZamowienia)
            END
         ELSE   UwzgRezerwacje - (Ilosc + UwzgZamowienia)
          END
   IF @RodzajNormatywu = 0   -- nie uwzględniaj stanu minimalny ani maksymalnego
   BEGIN
    -- dopasuj ilość zamawianą do zamawiać po
    UPDATE #RaportBrakow SET
     IloscZamawianaJM = cdn.DopasujDoZamawiacPo(cdn.PrzeliczIloscJMDlaTowaru(ID, IloscZamawiana, JM, JMZam), T.Twr_IloscZam, 1)
    FROM #RaportBrakow
    JOIN  cdn.Towary T ON ID = T.Twr_TwrId
    WHERE IloscZamawiana > 0
   END
   -- uwzględnij stan minimalny lub maksymalny
   IF @RodzajNormatywu = 1   -- uwzględnij stan minimalny
   BEGIN
    IF @TypAlgorytmu = 0
     UPDATE #RaportBrakow SET
     IloscZamawiana   = cdn.PrzeliczIloscJMDlaTowaru(ID, T.Twr_IloscMin, T.Twr_IloscMinJM, T.Twr_JM) + UwzgRezerwacje - Ilosc - UwzgZamowienia
     FROM  #RaportBrakow
     JOIN  cdn.Towary T ON ID = T.Twr_TwrId
     WHERE T.Twr_IloscMin > 0 AND (Ilosc + IloscZamawiana-UwzgRezerwacje) <  cdn.PrzeliczIloscJMDlaTowaru(T.Twr_TwrId, T.Twr_IloscMin, T.Twr_IloscMinJM, T.Twr_JM)
    IF @TypAlgorytmu = 1  -- wg sprzedaży
     UPDATE #RaportBrakow SET
      IloscZamawiana   = cdn.PrzeliczIloscJMDlaTowaru(ID, T.Twr_IloscMin, T.Twr_IloscMinJM, T.Twr_JM) - (Ilosc + UwzgZamowienia)
     FROM  #RaportBrakow
     JOIN  cdn.Towary T ON ID = T.Twr_TwrId
     WHERE T.Twr_IloscMin > 0 AND (IloscZamawiana + Ilosc + UwzgZamowienia)<  cdn.PrzeliczIloscJMDlaTowaru(T.Twr_TwrId, T.Twr_IloscMin, T.Twr_IloscMinJM, T.Twr_JM)
    IF @TypAlgorytmu = 2    -- wg RO
     UPDATE #RaportBrakow SET
      IloscZamawiana   = cdn.PrzeliczIloscJMDlaTowaru(ID, T.Twr_IloscMin, T.Twr_IloscMinJM, T.Twr_JM) - (Ilosc + UwzgZamowienia)
     FROM  #RaportBrakow
     JOIN  cdn.Towary T ON ID = T.Twr_TwrId
     WHERE T.Twr_IloscMin > 0 AND (IloscZamawiana + Ilosc + UwzgZamowienia)<  cdn.PrzeliczIloscJMDlaTowaru(T.Twr_TwrId, T.Twr_IloscMin, T.Twr_IloscMinJM, T.Twr_JM)
    -- dopasuj ilość zamawianą do zamawiać po
    UPDATE #RaportBrakow SET
     IloscZamawianaJM = cdn.DopasujDoZamawiacPo(cdn.PrzeliczIloscJMDlaTowaru(ID, IloscZamawiana, JM, JMZam), T.Twr_IloscZam, 1)
    FROM #RaportBrakow
    JOIN  cdn.Towary T ON ID = T.Twr_TwrId
    WHERE IloscZamawiana > 0
   END
   IF @RodzajNormatywu = 2   -- uwzględnij stan maksymalny
   BEGIN
    IF @TypAlgorytmu = 0
    BEGIN
     UPDATE #RaportBrakow SET
      IloscZamawiana  = cdn.PrzeliczIloscJMDlaTowaru(T.Twr_TwrId, T.Twr_IloscMax, T.Twr_IloscMaxJM, T.Twr_JM) + IloscZamawiana
     FROM  #RaportBrakow
     JOIN  cdn.Towary T ON ID = T.Twr_TwrId
     WHERE T.Twr_IloscMax > 0
    END
    IF @TypAlgorytmu = 1
    BEGIN
     UPDATE #RaportBrakow SET
      IloscZamawiana = cdn.PrzeliczIloscJMDlaTowaru(T.Twr_TwrId, T.Twr_IloscMax, T.Twr_IloscMaxJM, T.Twr_JM) - (Ilosc + UwzgZamowienia)
     FROM  #RaportBrakow
     JOIN  cdn.Towary T ON ID = T.Twr_TwrId
     WHERE T.Twr_IloscMax > 0  AND (IloscZamawiana + Ilosc + UwzgZamowienia) >  cdn.PrzeliczIloscJMDlaTowaru(T.Twr_TwrId, T.Twr_IloscMax, T.Twr_IloscMaxJM, T.Twr_JM)
    END
    IF @TypAlgorytmu = 2    -- wg RO
    BEGIN
     UPDATE #RaportBrakow SET
      IloscZamawiana = cdn.PrzeliczIloscJMDlaTowaru(T.Twr_TwrId, T.Twr_IloscMax, T.Twr_IloscMaxJM, T.Twr_JM) - (Ilosc + UwzgZamowienia)
     FROM  #RaportBrakow
     JOIN  cdn.Towary T ON ID = T.Twr_TwrId
     WHERE T.Twr_IloscMax > 0  AND (IloscZamawiana + Ilosc + UwzgZamowienia) >  cdn.PrzeliczIloscJMDlaTowaru(T.Twr_TwrId, T.Twr_IloscMax, T.Twr_IloscMaxJM, T.Twr_JM)
    END
    -- dopasuj ilość zamawianą do zamawiać po (dopasuj z -1)
    UPDATE #RaportBrakow SET
     IloscZamawianaJM = cdn.DopasujDoZamawiacPo(cdn.PrzeliczIloscJMDlaTowaru(ID, IloscZamawiana, JM, JMZam), T.Twr_IloscZam, -1)
    FROM #RaportBrakow
    JOIN  cdn.Towary T ON ID = T.Twr_TwrId
    WHERE IloscZamawiana > 0
   END
  END
  -- Ustal cenę dla jednostki, w której zamawiany jest towar (najpierw jednostka zamawiana, potem podstawowa)
  UPDATE #RaportBrakow SET CenaNettoWal = round(cdn.PrzeliczIloscJMDlaTowaru(ID, CenaNettoWal, JMZam, JM),ZaokraglajDo)
  UPDATE #RaportBrakow SET
   IloscZamawiana = cdn.PrzeliczIloscJMDlaTowaru(ID, IloscZamawianaJM, JMZam, JM),  -- ustal ilość w jednostkach podstawowych
   CenaNetto =
    CASE WHEN BrakKursuWaluty = 1 THEN 0
    ELSE
     Round( CenaNettoWal * (KursL / KursM ), ZaokraglajDo)
    END -- ustal cenę netto w walucie systemowej
  FROM #RaportBrakow
  WHERE IloscZamawiana > 0
  UPDATE #RaportBrakow SET
   BrakiPozostale  = CASE WHEN (Braki - Zamowienia) < 0 THEN 0 ELSE (Braki - Zamowienia) END, -- BrakiPozostale
   WartoscNetto = Convert( DECIMAL(20,2),CenaNetto * IloscZamawianaJM)
  FROM #RaportBrakow
  UPDATE #RaportBrakow SET
   CenaNettoWalDisp  =
   CASE WHEN @opeZakazCenZak = 1  THEN REPLICATE('-', 15)
   ELSE      Convert(NVARCHAR(20), CenaNettoWal) END, -- WartoscNettoDisp
   WartoscNettoDisp  =
   CASE WHEN @opeZakazCenZak = 1  THEN REPLICATE('-', 15)
     WHEN BrakKursuWaluty = 1  THEN '-kurs-'
   ELSE
    Convert(NVARCHAR(20), WartoscNetto)
   END -- WartoscNettoDisp
  FROM #RaportBrakow
  SET NOCOUNT OFF
  SELECT * FROM #RaportBrakow WHERE IloscZamawiana > 0 ORDER BY Kod
END
