CREATE TABLE [CDN].[RemanentElem] (
    [ReE_ReEID]                  INT             IDENTITY (1, 1) NOT NULL,
    [ReE_ReNID]                  INT             NOT NULL,
    [ReE_Lp]                     INT             NOT NULL,
    [ReE_TwrId]                  INT             NULL,
    [ReE_Nazwa]                  NVARCHAR (255)  NOT NULL,
    [ReE_Jm]                     NVARCHAR (20)   NOT NULL,
    [ReE_MetodaOblicz]           TINYINT         NOT NULL,
    [ReE_Ilosc]                  DECIMAL (15, 4) NOT NULL,
    [ReE_Cena]                   DECIMAL (17, 4) NOT NULL,
    [ReE_Wartosc]                DECIMAL (15, 2) NOT NULL,
    [ReE_CenaNabycia]            DECIMAL (17, 4) NOT NULL,
    [ReE_Opis]                   NVARCHAR (254)  NOT NULL,
    [ReE_OpeZalID]               INT             NULL,
    [ReE_StaZalId]               INT             NULL,
    [ReE_TS_Zal]                 DATETIME        NOT NULL,
    [ReE_OpeModID]               INT             NULL,
    [ReE_StaModId]               INT             NULL,
    [ReE_TS_Mod]                 DATETIME        NOT NULL,
    [ReE_OpeModKod]              VARCHAR (20)    CONSTRAINT [DF_ReE_OpeModKod] DEFAULT ('') NOT NULL,
    [ReE_OpeModNazwisko]         NVARCHAR (50)   CONSTRAINT [DF_ReE_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [ReE_OpeZalKod]              VARCHAR (20)    CONSTRAINT [DF_ReE_OpeZalKod] DEFAULT ('') NOT NULL,
    [ReE_OpeZalNazwisko]         NVARCHAR (50)   CONSTRAINT [DF_ReE_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [ReE_CenaZCzteremaMiejscami] TINYINT         CONSTRAINT [DF_ReE_CenaZCzteremaMiejscami] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [ReE_Primary] PRIMARY KEY CLUSTERED ([ReE_ReEID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ReELp] FOREIGN KEY ([ReE_ReNID]) REFERENCES [CDN].[RemanentNag] ([ReN_ReNID]) ON DELETE CASCADE,
    CONSTRAINT [FK_ReETowar] FOREIGN KEY ([ReE_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ReELp]
    ON [CDN].[RemanentElem]([ReE_ReNID] ASC, [ReE_Lp] ASC, [ReE_ReEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ReNNazwa]
    ON [CDN].[RemanentElem]([ReE_ReNID] ASC, [ReE_Nazwa] ASC, [ReE_ReEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [ReETowar]
    ON [CDN].[RemanentElem]([ReE_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.RemanentElem_InsertUpdateDelete_Trigger
  ON CDN.RemanentElem
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
--Sprawdzenie, czy nagłówek został zaksięgowany
  IF (EXISTS (SELECT * FROM inserted
             JOIN   CDN.RemanentNag
             ON     inserted.ReE_ReNId = CDN.RemanentNag.ReN_ReNId
             WHERE  CDN.RemanentNag.ReN_KPRId IS NOT NULL)) OR
     (EXISTS (SELECT * FROM deleted
             JOIN   CDN.RemanentNag
             ON     deleted.ReE_ReNId = CDN.RemanentNag.ReN_ReNId
             WHERE  CDN.RemanentNag.ReN_KPRId IS NOT NULL))
    BEGIN
          RAISERROR('##OPT32031##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
--Obliczenie wartości pola ReE_Ilosc
  IF EXISTS (SELECT * FROM inserted WHERE inserted.ReE_MetodaOblicz = 1)
    BEGIN
      UPDATE CDN.RemanentElem
      SET    CDN.RemanentElem.ReE_Ilosc =
             CASE WHEN CDN.RemanentElem.ReE_Cena = 0 THEN 0
             ELSE CDN.RemanentElem.ReE_Wartosc / CDN.RemanentElem.ReE_Cena END
      FROM  inserted
      JOIN  CDN.RemanentElem
      ON    inserted.ReE_ReEId = CDN.RemanentElem.ReE_ReEId
      WHERE inserted.ReE_MetodaOblicz = 1 AND
             CDN.RemanentElem.ReE_Ilosc <>
             CASE WHEN CDN.RemanentElem.ReE_Cena = 0 THEN 0
             ELSE ROUND(CDN.RemanentElem.ReE_Wartosc / CDN.RemanentElem.ReE_Cena, 4) END
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32032##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
--Obliczenie wartości pola ReE_Cena
  IF EXISTS (SELECT * FROM inserted WHERE inserted.ReE_MetodaOblicz = 2)
    BEGIN
      UPDATE CDN.RemanentElem
      SET    CDN.RemanentElem.ReE_Cena =
             CASE WHEN CDN.RemanentElem.ReE_Ilosc = 0 THEN 0
             ELSE CDN.RemanentElem.ReE_Wartosc / CDN.RemanentElem.ReE_Ilosc END
      FROM   inserted
      JOIN   CDN.RemanentElem
      ON     inserted.ReE_ReEId = CDN.RemanentElem.ReE_ReEId
      WHERE  inserted.ReE_MetodaOblicz = 2 AND
             CDN.RemanentElem.ReE_Cena <>
             CASE WHEN CDN.RemanentElem.ReE_Ilosc = 0 THEN 0
             ELSE ROUND(CDN.RemanentElem.ReE_Wartosc / CDN.RemanentElem.ReE_Ilosc, 2) END
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32033##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
--Obliczenie wartości pola ReE_Wartosc
  IF EXISTS (SELECT * FROM inserted WHERE inserted.ReE_MetodaOblicz = 3)
    BEGIN
      UPDATE CDN.RemanentElem
      SET CDN.RemanentElem.ReE_Wartosc = CDN.RemanentElem.ReE_Ilosc * CDN.RemanentElem.ReE_Cena
      FROM  inserted
      JOIN  CDN.RemanentElem
      ON    inserted.ReE_ReEId = CDN.RemanentElem.ReE_ReEId
      WHERE inserted.ReE_MetodaOblicz = 3 AND CDN.RemanentElem.ReE_Wartosc <> ROUND(CDN.RemanentElem.ReE_Ilosc * CDN.RemanentElem.ReE_Cena, 2)
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32034##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
--Aktualizacja wartości nagłówka przy kasowaniu elementów
  UPDATE CDN.RemanentNag
  SET CDN.RemanentNag.ReN_Wartosc = CDN.RemanentNag.ReN_Wartosc -
  (SELECT SUM(CASE WHEN deleted.ReE_MetodaOblicz = 3
                   THEN ROUND(deleted.ReE_Ilosc * deleted.ReE_Cena, 2)
                   ELSE deleted.ReE_Wartosc END)
   FROM deleted WHERE deleted.ReE_ReNId = CDN.RemanentNag.ReN_ReNId)
  FROM deleted JOIN CDN.RemanentNag ON deleted.ReE_ReNId = CDN.RemanentNag.ReN_ReNId
  LEFT OUTER JOIN inserted ON deleted.ReE_ReEId = inserted.ReE_ReEId
  WHERE inserted.ReE_Wartosc is NULL OR
        (CASE WHEN deleted.ReE_MetodaOblicz = 3 THEN ROUND(deleted.ReE_Ilosc * deleted.ReE_Cena, 2) ELSE deleted.ReE_Wartosc END) <>
        (CASE WHEN inserted.ReE_MetodaOblicz = 3 THEN ROUND(inserted.ReE_Ilosc * inserted.ReE_Cena, 2) ELSE inserted.ReE_Wartosc END)
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32020##%%1%%=RemanentNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Aktualizacja wartości nagłówka przy dodawaniu elementów
  UPDATE CDN.RemanentNag
  SET CDN.RemanentNag.ReN_Wartosc = CDN.RemanentNag.ReN_Wartosc +
  (SELECT SUM(CASE WHEN inserted.ReE_MetodaOblicz = 3
                   THEN ROUND(inserted.ReE_Ilosc * inserted.ReE_Cena ,2)
                   ELSE inserted.ReE_Wartosc END)
   FROM inserted WHERE inserted.ReE_ReNId = CDN.RemanentNag.ReN_ReNId)
  FROM inserted JOIN CDN.RemanentNag ON inserted.ReE_ReNId = CDN.RemanentNag.ReN_ReNId
  LEFT OUTER JOIN deleted ON deleted.ReE_ReEId = inserted.ReE_ReEId
  WHERE deleted.ReE_Wartosc is NULL OR
        (CASE WHEN deleted.ReE_MetodaOblicz = 3 THEN ROUND(deleted.ReE_Ilosc * deleted.ReE_Cena, 2) ELSE deleted.ReE_Wartosc END) <>
        (CASE WHEN inserted.ReE_MetodaOblicz = 3 THEN ROUND(inserted.ReE_Ilosc * inserted.ReE_Cena, 2) ELSE inserted.ReE_Wartosc END)
-- Rollback transakcji w przypadku błędu
      IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32020##%%1%%=RemanentNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
  SET NOCOUNT OFF
