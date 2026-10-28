create procedure cdn.ImportWypSkladniki
@Wps_WpEId int  ,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Pra_ImportRowID nvarchar(36),
@Pra_Kod varchar(20),
@Dzl_ImportRowID nvarchar(36),
@Dzl_AdresWezla nvarchar(512),
-- @Wps_PnbId int , - nie importujemy nieobecności
@TWp_ImportRowID nvarchar(36),
@TWp_Nazwa varchar(40),
@Wps_Nazwa nvarchar(128)  ,
@Wps_Podstawa decimal(15, 2) ,
@Wps_Wartosc decimal(15, 2)  ,
@Wps_WartoscWal decimal(15, 2)  ,
@Wps_Wartosc1 decimal(15, 2)  ,
@Wps_Wartosc2 decimal(15, 2)  ,
@Wps_DataOd nvarchar(10),
@Wps_DataDo nvarchar(10),
@Wps_DataDanych nvarchar(10),
@Wps_OkresDni int  ,
@Wps_OkresCzas int,
@Wps_Godziny int,
--@Wps_RodzajZrodla int ,
--@Wps_ZrodloId int ,
@Wps_EkwiwalentIlosc decimal(15, 2)  ,
@Wps_Procent decimal(15, 2)  ,
@Wps_Splacono decimal(15, 2)  ,
@Wps_SplaconoAll tinyint  ,
@Wps_Zaliczka int ,
--@Wps_DstId int ,
--@Wps_HrmId int ,
@Wps_Archiwalny tinyint  ,
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int output,
@Warnings nvarchar(1000) output
as
 begin
declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
  DECLARE @PraID INT
  SET @PraID = NULL
  IF @Pra_ImportRowID Is NOT Null
   SELECT @PraID = Pra_PraID FROM CDN.PracKod WHERE Pra_ImportRowId = @Pra_ImportRowID
  IF @PraID is Null
   SELECT @PraID = Pra_PraID FROM CDN.PracKod WHERE Pra_Kod = @Pra_Kod
  IF @PraID is Null
  BEGIN
   RAISERROR('##OPT33105##', 16, 1) --RAISERROR('Brak zadanego pracownika w bazie dla składnika wypłaty.', 16, 1)
   RETURN
  END
  DECLARE @DzlID INT
  SET @DzlID = NULL
  IF @Dzl_ImportRowID Is NOT Null
   SELECT @DzlID = Dzl_DzlID FROM CDN.Dzialy WHERE Dzl_ImportRowId = @Dzl_ImportRowID
  IF @DzlID is Null
   SELECT @DzlID = Dzl_DzlID FROM CDN.Dzialy WHERE Dzl_AdresWezla = @Dzl_AdresWezla
  IF @DzlID is Null
  BEGIN
   RAISERROR('##OPT33106##', 16, 1) --RAISERROR('Brak zadanego wydziału w bazie dla składnika wypłaty.', 16, 1)
   RETURN
  END
  DECLARE @TWpID INT
  SET @TWpID = NULL
  IF @TWp_ImportRowID Is NOT Null
   SELECT @TWpID = TWp_TWpID FROM CDN.TypWyplata WHERE TWp_ImportRowId = @TWp_ImportRowID
  IF @TWpID is Null
   SELECT @TWpID = TWp_TWpID FROM CDN.TypWyplata WHERE TWp_Nazwa = @TWp_Nazwa
  IF @TWpID is Null
  BEGIN
   RAISERROR('##OPT33107##', 16, 1) --RAISERROR('Brak zadanego typu wypłaty w bazie dla składnika wypłaty.', 16, 1)
   RETURN
  END
  DECLARE @WplID INT
  SET @WplID = NULL
  IF(@Wps_WpEID is not NULL)
   SELECT @WplID = WpE_WplID FROM CDN.WypElementy WHERE WpE_WpEID = @Wps_WpEID
  IF(@WplID is NULL)
  BEGIN
   RAISERROR('##OPT33108##', 16, 1) --RAISERROR('Brak zadanej wypłaty w bazie dla składnika wypłaty.', 16, 1)
   RETURN
  END
    DECLARE @WpS_DataOdDT DATETIME
    SET @WpS_DataOdDT = CONVERT(DATETIME, @WpS_DataOd, 120)
    DECLARE @WpS_DataDoDT DATETIME
    SET @WpS_DataDoDT = CONVERT(DATETIME, @WpS_DataDo, 120)
    DECLARE @WpS_DataDanychDT DATETIME
    SET @WpS_DataDanychDT = CONVERT(DATETIME, @WpS_DataDanych, 120)
    DECLARE @WpS_OkresCzasDT DATETIME
    --SET @WpS_OkresCzasDT = CONVERT(DATETIME, @WpS_OkresCzas, 120)
    SET @WpS_OkresCzasDT = cdn.Minutes2DateTime(@Wps_OkresCzas)
    DECLARE @WpS_GodzinyDT DATETIME
    --SET @WpS_GodzinyDT = CONVERT(DATETIME, @WpS_Godziny, 120)
    SET @WpS_GodzinyDT = cdn.Minutes2DateTime(@WpS_Godziny)
    insert into cdn.WypSkladniki
  (
   WPS_WplID   ,
   WPS_WpEID,
   WPS_PraID   ,
   WPS_DzlID   ,
   --WPS_PnbID  ,
   WPS_TwpID   ,
   WPS_Nazwa ,
   WPS_Podstawa  ,
   WPS_Wartosc   ,
   WPS_WartoscWal   ,
   WPS_Wartosc1   ,
   WPS_Wartosc2   ,
   WPS_DataOd  ,
   WPS_DataDo  ,
   WPS_DataDanych   ,
   WPS_OkresDni   ,
   WPS_OkresCzas   ,
   WPS_Godziny   ,
   WPS_RodzajZrodla  ,
   WPS_ZrodloId  ,
   WPS_EkwiwalentIlosc   ,
   WPS_Procent   ,
   WPS_Splacono   ,
   WPS_SplaconoAll   ,
   WPS_Zaliczka  ,
   --WPS_DstId  ,
   --WPS_HrmId  ,
   WPS_Archiwalny   ,
   WPS_OpeZalId  ,
   WPS_OpeZalKod,
   WPS_OpeZalNazwisko,
   WPS_TS_Zal   ,
   WPS_OpeModId  ,
   WPS_OpeModKod,
   WPS_OpeModNazwisko,
   WPS_TS_Mod
  )
  values
  (
   @WplID   ,
   @Wps_WpEId   ,
   @PraID   ,
   @DzlID   ,
   --@Wps_PnbId  ,
   @TWpID   ,
   @Wps_Nazwa ,
   @Wps_Podstawa  ,
   @Wps_Wartosc   ,
   @Wps_WartoscWal   ,
   @Wps_Wartosc1   ,
   @Wps_Wartosc2   ,
      @Wps_DataOdDT  ,
      @Wps_DataDoDT  ,
      @Wps_DataDanychDT   ,
   @Wps_OkresDni   ,
      @Wps_OkresCzasDT   ,
      @Wps_GodzinyDT   ,
   9, --@Wps_RodzajZrodla  ,
   @Wps_WpEID, --@Wps_ZrodloId  ,
   @Wps_EkwiwalentIlosc   ,
   @Wps_Procent   ,
   @Wps_Splacono   ,
   @Wps_SplaconoAll   ,
   @Wps_Zaliczka  ,
   --@Wps_DstId  ,
   --@Wps_HrmId  ,
   @Wps_Archiwalny   ,
   @OpeId  ,
   @OpeModKod,
   @OpeModNazwisko,
   getdate()  ,
   @OpeId  ,
   @OpeModKod,
   @OpeModNazwisko,
   getdate()
  )
  select @IdParam = SCOPE_IDENTITY()
 end
