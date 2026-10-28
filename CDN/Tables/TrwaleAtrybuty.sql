CREATE TABLE [CDN].[TrwaleAtrybuty] (
    [SrA_SrAId]      INT            IDENTITY (1, 1) NOT NULL,
    [SrA_DeAId]      INT            NULL,
    [SrA_SrTId]      INT            NULL,
    [SrA_WypID]      INT            NULL,
    [SrA_Typ]        INT            NULL,
    [SrA_WartoscTxt] NVARCHAR (255) NOT NULL,
    CONSTRAINT [SrA_Primary] PRIMARY KEY CLUSTERED ([SrA_SrAId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrADeAId] FOREIGN KEY ([SrA_DeAId]) REFERENCES [CDN].[DefAtrybuty] ([DeA_DeAId]) ON DELETE CASCADE,
    CONSTRAINT [FK_SrTId] FOREIGN KEY ([SrA_SrTId]) REFERENCES [CDN].[Trwale] ([SrT_SrTID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UniqueDeAID]
    ON [CDN].[TrwaleAtrybuty]([SrA_SrTId] ASC, [SrA_DeAId] ASC, [SrA_WypID] ASC, [SrA_Typ] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeAId]
    ON [CDN].[TrwaleAtrybuty]([SrA_DeAId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrTId]
    ON [CDN].[TrwaleAtrybuty]([SrA_SrTId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WypID]
    ON [CDN].[TrwaleAtrybuty]([SrA_WypID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TrwaleAtrybuty_InsertUpdate_Trigger
  ON CDN.TrwaleAtrybuty
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
 Declare @SrA_SrAId int,
  @SrA_DeAId int,
  @SrA_SrTId int,
  @SrA_WypID int,
  @SrA_Typ   int
 Declare Dodane Cursor Local Fast_Forward For
 Select SrA_SrAId, SrA_DeAId, SrA_SrTId, SrA_WypID, SrA_Typ From inserted
 Open Dodane
 While 1=1
   Begin
  Fetch Next From Dodane InTo @SrA_SrAId, @SrA_DeAId, @SrA_SrTId, @SrA_WypID, @SrA_Typ
  If @@Fetch_Status <> 0 Break
  if Update(SrA_DeAId)
  or Update(SrA_SrTId)
  or Update(SrA_WypID)
    or Update(SrA_Typ)
  Begin
   if @SrA_SrTId > 0
   Begin
    select @SrA_Typ=SrT_Typ from CDN.Trwale where SrT_SrTId=@SrA_SrTId
    Update CDN.TrwaleAtrybuty Set SrA_Typ = @SrA_Typ where SrA_SrAId=@SrA_SrAId
   End
    Else if @SrA_WypID > 0
   Begin
    Update CDN.TrwaleAtrybuty Set SrA_Typ = 13 where SrA_SrAId=@SrA_SrAId
   End
  End
 End
  SET NOCOUNT OFF
