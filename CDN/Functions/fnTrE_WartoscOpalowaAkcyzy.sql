CREATE FUNCTION [CDN].[fnTrE_WartoscOpalowaAkcyzy] ( @TrE_TrEId INT)
RETURNS DECIMAL(15,3)
AS
BEGIN
  RETURN (
                  select case when TrN_ZwolnionyZAkcyzy = 1 then 0 else round( Tre_AkcyzaStawka * Tre_Ilosc * Tre_AkcyzaJMPomPrzelicznikM/Tre_AkcyzaJMPomPrzelicznikL,3) end from cdn.TraElem
                  left join cdn.TraNag on TrN_TrNId = TrE_TrNId
                  where TrE_TrEID = @TrE_TrEId
         )
END
