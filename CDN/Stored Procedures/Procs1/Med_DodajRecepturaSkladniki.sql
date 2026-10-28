CREATE PROCEDURE [CDN].[Med_DodajRecepturaSkladniki]
 @OptimaId int ,   -- Id w optimie jeli nowy 0
 @PdRID    int ,   -- Id receptury w optimie
 @PdS_TwrId    int ,   -- Id towaru który jest składnikiem
 @PdS_MagId   int ,   -- Id magazynu w optimie
 @PdS_Ilosc decimal(15,2), -- ilość towaru
 @PdS_JM NVARCHAR(20),  -- nazwa jednostki miary towaru
 @CzySkasowac tinyint
AS
SET NOCOUNT ON
declare
@PdS_PdSID int,
@ProdId int,
@JMCalkowite tinyint,
@JMPrzelicznikL decimal(15,2),
@JMPrzelicznikM decimal(7,0)
if not exists (select * from cdn.ProdReceptury where PdR_PdRId = @PdRID)
BEGIN
     RAISERROR( 'Taka receptura nie istnieje', 16, 1)
     RETURN
    END
else
 select @ProdId = PdR_TwrId from cdn.ProdReceptury where PdR_PdRId = @PdRID
if not exists(select * from cdn.Towary where Twr_TwrId = @PdS_TwrId and Twr_JM = @PdS_JM )
begin
 if not exists(select * from cdn.TwrJMZ where TwJZ_TwrID = @PdS_TwrId and TwJZ_JM = @PdS_JM )
 BEGIN
     RAISERROR( 'Taka jednostka nie istnieje na towarze', 16, 1)
     RETURN
 END
 else
 BEGIN
 select @JMCalkowite = Twr_JMCalkowite,@JMPrzelicznikL =1,@JMPrzelicznikM =1 from cdn.Towary where Twr_TwrId = @PdS_TwrId
 select @JMPrzelicznikL =TwJZ_JMPrzelicznikL,@JMPrzelicznikM =TwJZ_JMPrzelicznikM from cdn.TwrJMZ where TwJZ_TwrID = @PdS_TwrId and TwJZ_JM = @PdS_JM
 END
end
else
begin
select @JMCalkowite = Twr_JMCalkowite,@JMPrzelicznikL =1,@JMPrzelicznikM =1 from cdn.Towary where Twr_TwrId = @PdS_TwrId
end
if @OptimaId = 0
 BEGIN
INSERT INTO CDN.ProdSkladniki
           (PdS_PdRId
           ,PdS_ProdId
           ,PdS_TwrId
           ,PdS_MagId
           ,PdS_Ilosc
           ,PdS_Jm
           ,PdS_JMCalkowite
           ,PdS_JMPrzelicznikL
           ,PdS_JMPrzelicznikM
           ,PdS_IloscJM)
     VALUES
           (@PdRID
           ,@ProdId
           ,@PdS_TwrId
           ,@PdS_MagId
           ,round(@PdS_Ilosc *@JMPrzelicznikL/@JMPrzelicznikM,4)
           ,@PdS_JM
           ,@JMCalkowite
           ,@JMPrzelicznikL
           ,@JMPrzelicznikM
           ,case when @JMCalkowite = 1 then ROUND(@PdS_Ilosc,0) else  @PdS_Ilosc end )
           select @PdS_PdSID = SCOPE_IDENTITY()
end
else
BEGIN
    select @PdS_PdSID = @OptimaId
    if @CzySkasowac = 1
  delete from CDN.ProdSkladniki where PdS_PdSID = @OptimaId
    else
   UPDATE CDN.ProdSkladniki
    SET PdS_PdRId = @PdRID
    ,PdS_ProdId = @ProdId
    ,PdS_TwrId = @PdS_TwrId
    ,PdS_MagId = @PdS_MagId
    ,PdS_Ilosc = round(@PdS_Ilosc *@JMPrzelicznikL/@JMPrzelicznikM,4)
    ,PdS_Jm = @PdS_JM
    ,PdS_JMCalkowite = @JMCalkowite
    ,PdS_JMPrzelicznikL = @JMPrzelicznikL
    ,PdS_JMPrzelicznikM = @JMPrzelicznikM
    ,PdS_IloscJM = case when @JMCalkowite = 1 then ROUND(@PdS_Ilosc,0) else  @PdS_Ilosc end
    WHERE PdS_PdSId = @OptimaId
 END
select  @PdS_PdSID
  SET NOCOUNT OFF
