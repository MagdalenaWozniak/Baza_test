CREATE PROCEDURE CDN.ESLKEP_ImportTrNZgody
  @JezykID         int,
  @DataChr         varchar(50),
  @IP              nvarchar(50),
  @VerIDChr        nvarchar(50),
  @Stan            int,
  @GIDNumer        int,
  @IDEsklep        int,
  @kanal1          nvarchar(50),
  @kanal2          nvarchar(50),
  @kanal3          nvarchar(50),
  @kanal4          nvarchar(50),
  @OpeZalIDChr     nvarchar(11),
  @StaZalIdChr     nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
  @TrN_TrNId             INT,
  @ESSID                 INT,
  @VerID                 UNIQUEIDENTIFIER,
  @TrescZgodyId          INT,
  @EMAIL                 tinyint,
  @SMS                   tinyint,
  @Telefon               tinyint,
  @List                  tinyint,
  @kanalid               int,
  @Data                  datetime,
  @OpeZalID              INT,
  @StaZalId              INT,
  @ZrodloID              INT,
  @Akronim               NVARCHAR(50),
  @ImieNazwisko          NVARCHAR(200),
  @ZgodaId               INT
  SELECT
    @OpeZalID          = CONVERT(INT,@OpeZalIDChr),
    @StaZalId          = CONVERT(INT,@StaZalIdChr)
  SELECT
    @EMAIL             = 0,
    @SMS               = 0,
    @Telefon           = 0,
    @List              = 0
  declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeZalID, @OpeZalKod OUT, @OpeZalNazwisko OUT
 if (@kanal1 != '0')
 begin
  select @kanalid = 0
  SELECT @kanalid = RZFK_RZFKId
  FROM Cdn.RejestracjaZgodFormyKontaktu
  WHERE RZFK_Guid = CONVERT(UNIQUEIDENTIFIER,@kanal1)
  if @kanalid = 1
  set @EMAIL = 1
  if @kanalid = 2
  set @SMS = 1
  if @kanalid = 3
  set @Telefon = 1
  if @kanalid = 4
  set @List = 1
 end
 if (@kanal2 != '0')
 begin
  select @kanalid = 0
  SELECT @kanalid = RZFK_RZFKId
  FROM Cdn.RejestracjaZgodFormyKontaktu
  WHERE RZFK_Guid = CONVERT(UNIQUEIDENTIFIER,@kanal2)
  if @kanalid = 1
  set @EMAIL = 1
  if @kanalid = 2
  set @SMS = 1
  if @kanalid = 3
  set @Telefon = 1
  if @kanalid = 4
  set @List = 1
 end
 if (@kanal3 != '0')
 begin
  select @kanalid = 0
  SELECT @kanalid = RZFK_RZFKId
  FROM Cdn.RejestracjaZgodFormyKontaktu
  WHERE RZFK_Guid = CONVERT(UNIQUEIDENTIFIER,@kanal3)
  if @kanalid = 1
  set @EMAIL = 1
  if @kanalid = 2
  set @SMS = 1
  if @kanalid = 3
  set @Telefon = 1
  if @kanalid = 4
  set @List = 1
 end
 if (@kanal4 != '0')
 begin
  select @kanalid = 0
  SELECT @kanalid = RZFK_RZFKId
  FROM Cdn.RejestracjaZgodFormyKontaktu
  WHERE RZFK_Guid = CONVERT(UNIQUEIDENTIFIER,@kanal4)
  if @kanalid = 1
  set @EMAIL = 1
  if @kanalid = 2
  set @SMS = 1
  if @kanalid = 3
  set @Telefon = 1
  if @kanalid = 4
  set @List = 1
 end
 SELECT @ESSID = ESS_ESSID from cdn.eSklepStanowiska where ESS_IdISklep = @IDEsklep
 set @TrN_TrNId =0
 SELECT @TrN_TrNId = TrN_TrNID
    FROM Cdn.TraNag
    WHERE TrN_GIDNumer =  @GIDNumer AND TrN_eSklepID = @ESSID
 if @TrN_TrNId = 0
  return
 select @VerID             = CONVERT(UNIQUEIDENTIFIER,@VerIDChr),
        @Data              = CONVERT(datetime,replace(@DataChr,'T',' '),120)
 SELECT @TrescZgodyId = RZT_RZTID
    FROM Cdn.RejestracjaZgodTresc
    WHERE RZT_GuidVer = @VerID
 if not exists (select * from CDN.RejestracjaZgodZrodlo where RZZ_Nazwa=  'Comarch e-Sklep')
    INSERT INTO [CDN].[RejestracjaZgodZrodlo]
           ([RZZ_Nazwa]
           ,[RZZ_Nieaktywny]
           ,[RZZ_OpeZalId]
           ,[RZZ_StaZalId]
           ,[RZZ_TS_Zal]
           ,[RZZ_OpeModId]
           ,[RZZ_StaModId]
           ,[RZZ_TS_Mod]
           ,[RZZ_OpeModKod]
           ,[RZZ_OpeModNazwisko]
           ,[RZZ_OpeZalKod]
           ,[RZZ_OpeZalNazwisko])
     VALUES
           ('Comarch e-Sklep'
           ,0
     ,@OpeZalID
           ,@StaZalId
           ,GETDATE()
           ,@OpeZalID
           ,@StaZalId
           ,GETDATE()
           ,@OpeZalKod
           ,@OpeZalNazwisko
           ,@OpeZalKod
           ,@OpeZalNazwisko)
   select @ZrodloID = RZZ_RZZId from CDN.RejestracjaZgodZrodlo where RZZ_Nazwa=  'Comarch e-Sklep'
   if not exists (select * from CDN.PodmiotRejestracjaZgod where PRZ_TrNId = @TrN_TrNID and  PRZ_TrescZgodyId = @TrescZgodyId)
     INSERT INTO [CDN].[PodmiotRejestracjaZgod]
           ([PRZ_PodmiotId]
           ,[PRZ_PodmiotTyp]
           ,[PRZ_PrzedstawicielId]
           ,[PRZ_TrescZgodyId]
           ,[PRZ_EMAIL]
           ,[PRZ_SMS]
           ,[PRZ_Telefon]
           ,[PRZ_List]
           ,[PRZ_DataWyrazenia]
           ,[PRZ_ZrodloPozyskaniaId]
           ,[PRZ_IPWyrazenia]
           ,[PRZ_DataWycofania]
           ,[PRZ_ZrodloWycofaniaId]
           ,[PRZ_IPWycofania]
           ,[PRZ_PowodWycofania]
           ,[PRZ_Akronim]
           ,[PRZ_ImieNazwisko]
           ,[PRZ_JezykId]
     ,[PRZ_WyrazenieESklepId]
     ,[PRZ_WycofanieESklepId]
     ,[PRZ_TrNId])
     VALUES
           (0
           ,0
           ,0
           ,@TrescZgodyId
           ,@EMAIL
           ,@SMS
           ,@Telefon
           ,@List
           ,@Data
           ,@ZrodloID
           ,@IP
           ,NULL
           ,0
     ,''
           ,''
           ,''
           ,''
           ,@JezykID
     ,@ESSID
     ,0
     ,@TrN_TrNId)
SET NOCOUNT OFF
