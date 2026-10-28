CREATE TABLE [CDN].[Dzienniki] (
    [Dzi_DziId]          INT           IDENTITY (1, 1) NOT NULL,
    [Dzi_Symbol]         VARCHAR (20)  NOT NULL,
    [Dzi_Nazwa]          VARCHAR (50)  NOT NULL,
    [Dzi_OObId]          INT           NOT NULL,
    [Dzi_OpeZalID]       INT           NULL,
    [Dzi_StaZalId]       INT           NULL,
    [Dzi_TS_Zal]         DATETIME      NOT NULL,
    [Dzi_OpeModID]       INT           NULL,
    [Dzi_StaModId]       INT           NULL,
    [Dzi_TS_Mod]         DATETIME      NOT NULL,
    [Dzi_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_Dzi_OpeModKod] DEFAULT ('') NOT NULL,
    [Dzi_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_Dzi_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Dzi_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_Dzi_OpeZalKod] DEFAULT ('') NOT NULL,
    [Dzi_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_Dzi_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [Dzi_Primary] PRIMARY KEY CLUSTERED ([Dzi_DziId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DziSymbol] FOREIGN KEY ([Dzi_OObId]) REFERENCES [CDN].[OkresyObrach] ([OOb_OObID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DziSymbol]
    ON [CDN].[Dzienniki]([Dzi_OObId] ASC, [Dzi_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Dzienniki_Update_Trigger
  ON CDN.Dzienniki
  FOR UPDATE
AS
SET NOCOUNT ON
IF UPDATE (Dzi_Symbol)
 IF EXISTS (SELECT * FROM CDN.DekretyNag JOIN inserted ON DeN_DziId = Dzi_DziId)
  BEGIN
 exec CDN.RiseOptimaException 32610
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Dzienniki_Delete_Trigger
  ON CDN.Dzienniki
  FOR DELETE
AS
SET NOCOUNT ON
 if exists (select * from CDN.DekretyNag join Deleted on (DeN_DziID = Deleted.Dzi_DziId and DeN_Typ=2))
 begin
  exec CDN.RiseOptimaException 32611
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 end
 if exists (select * from CDN.DekretyNag join Deleted on (DeN_DziID = Deleted.Dzi_DziId and DeN_Typ=1))
 begin
  delete CDN.DekretyNag
  from
  CDN.DekretyNag join Deleted on (DeN_DziID = Deleted.Dzi_DziId and DeN_Typ=1)
 end
 declare @maxDziId int;
 declare @symbolOOb nvarchar(5);
 if exists (select * from Deleted join cdn.OkresyObrach on (Deleted.Dzi_OObId = OOb_OObID and Deleted.Dzi_DziID = OOb_DziIdRK))
 begin
  select @maxDziId = max(Deleted.Dzi_DziID) from Deleted join cdn.OkresyObrach on (Deleted.Dzi_OObId = OOb_OObID and Deleted.Dzi_DziID = OOb_DziIdRK)
  select @symbolOOb = OOb_Symbol from Deleted join cdn.OkresyObrach on (Deleted.Dzi_OObId = OOb_OObID and Deleted.Dzi_DziID = OOb_DziIdRK) where Deleted.Dzi_DziId = @maxDziId
  exec CDN.RiseOptimaException 32612, 's', @symbolOOb
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 end
 if exists (select * from Deleted join cdn.OkresyObrach on (Deleted.Dzi_OObId = OOb_OObID and Deleted.Dzi_DziID = OOb_DziIdKomp))
 begin
  select @maxDziId = max(Deleted.Dzi_DziID) from Deleted join cdn.OkresyObrach on (Deleted.Dzi_OObId = OOb_OObID and Deleted.Dzi_DziID = OOb_DziIdKomp)
  select @symbolOOb = OOb_Symbol from Deleted join cdn.OkresyObrach on (Deleted.Dzi_OObId = OOb_OObID and Deleted.Dzi_DziID = OOb_DziIdKomp) where Deleted.Dzi_DziId = @maxDziId
  exec CDN.RiseOptimaException 32613, 's', @symbolOOb
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 end
SET NOCOUNT OFF
