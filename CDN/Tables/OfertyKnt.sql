CREATE TABLE [CDN].[OfertyKnt] (
    [OfK_OfKId]          INT            IDENTITY (1, 1) NOT NULL,
    [OfK_OfDId]          INT            NULL,
    [OfK_Kod]            NVARCHAR (20)  NULL,
    [OfK_Lp]             INT            NOT NULL,
    [OfK_PodmiotTyp]     SMALLINT       NULL,
    [OfK_PodID]          INT            NULL,
    [OfK_PodNazwa1]      NVARCHAR (50)  NOT NULL,
    [OfK_PodNazwa2]      NVARCHAR (50)  NOT NULL,
    [OfK_PodNazwa3]      NVARCHAR (250) NOT NULL,
    [OfK_PodKraj]        NVARCHAR (40)  NOT NULL,
    [OfK_PodWojewodztwo] NVARCHAR (40)  NOT NULL,
    [OfK_PodPowiat]      NVARCHAR (40)  NOT NULL,
    [OfK_PodGmina]       NVARCHAR (40)  NOT NULL,
    [OfK_PodUlica]       NVARCHAR (40)  NOT NULL,
    [OfK_PodNrDomu]      NVARCHAR (10)  NOT NULL,
    [OfK_PodNrLokalu]    NVARCHAR (10)  NOT NULL,
    [OfK_PodMiasto]      NVARCHAR (40)  NOT NULL,
    [OfK_PodKodPocztowy] VARCHAR (10)   NOT NULL,
    [OfK_PodPoczta]      NVARCHAR (40)  NOT NULL,
    [OfK_PodAdres2]      NVARCHAR (40)  NOT NULL,
    [OfK_PodNipKraj]     VARCHAR (2)    NOT NULL,
    [OfK_PodNipE]        NVARCHAR (20)  NOT NULL,
    [OfK_PodmiotGLN]     VARCHAR (13)   NOT NULL,
    [OfK_PodEmail]       NVARCHAR (127) NOT NULL,
    [OfK_KnO_KnOId]      INT            NULL,
    CONSTRAINT [OfK_Primary] PRIMARY KEY CLUSTERED ([OfK_OfKId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OfKOfertyDok] FOREIGN KEY ([OfK_OfDId]) REFERENCES [CDN].[OfertyDok] ([OfD_OfDId]) ON DELETE CASCADE,
    CONSTRAINT [FK_OfKPodmiot] FOREIGN KEY ([OfK_PodID], [OfK_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
Create Trigger CDN.OfertyKnt_Delete_Trigger
  On CDN.OfertyKnt
  For Delete
As
Set NoCount On
 DELETE cdn.OfertyElemCeny
 FROM cdn.OfertyElemCeny
 JOIN cdn.OfertyElem ON cdn.OfertyElemCeny.OfC_OfLId = cdn.OfertyElem.OfL_OfLId
 JOIN cdn.OfertyDok ON cdn.OfertyElem.OfL_OfDId = cdn.OfertyDok.OfD_OfDId
 WHERE cdn.OfertyElemCeny.OfC_KntId IN (Select OfK_OfKId From deleted)
 AND cdn.OfertyDok.OfD_OfDId IN (Select OfK_OfDId From deleted)
Set NoCount Off
