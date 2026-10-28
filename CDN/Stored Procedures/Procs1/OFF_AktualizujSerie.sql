CREATE  PROCEDURE CDN.OFF_AktualizujSerie
    @TypChar    nvarchar(30),
    @Seria      nvarchar(30),
    @Domyslna   nvarchar(3),
    @FormatNumeracji nvarchar(30)
AS
  SET NOCOUNT ON
  DECLARE
    @Typ           INT,
    @TypDokumentu  INT,
    @DDF_Numeracja nvarchar(50),
    @Komunikat     nvarchar(255),
    @SymbolOld     nvarchar(30),
    @SymbolNew     nvarchar(30),
    @Gru_Opis      nvarchar(50),
    @DDF_DDFId     INT
  SELECT
    @Typ        = CONVERT(INT, @TypChar),
    @Gru_Opis   = 'Z Centrali'
  --nie może być serii pustej
  IF @Seria='' RETURN
  IF @Domyslna = ''
  BEGIN
    -- FA
    IF @Typ = 2033
   BEGIN
     SELECT
    @TypDokumentu  = 302,
    @DDF_Numeracja = '@brak/FS/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'FS',
    @SymbolNew     = 'FS'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1270, @Seria, 'Domyślna seria - faktury sprzedaży'
     EXEC CDN.OFF_AktualizujFirma 1272, @Seria, 'Domyślna seria - faktury sprzedazy - korekty'
     EXEC CDN.OFF_AktualizujFirma 1281, @Seria, 'Domyślna seria - faktury z paragonów'
     EXEC CDN.OFF_AktualizujFirma 1283, @Seria, 'Domyślna seria - faktury z paragonów - korekty'
     EXEC CDN.OFF_AktualizujFirma 1292, @Seria, 'Domyślna seria - faktury sprzedaży z wydań zewnętrznych'
     EXEC CDN.OFF_AktualizujFirma 1294, @Seria, 'Domyślna seria - faktury sprzedaży z wydań zewnętrznych - korekty'
     EXEC CDN.OFF_AktualizujFirma 1296, @Seria, 'Domyślna seria - faktury sprzedaży z rezerwcji odbiorcy'
     EXEC CDN.OFF_AktualizujFirma 1298, @Seria, 'Domyślna seria - faktury sprzedaży z rezerwcji odbiorcy - korekty'
     EXEC CDN.OFF_AktualizujFirma 1568, @Seria, 'Domyślna seria - faktura sprzedaży z PF'
     EXEC CDN.OFF_AktualizujFirma 1544, @Seria, 'Domyślna seria - faktura pro-forma'
  --      EXEC CDN.sp_OFF_AktualizujFirma 1420, @Seria, 'Domyślna seria - bilans zamknięcia magazynu'
     --EXEC CDN.sp_OFF_AktualizujFirma 1322, @Seria, 'Domyślna seria - wydania zewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1326, @Seria, 'Domyślna seria - wydania zewnętrzne powstałe z faktur sprzedaży'
     EXEC CDN.OFF_AktualizujFirma 1487, @Seria, 'Domyślna seria - wydania zewnętrzne powstałe z faktur sprzedaży'
     --EXEC CDN.sp_OFF_AktualizujFirma 1330, @Seria, 'Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty'
     EXEC CDN.OFF_AktualizujFirma 1412, @Seria, 'Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty kosztu'
     EXEC CDN.OFF_AktualizujFirma 1695, @Seria, 'Domyślna seria - faktura sprzedaży z WKA'
     EXEC CDN.OFF_AktualizujFirma 1737, @Seria, 'Domyślna seria - faktura sprzedaży z WKA - korekta'
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1269, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1271, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1282, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1280, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1291, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1295, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1297, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1293, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1567, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1694, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1736, @DDF_DDFId, ''
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
  -- WZ
    ELSE IF @Typ = 2001
   BEGIN
     SELECT
    @TypDokumentu  = 306,
    @DDF_Numeracja = '@brak/WZ/@numer/@rok_kal/@rejestr',
    @SymbolOld     = ' WZ',
    @SymbolNew     = ' WZ'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1322, @Seria, 'Domyślna seria - wydania zewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1330, @Seria, 'Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty'
     IF NOT EXISTS(SELECT DDF_Numeracja FROM Cdn.DokDefinicje WHERE DDF_Numeracja  = @DDF_Numeracja and DDF_Symbol=@SymbolNew)
     BEGIN
     INSERT INTO [CDN].[DokDefinicje]( [DDf_Klasa], [DDf_Symbol], [DDf_Nazwa], [DDf_Numeracja], [DDf_SeriaOperatora], [DDf_TS_Export],  [DDf_ImportRowId], [DDf_OpeZalID], [DDf_StaZalId], [DDf_TS_Zal], [DDf_OpeModID], [DDf_StaModId], [DDf_TS_Mod])
     VALUES( @TypDokumentu, @SymbolNew, 'Wydanie zewnętrzne', @DDF_Numeracja,  0, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, GETDATE())
     END
     SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1321, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1780, @DDF_DDFId, ''
     --EXEC CDN.OFF_AktualizujFirma 1329, @DDF_DDFId, ''
    END
    -- WKA
    ELSE IF @Typ = 2000
   BEGIN
     SELECT
    @TypDokumentu  = 314,
    @DDF_Numeracja = '@brak/WKA/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'WKA',
    @SymbolNew     = 'WKA'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1701, @Seria, 'Domyślny typ - wydanie opakowań/kaucji'
     EXEC CDN.OFF_AktualizujFirma 1704, @Seria, 'Domyślny typ - wydanie opakowań/kaucji korekta'
     EXEC CDN.OFF_AktualizujFirma 1707, @Seria, 'Domyślny typ - wydanie kaucji do FA'
     EXEC CDN.OFF_AktualizujFirma 1710, @Seria, 'Domyślny typ - wydanie kaucji do PA'
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1700, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1703, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1706, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1709, @DDF_DDFId, ''
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
    -- PKA
    ELSE IF @Typ = 2002
   BEGIN
     SELECT
    @TypDokumentu  = 313,
    @DDF_Numeracja = '@brak/PKA/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'PKA',
    @SymbolNew     = 'PKA'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1713, @Seria, 'Domyślny typ - przyjęcie kaucji'
     EXEC CDN.OFF_AktualizujFirma 1716, @Seria, 'Domyślny typ - przyjęcie opakowań/kaucji korekta'
     EXEC CDN.OFF_AktualizujFirma 1719, @Seria, 'Domyślny typ - przyjęcie kaucji do FZ'
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1712, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1715, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1718, @DDF_DDFId, ''
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
    -- PA
    ELSE IF @Typ = 2034
   BEGIN
     SELECT
    @TypDokumentu  = 305,
    @DDF_Numeracja = '@brak/PA/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'PA',
    @SymbolNew     = 'PA'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1274, @Seria, 'Domyślna seria - paragony'
     EXEC CDN.OFF_AktualizujFirma 1279, @Seria, 'Domyślna seria - paragony - korekty'
     EXEC CDN.OFF_AktualizujFirma 1302, @Seria, 'Domyślna seria - paragony z rezerwcji odbiorcy'
     EXEC CDN.OFF_AktualizujFirma 1304, @Seria, 'Domyślna seria - paragony z rezerwcji odbiorcy - korekty'
     EXEC CDN.OFF_AktualizujFirma 1306, @Seria, 'Domyślna seria - wydania zewnętrzne z paragonów'
     EXEC CDN.OFF_AktualizujFirma 1308, @Seria, 'Domyślna seria - wydania zewnętrzne z paragonów - korekty'
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1273, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1278, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1301, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1305, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1303, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1307, @DDF_DDFId, ''
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
    -- RO i ZD
    ELSE IF @Typ = 9473
   BEGIN
     -- RO / ZZ
     SELECT
    @TypDokumentu  = 308,
    @DDF_Numeracja = '@brak/ZS/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'ZS',
    @SymbolNew     = 'ZS'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1309, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1570, @DDF_DDFId, ''
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
    ELSE IF @Typ = 9472
   BEGIN
     -- ZD / ZW
     SELECT
    @TypDokumentu  = 309,
    @DDF_Numeracja = '@brak/ZW/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'ZW',
    @SymbolNew     = 'ZW'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1310, @Seria, 'Domyślna seria - rezerwacje odbiorców'
     EXEC CDN.OFF_AktualizujFirma 1571, @Seria, 'Domyślna seria - rezerwacja odbiorcy z PF'
     EXEC CDN.OFF_AktualizujFirma 1320, @Seria, 'Domyślna seria - zamówienia u dostawców'
     EXEC CDN.OFF_AktualizujFirma 1437, @Seria, 'Domyślna seria - przyjęcie zewnętrzne z ZD'
     EXEC CDN.OFF_AktualizujFirma 1547, @Seria, 'Domyślna seria - wydanie zewnętrzne z RO'
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1319, @DDF_DDFId, ''
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
    -- FZ
    ELSE IF @Typ = 1521
   BEGIN
     SELECT
    @TypDokumentu  = 301,
    @DDF_Numeracja = '@brak/FZ/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'FZ',
    @SymbolNew     = 'FZ'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1285, @Seria, 'Domyślna seria - faktury zakupu'
     EXEC CDN.OFF_AktualizujFirma 1287, @Seria, 'Domyślna seria - faktury zakupu - korekty'
     EXEC CDN.OFF_AktualizujFirma 1312, @Seria, 'Domyślna seria - faktury zakupu z przyjęć zewnętrznych'
     EXEC CDN.OFF_AktualizujFirma 1314, @Seria, 'Domyślna seria - faktury zakupu z przyjęć zewnętrznych - korekty'
     EXEC CDN.OFF_AktualizujFirma 1316, @Seria, 'Domyślna seria - faktury zakupu z zamówień od dostawców'
     EXEC CDN.OFF_AktualizujFirma 1448, @Seria, 'Domyślna seria - nota korygująca do faktury zakupu'
     EXEC CDN.OFF_AktualizujFirma 1511, @Seria, 'Domyślna seria - korekta graniczna do faktury zakupu'
     --EXEC CDN.OFF_AktualizujFirma 1332, @Seria, 'Domyślna seria - przyjęcia zewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1334, @Seria, 'Domyślna seria - przyjęcia zewnętrzne z faktur zakupu'
     --EXEC CDN.OFF_AktualizujFirma 1338, @Seria, 'Domyślna seria - przyjęcia zewnętrzne - korekty'
     EXEC CDN.OFF_AktualizujFirma 1698, @Seria, 'Domyślna seria - faktura zakupu z PKA'
     EXEC CDN.OFF_AktualizujFirma 1739, @Seria, 'Domyślna seria - faktura zakupu z PKA - korekta'
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1284, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1286, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1311, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1313, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1315, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1447, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1510, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1317, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1697, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1738, @DDF_DDFId, ''
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
   -- PZ
    ELSE IF @Typ = 1489
   BEGIN
     SELECT
    @TypDokumentu  = 307,
    @DDF_Numeracja = '@brak/PZ/@numer/@rok_kal/@rejestr',
    @SymbolOld     = ' PZ',
    @SymbolNew     = ' PZ'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1332, @Seria, 'Domyślna seria - przyjęcia zewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1338, @Seria, 'Domyślna seria - przyjęcia zewnętrzne - korekty'
     IF NOT EXISTS(SELECT DDF_Numeracja FROM Cdn.DokDefinicje WHERE DDF_Numeracja  = @DDF_Numeracja and DDF_Symbol=@SymbolNew)
     BEGIN
     INSERT INTO [CDN].[DokDefinicje]( [DDf_Klasa], [DDf_Symbol], [DDf_Nazwa], [DDf_Numeracja], [DDf_SeriaOperatora], [DDf_TS_Export],  [DDf_ImportRowId], [DDf_OpeZalID], [DDf_StaZalId], [DDf_TS_Zal], [DDf_OpeModID], [DDf_StaModId], [DDf_TS_Mod])
     VALUES( @TypDokumentu, @SymbolNew, 'Przyjęcie zewnętrzne', @DDF_Numeracja,  0, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, GETDATE())
     END
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1331, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1779, @DDF_DDFId, ''
     --EXEC CDN.OFF_AktualizujFirma 1337, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
    ELSE IF @Typ = 5
   BEGIN
     SET @Komunikat = '##OPT34484##'--'Brak odpowiednika typu dokumentu '
     RAISERROR( @Komunikat, 16, 1)
     RETURN
   END
   -- PW
    ELSE IF @Typ = 1617
   BEGIN
     SELECT
    @TypDokumentu  = 303,
    @DDF_Numeracja = '@brak/PW/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'PW',
    @SymbolNew     = 'PW'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1340, @Seria, 'Domyślna seria - przychody wewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1342, @Seria, 'Domyślna seria - przychody wewnętrzne - korekty'
     EXEC CDN.OFF_AktualizujFirma 1423, @Seria, 'Domyślna seria - przychody wewnętrzne z AI'
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1339, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1341, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1422, @DDF_DDFId, ''
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
    -- RW
    ELSE IF @Typ = 1616
   BEGIN
     SELECT
    @TypDokumentu  = 304,
    @DDF_Numeracja = '@brak/RW/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'RW',
    @SymbolNew     = 'RW'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1344, @Seria, 'Domyślna seria - rozchody wewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1346, @Seria, 'Domyślna seria - rozchody wewnętrzne korekty'
     EXEC CDN.OFF_AktualizujFirma 1426, @Seria, 'Domyślna seria - rozchody wewnętrzne z AI'
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1343, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1345, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1425, @DDF_DDFId, ''
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
    -- AI
    ELSE IF @Typ = 1536
   BEGIN
     SELECT
    @TypDokumentu  = 311,
    @DDF_Numeracja = '@brak/AI/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'AI',
    @SymbolNew     = 'AI'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1429, @Seria,'Domyślna seria - arkusz inwentaryzacyjny'
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
   END
    -- MM
    ELSE IF @Typ = 1600 or  @Typ = 1603 or @Typ = 1604
   BEGIN
     SELECT
    @TypDokumentu  = 312,
    @DDF_Numeracja = '@brak/MM/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'MM',
    @SymbolNew     = 'MM'
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1348, @Seria, 'Domyślna seria - przesunięcia międzymagazynowe'
     UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
     IF NOT EXISTS (Select * From Cdn.DokDefinicje Where DDF_Klasa = 999)
      Insert Into Cdn.DokDefinicje(DDF_Klasa,DDF_Symbol,DDF_Nazwa,DDF_numeracja,DDF_seriaoperatora,DDF_TS_Mod,DDF_TS_Zal)
      Values(999,'MMOL','MM odległa','@brak/MM/@numer/@rok_kal/@brak',0,Getdate(),Getdate())
   END
    ELSE
   BEGIN
     SET @Komunikat = @Typ
     RAISERROR( @Komunikat, 16, 1)
     RETURN
   END
   END
   ELSE
   BEGIN
  -- FA
    IF @Typ = 2033
   BEGIN
     SELECT
    @TypDokumentu  = 302,
    @SymbolOld     = 'FS',
    @SymbolNew     = 'FS',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
             if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/FS/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'FS_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Faktura sprzedaży',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
              update cdn.detalstanowiska set dsta_DDfIdFS = @DDF_DDFId
      EXEC CDN.OFF_AktualizujFirma 1270, @Seria, 'Domyślna seria - faktury sprzedaży'
      EXEC CDN.OFF_AktualizujFirma 1272, @Seria, 'Domyślna seria - faktury sprzedazy - korekty'
      EXEC CDN.OFF_AktualizujFirma 1281, @Seria, 'Domyślna seria - faktury z paragonów'
      EXEC CDN.OFF_AktualizujFirma 1283, @Seria, 'Domyślna seria - faktury z paragonów - korekty'
      EXEC CDN.OFF_AktualizujFirma 1292, @Seria, 'Domyślna seria - faktury sprzedaży z wydań zewnętrznych'
      EXEC CDN.OFF_AktualizujFirma 1294, @Seria, 'Domyślna seria - faktury sprzedaży z wydań zewnętrznych - korekty'
      EXEC CDN.OFF_AktualizujFirma 1296, @Seria, 'Domyślna seria - faktury sprzedaży z rezerwcji odbiorcy'
      EXEC CDN.OFF_AktualizujFirma 1298, @Seria, 'Domyślna seria - faktury sprzedaży z rezerwcji odbiorcy - korekty'
      EXEC CDN.OFF_AktualizujFirma 1568, @Seria, 'Domyślna seria - faktura sprzedaży z PF'
      EXEC CDN.OFF_AktualizujFirma 1544, @Seria, 'Domyślna seria - faktura pro-forma'
   --      EXEC CDN.OFF_AktualizujFirma 1420, @Seria, 'Domyślna seria - bilans zamknięcia magazynu'
      --EXEC CDN.OFF_AktualizujFirma 1322, @Seria, 'Domyślna seria - wydania zewnętrzne'
      EXEC CDN.OFF_AktualizujFirma 1326, @Seria, 'Domyślna seria - wydania zewnętrzne powstałe z faktur sprzedaży'
      EXEC CDN.OFF_AktualizujFirma 1487, @Seria, 'Domyślna seria - wydania zewnętrzne powstałe z faktur sprzedaży'
      --EXEC CDN.OFF_AktualizujFirma 1330, @Seria, 'Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty'
      EXEC CDN.OFF_AktualizujFirma 1412, @Seria, 'Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty kosztu'
      EXEC CDN.OFF_AktualizujFirma 1695, @Seria, 'Domyślna seria - faktura sprzedaży z WKA'
      EXEC CDN.OFF_AktualizujFirma 1737, @Seria, 'Domyślna seria - faktura sprzedaży z WKA - korekta'
      EXEC CDN.OFF_AktualizujFirma 1269, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1271, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1282, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1280, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1291, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1295, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1297, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1293, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1567, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1694, @DDF_DDFId, ''
      EXEC CDN.OFF_AktualizujFirma 1736, @DDF_DDFId, ''
    end
   END
  -- WZ
    ELSE IF @Typ = 2001
   BEGIN
     SELECT
    @TypDokumentu  = 306,
    --@DDF_Numeracja = '@brak/WZ/@numer/@rok_kal/@rejestr',
    @SymbolOld     = ' WZ',
    @SymbolNew     = ' WZ',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,'WZ' ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/WZ/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = ' WZ_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Wydanie zewnętrzne',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     INSERT INTO [CDN].[DokDefinicje]( [DDf_Klasa], [DDf_Symbol], [DDf_Nazwa], [DDf_Numeracja], [DDf_SeriaOperatora], [DDf_TS_Export],  [DDf_ImportRowId], [DDf_OpeZalID], [DDf_StaZalId], [DDf_TS_Zal], [DDf_OpeModID], [DDf_StaModId], [DDf_TS_Mod])
     VALUES( @TypDokumentu, @SymbolNew, 'Wydanie zewnętrzne', @DDF_Numeracja,  0, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, GETDATE())
                    --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     EXEC CDN.OFF_AktualizujFirma 1322, @Seria, 'Domyślna seria - wydania zewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1330, @Seria, 'Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty'
     --IF NOT EXISTS(SELECT DDF_Numeracja FROM Cdn.DokDefinicje WHERE DDF_Numeracja  = @DDF_Numeracja and DDF_Symbol=@SymbolNew)
     --BEGIN
     -- INSERT INTO [CDN].[DokDefinicje]( [DDf_Klasa], [DDf_Symbol], [DDf_Nazwa], [DDf_Numeracja], [DDf_SeriaOperatora], [DDf_TS_Export],  [DDf_ImportRowId], [DDf_OpeZalID], [DDf_StaZalId], [DDf_TS_Zal], [DDf_OpeModID], [DDf_StaModId], [DDf_TS_Mod])
     --  VALUES( @TypDokumentu, @SymbolNew, 'Wydanie zewnętrzne', @DDF_Numeracja,  0, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, GETDATE())
     --END
     --SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1321, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1780, @DDF_DDFId, ''
     --EXEC CDN.OFF_AktualizujFirma 1329, @DDF_DDFId, ''
              end
    END
    -- WKA
    ELSE IF @Typ = 2000
   BEGIN
     SELECT
    @TypDokumentu  = 314,
    --@DDF_Numeracja = '@brak/WKA/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'WKA',
    @SymbolNew     = 'WKA',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/WKA/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'WKA_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Wydanie kaucji',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     EXEC CDN.OFF_AktualizujFirma 1701, @Seria, 'Domyślny typ - wydanie opakowań/kaucji'
     EXEC CDN.OFF_AktualizujFirma 1704, @Seria, 'Domyślny typ - wydanie opakowań/kaucji korekta'
     EXEC CDN.OFF_AktualizujFirma 1707, @Seria, 'Domyślny typ - wydanie kaucji do FA'
     EXEC CDN.OFF_AktualizujFirma 1710, @Seria, 'Domyślny typ - wydanie kaucji do PA'
     EXEC CDN.OFF_AktualizujFirma 1700, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1703, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1706, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1709, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
              end
   END
    -- PKA
    ELSE IF @Typ = 2002
   BEGIN
     SELECT
    @TypDokumentu  = 313,
    --@DDF_Numeracja = '@brak/PKA/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'PKA',
    @SymbolNew     = 'PKA',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/PKA/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'PKA_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Przyjęcie kaucji',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     --EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1713, @Seria, 'Domyślny typ - przyjęcie kaucji'
     EXEC CDN.OFF_AktualizujFirma 1716, @Seria, 'Domyślny typ - przyjęcie opakowań/kaucji korekta'
     EXEC CDN.OFF_AktualizujFirma 1719, @Seria, 'Domyślny typ - przyjęcie kaucji do FZ'
     --UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1712, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1715, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1718, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
             end
   END
    -- PA
    ELSE IF @Typ = 2034
   BEGIN
     SELECT
    @TypDokumentu  = 305,
    --@DDF_Numeracja = '@brak/PA/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'PA',
    @SymbolNew     = 'PA',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/PA/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'PA_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Paragon',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
    update cdn.detalstanowiska set dsta_DDfIdPA = @DDF_DDFId
     --EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1274, @Seria, 'Domyślna seria - paragony'
     EXEC CDN.OFF_AktualizujFirma 1279, @Seria, 'Domyślna seria - paragony - korekty'
     EXEC CDN.OFF_AktualizujFirma 1302, @Seria, 'Domyślna seria - paragony z rezerwcji odbiorcy'
     EXEC CDN.OFF_AktualizujFirma 1304, @Seria, 'Domyślna seria - paragony z rezerwcji odbiorcy - korekty'
     EXEC CDN.OFF_AktualizujFirma 1306, @Seria, 'Domyślna seria - wydania zewnętrzne z paragonów'
     EXEC CDN.OFF_AktualizujFirma 1308, @Seria, 'Domyślna seria - wydania zewnętrzne z paragonów - korekty'
     --UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1273, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1278, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1301, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1305, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1303, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1307, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
             end
   END
    -- RO i ZD
    ELSE IF @Typ = 9473
   BEGIN
     -- RO / ZZ
     SELECT
    @TypDokumentu  = 308,
    --@DDF_Numeracja = '@brak/ZS/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'ZS',
    @SymbolNew     = 'ZS',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/ZS/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'ZS_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Rezerwacja odbiorcy',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     --EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     --UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1310, @Seria, 'Domyślna seria - rezerwacje odbiorców'
     EXEC CDN.OFF_AktualizujFirma 1571, @Seria, 'Domyślna seria - rezerwacja odbiorcy z PF'
     EXEC CDN.OFF_AktualizujFirma 1309, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1570, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
              end
   END
    ELSE IF @Typ = 9472
   BEGIN
     -- ZD / ZW
     SELECT
    @TypDokumentu  = 309,
    --@DDF_Numeracja = '@brak/ZW/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'ZW',
    @SymbolNew     = 'ZW',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/ZW/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'ZW_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Zamówienie u dost.',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     --EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1320, @Seria, 'Domyślna seria - zamówienia u dostawców'
     EXEC CDN.OFF_AktualizujFirma 1437, @Seria, 'Domyślna seria - przyjęcie zewnętrzne z ZD'
     EXEC CDN.OFF_AktualizujFirma 1547, @Seria, 'Domyślna seria - wydanie zewnętrzne z RO'
     --UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1319, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
             end
   END
    -- FZ
    ELSE IF @Typ = 1521
   BEGIN
     SELECT
    @TypDokumentu  = 301,
    --@DDF_Numeracja = '@brak/FZ/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'FZ',
    @SymbolNew     = 'FZ',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/FZ/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'FZ_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Faktura zakupu',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     --EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1285, @Seria, 'Domyślna seria - faktury zakupu'
     EXEC CDN.OFF_AktualizujFirma 1287, @Seria, 'Domyślna seria - faktury zakupu - korekty'
     EXEC CDN.OFF_AktualizujFirma 1312, @Seria, 'Domyślna seria - faktury zakupu z przyjęć zewnętrznych'
     EXEC CDN.OFF_AktualizujFirma 1314, @Seria, 'Domyślna seria - faktury zakupu z przyjęć zewnętrznych - korekty'
     EXEC CDN.OFF_AktualizujFirma 1316, @Seria, 'Domyślna seria - faktury zakupu z zamówień od dostawców'
     EXEC CDN.OFF_AktualizujFirma 1448, @Seria, 'Domyślna seria - nota korygująca do faktury zakupu'
     EXEC CDN.OFF_AktualizujFirma 1511, @Seria, 'Domyślna seria - korekta graniczna do faktury zakupu'
     --EXEC CDN.OFF_AktualizujFirma 1332, @Seria, 'Domyślna seria - przyjęcia zewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1334, @Seria, 'Domyślna seria - przyjęcia zewnętrzne z faktur zakupu'
     --EXEC CDN.OFF_AktualizujFirma 1338, @Seria, 'Domyślna seria - przyjęcia zewnętrzne - korekty'
     EXEC CDN.OFF_AktualizujFirma 1698, @Seria, 'Domyślna seria - faktura zakupu z PKA'
     EXEC CDN.OFF_AktualizujFirma 1739, @Seria, 'Domyślna seria - faktura zakupu z PKA - korekta'
     --UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1284, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1286, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1311, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1313, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1315, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1447, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1510, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1317, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1697, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1738, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
             end
   END
   -- PZ
    ELSE IF @Typ = 1489
   BEGIN
     SELECT
    @TypDokumentu  = 307,
    --@DDF_Numeracja = '@brak/PZ/@numer/@rok_kal/@rejestr',
    @SymbolOld     = ' PZ',
    @SymbolNew     = ' PZ',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,'PZ' ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/PZ/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = ' PZ_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Przyjęcie zewnętrzne',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     INSERT INTO [CDN].[DokDefinicje]( [DDf_Klasa], [DDf_Symbol], [DDf_Nazwa], [DDf_Numeracja], [DDf_SeriaOperatora], [DDf_TS_Export],  [DDf_ImportRowId], [DDf_OpeZalID], [DDf_StaZalId], [DDf_TS_Zal], [DDf_OpeModID], [DDf_StaModId], [DDf_TS_Mod])
     VALUES( @TypDokumentu, @SymbolNew, 'Przyjęcie zewnętrzne', @DDF_Numeracja,  0, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, GETDATE())
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     --EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1332, @Seria, 'Domyślna seria - przyjęcia zewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1338, @Seria, 'Domyślna seria - przyjęcia zewnętrzne - korekty'
     --IF NOT EXISTS(SELECT DDF_Numeracja FROM Cdn.DokDefinicje WHERE DDF_Numeracja  = @DDF_Numeracja and DDF_Symbol=@SymbolNew)
     --BEGIN
    -- INSERT INTO [CDN].[DokDefinicje]( [DDf_Klasa], [DDf_Symbol], [DDf_Nazwa], [DDf_Numeracja], [DDf_SeriaOperatora], [DDf_TS_Export],  [DDf_ImportRowId], [DDf_OpeZalID], [DDf_StaZalId], [DDf_TS_Zal], [DDf_OpeModID], [DDf_StaModId], [DDf_TS_Mod])
    -- VALUES( @TypDokumentu, @SymbolNew, 'Przyjęcie zewnętrzne', @DDF_Numeracja,  0, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, GETDATE())
     --END
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1331, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1779, @DDF_DDFId, ''
     --EXEC CDN.OFF_AktualizujFirma 1337, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
             end
   END
    ELSE IF @Typ = 5
   BEGIN
     SET @Komunikat = '##OPT34484##'--'Brak odpowiednika typu dokumentu '
     RAISERROR( @Komunikat, 16, 1)
     RETURN
   END
   -- PW
    ELSE IF @Typ = 1617
   BEGIN
     SELECT
    @TypDokumentu  = 303,
    --@DDF_Numeracja = '@brak/PW/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'PW',
    @SymbolNew     = 'PW',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
      EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/PW/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'PW_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Przyjęcie wewnętrzne',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     --EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1340, @Seria, 'Domyślna seria - przychody wewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1342, @Seria, 'Domyślna seria - przychody wewnętrzne - korekty'
     EXEC CDN.OFF_AktualizujFirma 1423, @Seria, 'Domyślna seria - przychody wewnętrzne z AI'
     --UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1339, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1341, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1422, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
             end
   END
    -- RW
    ELSE IF @Typ = 1616
   BEGIN
     SELECT
    @TypDokumentu  = 304,
    --@DDF_Numeracja = '@brak/RW/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'RW',
    @SymbolNew     = 'RW',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/RW/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'RW_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Rozchód wewnętrzny',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     --EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1344, @Seria, 'Domyślna seria - rozchody wewnętrzne'
     EXEC CDN.OFF_AktualizujFirma 1346, @Seria, 'Domyślna seria - rozchody wewnętrzne korekty'
     EXEC CDN.OFF_AktualizujFirma 1426, @Seria, 'Domyślna seria - rozchody wewnętrzne z AI'
     --UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     EXEC CDN.OFF_AktualizujFirma 1343, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1345, @DDF_DDFId, ''
     EXEC CDN.OFF_AktualizujFirma 1425, @DDF_DDFId, ''
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
             end
   END
    -- AI
    ELSE IF @Typ = 1536
   BEGIN
     SELECT
    @TypDokumentu  = 311,
    --@DDF_Numeracja = '@brak/AI/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'AI',
    @SymbolNew     = 'AI',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
      EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/AI/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'AI_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Arkusz inwentaryzac.',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     --EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1429, @Seria,'Domyślna seria - arkusz inwentaryzacyjny'
              EXEC CDN.OFF_AktualizujFirma 1430, @DDF_DDFId, ''
     --UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
             end
   END
    -- MM
    ELSE IF @Typ = 1600 or  @Typ = 1603 or @Typ = 1604
   BEGIN
     SELECT
    @TypDokumentu  = 312,
    --@DDF_Numeracja = '@brak/MM/@numer/@rok_kal/@rejestr',
    @SymbolOld     = 'MM',
    @SymbolNew     = 'MM',
    @DDF_Numeracja = CDN.UtworzSchematNumeracjiXL (@FormatNumeracji ,@SymbolNew ) --'@brak/FS/@numer/@rok_kal/@rejestr',
    if not exists(select * from cdn.detalstanowiska where dsta_seria = @Seria)
     EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
              if @Domyslna = 1
              begin
              if not exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = @DDF_Numeracja )
              begin
                if exists (select * from cdn.dokdefinicje where ddf_klasa = @TypDokumentu and ddf_numeracja = '@brak/MM/@numer/@rok_kal/@rejestr' )
                begin
                    set @SymbolNew     = 'MM_N'
     INSERT INTO [CDN].[DokDefinicje]([DDf_Klasa],[DDf_Symbol],[DDf_Nazwa],[DDf_Numeracja],[DDf_SeriaOperatora],[DDf_TS_Zal],[DDf_TS_Mod])
      VALUES (@TypDokumentu,@SymbolNew,'Przesunięcie MM',@DDF_Numeracja,0,GETDATE(),GETDATE())
                end
                else
                begin
     UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
                    DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
                end
              end
              SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND  ddf_numeracja = @DDF_Numeracja
     --EXEC CDN.OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
     EXEC CDN.OFF_AktualizujFirma 1348, @Seria, 'Domyślna seria - przesunięcia międzymagazynowe'
     EXEC CDN.OFF_AktualizujFirma 1347, @DDF_DDFId, ''
     --UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
     --SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
     --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
     IF NOT EXISTS (Select * From Cdn.DokDefinicje Where DDF_Klasa = 999)
      Insert Into Cdn.DokDefinicje(DDF_Klasa,DDF_Symbol,DDF_Nazwa,DDF_numeracja,DDF_seriaoperatora,DDF_TS_Mod,DDF_TS_Zal)
      Values(999,'MMOL','MM odległa','@brak/MM/@numer/@rok_kal/@brak',0,Getdate(),Getdate())
             end
   END
    ELSE
   BEGIN
     SET @Komunikat = @Typ
     RAISERROR( @Komunikat, 16, 1)
     RETURN
   END
   END
   --KOMUNIKAT:
   --   RAISERROR( @Komunikat, 16, 1)
   --   RETURN
  SET NOCOUNT OFF
