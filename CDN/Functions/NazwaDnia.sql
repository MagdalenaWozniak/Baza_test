CREATE FUNCTION cdn.NazwaDnia (@Data DATETIME, @Mode INT)
  RETURNS     NVARCHAR(22)
  AS
  BEGIN
    -- funkcja zwraca nazwe dnia tygodnia
    IF @Data IS NULL
        RETURN ''
    DECLARE @Nazwa         NVARCHAR(22)
    SET @Nazwa = ''
    DECLARE @Format        INT
    IF @Mode < 2
        SET @Format = @Mode
    ELSE
        SET @Format = @Mode - 2
    DECLARE @dw   INT
    SELECT @dw = ( (DATEPART(dw, @Data) + @@DATEFIRST-2) % 7 + 1)
    SET @Nazwa =
    CASE
       WHEN @dw=1 AND @Format=0 THEN 'poniedziałek'
       WHEN @dw=1 AND @Format=1 THEN 'pon'
       WHEN @dw=2 AND @Format=0 THEN 'wtorek'
       WHEN @dw=2 AND @Format=1 THEN 'wt'
       WHEN @dw=3 AND @Format=0 THEN 'środa'
       WHEN @dw=3 AND @Format=1 THEN 'śr'
       WHEN @dw=4 AND @Format=0 THEN 'czwartek'
       WHEN @dw=4 AND @Format=1 THEN 'cz'
       WHEN @dw=5 AND @Format=0 THEN 'piątek'
       WHEN @dw=5 AND @Format=1 THEN 'pt'
       WHEN @dw=6 AND @Format=0 THEN 'sobota'
       WHEN @dw=6 AND @Format=1 THEN 'sob'
       WHEN @dw=7 AND @Format=0 THEN 'niedziela'
       WHEN @dw=7 AND @Format=1 THEN 'nie'
    END
    IF @Mode > 1
      SET @Nazwa = RTRIM(@Nazwa) + ' ' + Convert(NVARCHAR(10),@Data, 120)
    RETURN  @Nazwa
  END
