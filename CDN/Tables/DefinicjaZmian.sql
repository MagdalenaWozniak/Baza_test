CREATE TABLE [CDN].[DefinicjaZmian] (
    [DFZ_DfzId]        INT             IDENTITY (1, 1) NOT NULL,
    [DFZ_Nazwa]        NVARCHAR (128)  NOT NULL,
    [DFZ_Pole1]        INT             NULL,
    [DFZ_Pole2]        INT             NULL,
    [DFZ_Pole3]        INT             NULL,
    [DFZ_Wzor1]        NVARCHAR (254)  NOT NULL,
    [DFZ_Wzor2]        NVARCHAR (254)  NOT NULL,
    [DFZ_Wzor3]        NVARCHAR (254)  NOT NULL,
    [DFZ_Wzor]         NVARCHAR (2048) NOT NULL,
    [DFZ_Interaktywna] TINYINT         NOT NULL,
    [DFZ_Aktualizacja] TINYINT         NOT NULL,
    [DFZ_Standardowy]  INT             NOT NULL,
    [DFZ_Nieaktywny]   TINYINT         NOT NULL,
    [DFZ_Zaawansowany] TINYINT         NOT NULL,
    CONSTRAINT [DFZ_Primary] PRIMARY KEY CLUSTERED ([DFZ_DfzId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DFZPole1] FOREIGN KEY ([DFZ_Pole1]) REFERENCES [CDN].[DanePlacMod] ([DPM_DpmId]),
    CONSTRAINT [FK_DFZPole2] FOREIGN KEY ([DFZ_Pole2]) REFERENCES [CDN].[DanePlacMod] ([DPM_DpmId]),
    CONSTRAINT [FK_DFZPole3] FOREIGN KEY ([DFZ_Pole3]) REFERENCES [CDN].[DanePlacMod] ([DPM_DpmId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DFZNazwa]
    ON [CDN].[DefinicjaZmian]([DFZ_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DefinicjaZmian_Delete_Trigger
  ON CDN.DefinicjaZmian
  FOR DELETE
AS
  SET NOCOUNT ON
    IF EXISTS (SELECT * FROM deleted WHERE deleted.DFZ_Standardowy <> 0)
    BEGIN
      RAISERROR('##OPT32501##', 16, 1)--RAISERROR('Nie można kasować standardowego wzorca zmiany pola. ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacWzorca
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
