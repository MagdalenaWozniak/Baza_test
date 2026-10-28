CREATE FUNCTION CDN.ListaDokumentowRozliczajacych( @DokumentID int )
RETURNS TABLE
AS
RETURN(
 SELECT
  DokumentID = BZd_DokumentID,
  NumerDok = CASE WHEN BRK_LDokTyp=1 AND BRK_LDokID=BZd_BZdID THEN BRK_PNumer ELSE BRK_LNumer END,
  KwotaRoz = BRK_Kwota,
  DataRoz = BRK_DataDok,
  Waluta = BRK_Waluta,
  Termin = BZd_Termin,
  TypDokKB = CASE WHEN BRK_LDokTyp=1 AND BRK_LDokID=BZd_BZdID THEN BRK_PDokTyp ELSE BRK_LDokTyp END,
  IDDokKB = CASE WHEN BRK_LDokTyp=1 AND BRK_LDokID=BZd_BZdID THEN BRK_PDokID ELSE BRK_LDokID END
 FROM cdn.BnkZdarzenia
  JOIN cdn.BnkRozKwoty ON (BRK_LDokTyp=1 AND BRK_LDokID=BZd_BZdID OR BRK_PDokTyp=1 AND BRK_PDokID=BZd_BZdID)
 WHERE BZd_DokumentTyp = 1
  AND BZd_DokumentID IN (@DokumentID)
)
