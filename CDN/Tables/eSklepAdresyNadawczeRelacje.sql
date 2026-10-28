CREATE TABLE [CDN].[eSklepAdresyNadawczeRelacje] (
    [ESAN_ESANId]      INT      IDENTITY (1, 1) NOT NULL,
    [ESAN_SANOptimaID] INT      NOT NULL,
    [ESAN_SANeSklepID] INT      NOT NULL,
    [ESAN_eSklepID]    INT      NOT NULL,
    [ESAN_TS]          DATETIME NOT NULL,
    CONSTRAINT [ESAN_Primary] PRIMARY KEY CLUSTERED ([ESAN_ESANId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_eSklepAdresyNadawczeRelacje] FOREIGN KEY ([ESAN_SANOptimaID]) REFERENCES [CDN].[SenditAdresyNadawcze] ([SAN_SANID]) ON DELETE CASCADE
);

