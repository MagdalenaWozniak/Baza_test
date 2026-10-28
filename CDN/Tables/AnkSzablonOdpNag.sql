CREATE TABLE [CDN].[AnkSzablonOdpNag] (
    [AnkSoN_AnkSoNId]       INT            IDENTITY (1, 1) NOT NULL,
    [AnkSoN_Nazwa]          NVARCHAR (250) NOT NULL,
    [AnkSoN_OpeZalID]       INT            NULL,
    [AnkSoN_StaZalId]       INT            NULL,
    [AnkSoN_TS_Zal]         DATETIME       NOT NULL,
    [AnkSoN_OpeModID]       INT            NULL,
    [AnkSoN_StaModId]       INT            NULL,
    [AnkSoN_TS_Mod]         DATETIME       NOT NULL,
    [AnkSoN_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_AnkSoN_OpeModKod] DEFAULT ('') NOT NULL,
    [AnkSoN_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_AnkSoN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AnkSoN_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_AnkSoN_OpeZalKod] DEFAULT ('') NOT NULL,
    [AnkSoN_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_AnkSoN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [AnkSoN_Auto]           INT            CONSTRAINT [DF_AnkSoN_Auto] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [AnkSoN_Primary] PRIMARY KEY CLUSTERED ([AnkSoN_AnkSoNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AnkSoN_Nazwa_UniqueIx]
    ON [CDN].[AnkSzablonOdpNag]([AnkSoN_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.AnkSzablonOdpNag_Delete_Trigger
ON CDN.AnkSzablonOdpNag
FOR DELETE
AS
 SET NOCOUNT ON
 DELETE FROM cdn.AnkSzablonOdpElem WHERE AnkSoE_AnkSoNId IN (SELECT d.AnkSoN_AnkSonId FROM deleted d)
 SET NOCOUNT OFF
