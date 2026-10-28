CREATE FUNCTION CDN.fnProcentPodatkuMiesiac(@PrcId INT, @Dochod DECIMAL(15,4), @Rok INT, @Miesiac INT)
RETURNS DECIMAL(5,2)
 AS
 BEGIN
 DECLARE @procent DECIMAL(5,2)
 DECLARE @Ile INT
 SET @Ile = (select count(*) from CDN.Progi where PRG_PreId = @PrcId)
 IF @Ile <> 0
  SET @Procent = (select top 1 PRG_Procent from CDN.Progi
  where PRG_Kwota <= @Dochod and PRG_PreId = @PrcId
  order by PRG_Kwota desc)
 ELSE
  BEGIN
   IF @Rok < 2007
   BEGIN
    If @Dochod <= 37024
    SET @Procent = 19
    Else
    BEGIN
     If @Dochod > 37024 and @Dochod < 74048
     SET @Procent = 30
     Else
     SET @Procent = 40
    END
   END
 ELSE
  IF @Rok = 2007
   BEGIN
   If @Dochod <= 43405
   SET @Procent = 19
   Else
    BEGIN
     If @Dochod > 43405 and @Dochod < 85528
     SET @Procent = 30
     Else
     SET @Procent = 40
    END
   END
 ELSE
  IF @Rok = 2008
   BEGIN
   If @Dochod <= 44490
   SET @Procent = 19
   Else
    BEGIN
     If @Dochod > 44490 and @Dochod < 85528
     SET @Procent = 30
     Else
     SET @Procent = 40
    END
   END
 ELSE
  IF @Rok >= 2009
   BEGIN
    If @Dochod < 85528
  If @Rok < 2019 or @Rok = 2019 and @Miesiac <10
  SET @Procent = 18
  Else
  SET @Procent = 17
  Else
  SET @Procent = 32
   END
  END
RETURN @Procent
END
