CREATE TABLE [CDN].[Wyposazenie] (
    [Wyp_WypID]                   INT             IDENTITY (1, 1) NOT NULL,
    [Wyp_Lp]                      INT             NOT NULL,
    [Wyp_DokumentID]              INT             NULL,
    [Wyp_DokumentTyp]             INT             NULL,
    [Wyp_DokumentNr]              VARCHAR (30)    NULL,
    [Wyp_DataZak]                 DATETIME        NOT NULL,
    [Wyp_NumerKPR]                NVARCHAR (20)   NOT NULL,
    [Wyp_Nazwa]                   NVARCHAR (50)   NOT NULL,
    [Wyp_KatID]                   INT             NULL,
    [Wyp_Kategoria]               VARCHAR (50)    NOT NULL,
    [Wyp_NrInwent]                NVARCHAR (20)   NOT NULL,
    [Wyp_WartoscZakup]            DECIMAL (15, 2) NOT NULL,
    [Wyp_Ilosc]                   DECIMAL (15, 4) NULL,
    [Wyp_JednostkaMiary]          NVARCHAR (20)   NULL,
    [Wyp_PrcID]                   INT             NULL,
    [Wyp_PrcNazwisko]             NVARCHAR (100)  NOT NULL,
    [Wyp_DataLikw]                DATETIME        NULL,
    [Wyp_Stan]                    TINYINT         NOT NULL,
    [Wyp_Likwidacja]              NVARCHAR (50)   NOT NULL,
    [Wyp_LikwDokument]            NVARCHAR (256)  NOT NULL,
    [Wyp_Opis]                    NVARCHAR (254)  NOT NULL,
    [Wyp_ImportAppId]             VARCHAR (5)     NULL,
    [Wyp_ImportRowId]             VARCHAR (36)    NULL,
    [Wyp_OpeZalID]                INT             NULL,
    [Wyp_StaZalId]                INT             NULL,
    [Wyp_TS_Zal]                  DATETIME        NOT NULL,
    [Wyp_OpeModID]                INT             NULL,
    [Wyp_StaModId]                INT             NULL,
    [Wyp_TS_Mod]                  DATETIME        NOT NULL,
    [Wyp_KodKreskowy]             VARCHAR (128)   CONSTRAINT [DF_Wyp_KodKreskowy] DEFAULT ('') NOT NULL,
    [Wyp_UniqueKodKreskowyBuster] AS              (case when [Wyp_KodKreskowy]='' then [Wyp_WypID] else (0) end),
    [Wyp_OpeModKod]               VARCHAR (20)    CONSTRAINT [DF_Wyp_OpeModKod] DEFAULT ('') NOT NULL,
    [Wyp_OpeModNazwisko]          NVARCHAR (50)   CONSTRAINT [DF_Wyp_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Wyp_OpeZalKod]               VARCHAR (20)    CONSTRAINT [DF_Wyp_OpeZalKod] DEFAULT ('') NOT NULL,
    [Wyp_OpeZalNazwisko]          NVARCHAR (50)   CONSTRAINT [DF_Wyp_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [Wyp_Primary] PRIMARY KEY CLUSTERED ([Wyp_WypID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WypKategoria] FOREIGN KEY ([Wyp_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_WypPracownik] FOREIGN KEY ([Wyp_PrcID]) REFERENCES [CDN].[PracKod] ([PRA_PraId])
);


GO
CREATE NONCLUSTERED INDEX [WypPracownik]
    ON [CDN].[Wyposazenie]([Wyp_PrcID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WypKategoria]
    ON [CDN].[Wyposazenie]([Wyp_KatID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypLp]
    ON [CDN].[Wyposazenie]([Wyp_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypNazwa]
    ON [CDN].[Wyposazenie]([Wyp_Nazwa] ASC, [Wyp_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WypDokument]
    ON [CDN].[Wyposazenie]([Wyp_DokumentTyp] ASC, [Wyp_DokumentID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypNrInwent]
    ON [CDN].[Wyposazenie]([Wyp_NrInwent] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypKodKreskowy]
    ON [CDN].[Wyposazenie]([Wyp_KodKreskowy] ASC, [Wyp_UniqueKodKreskowyBuster] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WypGUID]
    ON [CDN].[Wyposazenie]([Wyp_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Wyposazenie_Update_Trigger
  ON CDN.Wyposazenie
  FOR UPDATE
AS
  SET NOCOUNT ON
--Sprawdzanie czy nie aktualizowane są kwoty wyposażenia zlikwidowanego
  IF UPDATE (Wyp_WartoscZakup)
   IF EXISTS (SELECT * FROM inserted WHERE Wyp_Stan<>0)
        BEGIN
          RAISERROR('##OPT32378##', 16, 1) -- RAISERROR('Wyposażenie zostało zlikwidowane.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Wyposazenie_InsertUpdate_Trigger
  ON CDN.Wyposazenie
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
 IF (UPDATE(Wyp_DataZak)) AND
  Exists (select * from inserted inner join cdn.WyposazenieAIElem ON WypAIE_WypID = inserted.Wyp_WypID inner join cdn.WyposazenieAINag ON WypAIN_WypAINID = WypAIE_WypAINID WHERE inserted.Wyp_DataZak > WypAIN_DataDok)
 BEGIN
  RAISERROR('##OPT32377##', 16, 1) -- RAISERROR('Wyposażenie zostało wybrane na dokumencie inwentaryzacji. Data zakupu nie może być wcześniejsza niż data wystawienia dokumentu inwentaryzacji, na którym to wyposażenie zostało uwzględnione.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where Wyp_ImportRowId Is Null Or Wyp_ImportRowId = '')
  Update CDN.Wyposazenie Set Wyp_ImportRowId = NewId()
  Where Wyp_WypId In (Select Wyp_WypId From inserted Where Wyp_ImportRowId Is Null Or Wyp_ImportRowId = '')
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Wyposazenie_Delete_Trigger
  ON CDN.Wyposazenie
  FOR DELETE
AS
SET NOCOUNT ON
SET ARITHABORT ON
-- obsługa sprawdzania relacji restrict do tabeli CDN.WyposazenieAIElem
IF EXISTS (SELECT * FROM CDN.WyposazenieAIElem join deleted ON WypAIE_WypID = Wyp_WypID)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=WyposazenieAIElem##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą WyposazenieAIElem). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Skasowanie relacji do dokumentów z biblioteki  (RZ za WJ)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1005 AND DoR_DokumentId=deleted.Wyp_WypId
SET NOCOUNT OFF

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[Wyposazenie_Delete_Trigger]', @order = N'first', @stmttype = N'delete';

