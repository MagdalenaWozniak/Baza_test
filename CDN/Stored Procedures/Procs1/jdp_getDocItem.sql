CREATE PROCEDURE [CDN].jdp_getDocItem
   @ID int
AS
SELECT
   OfD_OfDID AS ID,
   OfD_Nazwa AS Nazwa,
   OfD_KntID AS KntID,
   OfD_TrNID AS FaktID,
   OfD_Body AS Tresc,
   OfD_OpeZalID AS OpeZalID,
   OfD_OpeModID AS OpeModID
FROM
   CDN.OfertyDok
WHERE
   OfD_OfDID = @ID
