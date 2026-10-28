CREATE TABLE [CDN].[FormyPlatnWaluty] (
    [FPW_FPWId] INT IDENTITY (1, 1) NOT NULL,
    [FPW_FPlId] INT NOT NULL,
    [FPW_BRaId] INT NOT NULL,
    CONSTRAINT [FPW_Primary] PRIMARY KEY CLUSTERED ([FPW_FPWId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_FPWBnkrachunki] FOREIGN KEY ([FPW_BRaId]) REFERENCES [CDN].[BnkRachunki] ([BRa_BRaID]),
    CONSTRAINT [FK_FPWFormyPlatnosci] FOREIGN KEY ([FPW_FPlId]) REFERENCES [CDN].[FormyPlatnosci] ([FPl_FPlId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FPWFormyPlatnosci]
    ON [CDN].[FormyPlatnWaluty]([FPW_FPlId] ASC, [FPW_BRaId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [FPWBnkrachunki]
    ON [CDN].[FormyPlatnWaluty]([FPW_BRaId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.FormyPlatnWaluty_InsertUpdate_Trigger
  ON CDN.FormyPlatnWaluty
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  -- Sprawdzenie waluty systemowej
  If Exists (
    Select * From inserted
    Join CDN.BnkRachunki On FPW_BRaId = BRa_BRaId
    Where BRa_Waluta = ''
    )
    Begin
      RAISERROR('##OPT32331##', 16, 1) -- RAISERROR('Na liście rejestrów walutowych został użyty rejestr w walucie systemowej.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    End
  -- Sprawdzenie duplikacji waluty w obrębie formy płatności
  If Exists (
    Select FPW_FPlId, BRa_waluta From CDN.FormyPlatnWaluty
    Join CDN.BnkRachunki On FPW_BRaId = BRa_BRaId
    Where FPW_FPlId In (Select FPW_FPlId From inserted)
    Group By FPW_FPlId, BRa_waluta
    Having Count(FPW_FPlId) > 1
    )
    Begin
      RAISERROR('##OPT32332##', 16, 1) -- RAISERROR('Wystąpiła duplikacja rejestru walutowego dla formy płatności.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    End
  SET NOCOUNT OFF
