CREATE TABLE [CDN].[IntrastatElem] (
    [IsE_IsEId]            INT             IDENTITY (1, 1) NOT NULL,
    [IsE_IsNId]            INT             NULL,
    [IsE_Lp]               INT             NOT NULL,
    [IsE_Kraj]             NVARCHAR (2)    NOT NULL,
    [IsE_Opis]             NVARCHAR (255)  NOT NULL,
    [IsE_RodzajTransakcji] NVARCHAR (2)    NOT NULL,
    [IsE_CN]               NVARCHAR (8)    NOT NULL,
    [IsE_KrajPochodzenia]  NVARCHAR (2)    NOT NULL,
    [IsE_MasaNetto]        DECIMAL (15, 3) NOT NULL,
    [IsE_JmUzup]           DECIMAL (15, 2) NOT NULL,
    [IsE_Netto]            DECIMAL (15, 2) NOT NULL,
    [IsE_Automatyczny]     TINYINT         CONSTRAINT [DF_IsE_Automatyczny] DEFAULT ((0)) NOT NULL,
    [IsE_NumerIdentKnt]    NVARCHAR (40)   CONSTRAINT [DF_IsE_NumerIdentKnt] DEFAULT ('') NOT NULL,
    CONSTRAINT [IsE_Primary] PRIMARY KEY CLUSTERED ([IsE_IsEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_IsENaglowek] FOREIGN KEY ([IsE_IsNId]) REFERENCES [CDN].[IntrastatNag] ([IsN_IsNId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IsENaglowek]
    ON [CDN].[IntrastatElem]([IsE_IsNId] ASC, [IsE_IsEId] ASC) WITH (FILLFACTOR = 100);

