--SELECT * FROM  cdn.CRMDokumenty
CREATE PROCEDURE cdn.CrmDaneDokSkojarzonych( @CrDId INT )
AS
BEGIN
SELECT TrN_NumerPelny As NumerPelny,
cdn.TypDokumentu(TrN_TypDokumentu) As TypDokumentu,
TrN_DataDok As DataDok,
TrN_Opis As Opis
FROM cdn.CRMDokumenty JOIN cdn.TraNag ON CrD_DokumentId = TrN_TrnId
WHERE CrD_RodzajDokumentu = 2
AND CrD_TypDokumentu in(302 ,301 ,308 ,309 ,320 ,306 ,307 ,303 ,304 ,311 ,312 ,310 ,317 ,318 ,322 ,321 ,350 ,305 ,313 ,314 ,345 )
AND CrD_CrDId = @CrDId
UNION ALL
SELECT CrK_NumerPelny As NumerPelny,
'CRM' As TypDokumentu,
CrK_DataDok As DataDok,
CrK_Temat As Opis
FROM cdn.CRMDokumenty JOIN cdn.CrmKontakty ON CrD_DokumentId = CrK_CrKId
WHERE CrD_TypDokumentu = 700 AND CrD_CrDId = @CrDId
UNION ALL
SELECT VaN_Dokument As NumerPelny,
'VAT'  As TypDokumentu,
VaN_DataOpe As DataDok,
'' As Opis
FROM cdn.CRMDokumenty JOIN  cdn.VatNag ON CrD_DokumentId = VaN_VanId
WHERE CrD_TypDokumentu = 999  AND CrD_CrDId = @CrDId
UNION ALL
SELECT case DKB_NumerPelny when '' then DKB_Numer else DKB_NumerPelny end  As NumerPelny,
case DKB_TypDokumentuKB when 2 then
 case DKB_Kierunek when -1 then 'ZKB-KW' else 'ZKB-KP' end
when 1 then 'PP' end As TypDokumentu,
DkB_DataDok As DataDok,
DkB_Opis As Opis
FROM cdn.CRMDokumenty
JOIN  cdn.DokumentyKBView on CrD_DokumentId = Dkb_DkbId
WHERE ( Dkb_TypDokumentuKB=2 or CrD_TypDokumentu<>1000) AND --Dok ZKB
      ( Dkb_TypDokumentuKB=1 or CrD_TypDokumentu<>1001) AND --Dok PP
    CrD_TypDokumentu in (1000, 1001)
AND CrD_CrDId = @CrDId
UNION ALL
SELECT EDN_NumerPelny As NumerPelny,
'EDK' As TypDokumentu,
EdN_DataDok As DataDok,
'' As Opis
FROM cdn.CRMDokumenty
JOIN cdn.EwidDodNag on CrD_DokumentID = EDN_EDNID
WHERE CrD_TypDokumentu = 101
AND CrD_CrDId = @CrDId
UNION ALL
SELECT SrZ_NumerPelny As NumerPelny, 'SRW' As TypDokumentu,
SrZ_DataDok As DataDok,
SrZ_Opis As Opis
FROM cdn.CRMDokumenty
JOIN cdn.SrsZlecenia on CrD_DokumentID = SrZ_SrZId
WHERE CrD_TypDokumentu = 900
AND CrD_CrDId = @CrDId
UNION ALL
SELECT TOP 1
 KDN_NumerPelny As NumerPelny,
 CASE KDN_Typ WHEN 111 THEN 'PS-KH' WHEN 113 THEN 'NO-KH' ELSE '' END As TypDokumentu,
 KDN_DataDok As DataDok,
 CONVERT(NVARCHAR(50), KDN_Opis, 120) As Opis
FROM cdn.CRMDokumenty
JOIN cdn.KsiDokNag ON CrD_DokumentID = KDN_KDNId
WHERE CrD_TypDokumentu IN (111,113)
AND CrD_CrDId = @CrDId
UNION ALL
SELECT BDN_NumerPelny As NumerPelny,
case BDN_Typ when 222 then 'PON' when 223 then 'NO' else '' end As TypDokumentu,
BdN_DataDok As DataDok,
BdN_Uwagi As Opis
FROM cdn.CRMDokumenty
JOIN cdn.BnkDokNag on CrD_DokumentID = BDN_BDNId WHERE
CrD_TypDokumentu IN (222, 223, 1002)
AND ( (BDN_Typ = 222) OR --PO
 (  BDN_Typ = 223))  --NO
AND CrD_CrDId = @CrDId
UNION ALL
SELECT TOP 1
 NON_NumerPelny As NumerPelny,
 'NO-KB' As TypDokumentu,
 NON_DataDok As DataDok,
 CONVERT(NVARCHAR(50), NON_Uwagi, 120) As Opis
FROM cdn.CRMDokumenty
JOIN cdn.NotyOdsNag ON CrD_DokumentID = NON_NONId
WHERE CrD_TypDokumentu = 221
AND CrD_CrDId = @CrDId
-- Sekretariat
UNION ALL
SELECT DoN_NumerPelny As NumerPelny, 'OBD' As TrN_TypDokumentu, DoN_DataDok As DataDok,
DoN_Tytul As Opis
FROM cdn.DokNag
JOIN cdn.CRMDokumenty on CrD_DokumentID = DoN_DoNId
WHERE CrD_TypDokumentu = 750 AND CrD_CrDId = @CrDId
END
