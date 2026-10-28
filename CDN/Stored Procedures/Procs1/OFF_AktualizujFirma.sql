CREATE  PROCEDURE CDN.OFF_AktualizujFirma
  @Fir_Numer    INT,
  @Fir_Wartosc  nvarchar(254),
  @Fir_Opis     nvarchar(254)
AS
  SET NOCOUNT ON
  DECLARE @Fir_FirId INT
  SELECT TOP 1 @Fir_FirId = Fir_FirId  FROM cdn.Firma WHERE Fir_Numer = @Fir_Numer
  IF @Fir_FirId IS NULL
    INSERT INTO cdn.Firma (  Fir_Numer,  Fir_Wartosc,  Fir_Opis )
      VALUES              ( @Fir_Numer, @Fir_Wartosc, @Fir_Opis )
  ELSE
    UPDATE cdn.Firma SET Fir_Wartosc = @Fir_Wartosc WHERE  Fir_FirId = @Fir_FirId
  SET NOCOUNT OFF
