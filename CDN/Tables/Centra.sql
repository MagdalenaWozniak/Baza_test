CREATE TABLE [CDN].[Centra] (
    [CNT_CntId]          INT            IDENTITY (1, 1) NOT NULL,
    [CNT_Kod]            VARCHAR (40)   NOT NULL,
    [CNT_Nazwa]          NVARCHAR (254) NOT NULL,
    [CNT_ParentId]       INT            NULL,
    [CNT_Nieaktywny]     SMALLINT       NOT NULL,
    [CNT_AdresWezla]     NVARCHAR (512) NOT NULL,
    [CNT_Poziom]         SMALLINT       NOT NULL,
    [CNT_Lisc]           INT            NOT NULL,
    [CNT_AddMethod]      TINYINT        NOT NULL,
    [CNT_ImpId]          INT            NOT NULL,
    [CNT_Last]           TINYINT        NOT NULL,
    [CNT_OpeZalId]       INT            NULL,
    [CNT_StaZalId]       INT            NULL,
    [CNT_TS_Zal]         DATETIME       NOT NULL,
    [CNT_OpeModId]       INT            NULL,
    [CNT_StaModId]       INT            NULL,
    [CNT_TS_Mod]         DATETIME       NOT NULL,
    [CNT_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_CNT_OpeModKod] DEFAULT ('') NOT NULL,
    [CNT_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_CNT_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [CNT_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_CNT_OpeZalKod] DEFAULT ('') NOT NULL,
    [CNT_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_CNT_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [CNT_Primary] PRIMARY KEY CLUSTERED ([CNT_CntId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CNTParrent] FOREIGN KEY ([CNT_ParentId]) REFERENCES [CDN].[Centra] ([CNT_CntId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [CNTInclude]
    ON [CDN].[Centra]([CNT_ParentId] ASC, [CNT_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [CNTGridLookupFilter]
    ON [CDN].[Centra]([CNT_Kod] ASC, [CNT_CntId] ASC)
    INCLUDE([CNT_Nieaktywny], [CNT_Nazwa], [CNT_AdresWezla]) WITH (FILLFACTOR = 100);


GO
create trigger CDN.Centra_Insert_Trigger
 on CDN.Centra
 for insert
as
 set nocount on
 declare @NewId int, @ParentId int
 select @NewId = cnt_cntid, @ParentId = CNT_ParentId from inserted
 insert into cdn.centralink (cnl_cntid, cnl_parentid) values (@NewId, 0)
 while @ParentId > 0
 begin
  if @ParentId > 0
  begin
   insert into cdn.centralink (cnl_cntid, cnl_parentid) values (@NewId, @ParentId)
   select @ParentId = CNT_ParentId from cdn.centra where CNT_CntId = @ParentId
  end
 end
 set nocount off

GO
create trigger cdn.Centra_Delete_Trigger
  on cdn.Centra
  for delete
as
  set nocount on
    -- Sprawdzanie, czy nie skasowano centrum o Id=3 (FIRMA)
    if exists (select * from deleted where deleted.CNT_CntId = 3)
    begin
      RAISERROR('##OPT32497##', 16, 1)--raiserror('Nie można kasować nadrzędnego centrum podległościowego FIRMA. ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacCentrum
      rollback tran
      set nocount off
      return
    end
 delete from cdn.CentraLink where CNL_CntId = (select cnt_cntid from deleted)
  set nocount off
