CREATE TABLE [CDN].[KragKosztElem] (
    [KKE_KKEId]  INT           IDENTITY (1, 1) NOT NULL,
    [KKE_KKNId]  INT           NOT NULL,
    [KKE_Konto]  NVARCHAR (50) NOT NULL,
    [KKE_Strona] SMALLINT      NOT NULL,
    CONSTRAINT [KKE_Primary] PRIMARY KEY CLUSTERED ([KKE_KKEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KKENaglowek] FOREIGN KEY ([KKE_KKNId]) REFERENCES [CDN].[KragKosztNag] ([KKN_KKNId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KKENaglowek]
    ON [CDN].[KragKosztElem]([KKE_KKNId] ASC, [KKE_Strona] ASC, [KKE_Konto] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.KragKosztElem_InsertUpdate_Trigger
On CDN.KragKosztElem
For Insert, Update
As
Begin
Set NoCount On
Declare @KKEId Int
Declare dodane Cursor Local Fast_Forward For
 Select KKE_KKEId From inserted Join CDN.KragKosztNag On KKE_KKNId = KKN_KKNId Where KKN_NieAktywny = 0
Open dodane
While 1=1
 Begin
  Fetch Next From dodane InTo @KKEId
  If @@Fetch_Status <> 0 Break
  execute CDN.SprawdzDefinicjeKKK @KKEId
 End
Close dodane
Deallocate dodane
Set NoCount Off
End
