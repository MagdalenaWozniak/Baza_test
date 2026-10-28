CREATE TABLE [CDN].[RemanentNag] (
    [ReN_ReNID]           INT             IDENTITY (1, 1) NOT NULL,
    [ReN_Rok]             SMALLINT        NOT NULL,
    [ReN_Numer]           SMALLINT        NOT NULL,
    [ReN_DataSpi]         DATETIME        NOT NULL,
    [ReN_Wartosc]         DECIMAL (15, 2) NOT NULL,
    [ReN_WartoscKorekta]  DECIMAL (15, 2) CONSTRAINT [DF_ReN_WartoscKorekta] DEFAULT ((0)) NOT NULL,
    [ReN_KatId]           INT             NULL,
    [ReN_Kategoria]       VARCHAR (50)    NOT NULL,
    [ReN_Opis]            NVARCHAR (254)  NOT NULL,
    [ReN_KPRId]           INT             NULL,
    [ReN_WartoscZbiorcza] TINYINT         CONSTRAINT [DF_ReN_WartoscZbiorcza] DEFAULT ((0)) NOT NULL,
    [ReN_OpeZalID]        INT             NULL,
    [ReN_StaZalId]        INT             NULL,
    [ReN_TS_Zal]          DATETIME        NOT NULL,
    [ReN_OpeModID]        INT             NULL,
    [ReN_StaModId]        INT             NULL,
    [ReN_TS_Mod]          DATETIME        NOT NULL,
    [ReN_Korekta]         TINYINT         CONSTRAINT [DF_ReN_Korekta] DEFAULT ((0)) NOT NULL,
    [ReN_ZakID]           INT             NULL,
    [ReN_OpeModKod]       VARCHAR (20)    CONSTRAINT [DF_ReN_OpeModKod] DEFAULT ('') NOT NULL,
    [ReN_OpeModNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_ReN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [ReN_OpeZalKod]       VARCHAR (20)    CONSTRAINT [DF_ReN_OpeZalKod] DEFAULT ('') NOT NULL,
    [ReN_OpeZalNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_ReN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [ReN_Primary] PRIMARY KEY CLUSTERED ([ReN_ReNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ReNKategoria] FOREIGN KEY ([ReN_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID])
);


GO
CREATE NONCLUSTERED INDEX [ReNKategoria]
    ON [CDN].[RemanentNag]([ReN_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ReNNumer]
    ON [CDN].[RemanentNag]([ReN_Rok] ASC, [ReN_Numer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ReNKPR]
    ON [CDN].[RemanentNag]([ReN_KPRId] ASC, [ReN_ReNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.RemanentNag_DeleteHandler
  ON CDN.RemanentNag
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.ReN_ReNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=4)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.ReN_ReNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=4)
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.RemanentNag_InsertUpdate_Trigger
  ON CDN.RemanentNag
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
--Sprawdzenie wartości ReN_Rok
  IF EXISTS (SELECT * FROM inserted
             WHERE inserted.ReN_Rok <> YEAR(inserted.ReN_DataSpi))
    BEGIN
          RAISERROR('##OPT32036##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
--Sprawdzanie obecności wierszy w tabeli nadrzędnej ZapisyKPR
    IF EXISTS
        (  SELECT * FROM inserted LEFT OUTER JOIN CDN.ZapisyKPR ON
                inserted.ReN_KPRID       = CDN.ZapisyKPR.KPR_KPRID
            WHERE CDN.ZapisyKPR.KPR_KPRID IS NULL
            AND inserted.ReN_KPRID IS NOT NULL
        )
    BEGIN
  RAISERROR('##OPT32024##%%1%%=ZapisyKPR##', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
    END
 IF EXISTS(SELECT * FROM inserted) AND UPDATE(ReN_WartoscZbiorcza)
 BEGIN
  UPDATE CDN.RemanentNag SET CDN.RemanentNag.ReN_Wartosc = inserted.ReN_Wartosc + ISNULL((SELECT SUM(ReE_Wartosc) FROM CDN.RemanentElem WHERE ReE_ReNID = inserted.ReN_ReNID), 0)
  FROM inserted
  WHERE CDN.RemanentNag.ReN_ReNID = inserted.ReN_ReNID
 END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.RemanentNag_Delete_Trigger
  ON CDN.RemanentNag
  FOR DELETE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy zapisy nie są zaksięgowane do KPiR
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.ReN_KpRId IS NOT NULL)
    BEGIN
      RAISERROR('##OPT32023##%%1%%=KPiR##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych TraNag
  IF EXISTS (SELECT * FROM CDN.TraNag WHERE TrN_TypDokumentu = 310 AND TrN_VaNId IN (SELECT ReN_ReNId FROM deleted))
    BEGIN
      UPDATE CDN.TraNag
      SET    TrN_VaNId = NULL
      WHERE  TrN_TypDokumentu = 310 AND TrN_VaNId IN (SELECT ReN_ReNId FROM deleted);
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=TraNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
  SET NOCOUNT OFF
