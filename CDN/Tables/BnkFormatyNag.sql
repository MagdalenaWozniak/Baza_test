CREATE TABLE [CDN].[BnkFormatyNag] (
    [BFN_BFNId]                 INT            IDENTITY (5, 1) NOT NULL,
    [BFN_Nazwa]                 NVARCHAR (50)  NOT NULL,
    [BFN_Standardowy]           TINYINT        CONSTRAINT [DF_BFN_Standardowy] DEFAULT ((0)) NOT NULL,
    [BFN_CDC]                   TINYINT        NULL,
    [BFN_CDCAdres]              NVARCHAR (255) NULL,
    [BFN_CDCWariant]            TINYINT        NULL,
    [BFN_SepDzies]              NVARCHAR (1)   NULL,
    [BFN_FormatDaty]            NVARCHAR (20)  NULL,
    [BFN_UsunSpacje]            TINYINT        NULL,
    [BFN_OddzielajPola]         TINYINT        NULL,
    [BFN_SepPol]                NVARCHAR (3)   NULL,
    [BFN_SepOpisuZb]            NVARCHAR (3)   NULL,
    [BFN_SepGrup]               NVARCHAR (1)   NULL,
    [BFN_OgrTekstu]             NVARCHAR (3)   NULL,
    [BFN_OgrTekstuEsc]          NVARCHAR (3)   NULL,
    [BFN_PodzPolaNaWiersze]     NVARCHAR (3)   NULL,
    [BFN_SepWierszy]            NVARCHAR (2)   NULL,
    [BFN_RozszerzeniePliku]     NVARCHAR (3)   NULL,
    [BFN_StronaKodowa]          SMALLINT       NULL,
    [BFN_TylkoWielkieLitery]    TINYINT        NULL,
    [BFN_Nieaktywny]            TINYINT        CONSTRAINT [DF_BFN_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [BFN_XML]                   TINYINT        NULL,
    [BFN_XML_Rodzaj]            TINYINT        NULL,
    [BFN_SepDziesSplitPay]      NVARCHAR (1)   NULL,
    [BFN_CDCRodzajCertyfikatow] TINYINT        CONSTRAINT [DF_BFN_CDCRodzajCertyfikatow] DEFAULT ((0)) NOT NULL,
    [BFN_ObslugaEksportu]       TINYINT        CONSTRAINT [DF_BFN_ObslugaEksportu] DEFAULT ((1)) NOT NULL,
    [BFN_ObslugaImportu]        TINYINT        CONSTRAINT [DF_BFN_ObslugaImportu] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [BFN_Primary] PRIMARY KEY CLUSTERED ([BFN_BFNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BFNNazwa]
    ON [CDN].[BnkFormatyNag]([BFN_Standardowy] ASC, [BFN_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkFormatyNag_Delete_Trigger
  ON CDN.BnkFormatyNag
  FOR DELETE
AS
SET NOCOUNT ON
-- obsługa sprawdzania relacji restrict do tabeli CDN.BnkNazwy
IF EXISTS
  ( SELECT * FROM CDN.BnkNazwy, deleted
 WHERE BNa_Format = deleted.BFN_BFNId OR BNa_FormatUS = deleted.BFN_BFNId OR BNa_FormatZUS = deleted.BFN_BFNId)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=BnkNazwy##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą BnkNazwy). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkFormatyNag_Update_Trigger
  ON CDN.BnkFormatyNag
  FOR UPDATE
AS
 SET NOCOUNT ON
 IF EXISTS (SELECT * FROM CDN.BnkNazwy, inserted, deleted
  WHERE inserted.BFN_Nieaktywny = 1 AND deleted.BFN_Nieaktywny = 0 AND inserted.BFN_BFNId = deleted.BFN_BFNId
   AND (BNa_Format = inserted.BFN_BFNId OR BNa_FormatUS = inserted.BFN_BFNId OR BNa_FormatZUS = inserted.BFN_BFNId OR BNa_FormatImp = inserted.BFN_BFNId))
 BEGIN
    UPDATE B SET B.BNa_Format = 0
   FROM cdn.BnkNazwy B
   INNER JOIN inserted I ON I.BFN_BFNId = B.BNa_Format AND I.BFN_Nieaktywny = 1
   INNER JOIN deleted D ON D.BFN_BFNId = I.BFN_BFNId AND D.BFN_Nieaktywny = 0
    UPDATE B SET B.BNa_FormatUS = 0
   FROM cdn.BnkNazwy B
   INNER JOIN inserted I ON I.BFN_BFNId = B.BNa_FormatUS AND I.BFN_Nieaktywny = 1
   INNER JOIN deleted D ON D.BFN_BFNId = I.BFN_BFNId AND D.BFN_Nieaktywny = 0
  UPDATE B SET B.BNa_FormatZUS = 0
   FROM cdn.BnkNazwy B
   INNER JOIN inserted I ON I.BFN_BFNId = B.BNa_FormatZUS AND I.BFN_Nieaktywny = 1
   INNER JOIN deleted D ON D.BFN_BFNId = I.BFN_BFNId AND D.BFN_Nieaktywny = 0
  UPDATE B SET B.BNa_FormatImp = 0
   FROM cdn.BnkNazwy B
   INNER JOIN inserted I ON I.BFN_BFNId = B.BNa_FormatImp AND I.BFN_Nieaktywny = 1
   INNER JOIN deleted D ON D.BFN_BFNId = I.BFN_BFNId AND D.BFN_Nieaktywny = 0
  END
 SET NOCOUNT OFF
