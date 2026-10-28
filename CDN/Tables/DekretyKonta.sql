CREATE TABLE [CDN].[DekretyKonta] (
    [DeK_DeKId]    INT             IDENTITY (1, 1) NOT NULL,
    [DeK_DeEId]    INT             NOT NULL,
    [DeK_DeNId]    INT             NOT NULL,
    [DeK_DziId]    INT             NOT NULL,
    [DeK_AccId]    INT             NOT NULL,
    [DeK_Strona]   TINYINT         NOT NULL,
    [DeK_DataDok]  DATETIME        NOT NULL,
    [DeK_Kwota]    DECIMAL (15, 2) NOT NULL,
    [DeK_KwotaWal] DECIMAL (15, 2) NOT NULL,
    [DeK_Waluta]   VARCHAR (3)     NOT NULL,
    [DeK_Bufor]    TINYINT         NOT NULL,
    CONSTRAINT [DeK_Primary] PRIMARY KEY CLUSTERED ([DeK_DeKId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeKKonto] FOREIGN KEY ([DeK_AccId]) REFERENCES [CDN].[Konta] ([Acc_AccId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DeKElement]
    ON [CDN].[DekretyKonta]([DeK_DeEId] ASC, [DeK_Strona] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeKNaglowek]
    ON [CDN].[DekretyKonta]([DeK_DeNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DeEDziennik]
    ON [CDN].[DekretyKonta]([DeK_DziId] ASC, [DeK_AccId] ASC, [DeK_DataDok] ASC, [DeK_DeEId] ASC, [DeK_Strona] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DeKKonto]
    ON [CDN].[DekretyKonta]([DeK_AccId] ASC, [DeK_DataDok] ASC, [DeK_DeEId] ASC, [DeK_Strona] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeK_DETA]
    ON [CDN].[DekretyKonta]([DeK_DeEId] ASC, [DeK_AccId] ASC, [DeK_DataDok] ASC)
    INCLUDE([DeK_Strona], [DeK_Kwota], [DeK_KwotaWal], [DeK_Bufor]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DekretyKonta_InsertUpdateDelete_Trigger
  ON CDN.DekretyKonta
  FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @AccId    INT
DECLARE @DataDok  DATETIME
DECLARE @RokMies  INT
DECLARE @Bufor    SMALLINT
DECLARE @Kwota    NUMERIC(15,2)
DECLARE @KwotaWal NUMERIC(15,2)
DECLARE @Strona   INT
DECLARE @SqlStm   NVARCHAR(1000)
-- Aktualizacja skasowanych
IF EXISTS (SELECT * FROM deleted)
  BEGIN
    DECLARE Skasowane CURSOR LOCAL FAST_FORWARD FOR
      SELECT DeK_AccId, DeK_DataDok, DeK_Bufor, DeK_Kwota, DeK_KwotaWal, DeK_Strona FROM deleted
    OPEN Skasowane
    WHILE 1 = 1
      BEGIN
        FETCH NEXT FROM Skasowane INTO  @AccId, @DataDok, @Bufor, @Kwota, @KwotaWal, @Strona
        IF @@FETCH_STATUS <> 0 BREAK
        -- Aktualizacja obrotów
           SET @RokMies = 100 * YEAR(@DataDok) + MONTH(@DataDok)
           UPDATE CDN.Obroty
           SET
             Obr_ObrotyWnBufor    = Obr_ObrotyWnBufor    - (CASE WHEN @Strona = 1 THEN @Kwota ELSE 0 END),
             Obr_ObrotyMaBufor    = Obr_ObrotyMaBufor    - (CASE WHEN @Strona = 2 THEN @Kwota ELSE 0 END),
             Obr_ObrotyWn         = Obr_ObrotyWn         - (CASE WHEN @Strona = 1 AND @Bufor = 0 THEN @Kwota ELSE 0 END),
             Obr_ObrotyMa         = Obr_ObrotyMa         - (CASE WHEN @Strona = 2 AND @Bufor = 0 THEN @Kwota ELSE 0 END),
             Obr_ObrotyWnBuforWal = Obr_ObrotyWnBuforWal - (CASE WHEN @Strona = 1 THEN @KwotaWal ELSE 0 END),
             Obr_ObrotyMaBuforWal = Obr_ObrotyMaBuforWal - (CASE WHEN @Strona = 2 THEN @KwotaWal ELSE 0 END),
             Obr_ObrotyWnWal      = Obr_ObrotyWnWal      - (CASE WHEN @Strona = 1 AND @Bufor = 0 THEN @KwotaWal ELSE 0 END),
             Obr_ObrotyMaWal      = Obr_ObrotyMaWal      - (CASE WHEN @Strona = 2 AND @Bufor = 0 THEN @KwotaWal ELSE 0 END)
           WHERE Obr_RokMies = @RokMies AND Obr_Typ = 0 AND Obr_AccId = @AccId
      END
    CLOSE Skasowane
    DEALLOCATE Skasowane
  END
IF EXISTS (SELECT * FROM inserted)
  BEGIN
    DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR
       SELECT DeK_AccId, DeK_DataDok, DeK_Bufor, DeK_Kwota, DeK_KwotaWal, DeK_Strona FROM inserted
    OPEN Dodane
    WHILE 1 = 1
      BEGIN
        FETCH NEXT FROM Dodane INTO  @AccId, @DataDok, @Bufor, @Kwota, @KwotaWal, @Strona
        IF @@FETCH_STATUS <> 0 BREAK
        SET @RokMies = 100 * YEAR(@DataDok) + MONTH(@DataDok)
        -- Dodanie wiersza w obrotach
        IF @AccId IS NOT NULL
          IF NOT EXISTS (SELECT * FROM CDN.Obroty WHERE Obr_RokMies = @RokMies AND Obr_Typ = 0 AND Obr_AccId = @AccId)
            INSERT INTO CDN.Obroty (Obr_AccId, Obr_RokMies, Obr_Typ, Obr_ObrotyWn, Obr_ObrotyMa, Obr_ObrotyWnBufor, Obr_ObrotyMaBufor, Obr_ObrotyWnWal, Obr_ObrotyMaWal, Obr_ObrotyWnBuforWal, Obr_ObrotyMaBuforWal)
                            VALUES (@AccId,    @RokMies,    0,       0,            0,            0,                 0,                 0,               0,                0,                   0)
        -- Aktualizacja obrotów
           UPDATE CDN.Obroty
           SET
             Obr_ObrotyWnBufor    = Obr_ObrotyWnBufor    + (CASE WHEN @Strona = 1 THEN @Kwota ELSE 0 END),
             Obr_ObrotyMaBufor    = Obr_ObrotyMaBufor    + (CASE WHEN @Strona = 2 THEN @Kwota ELSE 0 END),
             Obr_ObrotyWn         = Obr_ObrotyWn         + (CASE WHEN @Strona = 1 AND @Bufor = 0 THEN @Kwota ELSE 0 END),
             Obr_ObrotyMa         = Obr_ObrotyMa         + (CASE WHEN @Strona = 2 AND @Bufor = 0 THEN @Kwota ELSE 0 END),
             Obr_ObrotyWnBuforWal = Obr_ObrotyWnBuforWal + (CASE WHEN @Strona = 1 THEN @KwotaWal ELSE 0 END),
             Obr_ObrotyMaBuforWal = Obr_ObrotyMaBuforWal + (CASE WHEN @Strona = 2 THEN @KwotaWal ELSE 0 END),
             Obr_ObrotyWnWal      = Obr_ObrotyWnWal      + (CASE WHEN @Strona = 1 AND @Bufor = 0 THEN @KwotaWal ELSE 0 END),
             Obr_ObrotyMaWal      = Obr_ObrotyMaWal      + (CASE WHEN @Strona = 2 AND @Bufor = 0 THEN @KwotaWal ELSE 0 END)
           WHERE Obr_RokMies = @RokMies AND Obr_Typ = 0 AND Obr_AccId = @AccId
      END
    CLOSE Dodane
    DEALLOCATE Dodane
  END
SET NOCOUNT OFF
