CREATE PROCEDURE CDN.AktualizujTraVATTraNag
 @TrN_TrNId INT
AS
-- update tabelki VAT w zależności od:
--   - typu dokumentu netto/brutto
--   - rodzaju liczenia płatności (od wartości walutowej, od wartości PLN )
SET NOCOUNT ON
DELETE FROM CDN.TraVat WHERE TrV_TrNId = @TrN_TrNId
INSERT INTO CDN.TraVat ( TrV_TrNId, TrV_Stawka, TrV_Flaga, TrV_Zrodlowa, TrV_Netto, TrV_VAT, TrV_NettoWal, TrV_VATWal, TrV_Typ )
  SELECT                @TrN_TrNId, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa,         0,       0,            0,          0,       0
    FROM CDN.TraElem
    WHERE TrE_TrNId = @TrN_TrNId
    GROUP BY TrE_Stawka, TrE_Flaga, TrE_Zrodlowa
UPDATE CDN.TraVat SET
  TrV_Netto    = Netto,
  TrV_VAT      = VAT,
  TrV_NettoWal = NettoWal,
  TrV_VATWal   = VATWal
FROM
( SELECT
  @TrN_TrNId   AS TrNId,
  TrE_Stawka   AS Stawka,
  TrE_Flaga    AS Flaga,
  TrE_Zrodlowa AS Zrodlowa,
  CASE
    WHEN TrN_TypNB=1 AND TrN_PlatElemWalSys=0 THEN   SUM(TrE_WartoscNettoWal)* TrN_KursL/TrN_KursM
    WHEN TrN_TypNB=1 AND TrN_PlatElemWalSys=1 THEN   SUM(TrE_WartoscNetto)
    WHEN TrN_TypNB=2 AND TrN_PlatElemWalSys=0 THEN   ROUND( ROUND(SUM(TrE_WartoscBruttoWal) - SUM(TrE_WartoscBruttoWal)  * TrE_Stawka / (100 + TrE_Stawka), 2)* TrN_KursL/TrN_KursM, 2)--ROUND(SUM(TrE_WartoscBruttoWal) * TrN_KursL/TrN_KursM, 2)  - ROUND(ROUND(SUM(TrE_WartoscBruttoWal) * TrN_KursL/TrN_KursM, 2) * TrE_Stawka / (100 + TrE_Stawka), 2)
    WHEN TrN_TypNB=2 AND TrN_PlatElemWalSys=1 THEN   SUM(TrE_WartoscBrutto)    - ROUND(SUM(TrE_WartoscBrutto)    * TrE_Stawka / (100+TrE_Stawka),2)
  END AS Netto,
  CASE
    WHEN TrN_TypNB=1 AND TrN_PlatElemWalSys=0 THEN ROUND(ROUND(SUM(TrE_WartoscNettoWal)  * TrE_Stawka/100,2) * TrN_KursL/TrN_KursM,2)--WHEN TrN_TypNB=1 AND TrN_PlatElemWalSys=0 THEN ROUND(SUM(TrE_WartoscNettoWal)  * TrN_KursL/TrN_KursM,2) * TrE_Stawka/100
    WHEN TrN_TypNB=1 AND TrN_PlatElemWalSys=1 THEN ROUND(SUM(TrE_WartoscNetto)     * TrE_Stawka/100,2)
    WHEN TrN_TypNB=2 AND TrN_PlatElemWalSys=0 THEN ROUND(ROUND(SUM(TrE_WartoscBruttoWal)  * TrE_Stawka / (100 + TrE_Stawka), 2)* TrN_KursL/TrN_KursM, 2)--WHEN TrN_TypNB=2 AND TrN_PlatElemWalSys=0 THEN ROUND(ROUND(SUM(TrE_WartoscBruttoWal) * TrN_KursL/TrN_KursM, 2) * TrE_Stawka / (100 + TrE_Stawka), 2)
    WHEN TrN_TypNB=2 AND TrN_PlatElemWalSys=1 THEN ROUND(SUM(TrE_WartoscBrutto)    * TrE_Stawka/(100+TrE_Stawka),2)
  END AS VAT,
  CASE
    WHEN TrN_TypNB=1 AND TrN_PlatElemWalSys=0 THEN          SUM(TrE_WartoscNettoWal)
    WHEN TrN_TypNB=1 AND TrN_PlatElemWalSys=1 THEN ROUND(   SUM(TrE_WartoscNetto)    *  TrN_KursM/TrN_KursL , 2 )
    WHEN TrN_TypNB=2 AND TrN_PlatElemWalSys=0 THEN          SUM(TrE_WartoscBruttoWal)    - ROUND( SUM(TrE_WartoscBruttoWal) * TrE_Stawka/(100+TrE_Stawka),2)
    WHEN TrN_TypNB=2 AND TrN_PlatElemWalSys=1 THEN ROUND(SUM(TrE_WartoscBrutto) * TrN_KursM/TrN_KursL, 2)  - ROUND(ROUND(SUM(TrE_WartoscBrutto) * TrN_KursM/TrN_KursL, 2) * TrE_Stawka/(100+TrE_Stawka), 2)
  END AS NettoWal,
  CASE
    WHEN TrN_TypNB=1 AND TrN_PlatElemWalSys=0 THEN ROUND(SUM(TrE_WartoscNettoWal) * (100+TrE_Stawka)/100, 2) - SUM(TrE_WartoscNettoWal)
    WHEN TrN_TypNB=1 AND TrN_PlatElemWalSys=1 THEN ROUND(ROUND(SUM(TrE_WartoscNetto)  * TrN_KursM/TrN_KursL,2)     * (100+TrE_Stawka)/100,2) - ROUND(   SUM(TrE_WartoscNetto)    *  TrN_KursM/TrN_KursL , 2 )
    WHEN TrN_TypNB=2 AND TrN_PlatElemWalSys=0 THEN ROUND(SUM(TrE_WartoscBruttoWal) * TrE_Stawka/(100+TrE_Stawka),2)
    WHEN TrN_TypNB=2 AND TrN_PlatElemWalSys=1 THEN ROUND(ROUND(SUM(TrE_WartoscBrutto) * TrN_KursM/TrN_KursL, 2) * TrE_Stawka/(100+TrE_Stawka), 2)
    WHEN TrE_Stawka =0 THEN 0
  END AS VATWal
  FROM CDN.TraElem JOIN CDN.TraNag ON TrN_TrNId=TrE_TrNId
  WHERE TrN_TrNId = @TrN_TrNId
  GROUP BY TrN_TypNB, TrN_KursL, TrN_KursM, TrN_PlatElemWalSys, TrE_Stawka, TrE_Flaga, TrE_Zrodlowa
 ) AS TraVATTmp
