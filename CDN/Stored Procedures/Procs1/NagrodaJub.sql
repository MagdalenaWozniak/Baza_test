CREATE Procedure [CDN].[NagrodaJub]
 @Od    DATETIME,
 @Do    DATETIME,
 @GuidNr   varchar(50),
 @Lata   INT,
 @Nauka   INT,
 @All   INT,
 @CzyWybrany  INT,
 @StazPozaFirma INT,
 @Urlop   INT
As
 SET NOCOUNT ON
 DECLARE @Nazwisko nvarchar(40)
 DECLARE @Imie  nvarchar(30)
 DECLARE @Kod  varchar(20)
 DECLARE @Id   int
 DECLARE @Dni  int
 DECLARE @Zapisy INT
 SET  @Dni = 0
 SET  @Zapisy = 0
 DECLARE @Slata  INT
 DECLARE @Smies  INT
 DECLARE @Sdni  INT
 DECLARE @SUMSlata INT
 DECLARE @SUMSmies INT
 DECLARE @SUMSdni INT
 DECLARE @PFlata   INT
 DECLARE @PFmies   INT
 DECLARE @PFdni   INT
 DECLARE @SumPFlata  INT  -- lata poza firma
 DECLARE @SumPFmies  INT  -- mies poza firma
 DECLARE @SumPFdni  INT  -- dni poza firma
 DECLARE @Alllata  INT
 DECLARE @Allmies  INT
 DECLARE @Alldni   INT
 DECLARE @SumAlllata  INT  -- lata stazu
 DECLARE @SumAllmies  INT  -- mies stazu
 DECLARE @SumAlldni  INT  -- dni stazu
 DECLARE @Wynik DATETIME
 SET @Wynik = CONVERT(DATETIME, '2999-12-31', 120)
 DECLARE @DElata  INT
 DECLARE @DEmies  INT
 DECLARE @DEdni  INT
 DECLARE @SumDElata  INT
 DECLARE @SumDEmies  INT
 DECLARE @SumDEdni  INT
 DECLARE @lata_ile INT
 DECLARE @mies_ile INT
 DECLARE @dni_ile  INT
 CREATE TABLE #Dane (
  Tmp_Nazwisko nvarchar(40),
  Tmp_Imie1  nvarchar(30),
  Tmp_Kod   varchar(20),
  Tmp_Id   INT,
  Tmp_Data  DATETIME
  )
 DECLARE Tmp_NagrodaJub CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 SELECT PRI_Nazwisko, PRI_Imie1, PRI_Kod, PRi_PraId
 FROM   CDN.Pracidx
 INNER JOIN CDN.RptZaznaczenia2 ON PRI_PraId=RpZ2_GIDNumer
 WHERE RpZ2_GUID=@GuidNr and PRI_Typ=1
 ORDER BY PRI_Nazwisko
 OPEN Tmp_NagrodaJub
 WHILE 1=1
BEGIN
  FETCH NEXT FROM Tmp_NagrodaJub INTO  @Nazwisko, @Imie, @Kod, @Id
  IF @@FETCH_STATUS <> 0 BREAK
BEGIN
  SET @PFlata   = 0 -- zmienne praca w firmie
  SET @PFmies   = 0
  SET @PFdni   = 0
  SET @SumPFlata  = 0
  SET @SumPFmies  = 0
  SET @SumPFdni  = 0
  SET @Slata   = 0 -- zmienne lata w szkole
  SET @Smies   = 0
  SET @Sdni   = 0
  SET @SUMSlata  = 0
  SET @SUMSmies  = 0
  SET @SUMSdni  = 0
  SET @Alllata  = 0 -- sumarycznie lata
  SET @Allmies  = 0
  SET @Alldni   = 0
  SET @SumAlllata  = 0
  SET @SumAllmies  = 0
  SET @SumAlldni  = 0
  SET @DElata = 0 -- lata z historii zatrudnienia
  SET @DEmies = 0
  SET @DEdni = 0
  SET @SumDElata = 0
  SET @SumDEmies = 0
  SET @SumDEdni = 0
  SET @DElata = (select IsNull(SUM(HZT_StazLata),0) from CDN.HisZatrud where HZT_PraId = @Id and HZT_Etaty=1)
  SET @DEmies = (select IsNull(SUM(HZT_StazMies),0) from CDN.HisZatrud where HZT_PraId = @Id and HZT_Etaty=1)
  SET @DEdni = (select IsNull(SUM(HZT_StazDni),0) from CDN.HisZatrud where HZT_PraId = @Id and HZT_Etaty=1)
  SET @lata_ile = 0
  SET @mies_ile = 0
  SET @dni_ile = 0
  IF (@DEdni<30 AND @DEmies<12) OR ((@DEmies + ROUND((@DEdni/30), 0, 1))<12)
  BEGIN
   SET @SumDElata = @DElata
  END
   ELSE
  BEGIN
   SET @SumDElata = @DElata + ROUND((ROUND((@DEdni/30) ,0,1)+ @DEmies)/12,0,1)
  END
   IF (@DEdni<30 and @DEmies<12)
  BEGIN
   SET @SumDEmies = @DEmies
  END
   ELSE
   IF (@DEmies + ROUND((@DEdni/30),0,1))<12
  BEGIN
   SET @SumDEmies = @DEmies + Round((@DEdni/30),0,1)
  END
   ELSE
  BEGIN
   SET @SumDEmies = (@DEmies + ROUND((@DEdni/30),0,1))  - (ROUND(((@DEmies + ROUND((@DEdni/30), 0,1))/12),0,1)*12)
  END
   IF @DEdni < 30
  BEGIN
   SET @SumDEdni = @DEdni
  END
   ELSE
  BEGIN
   SET @SumDEdni = (@DEdni % 30)
  END
