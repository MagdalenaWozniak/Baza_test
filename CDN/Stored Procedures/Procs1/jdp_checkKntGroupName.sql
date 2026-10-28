CREATE PROCEDURE [CDN].jdp_checkKntGroupName
   @Group NVARCHAR(255) = '',
 @Exists int output
AS
IF @Group = ''
 SET @Exists = 1
ELSE
SELECT
   @Exists = COUNT(*)
FROM
   CDN.Grupy
WHERE
   Gru_Typ = 31 AND Gru_Nazwa = @Group
