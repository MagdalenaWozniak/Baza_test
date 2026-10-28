CREATE PROCEDURE [CDN].[ESLKEP_ImportDefZgodyJezyki]
  @VerIDChr                       nvarchar(50),
  @JezykId                        int,
  @Nazwa                          nvarchar(100),
  @Tresc                          nvarchar(max),
  @IDEsklep                       int
AS
  SET NOCOUNT ON
  DECLARE
  @VerID                          UNIQUEIDENTIFIER,
  @Data                           DateTime,
  @ESSID                          INT,
  @Kod                            nvarchar(40),
  @Komunikat                      nvarchar(254),
  @OptimaID                       INT,
  @ParentID                       INT,
  @Wersja                         INT,
  @Nazwa_sklep                    nvarchar(100)
  SELECT
    @Komunikat         = '',
    @VerID             = CONVERT(UNIQUEIDENTIFIER,@VerIDChr),
    @OptimaID          = 0
   SELECT @OptimaID = RZT_RZTID,  @ParentID = RZT_ParentId
    FROM Cdn.RejestracjaZgodTresc
    WHERE RZT_GuidVer = @VerID
   SELECT @ESSID = ESS_ESSID,@Nazwa_sklep = ESS_Nazwa +'_' + CONVERT(varchar(11),@OptimaID)  from cdn.eSklepStanowiska where ESS_IdISklep = @IDEsklep
   if not exists (select * from [CDN].[RejestracjaZgodTrescJezykObcy] where RZTJ_RZTID= @OptimaID and RZTJ_JezykID = @JezykId)
     INSERT INTO [CDN].[RejestracjaZgodTrescJezykObcy]
           ([RZTJ_RZTID]
           ,[RZTJ_JezykID]
           ,[RZTJ_Tresc])
     VALUES
           (@OptimaID
           ,@JezykId
           ,@Tresc)
   if @JezykId = 1
     BEGIN
     if @ParentID > 0
       SELECT @Nazwa = RZT_Tytul
       FROM Cdn.RejestracjaZgodTresc
       WHERE RZT_RZTID = @ParentID
     else
          if @Nazwa ! = '' and exists (select * from CDN.RejestracjaZgodTresc where @Nazwa = RZT_Tytul)
            set @Nazwa = substring(@Nazwa,1,100-len(@Nazwa_sklep)) + '_'+@Nazwa_sklep
    update [CDN].[RejestracjaZgodTresc] set RZT_Tytul = case when @Nazwa ! = '' then @Nazwa else RZT_Tytul end, RZT_Tresc = @Tresc
    where RZT_GuidVer = @VerID
    END
SET NOCOUNT OFF
