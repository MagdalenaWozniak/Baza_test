CREATE PROCEDURE [CDN].[IGaleria_EksportTwrZasoby]
 @TypExp INT  -- Typ eksportu stanów towaru (0 - różnicowy, 1 - pełny)
AS
DECLARE
     @TwGNumer      nvarchar(254),
     @TwGNumerInt   INT,
     @MagID         nvarchar(254),
     @MagIDInt      INT,
     @DataDzis      INT,
     @WyslijStanWszystkieMag TINYINT,
  @ESSID            int
     select  top 1 @ESSID = ESS_ESSID, @DataDzis = ESS_StanyNaDzien,@TwGNumerInt = ESS_TwGNumer,@MagIDInt = ESS_DomyslnyMagazyn,@WyslijStanWszystkieMag = ESS_WyslijStanWszystkieMag
   from cdn.eSklepStanowiska where ESS_typ = 2
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1899 AND Fir_Wartosc = 1) SELECT @DataDzis = 0 ELSE SELECT @DataDzis = 1
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900) SELECT @TwGNumer = 0 ELSE SELECT @TwGNumer = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1900
 --SELECT  @TwGNumerInt = CONVERT(INT,@TwGNumer)
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1896) SELECT @MagID = 0 ELSE SELECT @MagID = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1896
 --SELECT  @MagIDInt = CONVERT(INT,@MagID)
IF @WyslijStanWszystkieMag = 1
BEGIN
IF @DataDzis = 1
SELECT
    1 AS Tag, NULL AS Parent,
 ZSB.Twr_TwrId AS [ZSB!1!TwrID],
 case when ISNULL(A.TwI_Ilosc,0) - ISNULL(A.TwI_Rezerwacje,0) < 0 then 0 else ISNULL(A.TwI_Ilosc,0) - ISNULL(A.TwI_Rezerwacje,0) end AS [ZSB!1!Wartosc]
from Cdn.towary as ZSB
LEFT OUTER JOIN cdn.TwrESklep on ZSB.Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
LEFT JOIN (SELECT * from Cdn.TwrIlosci
JOIN (
--SELECT MAX(TwI_Data)as DATA,MAX(TwI_TwIId) as TwIId  FROM CDN.TwrIlosci WHERE TwI_Data <= GETDATE() GROUP BY TwI_TwrId,TwI_MagId) B ON  TwIId= TwI_TwIId) A ON A.TwI_TwrId = ZSB.Twr_TwrID AND A.TwI_MagId = @MagIDInt
  SELECT X.twi_data AS DATA, X.twi_twiid AS Twiid
  FROM cdn.twrilosci X where X.twi_twiid = [CDN].[TwrIlosciID] ( X.twi_twrid, 0, GETDATE() )
  ) B ON  TwIId= TwI_TwIId) A ON A.TwI_TwrId = ZSB.Twr_TwrID AND A.TwI_MagId is NULL
WHERE  Twes_Udostepnij = 1  AND ZSB.Twr_NieAktywny = 0
FOR XML EXPLICIT
ELSE
SELECT
   1 AS Tag, NULL AS Parent,
 ZSB.Twr_TwrId AS [ZSB!1!TwrID],
 case when ISNULL(A.TwI_Ilosc,0) - ISNULL(A.TwI_Rezerwacje,0) < 0 then 0 else ISNULL(A.TwI_Ilosc,0) - ISNULL(A.TwI_Rezerwacje,0) end AS [ZSB!1!Wartosc]
