CREATE TABLE [CDN].[ListyPlac] (
    [LPL_LplId]            INT             IDENTITY (1, 1) NOT NULL,
    [LPL_DzlId]            INT             NOT NULL,
    [LPL_DdfId]            INT             NOT NULL,
    [LPL_Tryb]             INT             NOT NULL,
    [LPL_ParentId]         INT             NULL,
    [LPL_NumerString]      VARCHAR (31)    NOT NULL,
    [LPL_NumerNr]          INT             NOT NULL,
    [LPL_NumerPelny]       AS              ([CDN].[FN_NUMERPELNY]([LPL_NUMERNR],[LPL_NUMERSTRING])),
    [LPL_DataOd]           DATETIME        NOT NULL,
    [LPL_DataDo]           DATETIME        NOT NULL,
    [LPL_Miesiac]          SMALLINT        NOT NULL,
    [LPL_Rok]              INT             NOT NULL,
    [LPL_DataDok]          DATETIME        NOT NULL,
    [LPL_Nazwa]            NVARCHAR (128)  NOT NULL,
    [LPL_DataDanych]       DATETIME        NULL,
    [LPL_Zamknieta]        DATETIME        NULL,
    [LPL_Kategoria]        INT             NOT NULL,
    [LPL_MiesiecyWstecz]   INT             NOT NULL,
    [LPL_Zaksiegowana]     TINYINT         NOT NULL,
    [LPL_DekId]            INT             NULL,
    [LPL_KPRId]            INT             NULL,
    [LPL_PreDekId]         INT             NULL,
    [LPL_Symbol]           VARCHAR (5)     NOT NULL,
    [LPL_Oddelegowani]     TINYINT         CONSTRAINT [DF_LPL_Oddelegowani] DEFAULT ((0)) NOT NULL,
    [LPL_DataKur]          DATETIME        NULL,
    [LPL_KursNumer]        INT             CONSTRAINT [DF_LPL_KursNumer] DEFAULT ((3)) NOT NULL,
    [LPL_KursL]            DECIMAL (15, 4) CONSTRAINT [DF_LPL_KursL] DEFAULT ((1)) NOT NULL,
    [LPL_KursM]            DECIMAL (5)     CONSTRAINT [DF_LPL_KursM] DEFAULT ((1)) NOT NULL,
    [LPL_Waluta]           VARCHAR (3)     CONSTRAINT [DF_LPL_Waluta] DEFAULT ('') NOT NULL,
    [LPL_Tymczasowi]       TINYINT         CONSTRAINT [DF_LPL_Tymczasowi] DEFAULT ((0)) NOT NULL,
    [LPL_ImportAppId]      VARCHAR (5)     NULL,
    [LPL_ImportRowId]      VARCHAR (36)    NULL,
    [LPL_TS_Export]        DATETIME        NULL,
    [LPL_OpeZalId]         INT             NULL,
    [LPL_StaZalId]         INT             NULL,
    [LPL_TS_Zal]           DATETIME        NOT NULL,
    [LPL_OpeModId]         INT             NULL,
    [LPL_StaModId]         INT             NULL,
    [LPL_TS_Mod]           DATETIME        NOT NULL,
    [LPL_TS_Import]        DATETIME        NULL,
    [LPL_OddelegowaniKraj] NVARCHAR (40)   CONSTRAINT [DF_LPL_OddelegowaniKraj] DEFAULT ('') NOT NULL,
    [LPL_WalutaDieta]      VARCHAR (3)     CONSTRAINT [DF_LPL_WalutaDieta] DEFAULT ('') NOT NULL,
    [LPL_DataKurDieta]     DATETIME        NULL,
    [LPL_KursNumerDieta]   INT             CONSTRAINT [DF_LPL_KursNumerDieta] DEFAULT ((3)) NOT NULL,
    [LPL_KursLDieta]       DECIMAL (15, 4) CONSTRAINT [DF_LPL_KursLDieta] DEFAULT ((1)) NOT NULL,
    [LPL_KursMDieta]       DECIMAL (5)     CONSTRAINT [DF_LPL_KursMDieta] DEFAULT ((1)) NOT NULL,
    [LPL_ZakId]            INT             NULL,
    [LPL_OpeModKod]        VARCHAR (20)    CONSTRAINT [DF_LPL_OpeModKod] DEFAULT ('') NOT NULL,
    [LPL_OpeModNazwisko]   NVARCHAR (50)   CONSTRAINT [DF_LPL_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [LPL_OpeZalKod]        VARCHAR (20)    CONSTRAINT [DF_LPL_OpeZalKod] DEFAULT ('') NOT NULL,
    [LPL_OpeZalNazwisko]   NVARCHAR (50)   CONSTRAINT [DF_LPL_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [LPL_Primary] PRIMARY KEY CLUSTERED ([LPL_LplId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_LPLDdfLink] FOREIGN KEY ([LPL_DdfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_LPLDzlLink] FOREIGN KEY ([LPL_DzlId]) REFERENCES [CDN].[Dzialy] ([DZL_DzlId]),
    CONSTRAINT [FK_LPLParent] FOREIGN KEY ([LPL_ParentId]) REFERENCES [CDN].[ListyPlac] ([LPL_LplId]),
    CONSTRAINT [FK_LPLZakLink] FOREIGN KEY ([LPL_ZakId]) REFERENCES [CDN].[Zaklady] ([Zak_ZakID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [LPLNumerPelny]
    ON [CDN].[ListyPlac]([LPL_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [LplRokMiesiac]
    ON [CDN].[ListyPlac]([LPL_Rok] ASC, [LPL_Miesiac] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [LPLDdfLink]
    ON [CDN].[ListyPlac]([LPL_DdfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [LPLDzlLink]
    ON [CDN].[ListyPlac]([LPL_DzlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [LPlDekrety]
    ON [CDN].[ListyPlac]([LPL_DekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [LPlPreDekrety]
    ON [CDN].[ListyPlac]([LPL_PreDekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [LPlZapisyKPR]
    ON [CDN].[ListyPlac]([LPL_KPRId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [LPLInclude]
    ON [CDN].[ListyPlac]([LPL_ParentId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [LPLZakLink]
    ON [CDN].[ListyPlac]([LPL_ZakId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.ListyPlac_DeleteHandler
  ON CDN.ListyPlac
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.LPL_LplId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=10)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.LPL_LplId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=10)
    IF EXISTS(SELECT D.LPL_PreDekID FROM Deleted D WHERE D.LPL_PreDekID IS NOT NULL)
  DELETE CDN.DekretyNag
  FROM CDN.DekretyNag, deleted
  WHERE deleted.LPL_PreDekId = CDN.DekretyNag.DeN_DeNID
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.ListyPlac_InsertUpdate_Trigger
  ON CDN.ListyPlac
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
--kasowanie wskaźnika wyeksportowania
if (select LPL_Zamknieta from inserted) is null
begin
if not update (LPL_TS_Export) and exists (select * from inserted where LPL_TS_Export is not null)
 update cdn.ListyPlac set LPL_TS_Export = null
  where LPL_LplId in (select LPL_LplId from inserted where LPL_TS_Export is not null)
end
--ustawianie unikalnego identyfikatora
if exists (select * from inserted where LPL_ImportRowId is null or LPL_ImportRowId = '')
 update cdn.ListyPlac set LPL_ImportRowId = newid()
  where LPL_LplId in (select LPL_LplId from inserted where LPL_ImportRowId is null or LPL_ImportRowId = '')
--Sprawdzanie obecności wierszy w tabeli nadrzędnej ZapisyKPR
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.ZapisyKPR ON
                    inserted.Lpl_KPRID       = CDN.ZapisyKPR.KPR_KPRID
              WHERE CDN.ZapisyKPR.KPR_KPRID IS NULL
                AND inserted.Lpl_KPRID IS NOT NULL
           )
        BEGIN
          RAISERROR('##OPT32502##', 16, 1)--RAISERROR('Brak wartości w tabeli nadrzędnej (ZapisyKPR) ', 16, 1)--ERR_SQL_Place_BrakWartosciZapisyKPR
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.DekretyNag ON
                    inserted.Lpl_DekID       = CDN.DekretyNag.DeN_DeNId
              WHERE CDN.DekretyNag.DeN_DeNId IS NULL
                AND inserted.Lpl_DekID IS NOT NULL
           )
        BEGIN
          RAISERROR('##OPT32503##', 16, 1)--RAISERROR('Brak wartości w tabeli nadrzędnej (DekretyNag) ', 16, 1)--ERR_SQL_Place_BrakWartosciDekretyNag
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.ListyPlac_Delete_Trigger
  ON CDN.ListyPlac
  FOR DELETE
AS
  SET NOCOUNT ON
        IF EXISTS (SELECT * FROM deleted WHERE deleted.LPL_Zamknieta = 1)
        BEGIN
          RAISERROR('##OPT32504##', 16, 1)--RAISERROR('Nie mozna kasować zamkniętej listy płac.', 16, 1)--ERR_SQL_Place_NieMoznaUsunacZamLPL
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
  SET NOCOUNT OFF
