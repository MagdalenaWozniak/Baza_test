CREATE FUNCTION CDN.RejestrVatOdliczenia(@Typ INT, @VaNID INT)
RETURNS VARCHAR(10)
AS
BEGIN
 IF @Typ = 2
  RETURN ''
 DECLARE @ilosc INT
 DECLARE @odliczenia VARCHAR(10)
 SELECT @ilosc = COUNT(*) FROM (SELECT COUNT(*) as Ilosc FROM CDN.VatTab WHERE VaT_VaNID = @VaNID GROUP BY VaT_Odliczenia) AS IloscOdliczen
 IF @ilosc <> 1
  RETURN '*'
 ELSE
  SELECT TOP 1 @odliczenia = CASE VaT_Odliczenia WHEN 0 THEN 'Nie' WHEN '1' THEN 'Tak' WHEN '2' THEN 'Warunkowo' ELSE 'Nieznane' END
  FROM CDN.VatTab WHERE VaT_VaNID = @VaNID
 RETURN @odliczenia
END
