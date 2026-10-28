CREATE PROCEDURE [CDN].[DetalStan_ObliczTraVAT]
 @DSTrN_DSTrNId INT
AS
-- update tabelki VAT w zależności od:
--   - typu dokumentu netto/brutto
--   - rodzaju liczenia płatności (od wartości walutowej, od wartości PLN )
SET NOCOUNT ON
CREATE TABLE #TraVat(
 [TrV_TrNID] [int] NOT NULL,
 [TrV_Stawka] [decimal](5, 2) NOT NULL,
 [TrV_Flaga] [smallint] NOT NULL,
 [TrV_Netto] [decimal](15, 2) NOT NULL,
 [TrV_VAT] [decimal](15, 2) NOT NULL,
 [TrV_Brutto] [decimal](15, 2) NOT NULL)
INSERT INTO #TraVat ( TrV_TrNId, TrV_Stawka, TrV_Flaga,  TrV_Netto, TrV_VAT, TrV_Brutto )
  SELECT                @DSTrN_DSTrNId, DSTrE_Stawka, DSTrE_Flaga,          0,       0,            0
    FROM CDN.DetalStanTraElem
    WHERE DSTrE_DSTrNId = @DSTrN_DSTrNId
    GROUP BY DSTrE_Stawka, DSTrE_Flaga
UPDATE #TraVat SET
  TrV_Netto    = Netto,
  TrV_VAT      = VAT,
  TrV_Brutto   = Brutto
FROM
( SELECT
  @DSTrN_DSTrNId   AS TrNId,
  DSTrE_Stawka   AS Stawka,
  DSTrE_Flaga    AS Flaga,
  SUM(DSTrE_WartoscBrutto)    - ROUND(SUM(DSTrE_WartoscBrutto)    * DSTrE_Stawka / (100+DSTrE_Stawka),2) AS Netto,
  ROUND(SUM(DSTrE_WartoscBrutto)    * DSTrE_Stawka/(100+DSTrE_Stawka),2) AS VAT,
  SUM(DSTrE_WartoscBrutto) AS Brutto
  FROM CDN.DetalStanTraElem
  WHERE DSTrE_DSTrNId = @DSTrN_DSTrNId
  GROUP BY DSTrE_Stawka, DSTrE_Flaga
 ) AS TraVATTmp
JOIN #TraVAT ON TrV_TrNId = TrNId AND TrV_Stawka = Stawka AND TrV_Flaga = Flaga
select * from #TraVat
drop table #TraVat
SET NOCOUNT OFF
