CREATE TABLE [CDN].[PodArkuszInwenElem] (
    [PAE_PAEId]    INT             IDENTITY (1, 1) NOT NULL,
    [PAE_PAIId]    INT             NOT NULL,
    [PAE_Lp]       INT             NOT NULL,
    [PAE_TrEId]    INT             NOT NULL,
    [PAE_TwrId]    INT             NULL,
    [PAE_TwrKod]   NVARCHAR (50)   NOT NULL,
    [PAE_TwrNazwa] NVARCHAR (255)  NOT NULL,
    [PAE_TwrEAN]   VARCHAR (40)    NOT NULL,
    [PAE_Ilosc]    DECIMAL (15, 4) NOT NULL,
    [PAE_Jm]       NVARCHAR (20)   NOT NULL,
    [PAE_JMZ]      NVARCHAR (20)   NOT NULL,
    CONSTRAINT [PAE_Primary] PRIMARY KEY CLUSTERED ([PAE_PAEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ElemPodArkInw] FOREIGN KEY ([PAE_PAIId]) REFERENCES [CDN].[PodArkuszInwenNag] ([PAI_PAIId]) ON DELETE CASCADE,
    CONSTRAINT [FK_PAETowar] FOREIGN KEY ([PAE_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ElemPodArkInw]
    ON [CDN].[PodArkuszInwenElem]([PAE_PAIId] ASC, [PAE_PAEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PAETowar]
    ON [CDN].[PodArkuszInwenElem]([PAE_TwrId] ASC, [PAE_PAEId] ASC) WITH (FILLFACTOR = 100);

