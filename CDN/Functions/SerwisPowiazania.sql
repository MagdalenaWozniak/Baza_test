CREATE FUNCTION CDN.SerwisPowiazania(@Id INT, @IdTyp INT )
RETURNS @Relacje TABLE (TrN_TypDokumentu INT, TrN_NumerPelny NVARCHAR(40), TrN_DataOpe DATETIME,TrN_TrNId INT, TrN_Korekta INT, TrN_DataWys DATETIME, TrN_RazemNetto DECIMAL(15,2), TrN_MagZrdID INT, Trn_Waluta NVARCHAR(5), TrN_RazemNettoWal DECIMAL(15,2))
AS
BEGIN
 IF @IdTyp = 302 OR @IdTyp = 304 OR @IdTyp = 312 OR @IdTyp = 305 OR @IdTyp = 309 OR @IdTyp = 306
    BEGIN
  DECLARE  @srsTyp INT, @faTyp INT, @wzTyp INT,
     @idFaPier INT -- id faktury pierwotnej jeśli to jest korekta
  SET @faTyp = 302
  SET @wzTyp = 306
  SET @srsTyp = 900
  SET @idFaPier = IsNull((SELECT TOP 1 TrN_ZwrId  FROM cdn.TraNag WHERE TrN_TrNId = @Id), -1) -- TRACK ID: 164817
  INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
   SELECT DISTINCT 900, SrZ_NumerPelny, SrZ_DataDok, SrZ_SrZId, NULL, SrZ_DataPrzyjecia, 0, SrZ_MagId,SrZ_Waluta,0
   FROM CDN.SrSZlecenia WHERE SrZ_SrZId IN
    (SELECT DISTINCT DoR_ParentId FROM CDN.DokRelacje WHERE DoR_ParentTyp = @srsTyp AND DoR_DokumentTyp = @IdTyp AND (DoR_DokumentId = @Id OR DoR_DokumentId = @idFaPier)
     UNION
     SELECT DISTINCT DoR_ParentId FROM cdn.DokRelacje
     JOIN cdn.TraNagRelacje ON TrR_TrNID=DoR_DokumentId  AND TrR_TrNTyp=DoR_DokumentTyp AND DoR_ParentTyp=@srsTyp
     JOIN cdn.TraNag        ON TrN_TypDokumentu=TrR_FaTyp AND TrN_TrNId=TrR_FaId
     WHERE TrN_Bufor > -1 AND TrN_TypDokumentu=@IdTyp AND (TrN_TrNId=@Id OR TrN_TrNId=@idFaPier)
    )
 END
 RETURN
END
