CREATE TABLE [CDN].[Parametry] (
    [PRM_PrmId]       INT             IDENTITY (1, 1) NOT NULL,
    [PRM_WzrId]       INT             NOT NULL,
    [PRM_Nazwa]       NVARCHAR (50)   NOT NULL,
    [PRM_Typ]         INT             NOT NULL,
    [PRM_Wartosc1]    DECIMAL (15, 2) NOT NULL,
    [PRM_Wartosc2]    DECIMAL (15, 2) NOT NULL,
    [PRM_WartoscInt1] INT             NOT NULL,
    [PRM_WartoscInt2] INT             NOT NULL,
    [PRM_Wzor]        NVARCHAR (256)  NOT NULL,
    [PRM_Dodatkowe]   NVARCHAR (128)  NOT NULL,
    [PRM_Numer]       INT             NOT NULL,
    CONSTRAINT [PRM_Primary] PRIMARY KEY CLUSTERED ([PRM_PrmId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PTWWzorzec] FOREIGN KEY ([PRM_WzrId]) REFERENCES [CDN].[Wzorce] ([WZR_WzrId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PTWWzorzec]
    ON [CDN].[Parametry]([PRM_WzrId] ASC) WITH (FILLFACTOR = 100);

