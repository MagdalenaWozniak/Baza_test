CREATE TABLE [CDN].[WypElementyPodstawaElem] (
    [WEE_WeeId]        INT             IDENTITY (1, 1) NOT NULL,
    [WEE_WepId]        INT             NOT NULL,
    [WEE_Nazwa]        NVARCHAR (128)  NOT NULL,
    [WEE_NumerPelny]   VARCHAR (100)   NOT NULL,
    [WEE_Wlicz]        TINYINT         NOT NULL,
    [WEE_WliczMetoda]  TINYINT         NOT NULL,
    [WEE_RodzajElem]   TINYINT         NOT NULL,
    [WEE_Kwota1]       DECIMAL (15, 2) NOT NULL,
    [WEE_Kwota2]       DECIMAL (15, 2) NOT NULL,
    [WEE_Wspolczynnik] NVARCHAR (40)   NOT NULL,
    [WEE_Kwota3]       DECIMAL (15, 2) NOT NULL,
    [WEE_GodzDni]      NVARCHAR (40)   NOT NULL,
    [WEE_OkresOd]      DATETIME        NULL,
    [WEE_OkresDo]      DATETIME        NULL,
    CONSTRAINT [WEE_Primary] PRIMARY KEY CLUSTERED ([WEE_WeeId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WEEWepId] FOREIGN KEY ([WEE_WepId]) REFERENCES [CDN].[WypElementyPodstawa] ([WEP_WepId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [WEEWepId]
    ON [CDN].[WypElementyPodstawaElem]([WEE_WepId] ASC) WITH (FILLFACTOR = 100);

