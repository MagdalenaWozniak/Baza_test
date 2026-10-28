CREATE TABLE [CDN].[DaneBinarneLinki] (
    [DBL_DBLID]          INT              IDENTITY (1, 1) NOT NULL,
    [DBL_TwrID]          INT              NOT NULL,
    [DBL_Lp]             INT              NOT NULL,
    [DBL_Typ]            INT              NULL,
    [DBL_NazwaPliku]     NVARCHAR (255)   NULL,
    [DBL_Sciezka]        NVARCHAR (255)   NULL,
    [DBL_WBazie]         SMALLINT         NULL,
    [DBL_DabId]          INT              NULL,
    [DBL_FileMode]       SMALLINT         NOT NULL,
    [DBL_ESklep]         SMALLINT         NULL,
    [DBL_JezykId]        SMALLINT         CONSTRAINT [DF_DBL_JezykId] DEFAULT ((1)) NOT NULL,
    [DBL_TagLink]        NVARCHAR (100)   CONSTRAINT [DF_DBL_TagLink] DEFAULT ('') NOT NULL,
    [DBL_TagAlt]         NVARCHAR (500)   CONSTRAINT [DF_DBL_TagAlt] DEFAULT ('') NOT NULL,
    [DBL_TagRel]         TINYINT          CONSTRAINT [DF_DBL_TagRel] DEFAULT ((0)) NOT NULL,
    [DBL_TagTitle]       NVARCHAR (500)   CONSTRAINT [DF_DBL_TagTitle] DEFAULT ('') NOT NULL,
    [DBL_DokumentTyp]    INT              NULL,
    [DBL_DokumentId]     INT              NULL,
    [DBL_eSklepZalVerID] UNIQUEIDENTIFIER NULL,
    [DBL_eSklepJezykID]  INT              NULL,
    CONSTRAINT [DBL_Primary] PRIMARY KEY CLUSTERED ([DBL_DBLID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DBL_TwrId_Index]
    ON [CDN].[DaneBinarneLinki]([DBL_TwrID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DBL_Dokument_Index]
    ON [CDN].[DaneBinarneLinki]([DBL_DokumentTyp] ASC, [DBL_DokumentId] ASC) WITH (FILLFACTOR = 100);


GO
Create TRIGGER [CDN].[DaneBinarneLinki_Delete_Trigger]
ON [CDN].[DaneBinarneLinki]
FOR DELETE
AS
  SET NOCOUNT ON
   UPDATE cdn.towary SET Twr_TS_Mod = getdate()
            where twr_twrid in (select DBL_TwrId from deleted)
  SET NOCOUNT OFF

GO
Create TRIGGER [CDN].[DaneBinarneLinki_InsertUpdate_Trigger]
ON [CDN].[DaneBinarneLinki]
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  If Exists (select DBL_DABId from inserted where DBL_DABId is not null and inserted.DBL_WBazie = 1)
  Begin
    IF NOT EXISTS (select * from cdn.DaneBinarne JOIN inserted ON DAB_DABId =inserted.DBL_DABID  )
    BEGIN
  --RAISERROR('Dana binarna przypisana do załącznika nie istnieje!', 16, 1)
  EXEC CDN.RaiseOptimaException 34187
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
    END
 IF EXISTS (select DBL_DabId,DBL_TwrID from cdn.DaneBinarneLinki where DBL_ESklep = 1 and DBL_TwrID in (select DBL_TwrID from inserted) group by DBL_TwrID,DBL_DabId,DBL_JezykId
   having count(*)> 1)
    BEGIN
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 ) and exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1)
  begin
   --RAISERROR('Dodano dwie identyczne dane binarne wysyłane do e-Sklep/wszystko.pl!', 16, 1)
   EXEC CDN.RaiseOptimaException 34188
  end
  else
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 )
   --RAISERROR('Dodano dwie identyczne dane binarne wysyłane do wszystko.pl!', 16, 1)
   EXEC CDN.RaiseOptimaException 34189
  else
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1 )
  begin
   --RAISERROR('Dodano dwie identyczne dane binarne wysyłane do e-Sklep!', 16, 1)
   EXEC CDN.RaiseOptimaException 34190
  end
  else
  begin
   --RAISERROR('Dodano dwie identyczne dane binarne wysyłane do e-Sklep/wszystko.pl!', 16, 1)
   EXEC CDN.RaiseOptimaException 34188
  end
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
    END
 IF Update (DBL_ESklep) or Update (DBL_Typ)
      UPDATE dane SET dane.dab_ts_mod = getdate()
            FROM cdn.danebinarne dane
            JOIN inserted ON  DBL_DABId = DaB_DaBId
   if exists (select * from cdn.danebinarne JOIN inserted on DAB_DABID = DBL_DABID AND DBL_ESklep = 1 WHERE DATALENGTH(DAB_Wartosc)/1024 > 9999)
   BEGIN
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 ) and exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1)
   --RAISERROR('Dodano dwie identyczne dane binarne wysyłane do e-Sklep/wszystko.pl!', 16, 1)
   EXEC CDN.RaiseOptimaException 34188
  else
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 )
   --RAISERROR('Dodano dwie identyczne dane binarne wysyłane do wszystko.pl!', 16, 1)
   EXEC CDN.RaiseOptimaException 34189
  else
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1 )
   --RaisError ('Rozmiar danej binarnej, która jest wysyłana do e-Sklep, nie może być większa niż 10MB.', 16,1)
   EXEC CDN.RaiseOptimaException 34192
  else
   --RaisError ('Rozmiar danej binarnej, która jest wysyłana do e-Sklep/wszystko.pl, nie może być większa niż 10MB.', 16,1)
   EXEC CDN.RaiseOptimaException 34193
          RollBack Tran
          Return
   END
   if exists (select * from cdn.danebinarne JOIN inserted on DAB_DABID = DBL_DABID AND DBL_ESklep = 1 AnD DBL_Typ = 4 WHERE DATALENGTH(DAB_Wartosc)/1024 >500)
   BEGIN
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1 )
 --RaisError ('Rozmiar pliku graficznego, który jest wysyłany do e-Sklep, nie może być większy niż 512 KB.', 16,1)
 EXEC CDN.RaiseOptimaException 34194
  else
 --RaisError ('Rozmiar pliku graficznego, który jest wysyłany do e-Sklep/wszystko.pl, nie może być większy niż 512 KB.', 16,1)
 EXEC CDN.RaiseOptimaException 34195
          RollBack Tran
          Return
   END
   END
  SET NOCOUNT OFF
