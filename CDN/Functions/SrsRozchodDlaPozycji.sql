CREATE FUNCTION CDN.SrsRozchodDlaPozycji (@ParentTyp INT, @ParentId INT, @ForTyp INT)
RETURNS INT
AS
BEGIN
    DECLARE @ChildTyp INT ,@ChildId INT, @zlecenieId INT, @autoItem INT
 SET @autoItem = 255
    SET @ChildId = 0
    SELECT TOP 1 @ChildTyp = TeR_ChildTyp, @ChildId = TeR_ChildId FROM  CDN.TraElemRelacje
    WHERE TeR_ParentTyp=@ParentTyp and TeR_ParentId=@ParentId
    and TeR_ChildTyp IN (302,304,305,306)
    ORDER BY TeR_TeRId
 -- sprawdz, czy istnieja RW do agreagacji do FA
 IF @ForTyp = 302 AND @ChildId > 0 AND  @ChildTyp <> @ForTyp -- sprawdz, czy sa RW do agregacji
 BEGIN
  IF  @ParentTyp = 902 AND @ForTyp = 302
  BEGIN
   SELECT TOP 1 @zlecenieId = SrC_SrZId FROM cdn.SrsCzesci WHERE SrC_SrCId = @ParentId AND SrC_Fakturowac = 0
   IF @zlecenieId IS NOT NULL
    IF EXISTS( SELECT TOP 1 TrN_TrnId FROM cdn.TraNag
      JOIN cdn.DokRelacje ON DoR_DokumentTyp=TrN_TypDokumentu AND DoR_DokumentId=TrN_TrnId AND DoR_Flaga = @autoItem
      LEFT OUTER JOIN cdn.TraNagRelacje ON DoR_DokumentTyp = TrR_TrNTyp And DoR_DokumentId = TrR_TrNId
      WHERE TrN_TypDokumentu=304 AND TrR_TrRId Is NULL AND DoR_DokumentTyp=304
      AND DoR_ParentTyp=900 AND DoR_ParentId=@zlecenieId )
      SET @ChildId = 0
  END
 END
    RETURN @ChildId
END
