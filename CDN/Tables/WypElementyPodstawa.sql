CREATE TABLE [CDN].[WypElementyPodstawa] (
    [WEP_WepId]        INT             IDENTITY (1, 1) NOT NULL,
    [WEP_WpeId]        INT             NULL,
    [WEP_PraId]        INT             NOT NULL,
    [WEP_Nazwa]        NVARCHAR (128)  NOT NULL,
    [WEP_NumerPelny]   VARCHAR (100)   NOT NULL,
    [WEP_Wlicz]        TINYINT         NOT NULL,
    [WEP_WliczMetoda]  TINYINT         NOT NULL,
    [WEP_RodzajElem]   TINYINT         NOT NULL,
    [WEP_Kwota1]       DECIMAL (15, 6) NOT NULL,
    [WEP_Kwota2]       DECIMAL (15, 6) NOT NULL,
    [WEP_Wspolczynnik] DECIMAL (15, 2) NOT NULL,
    [WEP_Kwota3]       DECIMAL (15, 6) NOT NULL,
    [WEP_GodzDni]      NVARCHAR (40)   NOT NULL,
    [WEP_NormaGodz]    DATETIME        NULL,
    [WEP_IloscMies]    INT             NULL,
    [WEP_OkresOd]      DATETIME        NULL,
    [WEP_OkresDo]      DATETIME        NULL,
    [WEP_ParentId]     INT             NULL,
    CONSTRAINT [WEP_Primary] PRIMARY KEY CLUSTERED ([WEP_WepId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WEPWpeId] FOREIGN KEY ([WEP_WpeId]) REFERENCES [CDN].[WypElementy] ([WPE_WpeId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [WEPPraId]
    ON [CDN].[WypElementyPodstawa]([WEP_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WEPWpeId]
    ON [CDN].[WypElementyPodstawa]([WEP_WpeId] ASC) WITH (FILLFACTOR = 100);

