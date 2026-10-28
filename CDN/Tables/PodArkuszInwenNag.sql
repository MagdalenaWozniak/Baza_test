CREATE TABLE [CDN].[PodArkuszInwenNag] (
    [PAI_PAIId]          INT            IDENTITY (1, 1) NOT NULL,
    [PAI_TrNId]          INT            NOT NULL,
    [PAI_NumerNr]        INT            NOT NULL,
    [PAI_Status]         SMALLINT       NOT NULL,
    [PAI_OpeZalId]       INT            NULL,
    [PAI_StaZalId]       INT            NULL,
    [PAI_TS_Zal]         DATETIME       NOT NULL,
    [PAI_OpeModId]       INT            NULL,
    [PAI_StaModId]       INT            NULL,
    [PAI_TS_Mod]         DATETIME       NOT NULL,
    [PAI_Opis]           NVARCHAR (MAX) CONSTRAINT [DF_PAI_Opis] DEFAULT ('') NOT NULL,
    [PAI_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_PAI_OpeModKod] DEFAULT ('') NOT NULL,
    [PAI_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PAI_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [PAI_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_PAI_OpeZalKod] DEFAULT ('') NOT NULL,
    [PAI_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_PAI_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [PAI_AINumerPelny]   NVARCHAR (40)  CONSTRAINT [DF_PAI_AINumerPelny] DEFAULT ('') NOT NULL,
    CONSTRAINT [PAI_Primary] PRIMARY KEY CLUSTERED ([PAI_PAIId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PAITraNag] FOREIGN KEY ([PAI_TrNId]) REFERENCES [CDN].[TraNag] ([TrN_TrNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PAITraNag]
    ON [CDN].[PodArkuszInwenNag]([PAI_TrNId] ASC, [PAI_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.PodArkuszInwenNag_InsertUpdate_Trigger
  ON CDN.PodArkuszInwenNag
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
Declare
 @PAIId         Int,
 @NumerNr       Int,
 @Status  Int,
 @AINumerPelny nvarchar(40)
 --logowanie zatwierdzenia i zmiany
  If Update (PAI_Status)
  begin
  Declare dodane Cursor Local Fast_Forward For
 Select
  PAI_PAIId,
  PAI_NumerNr,
  PAI_Status,
  PAI_AINumerPelny
  From inserted
 Open Dodane
 While 1=1
   Begin
  Fetch Next From Dodane InTo
     @PAIId,
     @NumerNr,
     @Status,
     @AINumerPelny
  If @@Fetch_Status <> 0 Break
   set @AINumerPelny = 'Dotyczy '+ @AINumerPelny
   if (@Status = 1) and exists(select * from deleted where PAI_PAIId = @PAIId and PAI_Status = 0)
   exec [CDN].[RejestrOperacjiDodaj] 390,0, @PAIId, @NumerNr, 103, @AINumerPelny
   if (@Status = 0) and exists(select * from deleted where PAI_PAIId = @PAIId and PAI_Status = 1)
   exec [CDN].[RejestrOperacjiDodaj] 390,0, @PAIId, @NumerNr, 2, @AINumerPelny
  end
 Close Dodane
 Deallocate Dodane
end
if (UPDATE (PAI_Opis) or UPDATE (PAI_OpeModId) or UPDATE (PAI_StaModId) or UPDATE (PAI_TS_Mod))
and not UPDATE(PAI_NumerNr) and not UPDATE(PAI_Status) Return
else
 If Exists (
    Select trn_trnid From inserted a left outer join cdn.tranag on a.PAI_TrnId = TrN_TrNId
    where trn_rodzaj = 311001)
      Begin
      RaisError ('##OPT34523##', 16, 1)
      RollBack Tran
      Set NoCount Off
      Return
    End
SET NOCOUNT OFF
