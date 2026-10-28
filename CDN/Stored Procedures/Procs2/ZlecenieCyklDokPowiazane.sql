CREATE PROCEDURE CDN.ZlecenieCyklDokPowiazane(
@id   INT,
@dataOd  DATETIME,
@dataDo  DATETIME
)
AS
BEGIN
 IF @DataOd IS NULL OR @DataDo IS NULL
 BEGIN
  SELECT DoR_DoRId, DoR_ParentTyp, DoR_ParentId, DoR_ParentGUID, DoR_DokumentTyp, DoR_DokumentId, DoR_DokumentGUID, DoR_Flaga, 0 AS DoR_Kierunek
  FROM cdn.DokRelacje
  WHERE DoR_ParentTyp = 906 AND DoR_ParentId=@id
  ORDER BY DoR_DokumentId
 END
 ELSE
 BEGIN
  SET @dataOd = cdn.DateOnly(@DataOd)
  SET @dataDo = cdn.DateOnly(@DataDo)
  SELECT DoR_DoRId, DoR_ParentTyp, DoR_ParentId, DoR_ParentGUID, DoR_DokumentTyp, DoR_DokumentId, DoR_DokumentGUID, DoR_Flaga, 0 AS DoR_Kierunek
  FROM cdn.DokRelacje
  JOIN cdn.SrsZlecenia ON DoR_DokumentTyp = 900 AND  DoR_DokumentId = SrZ_SrZId AND SrZ_DataDok BETWEEN @dataOd AND @dataDo
  WHERE DoR_ParentTyp = 906 AND DoR_ParentId=@id
  ORDER BY DoR_DokumentId
 END
END
