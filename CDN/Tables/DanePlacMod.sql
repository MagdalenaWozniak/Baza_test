CREATE TABLE [CDN].[DanePlacMod] (
    [DPM_DpmId]          INT             IDENTITY (1, 1) NOT NULL,
    [DPM_Kod]            INT             NOT NULL,
    [DPM_Rodzaj]         TINYINT         NOT NULL,
    [DPM_Wartosc]        DECIMAL (15, 2) NULL,
    [DPM_Opis]           NVARCHAR (254)  NOT NULL,
    [DPM_Nazwa]          VARCHAR (60)    NOT NULL,
    [DPM_Nieaktywny]     TINYINT         NOT NULL,
    [DPM_Format]         NVARCHAR (20)   NOT NULL,
    [DPM_Dodatkowe]      NVARCHAR (254)  NOT NULL,
    [DPM_Kolekcja]       NVARCHAR (128)  NOT NULL,
    [DPM_Inne]           NVARCHAR (128)  NOT NULL,
    [DPM_KolejkaWartosc] NVARCHAR (254)  NOT NULL,
    [DPM_KolejkaOpis]    NVARCHAR (254)  NOT NULL,
    [DPM_Tag]            INT             CONSTRAINT [DF_DPM_Tag] DEFAULT ((0)) NOT NULL,
    [DPM_ZjeId]          NVARCHAR (128)  CONSTRAINT [DF_DPM_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [DPM_Primary] PRIMARY KEY CLUSTERED ([DPM_DpmId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DPMNazwa]
    ON [CDN].[DanePlacMod]([DPM_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DPMZjeLink]
    ON [CDN].[DanePlacMod]([DPM_ZjeId] ASC) WITH (FILLFACTOR = 100);

