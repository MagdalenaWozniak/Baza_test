CREATE TABLE [CDN].[NotyOdsNag] (
    [NON_NONId]           INT             IDENTITY (1, 1) NOT NULL,
    [NON_Bufor]           SMALLINT        NOT NULL,
    [NON_DDfId]           INT             NULL,
    [NON_NumerNr]         INT             NOT NULL,
    [NON_NumerString]     VARCHAR (31)    NOT NULL,
    [NON_NumerPelny]      AS              ([CDN].[FN_NUMERPELNY]([NON_NUMERNR],[NON_NUMERSTRING])),
    [NON_DataDok]         DATETIME        NOT NULL,
    [NON_PodmiotTyp]      SMALLINT        NULL,
    [NON_PodmiotID]       INT             NULL,
    [NON_KatID]           INT             NULL,
    [NON_Kategoria]       VARCHAR (50)    NOT NULL,
    [NON_FPlId]           INT             NULL,
    [NON_Termin]          DATETIME        NOT NULL,
    [NON_OdsetkiTyp]      TINYINT         NOT NULL,
    [NON_OdsetkiStopa]    DECIMAL (7, 2)  NOT NULL,
    [NON_Waluta]          VARCHAR (3)     NOT NULL,
    [NON_KursNumer]       INT             NOT NULL,
    [NON_KursL]           DECIMAL (15, 4) NOT NULL,
    [NON_KursM]           DECIMAL (5)     NOT NULL,
    [NON_RazemKwota]      DECIMAL (15, 2) NOT NULL,
    [NON_RazemKwotaSys]   DECIMAL (15, 2) NOT NULL,
    [NON_RazemOdsetki]    DECIMAL (15, 2) NOT NULL,
    [NON_RazemOdsetkiSys] DECIMAL (15, 2) NOT NULL,
    [NON_Uwagi]           NVARCHAR (254)  NOT NULL,
    [NON_DekId]           INT             NULL,
    [NON_PreDekId]        INT             NULL,
    [NON_OpeZalID]        INT             NULL,
    [NON_StaZalId]        INT             NULL,
    [NON_TS_Zal]          DATETIME        NOT NULL,
    [NON_OpeModID]        INT             NULL,
    [NON_StaModId]        INT             NULL,
    [NON_TS_Mod]          DATETIME        NOT NULL,
    [NON_OpeModKod]       VARCHAR (20)    CONSTRAINT [DF_NON_OpeModKod] DEFAULT ('') NOT NULL,
    [NON_OpeModNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_NON_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [NON_OpeZalKod]       VARCHAR (20)    CONSTRAINT [DF_NON_OpeZalKod] DEFAULT ('') NOT NULL,
    [NON_OpeZalNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_NON_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [NON_Primary] PRIMARY KEY CLUSTERED ([NON_NONId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_NONDokDefinicja] FOREIGN KEY ([NON_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_NONKategoria] FOREIGN KEY ([NON_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_NONPlatnosc] FOREIGN KEY ([NON_FPlId]) REFERENCES [CDN].[FormyPlatnosci] ([FPl_FPlId]),
    CONSTRAINT [FK_NONPodmiot] FOREIGN KEY ([NON_PodmiotID], [NON_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NONPodmiot]
    ON [CDN].[NotyOdsNag]([NON_PodmiotID] ASC, [NON_PodmiotTyp] ASC, [NON_DataDok] ASC, [NON_NONId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NONKategoria]
    ON [CDN].[NotyOdsNag]([NON_KatID] ASC, [NON_DataDok] ASC, [NON_NONId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NONDokDefinicja]
    ON [CDN].[NotyOdsNag]([NON_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NONNumer]
    ON [CDN].[NotyOdsNag]([NON_NumerString] ASC, [NON_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NONNumerPelny]
    ON [CDN].[NotyOdsNag]([NON_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NONPlatnosc]
    ON [CDN].[NotyOdsNag]([NON_FPlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NONDekrety]
    ON [CDN].[NotyOdsNag]([NON_DekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [NONPreDekrety]
    ON [CDN].[NotyOdsNag]([NON_PreDekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.NotyOdsNag_InsertUpdate_Trigger
  ON CDN.NotyOdsNag
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  Set ArithAbort On
--Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.DekretyNag ON
                    inserted.NON_DekID       = CDN.DekretyNag.DeN_DeNId
              WHERE CDN.DekretyNag.DeN_DeNId IS NULL
                AND inserted.NON_DekID IS NOT NULL
           )
        BEGIN
          RAISERROR('##OPT32242##%%tabela%%=DekretyNag##', 16, 1) -- RAISERROR('Brak wartości w tabeli nadrzędnej (DekretyNag) ', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Obsługa anulowania noty
If Update (NON_Bufor)
And Exists (Select * From inserted Where NON_Bufor = -1)
 Begin
-- Aktualizacja skojarzonych zapisów z BnkZdarzenia
  Declare @DokId Int
  Declare anulowane Cursor Local Fast_Forward For
   Select NON_NONId From inserted Where NON_Bufor = -1
  Open anulowane
  While 1=1
   Begin
    Fetch Next From anulowane InTo @DokId
    If @@Fetch_Status <> 0 Break
    Execute CDN.KasujRozliczenia 11, @DokId
   End
  Close anulowane
  Deallocate anulowane
-- Sprawdzenie rozliczonych zdarzeń
  IF EXISTS (SELECT * FROM CDN.BnkZdarzenia JOIN CDN.BnkRozRelacje ON BRR_ZDokTyp = 1 AND BRR_ZDokID = BZd_BZdId
             WHERE BZd_DokumentTyp = 11 AND BZd_DokumentId In (Select NON_NONId From inserted Where NON_Bufor = -1))
    BEGIN
     RAISERROR('##OPT32348##', 16, 1) -- RAISERROR('Dokument posiada rozliczone płatności (BnkZdarzenia). ', 16, 1)
     ROLLBACK TRAN
     SET NOCOUNT OFF
     RETURN
    END
-- Skasowanie zdarzeń
  Delete CDN.BnkZdarzenia Where BZd_DokumentTyp = 11 AND BZd_DokumentId In (Select NON_NONId From inserted Where NON_Bufor = -1)
 End
-- Usuniecie powiazan z elementow anulowanej noty
If Update (NON_Bufor) And Exists (Select * From inserted Where NON_Bufor = -1)
  Update CDN.NotyOdsElem Set NOE_BZdId = Null, NOE_BRKId = Null
  Where NOE_NONId In (Select NON_NONId From inserted Where NON_Bufor = -1)
    And (NOE_BZdId Is Not Null Or NOE_BRKId Is Not Null)
  SET NOCOUNT OFF

GO
Create Trigger CDN.NotyOdsNag_Delete_Trigger
  On CDN.NotyOdsNag
  For Delete
As
Set NoCount On
Set ArithAbort On
Declare @DokId Int
Declare skasowane Cursor Local Fast_Forward For
 Select NON_NONId From deleted
Open skasowane
While 1=1
 Begin
  Fetch Next From skasowane InTo @DokId
  If @@Fetch_Status <> 0 Break
  Execute CDN.KasujRozliczenia 11, @DokId
 End
Close skasowane
Deallocate skasowane
-- Skasowanie relacji do dokumentów
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1130 AND DoR_DokumentId=deleted.NON_NONId
DECLARE @DokumentIDTable cdn.IdsTableType
INSERT INTO @DokumentIDTable SELECT NON_NONID FROM deleted
EXEC cdn.UsunZdarzeniaKBDokumentuEx @DokumentTyp = 11, @DokumentIDTable = @DokumentIDTable
Set NoCount Off

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[NotyOdsNag_Delete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
CREATE TRIGGER CDN.NotyOdsNag_DeleteHandler
  ON CDN.NotyOdsNag
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.NON_NONId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=11)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.NON_NONId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=11)
    IF EXISTS(
   SELECT * FROM CDN.BnkZdarzenia INNER JOIN deleted
   ON deleted.NON_NONId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=11)
  )
  DELETE CDN.BnkZdarzenia
  FROM CDN.BnkZdarzenia, deleted
  WHERE deleted.NON_NONId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=11)
    IF EXISTS(SELECT D.NON_PreDekID FROM Deleted D WHERE D.NON_PreDekID IS NOT NULL)
  DELETE CDN.DekretyNag
  FROM CDN.DekretyNag, deleted
  WHERE deleted.NON_PreDekId = CDN.DekretyNag.DeN_DeNID
SET NOCOUNT OFF
