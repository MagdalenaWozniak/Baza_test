CREATE TABLE [CDN].[DodatkiHist] (
    [DOH_DohId]           INT             IDENTITY (1, 1) NOT NULL,
    [DOH_DodId]           INT             NOT NULL,
    [DOH_TwpId]           INT             NOT NULL,
    [DOH_ListaPlacSymbol] INT             NULL,
    [DOH_Nazwa]           NVARCHAR (40)   NULL,
    [DOH_OkresOd]         DATETIME        NOT NULL,
    [DOH_OkresDo]         DATETIME        NOT NULL,
    [DOH_WaznyOd]         DATETIME        NOT NULL,
    [DOH_WaznyDo]         DATETIME        NOT NULL,
    [DOH_Wartosc1]        DECIMAL (15, 2) NOT NULL,
    [DOH_Wartosc2]        DECIMAL (15, 2) NOT NULL,
    [DOH_PozyczkaNr]      NVARCHAR (40)   NOT NULL,
    [DOH_Opis]            NVARCHAR (512)  NOT NULL,
    [DOH_OpeZalId]        INT             NULL,
    [DOH_StaZalId]        INT             NULL,
    [DOH_TS_Zal]          DATETIME        NOT NULL,
    [DOH_OpeModId]        INT             NULL,
    [DOH_StaModId]        INT             NULL,
    [DOH_TS_Mod]          DATETIME        NOT NULL,
    [DOH_OpeModKod]       VARCHAR (20)    CONSTRAINT [DF_DOH_OpeModKod] DEFAULT ('') NOT NULL,
    [DOH_OpeModNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_DOH_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DOH_OpeZalKod]       VARCHAR (20)    CONSTRAINT [DF_DOH_OpeZalKod] DEFAULT ('') NOT NULL,
    [DOH_OpeZalNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_DOH_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [DOH_Primary] PRIMARY KEY CLUSTERED ([DOH_DohId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DOHDodLink] FOREIGN KEY ([DOH_DodId]) REFERENCES [CDN].[Dodatki] ([DOD_DodId]) ON DELETE CASCADE,
    CONSTRAINT [FK_DOHTwpLink] FOREIGN KEY ([DOH_TwpId]) REFERENCES [CDN].[TypWyplata] ([TWP_TwpId])
);


GO
CREATE NONCLUSTERED INDEX [DOHDodLink]
    ON [CDN].[DodatkiHist]([DOH_DodId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DOHTwpLink]
    ON [CDN].[DodatkiHist]([DOH_TwpId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DOHLPLink]
    ON [CDN].[DodatkiHist]([DOH_ListaPlacSymbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DodatkiHis_Delete_Trigger
  ON CDN.DodatkiHist
  FOR DELETE
AS
SET NOCOUNT ON
 declare @id int
 select @id = doh_dohid from deleted
 delete from cdn.opiskadry where opk_rodzajzrodla = 17 and opk_zrodloid = @id
SET NOCOUNT OFF
