CREATE TABLE [CDN].[TwrAtrybuty] (
    [TwA_TwAId]                  INT            IDENTITY (1, 1) NOT NULL,
    [TwA_DeAId]                  INT            NOT NULL,
    [TwA_TwrId]                  INT            NULL,
    [TwA_SrUId]                  INT            NULL,
    [TwA_SrRId]                  INT            NULL,
    [TwA_SrZId]                  INT            NULL,
    [TwA_Zalezny]                TINYINT        NOT NULL,
    [TwA_ESklep]                 TINYINT        NULL,
    [TwA_WartoscTxt]             NVARCHAR (100) NOT NULL,
    [TwA_CzyKopiowac]            TINYINT        NOT NULL,
    [TwA_CzyKod]                 TINYINT        NOT NULL,
    [TwA_CzyPrzenosic]           TINYINT        NOT NULL,
    [TwA_CzyDrukowac]            TINYINT        NOT NULL,
    [TwA_DABID]                  INT            NULL,
    [TwA_CzyObowiazkowySerwis]   TINYINT        NOT NULL,
    [TwA_CzyObowiazkowyDostawy]  TINYINT        NOT NULL,
    [TwA_CzyPrzenosicNaDostawy]  TINYINT        NOT NULL,
    [TwA_RodzajId]               INT            NULL,
    [TwA_UrzId]                  INT            NULL,
    [TwA_SourceId]               INT            NULL,
    [TwA_JezykId]                SMALLINT       CONSTRAINT [DF_TwA_JezykId] DEFAULT ((1)) NOT NULL,
    [TwA_Lp]                     INT            NULL,
    [TwA_AtrybutGrupujacyFantom] TINYINT        CONSTRAINT [DF_TwA_AtrybutGrupujacyFantom] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [TwA_Primary] PRIMARY KEY CLUSTERED ([TwA_TwAId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwADefAtrybut] FOREIGN KEY ([TwA_DeAId]) REFERENCES [CDN].[DefAtrybuty] ([DeA_DeAId]) ON DELETE CASCADE,
    CONSTRAINT [FK_TwARodzajU] FOREIGN KEY ([TwA_SrRId]) REFERENCES [CDN].[SrsRodzajeU] ([SrR_SrRId]) ON DELETE CASCADE,
    CONSTRAINT [FK_TwATowar] FOREIGN KEY ([TwA_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE,
    CONSTRAINT [FK_TwAUrzadzenie] FOREIGN KEY ([TwA_SrUId]) REFERENCES [CDN].[SrsUrzadzenia] ([SrU_SrUId]) ON DELETE CASCADE,
    CONSTRAINT [FK_TwAZlecenie] FOREIGN KEY ([TwA_SrZId]) REFERENCES [CDN].[SrsZlecenia] ([SrZ_SrZId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [TwATowar]
    ON [CDN].[TwrAtrybuty]([TwA_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwAUrzadzenie]
    ON [CDN].[TwrAtrybuty]([TwA_SrUId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwARodzajU]
    ON [CDN].[TwrAtrybuty]([TwA_SrRId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwADefAtrybut]
    ON [CDN].[TwrAtrybuty]([TwA_DeAId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwAZlecenie]
    ON [CDN].[TwrAtrybuty]([TwA_SrZId] ASC) WITH (FILLFACTOR = 100);


GO
Create TRIGGER [CDN].[TwrAtrybuty_InsertUpdate_Trigger]
ON [CDN].[TwrAtrybuty]
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
   --If Exists (select TwA_DABId from inserted where TwA_DABId is not null)
   --   UPDATE dane SET dane.dab_ts_mod = getdate()
   --         FROM cdn.danebinarne dane
   --         JOIN inserted ON  TwA_DABId = DaB_DaBId
  if exists (select * from inserted left join cdn.DefAtrybuty on DeA_DeAId = twa_deaid where DeA_PozwalajNaEdycjeESklep = 1 and TwA_AtrybutGrupujacyFantom = 1)
  BEGIN
      RAISERROR('##OPT34549##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- jeśli zaznaczamy atrybut do esklep to tez na definicji musi byc.
  if exists (select DeA_DeAId from inserted join CDN.DefAtrybuty on DeA_DeAId = twa_deaid where  isnull(TwA_ESklep,0) = 1 and isnull(DeA_ESklep,0) = 0)
  update CDN.DefAtrybuty set DeA_ESklep = 1,DeA_TS_Mod = GETDATE() where DeA_DeAId in (
  select DeA_DeAId from inserted join CDN.DefAtrybuty on DeA_DeAId = twa_deaid where  isnull(TwA_ESklep,0) = 1 and isnull(DeA_ESklep,0) = 0)
SET NOCOUNT OFF

GO
Create TRIGGER [CDN].[TwrAtrybuty_Delete_Trigger]
ON [CDN].[TwrAtrybuty]
FOR DELETE
AS
  SET NOCOUNT ON
   UPDATE cdn.towary SET Twr_TS_Mod = getdate()
            where twr_twrid in (select Twa_TwrId from deleted)
  SET NOCOUNT OFF
