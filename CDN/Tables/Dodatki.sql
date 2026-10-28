CREATE TABLE [CDN].[Dodatki] (
    [DOD_DodId]             INT           IDENTITY (1, 1) NOT NULL,
    [DOD_PraId]             INT           NOT NULL,
    [DOD_Nazwa]             NVARCHAR (40) NOT NULL,
    [DOD_RdzId]             INT           NULL,
    [DOD_Rodzaj]            INT           NOT NULL,
    [DOD_Nieaktywny]        TINYINT       CONSTRAINT [DF_DOD_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [DOD_Umowa]             TINYINT       CONSTRAINT [DF_DOD_Umowa] DEFAULT ((0)) NOT NULL,
    [DOD_WliczChorWOkresie] TINYINT       CONSTRAINT [DF_DOD_WliczChorWOkresie] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [DOD_Primary] PRIMARY KEY CLUSTERED ([DOD_DodId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DODPraLink] FOREIGN KEY ([DOD_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [DODPraLink]
    ON [CDN].[Dodatki]([DOD_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DODRdzLink]
    ON [CDN].[Dodatki]([DOD_RdzId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Dodatki2WypSkladniki_Delete_Trigger
  ON CDN.Dodatki
  FOR DELETE
AS
SET NOCOUNT ON
-- obsługa sprawdzania relacji restrict do tabeli CDN.WypSkladniki
IF EXISTS (SELECT * FROM CDN.WypSkladniki JOIN deleted ON Dod_DodId = WPS_ZrodloId
           WHERE CDN.WypSkladniki.WPS_RodzajZrodla=4)
  BEGIN
 RAISERROR('##OPT32559##', 16, 1)
    --RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą WypSkladniki). ', 16, 1)--ERR_SQL_Place_WypSkladnikiPowiazanieWPS 32559
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Dodatki_InsertUpdateHandler
  ON CDN.Dodatki
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.DOD_RdzId IS NOT NULL)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.Rodzina ON
                    inserted.DOD_RdzId = CDN.Rodzina.RDZ_RdzId
              WHERE CDN.Rodzina.RDZ_RdzId IS NULL AND (inserted.DOD_RdzId IS NOT NULL)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=Rodzina##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
