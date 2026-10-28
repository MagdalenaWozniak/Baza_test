CREATE PROCEDURE [CDN].[Detal_AktualizujTraElem]
 @DSTrEID int ,
 @DSTrNID int ,
 @StanDetalID int,
 @ZwrID int ,
 @TwrID int ,
 @Stawka decimal(5, 2) ,
 @Flaga smallint ,
 @Cena decimal(17, 4) ,
 @Rabat decimal(5, 2) ,
 @CenaPoRabacie decimal(17, 4) ,
 @Kaucja tinyint ,
 @Ilosc decimal(15, 4) ,
 @IloscJM decimal(15, 4) ,
 @Jm nvarchar(20) ,
 @JmCalkowite tinyint ,
 @JMPrzelicznikL  decimal(15, 2)  ,
 @JMPrzelicznikM  decimal(7, 0)  ,
 @WartoscBrutto decimal(15, 2)
AS
SET NOCOUNT ON
DECLARE @DTrE_DTrEId INT
DECLARE @JmZ nvarchar(20)
  SELECT  @DTrE_DTrEId = DTrE_DTrEId
    FROM CDN.DetalTraElem
    WHERE DTrE_DSTrEId = @DSTrEID AND DTre_StanDetalID = @StanDetalID
  SELECT  @JmZ = DSTwr_JM
    FROM CDN.DetalStanTowary
    WHERE DSTwr_OptimaId = @TwrID AND DSTwr_StanDetalID = @StanDetalID
  IF @DTrE_DTrEId IS NULL
    BEGIN
       INSERT INTO CDN.DetalTraElem (
 DTrE_DSTrEID ,
 DTrE_DSTrNID ,
 DTrE_StanDetalID,
 DTrE_ZwrID ,
 DTrE_TwrID ,
 DTrE_Stawka ,
 DTrE_Flaga ,
 DTrE_Cena ,
 DTrE_Rabat ,
 DTrE_CenaPoRabacie ,
 DTrE_Kaucja ,
 DTrE_Ilosc ,
 DTrE_IloscJM,
 DTrE_Jm ,
 DTrE_JmCalkowite ,
 DTrE_JMPrzelicznikL,
 DTrE_JMPrzelicznikM,
 DTrE_JMZ,
 DTrE_WartoscBrutto,
 DTrE_Waluta  )
  VALUES (
 @DSTrEID ,
 @DSTrNID ,
    @StanDetalID ,
 @ZwrID ,
 @TwrID ,
 @Stawka ,
 @Flaga ,
 @Cena ,
 @Rabat ,
 @CenaPoRabacie ,
 @Kaucja ,
 @Ilosc ,
 @IloscJM ,
 @Jm ,
 @JmCalkowite ,
 @JMPrzelicznikL,
 @JMPrzelicznikM,
 @JmZ,
 @WartoscBrutto,
 ''
         )
    END
  SET NOCOUNT OFF
