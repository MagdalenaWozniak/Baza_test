CREATE TABLE [CDN].[WindykacjaLog] (
    [WiL_WiLId]        INT              IDENTITY (1, 1) NOT NULL,
    [WiL_Data]         DATETIME         NOT NULL,
    [WiL_Akcja]        INT              NOT NULL,
    [WiL_AkcjaId]      INT              NOT NULL,
    [WiL_Blad]         INT              NOT NULL,
    [WiL_NumerDok]     NVARCHAR (256)   NOT NULL,
    [WiL_PodmiotTyp]   SMALLINT         NOT NULL,
    [WiL_PodmiotId]    INT              NOT NULL,
    [WiL_Opis]         NVARCHAR (1024)  NOT NULL,
    [WiL_DokumentTyp]  INT              NOT NULL,
    [WiL_DokumentId]   INT              NOT NULL,
    [WiL_PlatnoscId]   INT              NOT NULL,
    [WiL_DokumentGUID] UNIQUEIDENTIFIER NULL,
    [WiL_Source]       INT              CONSTRAINT [DF_WiL_Source] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [WiL_Primary] PRIMARY KEY CLUSTERED ([WiL_WiLId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [WiL_DataIndex]
    ON [CDN].[WindykacjaLog]([WiL_Data] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WiL_PodmiotIndex]
    ON [CDN].[WindykacjaLog]([WiL_PodmiotTyp] ASC, [WiL_PodmiotId] ASC) WITH (FILLFACTOR = 100);

