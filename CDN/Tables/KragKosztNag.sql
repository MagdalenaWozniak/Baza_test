CREATE TABLE [CDN].[KragKosztNag] (
    [KKN_KKNId]          INT           IDENTITY (1, 1) NOT NULL,
    [KKN_OObId]          INT           NOT NULL,
    [KKN_Symbol]         VARCHAR (20)  NOT NULL,
    [KKN_AccId]          INT           NULL,
    [KKN_NieAktywny]     SMALLINT      NOT NULL,
    [KKN_OpeZalID]       INT           NULL,
    [KKN_StaZalId]       INT           NULL,
    [KKN_TS_Zal]         DATETIME      NOT NULL,
    [KKN_OpeModID]       INT           NULL,
    [KKN_StaModId]       INT           NULL,
    [KKN_TS_Mod]         DATETIME      NOT NULL,
    [KKN_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_KKN_OpeModKod] DEFAULT ('') NOT NULL,
    [KKN_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_KKN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [KKN_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_KKN_OpeZalKod] DEFAULT ('') NOT NULL,
    [KKN_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_KKN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [KKN_Primary] PRIMARY KEY CLUSTERED ([KKN_KKNId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KKNKonto] FOREIGN KEY ([KKN_AccId]) REFERENCES [CDN].[Konta] ([Acc_AccId]),
    CONSTRAINT [FK_KKNSymbol] FOREIGN KEY ([KKN_OObId]) REFERENCES [CDN].[OkresyObrach] ([OOb_OObID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KKNSymbol]
    ON [CDN].[KragKosztNag]([KKN_OObId] ASC, [KKN_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [KKNKonto]
    ON [CDN].[KragKosztNag]([KKN_AccId] ASC, [KKN_NieAktywny] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.KragKosztNag_InsertUpdate_Trigger
On CDN.KragKosztNag
For Insert, Update
As
Begin
Set NoCount On
If Update (KKN_NieAktywny) And Exists (Select * From inserted Where KKN_NieAktywny = 0)
 Begin
  Declare @KKEId Int
  Declare elementy Cursor Local Fast_Forward For
    Select KKE_KKEId From inserted Join CDN.KragKosztElem On KKE_KKNId = KKN_KKNId Where KKN_NieAktywny = 0
  Open elementy
  While 1=1
   Begin
    Fetch Next From elementy InTo @KKEId
    If @@Fetch_Status <> 0 Break
    execute CDN.SprawdzDefinicjeKKK @KKEId
   End
  Close elementy
  Deallocate elementy
 End
Set NoCount Off
End