from Cdn.towary as ZSB
LEFT OUTER JOIN cdn.TwrESklep on ZSB.Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
LEFT JOIN (SELECT * from Cdn.TwrIlosci
JOIN (
--SELECT MAX(TwI_Data)as DATA,MAX(TwI_TwIId) as TwIId  FROM CDN.TwrIlosci GROUP BY TwI_TwrId,TwI_MagId) B ON  TwIId= TwI_TwIId) A ON A.TwI_TwrId = ZSB.Twr_TwrID AND A.TwI_MagId = @MagIDInt
  SELECT X.twi_data AS DATA, X.twi_twiid AS Twiid
  FROM cdn.twrilosci X where X.twi_twiid = [CDN].[TwrIlosciID] ( X.twi_twrid, 0, DATEADD(year, 1000, GETDATE()) )
  ) B ON  TwIId= TwI_TwIId) A ON A.TwI_TwrId = ZSB.Twr_TwrID AND A.TwI_MagId is NULL
WHERE  Twes_Udostepnij = 1  AND ZSB.Twr_NieAktywny = 0
FOR XML EXPLICIT
END
ELSE
BEGIN
IF @DataDzis = 1
SELECT
    1 AS Tag, NULL AS Parent,
 ZSB.Twr_TwrId AS [ZSB!1!TwrID],
 case when ISNULL(A.TwI_Ilosc,0) - ISNULL(A.TwI_Rezerwacje,0) < 0 then 0 else ISNULL(A.TwI_Ilosc,0) - ISNULL(A.TwI_Rezerwacje,0) end AS [ZSB!1!Wartosc]
from Cdn.towary as ZSB
LEFT OUTER JOIN cdn.TwrESklep on ZSB.Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
LEFT JOIN (SELECT * from Cdn.TwrIlosci
JOIN (
--SELECT MAX(TwI_Data)as DATA,MAX(TwI_TwIId) as TwIId  FROM CDN.TwrIlosci WHERE TwI_Data <= GETDATE() GROUP BY TwI_TwrId,TwI_MagId) B ON  TwIId= TwI_TwIId) A ON A.TwI_TwrId = ZSB.Twr_TwrID AND A.TwI_MagId = @MagIDInt
  SELECT X.twi_data AS DATA, X.twi_twiid AS Twiid
  FROM cdn.twrilosci X where X.twi_twiid = [CDN].[TwrIlosciID] ( X.twi_twrid, @MagIDInt, GETDATE() )
  ) B ON  TwIId= TwI_TwIId) A ON A.TwI_TwrId = ZSB.Twr_TwrID AND A.TwI_MagId = @MagIDInt
WHERE  Twes_Udostepnij = 1  AND ZSB.Twr_NieAktywny = 0
FOR XML EXPLICIT
ELSE
SELECT
   1 AS Tag, NULL AS Parent,
 ZSB.Twr_TwrId AS [ZSB!1!TwrID],
 case when ISNULL(A.TwI_Ilosc,0) - ISNULL(A.TwI_Rezerwacje,0) < 0 then 0 else ISNULL(A.TwI_Ilosc,0) - ISNULL(A.TwI_Rezerwacje,0) end AS [ZSB!1!Wartosc]
from Cdn.towary as ZSB
LEFT OUTER JOIN cdn.TwrESklep on ZSB.Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
LEFT JOIN (SELECT * from Cdn.TwrIlosci
JOIN (
--SELECT MAX(TwI_Data)as DATA,MAX(TwI_TwIId) as TwIId  FROM CDN.TwrIlosci GROUP BY TwI_TwrId,TwI_MagId) B ON  TwIId= TwI_TwIId) A ON A.TwI_TwrId = ZSB.Twr_TwrID AND A.TwI_MagId = @MagIDInt
  SELECT X.twi_data AS DATA, X.twi_twiid AS Twiid
  FROM cdn.twrilosci X where X.twi_twiid = [CDN].[TwrIlosciID] ( X.twi_twrid, @MagIDInt, DATEADD(year, 1000, GETDATE()) )
  ) B ON  TwIId= TwI_TwIId) A ON A.TwI_TwrId = ZSB.Twr_TwrID AND A.TwI_MagId = @MagIDInt
WHERE  Twes_Udostepnij = 1  AND ZSB.Twr_NieAktywny = 0
FOR XML EXPLICIT
END
