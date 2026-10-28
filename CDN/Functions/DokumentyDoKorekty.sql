CREATE FUNCTION CDN.DokumentyDoKorekty(@Data DateTime)
RETURNS @Result TABLE( Id Int,
      Typ Int,
      Termin DateTime,
      Opoznienie Int,
      sumaKwotZdarzen Decimal(15,2),
      sumaKwotRozliczen Decimal(15,2),
      kwotaDokumentu Decimal(15,2),
      DataDokumentu DateTime,
      status Int)
AS
BEGIN
 INSERT INTO @Result
 SELECT BZd_DokumentID,
     BZd_DokumentTyp,
     bzd_Termin,
     DATEDIFF(day,BZd_Termin,@Data) as Opoznienie,
     NULL as sumaKwotZdarzen,
     BRK_KwotaSysL as sumaKwotRozliczen,
     NULL as kwotaDokumentu,
     BZd_DataDok,
     0
 FROM
 cdn.BnkZdarzenia
 LEFT OUTER JOIN cdn.BnkRozKwoty ON (brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID) AND (brk_dataDok is NULL or brk_dataDok <= @Data)
 --LEFT OUTER JOIN CDN.DPD ON DPD_DokumentID = BZd_DokumentID AND DPD_DokumentTyp = BZd_DokumentID
 WHERE BZd_DokumentTyp IN (1,2,12)
   AND (BZd_Rozliczono = 1         --dokument nierozliczony
    --OR (BZd_Rozliczono2 = 2 AND BZd_Rozliczono = 1)  --dokument częściowo rozliczony
    --OR (SELECT TOP 1 DPD_Rozliczono FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID ORDER BY DPD_Rozliczono DESC) = 0)  --był wcześniej na zapisie korekcyjnym
    OR EXISTS (SELECT DPD_DPDID FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID) )  --był wcześniej na zapisie korekcyjnym
    OR BZd_DataRoz > @Data --rozliczony, ale po dacie wykonywania korekty
 INSERT INTO @Result
 SELECT BZd_DokumentID,
     BZd_DokumentTyp,
     bzd_Termin,
     DATEDIFF(day,BZd_Termin,@Data) as Opoznienie,
     NULL as sumaKwotZdarzen,
     BRK_KwotaSysP as sumaKwotRozliczen,
     NULL as swotaDokumentu,
     BZd_DataDok,
     0
 FROM
 cdn.BnkZdarzenia
 LEFT OUTER JOIN cdn.BnkRozKwoty ON (brk_PDokTyp = 1 AND brk_PDokID = bzd_BzDID) AND (brk_dataDok is NULL or brk_dataDok <= @Data)
 --LEFT OUTER JOIN CDN.DPD ON DPD_DokumentID = BZd_DokumentID AND DPD_DokumentTyp = BZd_DokumentID
 WHERE BZd_DokumentTyp IN (1,2,12)
   AND (BZd_Rozliczono = 1         --dokument nierozliczony
    --OR (BZd_Rozliczono2 = 2 AND BZd_Rozliczono = 1)  --dokument częściowo rozliczony
    --OR (SELECT TOP 1 DPD_Rozliczono FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID ORDER BY DPD_Rozliczono DESC) = 0 --był wcześniej na zapisie korekcyjnym
    OR EXISTS (SELECT DPD_DPDID FROM CDN.DPD WHERE DPD_DokumentTyp = BZd_DokumentTyp AND DPD_DokumentID = BZd_DokumentID)   --był wcześniej na zapisie korekcyjnym
    OR BZd_DataRoz > @Data
    )
   AND BRK_BRKID Is Not NULL
 INSERT INTO @Result
 SELECT Id, Typ, Termin, DATEDIFF(day,Termin,@Data) as Opoznienie, sumaKwotZdarzen, Sum(IsNull(sumaKwotRozliczen,0)) as sumaKwotRozliczen, kwotaDokumentu, DataDokumentu, 1
 from @Result
 Where status = 0
 GROUP BY Id, Typ, Termin, Termin,SumaKwotZdarzen, KwotaDokumentu, DataDokumentu
 delete from @Result where status = 0
 UPDATE @Result SET sumaKwotZdarzen = (SELECT SUM(ISNULL(BZd_KwotaSys,0)) FROM cdn.BnkZdarzenia WHERE bzd_DokumentTyp = Typ and bzd_DokumentID = Id and BZd_Termin = Termin GROUP BY BZd_DokumentID, BZd_DokumentTyp, BZd_Termin)
 UPDATE @Result SET kwotaDokumentu = (SELECT SUM(ISNULL(BZd_KwotaSys,0)) FROM cdn.BnkZdarzenia WHERE bzd_DokumentTyp = Typ and bzd_DokumentID = Id GROUP BY BZd_DokumentID, BZd_DokumentTyp)
RETURN
END
