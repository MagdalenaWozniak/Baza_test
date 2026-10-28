CREATE PROCEDURE [CDN].[ESLKEP_ImportDefZgody]
  @KategoriaIdChr      nvarchar(11),
  @IDChr                          nvarchar(50),
  @VerIDChr                       nvarchar(50),
  @DataChr        varchar(50),
  @OpeZalIDChr                    nvarchar(11),
  @StaZalIdChr                    nvarchar(11),
  @IDEsklepChr                    nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
  @KategoriaId                      INT,
  @ID        UNIQUEIDENTIFIER,
  @VerID       UNIQUEIDENTIFIER,
  @Data         DateTime,
  @IDEsklep                       INT,
  @ESSID                          INT,
  @TypSklepu                      INT,
  @OpeZalID                       INT,
  @StaZalId                       INT,
  @Kod                            nvarchar(40),
  @Komunikat                      nvarchar(254),
  @OptimaID                       INT,
  @ParentID                       INT,
  @Wersja        INT
  SELECT
    @IDEsklep          = CONVERT(INT,@IDEsklepChr),
    @OpeZalID          = CONVERT(INT,@OpeZalIDChr),
    @StaZalId          = CONVERT(INT,@StaZalIdChr),
    @Komunikat         = '',
    @KategoriaId       = CONVERT(INT,@KategoriaIdChr),
 @VerID             = CONVERT(UNIQUEIDENTIFIER,@VerIDChr),
    @ID                = CONVERT(UNIQUEIDENTIFIER,@IDChr),
 @OptimaID          = 0,
 @ParentID          = 0,
 @Wersja            = 0,
 @Data              = CONVERT(datetime,replace(@DataChr,'T',' '),120)
 declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeZalID, @OpeZalKod OUT, @OpeZalNazwisko OUT
  SELECT @ESSID = ESS_ESSID, @TypSklepu = ESS_TypSklepu from cdn.eSklepStanowiska where ESS_IdISklep = @IDEsklep
  SELECT @OptimaID = RZT_RZTID
    FROM Cdn.RejestracjaZgodTresc
    WHERE RZT_GuidVer = @VerID
 SELECT @ParentID = RZT_RZTID
    FROM Cdn.RejestracjaZgodTresc
    WHERE RZT_GuidGlowny = @ID and RZT_Wersja = 1
  SELECT @Wersja = max(RZT_Wersja)
    FROM Cdn.RejestracjaZgodTresc
    WHERE RZT_GuidGlowny = @ID
 SET @Kod = 'Zgoda_esklep' +@IDEsklepChr+'_' + @IDChr
if @OptimaID = 0
begin
INSERT INTO [CDN].[RejestracjaZgodTresc]
           ([RZT_Nieaktywny]
           ,[RZT_ParentId]
           ,[RZT_Tytul]
           ,[RZT_Tresc]
           ,[RZT_ObowiazujeOd]
           ,[RZT_RZKID]
           ,[RZT_EMAIL]
           ,[RZT_SMS]
           ,[RZT_Telefon]
           ,[RZT_List]
           ,[RZT_GuidGlowny]
           ,[RZT_GuidVer]
           ,[RZT_Wersja]
           ,[RZT_OpeZalId]
           ,[RZT_StaZalId]
           ,[RZT_TS_Zal]
           ,[RZT_OpeModId]
           ,[RZT_StaModId]
           ,[RZT_TS_Mod]
           ,[RZT_OpeModKod]
           ,[RZT_OpeModNazwisko]
           ,[RZT_OpeZalKod]
           ,[RZT_OpeZalNazwisko])
     VALUES
           (0
           ,isnull(@ParentId,0)
           ,@Kod
           ,''
           ,@Data
           ,case when @KategoriaId = 2 then 1
   when @KategoriaId = 3 then 2
   when @KategoriaId = 4 then 3
   when @KategoriaId = 1000 then 4
   when @KategoriaId = 5 then 5
   when @KategoriaId =1 then 6
   else 6
   end
           ,0
           ,0
           ,0
           ,0
           ,@ID
           ,@VerID
           ,isnull(@Wersja,0)+1
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
 SELECT @OptimaID = RZT_RZTID
    FROM Cdn.RejestracjaZgodTresc
    WHERE RZT_GuidVer = @VerID
 if isnull(@ParentId,0) > 0
  update cdn.RejestracjaZgodTresc set RZT_Nieaktywny = 1 where RZT_Nieaktywny = 0 and (RZT_RZTId = isnull(@ParentId,0) or (RZT_ParentId = isnull(@ParentId,0) and RZT_Wersja < isnull(@Wersja,0)+1))
 end
 if not exists (select * from [CDN].[RejestracjaZgodTrescESklepy] where RZTES_eSklepID = @ESSID and RZTES_RZTID = @OptimaID)
 INSERT INTO [CDN].[RejestracjaZgodTrescESklepy]
           ([RZTES_RZTID]
           ,[RZTES_eSklepID]
           ,[RZTES_eSklepWyslana]
           ,[RZTES_PrzyszlaZeSklep])
     VALUES
           (@OptimaID
           ,@ESSID
           ,0
           ,1)
SET NOCOUNT OFF
