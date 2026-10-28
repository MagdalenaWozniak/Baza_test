CREATE TABLE [CDN].[OpisyDniWolne] (
    [ODW_OdwId]          INT           IDENTITY (1, 1) NOT NULL,
    [ODW_Symbol]         NVARCHAR (2)  CONSTRAINT [DF_ODW_Symbol] DEFAULT ('') NOT NULL,
    [ODW_Nazwa]          NVARCHAR (45) CONSTRAINT [DF_ODW_Nazwa] DEFAULT ('') NOT NULL,
    [ODW_Standardowy]    SMALLINT      CONSTRAINT [DF_ODW_Standardowy] DEFAULT ((0)) NOT NULL,
    [ODW_Nieaktywny]     TINYINT       CONSTRAINT [DF_ODW_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [ODW_OpeZalId]       INT           NULL,
    [ODW_StaZalId]       INT           NULL,
    [ODW_TS_Zal]         DATETIME      NOT NULL,
    [ODW_OpeModId]       INT           NULL,
    [ODW_StaModId]       INT           NULL,
    [ODW_TS_Mod]         DATETIME      NOT NULL,
    [ODW_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_ODW_OpeModKod] DEFAULT ('') NOT NULL,
    [ODW_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_ODW_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [ODW_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_ODW_OpeZalKod] DEFAULT ('') NOT NULL,
    [ODW_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_ODW_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [ODW_Primary] PRIMARY KEY CLUSTERED ([ODW_OdwId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ODWNazwa]
    ON [CDN].[OpisyDniWolne]([ODW_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ODWSymbol]
    ON [CDN].[OpisyDniWolne]([ODW_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
create trigger CDN.OpisyDniWolne_Delete_Trigger
  on CDN.OpisyDniWolne
  for delete
as
  set nocount on
    if exists (select * from deleted where deleted.ODW_Standardowy <> 0)
    begin
      raiserror('Nie można usunąć standardowego opisu dnia wolnego. ', 16, 1)
      rollback tran
      set nocount off
      return
    end
    if exists (select * from deleted where exists (select 1 from cdn.kalenddni where deleted.odw_odwid = kad_odwid))
    begin
      raiserror('Nie można usunąć opisu dnia wolnego, który został użyty w kalendarzu. ', 16, 1)
      rollback tran
      set nocount off
      return
    end
 if exists (select * from deleted where exists (select 1 from cdn.pracplandni where deleted.odw_odwid = ppl_odwid))
    begin
      raiserror('Nie można usunąć opisu dnia wolnego, który został użyty w planie pracy. ', 16, 1)
      rollback tran
      set nocount off
      return
    end
 if exists (select * from deleted where exists (select 1 from cdn.seriekalpoz where deleted.odw_odwid = slp_odwid))
    begin
      raiserror('Nie można usunąć opisu dnia wolnego, który został użyty w serii kalendarzy. ', 16, 1)
      rollback tran
      set nocount off
      return
    end
  set nocount off

GO
create trigger CDN.OpisyDniWolne_Update_Trigger
  on CDN.OpisyDniWolne
  for update
as
  set nocount on
    if exists (select * from deleted where deleted.ODW_Standardowy <> 0)
    begin
      raiserror('Nie można modyfikować standardowego opisu dnia wolnego. ', 16, 1)
      rollback tran
      set nocount off
      return
    end
  set nocount off
