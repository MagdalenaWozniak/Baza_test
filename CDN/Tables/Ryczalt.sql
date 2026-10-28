CREATE TABLE [CDN].[Ryczalt] (
    [RYC_RycID]          INT             IDENTITY (1, 1) NOT NULL,
    [RYC_Bufor]          SMALLINT        NOT NULL,
    [RYC_RokMies]        INT             NOT NULL,
    [RYC_Lp]             INT             NOT NULL,
    [RYC_DataPrz]        DATETIME        NOT NULL,
    [RYC_DataWpi]        DATETIME        NOT NULL,
    [RYC_Dokument]       VARCHAR (256)   NOT NULL,
    [RYC_Przychod1]      DECIMAL (15, 2) NOT NULL,
    [RYC_Przychod2]      DECIMAL (15, 2) NOT NULL,
    [RYC_Przychod3]      DECIMAL (15, 2) NOT NULL,
    [RYC_Przychod4]      DECIMAL (15, 2) NOT NULL,
    [RYC_Przychod5]      DECIMAL (15, 2) NOT NULL,
    [RYC_Przychod6]      DECIMAL (15, 2) NOT NULL,
    [RYC_KatID]          INT             NULL,
    [RYC_Kategoria]      VARCHAR (50)    NOT NULL,
    [RYC_Skreslony]      TINYINT         NOT NULL,
    [RYC_Zrodlo]         TINYINT         NOT NULL,
    [RYC_OpeZalID]       INT             NULL,
    [RYC_StaZalId]       INT             NULL,
    [RYC_TS_Zal]         DATETIME        NOT NULL,
    [RYC_OpeModID]       INT             NULL,
    [RYC_StaModId]       INT             NULL,
    [RYC_TS_Mod]         DATETIME        NOT NULL,
    [RYC_Przychod7]      DECIMAL (15, 2) CONSTRAINT [DF_RYC_Przychod7] DEFAULT ((0)) NOT NULL,
    [RYC_DokTyp]         INT             CONSTRAINT [DF_RYC_DokTyp] DEFAULT ((0)) NOT NULL,
    [RYC_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_RYC_OpeModKod] DEFAULT ('') NOT NULL,
    [RYC_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_RYC_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [RYC_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_RYC_OpeZalKod] DEFAULT ('') NOT NULL,
    [RYC_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_RYC_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [RYC_Przychod8]      DECIMAL (15, 2) CONSTRAINT [DF_RYC_Przychod8] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [RYC_Primary] PRIMARY KEY CLUSTERED ([RYC_RycID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KeyKategoria] FOREIGN KEY ([RYC_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KeyKategoria]
    ON [CDN].[Ryczalt]([RYC_KatID] ASC, [RYC_DataPrz] ASC, [RYC_RycID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [RycLP]
    ON [CDN].[Ryczalt]([RYC_Bufor] ASC, [RYC_RokMies] ASC, [RYC_Lp] ASC, [RYC_RycID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [RycChronoBuf]
    ON [CDN].[Ryczalt]([RYC_Bufor] ASC, [RYC_DataPrz] ASC, [RYC_RycID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [RycChrono]
    ON [CDN].[Ryczalt]([RYC_DataPrz] ASC, [RYC_RycID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Ryczalt_InsertUpdate_Trigger
  ON CDN.Ryczalt
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Sprawdzanie miesiąca zamkniętego
  DECLARE @DataZamkniecia CHAR(10)
  SET @DataZamkniecia = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1300)
    IF EXISTS(SELECT * FROM deleted
              WHERE CONVERT(CHAR(10), deleted.Ryc_DataPrz, 120)  <= @DataZamkniecia
              AND   deleted.Ryc_Bufor = 0)
    OR EXISTS(SELECT * FROM inserted
              WHERE CONVERT(CHAR(10), inserted.Ryc_DataPrz, 120) <= @DataZamkniecia
              AND   inserted.Ryc_Bufor = 0)
    BEGIN
      RAISERROR('##OPT32037##%%1%%=%s##', 16, 1, @DataZamkniecia)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
--Ustalenie wartości Ryc_RokMies
  IF EXISTS (SELECT * FROM inserted
             WHERE inserted.Ryc_RokMies <> 100 *  YEAR(inserted.Ryc_DataPrz)
                                          + MONTH(inserted.Ryc_DataPrz))
    BEGIN
      UPDATE CDN.Ryczalt
      SET    CDN.Ryczalt.Ryc_RokMies = 100 *  YEAR(CDN.Ryczalt.Ryc_DataPrz)
                                     + MONTH(CDN.Ryczalt.Ryc_DataPrz)
      FROM   CDN.Ryczalt
      JOIN   inserted
      ON     CDN.Ryczalt.Ryc_RycId = inserted.Ryc_RycId
      WHERE  CDN.Ryczalt.Ryc_RokMies <> 100 *  YEAR(CDN.Ryczalt.Ryc_DataPrz)
                                      + MONTH(CDN.Ryczalt.Ryc_DataPrz);
-- Rollback transakcji w przypadku błędu
          IF @@ERROR <> 0
            BEGIN
              RAISERROR('##OPT32020##%%1%%=Ryczalt##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
            END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych VatNag
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.Ryc_RycId = inserted.Ryc_RycId
             WHERE deleted.Ryc_Zrodlo = 2 AND inserted.Ryc_Skreslony = 1)
    BEGIN
      UPDATE CDN.VatNag
        SET CDN.VatNag.VaN_RycId = NULL
      FROM CDN.VatNag
        JOIN deleted  ON CDN.VatNag.VaN_RycId = deleted.Ryc_RycId
        JOIN inserted ON CDN.VatNag.VaN_RycId = inserted.Ryc_RycId
        WHERE deleted.Ryc_Zrodlo = 2 AND inserted.Ryc_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=VatNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych EwidDodNag
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.Ryc_RycId = inserted.Ryc_RycId
             WHERE deleted.Ryc_Zrodlo = 12 AND inserted.Ryc_Skreslony = 1)
    BEGIN
      UPDATE CDN.EwidDodNag
        SET CDN.EwidDodNag.EDN_RycId = NULL
      FROM CDN.EwidDodNag
        JOIN deleted  ON CDN.EwidDodNag.EDN_RycId = deleted.Ryc_RycId
        JOIN inserted ON CDN.EwidDodNag.EDN_RycId = inserted.Ryc_RycId
        WHERE deleted.Ryc_Zrodlo = 12 AND inserted.Ryc_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=EwidDodNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- Zerowanie wskaźnika Ryc_Zrodlo w zapisach skreślonych
  IF EXISTS (SELECT * FROM deleted JOIN inserted
             ON deleted.Ryc_RycId = inserted.Ryc_RycId
             WHERE deleted.Ryc_Zrodlo <> 0 AND inserted.Ryc_Skreslony = 1)
    BEGIN
      UPDATE CDN.Ryczalt
        SET CDN.Ryczalt.Ryc_Zrodlo = 0
      FROM CDN.Ryczalt
        JOIN deleted  ON CDN.Ryczalt.Ryc_RycId = deleted.Ryc_RycId
        JOIN inserted ON CDN.Ryczalt.Ryc_RycId = inserted.Ryc_RycId
        WHERE deleted.Ryc_Zrodlo <> 0 AND inserted.Ryc_Skreslony = 1;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32020##%%1%%=Ryczalt##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Ryczalt_Delete_Trigger
  ON CDN.Ryczalt
  FOR DELETE
AS
  SET NOCOUNT ON
-- Sprawdzanie miesiąca zamkniętego
  DECLARE @DataZamkniecia CHAR(10)
  SET @DataZamkniecia = (SELECT Fir_Wartosc FROM CDN.Firma WHERE Fir_Numer = 1300)
    IF EXISTS(SELECT * FROM deleted
              WHERE CONVERT(CHAR(10), deleted.Ryc_DataPrz, 120)  <= @DataZamkniecia
              AND   deleted.Ryc_Bufor = 0)
    BEGIN
      RAISERROR('##OPT32037##%%1%%=%s##',16,1,@DataZamkniecia)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych VatNag
  IF EXISTS (SELECT * FROM deleted WHERE deleted.Ryc_Zrodlo = 2)
    BEGIN
      UPDATE CDN.VatNag
        SET CDN.VatNag.VaN_RycId = NULL
      FROM CDN.VatNag JOIN deleted
        ON CDN.VatNag.VaN_RycId = deleted.Ryc_RycId
        WHERE deleted.Ryc_Zrodlo = 2;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=VatNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowych EwidDodNag
  IF EXISTS (SELECT * FROM deleted WHERE deleted.Ryc_Zrodlo = 12)
    BEGIN
      UPDATE CDN.EwidDodNag
        SET CDN.EwidDodNag.EDN_RycId = NULL
      FROM CDN.EwidDodNag JOIN deleted
        ON CDN.EwidDodNag.EDN_RycId = deleted.Ryc_RycId
        WHERE deleted.Ryc_Zrodlo = 12;
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32035##%%1%%=EwidDodNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- obsługa kaskadowego uaktualniania zapisów źródłowcyh BnkRozKwoty
  IF EXISTS (SELECT * FROM deleted WHERE deleted.RYC_Zrodlo = 13)
 BEGIN
   UPDATE CDN.BnkRozKwoty
     SET CDN.BnkRozKwoty.BRK_RycID = NULL
   FROM CDN.BnkRozKwoty JOIN deleted
     ON CDN.BnkRozKwoty.BRK_RycID = deleted.Ryc_RycID
  WHERE deleted.Ryc_Zrodlo = 13;
-- Rollback transakcji w przypadku błędu
   IF @@ERROR <> 0
     BEGIN
    RAISERROR('##OPT32035##%%1%%=BnkRozKwoty##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
 END
 -- obsługa kaskadowego uaktualniania zapisów źródłowcyh BnkRozKwotyMW
  IF EXISTS (SELECT * FROM deleted WHERE deleted.RYC_Zrodlo = 43)
 BEGIN
   UPDATE CDN.BnkRozKwotyMW
     SET CDN.BnkRozKwotyMW.BRKMW_RycID = NULL
   FROM CDN.BnkRozKwotyMW JOIN deleted
     ON CDN.BnkRozKwotyMW.BRKMW_RycID = deleted.Ryc_RycID
  WHERE deleted.Ryc_Zrodlo = 43;
-- Rollback transakcji w przypadku błędu
   IF @@ERROR <> 0
     BEGIN
    RAISERROR('##OPT32035##%%1%%=BnkRozKwotyMW##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
 END
-- Skasowanie relacji do dokumentów z biblioteki  (RZ )
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1009 AND DoR_DokumentId=deleted.Ryc_RycId
  SET NOCOUNT OFF
