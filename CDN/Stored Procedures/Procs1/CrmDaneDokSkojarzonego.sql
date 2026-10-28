--SELECT * FROM  cdn.CRMDokumenty
CREATE PROCEDURE cdn.CrmDaneDokSkojarzonego(@DokumentTyp INT, @DokumentId INT)
AS
BEGIN
IF @DokumentTyp = 101
BEGIN
 SELECT EDN_NumerPelny As NumerPelny,
 'EDK' As TypDokumentu,
 EdN_DataDok As DataDok,
 '' As Opis
 FROM cdn.EwidDodNag WHERE  EDN_EDNID = @DokumentId
 GOTO KONIEC
END
IF @DokumentTyp IN (111,113)
BEGIN
 SELECT TOP 1
 KDN_NumerPelny As NumerPelny,
 CASE KDN_Typ WHEN 111 THEN 'PS-KH' WHEN 113 THEN 'NO-KH' ELSE '' END As TypDokumentu,
 KDN_DataDok As DataDok,
 CONVERT(NVARCHAR(50), KDN_Opis, 120) As Opis
 FROM cdn.KsiDokNag WHERE KDN_KDNId = @DokumentId
END
IF @DokumentTyp = 221
BEGIN
 SELECT TOP 1
 NON_NumerPelny As NumerPelny,
 'NO-KB' As TypDokumentu,
 NON_DataDok As DataDok,
 CONVERT(NVARCHAR(50), NON_Uwagi, 120) As Opis
 FROM cdn.NotyOdsNag WHERE NON_NONId  = @DokumentId
END
IF @DokumentTyp IN (222, 223, 1002)
BEGIN
 SELECT TOP 1
 BDN_NumerPelny As NumerPelny,
 CASE BDN_Typ WHEN 222 THEN 'PON-KB' WHEN 223 THEN 'PS-KB' ELSE '' END As TypDokumentu,
 BdN_DataDok As DataDok,
 BdN_Uwagi As Opis
 FROM cdn.BnkDokNag WHERE BDN_BDNId = @DokumentId
END
IF @DokumentTyp IN (302 ,301 ,308 ,309 ,320 ,306 ,307 ,303 ,304 ,311 ,312 ,310 ,317 ,318 ,322 ,321 ,350 ,305 ,313 ,314 ,345 )
BEGIN
 SELECT TOP 1 TrN_NumerPelny As NumerPelny,
 cdn.TypDokumentu(TrN_TypDokumentu) As TypDokumentu,
 TrN_DataDok As DataDok,
 TrN_Opis As Opis
 FROM cdn.TraNag WHERE TrN_TrnId = @DokumentId
 GOTO KONIEC
END
IF @DokumentTyp = 700
BEGIN
 SELECT CrK_NumerPelny As NumerPelny,
 'CRM' As TypDokumentu,
 CrK_DataDok As DataDok,
 CrK_Temat As Opis
 FROM cdn.CrmKontakty WHERE CrK_CrKId = @DokumentId
 GOTO KONIEC
END
IF @DokumentTyp = 710
BEGIN
 SELECT AnkAnN_NumerPelny As NumerPelny,
 'ANK' As TypDokumentu,
 AnkAnN_DataDok As DataDok,
 AnkAnN_Nazwa As Opis
 FROM cdn.AnkAnkietyNag WHERE AnkAnN_AnkAnNId = @DokumentId
 GOTO KONIEC
END
IF @DokumentTyp = 714
BEGIN
 SELECT AnkWaN_Kod As NumerPelny,
 'WZ_ANK' As TypDokumentu,
 cdn.DateOnly(AnkWaN_TS_Zal) As DataDok,
 AnkWaN_Nazwa As Opis
 FROM cdn.AnkWzorzecAnkietyNag WHERE AnkWaN_AnkWaNId = @DokumentId
 GOTO KONIEC
END
-- Sekretariat
IF @DokumentTyp = 750
BEGIN
 SELECT DoN_NumerPelny As NumerPelny,
 'OBD' As TypDokumentu,
 DoN_DataDok As DataDok,
 DoN_Tytul As Opis
 FROM cdn.DokNag WHERE DoN_DoNId = @DokumentId
 GOTO KONIEC
END
IF @DokumentTyp = 900
BEGIN
 SELECT SrZ_NumerPelny As NumerPelny, 'SRW' As TypDokumentu,
 SrZ_DataDok As DataDok,
 SrZ_Opis As Opis
 FROM cdn.SrsZlecenia WHERE SrZ_SrZId = @DokumentId
 GOTO KONIEC
END
IF @DokumentTyp = 999
BEGIN
 SELECT VaN_Dokument As NumerPelny,
 'VAT'  As TypDokumentu,
 VaN_DataOpe As DataDok,
 '' As Opis
 FROM cdn.VatNag WHERE VaN_VanId = @DokumentId
 GOTO KONIEC
