CREATE FUNCTION CDN.DomyslnaSeria
(
   @TrN_Rodzaj        INT          -- Rodzaj dokumentu
)
RETURNS NVARCHAR(20)
AS
 BEGIN
  DECLARE @Seria NVARCHAR(20)
  SET @Seria = (
    SELECT TOP 1 CONVERT(NVARCHAR(20), Fir_Wartosc)
    FROM CDN.Firma
    WHERE Fir_Numer =
    CASE @TrN_Rodzaj
            -- 301 faktury zakupu
--              WHEN 301000 THEN 1285 -- Domyślna seria - faktury zakupu
--              WHEN 301001 THEN 1287 -- Domyślna seria - faktury zakupu - korekta ilościowa
--              WHEN 301002 THEN 1287 -- Domyślna seria - faktury zakupu - korekta wartościowa
--              WHEN 301004 THEN 1312 -- Domyślna seria - faktury zakupu z przyjęć zewnętrzny
--              WHEN 301005 THEN 1314 -- Domyślna seria - faktury zakupu z przyjęć zewnętrznych - korekty
--              WHEN 301009 THEN 1316 -- Domyślna seria - faktury zakupu z zamówień od dostawców
--              WHEN 301009 THEN 1317 -- Domyślna seria - faktury zakupu z zamówień od dostawcó - korekty
--              WHEN 301006 THEN 1448 -- Domyślna seria - nota korygująca do faktury zakupu
--              WHEN 301005 THEN 1511 -- Domyślna seria - korekta graniczna do faktury zakupu
            -- 302 faktury sprzedaży
--              WHEN 302000 THEN 1270 -- Domyślna seria - faktury sprzedaży
--              WHEN 302001 THEN 1270 -- Domyślna seria - faktury sprzedaży - korekta ilościowa
--              WHEN 302002 THEN 1270 -- Domyślna seria - faktury sprzedaży - korekta wartościowa
--              WHEN 302006 THEN 1271 -- Domyślny typ   - faktury sprzedaży z paragonu
--              WHEN 302007 THEN 1272 -- Domyślny typ   - faktury sprzedaży z paragonu - korekty
--              WHEN 302004 THEN 1292 -- Domyślna seria - faktury sprzedaży z wydań zewnętrznych
--              WHEN 302005 THEN 1294 -- Domyślna seria - faktury sprzedaży z wydań zewnętrznętrznych - korekty
--              WHEN 302008 THEN 1296 -- Domyślna seria - faktury sprzedaży z rezerwcji odbiorcy
--              WHEN 302009 THEN 1298 -- Domyślna seria - faktury sprzedaży z rezerwcji odbiorcy - korekty
--              WHEN 302020 THEN 1568 -- Domyślna seria - faktura sprzedaży z PF
--              WHEN 302200 THEN 1674 -- Domyślna seria - faktury zaliczkowa
--              WHEN 302202 THEN 1677 -- Domyślna seria - faktury zaliczkowa korekta
            -- 305 paragony
--              WHEN 305000 THEN 1274 -- Domyślna seria - paragony z rezerwcji odbiorcy
--              WHEN 305001 THEN 1279 -- Domyślna seria - paragony z wydań zewnętrznych
--              WHEN 305008 THEN 1302 -- Domyślna seria - paragony z rezerwcji odbiorcy
--              WHEN 305009 THEN 1304 -- Domyślna seria - paragony z rezerwcji odbiorcy - korekty
--              WHEN 305004 THEN 1306 -- Domyślna seria - paragony z wydań zewnętrznych
--              WHEN 305005 THEN 1308 -- Domyślna seria - paragony z wydań zewnętrznych - korekty
            -- 306 wydanie zewnętrzne
--              WHEN 306000 THEN 1322 -- Domyślna seria - wydania zewnętrzne
              WHEN 306004 THEN 1326 -- Domyślna seria - wydania zewnętrzne powstałe z faktur sprzedaży
              WHEN 306006 THEN 1487 -- Domyślna seria - wydania zewnętrzne powstałe z paragonów
              WHEN 306002 THEN 1330 -- Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
              WHEN 306994 THEN 1326 -- Domyślna seria - wydania zewnętrzne powstałe z faktur sprzedaży
              WHEN 306996 THEN 1487 -- Domyślna seria - wydania zewnętrzne powstałe z paragonów
              WHEN 306009 THEN 1330 -- Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
--              WHEN 306005 THEN 1330 -- Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty
              WHEN 306071 THEN 1412 -- Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
              WHEN 306072 THEN 1412 -- Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
              WHEN 306061 THEN 1412 -- Domyślna seria - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
              WHEN 306008 THEN 1547 -- Domyślna seria - wydanie zewnętrzne z RO
              WHEN 306010 THEN 1782 -- Domyślna seria - wydanie zewnętrzne z PF
            -- 307 przyjęcie zewnętrzne
--              WHEN 307000 THEN 1332 -- Domyślna seria - przyjęcia zewnętrzne
              WHEN 307004 THEN 1334 -- Domyślna seria - przyjęcia zewnętrzne z faktur zakup
              WHEN 307006 THEN 1338 -- Domyślny seria - przyjęcia zewnętrzne - korekty
     WHEN 307011 THEN 1338 -- Domyślny seria - przyjęcia zewnętrzne - korekty
--              WHEN 307001 THEN 1338 -- Domyślna seria - przyjęcia zewnętrzne - korekty
--              WHEN 307009 THEN 1437 -- Domyślna seria - przyjęcie zewnętrzne z ZD
            -- 308 rezerwacje odbiorcy
--              WHEN 308000 THEN 1310 -- Domyślna seria - rezerwacje odbiorców
--              WHEN 308020 THEN 1571 -- Domyślna seria - rezerwacja odbiorcy z PF
            -- 309 zamówienia u dostawcy
--              WHEN 309000 THEN 1320 -- Domyślna seria - zamówienia u dostawców
            -- 320 faktury pro-forma
              WHEN 320000 THEN 1544 -- Domyślna seria - faktura pro-forma
            -- bilans otwarcia magazynu 310
--              WHEN 310000 THEN 1396 -- Domyślna seria - bilans otwarcia magazynu
--              WHEN 310001 THEN 1501 -- Domyślna seria - bilans otwarcia magazynu korekta ilościowa
--              WHEN 310002 THEN 1504 -- Domyślna seria - bilans otwarcia magazynu korekta wartościowa
              WHEN 310005 THEN 1420 -- Domyślna seria - bilans zamknięcia magazynu
            -- 312 przesunięcia międzymagazynowe
--              WHEN 312000 THEN 1348 -- Domyślna seria - przesunięcia międzymagazynowe lokalne
            -- 303 przyjęcia wewnętrzne
              WHEN 303000 THEN 1340 -- Domyślna seria - przychody wewnętrzne
              WHEN 303001 THEN 1342 -- Domyślna seria - przychody wewnętrzne - korekty
              WHEN 303010 THEN 1423 -- Domyślna seria - przychody wewnętrzne z AI
            -- 304 rozchody wewnętrzne
              WHEN 304000 THEN 1344 -- Domyślna seria - rozchody wewnętrzne
              WHEN 304001 THEN 1346 -- Domyślna seria - rozchody wewnętrzne korekty
              WHEN 304010 THEN 1426 -- Domyślna seria - rozchody wewnętrzne z AI
     WHEN 304004 THEN 1962 -- Domyślna seria - rozchody wewnętrzne z FA
              WHEN 304006 THEN 1959 -- Domyślna seria - rozchody wewnętrzne z PA
     WHEN 304008 THEN 1965 -- Domyślna seria - rozchody wewnętrzne z RO
            -- 317 kompletacja, przyjęcie wewnętrzne produktów
--              WHEN 317000 THEN 1451 -- Domyślna seria - przyjęcie wewnętrzne produktów
    WHEN 317001 THEN 1753
            -- 318 kompletacja, rozchody wewnętrzne składników
              WHEN 318000 THEN 1454 -- Domyślna seria - rozchód wewnętrzny składników
              WHEN 318001 THEN 1756 -- Domyślna seria - rozchód wewnętrzny składników - korekta
            -- 311 arkusz inwentaryzacyjny
              WHEN 311000 THEN 1429 -- Domyślna seria - arkusz inwentaryzacyjny
            -- 322 faktury wewnętrzne sprzedaży
--              WHEN 322000 THEN 1638 -- Domyślna seria - faktury wewnętrzne sprzedaży
--              WHEN 322021 THEN 1644 -- Domyślna seria - faktury wewnętrzne sprzedaży z FZ
            -- 321 faktury wewnętrzne zakupu
--              WHEN 321022 THEN 1642 -- Domyślna seria - faktury wewnętrzne zakupu z FZ
            -- 800 ofertowanie MS Word
              WHEN 800000 THEN 1671 -- Domyślna seria - oferta
            -- faktury rolnika ryczałtowego
--              WHEN 350000 THEN 1651 -- Domyślna seria - faktury rolnika ryczałtowego
--              WHEN 301050 THEN 1681 -- Domyślna seria - faktura zakupu z FRR
            -- 314 wydanie kaucji WKA solo
              WHEN 314000 THEN 1701 -- Domyślny typ - wydanie kaucji WKA solo
            -- 314 wydanie kaucji do FA
              WHEN 314004 THEN 1707 -- Domyślny typ - wydanie kaucji do FA
            -- 314 wydanie kaucji do PA
              WHEN 314006 THEN 1710 -- Domyślny typ - wydanie kaucji do PA
            -- 313 przyjęcie kaucji PKA solo
              WHEN 313000 THEN 1713 -- Domyślny typ - przyjcie kaucji PKA solo
            -- 313 przyjęcie kaucji do FZ
              WHEN 313004 THEN 1719 -- Domyślny typ - przyjcie kaucji do FZ
     -- na potrzeby pracy rozporoszonej dla ewidencji dodatkowej
        WHEN 909090 THEN 1444 -- Domyślny typ - ewidencja dodatkowa przychodów
        WHEN 909091 THEN 1441 -- Domyślny typ - ewidencja dodatkowa kosztów
            END
  )
  IF ISNULL(@Seria,'') = ''
    SET @Seria = (SELECT TOP 1 Gru_Nazwa FROM CDN.Grupy WHERE Gru_Typ = CONVERT(INT, @TrN_Rodzaj/1000) ORDER BY Gru_Nazwa )
  SET @Seria = ISNULL(@Seria,'')
  RETURN @Seria
 END
