CREATE PROCEDURE [CDN].jdp_getDocInfoList
   @KntID int = NULL,
   @Nazwa NVARCHAR(255) = NULL
AS
SELECT
   OfD_OfDID AS ID,
   OfD_KntID AS KntID,
   OfD_Nazwa AS Nazwa
FROM
   CDN.OfertyDok
WHERE
   (@KntID IS NULL OR OfD_KntID = @KntID) AND
   (@Nazwa IS NULL OR OfD_Nazwa = @Nazwa) AND
   (NOT OfD_KntID IS NULL)
ORDER BY
   OfD_Nazwa
