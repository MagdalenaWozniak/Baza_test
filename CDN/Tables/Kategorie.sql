CREATE TABLE [CDN].[Kategorie] (
    [Kat_KatID]                    INT             IDENTITY (1, 1) NOT NULL,
    [Kat_Typ]                      SMALLINT        NOT NULL,
    [Kat_Poziom]                   SMALLINT        NOT NULL,
    [Kat_ParentID]                 INT             NULL,
    [Kat_KodOgolny]                VARCHAR (20)    NOT NULL,
    [Kat_KodSzczegol]              VARCHAR (20)    NOT NULL,
    [Kat_Opis]                     VARCHAR (50)    NOT NULL,
    [Kat_KolumnaKPIR]              TINYINT         NOT NULL,
    [Kat_KolumnaRycz]              TINYINT         NOT NULL,
    [Kat_WzID]                     SMALLINT        NULL,
    [Kat_Stawka]                   DECIMAL (5, 2)  NOT NULL,
    [Kat_Flaga]                    SMALLINT        NOT NULL,
    [Kat_Zrodlowa]                 DECIMAL (5, 2)  NOT NULL,
    [Kat_Odliczenia]               SMALLINT        NOT NULL,
    [Kat_RodzajZakupu]             SMALLINT        NOT NULL,
    [Kat_Fiskalny]                 TINYINT         NOT NULL,
    [Kat_Detal]                    TINYINT         NOT NULL,
    [Kat_Kwota]                    DECIMAL (15, 2) NOT NULL,
    [Kat_Udzial]                   DECIMAL (5, 2)  NOT NULL,
    [Kat_Budzet]                   DECIMAL (15, 2) NOT NULL,
    [Kat_Nieaktywny]               TINYINT         NOT NULL,
    [Kat_KontoSegmentWN]           VARCHAR (50)    NOT NULL,
    [Kat_KontoSegmentMA]           VARCHAR (50)    NOT NULL,
    [Kat_TS_Uzyc]                  DATETIME        NULL,
    [Kat_ElixirO1]                 VARCHAR (35)    NOT NULL,
    [Kat_ElixirO2]                 VARCHAR (35)    NOT NULL,
    [Kat_ElixirO3]                 VARCHAR (35)    NOT NULL,
    [Kat_ElixirO4]                 VARCHAR (35)    NOT NULL,
    [Kat_PodzielOdliczenia]        TINYINT         CONSTRAINT [DF_Kat_PodzielOdliczenia] DEFAULT ((0)) NOT NULL,
    [Kat_PodzielOdliczeniaProcent] DECIMAL (5, 2)  CONSTRAINT [DF_Kat_PodzielOdliczeniaProcent] DEFAULT ((50.00)) NOT NULL,
    [Kat_TS_Export]                DATETIME        NULL,
    [Kat_ImportAppId]              VARCHAR (5)     NULL,
    [Kat_ImportRowId]              VARCHAR (36)    NULL,
    [Kat_OpeZalID]                 INT             NULL,
    [Kat_StaZalId]                 INT             NULL,
    [Kat_TS_Zal]                   DATETIME        NOT NULL,
    [Kat_OpeModID]                 INT             NULL,
    [Kat_StaModId]                 INT             NULL,
    [Kat_TS_Mod]                   DATETIME        NOT NULL,
    [Kat_OpeModKod]                VARCHAR (20)    CONSTRAINT [DF_Kat_OpeModKod] DEFAULT ('') NOT NULL,
    [Kat_OpeModNazwisko]           NVARCHAR (50)   CONSTRAINT [DF_Kat_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Kat_OpeZalKod]                VARCHAR (20)    CONSTRAINT [DF_Kat_OpeZalKod] DEFAULT ('') NOT NULL,
    [Kat_OpeZalNazwisko]           NVARCHAR (50)   CONSTRAINT [DF_Kat_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [Kat_KsiegujWKoszty]           TINYINT         CONSTRAINT [DF_Kat_KsiegujWKoszty] DEFAULT ((0)) NOT NULL,
    [Kat_KsiegujWKosztyProcent]    DECIMAL (5, 2)  CONSTRAINT [DF_Kat_KsiegujWKosztyProcent] DEFAULT ((75.00)) NOT NULL,
    CONSTRAINT [Kat_Primary] PRIMARY KEY CLUSTERED ([Kat_KatID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KatKod]
    ON [CDN].[Kategorie]([Kat_Typ] ASC, [Kat_KodOgolny] ASC, [Kat_Poziom] ASC, [Kat_KodSzczegol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KatOgolny]
    ON [CDN].[Kategorie]([Kat_Typ] ASC, [Kat_Poziom] ASC, [Kat_KodOgolny] ASC, [Kat_KodSzczegol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KatSzczegol]
    ON [CDN].[Kategorie]([Kat_KodSzczegol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KatGUID]
    ON [CDN].[Kategorie]([Kat_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Kategorie_Delete_Trigger
  ON CDN.Kategorie
  FOR Delete
AS
 SET NOCOUNT ON
 if exists(select * from CDN.Wymiary join deleted D on (Wyy_KatId = D.Kat_KatID))
 begin
  declare @name nvarchar(255);
  declare @wymiar nvarchar(255);
  select top 1 @name = Kat_KodSzczegol,  @wymiar=Wyy_Kod from CDN.Wymiary join deleted D on (Wyy_KatId = D.Kat_KatID)
  RAISERROR('##OPT32333##%%kateg%%=%s%%wymAnalit%%=%s##', 16, 1, @name, @wymiar) -- RAISERROR('Nie można usunąć kategorii [%s]. Kategoria została użyta w definicji wymiaru analitycznego [%s].', 16, 1, @name, @wymiar)
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 end
 -- skasowanie JPK
Delete From CDN.DokKodyJPKV7 Where
 DKV7_ParentTyp = 3
 And DKV7_ParentID In (Select Kat_KatId From deleted) OR DKV7_ParentID In (Select A.Kat_KatId From cdn.Kategorie A WHERE A.Kat_Poziom = 2 And Kat_KodOgolny In (Select Kat_KodOgolny From deleted Where Kat_Poziom = 1))
 Delete From CDN.Kategorie Where Kat_Poziom = 2 And Kat_KodOgolny In (Select Kat_KodOgolny From deleted Where Kat_Poziom = 1)
 SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Kategorie_InsertUpdate_Trigger
  ON CDN.Kategorie
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
--Ustalenie wartości KodSzczegol dla kategorii ogólnej
          IF EXISTS (SELECT * FROM inserted WHERE inserted.Kat_Poziom = 1 AND inserted.Kat_KodSzczegol <> inserted.Kat_KodOgolny)
            BEGIN
              UPDATE CDN.Kategorie
              SET    CDN.Kategorie.Kat_KodSzczegol = CDN.Kategorie.Kat_KodOgolny
              WHERE  CDN.Kategorie.Kat_KatId
                 IN  (SELECT inserted.Kat_KatId FROM inserted WHERE inserted.Kat_Poziom = 1 AND inserted.Kat_KodSzczegol <> inserted.Kat_KodOgolny);
-- Rollback transakcji w przypadku błędu
              IF @@ERROR <> 0
                BEGIN
                  RAISERROR('##OPT32020##%%1%%=Kategorie##', 16, 1) -- RAISERROR('Błąd aktualizacji zapisu (Kategorie)', 16, 1)
                  ROLLBACK TRAN
                  SET NOCOUNT OFF
                  RETURN
                END
            END
--Ustalenie wartości ParentID dla kategorii szczegółowej
          IF EXISTS (SELECT * FROM inserted WHERE inserted.Kat_Poziom = 2)
            BEGIN
     UPDATE s SET s.Kat_ParentID = o.Kat_KatID FROM cdn.Kategorie s join inserted i on i.Kat_KatID = s.Kat_KatID join cdn.Kategorie o on o.Kat_Poziom = 1 and o.Kat_KodSzczegol = i.Kat_KodOgolny and s.Kat_Poziom = 2
-- Rollback transakcji w przypadku błędu
              IF @@ERROR <> 0
                BEGIN
                  RAISERROR('##OPT32020##%%1%%=Kategorie##', 16, 1) -- RAISERROR('Błąd aktualizacji zapisu (Kategorie)', 16, 1)
                  ROLLBACK TRAN
                  SET NOCOUNT OFF
                  RETURN
                END
            END
 If Update (Kat_NieAktywny)
   Update CDN.Kategorie
   Set Kat_NieAktywny = i.Kat_NieAktywny
   From CDN.Kategorie A
   Join inserted i On A.Kat_KodOgolny = i.Kat_KodOgolny And A.Kat_Poziom = 2 And i.Kat_Poziom = 1
   Join deleted  d On i.Kat_KatId = d.Kat_KatId
   Where d.Kat_NieAktywny <> i.Kat_NieAktywny And A.Kat_NieAktywny <> i.Kat_NieAktywny
-- Kasowanie wskanika wyeksportowania
If Not Update (Kat_TS_Export) And Exists (Select * From inserted Where Kat_TS_Export Is Not Null)
  Update CDN.Kategorie Set Kat_TS_Export = Null Where Kat_KatId In (Select Kat_KatId From inserted Where Kat_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where Kat_ImportRowId Is Null Or Kat_ImportRowId = '')
  Update CDN.Kategorie Set Kat_ImportRowId = NewId()
  Where Kat_KatId In (Select Kat_KatId From inserted Where Kat_ImportRowId Is Null Or Kat_ImportRowId = '')
  SET NOCOUNT OFF
