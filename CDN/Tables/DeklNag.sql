CREATE TABLE [CDN].[DeklNag] (
    [DkN_DkNID]                        INT             IDENTITY (1, 1) NOT NULL,
    [DkN_DkkId]                        INT             NULL,
    [DkN_ParentId]                     INT             NULL,
    [DkN_Data]                         DATETIME        NULL,
    [DkN_Numer]                        INT             NOT NULL,
    [DkN_PraID]                        INT             NULL,
    [DkN_TypDeklar]                    SMALLINT        NOT NULL,
    [DkN_RokMiesiac]                   INT             NOT NULL,
    [DkN_Wersja]                       TINYINT         NOT NULL,
    [DkN_Zablokowana]                  TINYINT         NOT NULL,
    [DkN_DekId]                        INT             NULL,
    [DkN_PreDekId]                     INT             NULL,
    [DkN_ImportRowID]                  VARCHAR (36)    NULL,
    [DkN_OpeZalID]                     INT             NULL,
    [DkN_StaZalId]                     INT             NULL,
    [DkN_TS_Zal]                       DATETIME        NOT NULL,
    [DkN_OpeModID]                     INT             NULL,
    [DkN_StaModId]                     INT             NULL,
    [DkN_TS_Mod]                       DATETIME        NOT NULL,
    [DkN_EDekl_RefID]                  NVARCHAR (240)  NULL,
    [DkN_EDekl_Status]                 INT             NULL,
    [DkN_EDekl_StatusOpis]             NVARCHAR (1000) NULL,
    [DkN_EDekl_Podmiot]                NVARCHAR (1000) NULL,
    [DkN_EDekl_DokumentID]             VARCHAR (240)   NULL,
    [DkN_EDekl_DataWplyniecia]         NVARCHAR (50)   NULL,
    [DkN_EDekl_SkrotDokumentu]         NVARCHAR (240)  NULL,
    [DkN_EDekl_SkrotStruktury]         NVARCHAR (240)  NULL,
    [DkN_EDekl_StrukturaLogiczna]      NVARCHAR (240)  NULL,
    [DkN_EDekl_NIP1]                   VARCHAR (50)    NULL,
    [DkN_EDekl_NIP2]                   VARCHAR (50)    NULL,
    [DkN_EDekl_SigningTime]            NVARCHAR (50)   NULL,
    [DkN_EDekl_StempelCzasu]           NVARCHAR (240)  NULL,
    [DkN_EDekl_OperatorWysylajacy]     INT             NULL,
    [DkN_EDekl_OperatorPobierajacyUPO] INT             NULL,
    [DkN_EDekl_DataWyslania]           DATETIME        NULL,
    [DkN_EDekl_DataOdebraniaUPO]       DATETIME        NULL,
    [DkN_EDekl_KodUrzedu]              VARCHAR (6)     NULL,
    [DkN_ConstNIP]                     NVARCHAR (20)   NULL,
    [DkN_Finalna]                      AS              ([CDN].[DEKLFINALNA]([DKN_DKNID],[DKN_ROKMIESIAC])),
    [DkN_OpeModKod]                    VARCHAR (20)    CONSTRAINT [DF_DkN_OpeModKod] DEFAULT ('') NOT NULL,
    [DkN_OpeModNazwisko]               NVARCHAR (50)   CONSTRAINT [DF_DkN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DkN_OpeZalKod]                    VARCHAR (20)    CONSTRAINT [DF_DkN_OpeZalKod] DEFAULT ('') NOT NULL,
    [DkN_OpeZalNazwisko]               NVARCHAR (50)   CONSTRAINT [DF_DkN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [DkN_Pra2ID]                       INT             NULL,
    [DkN_Kwota]                        AS              ([CDN].[KWOTADEKLARACJI]([DKN_DKNID])),
    CONSTRAINT [DkN_Primary] PRIMARY KEY CLUSTERED ([DkN_DkNID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DKNDeklKedu] FOREIGN KEY ([DkN_DkkId]) REFERENCES [CDN].[DeklKedu] ([DKK_DkkId]) ON DELETE CASCADE,
    CONSTRAINT [FK_DkNPodatnik] FOREIGN KEY ([DkN_PraID]) REFERENCES [CDN].[PracKod] ([PRA_PraId]),
    CONSTRAINT [FK_DkNWspolwlasciciel] FOREIGN KEY ([DkN_Pra2ID]) REFERENCES [CDN].[PracKod] ([PRA_PraId])
);


GO
CREATE NONCLUSTERED INDEX [DkNDekretyNag]
    ON [CDN].[DeklNag]([DkN_DekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DkNPreDekret]
    ON [CDN].[DeklNag]([DkN_PreDekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DKNDeklKedu]
    ON [CDN].[DeklNag]([DkN_DkkId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DKNParentId]
    ON [CDN].[DeklNag]([DkN_ParentId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DkNPodatnik]
    ON [CDN].[DeklNag]([DkN_PraID] ASC, [DkN_TypDeklar] ASC, [DkN_RokMiesiac] ASC, [DkN_Data] ASC, [DkN_Numer] ASC, [DkN_ParentId] ASC, [DkN_ConstNIP] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DkNRokMies]
    ON [CDN].[DeklNag]([DkN_TypDeklar] ASC, [DkN_RokMiesiac] ASC, [DkN_Data] ASC, [DkN_Numer] ASC, [DkN_PraID] ASC, [DkN_ParentId] ASC, [DkN_ConstNIP] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DeklNag_Delete_Trigger
  ON CDN.DeklNag
  FOR DELETE
AS
 SET NOCOUNT ON
 SET ARITHABORT ON
-- Sprawdzenie, czy deklaracja zostala zablokowana
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.DkN_Zablokowana = 1)
    BEGIN
      RAISERROR('##OPT34717##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Kasowanie deklaracji podrzędnych
Delete CDN.DeklNag Where DkN_ParentId In (Select DkN_DkNId From deleted)
-- Kasowanie zalacznikow VAT-UEA, UEB i UEC
Delete CDN.DeklNag
From CDN.DeklNag
Join deleted ON CDN.DeklNag.DkN_TypDeklar IN (13,14,23) AND deleted.DkN_TypDeklar = 11
  AND CDN.DeklNag.DkN_RokMiesiac = deleted.DkN_RokMiesiac
Declare @DokId Int
Declare skasowane Cursor Local Fast_Forward For
 Select DkN_DkNId From deleted
Open skasowane
While 1=1
 Begin
  Fetch Next From skasowane InTo @DokId
  If @@Fetch_Status <> 0 Break
  Execute CDN.KasujRozliczenia 6, @DokId
 End
Close skasowane
Deallocate skasowane
-- obsługa kaskadowego kasowania wierszy z tabeli CDN.RptObrazy2
    DELETE CDN.RptObrazy2
    FROM CDN.RptObrazy2, deleted
    WHERE
          deleted.DkN_DkNID = CDN.RptObrazy2.Rpo2_DokumentId
      AND (CDN.RptObrazy2.Rpo2_DokumentTyp=100)
--
-- Skasowanie relacji do dokumentów  (WiNi)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp= 30000 + deleted.DkN_TypDeklar AND DoR_DokumentId=deleted.DkN_DkNId
Set NoCount Off

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[DeklNag_Delete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
CREATE TRIGGER CDN.DeklNag_InsertUpdate_Trigger
  ON CDN.DeklNag
  FOR INSERT, UPDATE
AS
SET NOCOUNT ON
SET ARITHABORT ON
--Sprawdzanie czy deklaracja może być zaksięgowana/odblokowana
If Update(DkN_DekId)
 If Exists
 (Select * From inserted Where DkN_DekId Is Not Null And DkN_Zablokowana = 0)
  Begin
   RaisError('Nie można księgować deklaracji niezatwierdzonej.', 16, 1)
   Rollback Transaction
   Set NoCount Off
   Return
  End
--Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
IF EXISTS
 (SELECT * FROM inserted LEFT OUTER JOIN CDN.DekretyNag ON inserted.DkN_DekID = CDN.DekretyNag.DeN_DeNId
  WHERE CDN.DekretyNag.DeN_DeNId IS NULL
    AND inserted.DkN_DekID IS NOT NULL )
  BEGIN
   RAISERROR('Brak wartości w tabeli nadrzędnej (DekretyNag) ', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  END
--Sprawdzanie obecności deklaracji nadrzędnej
IF EXISTS
 (SELECT * FROM inserted LEFT OUTER JOIN CDN.DeklNag ON inserted.DkN_ParentID = CDN.DeklNag.DkN_DkNId
  WHERE CDN.DeklNag.DkN_DkNId IS NULL
    AND inserted.DkN_ParentID IS NOT NULL )
  BEGIN
   RAISERROR('Brak deklaracji nadrzędnej (DeklNag) ', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  END
--Obsługa załączników VAT-UE/A, VAT-UE/B i VAT-UE/C oraz PIT/B i PIT-28/B
If Update (DkN_Zablokowana)
 Begin
  Update CDN.DeklNag
   Set DkN_Zablokowana = inserted.DkN_Zablokowana
   From CDN.DeklNag Join inserted
     On CDN.DeklNag.DkN_TypDeklar In (13,14,23) And inserted.DkN_TypDeklar = 11
    And CDN.DeklNag.DkN_RokMiesiac = inserted.DkN_RokMiesiac
  Update CDN.DeklNag
   Set DkN_Zablokowana = parent.DkN_Zablokowana
   From CDN.DeklNag Join inserted On CDN.DeklNag.DkN_DkNId = inserted.DkN_DkNId
   Join CDN.DeklNag parent
     On CDN.DeklNag.DkN_TypDeklar In (13,14,23) And parent.DkN_TypDeklar = 11
    And CDN.DeklNag.DkN_RokMiesiac = parent.DkN_RokMiesiac
 End
-- Obsługa "odblokowania" deklaracji
IF UPDATE (DkN_Zablokowana) And Exists (Select * From deleted)
 BEGIN
-- Sprawdzenie, czy deklaracja nie jest zaksięgowana
  If Exists
  (Select * From inserted Where DkN_DekId Is Not Null And DkN_Zablokowana = 0)
   Begin
    RaisError('Nie można odblokować zaksięgowanej deklaracji.', 16, 1)
    Rollback Transaction
    Set NoCount Off
    Return
   End
-- Aktualizacja skojarzonych zapisów z BnkZdarzenia
Declare @DokId Int
Declare anulowane Cursor Local Fast_Forward For
 Select DkN_DkNId From inserted Where DkN_Zablokowana = 0
Open anulowane
While 1=1
 Begin
  Fetch Next From anulowane InTo @DokId
  If @@Fetch_Status <> 0 Break
  Execute CDN.KasujRozliczenia 6, @DokId
 End
Close anulowane
Deallocate anulowane
-- Sprawdzenie rozliczonych zdarzeń
  IF EXISTS (SELECT * FROM CDN.BnkZdarzenia JOIN CDN.BnkRozRelacje ON BRR_ZDokTyp = 1 AND BRR_ZDokID = BZd_BZdId
             WHERE BZd_DokumentTyp = 6 AND BZd_DokumentId IN (SELECT DkN_DkNId FROM inserted WHERE DkN_Zablokowana = 0))
    BEGIN
     RAISERROR('Dokument posiada rozliczone płatności (BnkZdarzenia). ', 16, 1)
     ROLLBACK TRAN
     SET NOCOUNT OFF
     RETURN
    END
-- Sprawdzenie dokumentów BnkDokElem
  IF EXISTS (SELECT * FROM CDN.BnkZdarzenia JOIN CDN.BnkDokElem ON BDE_DokTyp = 1 AND BDE_DokID = BZd_BZdId
             WHERE BZd_DokumentTyp = 6 AND BZd_DokumentId IN (SELECT DkN_DkNId FROM inserted WHERE DkN_Zablokowana = 0))
    BEGIN
     RAISERROR('Deklaracja powiązana z potwierdzeniem salda (BnkDokElem). ', 16, 1)
     ROLLBACK TRAN
     SET NOCOUNT OFF
     RETURN
    END
-- Sprawdzenie dokumentów NotyOdsElem
  IF EXISTS (SELECT * FROM CDN.BnkZdarzenia JOIN CDN.NotyOdsElem ON NOE_BZdID = BZd_BZdId
             WHERE BZd_DokumentTyp = 6 AND BZd_DokumentId IN (SELECT DkN_DkNId FROM inserted WHERE DkN_Zablokowana = 0))
    BEGIN
     RAISERROR('Deklaracja powiązana z notą odsetkową (NotyOdsElem). ', 16, 1)
     ROLLBACK TRAN
     SET NOCOUNT OFF
     RETURN
    END
-- Update wszystkich tylko nie VAT7
  UPDATE CDN.BnkZdarzenia
    SET BZd_Stan = 0
    WHERE BZd_Stan <> 0 AND BZd_DokumentTyp = 6 AND BZd_DokumentId IN (SELECT DkN_DkNId FROM inserted WHERE DkN_Zablokowana = 0 and DkN_TypDeklar <> 1)
 declare @BZd_NumerPelny nvarchar(128), @BZd_Kierunek int
 select top 1 @BZd_NumerPelny = BZd_NumerPelny, @BZd_Kierunek = BZd_Kierunek from CDN.BnkZdarzenia
 where BZd_Stan <> 0 and BZd_DokumentTyp = 6 and BZd_DokumentId in (SELECT DkN_DkNId FROM inserted WHERE DkN_Zablokowana = 0 and DkN_TypDeklar <> 1)
 declare @IdParam int
 set @IdParam = SCOPE_IDENTITY()
  if @BZd_NumerPelny is not null
  begin
    exec [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1001, -- OptimaObjectType_ZdarzenieKB
    @ObiektSubTyp = @BZd_Kierunek,
    @ObiektID = @IdParam,
    @ObiektNazwa = @BZd_NumerPelny,
    @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
    @Opis = '' -- @OpisDok
  end
-- Update VAT7
    UPDATE CDN.BnkZdarzenia SET BZd_Stan = 0
    FROM CDN.BnkZdarzenia INNER JOIN inserted on (BZd_DokumentId = DkN_DkNID)
    where
    BZd_Stan <> 0 AND BZd_DokumentTyp = 6 and DkN_TypDeklar = 1
    and Year(BZd_Termin) = DkN_RokMiesiac/100 and Month(BZd_Termin) > DkN_RokMiesiac%100
-- obsługa kasowania wierszy z tabeli CDN.RptObrazy2
    DELETE CDN.RptObrazy2
    FROM CDN.RptObrazy2, deleted
    WHERE
          deleted.DkN_DkNID = CDN.RptObrazy2.Rpo2_DokumentId
      AND (CDN.RptObrazy2.Rpo2_DokumentTyp=100)
-- obsługa kasowania zapisów w CDN.RptObrazy2 dla deklaracji płacowych
   DELETE FROM CDN.RptObrazy2 WHERE RpO2_DokumentID IN
      (SELECT Bzd_BzdId FROM CDN.BnkZdarzenia JOIN inserted ON inserted.DkN_DknId = BzD_DokumentId
        JOIN RptObrazy2 A ON A.Rpo2_DokumentId = BzD_BzdId
          WHERE RpO2_DokumentTyp = 120 and BzD_dokumentTyp = 6 AND DkN_Typdeklar IN (120,121,122,123,124)
            AND inserted.Dkn_Zablokowana = 0)
 END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.DeklNag_DeleteHandler
  ON CDN.DeklNag
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.DkN_DkNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=6)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.DkN_DkNID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=6)
    IF EXISTS(
   SELECT * FROM CDN.BnkZdarzenia INNER JOIN deleted
   ON deleted.DkN_DkNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=6)
  )
 begin
  --[logowanie]
  create table #BZdIDs (ID int)
  insert into #BZdIDs
   select BZd_BZdID from CDN.BnkZdarzenia inner join deleted on deleted.DkN_DkNID = CDN.BnkZdarzenia.BZd_DokumentId and (CDN.BnkZdarzenia.BZd_DokumentTyp = 6)
  exec cdn.RejestrOperacjiDodajEx
    @ObiektTyp = '1001',
    @ObiektSubTyp = 'BZd_Kierunek',
    @ObiektID = 'BZd_BZdID',
    @ObiektNazwa = 'BZd_NumerPelny',
    @OperacjaTyp = 3,
    @Opis = '''''',
    @From = 'cdn.BnkZdarzenia',
    @Where = 'BZd_BZdID in (select ID from #BZdIDs)'
  drop table #BZdIDs
  DELETE CDN.BnkZdarzenia
  FROM CDN.BnkZdarzenia, deleted
  WHERE deleted.DkN_DkNID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=6)
 end
    IF EXISTS(SELECT D.DkN_PreDekID FROM Deleted D WHERE D.DkN_PreDekID IS NOT NULL)
  DELETE CDN.DekretyNag
  FROM CDN.DekretyNag, deleted
  WHERE deleted.DkN_PreDekId = CDN.DekretyNag.DeN_DeNID
SET NOCOUNT OFF
