CREATE TABLE [CDN].[Umowy] (
    [UMW_UmwId]               INT             IDENTITY (1, 1) NOT NULL,
    [UMW_PraId]               INT             NOT NULL,
    [UMW_DzlId]               INT             CONSTRAINT [DF_UMW_DzlId] DEFAULT ((3)) NULL,
    [UMW_DdfId]               INT             NOT NULL,
    [UMW_TwpId]               INT             NOT NULL,
    [UMW_TumId]               INT             NOT NULL,
    [UMW_TyuId]               INT             NOT NULL,
    [UMW_ListaPlacSymbol]     INT             NULL,
    [UMW_NumerString]         VARCHAR (31)    NOT NULL,
    [UMW_NumerNr]             INT             NOT NULL,
    [UMW_NumerPelny]          AS              ([CDN].[FN_NUMERPELNY]([UMW_NUMERNR],[UMW_NUMERSTRING])),
    [UMW_DataDok]             DATETIME        NOT NULL,
    [UMW_DataOd]              DATETIME        NOT NULL,
    [UMW_DataDo]              DATETIME        NOT NULL,
    [UMW_Tytul]               NVARCHAR (127)  NOT NULL,
    [UMW_Wartosc]             DECIMAL (15, 2) NOT NULL,
    [UMW_Rodzaj]              NVARCHAR (127)  NOT NULL,
    [UMW_Splacono]            DECIMAL (15, 2) NOT NULL,
    [UMW_Waluta]              VARCHAR (3)     NOT NULL,
    [UMW_WgBrutto]            TINYINT         NOT NULL,
    [UMW_JestZUS]             TINYINT         NOT NULL,
    [UMW_Brutto]              DECIMAL (15, 2) NOT NULL,
    [UMW_Fis]                 DECIMAL (15, 2) NOT NULL,
    [UMW_Zus]                 DECIMAL (15, 2) NOT NULL,
    [UMW_PomnZUS]             TINYINT         NOT NULL,
    [UMW_StawkaPodatku]       DECIMAL (15, 2) NOT NULL,
    [UMW_KosztyKwota]         DECIMAL (15, 2) NOT NULL,
    [UMW_KosztyProc]          DECIMAL (15, 2) NOT NULL,
    [UMW_KodZawodu]           INT             NOT NULL,
    [UMW_ZusOd]               DATETIME        NULL,
    [UMW_JestEmerytal]        TINYINT         NOT NULL,
    [UMW_JestRentowe]         TINYINT         NOT NULL,
    [UMW_JestChorobowe]       TINYINT         NOT NULL,
    [UMW_JestWypad]           TINYINT         NOT NULL,
    [UMW_EmerOd]              DATETIME        NULL,
    [UMW_EmerDo]              DATETIME        NULL,
    [UMW_RentOd]              DATETIME        NULL,
    [UMW_RentDo]              DATETIME        NULL,
    [UMW_ChorOd]              DATETIME        NULL,
    [UMW_ChorDo]              DATETIME        NULL,
    [UMW_WypadDo]             DATETIME        NULL,
    [UMW_EmerKod]             INT             NOT NULL,
    [UMW_RentKod]             INT             NOT NULL,
    [UMW_ChorKod]             INT             NOT NULL,
    [UMW_WypadKod]            INT             NOT NULL,
    [UMW_ZdrowOd]             DATETIME        NULL,
    [UMW_ZdrowDobrOd]         DATETIME        NULL,
    [UMW_ZdrowDo]             DATETIME        NULL,
    [UMW_ZdrowKwotaPierwSkl]  DECIMAL (15, 2) NOT NULL,
    [UMW_ZdrowKod]            INT             NOT NULL,
    [UMW_TytKontZUS]          INT             NOT NULL,
    [UMW_ZusKontoOd]          DATETIME        NULL,
    [UMW_JestDobrEmerytal]    TINYINT         NOT NULL,
    [UMW_JestDobrRentowe]     TINYINT         NOT NULL,
    [UMW_JestDobrChorobowe]   TINYINT         NOT NULL,
    [UMW_JestDobrZdrow]       TINYINT         NOT NULL,
    [UMW_PrzekroczRok]        INT             NULL,
    [UMW_PrzekroczMiesiac]    TINYINT         NULL,
    [UMW_PrzekroczKwota]      DECIMAL (15, 2) NULL,
    [UMW_PrzekroczInformacja] NVARCHAR (40)   NULL,
    [UMW_Przekroczenie]       TINYINT         NULL,
    [UMW_OgraniczSklZdrow]    TINYINT         NOT NULL,
    [UMW_KwotaNastWyp]        DECIMAL (15, 2) NULL,
    [UMW_Splacona]            TINYINT         NOT NULL,
    [UMW_Symbol]              VARCHAR (40)    NOT NULL,
    [UMW_Opis]                NVARCHAR (1024) NOT NULL,
    [UMW_NaliczajFundusze]    TINYINT         NOT NULL,
    [UMW_WliczChorZakonczona] TINYINT         CONSTRAINT [DF_UMW_WliczChorZakonczona] DEFAULT ((0)) NOT NULL,
    [UMW_OpeZalId]            INT             NULL,
    [UMW_StaZalId]            INT             NULL,
    [UMW_TS_Zal]              DATETIME        NOT NULL,
    [UMW_OpeModId]            INT             NULL,
    [UMW_StaModId]            INT             NULL,
    [UMW_TS_Mod]              DATETIME        NOT NULL,
    [UMW_UwzglMin]            TINYINT         CONSTRAINT [DF_UMW_UwzglMin] DEFAULT ((0)) NOT NULL,
    [UMW_CzasPracy]           TINYINT         CONSTRAINT [DF_UMW_CzasPracy] DEFAULT ((0)) NOT NULL,
    [UMW_StawkaGodz]          DECIMAL (15, 2) CONSTRAINT [DF_UMW_StawkaGodz] DEFAULT ((0)) NOT NULL,
    [UMW_OpeModKod]           VARCHAR (20)    CONSTRAINT [DF_UMW_OpeModKod] DEFAULT ('') NOT NULL,
    [UMW_OpeModNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_UMW_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [UMW_OpeZalKod]           VARCHAR (20)    CONSTRAINT [DF_UMW_OpeZalKod] DEFAULT ('') NOT NULL,
    [UMW_OpeZalNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_UMW_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [UMW_Primary] PRIMARY KEY CLUSTERED ([UMW_UmwId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UMWDdfLink] FOREIGN KEY ([UMW_DdfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_UMWDzlLink] FOREIGN KEY ([UMW_DzlId]) REFERENCES [CDN].[Dzialy] ([DZL_DzlId]),
    CONSTRAINT [FK_UMWPraLink] FOREIGN KEY ([UMW_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId]) ON DELETE CASCADE,
    CONSTRAINT [FK_UMWTyuLink] FOREIGN KEY ([UMW_TyuId]) REFERENCES [CDN].[TytUbezp] ([TYU_TyuId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UMWPraLink]
    ON [CDN].[Umowy]([UMW_PraId] ASC, [UMW_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UmwNumerPelny]
    ON [CDN].[Umowy]([UMW_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [UMWDzlLink]
    ON [CDN].[Umowy]([UMW_DzlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [UMWDdfLink]
    ON [CDN].[Umowy]([UMW_DdfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [UMWTyuLink]
    ON [CDN].[Umowy]([UMW_TyuId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [UMWTwpLink]
    ON [CDN].[Umowy]([UMW_TwpId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [UMWLPLink]
    ON [CDN].[Umowy]([UMW_ListaPlacSymbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Umowy2WypSkladniki_Delete_Trigger
  ON CDN.Umowy
  FOR DELETE
AS
SET NOCOUNT ON
-- obsługa sprawdzania relacji restrict do tabeli CDN.WypSkladniki
IF EXISTS (SELECT * FROM CDN.WypSkladniki JOIN deleted ON Umw_UmwId = WPS_ZrodloId
           WHERE CDN.WypSkladniki.WPS_RodzajZrodla=8)
  BEGIN
 RAISERROR('##OPT32559##', 16, 1)
    --RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą WypSkladniki). ', 16, 1)--ERR_SQL_Place_WypSkladnikiPowiazanieWPS 32559
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
 --MC8.5
 declare @id int
 select @id = umw_umwid from deleted
 delete from cdn.opiskadry where opk_rodzajzrodla = 8 and opk_zrodloid = @id
 if exists (select DOU_DouId from cdn.DodatkiUmowy where DOU_UmwId = @id)
    begin
  RAISERROR('##OPT32556##', 16, 1)
  --raiserror('Nie można usunąć umowy powiązanej z dodatkiem/potrąceniem.', 16, 1)--ERR_SQL_Place_NieMoznaUsunacUmowyPowiazanej 32556
      rollback tran
      set nocount off
      return
    end
SET NOCOUNT OFF
