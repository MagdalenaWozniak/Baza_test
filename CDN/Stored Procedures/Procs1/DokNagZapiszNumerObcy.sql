CREATE PROCEDURE CDN.DokNagZapiszNumerObcy( @numerPelny NVARCHAR(30), @dokTyp INT, @dokId INT)
AS
BEGIN
 UPDATE DN
 SET DN.DoN_NumerObcy = @numerPelny
 FROM cdn.DokNag DN
 JOIN cdn.DokRelacje ON DoR_ParentTyp = 750 AND DoR_ParentId = DN.DoN_DoNID
         AND DoR_DokumentTyp = @dokTyp AND DoR_DokumentId = @dokId
 WHERE DN.DoN_NumerObcy = ''
END