END
IF @DokumentTyp IN (1000, 1001)
BEGIN
 SELECT case DKB_NumerPelny when '' then DKB_Numer else DKB_NumerPelny end  As NumerPelny,
 case DKB_TypDokumentuKB when 2 then
  case DKB_Kierunek when -1 then 'ZKB-KW' else 'ZKB-KP' end
 when 1 then 'PP' end As TypDokumentu,
 DkB_DataDok As DataDok,
 DkB_Opis As Opis
 FROM cdn.DokumentyKBView
 WHERE ( Dkb_TypDokumentuKB=2 or @DokumentTyp<>1000) AND --Dok ZKB
    ( Dkb_TypDokumentuKB=1 or @DokumentTyp<>1001) AND --Dok PP
      Dkb_DkbId = @DokumentId
 GOTO KONIEC
END
IF @DokumentTyp = 1002
BEGIN
 SELECT BDN_NumerPelny As NumerPelny,
 case BDN_Typ when 222 then 'PON' when 223 then 'NO' else '' end As TypDokumentu,
 BdN_DataDok As DataDok,
 BdN_Uwagi As Opis
 FROM cdn.BnkDokNag WHERE BDN_BDNId  = @DokumentId
 AND  ( (BDN_Typ = 222) or --PO
      (BDN_Typ = 223)   )  --NO
 GOTO KONIEC
END
 IF @DokumentTyp = 1003 --  e_op_KlasaEwidencjaDodatkowa
 BEGIN
  SELECT TOP 1 EDN_NumerPelny As NumerPelny,
               'EwD' As TypDokumentu,
               CONVERT(NVARCHAR(10), EDN_DataDok, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod, 120) As PodmiotDok
               From cdn.EwidDodNag left outer join cdn.podmiotyview on EDN_podid = pod_podid and EDN_podmiottyp = pod_podmiottyp Where EDN_EDNId = @DokumentId
  GOTO KONIEC
 END
 IF @DokumentTyp = 1004 --  e_op_KlasaSrodkiTrwale
 BEGIN
  SELECT TOP 1 SrT_NrInwent As NumerPelny,
               'ŚrT' As TypDokumentu,
               CONVERT(NVARCHAR(50),SrT_Nazwa) As Opis,
               CONVERT(NVARCHAR(10), SrT_DataZak, 120) As DataDok,
               '' As PodmiotDok
               From cdn.Trwale
               Where SrT_SrTId = @DokumentId
  GOTO KONIEC
 END
 IF @DokumentTyp = 1005 --  e_op_KlasaWyposazenie
 BEGIN
  SELECT TOP 1 Wyp_NrInwent As NumerPelny,
               'Wyp' As TypDokumentu,
               CONVERT(NVARCHAR(50),Wyp_Nazwa) As Opis,
               CONVERT(NVARCHAR(10), Wyp_DataZak, 120) As DataDok,
               '' As PodmiotDok
               From cdn.Wyposazenie
               Where Wyp_WypId = @DokumentId
  GOTO KONIEC
 END
 IF @DokumentTyp = 1006 --  e_op_KlasaPolecenieKsiegowania
 BEGIN
  SELECT TOP 1 DeN_Dokument As NumerPelny,
               'PK' As TypDokumentu,
               CONVERT(NVARCHAR(50),DeN_Kategoria) As Opis,
               CONVERT(NVARCHAR(10), DeN_DataDok, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod, 120) As PodmiotDok
               From cdn.DekretyNag left outer join cdn.podmiotyview on DeN_PodmiotId = Pod_PodId and DeN_podmiottyp = pod_podmiottyp
               Where DeN_DeNId = @DokumentId
  GOTO KONIEC
 END
 IF @DokumentTyp = 1007 --  e_op_KlasaDokumentSrodkaTrwalego
 BEGIN
  SELECT TOP 1 SrH_Numer As NumerPelny,
               'DŚrT' As TypDokumentu,
               '' As Opis,
               CONVERT(NVARCHAR(10), SrH_DataOpe, 120) As DataDok,
               '' As PodmiotDok
               From cdn.TrwaleHist
               Where SrH_SrHId = @DokumentId
  GOTO KONIEC
 END
 IF @DokumentTyp = 1008 --  e_op_KlasaZapisKPIR
 BEGIN
  SELECT TOP 1 KPR_Dokument As NumerPelny,
               'KPiR' As TypDokumentu,
               CONVERT(NVARCHAR(50), KPR_Kategoria) As Opis,
               CONVERT(NVARCHAR(10), KPR_DataOpe, 120) As DataDok,
               CONVERT(NVARCHAR(20), Pod_Kod, 120) As PodmiotDok
               From cdn.ZapisyKPR left outer join cdn.podmiotyview on KPR_PodId = Pod_PodId and KPR_PodmiotTyp = Pod_PodmiotTyp
               Where KPR_KPRId = @DokumentId
  GOTO KONIEC
 END
 IF @DokumentTyp = 1009 --  e_op_KlasaZapisEwidencjiRycz
 BEGIN
  SELECT TOP 1 RYC_Dokument As NumerPelny,
               'RYCZ' As TypDokumentu,
               CONVERT(NVARCHAR(50), RYC_Kategoria) As Opis,
               CONVERT(NVARCHAR(10), RYC_DataWpi, 120) As DataDok,
               '' As PodmiotDok
               From cdn.Ryczalt
               Where Ryc_RycId = @DokumentId
  GOTO KONIEC
 END
KONIEC:
END
