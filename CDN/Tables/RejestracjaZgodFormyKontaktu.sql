CREATE TABLE [CDN].[RejestracjaZgodFormyKontaktu] (
    [RZFK_RZFKId]         INT              IDENTITY (1, 1) NOT NULL,
    [RZFK_Nazwa]          NVARCHAR (255)   NOT NULL,
    [RZFK_GUID]           UNIQUEIDENTIFIER NULL,
    [RZFK_OpeZalId]       INT              NULL,
    [RZFK_StaZalId]       INT              NULL,
    [RZFK_TS_Zal]         DATETIME         NOT NULL,
    [RZFK_OpeModId]       INT              NULL,
    [RZFK_StaModId]       INT              NULL,
    [RZFK_TS_Mod]         DATETIME         NOT NULL,
    [RZFK_OpeModKod]      VARCHAR (20)     CONSTRAINT [DF_RZFK_OpeModKod] DEFAULT ('') NOT NULL,
    [RZFK_OpeModNazwisko] NVARCHAR (50)    CONSTRAINT [DF_RZFK_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [RZFK_OpeZalKod]      VARCHAR (20)     CONSTRAINT [DF_RZFK_OpeZalKod] DEFAULT ('') NOT NULL,
    [RZFK_OpeZalNazwisko] NVARCHAR (50)    CONSTRAINT [DF_RZFK_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [RZFK_Primary] PRIMARY KEY CLUSTERED ([RZFK_RZFKId] ASC) WITH (FILLFACTOR = 100)
);

