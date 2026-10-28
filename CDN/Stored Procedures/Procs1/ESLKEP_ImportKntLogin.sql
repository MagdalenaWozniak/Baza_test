CREATE PROCEDURE [CDN].[ESLKEP_ImportKntLogin]
  @KntIDEsklep                    int,
  @LoginIDOptima                  int,
  @LoginIDEsklep                  int,
  @LoginImie                      nvarchar(50),
  @LoginNaz                       nvarchar(50),
  @LoginTel                       nvarchar(50),
  @LoginEmail                     nvarchar(192),
  @LoginAdmin                     int,
  @Knt_OpeZalIDChr                nvarchar(11),
  @Knt_StaZalIdChr                nvarchar(11),
  @IDEsklepChr                    nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
  @Knt_KntId                      INT,
  @PrzedstawicielID               INT,
  @PrzedstawicielKod              nvarchar(40),
  @IDEsklep                       INT,
  @ESSID                          INT,
  @TypSklepu                      INT,
  @OpeZalID                       INT,
  @StaZalId                       INT,
  @Kod                            nvarchar(40),
  @Komunikat                      nvarchar(254)
  SELECT
    @IDEsklep          = CONVERT(INT,@IDEsklepChr),
    @OpeZalID          = CONVERT(INT,@Knt_OpeZalIDChr),
    @StaZalId          = CONVERT(INT,@Knt_StaZalIdChr),
    @Komunikat         = '',
    @PrzedstawicielID  = 0,
    @PrzedstawicielKod = ''
 declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeZalID, @OpeZalKod OUT, @OpeZalNazwisko OUT
  SELECT @ESSID = ESS_ESSID, @TypSklepu = ESS_TypSklepu from cdn.eSklepStanowiska where ESS_IdISklep = @IDEsklep
  SELECT @Knt_KntId = ESK_KntOptimaID
    FROM Cdn.eSklepKntRelacje
    WHERE ESK_KnteSklepID =  @KntIDEsklep AND ESK_eSklepID = @ESSID
  if (LEN(@LoginImie) = 0 and LEN(@LoginNaz) = 0)
 SET @Kod = 'login_esklep' +@IDEsklepChr+'_' + CONVERT(varchar(11),@LoginIDEsklep)
  else
  BEGIN
    if (LEN(@LoginImie) != 0)
 BEGIN
  SET @Kod = @LoginImie
  if (LEN(@LoginNaz) != 0)
   SET @Kod = @LoginImie + ' '+@LoginNaz
 END
 ELSE
 BEGIN
  SET @Kod = @LoginNaz
 END
  END
  --dla standard zawsze 1 login
  if @TypSklepu < 3
     set @LoginAdmin = 1
  if @LoginAdmin = 1
    UPDATE [CDN].[KntESklepyPrzedstawiciele]
    SET KESP_Domyslny = 0
    WHERE  KESP_eSklepID = @ESSID  AND KESP_KntID = @Knt_KntId
  if @LoginIDOptima > 0
  BEGIN
  if not exists (select * from CDN.KntESklepyPrzedstawiciele left join CDN.KntOsoby on KESP_PrzedstawicielID = KnO_KnOId where KESP_KESPID = @LoginIDOptima and ISNULL(KnO_LpAnonimizacji,0) != 0)
    UPDATE [CDN].[KntESklepyPrzedstawiciele]
    SET
      [KESP_Domyslny] = @LoginAdmin
      ,[KESP_Email] = @LoginEmail
      ,[KESP_Nazwisko] = case when (LEN(@LoginImie) != 0 or LEN(@LoginNaz) != 0) then @Kod else KESP_Nazwisko end
      ,[KESP_PrzedstawicieleSklepID] = @LoginIDEsklep
    WHERE KESP_KESPID = @LoginIDOptima
  END
  ELSE
  BEGIN
 if exists(select * from [CDN].[KntESklepyPrzedstawiciele] where  KESP_Email = @LoginEmail AND KESP_eSklepID = @ESSID  AND KESP_KntID = @Knt_KntId)
 BEGIN
  UPDATE [CDN].[KntESklepyPrzedstawiciele]
  SET
    [KESP_Domyslny] = @LoginAdmin
    ,[KESP_Email] = @LoginEmail
    ,[KESP_Nazwisko] = case when (LEN(@LoginImie) != 0 or LEN(@LoginNaz) != 0) then @Kod else KESP_Nazwisko end
    ,[KESP_PrzedstawicieleSklepID] = @LoginIDEsklep
  WHERE KESP_Email = @LoginEmail AND KESP_eSklepID = @ESSID  AND KESP_KntID = @Knt_KntId
 END
 ELSE
 BEGIN
   select Top 1 @PrzedstawicielID = KnO_KnOId,@PrzedstawicielKod = KnO_Nazwisko from [CDN].[KntOsoby] where KnO_KntId = @Knt_KntId and KnO_Email = @LoginEmail
   -- znalesc przedstawiciela
   if @PrzedstawicielID = 0
   BEGIN
    INSERT INTO [CDN].[KntOsoby]
       ([KnO_KntId]
       ,[KnO_Plec]
       ,[KnO_KodPocztowy]
       ,[KnO_Telefon]
       ,[KnO_GSM]
       ,[KnO_Informacje]
       ,[KnO_Domyslny]
       ,[KnO_Adres2]
       ,[KnO_Email]
       ,[KnO_Gmina]
       ,[KnO_Kraj]
       ,[KnO_Miasto]
       ,[KnO_Nazwisko]
       ,[KnO_NrDomu]
       ,[KnO_NrLokalu]
       ,[KnO_Poczta]
       ,[KnO_Powiat]
       ,[KnO_Tytul]
       ,[KnO_Ulica]
       ,[KnO_Wojewodztwo]
       ,[KnO_Mailing]
       ,[KnO_TelefonSms]
       ,[KnO_Nieaktywny]
       ,[KnO_LpAnonimizacji]
       ,[KnO_OpeZalId]
       ,[KnO_StaZalId]
       ,[KnO_TS_Zal]
       ,[KnO_OpeModId]
       ,[KnO_StaModId]
       ,[KnO_TS_Mod]
       ,[KnO_OpeModKod]
       ,[KnO_OpeModNazwisko]
       ,[KnO_OpeZalKod]
       ,[KnO_OpeZalNazwisko]
       ,[KnO_EmailESklep])
    VALUES
       (@Knt_KntId
       ,1
       ,''
       ,@LoginTel
       ,''
       ,''
       ,0
       ,''
       ,@LoginEmail
       ,''
       ,''
       ,''
       ,@Kod
       ,''
       ,''
       ,''
       ,''
       ,''
       ,''
       ,''
       ,0
       ,''
       ,0
       ,0
       ,@OpeZalId
       ,@StaZalId
       ,GETDATE()
       ,@OpeZalId
       ,@StaZalId
       ,GETDATE()
       ,@OpeZalKod
       ,@OpeZalNazwisko
       ,@OpeZalKod
       ,@OpeZalNazwisko
       ,'')
       SELECT @PrzedstawicielID = KnO_KnOId,@PrzedstawicielKod = KnO_Nazwisko FROM Cdn.KntOsoby WHERE KnO_Nazwisko = @Kod and KnO_Email = @LoginEmail
  END
   INSERT INTO [CDN].[KntESklepyPrzedstawiciele]
      ([KESP_KntID]
      ,[KESP_eSklepID]
      ,[KESP_PrzedstawicielID]
      ,[KESP_Domyslny]
      ,[KESP_Email]
      ,[KESP_Nazwisko]
      ,[KESP_PrzedstawicieleSklepID])
   VALUES
      (@Knt_KntId
      ,@ESSID
      ,@PrzedstawicielID
      ,@LoginAdmin
      ,@LoginEmail
      ,case when (LEN(@LoginImie) != 0 or LEN(@LoginNaz) != 0) then @Kod else @PrzedstawicielKod  end
      ,@LoginIDEsklep)
 END
  END
SET NOCOUNT OFF
