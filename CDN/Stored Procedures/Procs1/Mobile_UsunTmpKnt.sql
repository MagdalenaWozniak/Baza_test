CREATE Procedure [CDN].[Mobile_UsunTmpKnt]
@ID int, -- id mobilnego sprzedawcy
@KntId int -- id tymczasowego kontrahenta
AS
BEGIN
 delete from CDN.DetalKontrahenci
  where DKnt_StanDetalID = @ID and DKnt_DSKntId = @KntId
END
