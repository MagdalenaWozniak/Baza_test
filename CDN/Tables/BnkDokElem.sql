CREATE TABLE [CDN].[BnkDokElem] (
    [BDE_BDEId]   INT             IDENTITY (1, 1) NOT NULL,
    [BDE_BDNId]   INT             NOT NULL,
    [BDE_DokTyp]  NVARCHAR (20)   NOT NULL,
    [BDE_DokId]   INT             NULL,
    [BDE_Numer]   NVARCHAR (30)   NOT NULL,
    [BDE_Opis]    NVARCHAR (254)  NOT NULL,
    [BDE_DataDok] DATETIME        NOT NULL,
    [BDE_Termin]  DATETIME        NOT NULL,
    [BDE_Kwota1]  DECIMAL (15, 2) NOT NULL,
    [BDE_Kwota2]  DECIMAL (15, 2) NOT NULL,
    [BDE_Kwota]   DECIMAL (15, 2) NOT NULL,
    CONSTRAINT [BDE_Primary] PRIMARY KEY CLUSTERED ([BDE_BDEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BDENaglowek] FOREIGN KEY ([BDE_BDNId]) REFERENCES [CDN].[BnkDokNag] ([BDN_BDNId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BDENaglowek]
    ON [CDN].[BnkDokElem]([BDE_BDNId] ASC, [BDE_BDEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BDEDokument]
    ON [CDN].[BnkDokElem]([BDE_DokId] ASC, [BDE_DokTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkDokElem_InsertUpdateHandler
  ON CDN.BnkDokElem
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BDE_DokTyp=2)
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkZapisy ON
                    inserted.BDE_DokId = CDN.BnkZapisy.BZp_BZpId
              WHERE CDN.BnkZapisy.BZp_BZpId IS NULL AND (inserted.BDE_DokTyp=2)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkZapisy##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BDE_DokTyp=1)
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkZdarzenia ON
                    inserted.BDE_DokId = CDN.BnkZdarzenia.BZd_BZdId
              WHERE CDN.BnkZdarzenia.BZd_BZdId IS NULL AND (inserted.BDE_DokTyp=1)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkZdarzenia##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
