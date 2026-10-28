CREATE FUNCTION [CDN].[fnTrE_WartoscAkcyzy] ( @TrE_TrEId INT)
RETURNS DECIMAL(15,2)
AS
BEGIN
  RETURN (
   select  round(case when (Tre_AkcyzaJMPomPrzelicznikL = 0 or TrN_ZwolnionyZAkcyzy <> 0) then 0 else Tre_AkcyzaOpal * Tre_AkcyzaStawka * Tre_Ilosc * Tre_AkcyzaJMPomPrzelicznikM/Tre_AkcyzaJMPomPrzelicznikL end,2) from cdn.TraElem
   left join cdn.TraNag on TrN_TrNId = TrE_TrNId
   where TrE_TrEID = @TrE_TrEId
         )
END