IF @Nauka = 1   -- uwzgledniac okres nauki TAK
BEGIN
   SET @Slata = (select IsNull(SUM(HWY_StazLata),0) from CDN.HisWyksztal where HWY_PraId = @Id)
   SET @Smies = (select IsNull(SUM(HWY_StazMies),0) from CDN.HisWyksztal where HWY_PraId = @Id)
   SET @Sdni = (select IsNull(SUM(HWY_StazDni),0) from CDN.HisWyksztal where HWY_PraId = @Id)
   IF (@Sdni<30 AND @Smies<12) OR ((@Smies + ROUND((@Sdni/30), 0, 1))<12)
  BEGIN
   SET @SUMSlata = @Slata
  END
   ELSE
  BEGIN
   SET @SUMSlata = @Slata + ROUND((ROUND((@Sdni/30) ,0,1)+ @Smies)/12,0,1)
  END
   IF (@Sdni<30 and @Smies<12)
  BEGIN
   SET @SUMSmies = @Smies
  END
   ELSE
   IF (@Smies + ROUND((@Sdni/30),0,1))<12
  BEGIN
   SET @SUMSmies = @Smies + Round((@Sdni/30),0,1)
  END
   ELSE
  BEGIN
   SET @SUMSmies = (@Smies + ROUND((@Sdni/30),0,1))  - (ROUND(((@Smies + ROUND((@Sdni/30), 0,1))/12),0,1)*12)
  END
   IF @Sdni < 30
  BEGIN
   SET @SUMSdni = @Sdni
  END
   ELSE
  BEGIN
   SET @SUMSdni = (@Sdni % 30)
  END
