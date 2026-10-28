CREATE TABLE [CDN].[OkresyObrach] (
    [OOb_OObID]               INT            IDENTITY (1, 1) NOT NULL,
    [OOb_Symbol]              VARCHAR (5)    NOT NULL,
    [OOb_DataOtw]             DATETIME       NOT NULL,
    [OOb_Dlugosc]             SMALLINT       NOT NULL,
    [OOb_DataKoncowa]         DATETIME       NOT NULL,
    [OOb_DataZam]             DATETIME       NULL,
    [OOb_CiaglaNumeracjaDC]   INT            NOT NULL,
    [OOb_Stan]                SMALLINT       NOT NULL,
    [OOb_Opis]                NVARCHAR (254) NOT NULL,
    [OOb_OpeZalID]            INT            NULL,
    [OOb_StaZalId]            INT            NULL,
    [OOb_TS_Zal]              DATETIME       NOT NULL,
    [OOb_OpeModID]            INT            NULL,
    [OOb_StaModId]            INT            NULL,
    [OOb_TS_Mod]              DATETIME       NOT NULL,
    [OOb_DziIdRK]             INT            NULL,
    [OOb_DziIdKomp]           INT            NULL,
    [OOb_DataKsiRk]           SMALLINT       CONSTRAINT [DF_OOb_DataKsiRk] DEFAULT ((1)) NOT NULL,
    [OOb_DataKsiKomp]         SMALLINT       CONSTRAINT [DF_OOb_DataKsiKomp] DEFAULT ((1)) NOT NULL,
    [OOb_OpeModKod]           VARCHAR (20)   CONSTRAINT [DF_OOb_OpeModKod] DEFAULT ('') NOT NULL,
    [OOb_OpeModNazwisko]      NVARCHAR (50)  CONSTRAINT [DF_OOb_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [OOb_OpeZalKod]           VARCHAR (20)   CONSTRAINT [DF_OOb_OpeZalKod] DEFAULT ('') NOT NULL,
    [OOb_OpeZalNazwisko]      NVARCHAR (50)  CONSTRAINT [DF_OOb_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [OOb_ZaliczkiUproszczone] INT            CONSTRAINT [DF_OOb_ZaliczkiUproszczone] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [OOb_Primary] PRIMARY KEY CLUSTERED ([OOb_OObID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [OObSymbol]
    ON [CDN].[OkresyObrach]([OOb_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [OObData]
    ON [CDN].[OkresyObrach]([OOb_DataOtw] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.OkresyObrach_InsertUpdate_Trigger
  ON CDN.OkresyObrach
  FOR INSERT, UPDATE
AS
SET NOCOUNT ON
IF UPDATE (OOb_DataOtw) OR UPDATE (OOb_DataKoncowa)
  BEGIN
    DECLARE @OObId INT, @DataOtw DATETIME, @Dlugosc SMALLINT, @DataKon DATETIME
 DECLARE @OObId_del INT, @DataOtw_del DATETIME, @DataKon_del DATETIME
    DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR SELECT OOb_OObId, OOb_DataOtw, OOb_Dlugosc, OOb_DataKoncowa FROM inserted
    OPEN Dodane
    WHILE 1=1
    BEGIN
      FETCH NEXT FROM Dodane INTO @OObId, @DataOtw, @Dlugosc, @DataKon
      IF @@FETCH_STATUS <> 0 BREAK
  SELECT @DataOtw_del = OOb_DataOtw, @DataKon_del = OOb_DataKoncowa FROM deleted WHERE deleted.OOb_OObID = @OObId
  IF @DataOtw_del < @DataOtw
  BEGIN
  IF EXISTS(SELECT * FROM CDN.DeklNag WHERE DkN_TypDeklar = 40 AND DkN_RokMiesiac >= Year(@DataOtw_del) * 100 + Month(@DataOtw_del) AND DkN_RokMiesiac < Year(@DataOtw) * 100 + Month(@DataOtw))
   BEGIN
    exec CDN.RiseOptimaException 32635
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
   END
  END
  IF @DataKon_del > @DataKon
  BEGIN
  IF EXISTS(SELECT * FROM CDN.DeklNag WHERE DkN_TypDeklar = 40 AND DkN_RokMiesiac > Year(@DataKon) * 100 + Month(@DataKon) AND DkN_RokMiesiac <= Year(@DataKon_del) * 100 + Month(@DataKon_del))
   BEGIN
    exec CDN.RiseOptimaException 32636
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
   END
  END
      IF EXISTS (SELECT * FROM CDN.DekretyNag WHERE DeN_OObId = @OObId AND DeN_Typ = 2 AND DeN_DataDok NOT BETWEEN @DataOtw AND @DataKon)
        BEGIN
     exec CDN.RiseOptimaException 32637
           ROLLBACK TRAN
           SET NOCOUNT OFF
           RETURN
        END
      IF EXISTS (SELECT * FROM CDN.OkresyObrach WHERE OOb_OObId <> @OObId AND
  (OOb_DataOtw Between @DataOtw And @DataKon OR
  OOb_DataKoncowa Between @DataOtw And @DataKon OR
  @DataOtw Between OOb_DataOtw And OOb_DataKoncowa))
        BEGIN
     exec CDN.RiseOptimaException 32638
           ROLLBACK TRAN
           SET NOCOUNT OFF
           RETURN
        END
    END
  END
IF UPDATE (OOb_Stan)
  BEGIN
    IF EXISTS (SELECT * FROM CDN.DekretyNag JOIN inserted ON DeN_OObId = OOb_OObId
               WHERE OOb_Stan = 1 AND DeN_Bufor = 1 AND DeN_Typ = 2)
        BEGIN
     exec CDN.RiseOptimaException 32639
           ROLLBACK TRAN
           SET NOCOUNT OFF
           RETURN
        END
    IF EXISTS (SELECT * FROM CDN.BONag JOIN inserted ON BON_OObId = OOb_OObId
               WHERE OOb_Stan = 1 AND BON_Bufor = 1)
        BEGIN
     exec CDN.RiseOptimaException 32640
           ROLLBACK TRAN
           SET NOCOUNT OFF
           RETURN
        END
    IF EXISTS (SELECT * FROM CDN.BONag JOIN inserted ON BON_OObPrevId = OOb_OObId
               WHERE OOb_Stan = 1 AND BON_Bufor = 1 AND BON_BilansZamkniecia = 1)
        BEGIN
     exec CDN.RiseOptimaException 32641
           ROLLBACK TRAN
           SET NOCOUNT OFF
           RETURN
        END
  END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.OkresyObrach_Delete_Trigger
  ON CDN.OkresyObrach
  FOR DELETE
AS
SET NOCOUNT ON
 if exists(select * from CDN.KsiDokNag join Deleted On (Deleted.OOb_OObId = KDN_OObID))
 begin
  exec CDN.RiseOptimaException 32642
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 end
 if exists (select * from CDN.DekretyNag join Deleted on (DeN_OObId = Deleted.OOb_OObID and DeN_Typ=2))
 begin
  exec CDN.RiseOptimaException 32643
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 end
 IF EXISTS ( SELECT * FROM CDN.DeklNag
 WHERE DkN_TypDeklar = 40
 AND DkN_RokMiesiac BETWEEN (SELECT YEAR(OOb_DataOtw) * 100 + Month(OOb_DataOtw) FROM Deleted) AND (SELECT Year(OOb_DataKoncowa) * 100 + Month(OOb_DataKoncowa) FROM Deleted))
 begin
  exec CDN.RiseOptimaException 32644
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 end
 if exists (select * from CDN.DekretyNag join deleted on (DeN_OObId = deleted.OOb_OObID and DeN_Typ=1))
  delete CDN.DekretyNag
  from
  CDN.DekretyNag join deleted on (DeN_OObId = deleted.OOb_OObID and DeN_Typ=1)
SET NOCOUNT OFF
