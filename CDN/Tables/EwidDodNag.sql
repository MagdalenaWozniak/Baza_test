CREATE TABLE [CDN].[EwidDodNag] (
    [EDN_EDNID]              INT             IDENTITY (1, 1) NOT NULL,
    [EDN_DDfId]              INT             NULL,
    [EDN_NumerString]        VARCHAR (31)    NOT NULL,
    [EDN_NumerNr]            INT             NOT NULL,
    [EDN_NumerPelny]         AS              ([CDN].[FN_NUMERPELNY]([EDN_NUMERNR],[EDN_NUMERSTRING])),
    [EDN_NumerObcy]          VARCHAR (256)   NOT NULL,
    [EDN_DataWys]            DATETIME        NOT NULL,
    [EDN_DataDok]            DATETIME        NOT NULL,
    [EDN_DataOpe]            DATETIME        NOT NULL,
    [EDN_DataKur]            DATETIME        NOT NULL,
    [EDN_Typ]                INT             NOT NULL,
    [EDN_Rejestr]            NVARCHAR (20)   NOT NULL,
    [EDN_RokMies]            AS              ((100)*datepart(year,[EDN_DATADOK])+datepart(month,[EDN_DATADOK])),
    [EDN_Lp]                 INT             NOT NULL,
    [EDN_PodmiotTyp]         SMALLINT        NULL,
    [EDN_PodID]              INT             NULL,
    [EDN_Nazwa1]             NVARCHAR (50)   NOT NULL,
    [EDN_Nazwa2]             NVARCHAR (50)   NOT NULL,
    [EDN_Nazwa3]             NVARCHAR (250)  NOT NULL,
    [EDN_Kraj]               NVARCHAR (40)   NOT NULL,
    [EDN_Wojewodztwo]        NVARCHAR (40)   NOT NULL,
    [EDN_Powiat]             NVARCHAR (40)   NOT NULL,
    [EDN_Gmina]              NVARCHAR (40)   NOT NULL,
    [EDN_Ulica]              NVARCHAR (40)   NOT NULL,
    [EDN_NrDomu]             NVARCHAR (10)   NOT NULL,
    [EDN_NrLokalu]           NVARCHAR (10)   NOT NULL,
    [EDN_Miasto]             NVARCHAR (40)   NOT NULL,
    [EDN_KodPocztowy]        VARCHAR (10)    NOT NULL,
    [EDN_Poczta]             NVARCHAR (40)   NOT NULL,
    [EDN_Adres2]             NVARCHAR (40)   NOT NULL,
    [EDN_NipKraj]            VARCHAR (2)     NOT NULL,
    [EDN_NipE]               NVARCHAR (20)   NOT NULL,
    [EDN_KatID]              INT             NULL,
    [EDN_PodmiotZalTyp]      SMALLINT        NULL,
    [EDN_PodZalId]           INT             NULL,
    [EDN_PlatnikTyp]         SMALLINT        NULL,
    [EDN_PlatnikID]          INT             NULL,
    [EDN_PlatnikRachunekLp]  INT             NULL,
    [EDN_PlatnikKraj]        NVARCHAR (40)   CONSTRAINT [df_EDN_PlatnikKraj] DEFAULT ('') NOT NULL,
    [EDN_PlatnikWojewodztwo] NVARCHAR (40)   CONSTRAINT [df_EDN_PlatnikWojewodztwo] DEFAULT ('') NOT NULL,
    [EDN_PlatnikPowiat]      NVARCHAR (40)   CONSTRAINT [df_EDN_PlatnikPowiat] DEFAULT ('') NOT NULL,
    [EDN_PlatnikGmina]       NVARCHAR (40)   CONSTRAINT [df_EDN_PlatnikGmina] DEFAULT ('') NOT NULL,
    [EDN_PlatnikUlica]       NVARCHAR (40)   CONSTRAINT [df_EDN_PlatnikUlica] DEFAULT ('') NOT NULL,
    [EDN_PlatnikNrDomu]      NVARCHAR (10)   CONSTRAINT [df_EDN_PlatnikNrDomu] DEFAULT ('') NOT NULL,
    [EDN_PlatnikNrLokalu]    NVARCHAR (10)   CONSTRAINT [df_EDN_PlatnikNrLokalu] DEFAULT ('') NOT NULL,
    [EDN_PlatnikMiasto]      NVARCHAR (40)   CONSTRAINT [df_EDN_PlatnikMiasto] DEFAULT ('') NOT NULL,
    [EDN_PlatnikKodPocztowy] NVARCHAR (10)   CONSTRAINT [df_EDN_PlatnikKodPocztowy] DEFAULT ('') NOT NULL,
    [EDN_PlatnikPoczta]      NVARCHAR (40)   CONSTRAINT [df_EDN_PlatnikPoczta] DEFAULT ('') NOT NULL,
    [EDN_PlatnikAdres2]      NVARCHAR (40)   CONSTRAINT [df_EDN_PlatnikAdres2] DEFAULT ('') NOT NULL,
    [EDN_PlatnikNazwa1]      NVARCHAR (50)   CONSTRAINT [df_EDN_PlatnikNazwa1] DEFAULT ('') NOT NULL,
    [EDN_PlatnikNazwa2]      NVARCHAR (50)   CONSTRAINT [df_EDN_PlatnikNazwa2] DEFAULT ('') NOT NULL,
    [EDN_PlatnikNazwa3]      NVARCHAR (250)  CONSTRAINT [df_EDN_PlatnikNazwa3] DEFAULT ('') NOT NULL,
    [EDN_PlatnikRachunekNr]  NVARCHAR (51)   CONSTRAINT [df_EDN_PlatnikRachunekNr] DEFAULT ('') NOT NULL,
    [EDN_Kategoria]          VARCHAR (50)    NOT NULL,
    [EDN_KwotaRazemSys]      DECIMAL (15, 2) NOT NULL,
    [EDN_KontrolaSumy]       TINYINT         NOT NULL,
    [EDN_KwotaRazem]         DECIMAL (15, 2) NOT NULL,
    [EDN_Waluta]             VARCHAR (3)     NOT NULL,
    [EDN_KursNumer]          INT             NOT NULL,
    [EDN_KursL]              DECIMAL (15, 4) NOT NULL,
    [EDN_KursM]              DECIMAL (5)     NOT NULL,
    [EDN_Platnosci]          TINYINT         NOT NULL,
    [EDN_FPlId]              INT             NULL,
    [EDN_Termin]             DATETIME        NOT NULL,
    [EDN_MagazynZrodlowy]    NVARCHAR (20)   NULL,
    [EDN_MagazynDocelowy]    NVARCHAR (20)   NULL,
    [EDN_DekId]              INT             NULL,
    [EDN_PreDekId]           INT             NULL,
    [EDN_KPRId]              INT             NULL,
    [EDN_RycId]              INT             NULL,
    [EDN_ImportAppId]        VARCHAR (5)     NULL,
    [EDN_ImportRowId]        VARCHAR (36)    NULL,
    [EDN_TS_Export]          DATETIME        NULL,
    [EDN_OpeZalID]           INT             NULL,
    [EDN_StaZalId]           INT             NULL,
    [EDN_TS_Zal]             DATETIME        NOT NULL,
    [EDN_OpeModID]           INT             NULL,
    [EDN_StaModId]           INT             NULL,
    [EDN_TS_Mod]             DATETIME        NOT NULL,
    [EDN_ZakID]              INT             NULL,
    [EDN_OpeModKod]          VARCHAR (20)    CONSTRAINT [DF_EDN_OpeModKod] DEFAULT ('') NOT NULL,
    [EDN_OpeModNazwisko]     NVARCHAR (50)   CONSTRAINT [DF_EDN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [EDN_OpeZalKod]          VARCHAR (20)    CONSTRAINT [DF_EDN_OpeZalKod] DEFAULT ('') NOT NULL,
    [EDN_OpeZalNazwisko]     NVARCHAR (50)   CONSTRAINT [DF_EDN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [EDN_DnpID]              INT             NULL,
    CONSTRAINT [EDN_Primary] PRIMARY KEY CLUSTERED ([EDN_EDNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_EDNDokDef] FOREIGN KEY ([EDN_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_EDNKategoria] FOREIGN KEY ([EDN_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_EDNPlatnosc] FOREIGN KEY ([EDN_FPlId]) REFERENCES [CDN].[FormyPlatnosci] ([FPl_FPlId]),
    CONSTRAINT [FK_EDNPodmiot] FOREIGN KEY ([EDN_PodID], [EDN_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [EDNKategoria]
    ON [CDN].[EwidDodNag]([EDN_KatID] ASC, [EDN_Typ] ASC, [EDN_DataWys] ASC, [EDN_EDNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [EDNPodmiot]
    ON [CDN].[EwidDodNag]([EDN_PodID] ASC, [EDN_PodmiotTyp] ASC, [EDN_Typ] ASC, [EDN_DataWys] ASC, [EDN_EDNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [EDNPodmiotZal]
    ON [CDN].[EwidDodNag]([EDN_PodZalId] ASC, [EDN_PodmiotZalTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [EDNChronoRej]
    ON [CDN].[EwidDodNag]([EDN_Typ] ASC, [EDN_Rejestr] ASC, [EDN_DataDok] ASC, [EDN_EDNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [EDNLp]
    ON [CDN].[EwidDodNag]([EDN_Typ] ASC, [EDN_Rejestr] ASC, [EDN_RokMies] ASC, [EDN_Lp] ASC, [EDN_EDNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [EDNDokDef]
    ON [CDN].[EwidDodNag]([EDN_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [EDNNumer]
    ON [CDN].[EwidDodNag]([EDN_NumerString] ASC, [EDN_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [EDNNumerPelny]
    ON [CDN].[EwidDodNag]([EDN_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [EDNPlatnosc]
    ON [CDN].[EwidDodNag]([EDN_FPlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [EDNDekrety]
    ON [CDN].[EwidDodNag]([EDN_DekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [EDNPreDekrety]
    ON [CDN].[EwidDodNag]([EDN_PreDekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [EDNZapisy]
    ON [CDN].[EwidDodNag]([EDN_KPRId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [EDNRyczalt]
    ON [CDN].[EwidDodNag]([EDN_RycId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [EDNGUID]
    ON [CDN].[EwidDodNag]([EDN_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.EwidDodNag_Delete_Trigger
  ON CDN.EwidDodNag
  FOR DELETE
AS
SET NOCOUNT ON
SET ARITHABORT ON
 DECLARE @WADokumentTypPrzychody int = 0;
 DECLARE @WADokumentTypKoszty int = 0;
 select @WADokumentTypPrzychody=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Ewidencja przychodów';
 select @WADokumentTypKoszty=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Ewidencja kosztów';
 IF EXISTS (SELECT * FROM deleted WHERE EDN_DekId Is Not Null)
 BEGIN
  RAISERROR('##OPT32023##%%1%%=Dekrety##', 16, 1)
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
 IF EXISTS (SELECT * FROM deleted WHERE EDN_KPRId Is Not Null)
 BEGIN
  RAISERROR('##OPT32023##%%1%%=ZapisyKPR##', 16, 1)
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
 IF EXISTS (SELECT * FROM deleted WHERE EDN_RycId Is Not Null)
 BEGIN
  RAISERROR('##OPT32023##%%1%%=Ryczalt##', 16, 1)
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
-- Sprawdzenie powiązania do korekty podatku dochodowego
 IF EXISTS(
  SELECT *
  FROM CDN.DeklNag D
  JOIN CDN.KorektaPodatkuDochodowegoZD ON KZD_DkNID = D.DkN_DkNID
  JOIN deleted on (deleted.EDN_EDNId = KZD_DokumentID)
  WHERE KZD_DokumentTyp = 12 AND D.DkN_Finalna = 1
 )
 BEGIN
     RAISERROR('##OPT34841##', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
 END
  IF EXISTS (SELECT * FROM CDN.TrwalePowiazania WHERE SrTP_DokumentTyp = 12 AND SrTP_DokumentID IN (SELECT EDN_EDNId FROM deleted))
    BEGIN
      RAISERROR('##OPT32026##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- Sprawdzamy powiązania z dokumentami ST innymi niż ulepszenie (one są zapisywane bezpośrednio na dokumencie)
  IF EXISTS (SELECT * FROM CDN.TrwaleHist WHERE SrH_TypDokumentu <> 1 AND SrH_DokumentTyp = 12 AND SrH_DokumentID IN (SELECT EDN_EDNId FROM deleted))
    BEGIN
      RAISERROR('##OPT32027##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- Sprawdzamy powiązania z dokumentami ulepszenia ST (one są zapisywane w tabeli podrzędnej względem dokumentów)
  IF EXISTS (SELECT * FROM CDN.TrwaleHistPowiazania WHERE SrHP_DokumentTyp = 12 AND SrHP_DokumentID IN (SELECT EDN_EDNID FROM deleted))
    BEGIN
      RAISERROR('##OPT32028##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (SELECT * FROM CDN.WyposazeniePowiazania WHERE WypP_DokumentTyp = 12 AND WypP_DokumentID IN (SELECT EDN_EDNId FROM deleted))
    BEGIN
      RAISERROR('##OPT32029##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (select * from CDN.DlgDokumenty where DLD_DokumentTyp = 12 and DLD_DokumentId in (SELECT EDN_EDNId FROM deleted))
    BEGIN
      RAISERROR('##OPT32030##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Skasowanie relacji do dokumentów z biblioteki  (RZ za WJ)
 IF EXISTS(
   SELECT * FROM CDN.DokRelacje INNER JOIN deleted
   ON DoR_DokumentTyp=1003 AND DoR_DokumentId=deleted.EDN_EDNId
  )
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1003 AND DoR_DokumentId=deleted.EDN_EDNId
 Declare @DokId Int
 Declare skasowane Cursor Local Fast_Forward For
  Select EDN_EDNId From deleted
 Open skasowane
 While 1=1
  Begin
   Fetch Next From skasowane InTo @DokId
   If @@Fetch_Status <> 0 Break
   Execute CDN.KasujRozliczenia 12, @DokId
  End
 Close skasowane
 Deallocate skasowane
 SET NOCOUNT OFF
 -- Usuwanie wymiarów analitycznych
 if exists(select * from CDN.WymiaryWartosci where WyW_DokumentTyp in (@WADokumentTypPrzychody, @WADokumentTypKoszty) and WyW_DokumentId in (select deleted.EDN_EDNID from deleted))
  delete from CDN.WymiaryWartosci where WyW_DokumentTyp in (@WADokumentTypPrzychody, @WADokumentTypKoszty)
  and WyW_DokumentId in (select deleted.EDN_EDNID from deleted)

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[EwidDodNag_Delete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
CREATE TRIGGER CDN.EwidDodNag_DeleteHandler
  ON CDN.EwidDodNag
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.EDN_EDNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=12)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.EDN_EDNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=12)
    IF EXISTS(
   SELECT * FROM CDN.BnkZdarzenia INNER JOIN deleted
   ON deleted.EDN_EDNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=12)
  )
  BEGIN
  CREATE TABLE #BZdIDs (ID INT)
  INSERT INTO #BZdIDs
   SELECT BZD_BZDID FROM CDN.BnkZdarzenia INNER JOIN deleted ON deleted.EDN_EDNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=12)
  EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1001',
         @ObiektSubTyp = 'BZd_Kierunek',
         @ObiektID = 'BZd_BZdID',
         @ObiektNazwa = 'BZd_NumerPelny',
         @OperacjaTyp = 3,
         @Opis = '''''',
         @From = 'cdn.BnkZdarzenia',
         @Where = 'BZd_BZdID IN (SELECT ID FROM #BZdIDs)'
  DROP TABLE #BZdIDs
  DELETE CDN.BnkZdarzenia
  FROM CDN.BnkZdarzenia, deleted
  WHERE deleted.EDN_EDNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=12)
  END
    IF EXISTS(SELECT D.EDN_PreDekID FROM Deleted D WHERE D.EDN_PreDekID IS NOT NULL)
  DELETE CDN.DekretyNag
  FROM CDN.DekretyNag, deleted
  WHERE deleted.EDN_PreDekId = CDN.DekretyNag.DeN_DeNID
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.EwidDodNag_InsertUpdate_Trigger
  ON CDN.EwidDodNag
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Sprawdzanie obecności wierszy w tabeli nadrzędnej ZapisyKPR
IF EXISTS
  (SELECT * FROM inserted
   LEFT OUTER JOIN CDN.ZapisyKPR ON EDN_KPRID = KPR_KPRID AND KPR_Zrodlo = 12
   WHERE KPR_KPRID IS NULL
   AND EDN_KPRID IS NOT NULL
  )
  BEGIN
    RAISERROR('##OPT32024##%%1%%=ZapisyKPR##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
IF EXISTS
  (SELECT * FROM inserted
   LEFT OUTER JOIN CDN.DekretyNag ON EDN_DekID = DeN_DeNID AND DeN_Zrodlo = 12
   WHERE DeN_DeNID IS NULL
   AND EDN_DekID IS NOT NULL
  )
  BEGIN
    RAISERROR('##OPT32024##%%1%%=DekretyNag##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzanie obecności wierszy w tabeli nadrzędnej Ryczalt
IF EXISTS
  (SELECT * FROM inserted
   LEFT OUTER JOIN CDN.Ryczalt ON EDN_RycID = Ryc_RycID AND Ryc_Zrodlo = 12
   WHERE Ryc_RycID IS NULL
   AND EDN_RycID IS NOT NULL
  )
  BEGIN
    RAISERROR('##OPT32024##%%1%%=Ryczalt##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
--Sprawdzanie zaliczkobiorcy
--  Sprawdzanie obecności wiersza w tabeli Kontrahenci
    IF EXISTS (SELECT * FROM inserted WHERE inserted.EDN_PodmiotZalTyp=1)
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.Kontrahenci ON
                    inserted.EDN_PodZalId       = CDN.Kontrahenci.Knt_KntId
              WHERE CDN.Kontrahenci.Knt_KntId IS NULL AND (inserted.EDN_PodmiotZalTyp=1)
           )
        BEGIN
    RAISERROR('##OPT32025##%%1%%=Kontrahenci##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--  Sprawdzanie obecności wiersza w tabeli BnkNazwy
    IF EXISTS (SELECT * FROM inserted WHERE inserted.EDN_PodmiotZalTyp=2)
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkNazwy ON
                    inserted.EDN_PodZalId       = CDN.BnkNazwy.BNa_BNaId
              WHERE CDN.BnkNazwy.BNa_BNaId IS NULL AND (inserted.EDN_PodmiotZalTyp=2)
           )
        BEGIN
    RAISERROR('##OPT32025##%%1%%=BnkNazwy##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--  Sprawdzanie obecności wiersza w tabeli PracKod
    IF EXISTS (SELECT * FROM inserted WHERE inserted.EDN_PodmiotZalTyp=3)
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.PracKod ON
                    inserted.EDN_PodZalId       = CDN.PracKod.PrA_PrAId
              WHERE CDN.PracKod.PrA_PrAId IS NULL AND (inserted.EDN_PodmiotZalTyp=3)
           )
        BEGIN
          RAISERROR('##OPT32025##%%1%%=PracKod##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--  Sprawdzanie obecności wiersza w tabeli Urzedy
    IF EXISTS (SELECT * FROM inserted WHERE inserted.EDN_PodmiotZalTyp=5)
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.Urzedy ON
                    inserted.EDN_PodZalId       = CDN.Urzedy.Urz_UrzId
              WHERE CDN.Urzedy.Urz_UrzId IS NULL AND (inserted.EDN_PodmiotZalTyp=5)
           )
        BEGIN
          RAISERROR('##OPT32025##%%1%%=Urzedy##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Koniec sprawdzania zaliczkobiorcy
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where EDN_ImportRowId Is Null Or EDN_ImportRowId = '')
  Update CDN.EwidDodNag Set EDN_ImportRowId = NewId()
  Where EDN_EDNId In (Select EDN_EDNId From inserted Where EDN_ImportRowId Is Null Or EDN_ImportRowId = '')
  SET NOCOUNT OFF
