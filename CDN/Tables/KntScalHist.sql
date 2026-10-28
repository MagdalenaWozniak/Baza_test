CREATE TABLE [CDN].[KntScalHist] (
    [KSH_KSHID]       INT           IDENTITY (1, 1) NOT NULL,
    [KSH_NazwaTabeli] VARCHAR (100) NULL,
    [KSH_IDWiersza]   INT           NULL,
    [KSH_NumerDok]    VARCHAR (100) NULL,
    [KSH_OldKntID]    INT           NULL,
    [KSH_OldKntKod]   VARCHAR (50)  NULL,
    [KSH_NewKntID]    INT           NULL,
    [KSH_NewKntKod]   VARCHAR (50)  NULL,
    CONSTRAINT [KSH_Primary] PRIMARY KEY CLUSTERED ([KSH_KSHID] ASC) WITH (FILLFACTOR = 100)
);

