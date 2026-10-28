CREATE PROCEDURE CDN.InsertDorDokumentySkojarzoneDoZlecenia( @id INT )
AS
BEGIN
    SET NOCOUNT ON
   DECLARE @srsTyp INT, @faTyp INT, @wzTyp INT, @autoItem INT
 SET @faTyp = 302
 SET @wzTyp = 306
 SET @srsTyp = 900
 SET @autoItem = 255
 -- teraz faktury powiązane z WZ wystawionym ze zlecenia serwisowego
 INSERT INTO [CDN].[DokRelacje]([DoR_ParentTyp], [DoR_ParentId], [DoR_DokumentTyp], [DoR_DokumentId], [DoR_Flaga])
 SELECT DISTINCT 900 As 'DoR_ParentTyp', @id As 'DoR_ParentId', TrR_FaTyp As 'DoR_DokumentTyp', TrR_FaId As 'DoR_DokumentId', @autoItem
    FROM cdn.TraNagRelacje
 JOIN cdn.DokRelacje ON TrR_TrNID = DoR_DokumentId  AND TrR_TrNTyp = DoR_DokumentTyp AND DoR_ParentTyp=@srsTyp AND DoR_ParentId = @id AND DoR_Flaga = @autoItem
 JOIN cdn.TraNag ON TrN_TypDokumentu = TrR_FaTyp AND TrN_TrNId = TrR_FaId AND TrN_Bufor <> -1
 WHERE TrN_Bufor > -1 AND TrN_TrNID NOT IN ( SELECT DoR_DokumentId FROM cdn.DokRelacje WHERE DoR_ParentTyp=@srsTyp AND DoR_ParentId=@id AND DoR_DokumentTyp = TrN_TypDokumentu)
 -- teraz korekty do faktur powiązanych ze zleceniem serwisowym
 INSERT INTO [CDN].[DokRelacje]([DoR_ParentTyp], [DoR_ParentId], [DoR_DokumentTyp], [DoR_DokumentId], [DoR_Flaga])
 SELECT DISTINCT 900 As 'DoR_ParentTyp', @id As 'DoR_ParentId', TrN_TypDokumentu As 'DoR_DokumentTyp', TrN_TrNId As 'DoR_DokumentId', @autoItem
 FROM cdn.TraNag JOIN cdn.DokRelacje ON DoR_ParentTyp=@srsTyp AND DoR_ParentId=@id AND DoR_DokumentTyp=@faTyp  AND DoR_Flaga = @autoItem
 WHERE TrN_Bufor > -1 AND TrN_ZwrId = DoR_DokumentId
 AND TrN_TrNID NOT IN ( SELECT DoR_DokumentId FROM cdn.DokRelacje WHERE DoR_ParentTyp=@srsTyp AND DoR_ParentId=@id AND DoR_DokumentTyp = TrN_TypDokumentu)
 -- teraz korekty do faktur wystawionych do WZ powiązanych ze zleceniem serwisowym
 INSERT  INTO [CDN].[DokRelacje]([DoR_ParentTyp], [DoR_ParentId], [DoR_DokumentTyp], [DoR_DokumentId], [DoR_Flaga])
 SELECT DISTINCT 900 As 'DoR_ParentTyp', @id As 'DoR_ParentId', K.TrN_TypDokumentu As 'DoR_DokumentTyp', K.TrN_TrNId As 'DoR_DokumentId', @autoItem
 FROM cdn.DokRelacje
 JOIN cdn.TraNagRelacje ON DoR_DokumentTyp = TrR_TrNTyp AND DoR_DokumentId = TrR_TrNId
    JOIN cdn.TraNag F ON TrR_FaTyp = F.TrN_TypDokumentu AND TrR_FaId = F.TrN_TrNId AND F.TrN_Bufor <> -1
    JOIN cdn.TraNag K ON F.TrN_TrNId = K.TrN_ZwrId AND F.TrN_Bufor <> -1 AND K.TrN_Bufor <> -1
 WHERE DoR_ParentTyp=@srsTyp AND DoR_ParentId = @id  AND DoR_Flaga = @autoItem
 AND K.TrN_TrNID NOT IN ( SELECT DoR_DokumentId FROM cdn.DokRelacje WHERE DoR_ParentTyp=@srsTyp AND DoR_ParentId=@id AND DoR_DokumentTyp = K.TrN_TypDokumentu)
 ORDER BY DoR_DokumentId
    SET NOCOUNT OFF
END
