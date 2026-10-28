CREATE PROCEDURE [CDN].[ESLKEP_ImportKntZgody]
  @JezykID         int,
  @DataChr         varchar(50),
  @IP              nvarchar(50),
  @VerIDChr        nvarchar(50),
  @Stan            int,
  @LoginESklepID   int,
  @KntIDEsklep     int,
  @IDEsklep        int,
  @kanal1          nvarchar(50),
  @kanal2          nvarchar(50),
  @kanal3          nvarchar(50),
  @kanal4          nvarchar(50),
  @kanal1Stan      tinyint,
  @kanal2Stan      tinyint,
  @kanal3Stan      tinyint,
  @kanal4Stan      tinyint,
  @OpeZalIDChr     nvarchar(11),
  @StaZalIdChr     nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
  @Knt_KntId             INT,
  @PrzedstawicielID      INT,
  @ESSID                 INT,
  @VerID                 UNIQUEIDENTIFIER,
  @TrescZgodyId          INT,
  @EMAIL                 tinyint,
  @SMS                   tinyint,
  @Telefon               tinyint,
  @List                  tinyint,
  @EMAILStan             tinyint,
  @SMSStan               tinyint,
  @TelefonStan           tinyint,
  @ListStan              tinyint,
  @kanalid               int,
  @Data                  datetime,
  @OpeZalID              INT,
  @StaZalId              INT,
  @ZrodloID              INT,
  @Akronim               NVARCHAR(50),
  @ImieNazwisko          NVARCHAR(200),
  @ZgodaId               INT
  SELECT
    @PrzedstawicielID  = 0,
    @EMAIL             = 0,
    @SMS               = 0,
    @Telefon           = 0,
    @List              = 0,
 @EMAILStan         = 0,
    @SMSStan           = 0,
    @Telefonstan       = 0,
    @ListStan          = 0
  declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeZalID, @OpeZalKod OUT, @OpeZalNazwisko OUT
 if (@kanal1 != '0')
 begin
  select @kanalid = 0
  SELECT @kanalid = RZFK_RZFKId
  FROM Cdn.RejestracjaZgodFormyKontaktu
  WHERE RZFK_Guid = CONVERT(UNIQUEIDENTIFIER,@kanal1)
  if @kanalid = 1
  select @EMAIL = 1,@EMAILStan = @kanal1Stan
  if @kanalid = 2
  select @SMS = 1,@SMSStan = @kanal1Stan
  if @kanalid = 3
  select @Telefon = 1,@TelefonStan = @kanal1Stan
  if @kanalid = 4
  select @List = 1,@ListStan = @kanal1Stan
 end
 if (@kanal2 != '0')
 begin
  select @kanalid = 0
  SELECT @kanalid = RZFK_RZFKId
  FROM Cdn.RejestracjaZgodFormyKontaktu
  WHERE RZFK_Guid = CONVERT(UNIQUEIDENTIFIER,@kanal2)
  if @kanalid = 1
  select @EMAIL = 1,@EMAILStan = @kanal2Stan
  if @kanalid = 2
  select @SMS = 1,@SMSStan = @kanal2Stan
  if @kanalid = 3
  select @Telefon = 1,@TelefonStan = @kanal2Stan
  if @kanalid = 4
  select @List = 1,@ListStan = @kanal2Stan
 end
 if (@kanal3 != '0')
 begin
  select @kanalid = 0
  SELECT @kanalid = RZFK_RZFKId
  FROM Cdn.RejestracjaZgodFormyKontaktu
  WHERE RZFK_Guid = CONVERT(UNIQUEIDENTIFIER,@kanal3)
  if @kanalid = 1
  select @EMAIL = 1,@EMAILStan = @kanal3Stan
  if @kanalid = 2
  select @SMS = 1,@SMSStan = @kanal3Stan
  if @kanalid = 3
  select @Telefon = 1,@TelefonStan = @kanal3Stan
  if @kanalid = 4
  select @List = 1,@ListStan = @kanal3Stan
 end
 if (@kanal4 != '0')
 begin
  select @kanalid = 0
  SELECT @kanalid = RZFK_RZFKId
  FROM Cdn.RejestracjaZgodFormyKontaktu
  WHERE RZFK_Guid = CONVERT(UNIQUEIDENTIFIER,@kanal4)
  if @kanalid = 1
  select @EMAIL = 1,@EMAILStan = @kanal4Stan
  if @kanalid = 2
  select @SMS = 1,@SMSStan = @kanal4Stan
  if @kanalid = 3
  select @Telefon = 1,@TelefonStan = @kanal4Stan
  if @kanalid = 4
  select @List = 1,@ListStan = @kanal4Stan
 end
 SELECT @ESSID = ESS_ESSID from cdn.eSklepStanowiska where ESS_IdISklep = @IDEsklep
 SELECT @Knt_KntId = ESK_KntOptimaID
    FROM Cdn.eSklepKntRelacje
    WHERE ESK_KnteSklepID =  @KntIDEsklep AND ESK_eSklepID = @ESSID
 select @PrzedstawicielID = KESP_PrzedstawicielID, @Akronim = Knt_Kod, @ImieNazwisko = KnO_Nazwisko+'; '+ KESP_Email from CDN.KntESklepyPrzedstawiciele
 left join CDN.KntOsoby on KESP_PrzedstawicielID = KnO_KnOId
 left join CDN.Kontrahenci on KESP_KntID = Knt_KntId
  where KESP_KntID = @Knt_KntId and KESP_PrzedstawicieleSklepID = @LoginESklepID
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
 if not exists (select * from CDN.PodmiotRejestracjaZgod where PRZ_PrzedstawicielId = @PrzedstawicielID and  PRZ_TrescZgodyId = @TrescZgodyId)
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
           ,[PRZ_TS_Mod])
     VALUES
           (0
           ,0
           ,@PrzedstawicielID
           ,@TrescZgodyId
           ,case when @EMAIL = 1 then @EMAILStan else 0 end
           ,case when @SMS = 1 then @SMSStan else 0 end
           ,case when @Telefon = 1 then @TelefonStan else 0 end
           ,case when @List = 1 then @ListStan  else 0 end
           ,@Data
           ,@ZrodloID
           ,@IP
           ,case when @Stan = 0 then  @Data else NULL end
           ,case when @Stan = 0 then  @ZrodloID else 0 end
           ,case when @Stan = 0 then  @IP else '' end
           ,''
           ,@Akronim
           ,@ImieNazwisko
           ,@JezykID
           ,@ESSID
           ,case when @Stan = 0 then  @ESSID else 0 end
           ,@Data)
 else
 begin
    declare
     @ZgodaEmail int,
     @ZgodaSMS int,
     @ZgodaTelefon int,
     @ZgodaList int,
     @ZgodaStan  int,
     @DataZmiany datetime,
     @TSMOD datetime
  select @ZgodaId = PRZ_PRZID, @ZgodaEmail = PRZ_EMAIL,
  @ZgodaSMS  = PRZ_SMS,
  @ZgodaTelefon = PRZ_Telefon,
  @ZgodaList = PRZ_List,
  @ZgodaStan = case when PRZ_ZrodloWycofaniaId = 0 then 1 else 0 end,
  @DataZmiany = case when PRZ_ZrodloWycofaniaId = 0 then PRZ_DataWyrazenia else PRZ_DataWycofania end,
  @TSMOD = PRZ_TS_Mod
  from CDN.PodmiotRejestracjaZgod where PRZ_PrzedstawicielId = @PrzedstawicielID and  PRZ_TrescZgodyId = @TrescZgodyId
  if @TSMOD > @DataZmiany
   set @DataZmiany = @TSMOD
  if @DataZmiany < @Data
  begin
  if @Stan != @ZgodaStan and @Stan = 1
  begin
    --dodac jeszcze raz
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
           ,[PRZ_TS_Mod])
     VALUES
           (0
           ,0
           ,@PrzedstawicielID
           ,@TrescZgodyId
           ,case when @EMAIL = 1 then @EMAILStan else 0 end
           ,case when @SMS = 1 then @SMSStan  else 0 end
           ,case when @Telefon = 1 then @TelefonStan else 0 end
           ,case when @List = 1 then @ListStan  else 0 end
           ,@Data
           ,@ZrodloID
           ,@IP
           ,case when @Stan = 0 then  @Data else NULL end
           ,case when @Stan = 0 then  @ZrodloID else 0 end
           ,case when @Stan = 0 then  @IP else '' end
           ,''
           ,@Akronim
           ,@ImieNazwisko
           ,@JezykID
           ,@ESSID
           ,case when @Stan = 0 then  @ESSID else 0 end
           ,@Data)
  end
  --trzeba zamknąć
  if @Stan != @ZgodaStan and @Stan = 0
  begin
  UPDATE [CDN].[PodmiotRejestracjaZgod]
  SET
         [PRZ_DataWycofania] = @Data
        ,[PRZ_ZrodloWycofaniaId] = @ZrodloID
        ,[PRZ_IPWycofania] = @IP
        ,[PRZ_PowodWycofania] = ''
        ,[PRZ_WycofanieESklepId] = @ESSID
  ,[PRZ_TS_Mod] = @Data
  WHERE PRZ_PRZID = @ZgodaId
  end
  if @Stan = @ZgodaStan and @Stan = 1 and (@ZgodaEmail != @EMAIL or
  @ZgodaSMS != @SMS or
  @ZgodaTelefon != @Telefon or
  @ZgodaList !=@List)
  begin
  UPDATE [CDN].[PodmiotRejestracjaZgod]
  SET
         [PRZ_DataWycofania] = @Data
        ,[PRZ_ZrodloWycofaniaId] = @ZrodloID
        ,[PRZ_IPWycofania] = @IP
        ,[PRZ_PowodWycofania] = ''
        ,[PRZ_WycofanieESklepId] = @ESSID
  ,[PRZ_TS_Mod] = @Data
  WHERE PRZ_PRZID = @ZgodaId
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
           ,[PRZ_JezykId],[PRZ_WyrazenieESklepId]
           ,[PRZ_WycofanieESklepId]
           ,[PRZ_TS_Mod])
     VALUES
           (0
           ,0
           ,@PrzedstawicielID
           ,@TrescZgodyId
           ,case when @EMAIL = 1 then @EMAILStan else @ZgodaEmail end
           ,case when @SMS = 1 then @SMSStan  else @ZgodaSMS end
           ,case when @Telefon = 1 then @TelefonStan  else @ZgodaTelefon end
           ,case when @List = 1 then @ListStan  else @ZgodaList end
           ,@Data
           ,@ZrodloID
           ,@IP
           ,case when @Stan = 0 then  @Data else NULL end
           ,case when @Stan = 0 then  @ZrodloID else 0 end
           ,case when @Stan = 0 then  @IP else '' end
           ,''
           ,@Akronim
           ,@ImieNazwisko
           ,@JezykID
           ,@ESSID
           ,case when @Stan = 0 then  @ESSID else 0 end
           ,@Data)
  end
  end
 end
SET NOCOUNT OFF
