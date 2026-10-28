CREATE PROCEDURE  CDN.Med_DodajRecepture
 @OptimaId int ,   -- Id w optimie jeli nowy 0
 @TwrID    int ,   -- Id towaru w optimie
 @PdR_Kod NVARCHAR(20), -- Kod receptury
 @PdR_Nazwa NVARCHAR(50), -- Nazwa receptury
 @PdR_Domyslna tinyint, -- czy receptura domyślna
 @PdR_Ilosc decimal(15,2), -- ilość usługi
 @PdR_JM NVARCHAR(20),  -- nazwa jednostki miary usługi
 @Twr_Opis NVARCHAR(254)  -- opis
AS
SET NOCOUNT ON
declare
@PdR_PdRID int
if not exists(select * from cdn.Towary where Twr_TwrId = @TwrID and Twr_JM = @PdR_JM )
 if not exists(select * from cdn.TwrJMZ where TwJZ_TwrID = @TwrID and TwJZ_JM = @PdR_JM )
 BEGIN
     RAISERROR( 'Taka jednostka nie istnieje na towarze', 16, 1)
     RETURN
    END
if @OptimaId = 0
 BEGIN
    if exists (SELECT   *    FROM CDN.ProdReceptury    WHERE PdR_Kod = @PdR_Kod and PdR_TwrId = @TwrID)
    BEGIN
     RAISERROR( 'Taki symbol receptury już istnieje', 16, 1)
     RETURN
    END
INSERT INTO CDN.ProdReceptury
           (PdR_TwrId
           ,PdR_Kod
           ,PdR_Nazwa
           ,PdR_Domyslna
           ,PdR_Ilosc
           ,PdR_JM
           ,PdR_Opis
           ,PdR_OpeZalID
           ,PdR_StaZalId
           ,PdR_TS_Zal
           ,PdR_OpeModID
           ,PdR_StaModId
           ,PdR_TS_Mod)
     VALUES
           (@TwrID
           ,@PdR_Kod
           ,@PdR_Nazwa
           ,@PdR_Domyslna
           ,@PdR_Ilosc
           ,@PdR_JM
           ,@Twr_Opis
           ,NULL
           ,NULL
           ,GETDATE()
           ,NULL
           ,NULL
           ,GETDATE())
           select @PdR_PdRID = PdR_PdRID from cdn.ProdReceptury where PdR_Kod = @PdR_Kod and PdR_TwrId = @TwrID
end
else
BEGIN
    select @PdR_PdRID = @OptimaId
   UPDATE CDN.ProdReceptury
   SET PdR_TwrId = @TwrID
      ,PdR_Kod = @PdR_Kod
      ,PdR_Nazwa = @PdR_Nazwa
      ,PdR_Domyslna = @PdR_Domyslna
      ,PdR_Ilosc = @PdR_Ilosc
      ,PdR_JM = @PdR_JM
      ,PdR_Opis = @Twr_Opis
      WHERE PdR_PdRID = @OptimaId
 END
if @PdR_Domyslna = 1
   update  cdn.ProdReceptury set PdR_Domyslna = 0 where PdR_TwrId = @TwrID and PdR_PdRId != @PdR_PdRID
select  @PdR_PdRID
  SET NOCOUNT OFF
