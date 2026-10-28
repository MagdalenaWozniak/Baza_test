CREATE PROCEDURE [CDN].[Mobile_ImportDocumentElement]
@ID int,
@EId int,
@ElemId int,
@ElemLp int,
@DocId int,
@Value decimal(15,2),
@Quantity decimal(15,4),
@VatName NVARCHAR(254),
@VatValue decimal(15,2),
@Discount decimal(15,2),
@StartPrice decimal(15,2),
@Description NVARCHAR(1024),
@BaseUnitName NVARCHAR(20) = '',
@UnitName NVARCHAR(20) = '',
@Nominator decimal(15,2) = 1,
@Denominator decimal(15,2) = 1,
@QuantityUnit decimal(15,2)= 1,
@ReverseCharge tinyint = 0,
@PriceTypeId int = -1
AS
BEGIN
SET NOCOUNT ON
if @Discount < -999.99
   set @Discount = -999.99
if @VatValue = -1
 begin
  set @VatValue = 0
  select @VatValue = isnull(twr_stawka,0) from cdn.towary where twr_twrid = @ElemId
 end
if not exists(select * from cdn.DetalTraElem where DTrE_DSTrEID=@EId and DTrE_DSTrNID = @DocId AND DTre_StanDetalID = @ID)
 INSERT INTO CDN.DetalTraElem (
 DTrE_DSTrEID ,
 DTrE_DSTrNID ,
 DTrE_StanDetalID,
 DTrE_TwrID ,
 DTrE_Stawka ,
 DTrE_Flaga ,
 DTrE_Cena ,
 DTrE_Rabat ,
 DTrE_CenaPoRabacie ,
 DTrE_Kaucja ,
 DTrE_Ilosc ,
 DTrE_Jm ,
 DTrE_JmCalkowite ,
 DTrE_WartoscBrutto,
 DTrE_Waluta,
 DTre_Opis,
 DTrE_JMZ,
 DTrE_JMPrzelicznikM,
 DTrE_JMPrzelicznikL ,
 DTrE_IloscJM,
 DTrE_OdwrotneObciazenie,
 DTre_TwCNumer )
  VALUES (
 @EId ,--
 @DocId ,--
 @ID ,--
 @ElemId ,--
 @VatValue ,
 case when @ReverseCharge = 1 and @VatValue = 0 then  4 else 2 end ,
 @StartPrice,
 @Discount ,
 0,
 0,--
 @Quantity ,--
 @BaseUnitName ,
 '' ,
 @Value ,
 '',
 @Description,
 @UnitName,
 @Nominator,
 @Denominator,
round(@Quantity*@Nominator/@Denominator,4),
@ReverseCharge,
@PriceTypeId
         )
SET NOCOUNT OFF
END
