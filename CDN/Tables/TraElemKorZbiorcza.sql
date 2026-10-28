CREATE TABLE [CDN].[TraElemKorZbiorcza] (
    [TreZ_TreZID]        INT             IDENTITY (1, 1) NOT NULL,
    [TreZ_TrNID]         INT             NOT NULL,
    [TreZ_Stawka]        DECIMAL (5, 2)  NOT NULL,
    [TreZ_Flaga]         SMALLINT        NOT NULL,
    [TreZ_Zrodlowa]      DECIMAL (5, 2)  NOT NULL,
    [TreZ_WartoscFaktur] DECIMAL (15, 2) NOT NULL,
    [TreZ_Rabat]         DECIMAL (15, 2) NOT NULL,
    [TreZ_Waluta]        VARCHAR (3)     NOT NULL,
    CONSTRAINT [TreZ_Primary] PRIMARY KEY CLUSTERED ([TreZ_TreZID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TreZTraNag] FOREIGN KEY ([TreZ_TrNID]) REFERENCES [CDN].[TraNag] ([TrN_TrNID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [TreZTraNag]
    ON [CDN].[TraElemKorZbiorcza]([TreZ_TrNID] ASC) WITH (FILLFACTOR = 100);

