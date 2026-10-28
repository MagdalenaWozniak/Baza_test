CREATE FUNCTION CDN.StatusEDeklaracji( @DkNID INT)
RETURNS NVARCHAR(100)
AS
BEGIN
 DECLARE @ret NVARCHAR(100);
 SELECT @ret =
  CASE WHEN DkN_RokMiesiac < 200800 THEN
   'Nie dotyczy'
  ELSE
   CASE DkN_EDekl_Status
       WHEN 2 THEN 'Wysłano/nie odebrano UPO'-- dla deklaracji AKCWW
    WHEN 3 THEN 'Wysłano/odebrano UPO'-- dla deklaracji AKCWW
    WHEN 100 THEN 'Błąd wysyłania'
    WHEN 101 THEN 'Błąd wysyłania dokumentu'
    WHEN 102 THEN 'Błąd wysyłania żądania UPO'
    WHEN 200 THEN 'Wysłano/odebrano UPO'
    WHEN 301 THEN 'Wysłano/nie odebrano UPO'
    WHEN 302 THEN 'Wysłano/nie odebrano UPO'
    WHEN 303 THEN 'Wysłano/nie odebrano UPO'
    WHEN 306 THEN 'Wysłano/nie odebrano UPO'
    WHEN 400 THEN 'Błąd przetwarzania'
    WHEN 401 THEN 'Błąd przetwarzania'
    WHEN 402 THEN 'Błąd przetwarzania'
    WHEN 403 THEN 'Błąd przetwarzania'
    WHEN 404 THEN 'Błąd przetwarzania'
    WHEN 405 THEN 'Błąd przetwarzania'
    WHEN 406 THEN 'Błąd przetwarzania'
    WHEN 407 THEN 'Błąd przetwarzania'
    ELSE 'Nie wysłano'
   END
  END
 FROM CDN.DeklNag WHERE DkN_DkNID = @DkNID
 IF @ret IS NULL
  SET @ret = '';
 RETURN @ret
END
