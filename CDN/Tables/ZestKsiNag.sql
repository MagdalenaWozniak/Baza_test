CREATE TABLE [CDN].[ZestKsiNag] (
    [ZKN_ZKNId]          INT            IDENTITY (1, 1) NOT NULL,
    [ZKN_Symbol]         VARCHAR (20)   NOT NULL,
    [ZKN_TypZest]        SMALLINT       NOT NULL,
    [ZKN_Nazwa]          NVARCHAR (255) NOT NULL,
    [ZKN_Opis]           NVARCHAR (254) NOT NULL,
    [ZKN_Bufor]          TINYINT        NOT NULL,
    [ZKN_Numeracja]      NVARCHAR (20)  NOT NULL,
    [ZKN_TS_Oblicz]      DATETIME       NULL,
    [ZKN_OpeZalID]       INT            NULL,
    [ZKN_StaZalId]       INT            NULL,
    [ZKN_TS_Zal]         DATETIME       NOT NULL,
    [ZKN_OpeModID]       INT            NULL,
    [ZKN_StaModId]       INT            NULL,
    [ZKN_TS_Mod]         DATETIME       NOT NULL,
    [ZKN_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_ZKN_OpeModKod] DEFAULT ('') NOT NULL,
    [ZKN_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_ZKN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [ZKN_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_ZKN_OpeZalKod] DEFAULT ('') NOT NULL,
    [ZKN_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_ZKN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [ZKN_Nieaktywne]     SMALLINT       CONSTRAINT [DF_ZKN_Nieaktywne] DEFAULT ((0)) NOT NULL,
    [ZKN_TypZestawienia] INT            NULL,
    [ZKN_TypJednostki]   INT            NULL,
    CONSTRAINT [ZKN_Primary] PRIMARY KEY CLUSTERED ([ZKN_ZKNId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ZKNSymbol]
    ON [CDN].[ZestKsiNag]([ZKN_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ZKNTyp]
    ON [CDN].[ZestKsiNag]([ZKN_TypZest] ASC, [ZKN_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.ZestKsiNag_Update_Trigger
  ON CDN.ZestKsiNag
  FOR UPDATE
AS
 SET NOCOUNT ON
 if exists (select * from deleted join inserted on (deleted.ZKN_ZKNId = inserted.ZKN_ZKNId) where deleted.ZKN_TypJednostki <> inserted.ZKN_TypJednostki or deleted.ZKN_TypZestawienia <> inserted.ZKN_TypZestawienia)
  update CDN.ZestKsiPoz set ZKP_SFId = null
  from CDN.ZestKsiPoz
  join inserted on (ZKP_ZKNId = inserted.ZKN_ZKNId)
  join deleted on (deleted.ZKN_ZKNId = inserted.ZKN_ZKNId)
  where deleted.ZKN_TypJednostki <> inserted.ZKN_TypJednostki or deleted.ZKN_TypZestawienia <> inserted.ZKN_TypZestawienia
 SET NOCOUNT OFF

GO
Create Trigger CDN.ZestKsiNag_Delete_Trigger
  On CDN.ZestKsiNag
  For Delete
As
Set Nocount On
If Exists (Select * From deleted Where ZKN_TypZest <> 0)
  Begin
 exec CDN.RiseOptimaException 32656
    Rollback Tran
    Set Nocount Off
    Return
  End
Set Nocount Off
