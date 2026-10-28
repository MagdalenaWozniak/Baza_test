CREATE FUNCTION [CDN].[fnTrN_WartoscAkcyzy] (@TrN_TrNID INT)
RETURNS DECIMAL (15,2)
AS
BEGIN
 DECLARE @Zwolniony INT
SELECT @Zwolniony = TrN_ZwolnionyZAkcyzy FROM CDN.TraNag WHERE Trn_TrNID = @TrN_TrNID
IF @Zwolniony = 0
RETURN(
select
  isnull(sum(round(case when Tre_AkcyzaJMPomPrzelicznikL = 0 then 0 else Tre_AkcyzaOpal * Tre_AkcyzaStawka * Tre_Ilosc * Tre_AkcyzaJMPomPrzelicznikM/Tre_AkcyzaJMPomPrzelicznikL end,2)) ,0)
 from cdn.TraNag
 left join cdn.TraElem on TrN_TrNId = TrE_TrNId
where TrN_TrNID = @TrN_TrNID
GROUP BY TrN_ZwolnionyZAkcyzy
)
RETURN 0
END
