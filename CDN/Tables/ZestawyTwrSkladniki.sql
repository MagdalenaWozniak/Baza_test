CREATE TABLE [CDN].[ZestawyTwrSkladniki] (
    [ZTS_ZTSId]     INT             IDENTITY (1, 1) NOT NULL,
    [ZTS_ZTwId]     INT             NOT NULL,
    [ZTS_TwrId]     INT             NULL,
    [ZTS_TypRabatu] TINYINT         NOT NULL,
    [ZTS_Wartosc]   DECIMAL (17, 4) NOT NULL,
    [ZTS_Waluta]    VARCHAR (3)     NOT NULL,
    [ZTS_Ilosc]     DECIMAL (15, 4) NOT NULL,
    [ZTS_Jm]        NVARCHAR (20)   NOT NULL,
    CONSTRAINT [ZTS_Primary] PRIMARY KEY CLUSTERED ([ZTS_ZTSId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ZTSReceptura] FOREIGN KEY ([ZTS_ZTwId]) REFERENCES [CDN].[ZestawyTwr] ([ZTw_ZTwId]) ON DELETE CASCADE,
    CONSTRAINT [FK_ZTSTowar] FOREIGN KEY ([ZTS_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId])
);


GO
CREATE NONCLUSTERED INDEX [ZTSTowar]
    ON [CDN].[ZestawyTwrSkladniki]([ZTS_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ZTSZestaw]
    ON [CDN].[ZestawyTwrSkladniki]([ZTS_ZTwId] ASC, [ZTS_ZTSId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER [CDN].[ZestawyTwrSkladniki_Delete_Trigger]
ON [CDN].[ZestawyTwrSkladniki]
FOR DELETE
AS
  SET NOCOUNT ON
   --UPDATE cdn.towary SET Twr_TS_Mod = getdate()
   --         where twr_twrid in (select ZTS_TwrId from deleted)
   update Twr  set TwTS_TS_ModESklep = GETDATE() from CDN.TwrTSModEsklep Twr
   join deleted on TwTS_TwrId = ZTS_TwrId
   insert into  CDN.TwrTSModEsklep
   select distinct ZTS_TwrId,GETDATE() from deleted
   left join CDN.TwrTSModEsklep on TwTS_TwrId = ZTS_TwrId
   where TwTS_TwrId is null
  SET NOCOUNT OFF

GO
Create TRIGGER [CDN].[ZestawyTwrSkladniki_InsertUpdate_Trigger]
ON [CDN].[ZestawyTwrSkladniki]
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  update CDN.ZestawyTwr set ZTw_TS_Mod = getdate() where ZTw_TwrId in ( select distinct ZTS_TwrId From inserted)
  SET NOCOUNT OFF
