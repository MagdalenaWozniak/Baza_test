CREATE TABLE [CDN].[ProdElem] (
    [PdE_PdEId]          INT             IDENTITY (1, 1) NOT NULL,
    [PdE_TrEId]          INT             NOT NULL,
    [PdE_ZwrId]          INT             NULL,
    [PdE_Lp]             SMALLINT        NOT NULL,
    [PdE_DataWys]        DATETIME        NOT NULL,
    [PdE_DataOpe]        DATETIME        NOT NULL,
    [PdE_TwrId]          INT             NULL,
    [PdE_MagId]          INT             NULL,
    [PdE_TrEIdRWS]       INT             NULL,
    [PdE_Ilosc]          DECIMAL (15, 4) NOT NULL,
    [PdE_Jm]             NVARCHAR (20)   NOT NULL,
    [PdE_JmCalkowite]    SMALLINT        NOT NULL,
    [PdE_JMPrzelicznikL] DECIMAL (15, 2) NOT NULL,
    [PdE_JMPrzelicznikM] DECIMAL (7)     NOT NULL,
    [PdE_IloscJM]        DECIMAL (15, 4) NOT NULL,
    [PdE_WartoscZakupu]  DECIMAL (15, 2) NOT NULL,
    [PdE_WyborDostaw]    TINYINT         CONSTRAINT [DF_PdE_WyborDostaw] DEFAULT ((0)) NULL,
    [PdE_TwrTyp]         TINYINT         NOT NULL,
    CONSTRAINT [PdE_Primary] PRIMARY KEY CLUSTERED ([PdE_PdEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PdEMagazyn] FOREIGN KEY ([PdE_MagId]) REFERENCES [CDN].[Magazyny] ([Mag_MagId]),
    CONSTRAINT [FK_PdETowar] FOREIGN KEY ([PdE_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId]),
    CONSTRAINT [FK_PdETraElem] FOREIGN KEY ([PdE_TrEId]) REFERENCES [CDN].[TraElem] ([TrE_TrEID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [PdERWS]
    ON [CDN].[ProdElem]([PdE_TrEIdRWS] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PdETowar]
    ON [CDN].[ProdElem]([PdE_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PdETraElem]
    ON [CDN].[ProdElem]([PdE_TrEId] ASC, [PdE_Lp] ASC, [PdE_PdEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PdEMagazyn]
    ON [CDN].[ProdElem]([PdE_MagId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [PdEZwrot]
    ON [CDN].[ProdElem]([PdE_ZwrId] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger [CDN].[ProdElem_Update_Trigger]
  On [CDN].[ProdElem]
  For Update
As
Set NoCount On
IF  UPDATE( PdE_WartoscZakupu )
AND NOT UPDATE( PdE_TrEId)
AND NOT UPDATE( PdE_ZwrId)
AND NOT UPDATE( PdE_Lp)
AND NOT UPDATE( PdE_DataWys)
AND NOT UPDATE( PdE_DataOpe)
AND NOT UPDATE( PdE_TwrId)
AND NOT UPDATE( PdE_MagId)
AND NOT UPDATE( PdE_TrEIdRWS)
AND NOT UPDATE( PdE_Ilosc)
AND NOT UPDATE( PdE_JmCalkowite)
AND NOT UPDATE( PdE_JMPrzelicznikL)
AND NOT UPDATE( PdE_JMPrzelicznikM)
AND NOT UPDATE( PdE_IloscJM)
AND NOT UPDATE( PdE_Jm)
AND NOT UPDATE( PdE_WyborDostaw)
AND NOT UPDATE( PdE_TwrTyp)
return
If Exists (select * from cdn.traselem where trs_treid in(
select PdE_TrEIdRWS from deleted)
and exists(select *
FROM inserted
    JOIN deleted ON inserted.PdE_PdEId = deleted.PdE_PdEId
    WHERE   inserted.PdE_WyborDostaw = 1)
)
 delete from cdn.traselem where trs_treid in(
select inserted.PdE_TrEIdRWS from inserted JOIN deleted ON inserted.PdE_PdEId = deleted.PdE_PdEId
    WHERE   inserted.PdE_WyborDostaw = 1)
Set NoCount Off
