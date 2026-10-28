CREATE FUNCTION cdn.fn_IsWorkingDay(@date DATETIME)
RETURNS INT
AS
BEGIN
  -- soboty i niedziele
 --IF DATENAME(dw, @date) = 'Saturday' OR DATENAME(dw, @date) = 'Sunday'
 -- RETURN 0
 -- DATENAME działa zależnie od języka, więc odpada.
 -- DATEPART(dw z kolei zwraca int-a, ale zależnego od ustawienia pierwszego dnia tygodnia (@@DATEFIRST). W Optimie jest on ustawiany na połączeniu na 1, ale domyślnie na serwerze może być inny
 -- (najczęściej 7 - po "hamerykańsku"). Dlatego trzeba najpierw wyliczyć dzień tygodnia niezależny od ustawień, co robimy poniżej przyjmując 1 - pn,..., 7 - niedziela.
 DECLARE @dayOfWeek TINYINT
 IF @@DATEFIRST + DATEPART(dw, CONVERT(DATETIME, @date, 120)) > 7
  SELECT @dayOfWeek = @@DATEFIRST + DATEPART(dw, CONVERT(DATETIME, @date, 120)) - 8
 ELSE
  SELECT @dayOfWeek = @@DATEFIRST + DATEPART(dw, CONVERT(DATETIME, @date, 120)) - 1
 IF @dayOfWeek = 0
  SELECT @dayOfWeek = 7
 IF @dayOfWeek = 6 OR @dayOfWeek = 7
  RETURN 0
  -- święta stałe
 IF (
  MONTH(@date) =  1 AND DAY(@date) = 1 OR
  MONTH(@date) =  1 AND DAY(@date) = 6 OR
  MONTH(@date) =  5 AND DAY(@date) = 1 OR
  MONTH(@date) =  5 AND DAY(@date) = 3 OR
  MONTH(@date) =  8 AND DAY(@date) = 15 OR
  MONTH(@date) = 11 AND DAY(@date) =  1 OR
  MONTH(@date) = 11 AND DAY(@date) = 11 OR
  MONTH(@date) = 12 AND DAY(@date) = 25 OR
  MONTH(@date) = 12 AND DAY(@date) = 26
  )
  RETURN 0
  -- święta ruchome
 IF EXISTS (SELECT * FROM cdn.SwietaRuchome WHERE SwR_Data = @date)
  RETURN 0
 RETURN 1
END
