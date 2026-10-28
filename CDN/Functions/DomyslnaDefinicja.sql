CREATE FUNCTION CDN.DomyslnaDefinicja
(
  @TrN_Rodzaj        INT          -- Rodzaj dokumentu
)
RETURNS INT
AS
  BEGIN
  -- Id numeracji
  RETURN
    (
      SELECT TOP 1 CONVERT(INT, Fir_Wartosc)
        FROM CDN.Firma
          WHERE Fir_Numer =
            CASE @TrN_Rodzaj
            -- 301 faktury zakupu
--              WHEN 301004 THEN 1311 -- Domyślny typ - faktury zakupu z przyjęć zewnętrzny
--              WHEN 301005 THEN 1313 -- Domyślny typ - faktury zakupu z przyjęć zewnętrznych - korekty
--              WHEN 301009 THEN 1315 -- Domyślny typ - faktury zakupu z zamówień od dostawców
--              WHEN 301009 THEN 1317 -- Domyślny typ - faktury zakupu z zamówień od dostawcó - korekty
--              WHEN 301006 THEN 1447 -- Domyślny typ - nota korygująca do faktury zakupu
--              WHEN 301005 THEN 1510 -- Domyślny typ - korekta graniczna do faktury zakupu
            -- 302 faktury sprzedaży
--              WHEN 302000 THEN 1269 -- Domyślny typ - faktury sprzedaży
--              WHEN 302001 THEN 1269 -- Domyślny typ - faktury sprzedaży - korekta ilościowa
--              WHEN 302002 THEN 1269 -- Domyślny typ - faktury sprzedaży - korekta wartościowa
--              WHEN 302006 THEN 1269 -- Domyślny typ - faktury sprzedaży z paragonu
--              WHEN 302007 THEN 1269 -- Domyślny typ - faktury sprzedaży z paragonu - korekty
--              WHEN 302004 THEN 1291 -- Domyślny typ - faktury sprzedaży z wydań zewnętrznych
--              WHEN 302008 THEN 1295 -- Domyślny typ - faktury sprzedaży z rezerwcji odbiorcy
--              WHEN 302009 THEN 1297 -- Domyślny typ - faktury sprzedaży z rezerwcji odbiorcy - korekty
--              WHEN 302005 THEN 1293 -- Domyślny typ - faktury sprzedaży z wydań zewnętrznętrznych - korekty
--              WHEN 302020 THEN 1567 -- Domyślny typ - faktura sprzedaży z PF
--              WHEN 302202 THEN 1676 -- Domyślny typ - faktury zaliczkowa korekta
--              WHEN 302200 THEN 1673 -- Domyślny typ - faktury zaliczkowa
            -- 305 paragony
--              WHEN 305008 THEN 1301 -- Domyślny typ - paragony z rezerwcji odbiorcy
--              WHEN 305004 THEN 1305 -- Domyślny typ - paragony z wydań zewnętrznych
--              WHEN 305009 THEN 1303 -- Domyślny typ - paragony z rezerwcji odbiorcy - korekty
--              WHEN 305005 THEN 1307 -- Domyślny typ - paragony z wydań zewnętrznych - korekty
            -- 306 wydanie zewnętrzne
--              WHEN 306000 THEN 1321 -- Domyślny typ - wydania zewnętrzne
              WHEN 306004 THEN 1325 -- Domyślny typ - wydania zewnętrzne powstałe z faktur sprzedaży
              WHEN 306006 THEN 1486 -- Domyślny typ - wydania zewnętrzne powstałe z paragonów
              WHEN 306994 THEN 2161 -- Domyślny typ - wydania zewnętrzne powstałe z faktur akcyza
              WHEN 306996 THEN 2161 -- Domyślny typ - wydania zewnętrzne powstałe z paragonów akcyza
              WHEN 306008 THEN 1546 -- Domyślny typ - wydanie zewnętrzne z RO
--              WHEN 306005 THEN 1329 -- Domyślny typ - wydania zewnętrzne uzupełniające z faktur sprzedaży - korekty
              WHEN 306002 THEN 1329 -- Domyślny typ - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
              WHEN 306009 THEN 1329 -- Domyślny typ - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
              WHEN 306071 THEN 1411 -- Domyślny typ - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
              WHEN 306072 THEN 1411 -- Domyślny typ - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
              WHEN 306061 THEN 1411 -- Domyślny typ - wydania zewnętrzne uzupełniające z faktur sprzedaży korekty kosztu
              WHEN 306010 THEN 1781 -- Domyślny typ - wydanie zewnętrzne z PF
            -- 307 przyjęcie zewnętrzne
--              WHEN 307000 THEN 1331 -- Domyślny typ - przyjęcia zewnętrzne
--              WHEN 307001 THEN 1337 -- Domyślny typ - przyjęcia zewnętrzne - korekty
              WHEN 307004 THEN 1333 -- Domyślny typ - przyjęcia zewnętrzne z faktur zakup
              WHEN 307006 THEN 1337 -- Domyślny typ - przyjęcia zewnętrzne - korekty
     WHEN 307011 THEN 1337 -- Domyślny typ - przyjęcia zewnętrzne - korekty
--              WHEN 307009 THEN 1436 -- Domyślny typ - przyjęcie zewnętrzne z ZD
            -- 308 rezerwacje odbiorcy
--              WHEN 308000 THEN 1309 -- Domyślny typ - rezerwacje odbiorców
--              WHEN 308020 THEN 1570 -- Domyślny typ - rezerwacja odbiorcy z PF
            -- 309 zamówienia u dostawcy
--              WHEN 309000 THEN 1319 -- Domyślny typ - zamówienia u dostawców
            -- 320 faktury pro-forma
              WHEN 320000 THEN 1543 -- Domyślny typ - faktura pro-forma
            -- bilans otwarcia magazynu 310
--              WHEN 310000 THEN 1395 -- Domyślny typ - bilans otwarcia magazynu
--              WHEN 310001 THEN 1500 -- Domyślny typ - bilans otwarcia magazynu korekta ilościowa
--              WHEN 310002 THEN 1503 -- Domyślny typ - bilans otwarcia magazynu korekta wartościowa
              WHEN 310005 THEN 1419 -- Domyślny typ - bilans zamknięcia magazynu
            -- 312 przesunięcia międzymagazynowe
--              WHEN 312000 THEN 1347 -- Domyślny typ - przesunięcia międzymagazynowe lokal
            -- 303 przyjęcia wewnętrzne
              WHEN 303000 THEN 1339 -- Domyślny typ - przychody wewnętrzne
              WHEN 303001 THEN 1341 -- Domyślny typ - przychody wewnętrzne - korekty
              WHEN 303010 THEN 1422 -- Domyślny typ - przychody wewnętrzne z AI
            -- 304 rozchody wewnętrzne
              WHEN 304000 THEN 1343 -- Domyślny typ - rozchody wewnętrzne
              WHEN 304001 THEN 1345 -- Domyślny typ - rozchody wewnętrzne korekty
              WHEN 304010 THEN 1425 -- Domyślny typ - rozchody wewnętrzne z AI
     WHEN 304004 THEN 1961 -- Domyślny typ - rozchody wewnętrzne z FA
              WHEN 304006 THEN 1958 -- Domyślny typ - rozchody wewnętrzne z PA
     WHEN 304008 THEN 1964 -- Domyślny typ - rozchody wewnętrzne z RO
            -- 317 kompletacja, przyjęcie wewnętrzne produktów
--              WHEN 317000 THEN 1450 -- Domyślny typ - przyjęcie wewnętrzne produktów
   when 317001 then 1752
            -- 318 kompletacja, rozchody wewnętrzne składników
              WHEN 318000 THEN 1453 -- Domyślny typ - rozchód wewnętrzny składników
              WHEN 318001 THEN 1755 -- Domyślny typ - rozchód wewnętrzny składników - korekta
            -- 311 arkusz inwentaryzacyjny
              WHEN 311000 THEN 1428 -- Domyślny typ - arkusz inwentaryzacyjny
            -- 322 faktury wewnętrzne sprzedaży
--              WHEN 322000 THEN 1639 -- Domyślny typ - faktury wewnętrzne sprzedaży
--              WHEN 322021 THEN 1645 -- Domyślny typ - faktury wewnętrzne sprzedaży z FZ
            -- 321 faktury wewnętrzne zakupu
--              WHEN 321022 THEN 1641 -- Domyślny typ - faktury wewnętrzne zakupu z FZ
            -- 800 ofertowanie MS Word
              WHEN 800000 THEN 1670 -- Domyślny typ - oferta
            -- 350 faktury rolnika ryczałtowego
--              WHEN 350000 THEN 1650 -- Domyślny typ - faktury rolnika ryczałtowego
--              WHEN 301050 THEN 1680 -- Domyślny typ - faktura zakupu z FRR
            -- 314 wydanie kaucji WKA solo
              WHEN 314000 THEN 1700 -- Domyślny typ - wydanie kaucji WKA solo
            -- 314 wydanie kaucji do FA
              WHEN 314004 THEN 1706 -- Domyślny typ - wydanie kaucji do FA
            -- 314 wydanie kaucji do PA
              WHEN 314006 THEN 1709 -- Domyślny typ - wydanie kaucji do PA
            -- 313 przyjęcie kaucji PKA solo
              WHEN 313000 THEN 1712 -- Domyślny typ - przyjcie kaucji PKA solo
            -- 313 przyjęcie kaucji do FZ
              WHEN 313004 THEN 1718 -- Domyślny typ - przyjcie kaucji do FZ
     -- na potrzeby pracy rozporoszonej dla ewidencji dodatkowej
        WHEN 909090 THEN 1443 -- Domyślny typ - ewidencja dodatkowa przychodów
        WHEN 909091 THEN 1440 -- Domyślny typ - ewidencja dodatkowa kosztów
     -- na potrzeby pracy rozproszonej dla automatycznych zapisów
        WHEN 909092 THEN case ( SELECT Fir_Wartosc -- Domyślny typ - rejestr sprzedaży
    FROM CDN.Firma
    WHERE Fir_Numer = 1777)
   when 1 then 1727
   else 1275
   end
  WHEN 909093 THEN case ( SELECT Fir_Wartosc -- Domyślny typ - rejestr zakupów
    FROM CDN.Firma
    WHERE Fir_Numer = 1777)
   when 1 then 1730
   else 1276
   end
            END
    )
  END