/*PROCEDURE CDN.sp_OFF_AktualizujSerie
    @TypChar    nvarchar(30),
    @Seria      nvarchar(30),
    @Domyslna   nvarchar(3),
    @FormatNumeracji nvarchar(30)
AS
  SET NOCOUNT ON
  DECLARE
    @Typ           INT,
    @TypDokumentu  INT,
    @DDF_Numeracja nvarchar(50),
    @Komunikat     nvarchar(255),
    @SymbolOld     nvarchar(30),
    @SymbolNew     nvarchar(30),
    @Gru_Opis      nvarchar(50),
    @DDF_DDFId     INT
  SELECT
    @Typ        = CONVERT(INT, @TypChar),
    @Gru_Opis   = 'Z Centrali'
  --nie może być serii pustej
  IF @Seria='' RETURN
  -- FA
  IF @Typ = 2033
    BEGIN
      SELECT
        @TypDokumentu  = 302,
        @DDF_Numeracja = '@brak/FS/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'FS',
        @SymbolNew     = 'FS'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1270, @Seria, 'Domyślna seria - faktury sprzedaży'
      EXEC CDN.sp_OFF_AktualizujFirma 1272, @Seria, 'Domyślna seria - faktury sprzedazy - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1281, @Seria, 'Domyślna seria - faktury z paragonów'
      EXEC CDN.sp_OFF_AktualizujFirma 1283, @Seria, 'Domyślna seria - faktury z paragonów - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1292, @Seria, 'Domyślna seria - faktury sprzedaży z wydań zewnętrznych'
      EXEC CDN.sp_OFF_AktualizujFirma 1294, @Seria, 'Domyślna seria - faktury sprzedaży z wydań zewnętrznych - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1296, @Seria, 'Domyślna seria - faktury sprzedaży z rezerwcji odbiorcy'
      EXEC CDN.sp_OFF_AktualizujFirma 1298, @Seria, 'Domyślna seria - faktury sprzedaży z rezerwcji odbiorcy - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1568, @Seria, 'Domyślna seria - faktura sprzedaży z PF'
      EXEC CDN.sp_OFF_AktualizujFirma 1544, @Seria, 'Domyślna seria - faktura pro-forma'
--      EXEC CDN.sp_OFF_AktualizujFirma 1420, @Seria, 'Domyślna seria - bilans zamknięcia magazynu'
      --EXEC CDN.sp_OFF_AktualizujFirma 1322, @Seria, 'Domyślna seria - wydania zewnętrzne'
      EXEC CDN.sp_OFF_AktualizujFirma 1326, @Seria, 'Domyślna seria - wydania zewnętrzne powstałe z faktur sprzedaży'
      EXEC CDN.sp_OFF_AktualizujFirma 1487, @Seria, 'Domyślna seria - wydania zewnętrzne powstałe z faktur sprzedaży'
      --EXEC CDN.sp_OFF_AktualizujFirma 1330, @Seria, 'Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1412, @Seria, 'Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty kosztu'
      EXEC CDN.sp_OFF_AktualizujFirma 1695, @Seria, 'Domyślna seria - faktura sprzedaży z WKA'
      EXEC CDN.sp_OFF_AktualizujFirma 1737, @Seria, 'Domyślna seria - faktura sprzedaży z WKA - korekta'
      UPDATE Cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1269, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1271, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1282, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1280, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1291, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1295, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1297, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1293, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1567, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1694, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1736, @DDF_DDFId, ''
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
-- WZ
  ELSE IF @Typ = 2001
    BEGIN
      SELECT
        @TypDokumentu  = 306,
        @DDF_Numeracja = '@brak/WZ/@numer/@rok_kal/@rejestr',
        @SymbolOld     = ' WZ',
        @SymbolNew     = ' WZ'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1322, @Seria, 'Domyślna seria - wydania zewnętrzne'
      EXEC CDN.sp_OFF_AktualizujFirma 1330, @Seria, 'Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty'
      IF NOT EXISTS(SELECT DDF_Numeracja FROM Cdn.DokDefinicje WHERE DDF_Numeracja  = @DDF_Numeracja and DDF_Symbol=@SymbolNew)
      BEGIN
         INSERT INTO [CDN].[DokDefinicje]( [DDf_Klasa], [DDf_Symbol], [DDf_Nazwa], [DDf_Numeracja], [DDf_SeriaOperatora], [DDf_TS_Export],  [DDf_ImportRowId], [DDf_OpeZalID], [DDf_StaZalId], [DDf_TS_Zal], [DDf_OpeModID], [DDf_StaModId], [DDf_TS_Mod])
         VALUES( @TypDokumentu, @SymbolNew, 'Wydanie zewnętrzne', @DDF_Numeracja,  0, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, GETDATE())
      END
      SELECT @DDF_DDFId=DDF_DDFId  FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1321, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1780, @DDF_DDFId, ''
      --EXEC CDN.sp_OFF_AktualizujFirma 1329, @DDF_DDFId, ''
     END
  -- WKA
  ELSE IF @Typ = 2000
    BEGIN
      SELECT
        @TypDokumentu  = 314,
        @DDF_Numeracja = '@brak/WKA/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'WKA',
        @SymbolNew     = 'WKA'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1701, @Seria, 'Domyślny typ - wydanie opakowań/kaucji'
      EXEC CDN.sp_OFF_AktualizujFirma 1704, @Seria, 'Domyślny typ - wydanie opakowań/kaucji korekta'
      EXEC CDN.sp_OFF_AktualizujFirma 1707, @Seria, 'Domyślny typ - wydanie kaucji do FA'
      EXEC CDN.sp_OFF_AktualizujFirma 1710, @Seria, 'Domyślny typ - wydanie kaucji do PA'
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1700, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1703, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1706, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1709, @DDF_DDFId, ''
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
  -- PKA
  ELSE IF @Typ = 2002
    BEGIN
      SELECT
        @TypDokumentu  = 313,
        @DDF_Numeracja = '@brak/PKA/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'PKA',
        @SymbolNew     = 'PKA'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1713, @Seria, 'Domyślny typ - przyjęcie kaucji'
      EXEC CDN.sp_OFF_AktualizujFirma 1716, @Seria, 'Domyślny typ - przyjęcie opakowań/kaucji korekta'
      EXEC CDN.sp_OFF_AktualizujFirma 1719, @Seria, 'Domyślny typ - przyjęcie kaucji do FZ'
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1712, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1715, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1718, @DDF_DDFId, ''
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
  -- PA
  ELSE IF @Typ = 2034
    BEGIN
      SELECT
        @TypDokumentu  = 305,
        @DDF_Numeracja = '@brak/PA/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'PA',
        @SymbolNew     = 'PA'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1274, @Seria, 'Domyślna seria - paragony'
      EXEC CDN.sp_OFF_AktualizujFirma 1279, @Seria, 'Domyślna seria - paragony - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1302, @Seria, 'Domyślna seria - paragony z rezerwcji odbiorcy'
      EXEC CDN.sp_OFF_AktualizujFirma 1304, @Seria, 'Domyślna seria - paragony z rezerwcji odbiorcy - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1306, @Seria, 'Domyślna seria - wydania zewnętrzne z paragonów'
      EXEC CDN.sp_OFF_AktualizujFirma 1308, @Seria, 'Domyślna seria - wydania zewnętrzne z paragonów - korekty'
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1273, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1278, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1301, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1305, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1303, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1307, @DDF_DDFId, ''
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
  -- RO i ZD
  ELSE IF @Typ = 9473
    BEGIN
      -- RO / ZZ
      SELECT
        @TypDokumentu  = 308,
        @DDF_Numeracja = '@brak/ZS/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'ZS',
        @SymbolNew     = 'ZS'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1309, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1570, @DDF_DDFId, ''
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
  ELSE IF @Typ = 9472
    BEGIN
      -- ZD / ZW
      SELECT
        @TypDokumentu  = 309,
        @DDF_Numeracja = '@brak/ZW/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'ZW',
        @SymbolNew     = 'ZW'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1310, @Seria, 'Domyślna seria - rezerwacje odbiorców'
      EXEC CDN.sp_OFF_AktualizujFirma 1571, @Seria, 'Domyślna seria - rezerwacja odbiorcy z PF'
      EXEC CDN.sp_OFF_AktualizujFirma 1320, @Seria, 'Domyślna seria - zamówienia u dostawców'
      EXEC CDN.sp_OFF_AktualizujFirma 1437, @Seria, 'Domyślna seria - przyjęcie zewnętrzne z ZD'
      EXEC CDN.sp_OFF_AktualizujFirma 1547, @Seria, 'Domyślna seria - wydanie zewnętrzne z RO'
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1319, @DDF_DDFId, ''
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
  -- FZ
  ELSE IF @Typ = 1521
    BEGIN
      SELECT
        @TypDokumentu  = 301,
        @DDF_Numeracja = '@brak/FZ/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'FZ',
        @SymbolNew     = 'FZ'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1285, @Seria, 'Domyślna seria - faktury zakupu'
      EXEC CDN.sp_OFF_AktualizujFirma 1287, @Seria, 'Domyślna seria - faktury zakupu - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1312, @Seria, 'Domyślna seria - faktury zakupu z przyjęć zewnętrznych'
      EXEC CDN.sp_OFF_AktualizujFirma 1314, @Seria, 'Domyślna seria - faktury zakupu z przyjęć zewnętrznych - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1316, @Seria, 'Domyślna seria - faktury zakupu z zamówień od dostawców'
      EXEC CDN.sp_OFF_AktualizujFirma 1448, @Seria, 'Domyślna seria - nota korygująca do faktury zakupu'
      EXEC CDN.sp_OFF_AktualizujFirma 1511, @Seria, 'Domyślna seria - korekta graniczna do faktury zakupu'
      --EXEC CDN.sp_OFF_AktualizujFirma 1332, @Seria, 'Domyślna seria - przyjęcia zewnętrzne'
      EXEC CDN.sp_OFF_AktualizujFirma 1334, @Seria, 'Domyślna seria - przyjęcia zewnętrzne z faktur zakupu'
      --EXEC CDN.sp_OFF_AktualizujFirma 1338, @Seria, 'Domyślna seria - przyjęcia zewnętrzne - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1698, @Seria, 'Domyślna seria - faktura zakupu z PKA'
      EXEC CDN.sp_OFF_AktualizujFirma 1739, @Seria, 'Domyślna seria - faktura zakupu z PKA - korekta'
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1284, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1286, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1311, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1313, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1315, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1447, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1510, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1317, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1697, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1738, @DDF_DDFId, ''
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
 -- PZ
  ELSE IF @Typ = 1489
    BEGIN
      SELECT
        @TypDokumentu  = 307,
        @DDF_Numeracja = '@brak/PZ/@numer/@rok_kal/@rejestr',
        @SymbolOld     = ' PZ',
        @SymbolNew     = ' PZ'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1332, @Seria, 'Domyślna seria - przyjęcia zewnętrzne'
      EXEC CDN.sp_OFF_AktualizujFirma 1338, @Seria, 'Domyślna seria - przyjęcia zewnętrzne - korekty'
      IF NOT EXISTS(SELECT DDF_Numeracja FROM Cdn.DokDefinicje WHERE DDF_Numeracja  = @DDF_Numeracja and DDF_Symbol=@SymbolNew)
      BEGIN
         INSERT INTO [CDN].[DokDefinicje]( [DDf_Klasa], [DDf_Symbol], [DDf_Nazwa], [DDf_Numeracja], [DDf_SeriaOperatora], [DDf_TS_Export],  [DDf_ImportRowId], [DDf_OpeZalID], [DDf_StaZalId], [DDf_TS_Zal], [DDf_OpeModID], [DDf_StaModId], [DDf_TS_Mod])
         VALUES( @TypDokumentu, @SymbolNew, 'Przyjęcie zewnętrzne', @DDF_Numeracja,  0, NULL, NULL, NULL, NULL, GETDATE(), NULL, NULL, GETDATE())
      END
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1331, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1779, @DDF_DDFId, ''
      --EXEC CDN.sp_OFF_AktualizujFirma 1337, @DDF_DDFId, ''
      --DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
  ELSE IF @Typ = 5
    BEGIN
      SET @Komunikat = '##OPT34484##'--'Brak odpowiednika typu dokumentu '
      RAISERROR( @Komunikat, 16, 1)
      RETURN
    END
 -- PW
  ELSE IF @Typ = 1617
    BEGIN
      SELECT
        @TypDokumentu  = 303,
        @DDF_Numeracja = '@brak/PW/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'PW',
        @SymbolNew     = 'PW'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1340, @Seria, 'Domyślna seria - przychody wewnętrzne'
      EXEC CDN.sp_OFF_AktualizujFirma 1342, @Seria, 'Domyślna seria - przychody wewnętrzne - korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1423, @Seria, 'Domyślna seria - przychody wewnętrzne z AI'
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1339, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1341, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1422, @DDF_DDFId, ''
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
  -- RW
  ELSE IF @Typ = 1616
    BEGIN
      SELECT
        @TypDokumentu  = 304,
        @DDF_Numeracja = '@brak/RW/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'RW',
        @SymbolNew     = 'RW'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1344, @Seria, 'Domyślna seria - rozchody wewnętrzne'
      EXEC CDN.sp_OFF_AktualizujFirma 1346, @Seria, 'Domyślna seria - rozchody wewnętrzne korekty'
      EXEC CDN.sp_OFF_AktualizujFirma 1426, @Seria, 'Domyślna seria - rozchody wewnętrzne z AI'
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      EXEC CDN.sp_OFF_AktualizujFirma 1343, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1345, @DDF_DDFId, ''
      EXEC CDN.sp_OFF_AktualizujFirma 1425, @DDF_DDFId, ''
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
  -- AI
  ELSE IF @Typ = 1536
    BEGIN
      SELECT
        @TypDokumentu  = 311,
        @DDF_Numeracja = '@brak/AI/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'AI',
        @SymbolNew     = 'AI'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1429, @Seria,'Domyślna seria - arkusz inwentaryzacyjny'
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
    END
  -- MM
  ELSE IF @Typ = 1600 or  @Typ = 1603 or @Typ = 1604
    BEGIN
      SELECT
        @TypDokumentu  = 312,
        @DDF_Numeracja = '@brak/MM/@numer/@rok_kal/@rejestr',
        @SymbolOld     = 'MM',
        @SymbolNew     = 'MM'
      EXEC CDN.sp_OFF_AktualizujGrupy  @TypDokumentu, @Seria, @Gru_Opis
      EXEC CDN.sp_OFF_AktualizujFirma 1348, @Seria, 'Domyślna seria - przesunięcia międzymagazynowe'
      UPDATE cdn.DokDefinicje SET DDF_Numeracja  = @DDF_Numeracja, DDF_Symbol = @SymbolNew WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol = @SymbolOld
      SELECT @DDF_DDFId=DDF_DDFId FROM Cdn.DokDefinicje where DDF_Klasa=@TypDokumentu AND DDF_symbol=@SymbolNew
      DELETE FROM cdn.DokDefinicje WHERE DDF_Klasa = @TypDokumentu AND DDF_Symbol != @SymbolNew
      IF NOT EXISTS (Select * From Cdn.DokDefinicje Where DDF_Klasa = 999)
          Insert Into Cdn.DokDefinicje(DDF_Klasa,DDF_Symbol,DDF_Nazwa,DDF_numeracja,DDF_seriaoperatora,DDF_TS_Mod,DDF_TS_Zal)
          Values(999,'MMOL','MM odległa','@brak/MM/@numer/@rok_kal/@brak',0,Getdate(),Getdate())
    END
  ELSE
    BEGIN
      SET @Komunikat = @Typ
      RAISERROR( @Komunikat, 16, 1)
      RETURN
    END
   --KOMUNIKAT:
   --   RAISERROR( @Komunikat, 16, 1)
   --   RETURN
  SET NOCOUNT OFF
*/
