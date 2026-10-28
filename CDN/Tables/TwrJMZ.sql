CREATE TABLE [CDN].[TwrJMZ] (
    [TwJZ_TwJZId]          INT             IDENTITY (1, 1) NOT NULL,
    [TwJZ_TwrID]           INT             NOT NULL,
    [TwJZ_JM]              NVARCHAR (20)   NOT NULL,
    [TwJZ_JMPrzelicznikL]  DECIMAL (15, 2) NOT NULL,
    [TwJZ_JMPrzelicznikM]  DECIMAL (7)     NOT NULL,
    [TwJZ_eSklepID]        INT             CONSTRAINT [DF_TwJZ_eSklepID] DEFAULT ((0)) NOT NULL,
    [TwJZ_eSklepDomyslna]  TINYINT         CONSTRAINT [DF_TwJZ_eSklepDomyslna] DEFAULT ((0)) NOT NULL,
    [TwJZ_CenaJednostkowa] TINYINT         CONSTRAINT [DF_TwJZ_CenaJednostkowa] DEFAULT ((0)) NOT NULL,
    [TwJZ_Lp]              INT             NULL,
    [TwJZ_WysCm]           SMALLINT        NULL,
    [TwJZ_SzerCm]          SMALLINT        NULL,
    [TwJZ_DlugCm]          SMALLINT        NULL,
    CONSTRAINT [TwJZ_Primary] PRIMARY KEY CLUSTERED ([TwJZ_TwJZId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwJZTowar] FOREIGN KEY ([TwJZ_TwrID]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwJZTowar]
    ON [CDN].[TwrJMZ]([TwJZ_TwrID] ASC, [TwJZ_JM] ASC, [TwJZ_eSklepID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER [CDN].[TwrJMZ_Delete_Trigger]
  ON [CDN].[TwrJmZ]
  FOR DELETE
AS
SET NOCOUNT ON
  declare
  @JM nvarchar(20),
  @Zestaw nvarchar(20),
  @komunikat nvarchar(254)
   IF EXISTS (SELECT * FROM cdn.ZestawyTwrSkladniki  JOIN deleted ON ZTS_TwrId=deleted.TwJZ_TwrID and deleted.TwJZ_JM = ZTS_JM where deleted.TwJZ_eSklepID = 0)
  BEGIN
    SELECT top 1 @JM =ZTS_JM,@Zestaw = ZTw_Kod  FROM cdn.ZestawyTwrSkladniki  JOIN deleted ON ZTS_TwrId=deleted.TwJZ_TwrID and deleted.TwJZ_JM = ZTS_JM
    join cdn.ZestawyTwr on ZTS_ZTwId = ZTw_ZTwId
     set @komunikat = '##OPT34536##%%s1%%=' +@JM+ '%%s2%%='+@Zestaw+'##'--'Usunięto jednostkę miary ' +@JM+ ' występującą na zestawie promocyjnym  '+@Zestaw+'. Nie można zatwierdzić formularza towaru.'
    RAISERROR(@komunikat, 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  UPDATE T set T.Twr_JMZ = '',T.Twr_JMPrzelicznikL = 1,T.Twr_JMPrzelicznikM = 1
  FROM  CDN.Towary T where Twr_TwrId in (select TwJZ_TwrID from deleted where deleted.TwJZ_eSklepID = 0 )
        UPDATE T set T.Twr_JMZ = D.TwJZ_JM,T.Twr_JMPrzelicznikL = D.TwJZ_JMPrzelicznikL,T.Twr_JMPrzelicznikM = D.TwJZ_JMPrzelicznikM
        FROM  CDN.Towary T
        JOIN (select TwJZ_TwrID, TwJZ_JM,TwJZ_JMPrzelicznikL,TwJZ_JMPrzelicznikM from cdn.twrjmz where TwJZ_eSklepID = 0 AND TwJZ_TwJZID in
        (select min(TwJZ_TwJZID) from  cdn.twrjmz
        where TwJZ_eSklepID = 0 AND TwJZ_Twrid in (select TwJZ_TwrID from deleted where deleted.TwJZ_eSklepID = 0 )
        group by TwJZ_TwrID)) D ON T.Twr_TwrId = D.TwJZ_TwrID
SET NOCOUNT OFF

GO
CREATE TRIGGER [CDN].[TwrJMZ_INSERTUPDATE_Trigger]
  ON [CDN].[TwrJmZ]
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
   declare
  @JM nvarchar(20),
  @Zestaw nvarchar(20),
  @komunikat nvarchar(254)
   IF EXISTS (SELECT * FROM cdn.ZestawyTwrSkladniki  JOIN deleted ON ZTS_TwrId=deleted.TwJZ_TwrID and deleted.TwJZ_JM = ZTS_JM where deleted.TwJZ_eSklepID = 0)
  BEGIN
    SELECT top 1 @JM =ZTS_JM,@Zestaw = ZTw_Kod  FROM cdn.ZestawyTwrSkladniki  JOIN deleted ON ZTS_TwrId=deleted.TwJZ_TwrID and deleted.TwJZ_JM = ZTS_JM
    join cdn.ZestawyTwr on ZTS_ZTwId = ZTw_ZTwId
     set @komunikat = '##OPT34537##%%s1%%=' +@JM+ '%%s2%%='+@Zestaw+'##'--'Usunięto jednostkę miary ' +@JM+ ' występującą na zestawie promocyjnym  '+@Zestaw+'.'
    RAISERROR(@komunikat, 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
        UPDATE T set T.Twr_JMZ = D.TwJZ_JM,T.Twr_JMPrzelicznikL = D.TwJZ_JMPrzelicznikL,T.Twr_JMPrzelicznikM = D.TwJZ_JMPrzelicznikM
        FROM  CDN.Towary T
        JOIN (select TwJZ_TwrID, TwJZ_JM,TwJZ_JMPrzelicznikL,TwJZ_JMPrzelicznikM from cdn.twrjmz where TwJZ_eSklepID = 0 AND TwJZ_TwJZID in
        (select min(TwJZ_TwJZID) from  cdn.twrjmz
        where TwJZ_eSklepID = 0 AND TwJZ_Twrid in (select TwJZ_TwrID from INSERTED where INSERTED.TwJZ_eSklepID = 0)
        group by TwJZ_TwrID)) D ON T.Twr_TwrId = D.TwJZ_TwrID
SET NOCOUNT OFF
