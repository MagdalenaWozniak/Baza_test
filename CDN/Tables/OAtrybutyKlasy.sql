CREATE TABLE [CDN].[OAtrybutyKlasy] (
    [ATK_AtkId]                INT             IDENTITY (1, 1) NOT NULL,
    [ATK_Nazwa]                VARCHAR (41)    NOT NULL,
    [ATK_Typ]                  TINYINT         NOT NULL,
    [ATK_Opis]                 NVARCHAR (256)  NOT NULL,
    [ATK_Format]               NVARCHAR (21)   NOT NULL,
    [ATK_ZListy]               TINYINT         NOT NULL,
    [ATK_Zamknieta]            TINYINT         NOT NULL,
    [ATK_Wymagany]             TINYINT         NOT NULL,
    [ATK_Controlling]          TINYINT         NOT NULL,
    [ATK_Automat]              TINYINT         NOT NULL,
    [ATK_Nieaktywny]           TINYINT         NOT NULL,
    [ATK_Historia]             TINYINT         NOT NULL,
    [ATK_SQL]                  NVARCHAR (2049) NOT NULL,
    [ATK_Domyslna]             NVARCHAR (101)  NOT NULL,
    [ATK_DomyslnaApi]          NVARCHAR (101)  NOT NULL,
    [ATK_DomyslnaSQL]          NVARCHAR (2049) NOT NULL,
    [ATK_DomyslnaAPISQL]       NVARCHAR (2049) NOT NULL,
    [ATK_TypDom]               TINYINT         NOT NULL,
    [ATK_TypDomApi]            TINYINT         NOT NULL,
    [ATK_CharSet]              INT             NOT NULL,
    [ATK_Maska]                NVARCHAR (20)   NOT NULL,
    [ATK_SynchronizowanyXL]    TINYINT         CONSTRAINT [DF_ATK_SynchronizowanyXL] DEFAULT ((1)) NOT NULL,
    [ATK_SynchronizowanyAltum] TINYINT         CONSTRAINT [DF_ATK_SynchronizowanyAltum] DEFAULT ((0)) NOT NULL,
    [ATK_ImportRowId]          NVARCHAR (36)   CONSTRAINT [DF_ATK_ImportRowId] DEFAULT (newid()) NULL,
    CONSTRAINT [ATK_Primary] PRIMARY KEY CLUSTERED ([ATK_AtkId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AtkNazwa]
    ON [CDN].[OAtrybutyKlasy]([ATK_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.OAtrybutyKlasy_InsertUpdate_Trigger
  On CDN.OAtrybutyKlasy
  For Insert, Update
As
Set NoCount On
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where ATK_ImportRowId Is Null Or ATK_ImportRowId = '')
  Update CDN.OAtrybutyKlasy Set ATK_ImportRowId = NewId()
  Where ATK_AtkId In (Select ATK_AtkId From inserted Where ATK_ImportRowId Is Null Or ATK_ImportRowId = '')
Set NoCount Off

GO
CREATE TRIGGER CDN.OAtrybutyKlasy_Update_Trigger
  ON CDN.OAtrybutyKlasy
  FOR UPDATE
AS
  SET NOCOUNT ON
    declare @id int
    declare @nazwa NVarchar(40)
    SELECT @id = atk_atkid, @nazwa=atk_nazwa from inserted
    UPDATE CDN.OAtrybuty SET Oat_NazwaKlasy = @nazwa where Oat_AtkId = @id
    UPDATE CDN.OAtrybutyGrupyLinki SET Agl_NazwaKlasy = @nazwa where Agl_AtkId = @id
  SET NOCOUNT OFF
