CREATE PROCEDURE CDN.AktualizujIntrastat
  @Rodzaj         CHAR(3),      -- 1 - przywóz,   2 - wywóz
  @Rok            CHAR(4),      -- rok deklaracji
  @Miesiac        CHAR(2),      -- miesiąc deklaracji
  @KursNumer      NVARCHAR(10),  -- Numer typu kursu
  @TypyDokumentow NVARCHAR(50),  -- typy uwzglednianych dokuemntów w postaci stringu rozdzielone przecinkami
  @TypyDokumentowKor NVARCHAR(50),  -- typy uwzglednianych dokuemntów w postaci stringu rozdzielone przecinkami
  @IsN_IsNIdChr   CHAR(20),      -- Id IsN_IsNId deklaracji, która obejmuje policzone dokumenty); jeśli NULL, to nie updatujemy nagłówków
  @Tryb TinyInt = 0,
  @Typ TinyInt = 1
AS
SET NOCOUNT ON
   DECLARE @IntrastatElemTM TABLE
   (
     IsE_IsEId    INT IDENTITY(1,1),
     IsE_Lp    INT,
     IsE_Kraj    NVARCHAR(2),
     IsE_Opis    NVARCHAR(1024),
     IsE_RodzajTransakcji  NVARCHAR(2),
     IsE_CN    CHAR(8),
     IsE_KrajPochodzenia  NVARCHAR(2),
     IsE_MasaNetto   DECIMAL(20,2),
     IsE_IloscJmUzup   DECIMAL(20,2),
     TrN_DataTransportu         DATETIME,
     TrN_DataWys                DATETIME,
     TrN_Waluta                 CHAR(3),
     IsE_NettoWal        DECIMAL(20,2),
     IsE_NettoSys  DECIMAL(20,2),
     IsE_NettoEur               DECIMAL(20,2),
     IsE_NumerIdentKnt NVARCHAR(40)
   )
   DECLARE @IntrastatElem TABLE
   (
     IsE_IsEId    INT IDENTITY(1,1),
     IsE_Lp    INT,
     IsE_Kraj    NVARCHAR(2),
     IsE_Opis    NVARCHAR(1024),
     IsE_RodzajTransakcji  NVARCHAR(2),
     IsE_CN    CHAR(8),
     IsE_KrajPochodzenia  NVARCHAR(2),
     IsE_MasaNetto   DECIMAL(20,2),
     IsE_IloscJmUzup   DECIMAL(20,2),
     TrN_DataTransportu         DATETIME,
     TrN_DataWys                DATETIME,
     TrN_Waluta                 CHAR(3),
     IsE_NettoWal        DECIMAL(20,2),
     IsE_NettoSys  DECIMAL(20,2),
     IsE_NettoEur               DECIMAL(20,2),
  IsE_NumerIdentKnt NVARCHAR(40)
   )
   DECLARE @TraNag TABLE
   (
     TrN_TrNId       INT,
     TrN_KodKraju    CHAR(2),
     TrN_KodTransakcji  NVARCHAR(2),
     TrN_DataTransportu         DATETIME,
     TrN_DataWys                DATETIME,
     TrN_Waluta                 CHAR(3),
  TrN_NumerIdentKnt NVARCHAR(40)
     PRIMARY KEY(TrN_TrNId)
   )
   DECLARE
     @DataStart                 DATETIME,
     @DataStop                  DATETIME,
     @IsE_IsEId   INT,
     @Lp          INT,
     @ServerCfgString    NVARCHAR(255),
     @BazaCfgString       NVARCHAR(255),
     @SQLTxt              NVARCHAR(1000),
     @TrN_Waluta          NVARCHAR(3),
     @TrN_DataTransportu        DATETIME,
     @TrN_DataWys               DATETIME,
     @IsN_IsNId                 INT,
     @IsE_NettoWal              DECIMAL(20,2),
     @IsE_NettoSys              DECIMAL(20,2),
     @IsE_NettoEur              DECIMAL(20,2),
     @GranicaMalejWartosci      DECIMAL(20,2),
     @SumaMalychWartosci        DECIMAL(20,2),
     @EurKursL                  DECIMAL(15,4),
     @EurKursM                  DECIMAL(5,0),
     @WalKursL                  DECIMAL(15,4),
     @WalKursM                  DECIMAL(5,0),
     @Brak                      TINYINT,
     @PobierajOstatniKurs       CHAR(1),
     @dw                        INT,
     @Komunikat                 NVARCHAR(255)
   -- wyliczenie daty początkowej i końcowej
   IF LEN(@Miesiac) = 1 SET @Miesiac = '0'+ SUBSTRING(@Miesiac,1,1)
   SET @DataStart = CONVERT( DATETIME, @Rok + '-' + @MIesiac + '-' + '01', 120)
   SET @DataStop  = DATEADD( DAY, -1, DATEADD( MONTH, 1, @DataStart ) )
   -- dane bazy konfiguracyjnej dla odczytania tabeli kursowej walut
   SELECT @ServerCfgString = Sys_Wartosc FROM cdn.SystemCDN WHERE Sys_Id = 1001
   SELECT @BazaCfgString   = Sys_Wartosc FROM cdn.SystemCDN WHERE Sys_Id = 1002
   -- Granica małej wartości z konfiguracji
   SELECT @GranicaMalejWartosci = CASE WHEN Fir_Wartosc IS NULL OR Fir_Wartosc = '' THEN 200.00 ELSE CONVERT(DECIMAL(20,2), replace(fir_wartosc,',','.')) END
     FROM cdn.Firma WHERE Fir_Numer = 1648
   -- Parametr pobieraj ostatnio ustalony kurs waluty
   SELECT @PobierajOstatniKurs = CASE WHEN Fir_Wartosc IS NULL OR Fir_Wartosc = '' THEN '1' ELSE SUBSTRING(Fir_Wartosc,1,1) END
     FROM cdn.Firma WHERE Fir_Numer = 1540
   -- IsN_IsNId numeryczny
   SELECT @IsN_IsNId = CONVERT ( INT, ISNULL(@IsN_IsNIdChr,'0') )
   -- wyliczenie TrN_TrNId dokumentów, dla których ma być liczona deklaracja
   DECLARE @TrNId TABLE ( TrN_TrNId INT )
   INSERT INTO @TrNId
     SELECT distinct TrE_TrNId
       FROM cdn.TraNag
         JOIN cdn.TraElem ON TrE_TrNId = TrN_TrNId
         JOIN cdn.Towary ON TrE_TwrId = Twr_TwrId
       WHERE TrN_TypDokumentu IN ( SELECT NextIdINT FROM cdn.Text2TableInt(@TypyDokumentow) )
         AND TrN_Rodzaj NOT IN ( 306071, 306072, 306061, 312000, 312008 )
         AND TrN_Bufor = 0
         AND ISNULL(TrN_KodKraju,'') NOT IN ('', 'PL')
         AND TrN_DataTransportu IS NOT NULL
         AND TrN_DataTransportu BETWEEN @DataStart AND @DataStop
         AND TrN_Korekta NOT IN (3, 4 )
         AND ISNULL(TrN_KodTransakcji,'') <> ''
         AND Twr_Typ = 1
         AND TrE_Aktywny = 1
   and TrE_TrEID in (select tre_treid from cdn.TraElem where  TrE_Ilosc >=0)
         -- przy ponownym przeliczeniu mamy @IsN_IsNId ujemne i dlatego także te dokumenty muszą być brane pod uwage
         AND ( ISNULL(TrN_IsNId,0)= 0  OR TrN_IsNId = ABS(@IsN_IsNId) )
  DECLARE @TrNIdKor TABLE ( TrN_TrNId INT )
     INSERT INTO @TrNIdKor
     SELECT distinct TrE_TrNId
       FROM cdn.TraNag
         JOIN cdn.TraElem ON TrE_TrNId = TrN_TrNId
         JOIN cdn.Towary ON TrE_TwrId = Twr_TwrId
       WHERE TrN_TypDokumentu IN ( SELECT NextIdINT FROM cdn.Text2TableInt(@TypyDokumentowKor) )
         AND TrN_Rodzaj NOT IN ( 306071, 306072, 306061, 312000,312008 )
         AND TrN_Bufor = 0
         AND ISNULL(TrN_KodKraju,'') NOT IN ('', 'PL')
         AND TrN_DataTransportu IS NOT NULL
         AND TrN_DataTransportu BETWEEN @DataStart AND @DataStop
         AND TrN_Korekta IN (1 )
         AND ISNULL(TrN_KodTransakcji,'') <> ''
         AND Twr_Typ = 1
         AND TrE_Aktywny = 1
         and TrE_TrEID in (select tre_treid from cdn.TraElem where  TrE_Ilosc <0)
         -- przy ponownym przeliczeniu mamy @IsN_IsNId ujemne i dlatego także te dokumenty muszą być brane pod uwage
         --AND ( ISNULL(TrN_IsNId,0)= 0  OR TrN_IsNId = ABS(@IsN_IsNId) )
   -- eliminacja tych dokumentów, które:
   --  towary nie mają wskaźnika na kod CN w słowniku
   --  dla przywozu nie mają wypełnionego kraju pochodzenia
   DECLARE @TrEId TABLE ( TrE_TrEId INT, TrE_TrNId INT, TrE_TwrId INT, Twr_KCNId INT, Twr_Typ INT, Twr_KrajPochodzenia  NVARCHAR(2) )
   INSERT INTO @TrEId ( TrE_TrEId,     TrE_TrNId,     TrE_TwrId,     Twr_KCNId,     Twr_Typ,     Twr_KrajPochodzenia             )
     SELECT             TrE_TrEId,     TrE_TrNId,     TrE_TwrId,     Twr_KCNId,     Twr_Typ,     Twr_KrajPochodzenia
       FROM cdn.TraElem
         JOIN @TrNId ON TrE_TrNId = TrN_TrNId
         JOIN cdn.Towary ON Twr_TwrId = TrE_TwrId
   -- ignorujemy elementy z usługami
   DELETE FROM @TrEId WHERE Twr_Typ <> 1
   -- dokumenty
   DELETE FROM @TrNId
     WHERE TrN_TrNId IN
      ( SELECT TrE_TrNId
          FROM @TrEId
          WHERE Twr_KCNId IS NULL
            OR ( @Rodzaj = 1 AND ISNULL(Twr_KrajPochodzenia, '') = ''  )
          GROUP BY TrE_TrNId
      )
   -- liczenie elementów z symbolem waluty dokumentu i daty transportu na dokumencie
  INSERT INTO @TraNag
   SELECT distinct
     a.TrN_TrNId,
     a.TrN_KodKraju,
     a.TrN_KodTransakcji,
     a.TrN_DataTransportu,
     case when ISNULL(a.TrN_Korekta,0) = 0 then a.TrN_DataWys else b.TrN_DataWys end  as TrN_DataWys,
     a.TrN_Waluta,
  a.TrN_PodNipKraj + a.TrN_PodNipE
   FROM cdn.TraElem
     JOIN cdn.TraNag a ON TrN_TrNId = TrE_TrNId
     LEFT JOIN cdn.TraNag b ON a.TrN_ZwrId = b.TrN_TrNId
  if @Typ = 2
   BEGIN
    INSERT INTO @IntrastatElemTM
    (
   IsE_Kraj,
   IsE_Opis,
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   IsE_MasaNetto,
   IsE_IloscJMUzup,
   TrN_DataTransportu,
   TrN_DataWys,
   TrN_Waluta,
   IsE_NettoWal,
   IsE_NettoSys,
   IsE_NettoEur,
   IsE_NumerIdentKnt
    )
    SELECT
   IsE_Kraj             = TrN_KodKraju,
   IsE_Opis             = MAX(SUBSTRING(KCN_Opis,1,255)),
   IsE_RodzajTransakcji = TrN_KodTransakcji,
   IsE_CN               = KCN_Kod,
   IsE_KrajPochodzenia  = CASE WHEN @Rodzaj='1' THEN Twr_KrajPochodzenia ELSE '' END,
   IsE_MasaNetto        = SUM(TrE_Ilosc * CASE WHEN KCN_Masa = 1 THEN Twr_Masa ELSE 0 END ),
   IsE_IloscJMUzup      = SUM(CASE WHEN ISNULL(KCN_UzupJM,'') ='' THEN 0 ELSE TrE_Ilosc END * ISNULL(Twr_JMPomPrzelicznikL,0) / ISNULL(Twr_JMPomPrzelicznikM,1)),
   TrN_DataTransportu   = TrN_DataTransportu,
   TrN_DataTransportu   = TrN_DataWys,
   TrN_Waluta           = TrN_Waluta,
   IsE_NettoWal         = SUM(TrE_WartoscNettoWal),
   IsE_NettoSys         = 0,
   IsE_NettoEur         = SUM(TrE_WartoscNettoWal),
   TrN_NumerIdentKnt
    FROM cdn.TraElem
   JOIN @TraNag ON TrN_TrNId = TrE_TrNId
   --JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
   JOIN cdn.Towary ON Twr_TwrId = TrE_TwrId
   JOIN cdn.KodyCN ON KCN_KCNId = Twr_KCNId
    WHERE  TrE_TrNId IN ( SELECT TrN_TrNId FROM @TrNId  ) /*and TrE_Ilosc >=0*/  and TrE_TrEID in (select tre_treid from cdn.TraElem where  TrE_Ilosc >=0)
    GROUP BY
   TrN_NumerIdentKnt,
   TrN_KodKraju,
   TrN_KodTransakcji,
   KCN_Kod,
   Twr_KrajPochodzenia,
   TrN_Waluta,
   TrN_DataTransportu,
   TrN_DataWys
  INSERT INTO @IntrastatElemTM
    (
   IsE_Kraj,
   IsE_Opis,
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   IsE_MasaNetto,
   IsE_IloscJMUzup,
   TrN_DataTransportu,
   TrN_DataWys,
   TrN_Waluta,
   IsE_NettoWal,
   IsE_NettoSys,
   IsE_NettoEur,
   IsE_NumerIdentKnt
    )
    SELECT
   IsE_Kraj             = TrN_KodKraju,
   IsE_Opis             = MAX(SUBSTRING(KCN_Opis,1,255)),
   IsE_RodzajTransakcji = TrN_KodTransakcji,
   IsE_CN               = KCN_Kod,
   IsE_KrajPochodzenia  = CASE WHEN @Rodzaj='1' THEN Twr_KrajPochodzenia ELSE '' END,
   IsE_MasaNetto        = SUM(TrE_Ilosc * -1 * CASE WHEN KCN_Masa = 1 THEN Twr_Masa ELSE 0 END ),
   IsE_IloscJMUzup      = SUM(CASE WHEN ISNULL(KCN_UzupJM,'') ='' THEN 0 ELSE TrE_Ilosc* -1 END * ISNULL(Twr_JMPomPrzelicznikL,0) / ISNULL(Twr_JMPomPrzelicznikM,1)),
   TrN_DataTransportu   = TrN_DataTransportu,
   TrN_DataTransportu   = TrN_DataWys,
   TrN_Waluta           = TrN_Waluta,
   IsE_NettoWal         = SUM(TrE_WartoscNettoWal* -1),
   IsE_NettoSys         = 0,
   IsE_NettoEur         = SUM(TrE_WartoscNettoWal *-1),
   TrN_NumerIdentKnt
    FROM cdn.TraElem
   JOIN @TraNag ON TrN_TrNId = TrE_TrNId
   --JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
   JOIN cdn.Towary ON Twr_TwrId = TrE_TwrId
   JOIN cdn.KodyCN ON KCN_KCNId = Twr_KCNId
    WHERE  TrE_TrNId IN ( SELECT TrN_TrNId FROM @TrNIdKor  ) /*and TrE_Ilosc >=0*/  and TrE_TrEID in (select tre_treid from cdn.TraElem where  TrE_Ilosc <0)
    GROUP BY
   TrN_NumerIdentKnt,
   TrN_KodKraju,
   TrN_KodTransakcji,
   KCN_Kod,
   Twr_KrajPochodzenia,
   TrN_Waluta,
   TrN_DataTransportu,
   TrN_DataWys
  INSERT INTO @IntrastatElem
    (
   IsE_Kraj,
   IsE_Opis,
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   IsE_MasaNetto,
   IsE_IloscJMUzup,
   TrN_DataTransportu,
   TrN_DataWys,
   TrN_Waluta,
   IsE_NettoWal,
   IsE_NettoSys,
   IsE_NettoEur,
   Ise_NumerIdentKnt
    )
    select
   IsE_Kraj,
   MAX(IsE_Opis),
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   SUM(IsE_MasaNetto),
   SUM(IsE_IloscJMUzup),
   TrN_DataTransportu,
   TrN_DataWys,
   TrN_Waluta,
   SUM(IsE_NettoWal),
   SUM(IsE_NettoSys),
   SUM(IsE_NettoEur),
   Ise_NumerIdentKnt
    from @IntrastatElemTM
     GROUP BY
   IsE_NumerIdentKnt,
   IsE_Kraj,
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   TrN_Waluta,
   TrN_DataTransportu,
   TrN_DataWys
 end
   else
   BEGIN
    INSERT INTO @IntrastatElemTM
    (
   IsE_Kraj,
   IsE_Opis,
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   IsE_MasaNetto,
   IsE_IloscJMUzup,
   TrN_DataTransportu,
   TrN_DataWys,
   TrN_Waluta,
   IsE_NettoWal,
   IsE_NettoSys,
   IsE_NettoEur,
   Ise_NumerIdentKnt
    )
    SELECT
   IsE_Kraj             = TrN_KodKraju,
   IsE_Opis             = MAX(SUBSTRING(KCN_Opis,1,255)),
   IsE_RodzajTransakcji = TrN_KodTransakcji,
   IsE_CN               = KCN_Kod,
   IsE_KrajPochodzenia  = CASE WHEN @Rodzaj='1' THEN Twr_KrajPochodzenia ELSE '' END,
   IsE_MasaNetto        = SUM(TrE_Ilosc * CASE WHEN KCN_Masa = 1 THEN Twr_Masa ELSE 0 END ),
   IsE_IloscJMUzup      = SUM(CASE WHEN ISNULL(KCN_UzupJM,'') ='' THEN 0 ELSE TrE_Ilosc END * ISNULL(Twr_JMPomPrzelicznikL,0) / ISNULL(Twr_JMPomPrzelicznikM,1)),
   TrN_DataTransportu   = TrN_DataTransportu,
   TrN_DataTransportu   = TrN_DataWys,
   TrN_Waluta           = TrN_Waluta,
   IsE_NettoWal         = SUM(TrE_WartoscNettoWal),
   IsE_NettoSys         = 0,
   IsE_NettoEur         = SUM(TrE_WartoscNettoWal),
   ''
    FROM cdn.TraElem
   JOIN @TraNag ON TrN_TrNId = TrE_TrNId
   --JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
   JOIN cdn.Towary ON Twr_TwrId = TrE_TwrId
   JOIN cdn.KodyCN ON KCN_KCNId = Twr_KCNId
    WHERE  TrE_TrNId IN ( SELECT TrN_TrNId FROM @TrNId  ) /*and TrE_Ilosc >=0*/  and TrE_TrEID in (select tre_treid from cdn.TraElem where  TrE_Ilosc >=0)
    GROUP BY
   TrN_KodKraju,
   TrN_KodTransakcji,
   KCN_Kod,
   Twr_KrajPochodzenia,
   TrN_Waluta,
   TrN_DataTransportu,
   TrN_DataWys
  INSERT INTO @IntrastatElemTM
    (
   IsE_Kraj,
   IsE_Opis,
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   IsE_MasaNetto,
   IsE_IloscJMUzup,
   TrN_DataTransportu,
   TrN_DataWys,
   TrN_Waluta,
   IsE_NettoWal,
   IsE_NettoSys,
   IsE_NettoEur,
   Ise_NumerIdentKnt
    )
    SELECT
   IsE_Kraj             = TrN_KodKraju,
   IsE_Opis             = MAX(SUBSTRING(KCN_Opis,1,255)),
   IsE_RodzajTransakcji = TrN_KodTransakcji,
   IsE_CN               = KCN_Kod,
   IsE_KrajPochodzenia  = CASE WHEN @Rodzaj='1' THEN Twr_KrajPochodzenia ELSE '' END,
   IsE_MasaNetto        = SUM(TrE_Ilosc * -1 * CASE WHEN KCN_Masa = 1 THEN Twr_Masa ELSE 0 END ),
   IsE_IloscJMUzup      = SUM(CASE WHEN ISNULL(KCN_UzupJM,'') ='' THEN 0 ELSE TrE_Ilosc* -1 END * ISNULL(Twr_JMPomPrzelicznikL,0) / ISNULL(Twr_JMPomPrzelicznikM,1)),
   TrN_DataTransportu   = TrN_DataTransportu,
   TrN_DataTransportu   = TrN_DataWys,
   TrN_Waluta           = TrN_Waluta,
   IsE_NettoWal         = SUM(TrE_WartoscNettoWal* -1),
   IsE_NettoSys         = 0,
   IsE_NettoEur         = SUM(TrE_WartoscNettoWal *-1),
   ''
    FROM cdn.TraElem
   JOIN @TraNag ON TrN_TrNId = TrE_TrNId
   --JOIN cdn.TraNag ON TrN_TrNId = TrE_TrNId
   JOIN cdn.Towary ON Twr_TwrId = TrE_TwrId
   JOIN cdn.KodyCN ON KCN_KCNId = Twr_KCNId
    WHERE  TrE_TrNId IN ( SELECT TrN_TrNId FROM @TrNIdKor  ) /*and TrE_Ilosc >=0*/  and TrE_TrEID in (select tre_treid from cdn.TraElem where  TrE_Ilosc <0)
    GROUP BY
   TrN_KodKraju,
   TrN_KodTransakcji,
   KCN_Kod,
   Twr_KrajPochodzenia,
   TrN_Waluta,
   TrN_DataTransportu,
   TrN_DataWys
  INSERT INTO @IntrastatElem
    (
   IsE_Kraj,
   IsE_Opis,
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   IsE_MasaNetto,
   IsE_IloscJMUzup,
   TrN_DataTransportu,
   TrN_DataWys,
   TrN_Waluta,
   IsE_NettoWal,
   IsE_NettoSys,
   IsE_NettoEur,
   IsE_NumerIdentKnt
    )
    select
   IsE_Kraj,
   MAX(IsE_Opis),
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   SUM(IsE_MasaNetto),
   SUM(IsE_IloscJMUzup),
   TrN_DataTransportu,
   TrN_DataWys,
   TrN_Waluta,
   SUM(IsE_NettoWal),
   SUM(IsE_NettoSys),
   SUM(IsE_NettoEur),
   '' from @IntrastatElemTM
     GROUP BY
   IsE_Kraj,
   IsE_RodzajTransakcji,
   IsE_CN,
   IsE_KrajPochodzenia,
   TrN_Waluta,
   TrN_DataTransportu,
   TrN_DataWys
 end
  -- Przeliczanie na PLN po kursie wg daty transportu i zadanego numeru kursu
  DECLARE IsE CURSOR LOCAL FAST_FORWARD FOR
    SELECT IsE_IsEId, TrN_Waluta, TrN_DataWys FROM @IntrastatElem
    OPEN IsE
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM IsE INTO @IsE_IsEId, @TrN_Waluta, @TrN_DataWys
        IF @@FETCH_STATUS <> 0 BREAK
          -- kurs z konfiguracji
          IF @DataStart < CONVERT( DATETIME,'2008-12-01',120)
          BEGIN
            SET @sqltxt = 'EXEC [' + @ServerCfgString +'].['+@BazaCfgString+'].CDN.PobierzNotowania '''',' + @KursNumer + ', '''+ CONVERT(NVARCHAR(10),@TrN_DataWys,120) + ''',' + @PobierajOstatniKurs + ',1'
          END
          ELSE
          BEGIN
            SET @TrN_DataWys = @TrN_DataWys-1
            SELECT @dw = ( (DATEPART(dw, @TrN_DataWys) + @@DATEFIRST-2) % 7 + 1)
            if  @dw = 7
               SET @TrN_DataWys = @TrN_DataWys-2
            if  @dw = 6
               SET @TrN_DataWys = @TrN_DataWys-1
            SET @sqltxt = 'EXEC [' + @ServerCfgString +'].['+@BazaCfgString+'].CDN.PobierzNotowania '''',' + @KursNumer + ', '''+ CONVERT(NVARCHAR(10),@TrN_DataWys,120) + ''',' + @PobierajOstatniKurs + ',1'
          END
          CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta NVARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
          INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
          EXEC sp_executesql @SQLTxt
          -- istnienie waluty transakcji
          IF ISNULL(@TrN_Waluta, '') <> '' AND NOT EXISTS ( SELECT *
          FROM #Notowania
          WHERE UPPER(Waluta) = UPPER(@TrN_Waluta) )
            BEGIN
              SET @Komunikat = '##OPT34453##%%s1%%=' + @TrN_Waluta+ '##'
              --SET @Komunikat = ' Automatyczne naliczenie deklaracji Intrastat niemożliwe ! Brak waluty ' + @TrN_Waluta + '.'
              RAISERROR( @Komunikat, 16, 1)
              SET NOCOUNT OFF
              RETURN
            END
          -- kurs waluty transakcji
          SELECT TOP 1
             @Brak = Brak,
             @WalKursL = KursL,
             @WalKursM = KursM
          FROM #Notowania
          WHERE UPPER(Waluta) = UPPER(@TrN_Waluta)
          IF @Brak = 1
            BEGIN
     SET @Komunikat = '##OPT34454##%%s1%%=' + @TrN_Waluta+ '%%s2%%=' + CONVERT(NVARCHAR(10),@TrN_DataWys,120) + '##'
              --SET @Komunikat = ' Automatyczne naliczenie deklaracji Intrastat niemożliwe ! Brak kursu ' + @TrN_Waluta + ' na dzień ' + CONVERT(NVARCHAR(10),@TrN_DataWys,120) + ' ! '
              RAISERROR( @Komunikat, 16, 1)
              SET NOCOUNT OFF
              RETURN
            END
          -- istnienie EUR
          IF NOT EXISTS ( SELECT TOP 1 Waluta
          FROM #Notowania
          WHERE UPPER(Waluta) = 'EUR' )
            BEGIN
              SET @Komunikat = '##OPT34455##'--SET @Komunikat = ' Automatyczne naliczenie deklaracji Intrastat niemożliwe ! Brak waluty EUR . '
              RAISERROR( @Komunikat, 16, 1)
              SET NOCOUNT OFF
              RETURN
            END
          -- kurs EURO
          SELECT TOP 1
             @Brak = Brak,
             @EurKursL = KursL,
             @EurKursM = KursM
          FROM #Notowania
          WHERE UPPER(Waluta) = 'EUR'
          IF @Brak = 1
            BEGIN
     SET @Komunikat = '##OPT34454##%%s1%%=' + @TrN_Waluta+ '%%s2%%=' + CONVERT(NVARCHAR(10),@TrN_DataWys,120) + '##'
              --SET @Komunikat = ' Automatyczne naliczenie deklaracji Intrastat niemożliwe ! Brak kursu waluty EUR na dzień ' + CONVERT(NVARCHAR(10),@TrN_DataWys,120) + ' ! '
              RAISERROR( @Komunikat, 16, 1)
              SET NOCOUNT OFF
              RETURN
            END
          --
          IF ISNULL(@TrN_Waluta,'') = '' OR ISNULL(@TrN_Waluta,'') = (SELECT TOP 1 Waluta FROM #Notowania WHERE Systemowa = 1 )
            SELECT
             @WalKursL = 1,
             @WalKursM = 1
          DROP TABLE #Notowania
          -- wartość netto w walucie systemowej i w EUR
          UPDATE @IntrastatElem SET
            IsE_NettoSys = IsE_NettoWal * @WalKursL/@WalKursM,
            IsE_NettoEur = IsE_NettoWal * @WalKursL/@WalKursM * @EurKursM/@EurKursL
          WHERE IsE_IsEId = @IsE_IsEId
      END
    CLOSE IsE
  DEALLOCATE IsE
  -- grupowanie elementów po przeliczeniu na PLN
  SELECT
     IsE_Lp               = 0,
     IsE_Kraj             = IsE_Kraj,
     IsE_Opis      = MAX(IsE_Opis),
     IsE_RodzajTransakcji = IsE_RodzajTransakcji,
     IsE_CN               = IsE_CN,
     IsE_KrajPochodzenia  = IsE_KrajPochodzenia,
     IsE_MasaNetto        = Round(SUM(IsE_MasaNetto),0),
     IsE_IloscJmUzup      = SUM(IsE_IloscJmUzup),
     IsE_NettoSys         = SUM(IsE_NettoSys),
     IsE_NettoEur         = SUM(IsE_NettoEur),
  IsE_NumerIdentKnt    = IsE_NumerIdentKnt
   INTO #IsETmp
   FROM @IntrastatElem
   GROUP BY
     IsE_NumerIdentKnt,
     IsE_Kraj,
     IsE_RodzajTransakcji,
     IsE_CN,
     IsE_KrajPochodzenia
   DELETE FROM @IntrastatElem
   INSERT INTO @IntrastatElem
   (
     IsE_Kraj,
     IsE_Opis,
     IsE_RodzajTransakcji,
     IsE_CN,
     IsE_KrajPochodzenia,
     IsE_MasaNetto,
     IsE_IloscJmUzup,
     IsE_NettoSys,
     IsE_NettoEur,
  IsE_NumerIdentKnt
   )
   SELECT
     IsE_Kraj,
     IsE_Opis,
     IsE_RodzajTransakcji,
     IsE_CN,
     IsE_KrajPochodzenia,
     IsE_MasaNetto,
     IsE_IloscJmUzup,
     IsE_NettoSys,
     IsE_NettoEur,
  IsE_NumerIdentKnt
   FROM #IsETmp
   DROP TABLE #IsETmp
  -- grupowanie elementów o wartości < 100 EUR
  DECLARE @IsEdoskasowania TABLE (IsEId INT)
  --INSERT INTO @IsEdoskasowania (IsEId)
  --  SELECT IsE_IsEId FROM @IntrastatElem WHERE ABS(IsE_NettoEur) < @GranicaMalejWartosci
  INSERT INTO @IsEdoskasowania (IsEId)
  SELECT IsE_IsEId FROM @IntrastatElem WHERE ABS(IsE_NettoEur) < @GranicaMalejWartosci
     and IsE_Kraj not in (SELECT IsE_Kraj FROM @IntrastatElem
   GROUP BY IsE_Kraj
  HAVING SUM(ABS(IsE_NettoEur))  >= @GranicaMalejWartosci)
  INSERT INTO @IntrastatElem  ( IsE_Kraj,    IsE_Opis, IsE_RodzajTransakcji,     IsE_CN, IsE_KrajPochodzenia, IsE_MasaNetto, IsE_IloscJmUzup,     IsE_NettoSys,IsE_NumerIdentKnt  )
   SELECT                       IsE_Kraj, '',                   '', '99500000',                  '',             0,               0, SUM(IsE_NettoSys), ''
  FROM @IntrastatElem
    JOIN @IsEdoskasowania ON IsEId = IsE_IsEId
  GROUP BY IsE_Kraj
  DELETE @IntrastatElem FROM @IntrastatElem JOIN @IsEdoskasowania ON IsEId = IsE_IsEId
/* -- 9.0 inny sposób grupowania małych wartości
  DECLARE @IsEdoskasowania TABLE (IsEId INT)
  SET @SumaMalychWartosci = 0.00
  DECLARE IsE CURSOR LOCAL FAST_FORWARD FOR
    SELECT IsE_IsEId, IsE_NettoEur, IsE_NettoSys FROM @IntrastatElem
    OPEN IsE
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM IsE INTO @IsE_IsEId, @IsE_NettoEur, @IsE_NettoSys
        IF @@FETCH_STATUS <> 0 BREAK
          IF ABS(@IsE_NettoEur) < @GranicaMalejWartosci
            BEGIN
              SET @SumaMalychWartosci = @SumaMalychWartosci + ISNULL(@IsE_NettoSys,0)
              DELETE FROM @IntrastatElem WHERE IsE_IsEId = @IsE_IsEId
            END
      END
    CLOSE IsE
  DEALLOCATE IsE
  IF @SumaMalychWartosci > 0
    INSERT INTO @IntrastatElem  ( IsE_Kraj,    IsE_Opis, IsE_RodzajTransakcji,     IsE_CN, IsE_KrajPochodzenia, IsE_MasaNetto, IsE_IloscJmUzup,        IsE_NettoSys )
      SELECT                             '', '< 100 EUR',                   '', '99500000',                  '',             0,               0, @SumaMalychWartosci
*/
  -- nadawanie Lp
  SET @Lp = 1
  DECLARE IsE CURSOR LOCAL FAST_FORWARD FOR
    SELECT IsE_IsEId FROM @IntrastatElem
    OPEN IsE
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM IsE INTO @IsE_IsEId
        IF @@FETCH_STATUS <> 0 BREAK
          UPDATE @IntrastatElem SET IsE_Lp = @Lp WHERE IsE_IsEId = @IsE_IsEId
          SET @Lp = @Lp + 1
      END
    CLOSE IsE
  DEALLOCATE IsE
 -- update w celu zaokraglenia do pełnych złotych masy i wartości netto pozycji
  UPDATE @IntrastatElem SET
    IsE_NettoSys     = ROUND(IsE_NettoSys,    0),
    IsE_MasaNetto    = ROUND(IsE_MasaNetto,   0),
    IsE_IloscJmUzup  = ROUND(IsE_IloscJmUzup, 0)
  -- procedura zwraca elementy deklaracji z nadanymi Lp
  IF @IsN_IsNId > 0
    BEGIN
   if @Tryb = 0
    DELETE FROM cdn.IntrastatElem WHERE IsE_IsNId = @IsN_IsNId and IsE_Automatyczny = 1
      UPDATE cdn.TraNag SET TrN_IsNId = NULL WHERE TrN_IsNId = CONVERT(INT, @IsN_IsNId)
   if @Tryb = 0
    INSERT INTO cdn.IntrastatElem (              IsE_IsNId, IsE_Lp, IsE_Opis, IsE_Kraj, IsE_RodzajTransakcji, IsE_CN, IsE_KrajPochodzenia, IsE_MasaNetto, IsE_JMUzup,      IsE_Netto, IsE_NumerIdentKnt     )
   SELECT                        CONVERT(INT, @IsN_IsNId), IsE_Lp, IsE_Opis, IsE_Kraj, IsE_RodzajTransakcji, IsE_CN, IsE_KrajPochodzenia, IsE_MasaNetto, IsE_IloscJMUzup, IsE_NettoSys, IsE_NumerIdentKnt
     FROM @IntrastatElem
     ORDER BY IsE_Lp
      -- oznaczenie nagłówków biorących udział w tworzeniu Intrastat
      UPDATE cdn.TraNag SET TrN_IsNId = @IsN_IsNId
        WHERE TrN_TrNId IN ( SELECT TrN_TrNId FROM @TrNId )
   -- oznaczenie nagłówków biorących udział w tworzeniu Intrastat
      UPDATE cdn.TraNag SET TrN_IsNId = @IsN_IsNId
        WHERE TrN_TrNId IN ( SELECT TrN_TrNId FROM @TrNIdKor )
      SET NOCOUNT OFF
    END
  ELSE
    BEGIN
    SET NOCOUNT OFF
      SELECT
        IsE_Lp,
        IsE_Opis,
        IsE_Kraj,
        IsE_RodzajTransakcji,
        IsE_CN,
        IsE_KrajPochodzenia,
        IsE_MasaNetto,
        IsE_IloscJMUzup,
        IsE_NettoSys,
  IsE_NumerIdentKnt
      FROM @IntrastatElem
      ORDER BY IsE_Lp
    END
