CREATE TABLE [CDN].[CRMKontakty] (
    [CRK_CRKId]                                             INT            IDENTITY (1, 1) NOT NULL,
    [CRK_WatekId]                                           INT            NOT NULL,
    [CRK_ParId]                                             INT            NULL,
    [CRK_DDfId]                                             INT            NOT NULL,
    [CRK_NumerString]                                       VARCHAR (31)   NOT NULL,
    [CRK_NumerNr]                                           INT            NOT NULL,
    [CRK_NumerPelny]                                        AS             ([CDN].[FN_NUMERPELNY]([CRK_NUMERNR],[CRK_NUMERSTRING])),
    [CRK_Anulowany]                                         INT            NOT NULL,
    [CRK_Bufor]                                             SMALLINT       NOT NULL,
    [CRK_PodmiotTyp]                                        SMALLINT       NULL,
    [CRK_PodID]                                             INT            NULL,
    [CRK_OsobaId]                                           INT            NULL,
    [CRK_OsobaNazwisko]                                     NVARCHAR (40)  NOT NULL,
    [CRK_OpiekunTyp]                                        SMALLINT       NULL,
    [CRK_OpiekunId]                                         INT            NULL,
    [CRK_Obsluga]                                           TINYINT        NOT NULL,
    [CRK_DataDok]                                           DATETIME       NOT NULL,
    [CRK_CzasPrzygot]                                       DATETIME       NULL,
    [CRK_CzasKontaktu]                                      DATETIME       NULL,
    [CRK_CzasOpracow]                                       DATETIME       NULL,
    [CRK_Zadanie]                                           TINYINT        NOT NULL,
    [CRK_TerminOd]                                          DATETIME       NULL,
    [CRK_TerminDo]                                          DATETIME       NULL,
    [CRK_Przypomnienie]                                     TINYINT        NOT NULL,
    [CRK_CzasPrzypomnienia]                                 DATETIME       NULL,
    [CRK_Priorytet]                                         TINYINT        NOT NULL,
    [CRK_Wykonano]                                          DECIMAL (5, 2) NOT NULL,
    [CRK_EtapRealizacji]                                    INT            NULL,
    [CRK_Temat]                                             NVARCHAR (255) NOT NULL,
    [CRK_Opis]                                              NVARCHAR (MAX) NOT NULL,
    [CRK_UwagiDoRealizacji]                                 NVARCHAR (MAX) CONSTRAINT [DF_CRK_UwagiDoRealizacji] DEFAULT ('') NOT NULL,
    [CRK_Lokalizacja]                                       NVARCHAR (255) NULL,
    [CRK_Windykacja]                                        INT            CONSTRAINT [DF_CRK_Windykacja] DEFAULT ((0)) NOT NULL,
    [CRK_OpeZalID]                                          INT            NULL,
    [CRK_StaZalId]                                          INT            NULL,
    [CRK_TS_Zal]                                            DATETIME       NOT NULL,
    [CRK_OpeModID]                                          INT            NULL,
    [CRK_StaModId]                                          INT            NULL,
    [CRK_TS_Mod]                                            DATETIME       NOT NULL,
    [CRK_StanowiskoID]                                      INT            NULL,
    [CRK_DokID]                                             INT            NULL,
    [CrK_AutomatycznePrzypomnienia]                         TINYINT        CONSTRAINT [DF_CrK_AutomatycznePrzypomnienia] DEFAULT ((0)) NOT NULL,
    [CrK_AutomatycznePrzypomnieniaMail]                     TINYINT        NULL,
    [CrK_AutomatycznePrzypomnieniaEmailAdres]               NVARCHAR (127) NULL,
    [CrK_AutomatycznePrzypomnieniaMailCzasPrzypomnienia]    DATETIME       NULL,
    [CrK_AutomatycznePrzypomnieniaMailWyslano]              DATETIME       NULL,
    [CrK_AutomatycznePrzypomnieniaMailSzablonId]            INT            NULL,
    [CrK_AutomatycznePrzypomnieniaSms]                      TINYINT        NULL,
    [CrK_AutomatycznePrzypomnieniaSmsNumerTelefonu]         NVARCHAR (127) NULL,
    [CrK_AutomatycznePrzypomnieniaSmsCzasPrzypomnienia]     DATETIME       NULL,
    [CrK_AutomatycznePrzypomnieniaSmsWyslano]               DATETIME       NULL,
    [CrK_AutomatycznePrzypomnieniaSmsSzablonId]             INT            NULL,
    [CRK_Cykl]                                              INT            CONSTRAINT [DF_CrK_Cykl] DEFAULT ((0)) NOT NULL,
    [CRK_CyklTyp]                                           INT            CONSTRAINT [DF_CrK_CyklTyp] DEFAULT ((2)) NOT NULL,
    [CRK_CyklPowtarzajCo]                                   INT            CONSTRAINT [DF_CrK_CyklPowtarzajCo] DEFAULT ((1)) NOT NULL,
    [CRK_CyklDzienTygodnia]                                 INT            CONSTRAINT [DF_CrK_CyklDzienTygodnia] DEFAULT ((1)) NOT NULL,
    [CRK_CyklDzienMiesiaca]                                 INT            CONSTRAINT [DF_CrK_CyklDzienMiesiaca] DEFAULT ((1)) NOT NULL,
    [CRK_CyklMiesiac]                                       INT            CONSTRAINT [DF_CrK_CyklMiesiac] DEFAULT ((1)) NOT NULL,
    [CRK_CyklTydzien]                                       INT            CONSTRAINT [DF_CrK_CyklTydzien] DEFAULT ((1)) NOT NULL,
    [CRK_CyklDataStart]                                     DATETIME       NULL,
    [CRK_CyklDataEnd]                                       DATETIME       NULL,
    [CRK_CyklLiczbaWystapien]                               INT            CONSTRAINT [DF_CrK_CyklLiczbaWystapien] DEFAULT ((1)) NOT NULL,
    [CRK_CyklParentId]                                      INT            NULL,
    [CrK_AutomatycznePrzypomnieniaOpe]                      TINYINT        CONSTRAINT [DF_CrK_AutomatycznePrzypomnieniaOpe] DEFAULT ((0)) NOT NULL,
    [CrK_AutomatycznePrzypomnieniaOpeMail]                  TINYINT        NULL,
    [CrK_AutomatycznePrzypomnieniaOpeMailCzasPrzypomnienia] DATETIME       NULL,
    [CrK_AutomatycznePrzypomnieniaOpeMailWyslano]           DATETIME       NULL,
    [CrK_AutomatycznePrzypomnieniaOpeMailSzablonId]         INT            NULL,
    [CrK_AutomatycznePrzypomnieniaOpeSms]                   TINYINT        NULL,
    [CrK_AutomatycznePrzypomnieniaOpeSmsCzasPrzypomnienia]  DATETIME       NULL,
    [CrK_AutomatycznePrzypomnieniaOpeSmsWyslano]            DATETIME       NULL,
    [CrK_AutomatycznePrzypomnieniaOpeSmsSzablonId]          INT            NULL,
    [CRK_OpeModKod]                                         VARCHAR (20)   CONSTRAINT [DF_CRK_OpeModKod] DEFAULT ('') NOT NULL,
    [CRK_OpeModNazwisko]                                    NVARCHAR (50)  CONSTRAINT [DF_CRK_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [CRK_OpeZalKod]                                         VARCHAR (20)   CONSTRAINT [DF_CRK_OpeZalKod] DEFAULT ('') NOT NULL,
    [CRK_OpeZalNazwisko]                                    NVARCHAR (50)  CONSTRAINT [DF_CRK_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [CRK_Primary] PRIMARY KEY CLUSTERED ([CRK_CRKId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CRKDokDef] FOREIGN KEY ([CRK_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_CRKNadrzedne] FOREIGN KEY ([CRK_ParId]) REFERENCES [CDN].[CRMKontakty] ([CRK_CRKId]),
    CONSTRAINT [FK_CRKPodmiot] FOREIGN KEY ([CRK_PodID], [CRK_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_CrkPrzedstawiciel] FOREIGN KEY ([CRK_OsobaId]) REFERENCES [CDN].[KntOsoby] ([KnO_KnOId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [CrkWatek]
    ON [CDN].[CRMKontakty]([CRK_WatekId] ASC, [CRK_CRKId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CrkOnlyWatek]
    ON [CDN].[CRMKontakty]([CRK_WatekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CRKEtap]
    ON [CDN].[CRMKontakty]([CRK_EtapRealizacji] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CrkTemat]
    ON [CDN].[CRMKontakty]([CRK_Temat] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [CRKPodmiot]
    ON [CDN].[CRMKontakty]([CRK_PodID] ASC, [CRK_PodmiotTyp] ASC, [CRK_DataDok] ASC, [CRK_NumerString] ASC, [CRK_NumerNr] ASC, [CRK_Anulowany] ASC, [CRK_CRKId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CRKDokDef]
    ON [CDN].[CRMKontakty]([CRK_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [CRKNumer]
    ON [CDN].[CRMKontakty]([CRK_NumerString] ASC, [CRK_NumerNr] ASC, [CRK_Anulowany] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [CRKNumerPelny]
    ON [CDN].[CRMKontakty]([CRK_NumerPelny] ASC, [CRK_Anulowany] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CRKOpiekun]
    ON [CDN].[CRMKontakty]([CRK_OpiekunId] ASC, [CRK_OpiekunTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CRKNadrzedne]
    ON [CDN].[CRMKontakty]([CRK_ParId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CrKDataDok]
    ON [CDN].[CRMKontakty]([CRK_DataDok] ASC, [CRK_NumerString] ASC, [CRK_NumerNr] ASC, [CRK_Anulowany] ASC, [CRK_CRKId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CrkPrzedstawiciel]
    ON [CDN].[CRMKontakty]([CRK_OsobaId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [CrkBufor]
    ON [CDN].[CRMKontakty]([CRK_Bufor] ASC, [CRK_Zadanie] ASC)
    INCLUDE([CRK_TerminOd], [CRK_TerminDo]) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.CRMKontakty_Delete_Trigger
  On CDN.CRMKontakty
  For Delete
As
Set NoCount On
If Exists (Select * From deleted Where CRK_Bufor<>1)
 Begin
  --RAISERROR('Nie można kasować kontaktów nie będących w buforze.', 16, 1)
  EXEC CDN.RaiseOptimaException 34150
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 End
-- Skasowanie relacji do dokumentów CRM  (WiNi)
 DELETE CDN.CrmDokumenty
 FROM CDN.CrmDokumenty JOIN deleted ON CRD_TypDokumentu=700 AND CRD_DokumentId=deleted.CrK_CrKId
-- Skasowanie relacji do uczestników
 DELETE CDN.CrmUczestnicy
 FROM CDN.CrmUczestnicy JOIN deleted ON  CrU_CrKId=deleted.CrK_CrKId
-- Skasowanie relacji do dokumentów serwisowych  (WiNi)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=700 AND DoR_DokumentId=deleted.CrK_CrKId
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_ParentTyp=700 AND DoR_ParentId=deleted.CrK_CrKId
Set NoCount Off

GO
CREATE TRIGGER cdn.CrmKontakty_InsertUpdate_Trigger
  ON cdn.CrmKontakty
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
 DECLARE @CrKId   INT,
    @CrKBufor  INT,
    @CrKParentId INT,
    @CrKCyklParentId INT,
    @CrKNumerPelny NVarchar(30)
 DECLARE dodane CURSOR LOCAL Fast_Forward FOR
  SELECT
   CrK_CrkId,
   CrK_Bufor,
   IsNull(CrK_ParId, 0),
   CrK_NumerPelny,
   CrK_CyklParentId
  FROM inserted
 OPEN Dodane
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM Dodane INTO
   @CrKId,
   @CrKBufor,
   @CrKParentId,
   @CrKNumerPelny,
   @CrKCyklParentId
     IF @@FETCH_STATUS <> 0 BREAK
  -- wyliczenie kolejnego numeru Crm_Anulowany dla dokumentów anulowanych - dla pozostałych 0
  UPDATE cdn.CrmKontakty
  SET CrK_Anulowany =
  CASE @CrKBufor
  WHEN -1 THEN
                ( SELECT ISNULL(MAX(CrK_Anulowany), -2147483648 ) + 1 FROM cdn.CrmKontakty WHERE CrK_NumerPelny = @CrKNumerPelny AND CrK_Bufor = -1 AND CrK_CrkId <> @CrKId)
  ELSE  0  END,
  CrK_WatekId =
  CASE @CrKParentId
  WHEN  0 THEN CrK_CrKId
  ELSE  @CrKParentId  END
  WHERE CrK_CrKId = @CrKId
  -- aktualizacja cyklu jeżeli zadnie powstało jako wydzielone z cyklu
  IF @CrKCyklParentId > 0
  BEGIN
   UPDATE CDN.[CrmKontaktyCykl] SET [CRC_Aktywny]=0, CRC_Bufor=0, CRC_CrKWylaczonyId = @CrKId WHERE [CRC_CRCId] = @CrKCyklParentId
  END
 END
 CLOSE dodane
 DEALLOCATE dodane
SET NOCOUNT OFF
