CREATE FUNCTION [CDN].[StatusJPK]( @JPKID INT)
RETURNS NVARCHAR(100)
AS
BEGIN
 DECLARE @ret NVARCHAR(100);
 SELECT @ret =
 CASE JPK_StatusCode
  WHEN -1 THEN 'Nie podlega'
  WHEN 2 THEN 'Wysłano/nie odebrano UPO'
  WHEN 3 THEN 'Wysłano/odebrano UPO'
  WHEN 4 THEN 'Podpisany Profilem Zaufanym ePUAP/Nie wysłano'
  WHEN 100 THEN 'Wysłano/nie odebrano UPO'
  WHEN 101 THEN 'Błąd wysyłania dokumentu'
  WHEN 102 THEN 'Błąd wysyłania żądania UPO'
  WHEN 110 THEN 'Błąd wysyłania'
  WHEN 120 THEN 'Wysłano/nie odebrano UPO'
  WHEN 200 THEN 'Wysłano/odebrano UPO'
  WHEN 300 THEN 'Błąd przetwarzania'
  WHEN 301 THEN 'Wysłano/nie odebrano UPO'
  WHEN 302 THEN 'Wysłano/nie odebrano UPO'
  WHEN 303 THEN 'Wysłano/nie odebrano UPO'
  WHEN 400 THEN 'Błąd przetwarzania'
  WHEN 401 THEN 'Błąd przetwarzania'
  WHEN 402 THEN 'Błąd przetwarzania'
  WHEN 404 THEN 'Błąd przetwarzania'
  WHEN 405 THEN 'Błąd przetwarzania'
  WHEN 406 THEN 'Błąd przetwarzania'
  WHEN 407 THEN 'Błąd przetwarzania'
  WHEN 408 THEN 'Błąd przetwarzania'
  WHEN 409 THEN 'Błąd przetwarzania'
  WHEN 410 THEN 'Błąd przetwarzania'
  WHEN 411 THEN 'Błąd przetwarzania'
  WHEN 412 THEN 'Błąd przetwarzania'
  WHEN 413 THEN 'Błąd przetwarzania'
  WHEN 414 THEN 'Błąd przetwarzania'
  WHEN 415 THEN 'Błąd przetwarzania'
  ELSE 'Nie wysłano'
 END
 FROM CDN.PlikiJPK WHERE JPK_JPKID = @JPKID
 IF @ret IS NULL
  SET @ret = 'Brak';
 RETURN @ret
END
