CREATE FUNCTION cdn.ZestKsiSegment (@ZKPId INT)
RETURNS NVARCHAR(8)
AS
BEGIN
DECLARE @Wynik NVARCHAR(50)
DECLARE @Numer INT
DECLARE @Schemat CHAR(1)
DECLARE @SchematPozycji CHAR(4)
DECLARE @Poziom SMALLINT
DECLARE @ZKNId int
DECLARE @ParentId int
 SET @Wynik = ''
 SELECT @Numer = ZKP_Lp, @SchematPozycji = ZKP_Numeracja, @Poziom = ZKP_Poziom, @ZKNId = ZKP_ZKNId, @ParentId = ZKP_ParId FROM CDN.ZestKsiPoz WHERE ZKP_ZKPId = @ZKPId
 SELECT @Schemat = SUBSTRING(ZKN_Numeracja, @Poziom, 1) FROM CDN.ZestksiNag WHERE ZKN_ZKNId = @ZKNId
 if @SchematPozycji <> 'AUTO' --and ltrim(rtrim(@Numeracja)) <> @Schemat
 begin
    set @Schemat = @SchematPozycji
    select @Numer = CDN.NumerPozycjiZestawienia(@ZKNId, @ParentId, @Numer, @SchematPozycji)
 end
 else
 begin
    select @Numer = CDN.NumerPozycjiZestawienia(@ZKNId, @ParentId, @Numer, @Schemat)
 end
  IF @Numer < 1 OR @Numer >= 100 RETURN '-'
  IF @Schemat = '' OR @Schemat = '-'
  BEGIN
    SET @Wynik = '-'
  END
  IF @Schemat = '1'
  BEGIN
    SET @Wynik = LTRIM(STR(@Numer))
  END
  IF @Schemat IN ('a', 'A')
  BEGIN
    IF @Numer <= 26
      SET @Wynik = CHAR(@Numer + ASCII('A') - 1)
    ELSE
      SET @Wynik = '-'
  END
  IF @Schemat IN ('x', 'X')
  BEGIN
    SET @Wynik =  CASE FLOOR(@Numer / 10.0)
                  WHEN 1 THEN 'X'
                  WHEN 2 THEN 'XX'
                  WHEN 3 THEN 'XXX'
                  WHEN 4 THEN 'XL'
                  WHEN 5 THEN 'L'
                  WHEN 6 THEN 'LX'
                  WHEN 7 THEN 'LXX'
                  WHEN 8 THEN 'LXXX'
                  WHEN 9 THEN 'XC'
                  ELSE '' END
    SET @Wynik = @Wynik +   CASE @Numer - 10 * FLOOR(@Numer / 10.0)
                            WHEN 1 THEN 'I'
                            WHEN 2 THEN 'II'
                            WHEN 3 THEN 'III'
                            WHEN 4 THEN 'IV'
                            WHEN 5 THEN 'V'
                            WHEN 6 THEN 'VI'
                            WHEN 7 THEN 'VII'
                            WHEN 8 THEN 'VIII'
                            WHEN 9 THEN 'IX'
                            ELSE '' END
  END
  IF ASCII(@Schemat) IN (ASCII('a'), ASCII('x'))
    SET @Wynik = lower(@Wynik)
  RETURN @Wynik
END
