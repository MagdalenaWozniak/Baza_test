CREATE PROCEDURE CDN.ImportWypNagPopraw @WyNID INT, @Rok INT, @Miesiac INT, @ProcentFGSP DECIMAL(6,2), @ProcentFP DECIMAL(6,2)
AS
BEGIN
 UPDATE CDN.WyplatyNag SET
  WyN_PodstawaFGSP = 100*WyN_PodstawaFGSP / @ProcentFGSP,
  WyN_PodstawaFP   = 100*WyN_PodstawaFP   / @ProcentFP
 WHERE WyN_WyNId = @WyNID;
END
