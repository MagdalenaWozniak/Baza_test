CREATE TABLE [CDN].[ZapisyKPR] (
    [KPR_KPRID]              INT             IDENTITY (1, 1) NOT NULL,
    [KPR_Bufor]              SMALLINT        NOT NULL,
    [KPR_RokMies]            INT             NOT NULL,
    [KPR_Lp]                 INT             NOT NULL,
    [KPR_OrgId]              INT             NULL,
    [KPR_DataOpe]            DATETIME        NOT NULL,
    [KPR_Dokument]           VARCHAR (256)   NOT NULL,
    [KPR_Korekta]            TINYINT         CONSTRAINT [DF_KPR_Korekta] DEFAULT ((0)) NOT NULL,
    [KPR_PodmiotTyp]         SMALLINT        NULL,
    [KPR_PodID]              INT             NULL,
    [KPR_KntNazwa1]          NVARCHAR (50)   NOT NULL,
    [KPR_KntNazwa2]          NVARCHAR (50)   NOT NULL,
    [KPR_KntNazwa3]          NVARCHAR (250)  NOT NULL,
    [KPR_KntKraj]            NVARCHAR (40)   NOT NULL,
    [KPR_KntWojewodztwo]     NVARCHAR (40)   NOT NULL,
    [KPR_KntPowiat]          NVARCHAR (40)   NOT NULL,
    [KPR_KntGmina]           NVARCHAR (40)   NOT NULL,
    [KPR_KntUlica]           NVARCHAR (40)   NOT NULL,
    [KPR_KntNrDomu]          NVARCHAR (10)   NOT NULL,
    [KPR_KntNrLokalu]        NVARCHAR (10)   NOT NULL,
    [KPR_KntMiasto]          NVARCHAR (40)   NOT NULL,
    [KPR_KntKodPocztowy]     VARCHAR (10)    NOT NULL,
    [KPR_KntPoczta]          NVARCHAR (40)   NOT NULL,
    [KPR_KntAdres2]          NVARCHAR (40)   NOT NULL,
    [KPR_KntNipKraj]         VARCHAR (2)     NOT NULL,
    [KPR_KntNipE]            NVARCHAR (20)   NOT NULL,
    [KPR_KatID]              INT             NULL,
    [KPR_Kategoria]          VARCHAR (50)    NOT NULL,
    [KPR_Sprzedaz]           DECIMAL (15, 2) NOT NULL,
    [KPR_Pozostale]          DECIMAL (15, 2) NOT NULL,
    [KPR_Towary]             DECIMAL (15, 2) NOT NULL,
    [KPR_Uboczne]            DECIMAL (15, 2) NOT NULL,
    [KPR_Reklama]            DECIMAL (15, 2) NOT NULL,
    [KPR_Wynagrodz]          DECIMAL (15, 2) NOT NULL,
    [KPR_Inne]               DECIMAL (15, 2) NOT NULL,
    [KPR_Zaszlosci]          DECIMAL (15, 2) NOT NULL,
    [KPR_Uwagi]              NVARCHAR (254)  NOT NULL,
    [KPR_Skreslony]          TINYINT         NOT NULL,
    [KPR_Zrodlo]             TINYINT         NOT NULL,
    [KPR_ImportRowId]        VARCHAR (36)    NULL,
    [KPR_OpeZalID]           INT             NULL,
    [KPR_StaZalId]           INT             NULL,
    [KPR_TS_Zal]             DATETIME        NOT NULL,
    [KPR_OpeModID]           INT             NULL,
    [KPR_StaModId]           INT             NULL,
    [KPR_TS_Mod]             DATETIME        NOT NULL,
    [KPR_OpisKorekta]        NVARCHAR (254)  NULL,
    [KPR_SpisZNatury]        INT             CONSTRAINT [DF_KPR_SpisZNatury] DEFAULT ((0)) NOT NULL,
    [KPR_DataGosp]           DATETIME        CONSTRAINT [DF_KPR_DataGosp] DEFAULT ((-2)) NOT NULL,
    [KPR_KorektaZaplaconych] TINYINT         CONSTRAINT [DF_KPR_KorektaZaplaconych] DEFAULT ((0)) NOT NULL,
    [KPR_Koszty_BiR]         DECIMAL (15, 2) CONSTRAINT [DF_KPR_Koszty_BiR] DEFAULT ((0)) NOT NULL,
    [KPR_OpisKosztow]        NVARCHAR (254)  CONSTRAINT [DF_KPR_OpisKosztow] DEFAULT ('') NOT NULL,
    [KPR_ZakID]              INT             NULL,
    [KPR_ZakLp]              INT             CONSTRAINT [DF_KPR_ZakLP] DEFAULT ((0)) NOT NULL,
    [KPR_OpeModKod]          VARCHAR (20)    CONSTRAINT [DF_KPR_OpeModKod] DEFAULT ('') NOT NULL,
    [KPR_OpeModNazwisko]     NVARCHAR (50)   CONSTRAINT [DF_KPR_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [KPR_OpeZalKod]          VARCHAR (20)    CONSTRAINT [DF_KPR_OpeZalKod] DEFAULT ('') NOT NULL,
    [KPR_OpeZalNazwisko]     NVARCHAR (50)   CONSTRAINT [DF_KPR_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [KPR_Primary] PRIMARY KEY CLUSTERED ([KPR_KPRID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KPRKategoria] FOREIGN KEY ([KPR_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_KPRKontrah] FOREIGN KEY ([KPR_PodID], [KPR_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE NONCLUSTERED INDEX [KPROryginal]
    ON [CDN].[ZapisyKPR]([KPR_OrgId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPRLp]
    ON [CDN].[ZapisyKPR]([KPR_Bufor] ASC, [KPR_RokMies] ASC, [KPR_Lp] ASC, [KPR_KPRID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPRChronoBuf]
    ON [CDN].[ZapisyKPR]([KPR_Bufor] ASC, [KPR_DataOpe] ASC, [KPR_KPRID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPRChrono]
    ON [CDN].[ZapisyKPR]([KPR_DataOpe] ASC, [KPR_KPRID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPRKontrah]
    ON [CDN].[ZapisyKPR]([KPR_PodID] ASC, [KPR_PodmiotTyp] ASC, [KPR_DataOpe] ASC, [KPR_KPRID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KPRKategoria]
    ON [CDN].[ZapisyKPR]([KPR_KatID] ASC, [KPR_DataOpe] ASC, [KPR_KPRID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.ZapisyKPR_InsertUpdate_Trigger
  ON CDN.ZapisyKPR
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Sprawdzanie miesiąca zamkniętego
  DECLARE @DataZamkniecia CHAR(10)
  SET @DataZamkniecia = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1300)
    IF EXISTS(SELECT * FROM deleted
              WHERE CONVERT(CHAR(10), deleted.KPR_DataOpe, 120)  <= @DataZamkniecia
              AND   deleted.KPR_Bufor = 0)
    OR EXISTS(SELECT * FROM inserted
              WHERE CONVERT(CHAR(10), inserted.KPR_DataOpe, 120) <= @DataZamkniecia)
              --AND   inserted.KPR_Bufor = 0)//163371
    BEGIN
   RAISERROR('##OPT32037##%%1%%=%s##',16,1,@DataZamkniecia)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
--Ustalenie wartości KPR_RokMies
  IF UPDATE(KPR_RokMies) OR UPDATE(KPR_DataOpe)
    IF EXISTS (SELECT * FROM inserted
               WHERE  inserted.KPR_RokMies <> 100 *  YEAR(inserted.KPR_DataOpe)
                                            + MONTH(inserted.KPR_DataOpe))
      BEGIN
        UPDATE CDN.ZapisyKPR
        SET    CDN.ZapisyKPR.KPR_RokMies  = 100 *  YEAR(CDN.ZapisyKPR.KPR_DataOpe)
                                          + MONTH(CDN.ZapisyKPR.KPR_DataOpe)
        FROM   CDN.ZapisyKPR
        JOIN   inserted
        ON     CDN.ZapisyKPR.KPR_KPRId    = inserted.KPR_KPRId
        WHERE  CDN.ZapisyKPR.KPR_RokMies <> 100 *  YEAR(CDN.ZapisyKPR.KPR_DataOpe)
                                          + MONTH(CDN.ZapisyKPR.KPR_DataOpe);
-- Rollback transakcji w przypadku błędu
          IF @@ERROR <> 0
            BEGIN
     RAISERROR('##OPT32020##%%1%%=ZapisyKPR##',16,1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
            END
    END
Declare @DataTmp Char(10)
  -- Sprawdzanie zapisu skojarzonego (Spis z natury)
  If Exists (
  Select * From CDN.ZapisyKPR Where KPR_Skreslony=0 And KPR_Zrodlo = 4 And KPR_OrgId In
  (Select KPR_KPRId From inserted WHERE inserted.KPR_Skreslony=1 And inserted.KPR_Zrodlo = 4))
  Begin
 Declare @Numer CHAR(5)
 Select Top 1 @DataTmp = Convert(Char(10), KPR_DataOpe, 120), @Numer = Convert(Char(5), KPR_Lp)
      From CDN.ZapisyKPR
      Where KPR_OrgId In (Select KPR_KPRId From inserted Where inserted.KPR_Skreslony=1 And inserted.KPR_Zrodlo = 4)
   RaisError('##OPT32054##%%1%%=%s%%2%%=%s##',16,1,@Numer,@DataTmp)
      Rollback Tran
      Set NoCount Off
      Return
  End
-- Sprawdzanie zapisu skojarzonego (ZUS)
  If Exists (
    Select * From CDN.ZapisyKPR Where KPR_Skreslony=0 And KPR_Zrodlo != 4 And KPR_OrgId In
   (Select KPR_KPRId From inserted Where inserted.KPR_Skreslony=1 And inserted.KPR_Zrodlo != 4)
   )
  Begin
  Declare @Opis VARCHAR(50)
    Select Top 1 @DataTmp = Convert(Char(10), KPR_DataOpe, 120), @Opis = KPR_Kategoria
      From CDN.ZapisyKPR
      Where KPR_OrgId In (Select KPR_KPRId From inserted Where inserted.KPR_Skreslony=1 And inserted.KPR_Zrodlo != 4)
      RaisError('##OPT32056##%%1%%=%s%%2%%=%s##',16,1,@Opis, @DataTmp)
      Rollback Tran
      Set NoCount Off
      Return
  End
--Sprawdzanie obecności wierszy w tabeli nadrzędnej (relacja ZapisyKPR-ZapisyKPR)
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.ZapisyKPR ON inserted.KPR_OrgID = CDN.ZapisyKPR.KPR_KPRId
              WHERE inserted.KPR_OrgId IS NOT NULL And CDN.ZapisyKPR.KPR_KPRId IS NULL
           )
        BEGIN
    RAISERROR('##OPT32024##%%1%%=ZapisyKPR##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
-- obsługa kaskadowego uaktualniania zapisów źródłowych
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON     deleted.KPR_KPRId          = inserted.KPR_KPRId
             WHERE  deleted.KPR_Zrodlo        <> 0
               AND  inserted.KPR_Skreslony     = 1)
    BEGIN
-- obsługa kaskadowego uaktualniania zapisów źródłowych VatNag
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON     deleted.KPR_KPRId      = inserted.KPR_KPRId
             WHERE  (deleted.KPR_Zrodlo = 2  OR deleted.KPR_Zrodlo = 3)
                    AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.VatNag
      SET    CDN.VatNag.VaN_KPRId = NULL
      FROM   CDN.VatNag
      JOIN   deleted  ON CDN.VatNag.VaN_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.VatNag.VaN_KPRId = inserted.KPR_KPRId
      WHERE  (deleted.KPR_Zrodlo = 2  OR deleted.KPR_Zrodlo = 3)
             AND inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=VatNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych samochodówki
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 3 AND inserted.KPR_Skreslony = 1)
    BEGIN
-- aktualizacja zapisu AutoRozlicz
      UPDATE CDN.AutoRozlicz
      SET    CDN.AutoRozlicz.AuR_KPRId = NULL
      FROM   CDN.AutoRozlicz
      JOIN   deleted  ON CDN.AutoRozlicz.AuR_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.AutoRozlicz.AuR_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 3 AND inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=AutoRozlicz##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych RemanentNag
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 4 AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.RemanentNag
      SET    CDN.RemanentNag.ReN_KPRId = NULL
      FROM   CDN.RemanentNag
      JOIN   deleted  ON CDN.RemanentNag.ReN_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.RemanentNag.ReN_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 4 AND inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=RemanentNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych TrwaleHist
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 7
               AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.TrwaleHist
      SET    CDN.TrwaleHist.SrH_KPRId = NULL
      FROM   CDN.TrwaleHist
      JOIN   deleted  ON CDN.TrwaleHist.SrH_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.TrwaleHist.SrH_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 7
        AND  inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=TrwaleHist##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych WyplatyNag
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 5 AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.WyplatyNag
      SET    CDN.WyplatyNag.WyN_KPRId = NULL
      FROM   CDN.WyplatyNag
      JOIN   deleted  ON CDN.WyplatyNag.WyN_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.WyplatyNag.WyN_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 5 AND  inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=WyplatyNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych ListyPlac
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 10 AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.ListyPlac
      SET    CDN.ListyPlac.LPL_KPRId = NULL
      FROM   CDN.ListyPlac
      JOIN   deleted  ON CDN.ListyPlac.LPL_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.ListyPlac.LPL_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 10 AND  inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=ListyPlac##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych EwidDodNag
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 12 AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.EwidDodNag
      SET    CDN.EwidDodNag.EDN_KPRId = NULL
      FROM   CDN.EwidDodNag
      JOIN   deleted  ON CDN.EwidDodNag.EDN_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.EwidDodNag.EDN_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 12 AND  inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=EwidDodNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych BnkRozKwoty
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 13 AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.BnkRozKwoty
      SET    CDN.BnkRozKwoty.BRK_KPRId = NULL
      FROM   CDN.BnkRozKwoty
      JOIN   deleted  ON CDN.BnkRozKwoty.BRK_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.BnkRozKwoty.BRK_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 13 AND  inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=BnkRozKwoty##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych BnkRozKwotyMW
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 43 AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.BnkRozKwotyMW
      SET    CDN.BnkRozKwotyMW.BRKMW_KPRId = NULL
      FROM   CDN.BnkRozKwotyMW
      JOIN   deleted  ON CDN.BnkRozKwotyMW.BRKMW_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.BnkRozKwotyMW.BRKMW_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 43 AND  inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=BnkRozKwotyMW##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych BnkZapisy
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 14 AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.BnkZapisy
      SET    CDN.BnkZapisy.BZp_KPRId = NULL
      FROM   CDN.BnkZapisy
      JOIN   deleted  ON CDN.BnkZapisy.BZp_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.BnkZapisy.BZp_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 14 AND inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=BnkZapisy##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych Delegacji
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.KPR_KPRId = inserted.KPR_KPRId
             WHERE deleted.KPR_Zrodlo = 108 AND inserted.KPR_Skreslony = 1)
    BEGIN
      UPDATE CDN.DlgNag
      SET    CDN.DlgNag.DLN_KPRId = NULL
      FROM   CDN.DlgNag
      JOIN   deleted  ON CDN.DlgNag.DLN_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.DlgNag.DLN_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 108 AND inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=DlgNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- Zerowanie wskaźnika KpR_Zrodlo w zapisach skreślonych
      UPDATE CDN.ZapisyKPR
      SET    CDN.ZapisyKPR.KPR_Zrodlo = 0
      FROM   CDN.ZapisyKPR
      JOIN   deleted  ON CDN.ZapisyKPR.KPR_KPRId = deleted.KPR_KPRId
      JOIN   inserted ON CDN.ZapisyKPR.KPR_KPRId = inserted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo <> 0 AND  inserted.KPR_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32020##%%1%%=ZapisyKPR##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
  END
--Ustalenie relacji do kontrahenta nieokreślonego
  IF UPDATE(KPR_PodmiotTyp) OR UPDATE(KPR_PodId)
    IF EXISTS (SELECT * FROM inserted
               WHERE IsNull(KPR_PodmiotTyp ,0) = 0 OR IsNull(KPR_PodId ,0) = 0)
      BEGIN
        UPDATE CDN.ZapisyKPR
           SET KPR_PodmiotTyp = 1, KPR_PodId = 1
         WHERE KPR_KPRId IN (SELECT KPR_KPRId FROM inserted WHERE IsNull(KPR_PodmiotTyp ,0) = 0 OR IsNull(KPR_PodId ,0) = 0)
-- Rollback transakcji w przypadku błędu
        IF @@ERROR <> 0
          BEGIN
            RAISERROR('##OPT32020##%%1%%=ZapisyKPR##', 16, 1)
            ROLLBACK TRAN
            SET NOCOUNT OFF
            RETURN
          END
      END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.ZapisyKPR_Delete_Trigger
  ON CDN.ZapisyKPR
  FOR DELETE
AS
  SET NOCOUNT ON
  DECLARE @DataTmp CHAR(10)
  DECLARE @Numer CHAR(5)
  DECLARE @Opis VARCHAR(50)
  -- Sprawdzanie zapisu skojarzonego (Spis z natury)
  If Exists (Select * From CDN.ZapisyKPR Where KPR_Skreslony=0 And KPR_Zrodlo = 4 And KPR_OrgId In (Select KPR_KPRId From deleted))
  Begin
    Select Top 1 @DataTmp = Convert(Char(10), KPR_DataOpe, 120), @Numer = Convert(Char(5), KPR_Lp)
      From CDN.ZapisyKPR
      Where KPR_Skreslony=0 And KPR_Zrodlo = 4 And KPR_OrgId In (Select KPR_KPRId From deleted)
      RaisError('##OPT32054##%%1%%=%s%%2%%=%s##',16,1,@Numer,@DataTmp)
      Rollback Tran
      Set NoCount Off
      Return
  End
-- Sprawdzanie zapisu skojarzonego (ZUS)
  If Exists (Select * From CDN.ZapisyKPR Where KPR_Skreslony=0 And KPR_Zrodlo != 4 And KPR_OrgId In (Select KPR_KPRId From deleted))
  Begin
    Select Top 1 @DataTmp = Convert(Char(10), KPR_DataOpe, 120), @Opis = KPR_Kategoria
      From CDN.ZapisyKPR
      Where KPR_Skreslony=0 And KPR_Zrodlo != 4 And KPR_OrgId In (Select KPR_KPRId From deleted)
      RaisError('##OPT32056##%%1%%=%s%%2%%=%s##',16,1,@Opis, @DataTmp)
      Rollback Tran
      Set NoCount Off
      Return
  End
-- Sprawdzanie miesiąca zamkniętego
  SET @DataTmp = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1300)
    IF EXISTS(SELECT * FROM deleted
              WHERE CONVERT(CHAR(10), deleted.KPR_DataOpe, 120)  <= @DataTmp
              AND   deleted.KPR_Bufor = 0)
    BEGIN
      RAISERROR('##OPT32037##%%1%%=%s##',16,1,@DataTmp)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzanie uwzględnienia na Spisie z natury
DECLARE @SpisZNatury INT
SET @SpisZNatury = (SELECT KPR_SpisZNatury FROM deleted)
If (@SpisZNatury > 0)
BEGIN
   RAISERROR('##OPT32057##',16,1)
      Rollback Tran
      Set NoCount Off
      Return
END
-- obsługa kaskadowego uaktualniania zapisów ZapisyKPR
      UPDATE CDN.ZapisyKPR
      SET    CDN.ZapisyKPR.KPR_OrgId = NULL
      FROM   CDN.ZapisyKPR JOIN deleted
      ON     CDN.ZapisyKPR.KPR_OrgId = deleted.KPR_KPRId
-- obsługa kaskadowego uaktualniania zapisów VatNag dla księgowań z VatNag i AutoRozlicz
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.KPR_Zrodlo = 2 OR deleted.KPR_Zrodlo = 3)
    BEGIN
      UPDATE CDN.VatNag
      SET    CDN.VatNag.VaN_KPRId = NULL
      FROM   CDN.VatNag JOIN deleted
      ON     CDN.VatNag.VaN_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 2 OR deleted.KPR_Zrodlo = 3;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z samochodówki
  IF EXISTS (SELECT * FROM deleted WHERE deleted.KPR_Zrodlo = 3)
    BEGIN
-- uaktualnianie zapisów w AutoRolicz
      UPDATE CDN.AutoRozlicz
      SET    CDN.AutoRozlicz.AuR_KPRId = NULL
      FROM   CDN.AutoRozlicz
      JOIN   deleted
      ON     CDN.AutoRozlicz.AuR_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo        = 3;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z RemanentNag
  IF EXISTS (SELECT * FROM deleted WHERE deleted.KPR_Zrodlo = 4)
    BEGIN
      UPDATE CDN.RemanentNag
      SET    CDN.RemanentNag.ReN_KPRId = NULL
      FROM   CDN.RemanentNag
      JOIN   deleted
      ON     CDN.RemanentNag.ReN_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo        = 4;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z TrwaleHist
  IF EXISTS (SELECT * FROM deleted WHERE deleted.KPR_Zrodlo = 7)
    BEGIN
      UPDATE CDN.TrwaleHist
      SET    CDN.TrwaleHist.SrH_KPRId = NULL
      FROM   CDN.TrwaleHist
      JOIN   deleted
      ON     CDN.TrwaleHist.SrH_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo        = 7;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z WyplatyNag
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.KPR_Zrodlo = 5)
    BEGIN
      UPDATE CDN.WyplatyNag
      SET    CDN.WyplatyNag.WyN_KPRId = NULL
      FROM   CDN.WyplatyNag JOIN deleted
      ON     CDN.WyplatyNag.WyN_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 5;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z ListyPlac
  IF EXISTS (SELECT * FROM deleted WHERE deleted.KPR_Zrodlo = 10)
    BEGIN
      UPDATE CDN.ListyPlac
      SET    CDN.ListyPlac.LPl_KPRId = NULL
      FROM   CDN.ListyPlac JOIN deleted
      ON     CDN.ListyPlac.LPl_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 10;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z EwidDodNag
  IF EXISTS (SELECT * FROM deleted WHERE deleted.KPR_Zrodlo = 12)
    BEGIN
      UPDATE CDN.EwidDodNag
      SET    CDN.EwidDodNag.EDN_KPRId = NULL
      FROM   CDN.EwidDodNag JOIN deleted
      ON     CDN.EwidDodNag.EDN_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 12;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z BnkRozKwoty
  IF EXISTS (SELECT * FROM deleted WHERE deleted.KPR_Zrodlo = 13)
    BEGIN
      UPDATE CDN.BnkRozKwoty
      SET    CDN.BnkRozKwoty.BRK_KPRId = NULL
      FROM   CDN.BnkRozKwoty JOIN deleted
      ON     CDN.BnkRozKwoty.BRK_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 13;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z BnkRozKwotyMW
  IF EXISTS (SELECT * FROM deleted WHERE deleted.KPR_Zrodlo = 43)
    BEGIN
      UPDATE CDN.BnkRozKwotyMW
      SET    CDN.BnkRozKwotyMW.BRKMW_KPRId = NULL
      FROM   CDN.BnkRozKwotyMW JOIN deleted
      ON     CDN.BnkRozKwotyMW.BRKMW_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 43;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z BnkZapisy
  IF EXISTS (SELECT * FROM deleted WHERE deleted.KPR_Zrodlo = 14)
    BEGIN
      UPDATE CDN.BnkZapisy
      SET    CDN.BnkZapisy.BZp_KPRId = NULL
      FROM   CDN.BnkZapisy JOIN deleted
      ON     CDN.BnkZapisy.BZp_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 14;
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych dla księgowań z DlgNag
  IF EXISTS (SELECT * FROM deleted WHERE deleted.KPR_Zrodlo = 108)
    BEGIN
      UPDATE CDN.DlgNag
      SET    CDN.DlgNag.DLN_KPRId = NULL
      FROM   CDN.DlgNag JOIN deleted
      ON     CDN.DlgNag.DLN_KPRId = deleted.KPR_KPRId
      WHERE  deleted.KPR_Zrodlo = 108;
    END
-- Skasowanie relacji do dokumentów z biblioteki  (RZ )
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1008 AND DoR_DokumentId=deleted.KPR_KPRId
-- Skasowanie korekt związanych z zapisem
  DELETE CDN.DPD
  FROM CDN.DPD JOIN deleted
  ON CDN.DPD.DPD_KPRId = deleted.KPR_KPRID
  WHERE DPD_KPRId = deleted.KPR_KPRID
  SET NOCOUNT OFF
