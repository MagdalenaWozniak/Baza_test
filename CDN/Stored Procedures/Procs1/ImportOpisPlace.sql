create procedure cdn.ImportOpisPlace
@Opp_WpEID int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Pra_ImportRowID nvarchar(36),
@Pra_Kod varchar(20),
@Dzl_ImportRowID nvarchar(36),
@Dzl_AdresWezla nvarchar(512),
@Prj_ImportRowID nvarchar(36),
@Prj_Kod varchar(40),
@Opp_Procent decimal(15, 4)  ,
@Opp_Brutto decimal(15, 2)  ,
@Opp_ZUSF decimal(15, 2)  ,
@Opp_ZUSP decimal(15, 2)  ,
@Opp_Zdrow decimal(15, 2)  ,
@Opp_ZalFIS decimal(15, 2)  ,
@Opp_PPKP decimal(15, 2)  ,
@Opp_PPKF decimal(15, 2)  ,
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int output,
@Warnings nvarchar(1000) output
as
 begin
  DECLARE @PraID INT
  SET @PraID = NULL
  IF @Pra_ImportRowID Is NOT Null
   SELECT @PraID = Pra_PraID FROM CDN.PracKod WHERE Pra_ImportRowId = @Pra_ImportRowID
  IF @PraID is Null
   SELECT @PraID = Pra_PraID FROM CDN.PracKod WHERE Pra_Kod = @Pra_Kod
  IF @PraID is Null
  BEGIN
   RAISERROR('##OPT33109##', 16, 1) --RAISERROR('Brak zadanego pracownika w bazie dla opisu wypłaty.', 16, 1)
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
   RAISERROR('##OPT33110##', 16, 1) --RAISERROR('Brak zadanego wydziału w bazie dla opisu wypłaty.', 16, 1)
   RETURN
  END
  DECLARE @PrjID INT
  SET @PrjID = NULL
  IF @Prj_ImportRowID Is NOT Null
   SELECT @PrjID = Prj_PrjID FROM CDN.DefProjekty WHERE Prj_ImportRowId = @Prj_ImportRowID
  IF @PrjID is Null
   SELECT @PrjID = Prj_PrjID FROM CDN.DefProjekty WHERE Prj_Kod = @Prj_Kod
  IF @PrjID is Null
  BEGIN
   RAISERROR('##OPT33111##', 16, 1) --RAISERROR('Brak zadanego projektu w bazie dla opisu wypłaty.', 16, 1)
   RETURN
  END
  insert into cdn.OpisPlace
  (
   OPP_WpEID,
   OPP_PraID,
   OPP_DzlID,
   OPP_PrjID,
   OPP_Procent,
   OPP_Brutto,
   OPP_ZUSF,
   OPP_ZUSP,
   OPP_Zdrow,
   OPP_ZalFIS,
   OPP_PPKP,
   OPP_PPKF
  )
  values
  (
   @Opp_WpEID,
   @PraID,
   @DzlID,
   @PrjID,
   @Opp_Procent,
   @Opp_Brutto,
   @Opp_ZUSF,
   @Opp_ZUSP,
   @Opp_Zdrow,
   @Opp_ZalFIS,
   IsNull(@Opp_PPKP, 0),
   IsNull(@Opp_PPKF, 0)
  )
  select @IdParam = SCOPE_IDENTITY()
 end
