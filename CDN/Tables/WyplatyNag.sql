CREATE TABLE [CDN].[WyplatyNag] (
    [WyN_WyNId]           INT             IDENTITY (1, 1) NOT NULL,
    [WyN_PrcID]           INT             NULL,
    [WyN_RokMies]         INT             NOT NULL,
    [WyN_DataWyp]         DATETIME        NOT NULL,
    [WyN_DataZap]         DATETIME        NULL,
    [WyN_Etat]            TINYINT         NOT NULL,
    [WyN_KatID]           INT             NULL,
    [WyN_Kategoria]       VARCHAR (50)    NOT NULL,
    [WyN_BruttoRazem]     DECIMAL (15, 2) NOT NULL,
    [WyN_BruttoOpodat]    DECIMAL (15, 2) NOT NULL,
    [WyN_BruttoKoszt]     DECIMAL (15, 2) NOT NULL,
    [WyN_BruttoGotowka]   DECIMAL (15, 2) NOT NULL,
    [WyN_UbEmerytPrac]    DECIMAL (15, 2) NOT NULL,
    [WyN_UbEmerytFir]     DECIMAL (15, 2) NOT NULL,
    [WyN_UbRentowPrac]    DECIMAL (15, 2) NOT NULL,
    [WyN_UbRentowFir]     DECIMAL (15, 2) NOT NULL,
    [WyN_UbChorobPrac]    DECIMAL (15, 2) NOT NULL,
    [WyN_UbWypadkFir]     DECIMAL (15, 2) NOT NULL,
    [WyN_PodstawaFGSP]    DECIMAL (15, 2) NOT NULL,
    [WyN_PodstawaFP]      DECIMAL (15, 2) NOT NULL,
    [WyN_KosztyUzyskania] DECIMAL (15, 2) NOT NULL,
    [WyN_Podatek]         DECIMAL (15, 2) NOT NULL,
    [WyN_UbZdrowotne]     DECIMAL (15, 2) NOT NULL,
    [WyN_UbZdrowNOdl]     DECIMAL (15, 2) NOT NULL,
    [WyN_ZaliczkaUS]      DECIMAL (15, 2) NOT NULL,
    [WyN_Gotowka]         DECIMAL (15, 2) NOT NULL,
    [WyN_PodstawaFEP]     DECIMAL (15, 2) NOT NULL,
    [WyN_SkladkaFEP]      DECIMAL (15, 2) NOT NULL,
    [WyN_KprID]           INT             NULL,
    [WyN_DekID]           INT             NULL,
    [WyN_ImportRowId]     VARCHAR (36)    NULL,
    [WyN_OpeZalID]        INT             NULL,
    [WyN_StaZalId]        INT             NULL,
    [WyN_TS_Zal]          DATETIME        NOT NULL,
    [WyN_OpeModID]        INT             NULL,
    [WyN_StaModId]        INT             NULL,
    [WyN_TS_Mod]          DATETIME        NOT NULL,
    [WyN_ZakID]           INT             NULL,
    [WyN_OpeModKod]       VARCHAR (20)    CONSTRAINT [DF_WyN_OpeModKod] DEFAULT ('') NOT NULL,
    [WyN_OpeModNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_WyN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [WyN_OpeZalKod]       VARCHAR (20)    CONSTRAINT [DF_WyN_OpeZalKod] DEFAULT ('') NOT NULL,
    [WyN_OpeZalNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_WyN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [WyN_Zwolnienie]      TINYINT         CONSTRAINT [DF_WyN_Zwolnienie] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [WyN_Primary] PRIMARY KEY CLUSTERED ([WyN_WyNId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WyNKategoria] FOREIGN KEY ([WyN_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_WyNPracownik] FOREIGN KEY ([WyN_PrcID]) REFERENCES [CDN].[PracKod] ([PRA_PraId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WyNKategoria]
    ON [CDN].[WyplatyNag]([WyN_KatID] ASC, [WyN_RokMies] ASC, [WyN_DataWyp] ASC, [WyN_WyNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WyNPracownik]
    ON [CDN].[WyplatyNag]([WyN_PrcID] ASC, [WyN_RokMies] ASC, [WyN_DataWyp] ASC, [WyN_WyNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WyNMiesiac]
    ON [CDN].[WyplatyNag]([WyN_RokMies] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WyNZapisyKPR]
    ON [CDN].[WyplatyNag]([WyN_KprID] ASC, [WyN_WyNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WyNDekrety]
    ON [CDN].[WyplatyNag]([WyN_DekID] ASC, [WyN_WyNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.WyplatyNag_DeleteHandler
  ON CDN.WyplatyNag
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.WyN_WyNId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=5)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.WyN_WyNId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=5)
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.WyplatyNag_Delete_Trigger
  ON CDN.WyplatyNag
  FOR DELETE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy zapisy nie są zaksięgowane do KPR
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.WyN_KPRId IS NOT NULL)
    BEGIN
      RAISERROR('Nie można kasować zapisów zaksięgowanych (ZapisyKPR)', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy zapisy nie są zaksięgowane do dekretów
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.WyN_DekId IS NOT NULL)
    BEGIN
      RAISERROR('Nie można kasować zapisów zaksięgowanych (Dekrety)', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.WyplatyNag_InsertUpdate_Trigger
  ON CDN.WyplatyNag
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
--Sprawdzanie obecności wierszy w tabeli nadrzędnej ZapisyKPR
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.ZapisyKPR ON
                    inserted.WyN_KPRID       = CDN.ZapisyKPR.KPR_KPRID
              WHERE CDN.ZapisyKPR.KPR_KPRID IS NULL
                AND inserted.WyN_KPRID IS NOT NULL
           )
        BEGIN
          RAISERROR('Brak wartości w tabeli nadrzędnej (ZapisyKPR) ', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.DekretyNag ON
                    inserted.WyN_DekID       = CDN.DekretyNag.DeN_DeNId
              WHERE CDN.DekretyNag.DeN_DeNId IS NULL
                AND inserted.WyN_DekID IS NOT NULL
           )
        BEGIN
          RAISERROR('Brak wartości w tabeli nadrzędnej (DekretyNag) ', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
  SET NOCOUNT OFF
