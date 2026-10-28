CREATE TABLE [CDN].[TwrGrupyJezykObcy] (
    [TwGJ_TwGJID]            INT            IDENTITY (1, 1) NOT NULL,
    [TwGJ_TwGID]             INT            NOT NULL,
    [TwGJ_JezykID]           SMALLINT       CONSTRAINT [DF_TwGJ_JezykID] DEFAULT ((1)) NOT NULL,
    [TwGJ_Nazwa]             NVARCHAR (255) NOT NULL,
    [TwGJ_OpisHTML]          NVARCHAR (MAX) NOT NULL,
    [TwGJ_OpisKrotki]        NVARCHAR (500) NOT NULL,
    [TwGJ_MetaTytul]         NVARCHAR (100) NOT NULL,
    [TwGJ_MetaSlowaKluczowe] NVARCHAR (500) NOT NULL,
    [TwGJ_MetaOpis]          NVARCHAR (320) NOT NULL,
    [TwGJ_Link]              NVARCHAR (50)  CONSTRAINT [DF_TwGJ_Link] DEFAULT ('') NOT NULL,
    [TwGJ_Szukaj]            NVARCHAR (512) CONSTRAINT [DF_TwGJ_Szukaj] DEFAULT ('') NOT NULL,
    [TwGJ_NazwaNag]          NVARCHAR (250) CONSTRAINT [DF_TwGJ_NazwaNag] DEFAULT ('') NOT NULL,
    CONSTRAINT [TwGJ_Primary] PRIMARY KEY CLUSTERED ([TwGJ_TwGID] ASC, [TwGJ_JezykID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwGJOdoTwrGrup] FOREIGN KEY ([TwGJ_TwGID]) REFERENCES [CDN].[TwrGrupy] ([TwG_TwGID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwGJOID]
    ON [CDN].[TwrGrupyJezykObcy]([TwGJ_TwGJID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TwrGrupyJezykObcy_InsertUpdate_Trigger
ON CDN.TwrGrupyJezykObcy
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  UPDATE CDN.TwrGrupy SET TwG_CzasModyfikacji = DATEDIFF(s,CONVERT(datetime,'1990-01-01',120),GETDATE()), TwG_Kod = TwG_Kod
  where TwG_TwGId in ( select distinct TwGJ_TwGId From inserted)
  SET NOCOUNT OFF
