CREATE PROCEDURE [CDN].[DetalStan_DodajZmiane]
@PosId int,
@OpeIdOtw int,
@DataOtw datetime
AS
BEGIN
SET NOCOUNT ON
DECLARE @StanKasy decimal(15,2)
DECLARE @NrNumer int
SET @NrNumer = 0
SET @StanKasy = 0.0
SELECT @NrNumer = ISNULL(MAX(DSZ_NumerNr),0)+1 FROM CDN.DetalStanZmiany WHERE
DSZ_StanDetalID = @PosId AND DSZ_Bufor = 0 AND
convert(NVARCHAR(4), DSZ_DataOtw,120) = convert(NVARCHAR(4), @DataOtw,120)
SELECT @StanKasy =  ISNULL(DSZ_StanKasy,convert(decimal(15,2),0)) +
     ISNULL(DSZ_KwotaZPrzeniesienia,convert(decimal(15,2),0)) +
     ISNULL(DSZ_KPOtw,convert(decimal(15,2),0)) -
     ISNULL(DSZ_KWZamk,convert(decimal(15,2),0)) FROM CDN.DetalStanZmiany
 WHERE DSZ_StanDetalID = @PosId AND DSZ_Bufor = 0 AND DSZ_DSZID =
 (SELECT ISNULL(MAX(DSZ_DSZID),1) FROM CDN.DetalStanZmiany
  WHERE DSZ_StanDetalID = @PosId AND DSZ_Bufor = 0)
 INSERT INTO CDN.DetalStanZmiany (
    [DSZ_StanDetalID]
      ,[DSZ_NumerNr]
      ,[DSZ_NumerPelny]
      ,[DSZ_OpeIdOtw]
      ,[DSZ_OpeIdZamk]
      ,[DSZ_Bufor]
      ,[DSZ_DataOtw]
      ,[DSZ_DataZamk]
      ,[DSZ_IloscAnulowanychParagonow]
      ,[DSZ_StanKasy]
      ,[DSZ_KPOtw]
      ,[DSZ_KWZamk]
      ,[DSZ_KwotaZPrzeniesienia])
VALUES (@PosId,
  @NrNumer,
  convert(NVARCHAR(10), @NrNumer) + '/' + convert(NVARCHAR(4), @DataOtw,120),
  @OpeIdOtw,
  0,
  1,
  @DataOtw,
  '1901-01-01',
  0,
  0.0,
  0.0,
  0.0,
  @StanKasy)
SET NOCOUNT OFF
END
