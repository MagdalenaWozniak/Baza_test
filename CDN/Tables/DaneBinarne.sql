CREATE TABLE [CDN].[DaneBinarne] (
    [DAB_DABID]               INT              IDENTITY (1, 1) NOT NULL,
    [DAB_MagazynDanych]       TINYINT          CONSTRAINT [DF_DAB_MagazynDanych] DEFAULT ((1)) NOT NULL,
    [DAB_MagazynDanychId]     VARCHAR (20)     NULL,
    [DAB_Typ]                 INT              NULL,
    [DAB_Flaga]               INT              NULL,
    [DAB_TwAID]               INT              NOT NULL,
    [DAB_Wartosc]             IMAGE            NULL,
    [DAB_Rozmiar]             INT              NULL,
    [DAB_RozmiarWartosci]     AS               (datalength([DAB_WARTOSC])),
    [DAB_NazwaPliku]          NVARCHAR (254)   NOT NULL,
    [DAB_Nazwa]               NVARCHAR (128)   NULL,
    [DAB_Rozszerzenie]        NVARCHAR (4)     NULL,
    [DAB_Sciezka]             NVARCHAR (255)   CONSTRAINT [DF_DAB_Sciezka] DEFAULT ('') NOT NULL,
    [DAB_Wersja]              NVARCHAR (20)    NULL,
    [DAB_OpeZalID]            INT              NULL,
    [DAB_StaZalId]            INT              NULL,
    [DAB_TS_Zal]              DATETIME         NOT NULL,
    [DAB_OpeModID]            INT              NULL,
    [DAB_StaModId]            INT              NULL,
    [DAB_TS_Mod]              DATETIME         NOT NULL,
    [DAB_GUID]                UNIQUEIDENTIFIER NULL,
    [DAB_IBard24Id]           BIGINT           NULL,
    [DAB_OpeModKod]           VARCHAR (20)     CONSTRAINT [DF_DAB_OpeModKod] DEFAULT ('') NOT NULL,
    [DAB_OpeModNazwisko]      NVARCHAR (50)    CONSTRAINT [DF_DAB_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DAB_OpeZalKod]           VARCHAR (20)     CONSTRAINT [DF_DAB_OpeZalKod] DEFAULT ('') NOT NULL,
    [DAB_OpeZalNazwisko]      NVARCHAR (50)    CONSTRAINT [DF_DAB_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [DAB_IBard24LinkPrywatny] NVARCHAR (512)   NULL,
    [DAB_eSklepZalVerID]      UNIQUEIDENTIFIER NULL,
    [DAB_eSklepZalID]         UNIQUEIDENTIFIER NULL,
    [DAB_eSklepJezykID]       INT              NULL,
    [DAB_eSklepID]            INT              NULL,
    CONSTRAINT [DAB_Primary] PRIMARY KEY CLUSTERED ([DAB_DABID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DABKeyNazwa]
    ON [CDN].[DaneBinarne]([DAB_Nazwa] ASC, [DAB_DABID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [AtBTwrAtrybut]
    ON [CDN].[DaneBinarne]([DAB_TwAID] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger [CDN].[DaneBinarne_Delete_Trigger]
  On CDN.DaneBinarne
    For Delete
As
Set NoCount On
-- Sprawdzenie, czy towar nie jest wzięty na urządzenie
  IF EXISTS (select * from cdn.TwrAtrybuty JOIN deleted ON TwA_DABID =deleted.DAB_DABId)
  OR EXISTS (select * from cdn.DaneBinarneLinki JOIN deleted ON DBL_DABID=deleted.DAB_DABId )
    BEGIN
  --RAISERROR('Nie można usunąć danej binarnej wykorzystanej na towarze lub urządzeniu!', 16, 1)
  EXEC CDN.RaiseOptimaException 34182
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
    END
 IF EXISTS (select * from cdn.TwrGrupyAtrybuty JOIN deleted ON TwGA_DABID=deleted.DAB_DABId)
    BEGIN
  --RAISERROR('Nie można usunąć danej binarnej wykorzystanej na grupie towarowej!', 16, 1)
  EXEC CDN.RaiseOptimaException 34183
  ROLLBACK TRAN
  SET NOCOUNT OFF
      RETURN
    END
 IF EXISTS (select * from cdn.Producenci JOIN deleted ON Prd_Logo =deleted.DAB_DABId)
    BEGIN
  --RAISERROR('Nie można usunąć danej binarnej wykorzystanej na producencie!', 16, 1)
  EXEC CDN.RaiseOptimaException 34184
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
    END
 IF EXISTS (select * from cdn.Marki JOIN deleted ON Mrk_Logo =deleted.DAB_DABId)
    BEGIN
  --RAISERROR('Nie można usunąć danej binarnej wykorzystanej na marce!', 16, 1)
  EXEC CDN.RaiseOptimaException 34185
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
   IF EXISTS (select * from cdn.eSklepStanowiska JOIN deleted ON ESS_DaneFirmyLogo =deleted.DAB_DABId)
    BEGIN
      --RAISERROR('Nie można usunąć danej binarnej wykorzystanej na wizytówce wszystko.pl!', 16, 1)
   EXEC CDN.RaiseOptimaException 34186
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
Set NoCount Off
