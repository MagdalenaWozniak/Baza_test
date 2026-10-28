CREATE TABLE [CDN].[SerieKalPoz] (
    [SLP_SlpId]   INT IDENTITY (1, 1) NOT NULL,
    [SLP_SlnId]   INT NOT NULL,
    [SLP_TypDnia] INT NOT NULL,
    [SLP_Lp]      INT NOT NULL,
    [SLP_OdwId]   INT NULL,
    CONSTRAINT [SLP_Primary] PRIMARY KEY CLUSTERED ([SLP_SlpId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SlpNaglowek] FOREIGN KEY ([SLP_SlnId]) REFERENCES [CDN].[SerieKalNag] ([SLN_SlnId]) ON DELETE CASCADE,
    CONSTRAINT [FK_SLPOdwLink] FOREIGN KEY ([SLP_OdwId]) REFERENCES [CDN].[OpisyDniWolne] ([ODW_OdwId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SlpNaglowek]
    ON [CDN].[SerieKalPoz]([SLP_SlnId] ASC, [SLP_SlpId] ASC) WITH (FILLFACTOR = 100);


GO
create trigger CDN.SerieKalPoz_Delete_Trigger
  on CDN.SerieKalPoz
  for delete
as
  set nocount on
 delete from cdn.SerieKalPozGodz where SKP_SlpId in (select slp_slpid from deleted)
  set nocount off
