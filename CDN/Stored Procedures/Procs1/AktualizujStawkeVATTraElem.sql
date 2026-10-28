CREATE PROCEDURE CDN.AktualizujStawkeVATTraElem
  @TreId INT,      -- id elementu
  @TwrId INT,    -- id towaru
  @TrnTypNB tinyint,
  @TrnPlatElemSys tinyint,
  @TrnKursL decimal (15,4),
  @TrnKursM decimal (5,0),
  @TrnRodzaj int
AS
SET NOCOUNT ON
declare
@TwrStawka decimal(15,2),
@TwrFlaga smallint,
@TwrZrodlowa decimal(15, 2),
@WartoscW decimal(15,2),
@Wartosc decimal(15,2)
-- pobieranie stawki
if (CONVERT(INT, @TrnRodzaj/1000) in (301,307,309,322))
select
 @TwrStawka = Twr_StawkaZak,
 @TwrFlaga = Twr_FlagaZak,
 @TwrZrodlowa = Twr_ZrodlowaZak
from CDN.Towary where Twr_TwrId = @TwrId
else
select
 @TwrStawka = Twr_stawka,
 @TwrFlaga = Twr_Flaga,
 @TwrZrodlowa = Twr_Zrodlowa
from CDN.Towary where Twr_TwrId = @TwrId
-- update stawki
update CDN.TraElem set
 TrE_Stawka = @TwrStawka,
 TrE_Flaga = @TwrFlaga,
 TrE_Zrodlowa = @TwrZrodlowa
where TrE_TrEID = @TreId
-- update wartości
select @WartoscW = case when @TrnRodzaj in (302200,302202) then TrE_WartoscBruttoWal else  ROUND(TrE_IloscJM * TrE_CenaWWD, 2) end from CDN.TraElem where TrE_TrEID = @TreId
if (@TrnPlatElemSys > 0)
 select @Wartosc = case when @TrnRodzaj in (302200,302202) then TrE_WartoscBrutto else ROUND(TrE_IloscJM * TrE_CenaT, 2) end from CDN.TraElem where TrE_TrEID = @TreId
else
 set @Wartosc = ROUND(@WartoscW * @TrnKursL/@TrnKursM, 2)
if (@TrnTypNB = 1) -- netto
 update CDN.TraElem set
  TrE_WartoscNetto = @Wartosc,
  TrE_WartoscNettoWal = @WartoscW,
  TrE_WartoscBrutto = ROUND(TrE_WartoscNetto * (100.0+Tre_Stawka)/100.0, 2),
  TrE_WartoscBruttoWal = ROUND(Tre_WartoscNettoWal * (100.0+Tre_Stawka)/100.0, 2)
 where TrE_TrEID = @TreId
else
 update CDN.TraElem set
  TrE_WartoscBrutto = @Wartosc,
  TrE_WartoscBruttoWal = @WartoscW,
  TrE_WartoscNetto = ROUND(TrE_WartoscBrutto - TrE_WartoscBrutto*TrE_Stawka/(100.0+Tre_Stawka), 2),
  TrE_WartoscNettoWal = ROUND(Tre_WartoscBruttoWal - TrE_WartoscBruttoWal*TrE_Stawka/(100.0+Tre_Stawka), 2)
 where TrE_TrEID = @TreId
SET NOCOUNT OFF
