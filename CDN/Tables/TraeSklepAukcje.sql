CREATE TABLE [CDN].[TraeSklepAukcje] (
    [TrEA_TrEAId]            INT             IDENTITY (1, 1) NOT NULL,
    [TrEA_TrNId]             INT             NOT NULL,
    [TrEA_AukcjaTyp]         NVARCHAR (50)   NOT NULL,
    [TrEA_AukcjaTranID]      NVARCHAR (50)   NOT NULL,
    [TrEA_AukcjaLogin]       NVARCHAR (200)  NOT NULL,
    [TrEA_Aukcje]            NVARCHAR (1000) NOT NULL,
    [TrEA_AukcjaDostawaID]   NVARCHAR (50)   CONSTRAINT [DF_TrEA_AukcjaDostawaID] DEFAULT ('') NOT NULL,
    [TrEA_AukcjaLoginID]     NVARCHAR (50)   CONSTRAINT [DF_TrEA_AukcjaLoginID] DEFAULT ('') NOT NULL,
    [TrEA_AukcjaLoginSell]   NVARCHAR (200)  CONSTRAINT [DF_TrEA_AukcjaLoginSell] DEFAULT ('') NOT NULL,
    [TrEA_AukcjaLoginSellID] NVARCHAR (50)   CONSTRAINT [DF_TrEA_AukcjaLoginSellID] DEFAULT ('') NOT NULL,
    [TrEA_AukcjaSmart]       TINYINT         CONSTRAINT [DF_TrEA_AukcjaSmart] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [TrEA_Primary] PRIMARY KEY CLUSTERED ([TrEA_TrEAId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TrEATraNag] FOREIGN KEY ([TrEA_TrNId]) REFERENCES [CDN].[TraNag] ([TrN_TrNID]) ON DELETE CASCADE
);

