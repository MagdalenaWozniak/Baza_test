CREATE TABLE [CDN].[AkordyHist] (
    [AKH_AkhId]           INT             IDENTITY (1, 1) NOT NULL,
    [AKH_AkrId]           INT             NOT NULL,
    [AKH_AdfId]           INT             NOT NULL,
    [AKH_Nazwa]           NVARCHAR (40)   NULL,
    [AKH_OkresOd]         DATETIME        NOT NULL,
    [AKH_OkresDo]         DATETIME        NOT NULL,
    [AKH_Ilosc]           DECIMAL (15, 2) NULL,
    [AKH_Czas]            DATETIME        NULL,
    [AKH_Miesiac]         SMALLINT        NOT NULL,
    [AKH_Rok]             INT             NOT NULL,
    [AKH_Stawka]          DECIMAL (15, 4) NOT NULL,
    [AKH_Proporcjonalnie] TINYINT         NOT NULL,
    [AKH_Wspolczynnik]    DECIMAL (15, 4) NOT NULL,
    [AKH_OpeZalId]        INT             NULL,
    [AKH_StaZalId]        INT             NULL,
    [AKH_TS_Zal]          DATETIME        NOT NULL,
    [AKH_OpeModId]        INT             NULL,
    [AKH_StaModId]        INT             NULL,
    [AKH_TS_Mod]          DATETIME        NOT NULL,
    [AKH_OpeModKod]       VARCHAR (20)    CONSTRAINT [DF_AKH_OpeModKod] DEFAULT ('') NOT NULL,
    [AKH_OpeModNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_AKH_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AKH_OpeZalKod]       VARCHAR (20)    CONSTRAINT [DF_AKH_OpeZalKod] DEFAULT ('') NOT NULL,
    [AKH_OpeZalNazwisko]  NVARCHAR (50)   CONSTRAINT [DF_AKH_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [AKH_Primary] PRIMARY KEY CLUSTERED ([AKH_AkhId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AKHAdfLink] FOREIGN KEY ([AKH_AdfId]) REFERENCES [CDN].[AkordDefinicja] ([ADF_AdfId]),
    CONSTRAINT [FK_AKHAkrLink] FOREIGN KEY ([AKH_AkrId]) REFERENCES [CDN].[Akordy] ([AKR_AkrId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [AKHAkrLink]
    ON [CDN].[AkordyHist]([AKH_AkrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [AKHAdfLink]
    ON [CDN].[AkordyHist]([AKH_AdfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.AkordyHis_Delete_Trigger
  ON CDN.AkordyHist
  FOR DELETE
AS
SET NOCOUNT ON
 declare @id int
 select @id = akh_akhid from deleted
 delete from cdn.opiskadry where opk_rodzajzrodla = 19 and opk_zrodloid = @id
SET NOCOUNT OFF
