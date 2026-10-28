CREATE PROCEDURE [CDN].[DetalStan_PobierzStatystykiZmianyDlaOperatora]
@IdZmiany int,
@opeId int
AS
BEGIN
SET NOCOUNT ON
CREATE TABLE #TmpTable
(
 iloscParagonow int,
 iloscStornoPozycji int,
 kaucjePrzyjete decimal(15, 2),
 kaucjeWydane decimal(15, 2),
 wplaty decimal(15, 2),
 wyplaty decimal(15, 2),
 wartoscTowarowNaParagonach decimal(15,2)
)
DECLARE @ilParag int
DECLARE @ilStornoPoz int
DECLARE @kaucjePrzyjete decimal(15, 2)
DECLARE @kaucjeWydane decimal(15, 2)
DECLARE @wplaty decimal(15, 2)
DECLARE @wyplaty decimal(15, 2)
DECLARE @wartoscTowarowNaParagonach decimal(15, 2)
SET @ilParag = 0
SET @ilStornoPoz = 0
SET @kaucjePrzyjete = 0.0
SET @kaucjeWydane = 0.0
SET @wplaty = 0.0
SET @wyplaty = 0.0
SELECT @ilParag = ISNULL(COUNT(DSTrN_DSTrNID),0) FROM CDN.DetalStanTraNag
 WHERE DSTrN_ZmianaId = @IdZmiany AND
  DSTrN_TypDokumentu = 305 AND
  ISNULL(DSTrN_Korekta, 0) = 0 AND
  DSTrN_Bufor = 0 AND
  DSTrN_OpeID = @opeId
SELECT @ilStornoPoz = ISNULL(COUNT(b.DSTrE_DSTrEID),0) FROM CDN.DetalStanTraElem b
inner join CDN.DetalStanTraNag a ON a.DSTrN_DSTrNID = b.DSTrE_DSTrNId
 WHERE a.DSTrN_ZmianaId = @IdZmiany AND
 a.DSTrN_TypDokumentu = 305 AND
 a.DSTrN_Bufor = 0 AND
 b.DSTrE_StornoId <> 0 AND
 b.DSTrE_Ilosc < 0 AND
 a.DSTrN_OpeID = @opeId
SELECT @kaucjePrzyjete = ISNULL(SUM(b.DSTrE_WartoscBrutto),convert(decimal(15,2),0)) FROM CDN.DetalStanTraElem b
inner join CDN.DetalStanTraNag a ON a.DSTrN_DSTrNID = b.DSTrE_DSTrNId
 WHERE a.DSTrN_ZmianaId = @IdZmiany AND
 a.DSTrN_TypDokumentu = 313 AND
 a.DSTrN_Bufor = 0 AND
 a.DSTrN_OpeID = @opeId
SELECT @kaucjeWydane = ISNULL(SUM(b.DSTrE_WartoscBrutto),convert(decimal(15,2),0)) FROM CDN.DetalStanTraElem b
inner join CDN.DetalStanTraNag a ON a.DSTrN_DSTrNID = b.DSTrE_DSTrNId
 WHERE a.DSTrN_ZmianaId = @IdZmiany AND
 a.DSTrN_TypDokumentu = 305 AND
 a.DSTrN_Bufor = 0 AND
 b.DSTrE_Kaucja = 1 AND
 a.DSTrN_OpeID = @opeId
SELECT @wplaty = ISNULL(SUM(DSZKB_RazemBrutto),convert(decimal(15,2),0)) FROM CDN.DetalStanZapisyKB
 WHERE DSZKB_ZmianaId = @IdZmiany AND
 DSZKB_TypDokumentu = 1 AND
 DSZKB_Bufor = 0 AND
 DSZKB_Opis <> 'Wpłata przy rozpoczęciu zmiany' AND
 DSZKB_OpeID = @opeId
SELECT @wyplaty = ISNULL(SUM(DSZKB_RazemBrutto),convert(decimal(15,2),0)) FROM CDN.DetalStanZapisyKB
 WHERE DSZKB_ZmianaId = @IdZmiany AND
 DSZKB_TypDokumentu = 2 AND
 DSZKB_Bufor = 0 AND
 DSZKB_Opis <> 'Wypłata przy zakończeniu zmiany' AND
 DSZKB_OpeID = @opeId
SELECT @wartoscTowarowNaParagonach =
ISNULL(SUM(b.DSTrE_WartoscBrutto),convert(decimal(15,2),0)) FROM CDN.DetalStanTraElem b
inner join CDN.DetalStanTraNag a ON a.DSTrN_DSTrNID = b.DSTrE_DSTrNId
 WHERE a.DSTrN_ZmianaId = @IdZmiany AND
 (a.DSTrN_TypDokumentu = 305 OR a.DSTrN_TypDokumentu = 302 AND ISNULL(a.DSTrN_Korekta,0) = 1) AND
 a.DSTrN_Bufor = 0 AND
 b.DSTrE_Kaucja = 0 AND
 a.DSTrN_OpeID = @opeId
INSERT INTO #TmpTable(iloscParagonow,
     iloscStornoPozycji,
     kaucjePrzyjete,
     kaucjeWydane,
     wplaty,
     wyplaty,
     wartoscTowarowNaParagonach)
VALUES (@ilParag,
  @ilStornoPoz,
  @kaucjePrzyjete,
  @kaucjeWydane,
  @wplaty,
  @wyplaty,
  @wartoscTowarowNaParagonach)
Select * FROM #TmpTable
SET NOCOUNT OFF
END
