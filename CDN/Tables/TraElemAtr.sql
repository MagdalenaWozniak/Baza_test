CREATE TABLE [CDN].[TraElemAtr] (
    [TrA_TrEId]   INT            NOT NULL,
    [TrA_Lp]      INT            NOT NULL,
    [TrA_DeAId]   INT            NOT NULL,
    [TrA_Kod]     VARCHAR (20)   NOT NULL,
    [TrA_Wartosc] NVARCHAR (100) NOT NULL,
    [TrA_TrAID]   INT            IDENTITY (1, 1) NOT NULL,
    [TrA_ESklep]  SMALLINT       CONSTRAINT [DF_TrA_ESklep] DEFAULT ((0)) NOT NULL,
    [TrA_DokTyp]  INT            NULL,
    [TrA_DokId]   INT            NULL,
    [TrA_TwrId]   INT            NULL,
    CONSTRAINT [TrA_Primary] PRIMARY KEY CLUSTERED ([TrA_TrAID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [TrATraElemAtr]
    ON [CDN].[TraElemAtr]([TrA_TrEId] ASC, [TrA_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrA_Dok_Index]
    ON [CDN].[TraElemAtr]([TrA_DokTyp] ASC, [TrA_DokId] ASC, [TrA_Lp] ASC) WITH (FILLFACTOR = 100);

