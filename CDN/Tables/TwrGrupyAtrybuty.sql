CREATE TABLE [CDN].[TwrGrupyAtrybuty] (
    [TwGA_TwGAId]     INT            IDENTITY (1, 1) NOT NULL,
    [TwGA_DeAId]      INT            NOT NULL,
    [TwGA_TwGId]      INT            NULL,
    [TwGA_WartoscTxt] NVARCHAR (100) NOT NULL,
    [TwGA_DABID]      INT            NULL,
    [TwGA_SourceId]   INT            NULL,
    [TwGA_JezykId]    SMALLINT       CONSTRAINT [DF_TwGA_JezykId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [TwGA_Primary] PRIMARY KEY CLUSTERED ([TwGA_TwGAId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [TwGAGrupa]
    ON [CDN].[TwrGrupyAtrybuty]([TwGA_TwGId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwGADefAtrybut]
    ON [CDN].[TwrGrupyAtrybuty]([TwGA_DeAId] ASC) WITH (FILLFACTOR = 100);


GO
create TRIGGER [CDN].[TwrGrupyAtrybuty_Delete_Trigger]
ON [CDN].[TwrGrupyAtrybuty]
FOR DELETE
AS
  SET NOCOUNT ON
      UPDATE cdn.twrgrupy SET twg_CzasModyfikacji = datediff(second,convert(DATETIME,'1990-01-01',120), getdate()), TwG_Kod = TwG_Kod
            where twg_twgid in (select TwGA_TwgId from deleted)
SET NOCOUNT OFF

GO
create TRIGGER [CDN].[TwrGrupyAtrybuty_InsertUpdate_Trigger]
ON [CDN].[TwrGrupyAtrybuty]
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
      UPDATE cdn.twrgrupy SET twg_CzasModyfikacji = datediff(second,convert(DATETIME,'1990-01-01',120), getdate()), TwG_Kod = TwG_Kod
            where twg_twgid in (select TwGA_TwgId from inserted)
   If Exists (select TwGA_DABId from inserted where TwGA_DABId is not null)
      UPDATE dane SET dane.dab_ts_mod = getdate()
            FROM cdn.danebinarne dane
            JOIN inserted ON  TwGA_DABId = DaB_DaBId
SET NOCOUNT OFF
