CREATE FUNCTION CDN.OpisKorektyKPR(@DokId int, @DokTyp int, @Data datetime)
RETURNS @Result Table(DokumentNumer VARCHAR(30))
AS
BEGIN
 declare @PrevDate DATETIME;
 select @PrevDate = max(DPD_DataKorekty) from CDN.DPD
 where DPD_DokumentID = @DokId AND DPD_DokumentTyp = @DokTyp and DPD_DataKorekty < @Data
 INSERT INTO @Result
 SELECT DISTINCT
 CASE WHEN BRK_LDokTyp=1 AND BRK_LDokID=BZd_BZdID THEN BRK_PNumer ELSE BRK_LNumer END
 FROM cdn.BnkZdarzenia A JOIN cdn.BnkRozKwoty B ON (B.BRK_LDokTyp=1 AND B.BRK_LDokID=A.BZd_BZdID OR B.BRK_PDokTyp=1 AND B.BRK_PDokID=A.BZd_BZdID)
  JOIN CDN.DPD ON DPD_DokumentID = BZd_DokumentID AND DPD_DokumentTyp = BZd_DokumentTyp
 WHERE
  BZd_DokumentTyp = @DokTyp
  and BZd_DokumentID = @DokId
  and BRK_DataDok <= @Data
  and BRK_DataDok > @PrevDate
  and BRK_DataDok > DPD_DataKorekty
   --AND EXISTS(SELECT * FROM CDN.DPD WHERE DPD_DokumentID = @DokId AND DPD_DokumentTyp = @DokTyp)
 RETURN
END
