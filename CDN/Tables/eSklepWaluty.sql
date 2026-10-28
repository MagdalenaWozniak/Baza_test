CREATE TABLE [CDN].[eSklepWaluty] (
    [ESW_ESWId]   INT             IDENTITY (1, 1) NOT NULL,
    [ESW_ESSId]   INT             NOT NULL,
    [ESW_Waluta]  VARCHAR (3)     NULL,
    [ESW_KursL]   DECIMAL (15, 4) NOT NULL,
    [ESW_KursM]   DECIMAL (15)    NOT NULL,
    [ESW_ZKonfig] TINYINT         NOT NULL,
    [ESW_TS_Mod]  DATETIME        NOT NULL,
    CONSTRAINT [ESW_Primary] PRIMARY KEY CLUSTERED ([ESW_ESWId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ESWESSId] FOREIGN KEY ([ESW_ESSId]) REFERENCES [CDN].[eSklepStanowiska] ([ESS_ESSId]) ON DELETE CASCADE
);


GO
Create TRIGGER [CDN].[eSklepWaluty_InsertUpdate_Trigger]
  ON [CDN].[eSklepWaluty]
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
 update cdn.eSklepWaluty set ESW_TS_Mod = GETDATE()
  SET NOCOUNT OFF
