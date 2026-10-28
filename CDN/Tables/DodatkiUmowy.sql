CREATE TABLE [CDN].[DodatkiUmowy] (
    [DOU_DouId] INT IDENTITY (1, 1) NOT NULL,
    [DOU_DodId] INT NOT NULL,
    [DOU_UmwId] INT NOT NULL,
    CONSTRAINT [DOU_Primary] PRIMARY KEY CLUSTERED ([DOU_DouId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DOUDodLink] FOREIGN KEY ([DOU_DodId]) REFERENCES [CDN].[Dodatki] ([DOD_DodId]) ON DELETE CASCADE,
    CONSTRAINT [FK_DOUUmwLink] FOREIGN KEY ([DOU_UmwId]) REFERENCES [CDN].[Umowy] ([UMW_UmwId])
);


GO
CREATE NONCLUSTERED INDEX [DOUDodLink]
    ON [CDN].[DodatkiUmowy]([DOU_DodId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DOUUmwLink]
    ON [CDN].[DodatkiUmowy]([DOU_UmwId] ASC) WITH (FILLFACTOR = 100);


GO
create trigger cdn.DodatkiUmowy_InsertUpdate_Trigger
  on cdn.DodatkiUmowy
  for insert
as
set nocount on
declare @id int
select @id = DOU_DodId from inserted
if exists (select DOU_DouId from cdn.DodatkiUmowy where DOU_DodId = @id)
 update cdn.Dodatki set DOD_Umowa = 1 where DOD_DodId = @id
else
 update cdn.Dodatki set DOD_Umowa = 0 where DOD_DodId = @id
set nocount off

GO
create trigger cdn.DodatkiUmowy_Delete_Trigger
  on cdn.DodatkiUmowy
  for delete
as
set nocount on
set arithabort on
declare @id int
select @id = DOU_DodId from deleted
if exists (select DOU_DouId from cdn.DodatkiUmowy where DOU_DodId = @id)
 update cdn.Dodatki set DOD_Umowa = 1 where DOD_DodId = @id
else
 update cdn.Dodatki set DOD_Umowa = 0 where DOD_DodId = @id
set nocount off