JOIN CDN.TraVAT ON TrV_TrNId = TrNId AND TrV_Stawka = Stawka AND TrV_Flaga = Flaga AND TrV_Zrodlowa = Zrodlowa
-- wyłapanie zaokrąglenia
Declare @RazemSum Decimal(15,2), @RazemSumWal Decimal(15,2), @RazemBrutto Decimal(15,2), @RazemBruttoWal Decimal(15,2), @PlatElemWalSys Int, @TrVMinId Int
Select
 @PlatElemWalSys = TrN_PlatElemWalSys,
 @RazemSum       = SUM(TrV_Netto+TrV_Vat),
 @RazemSumWal    = SUM(TrV_NettoWal+TrV_VatWal),
 @RazemBrutto    = SUM(TrV_NettoWal+TrV_VatWal) * TrN_KursL/TrN_KursM,
 @RazemBruttoWal = SUM(TrV_Netto+TrV_Vat) * TrN_KursM/TrN_KursL
From CDN.TraVat Join CDN.TraNag On TrN_TrNId = TrV_TrNId
Where TrN_TrNId = @TrN_TrNId
Group By TrN_PlatElemWalSys, TrN_KursM, TrN_KursL
If @PlatElemWalSys = 0 And @RazemSum <> @RazemBrutto
 Begin
  Select @TrVMinId = Min(TrV_TrVId) From CDN.TraVat Where TrV_TrNId = @TrN_TrNId
  Update CDN.TraVat Set TrV_Netto = TrV_Netto + @RazemBrutto - @RazemSum Where TrV_TrVId = @TrVMinId
 End
If @PlatElemWalSys = 1 And @RazemSumWal <> @RazemBruttoWal
 Begin
  Select @TrVMinId = Min(TrV_TrVId) From CDN.TraVat Where TrV_TrNId = @TrN_TrNId
  Update CDN.TraVat Set TrV_NettoWal = TrV_NettoWal + @RazemBruttoWal - @RazemSumWal Where TrV_TrVId = @TrVMinId
 End
-- update wartości do nagłówka na podstawie tabelki VAT
UPDATE CDN.TraNag SET
  TrN_RazemNetto     = ISNULL(TrV_Netto,0),
  TrN_RazemVAT       = ISNULL(TrV_Vat,0),
  TrN_RazemBrutto    = ISNULL(TrV_Brutto,0),
  TrN_RazemNettoWal  = ISNULL(TrV_NettoWal,0),
  TrN_RazemVATWal    = ISNULL(TrV_VatWal,0),
  TrN_RazemBruttoWal = ISNULL(TrV_BruttoWal,0)
FROM CDN.TraNag LEFT OUTER JOIN
( SELECT
    TrV_TrNId     = TrV_TrNId,
    TrV_Netto     = SUM(TrV_Netto),
    TrV_Vat       = SUM(TrV_Vat),
    TrV_Brutto    = SUM(TrV_Netto + TrV_Vat),
    TrV_NettoWal  = SUM(TrV_NettoWal),
    TrV_VatWal    = SUM(TrV_VatWal),
    TrV_BruttoWal = SUM(TrV_NettoWal + TrV_VatWal)
  FROM CDN.TraVat
  WHERE TrV_TrNId = @TrN_TrNId
  GROUP BY TrV_TrNId
) AS TraVatTmp ON TrN_TrNId = TrV_TrNId
WHERE TrN_TrNId = @TrN_TrNId
SET NOCOUNT OFF
