CREATE  FUNCTION CDN.CechyDostaw (@TrSId INT)
RETURNS @Dostawy TABLE (Kod NVARCHAR(20), Cecha NVARCHAR(255), Ilosc DECIMAL(15,4))
BEGIN
IF (SELECT Tsd_cecha1_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha1_kod, tsd_cecha1_Wartosc, tsd_ilosc FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
IF (SELECT tsd_cecha2_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha2_kod, tsd_cecha2_Wartosc,tsd_ilosc FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
IF (SELECT tsd_cecha3_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha3_kod, tsd_cecha3_Wartosc,tsd_ilosc  FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
IF (SELECT tsd_cecha4_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha4_kod, tsd_cecha4_Wartosc, tsd_ilosc  FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
IF (SELECT tsd_cecha5_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha5_kod, tsd_cecha5_Wartosc,tsd_ilosc  FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
IF (SELECT tsd_cecha6_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha6_kod, tsd_cecha6_Wartosc, tsd_ilosc  FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
IF (SELECT tsd_cecha7_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha7_kod, tsd_cecha7_Wartosc,tsd_ilosc FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
IF (SELECT tsd_cecha8_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha8_kod, tsd_cecha8_Wartosc,tsd_ilosc  FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
IF (SELECT tsd_cecha9_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha9_kod, tsd_cecha9_Wartosc,tsd_ilosc FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
IF (SELECT tsd_cecha10_deaid FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId) <> 0
INSERT INTO @Dostawy (Kod, Cecha, Ilosc)
SELECT tsd_cecha10_kod, tsd_cecha10_Wartosc, tsd_ilosc  FROM CDN.TrasElemDost WHERE Tsd_TrSId = @TrSId
RETURN
END
