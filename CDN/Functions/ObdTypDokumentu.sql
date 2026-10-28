CREATE FUNCTION CDN.ObdTypDokumentu(@typDok INT, @dokId INT)
RETURNS     NVARCHAR(20)
  AS
BEGIN
  DECLARE @typ NVARCHAR(20)
  IF @typDok = 101 RETURN 'EDK'
  IF @typDok = 114 RETURN 'Delegacja'
  IF @typDok >= 300 AND @typDok < 500 RETURN CDN.TypDokumentu(@typDok)
  IF @typDok = 500 RETURN 'BO'
  IF @typDok = 700 RETURN 'CRM'
  IF @typDok = 750 RETURN 'OBD'
  IF @typDok = 751 RETURN 'OBD'
  IF @typDok = 752 RETURN 'wydruk'
  IF @typDok = 900 RETURN 'SRW'
  IF @typDok = 999 RETURN 'VAT'
  IF @typDok = 1003 RETURN 'EwD'
  IF @typDok = 1006 RETURN 'PK'
  IF @typDok = 1008 RETURN 'KPiR'
  IF @typDok = 1009 RETURN 'RYCZ'
  IF @typDok = 1020 RETURN 'SMS'
  IF @typDok = 1038 RETURN 'PrzeszWal'
  IF @typDok = 1100 RETURN 'FormaPlat'
  IF @typDok = 1101 RETURN 'KartaKr'
  IF @typDok = 1102 RETURN 'Bank'
  IF @typDok = 1103 RETURN 'Kontrahent'
  IF @typDok = 1105 RETURN 'Urząd'
  IF @typDok = 1120 RETURN 'RejestrKB'
  IF @typDok = 1122 RETURN 'RaportKB'
  IF @typDok = 1000 OR @typDok = 1001
  BEGIN
   SELECT TOP 1 @typ = case DKB_TypDokumentuKB
      when 1 then 'PP'
        when 2 then case DKB_Kierunek when -1 then 'ZKB-KW' else 'ZKB-KP' end
        end
      FROM cdn.DokumentyKBView
      WHERE ( Dkb_TypDokumentuKB=2 or @typDok<>1000) AND --Dok ZKB
         ( Dkb_TypDokumentuKB=1 or @typDok<>1001) AND --Dok PP
           Dkb_DkbId = @dokId
 IF @typ Is NULL SET @typ = ''
 RETURN @typ
  END
  --IF @typDok = 1002
  --BEGIN
  -- SELECT TOP 1 @typ = case BDN_Typ when 222 then 'PON' when 223 then 'NO' else '' end
--      FROM cdn.BnkDokNag WHERE BDN_BDNId  = @dokId
--      AND  ( (BDN_Typ = 222) or --PO
  --         (BDN_Typ = 223)   )  --NO
-- IF @typ Is NULL SET @typ = ''
-- RETURN @typ
--  END
  IF @typDok = 1130 RETURN 'NotaOdsKB'
  IF @typDok = 1131 RETURN 'NOElemKB'
  IF @typDok = 1002 RETURN 'PonKB'
  IF @typDok = 1133 RETURN 'PonElemKB'
  IF @typDok = 1134 RETURN 'PSaldaKB'
  IF @typDok = 1135 RETURN 'PSElemKB'
  IF @typDok = 1140 RETURN 'BOMW'
  IF @typDok = 1141 RETURN 'RozlMW'
  IF @typDok = 1142 RETURN 'RKurMW'
  IF @typDok = 1150 RETURN 'FormatKB'
  IF @typDok = 1151 RETURN 'ForElemKB'
  IF @typDok = 1200 RETURN 'KŚT'
  IF @typDok = 1004 RETURN 'ŚrT'
  IF @typDok = 1005 RETURN 'Wyp'
  IF @typDok = 1007 RETURN 'DŚrT'
  IF @typDok = 1221 RETURN 'PŚrT'
  IF @typDok = 1222 RETURN 'PWyp'
  IF @typDok = 1230 RETURN 'AtrŚrT'
  IF @typDok = 1240 RETURN 'Przejazd'
  IF @typDok = 1241 RETURN 'KosztPrzej'
  IF @typDok = 1242 RETURN 'RozlSam'
  IF @typDok = 1243 RETURN 'Samochód'
  IF @typDok = 1244 RETURN 'Trasa'
  -- deklaracje
  RETURN
 CASE @typDok
  WHEN 30001 THEN 'VAT-7'
  WHEN 30002 THEN 'Zal.PIT-36'
  WHEN 30003 THEN 'PIT-4'
  WHEN 30004 THEN 'ZNPR'
  WHEN 30005 THEN 'PIT-11'
  WHEN 30006 THEN 'PIT-8A'
  WHEN 30007 THEN 'PIT-8B'
  WHEN 30008 THEN 'Zal.CIT-8'
  WHEN 30009 THEN 'PIT-40'
  WHEN 30010 THEN 'IFT-1'
  WHEN 30011 THEN 'VAT-UE'
  WHEN 30012 THEN 'Zal.PIT-36L'
  WHEN 30013 THEN 'VAT-UE/A'
  WHEN 30014 THEN 'VAT-UE/B'
  WHEN 30015 THEN 'PIT-36'
  WHEN 30016 THEN 'PIT-36L'
  WHEN 30017 THEN 'CIT-8'
  WHEN 30018 THEN 'PIT-4R'
  WHEN 30019 THEN 'PIT-8AR'
  WHEN 30020 THEN 'PIT-28'
  WHEN 30021 THEN 'PIT-8C'
  WHEN 30022 THEN 'Kor.VAT-UE'
  WHEN 30023 THEN 'VAT-UE/C'
  WHEN 30024 THEN 'IFT-1R'
  WHEN 30100 THEN 'ZUS-ZUA'
  WHEN 30101 THEN 'ZUS-ZIUA'
  WHEN 30102 THEN 'ZUS-ZCNA'
  WHEN 30103 THEN 'ZUS-ZCZA'
  WHEN 30104 THEN 'ZUS-ZWUA'
  WHEN 30105 THEN 'ZUS-ZZA'
  WHEN 30106 THEN 'ZUS-ZSWA'
  WHEN 30110 THEN 'ZUS-ZPA'
  WHEN 30111 THEN 'ZUS-ZFA'
  WHEN 30112 THEN 'ZUS-ZIPA'
  WHEN 30113 THEN 'ZUS-ZWPA'
  WHEN 30114 THEN 'ZUS-ZBA'
  WHEN 30115 THEN 'ZUS-ZAA'
  WHEN 30120 THEN 'ZUS-DRA'
        WHEN 30121 THEN 'ZUS-RCA'
        WHEN 30122 THEN 'ZUS-RNA'
        WHEN 30123 THEN 'ZUS-RZA'
        WHEN 30124 THEN 'ZUS-RSA'
        WHEN 30125 THEN 'ZUS-RGA'
        WHEN 30130 THEN 'ZUS-IWA'
        WHEN 30300 THEN 'PFRON-INFD'
        WHEN 30301 THEN 'PFRON-INFDP'
        WHEN 30302 THEN 'PFRON-INFDZ'
        WHEN 30310 THEN 'PFRON-WND'
        WHEN 30311 THEN 'PFRON-INFDP2'
        WHEN 30320 THEN 'PFRON-WNU'
        WHEN 30321 THEN 'PFRON-INFUP'
        ELSE ''
 END
END
