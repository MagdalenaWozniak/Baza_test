CREATE TABLE [CDN].[OfertyDok] (
    [OfD_OfDId]          INT             IDENTITY (1, 1) NOT NULL,
    [OfD_Nazwa]          NVARCHAR (255)  NOT NULL,
    [OfD_Opis]           NVARCHAR (1024) NULL,
    [OfD_StatusId]       INT             NULL,
    [OfD_StatusOpis]     NVARCHAR (254)  NULL,
    [OfD_Body]           NVARCHAR (MAX)  NULL,
    [OfD_NazwaSzablonu]  NVARCHAR (50)   CONSTRAINT [DF_OfD_NazwaSzablonu] DEFAULT ('') NOT NULL,
    [OfD_KntId]          INT             NULL,
    [OfD_TrNId]          INT             NULL,
    [OfD_DDfId]          INT             NULL,
    [OfD_TypDokumentu]   SMALLINT        NOT NULL,
    [OfD_NumerNr]        INT             NOT NULL,
    [OfD_NumerString]    VARCHAR (30)    NOT NULL,
    [OfD_NumerPelny]     AS              ([CDN].[FN_NUMERPELNY]([OFD_NUMERNR],[OFD_NUMERSTRING])),
    [OfD_DataDok]        DATETIME        NOT NULL,
    [OfD_DataOd]         DATETIME        CONSTRAINT [DF_OfD_DataOd] DEFAULT ((0)) NOT NULL,
    [OfD_DataDo]         DATETIME        CONSTRAINT [DF_OfD_DataDo] DEFAULT ((0)) NOT NULL,
    [OfD_Waluta]         VARCHAR (3)     CONSTRAINT [DF_OfD_Waluta] DEFAULT ('') NOT NULL,
    [OfD_KursNumer]      INT             CONSTRAINT [DF_OfD_KursNumer] DEFAULT ((0)) NOT NULL,
    [OfD_KursL]          DECIMAL (15, 4) CONSTRAINT [DF_OfD_KursL] DEFAULT ((1)) NOT NULL,
    [OfD_KursM]          DECIMAL (5)     CONSTRAINT [DF_OfD_KursM] DEFAULT ((1)) NOT NULL,
    [OfD_DataKur]        DATETIME        CONSTRAINT [DF_OfD_DataKur] DEFAULT ((0)) NOT NULL,
    [OfD_Bufor]          SMALLINT        CONSTRAINT [DF_OfD_Bufor] DEFAULT ((0)) NOT NULL,
    [OfD_Anulowany]      INT             CONSTRAINT [DF_OfD_Anulowany] DEFAULT ((0)) NOT NULL,
    [OfD_KopiaEl]        TINYINT         CONSTRAINT [DF_OfD_KopiaEl] DEFAULT ((0)) NOT NULL,
    [OfD_PodpisCyfrowy]  TINYINT         CONSTRAINT [DF_OfD_PodpisCyfrowy] DEFAULT ((0)) NOT NULL,
    [OfD_TypNB]          TINYINT         CONSTRAINT [DF_OfD_TypNB] DEFAULT ((0)) NOT NULL,
    [OfD_RodzajCeny]     INT             NULL,
    [OfD_GrupaCenowa]    INT             NULL,
    [OfD_Rabat]          DECIMAL (11, 4) NULL,
    [OfD_OpeZalId]       INT             NULL,
    [OfD_StaZalId]       INT             NULL,
    [OfD_TS_Zal]         DATETIME        NOT NULL,
    [OfD_OpeModId]       INT             NULL,
    [OfD_StaModId]       INT             NULL,
    [OfD_TS_Mod]         DATETIME        NOT NULL,
    [OfD_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_OfD_OpeModKod] DEFAULT ('') NOT NULL,
    [OfD_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_OfD_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [OfD_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_OfD_OpeZalKod] DEFAULT ('') NOT NULL,
    [OfD_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_OfD_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [OfD_Primary] PRIMARY KEY CLUSTERED ([OfD_OfDId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_OfDDokDefinicje] FOREIGN KEY ([OfD_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_OfDKontrahent] FOREIGN KEY ([OfD_KntId]) REFERENCES [CDN].[Kontrahenci] ([Knt_KntId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [OfDData]
    ON [CDN].[OfertyDok]([OfD_DataDok] ASC, [OfD_NumerPelny] ASC, [OfD_Anulowany] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [OfDKontrahent]
    ON [CDN].[OfertyDok]([OfD_KntId] ASC, [OfD_DataDok] ASC, [OfD_OfDId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [OfDDokDefinicje]
    ON [CDN].[OfertyDok]([OfD_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [OfDNumer]
    ON [CDN].[OfertyDok]([OfD_NumerString] ASC, [OfD_NumerNr] ASC, [OfD_Anulowany] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Ofer_Delete_Trigger
  ON CDN.OfertyDok
  FOR DELETE
AS
  SET NOCOUNT ON
  Set ArithAbort On
--Sprawdzanie, czy dokument może byc skasowany (jest w buforze)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.OfD_Bufor <> 1 )
        BEGIN
          RAISERROR('##OPT29447##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
-- Skasowanie relacji do dokumentów powiązanych
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=800 AND DoR_DokumentId=deleted.OfD_OfDId
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_ParentTyp=800 AND DoR_ParentId=deleted.OfD_OfDId
  SET NOCOUNT OFF

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[Ofer_Delete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
CREATE TRIGGER CDN.Ofer_InsertUpdate_Trigger
  ON CDN.OfertyDok
  AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON
  Set ArithAbort On
 DECLARE @Ofd_OfdID INT
 DECLARE @Ofd_NumerPelny nvarchar(30)
 Declare dodane Cursor Local Fast_Forward For
 Select
  Ofd_OfdID,
  Ofd_NumerPelny
  From inserted
 Open Dodane
 While 1=1
  Begin
  Fetch Next From Dodane InTo
   @Ofd_OfdID,
   @Ofd_NumerPelny
  If @@Fetch_Status <> 0 Break
   UPDATE cdn.OfertyDok SET Ofd_Anulowany =
      CASE Ofd_Bufor
      WHEN -1 THEN
      ( SELECT ISNULL(MAX(Ofd_Anulowany), -2147483648 ) + 1 FROM cdn.OfertyDok WHERE Ofd_NumerPelny = @Ofd_NumerPelny AND Ofd_Bufor = -1 AND Ofd_OfdId <> @Ofd_OfdID)
      ELSE  0  END
     WHERE Ofd_OfdID = @Ofd_OfdID
  END
 Close Dodane
 Deallocate Dodane
  SET NOCOUNT OFF
END
