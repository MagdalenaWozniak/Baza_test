CREATE TABLE [CDN].[DefAtrybuty] (
    [DeA_DeAId]                  INT           IDENTITY (1, 1) NOT NULL,
    [DeA_Typ]                    TINYINT       NOT NULL,
    [DeA_Kod]                    VARCHAR (20)  NOT NULL,
    [DeA_Nazwa]                  NVARCHAR (40) NOT NULL,
    [DeA_Format]                 SMALLINT      NOT NULL,
    [DeA_Zalezny]                TINYINT       NOT NULL,
    [DeA_CzyKopiowacFA]          TINYINT       NOT NULL,
    [DeA_CzyKopiowacDoVAT]       TINYINT       NOT NULL,
    [DeA_CzyKod]                 TINYINT       NOT NULL,
    [DeA_CzyPrzenosic]           TINYINT       NOT NULL,
    [DeA_CzyDrukowac]            TINYINT       NOT NULL,
    [DeA_CzyPrzenosicNaDostawy]  TINYINT       NOT NULL,
    [DeA_CzyObowiazkowyDostawy]  TINYINT       NOT NULL,
    [DeA_ESklep]                 TINYINT       NULL,
    [DeA_UdostepniajWMobile]     TINYINT       CONSTRAINT [DF_DeA_UdostepniajWMobile] DEFAULT ((0)) NOT NULL,
    [DeA_PozwalajNaEdycje]       TINYINT       CONSTRAINT [DF_DeA_PozwalajNaEdycje] DEFAULT ((0)) NOT NULL,
    [DeA_TS_Export]              DATETIME      NULL,
    [DeA_ImportAppId]            VARCHAR (5)   NULL,
    [DeA_ImportRowId]            VARCHAR (36)  NULL,
    [DeA_OpeZalID]               INT           NULL,
    [DeA_StaZalId]               INT           NULL,
    [DeA_TS_Zal]                 DATETIME      NOT NULL,
    [DeA_OpeModID]               INT           NULL,
    [DeA_StaModId]               INT           NULL,
    [DeA_JezykId]                SMALLINT      CONSTRAINT [DF_DeA_JezykId] DEFAULT ((1)) NOT NULL,
    [DeA_TS_Mod]                 DATETIME      NOT NULL,
    [DeA_AnalizyBI]              TINYINT       CONSTRAINT [DF_DeA_AnalizyBI] DEFAULT ((0)) NOT NULL,
    [DeA_PozwalajNaEdycjeESklep] TINYINT       CONSTRAINT [DF_DeA_PozwalajNaEdycjeESklep] DEFAULT ((0)) NOT NULL,
    [DeA_JPKDostepnyFA]          TINYINT       CONSTRAINT [DF_DeA_JPKDostepnyFA] DEFAULT ((0)) NOT NULL,
    [DeA_JPKDostepnyFAVAT]       TINYINT       CONSTRAINT [DF_DeA_JPKDostepnyFAVAT] DEFAULT ((0)) NOT NULL,
    [DeA_JPKDostepnyVAT]         TINYINT       CONSTRAINT [DF_DeA_JPKDostepnyVAT] DEFAULT ((0)) NOT NULL,
    [DeA_OpeModKod]              VARCHAR (20)  CONSTRAINT [DF_DeA_OpeModKod] DEFAULT ('') NOT NULL,
    [DeA_OpeModNazwisko]         NVARCHAR (50) CONSTRAINT [DF_DeA_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DeA_OpeZalKod]              VARCHAR (20)  CONSTRAINT [DF_DeA_OpeZalKod] DEFAULT ('') NOT NULL,
    [DeA_OpeZalNazwisko]         NVARCHAR (50) CONSTRAINT [DF_DeA_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [DeA_Primary] PRIMARY KEY CLUSTERED ([DeA_DeAId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DeAKod]
    ON [CDN].[DefAtrybuty]([DeA_Typ] ASC, [DeA_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DeAGridLookupFilter]
    ON [CDN].[DefAtrybuty]([DeA_Kod] ASC, [DeA_DeAId] ASC)
    INCLUDE([DeA_Typ], [DeA_Format], [DeA_Nazwa]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DefAtrybuty_Delete_Trigger
  ON CDN.DefAtrybuty
  FOR DELETE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy wartość atrybutu jest podpięta do środka trwałego
  IF EXISTS (SELECT * FROM deleted, CDN.TrwaleAtrybuty where deleted.DeA_Typ = 3 and deleted.DeA_DeAId = CDN.TrwaleAtrybuty.SrA_DeAId)
    BEGIN
      --RAISERROR('Nie można kasować wykorzystanych atrybutów.', 16, 1)
   EXEC CDN.RaiseOptimaException 34196
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- obsługa kaskadowego kasowania wierszy z tabeli CDN.TrwaleAtrybuty
 DELETE CDN.TrwaleAtrybuty
 FROM CDN.TrwaleAtrybuty, deleted
 WHERE deleted.DeA_Typ = 3 and deleted.DeA_DeAId = CDN.TrwaleAtrybuty.SrA_DeAId
  SET NOCOUNT OFF

GO
CREATE  TRIGGER CDN.DefAtrybuty_Insert_Trigger
  ON CDN.DefAtrybuty
  FOR INSERT
AS
  SET NOCOUNT ON
  -- Ustawianie unikalnego identyfikatora
  If Exists (Select * From inserted Where DeA_ImportRowId Is Null Or DeA_ImportRowId = '')
  Update CDN.DefAtrybuty Set DeA_ImportRowId = NewId()
  Where DeA_DeAId In (Select DeA_DeAId From inserted Where DeA_ImportRowId Is Null Or DeA_ImportRowId = '')
SET NOCOUNT OFF

GO
CREATE  TRIGGER CDN.DefAtrybuty_Update_Trigger
  ON CDN.DefAtrybuty
  FOR UPDATE
AS
  SET NOCOUNT ON
  IF EXISTS (SELECT * FROM inserted JOIN deleted ON deleted.DeA_DeAID = inserted.DeA_DeAID JOIN cdn.KntAtrybuty ON KnA_DeAID = deleted.DeA_DeAID WHERE inserted.DeA_Format <> deleted.DeA_Format)
 BEGIN
  --RAISERROR('Nie można zmieniać typu wykorzystanych definicji atrybutów (KntAtrybuty).', 16, 1)
  EXEC CDN.RaiseOptimaException 34197
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
  IF EXISTS (SELECT * FROM inserted JOIN deleted ON deleted.DeA_DeAID = inserted.DeA_DeAID JOIN cdn.TwrAtrybuty ON TwA_DeAID = deleted.DeA_DeAID WHERE inserted.DeA_Format <> deleted.DeA_Format)
 BEGIN
  --RAISERROR('Nie można zmieniać typu wykorzystanych definicji atrybutów (TwrAtrybuty).', 16, 1)
  EXEC CDN.RaiseOptimaException 34198
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
  IF EXISTS (SELECT * FROM inserted JOIN deleted ON deleted.DeA_DeAID = inserted.DeA_DeAID JOIN cdn.TrwaleAtrybuty ON SrA_DeAId = deleted.DeA_DeAID WHERE inserted.DeA_Format <> deleted.DeA_Format)
 BEGIN
  --RAISERROR('Nie można zmieniać typu wykorzystanych definicji atrybutów (TrwaleAtrybuty).', 16, 1)
  EXEC CDN.RaiseOptimaException 34199
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
  IF EXISTS (SELECT * FROM inserted JOIN deleted ON deleted.DeA_DeAID = inserted.DeA_DeAID JOIN cdn.DokAtrybuty ON DAt_DeAId = deleted.DeA_DeAID WHERE inserted.DeA_Format <> deleted.DeA_Format)
 BEGIN
  --RAISERROR('Nie można zmieniać typu wykorzystanych definicji atrybutów (DokAtrybuty).', 16, 1)
  EXEC CDN.RaiseOptimaException 34200
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
  If Not Update (DeA_TS_Export) And Exists (Select * From inserted Where DeA_TS_Export Is Not Null)
  Update CDN.DefAtrybuty Set DeA_TS_Export = Null Where DeA_DeAId In (Select DeA_DeAId From inserted Where DeA_TS_Export Is Not Null)
   if exists (select * from TwrAtrybuty join inserted on DeA_DeAId = twa_deaid where DeA_PozwalajNaEdycjeESklep = 1 and TwA_AtrybutGrupujacyFantom = 1)
  BEGIN
      --RAISERROR('Atrybut nie może być jednocześnie edytowalny i grupujący.', 16, 1)
   EXEC CDN.RaiseOptimaException 34201
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 -- odznaczenie czeka esklep na definicji odznacza na twratrybutach
  update Twr  set TwTS_TS_ModESklep = GETDATE() from CDN.TwrTSModEsklep Twr
 join cdn.Towary on TwTS_TwrId = Twr_TwrId
 where Twr_TwrId in (
 select twa_twrid from CDN.TwrAtrybuty join inserted on DeA_DeAId = twa_deaid where  TwA_ESklep = 1 and DeA_ESklep = 0)
 and exists (select * from cdn.TwrESklep where  Twr_TwrId = Twes_TwrID and Twes_Udostepnij = 1)
    insert into  CDN.TwrTSModEsklep
 select Twr_TwrId,GETDATE() from cdn.Towary
 left join CDN.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
 where TwTS_TwrId is null and Twr_TwrId in (
 select twa_twrid from CDN.TwrAtrybuty join inserted on DeA_DeAId = twa_deaid where  TwA_ESklep = 1 and DeA_ESklep = 0)
 and exists (select * from cdn.TwrESklep where  Twr_TwrId = Twes_TwrID and Twes_Udostepnij = 1)
 if exists (select twa_twaid from CDN.TwrAtrybuty join inserted on DeA_DeAId = twa_deaid where  isnull(TwA_ESklep,0) = 1 and isnull(DeA_ESklep,0) = 0)
    update CDN.TwrAtrybuty set TwA_ESklep = 0 where twa_twaid in (
    select twa_twaid from CDN.TwrAtrybuty join inserted on DeA_DeAId = twa_deaid where  isnull(TwA_ESklep,0) = 1 and isnull(DeA_ESklep,0) = 0)
SET NOCOUNT OFF
