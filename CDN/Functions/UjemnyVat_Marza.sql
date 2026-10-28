CREATE FUNCTION CDN.UjemnyVat_Marza(@VaNId int)
RETURNS int
AS
BEGIN
    declare @result int = 0
 IF EXISTS(
  SELECT *
  FROM CDN.VatNag
  LEFT OUTER JOIN CDN.VatTab ON VaT_VaNID = VaN_VaNID
  WHERE
  VaN_VaNID = @VaNId AND VaN_Rodzaj = 5 AND VaN_RazemNetto = 0 AND VaN_RazemVAT = 0
  AND VaT_StawkaSymbol != 'NP' AND VaT_Netto < 0)
   SET @result = 1
    return @result;
END