END
BEGIN
  IF (@All = 1) OR (@All=0 and @CzyWybrany=1 and @StazPozaFirma=0)  -- uwzgledniac  caly staz poza firma TAK
           -- lub uwzgledniac caly staz poza firma NIE i wybrac ktory staz BRAK
  BEGIN
   SET @PFlata = (select IsNull(SUM(HZT_StazLata),0) from CDN.HisZatrud where HZT_PraId = @Id and HZT_Etaty=0)
   SET @PFmies = (select IsNull(SUM(HZT_StazMies),0) from CDN.HisZatrud where HZT_PraId = @Id and HZT_Etaty=0)
   SET @PFdni = (select IsNull(SUM(HZT_StazDni),0) from CDN.HisZatrud where HZT_PraId = @Id and HZT_Etaty=0)
  IF (@PFdni<30 AND @PFmies<12) OR ((@PFmies + ROUND((@PFdni/30), 0, 1))<12)
   BEGIN
    SET @SUMPFlata = @PFlata
   END
  ELSE
   BEGIN
    SET @SUMPFlata = @PFlata + ROUND((ROUND((@PFdni/30) ,0,1)+ @PFmies)/12,0,1)
   END
     IF (@PFdni<30 and @PFmies<12)
   BEGIN
    SET @SUMPFmies = @PFmies
   END
     ELSE
     IF (@PFmies + ROUND((@PFdni/30),0,1))<12
   BEGIN
    SET @SUMPFmies = @PFmies + Round((@PFdni/30),0,1)
   END
     ELSE
   BEGIN
    SET @SUMPFmies = (@PFmies + ROUND((@PFdni/30),0,1))  - (ROUND(((@PFmies + ROUND((@PFdni/30), 0,1))/12),0,1)*12)
   END
     IF @PFdni < 30
   BEGIN
    SET @SUMPFdni = @PFdni
   END
     ELSE
   BEGIN
    SET @SUMPFdni = (@PFdni % 30)
   END
 END
  IF @All = 0   -- uwzgledniac caly stac poza firma NIE
  BEGIN
  IF @CzyWybrany = 1  -- uwzgledniac wybrany rodzaj stazu poza firma TAK  - zapytanie dla wybranego
  BEGIN
   SET @PFlata = (select IsNull(SUM(HZT_StazLata),0) from CDN.HisZatrud where HZT_PraId = @Id AND HZT_DkmId = @StazPozaFirma and HZT_Etaty=0)
   SET @PFmies = (select IsNull(SUM(HZT_StazMies),0) from CDN.HisZatrud where HZT_PraId = @Id AND HZT_DkmId = @StazPozaFirma and HZT_Etaty=0)
   SET @PFdni = (select IsNull(SUM(HZT_StazDni),0) from CDN.HisZatrud where HZT_PraId = @Id AND HZT_DkmId = @StazPozaFirma and HZT_Etaty=0)
   IF (@PFdni<30 AND @PFmies<12) OR ((@PFmies + ROUND((@PFdni/30), 0, 1))<12)
  BEGIN
   SET @SUMPFlata = @PFlata
  END
   ELSE
  BEGIN
   SET @SUMPFlata = @PFlata + ROUND((ROUND((@PFdni/30) ,0,1)+ @PFmies)/12,0,1)
  END
   IF (@PFdni<30 and @PFmies<12)
  BEGIN
   SET @SUMPFmies = @PFmies
  END
   ELSE
      IF (@PFmies + ROUND((@PFdni/30),0,1))<12
  BEGIN
   SET @SUMPFmies = @PFmies + Round((@PFdni/30),0,1)
  END
   ELSE
  BEGIN
   SET @SUMPFmies = (@PFmies + ROUND((@PFdni/30),0,1))  - (ROUND(((@PFmies + ROUND((@PFdni/30), 0,1))/12),0,1)*12)
  END
   IF @PFdni < 30
  BEGIN
   SET @SUMPFdni = @PFdni
  END
   ELSE
  BEGIN
   SET @SUMPFdni = (@PFdni % 30)
  END
  END
  END
  SET @Alllata  = @SUMPFlata + @SUMSlata + @SumDElata
  SET @Allmies  = @SUMPFmies + @SUMSmies + @SumDEmies
  SET @Alldni   = @SUMPFdni  + @SUMSdni + @SumDEdni
  IF (@Alldni<30 AND @Allmies<12) OR ((@Allmies + ROUND((@Alldni/30), 0, 1))<12)
  BEGIN
   SET @SUMAllLata = @AllLata
  END
  ELSE
  BEGIN
   SET @SUMAllLata = @AllLata + ROUND((ROUND((@Alldni/30) ,0,1)+ @Allmies)/12,0,1)
  END
  IF (@Alldni<30 and @Allmies<12)
  BEGIN
   SET @SUMAllmies = @Allmies
  END
  ELSE
  IF (@Allmies + ROUND((@Alldni/30),0,1))<12
  BEGIN
   SET @SUMAllmies = @Allmies + Round((@Alldni/30),0,1)
  END
  ELSE
  BEGIN
   SET @SUMAllmies = (@Allmies + ROUND((@Alldni/30),0,1))  - (ROUND(((@Allmies + ROUND((@Alldni/30), 0,1))/12),0,1)*12)
  END
  IF @Alldni < 30
  BEGIN
   SET @SUMAlldni = @Alldni
  END
  ELSE
  BEGIN
   SET @SUMAlldni = (@Alldni % 30)
  END
  IF  (@SUMAllLata>@Lata) OR ((@SUMAllLata=@Lata) AND (@SUMAllmies<>0 OR @SUMAlldni<>0))
  SET @Wynik = CONVERT(DATETIME, '2999-12-31', 120)
  ELSE
   BEGIN
 IF @SumAlldni>0
  SET @dni_ile = 30 - @SumAlldni
 IF @SumAlldni>0
  SET @mies_ile = 12 - @SumAllmies - 1
 IF @SumAlldni=0 and @SumAllmies>0
  SET @mies_ile = 12 - @SumAllmies
 IF @SumAlldni=0 and @SumAllmies=0
  SET @mies_ile = 0
 IF @SumAlldni=0 and @SumAllmies=0
  SET @lata_ile = @Lata - @SUMAlllata
 IF @SumAlldni>0 or @SumAllmies > 0
  SET @lata_ile = @Lata - @SUMAlllata - 1
 exec [CDN].[ZapisyHist] @Id, @dni_ile, @mies_ile, @lata_ile, @Urlop, @Wynik OUTPUT
 IF @Wynik between @Od and @Do
  INSERT INTO #Dane  VALUES (@Nazwisko, @Imie, @Kod, @Id,@Wynik)
 SET @Wynik = CONVERT(DATETIME, '2999-12-31', 120)
  END
END
END
END
 CLOSE  Tmp_NagrodaJub
 DEALLOCATE  Tmp_NagrodaJub
SELECT * FROM #Dane
