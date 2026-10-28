CREATE PROCEDURE CDN.IleDniUrlopu @dataod datetime, @datado datetime, @PrcId Int, @ile Int Output
AS
DECLARE @DniN INT
DECLARE @DzienWolny INT
DECLARE @dzien DATETIME
DECLARE @LiczeDni INT
DECLARE @Zest INT
SET @dzien      = @DataOd
SET @DzienWolny = 0
SET @LiczeDni   = 0
SET @DniN = (SELECT isnull(sum(dni),0) FROM ( select datediff(day,case when pnb_okresod<@dataod then @dataod else pnb_okresod end,
                      case when pnb_okresdo>@datado then @datado else pnb_okresdo end)+1 as dni
         FROM CDN.PracNieobec JOIN CDN.TypNieobec ON Pnb_TnbId = Tnb_TnbId
         WHERE pnb_praid = @PrcId and pnb_okresod<=@dataDo AND @dataOd<=pnb_okresdo and TNB_PomnCzasRNA = 0)
         AS Nieobec )
SET @zest = (select isnull(pre_zestczasupracy,99) from cdn.pracetaty where pre_praid=@PrcId and @DataDo between pre_dataod and pre_datado)
IF @dniN <> 0 and @zest = 2
BEGIN
  SET @dzien = CONVERT (DATETIME,  @dzien, 120)
  IF @DataOd IS NULL OR @DataDo IS NULL
  BEGIN
 SET @DataOd = '1899-12-30 00:00:00'
 SET @DataDo = '1899-12-30 00:00:00'
  END
  IF @PrcId IS NULL SET @PrcId = 0
  WHILE @dzien<=@DataDo
  BEGIN
        SET @DzienWolny = 0
 exec @DzienWolny = CDN.CzyDzienWolny @dzien
 IF @DzienWolny = 0
 BEGIN
  IF EXISTS (SELECT 1 from CDN.PracNieobec JOIN CDN.TypNieobec ON Pnb_TnbId = Tnb_TnbId
        where pnb_praid=@PrcId and @dzien>= pnb_okresod AND @dzien<=pnb_okresdo and TNB_PomnCzasRNA = 0)
  SET @LiczeDni = @LiczeDni + 1
 END
        SET @dzien = @dzien + 1
  END
set @ile = @LiczeDni
END
Else
IF @dniN <> 0 and @zest <> 2
BEGIN
  SET @dzien = CONVERT (DATETIME,  @dzien, 120)
  IF @DataOd IS NULL OR @DataDo IS NULL
  BEGIN
 SET @DataOd = '1899-12-30 00:00:00'
 SET @DataDo = '1899-12-30 00:00:00'
  END
  IF @PrcId IS NULL SET @PrcId = 0
  WHILE @dzien<=@DataDo
  BEGIN
        SET @DzienWolny = 0
 exec @DzienWolny = CDN.CzyDzienWolny @dzien
 IF @DzienWolny = 0
 BEGIN
  IF EXISTS (SELECT 1 from CDN.PracNieobec JOIN CDN.TypNieobec ON Pnb_TnbId = Tnb_TnbId
        where pnb_praid=@PrcId and @dzien>= pnb_okresod AND @dzien<=pnb_okresdo)
  SET @LiczeDni = @LiczeDni + 1
 END
        SET @dzien = @dzien + 1
  END
set @ile = @LiczeDni
END
