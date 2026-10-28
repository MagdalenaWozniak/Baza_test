CREATE FUNCTION CDN.GetDDfIDFromRowIDOrSymbol(@DDf_ImportRowId NVARCHAR(36), @DDf_Symbol NVARCHAR(5))
RETURNS INT
AS
BEGIN
 DECLARE @ddfID INT;
 IF EXISTS(SELECT DDf_DDfID FROM CDN.DokDefinicje WHERE @DDf_ImportRowId=DDf_ImportRowId AND DDf_ImportRowId IS NOT NULL AND DDf_ImportRowId <> '')
  SELECT @ddfID = DDf_DDfId
  FROM CDN.DokDefinicje
  WHERE DDf_ImportRowId = @DDf_ImportRowId
 ELSE
  SELECT @ddfID = DDf_DDfId
  FROM CDN.DokDefinicje
  WHERE DDf_Symbol = @DDf_Symbol AND DDF_Nieaktywna = 0
 RETURN @ddfID;
END
