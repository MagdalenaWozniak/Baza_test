CREATE TABLE [CDN].[DetalStanKontrahenci] (
    [DSKnt_DSKntId]            INT            IDENTITY (1, 1) NOT NULL,
    [DSKnt_OptimaId]           INT            NOT NULL,
    [DSKnt_Kod]                VARCHAR (20)   NOT NULL,
    [DSKnt_EAN]                VARCHAR (16)   NOT NULL,
    [DSKnt_Nazwa1]             NVARCHAR (50)  NOT NULL,
    [DSKnt_Nazwa2]             NVARCHAR (50)  NOT NULL,
    [DSKnt_Nazwa3]             NVARCHAR (250) NOT NULL,
    [DSKnt_Kraj]               NVARCHAR (40)  NOT NULL,
    [DSKnt_Wojewodztwo]        NVARCHAR (40)  NOT NULL,
    [DSKnt_Powiat]             NVARCHAR (40)  NOT NULL,
    [DSKnt_Gmina]              NVARCHAR (40)  NOT NULL,
    [DSKnt_Ulica]              NVARCHAR (40)  NOT NULL,
    [DSKnt_NrDomu]             NVARCHAR (10)  NOT NULL,
    [DSKnt_NrLokalu]           NVARCHAR (10)  NOT NULL,
    [DSKnt_Miasto]             NVARCHAR (40)  NOT NULL,
    [DSKnt_KodPocztowy]        VARCHAR (10)   NOT NULL,
    [DSKnt_Poczta]             NVARCHAR (40)  NOT NULL,
    [DSKnt_Adres2]             NVARCHAR (40)  NOT NULL,
    [DSKnt_NipKraj]            VARCHAR (2)    NOT NULL,
    [DSKnt_NipE]               NVARCHAR (20)  NOT NULL,
    [DSKnt_Nip]                NVARCHAR (20)  NOT NULL,
    [DSKnt_Regon]              VARCHAR (20)   NOT NULL,
    [DSKnt_Pesel]              NVARCHAR (11)  NOT NULL,
    [DSKnt_NieAktywny]         TINYINT        NOT NULL,
    [DSKnt_StanSynchronizacji] INT            NOT NULL,
    [DSKnt_Telefon]            VARCHAR (20)   NOT NULL,
    [DSKnt_Opis]               NVARCHAR (254) NOT NULL,
    [DSKnt_OsobaOdbierajaca]   NVARCHAR (40)  NOT NULL,
    [DSKnt_TS_Mod]             DATETIME       NOT NULL,
    [DSKnt_OpeID]              INT            NOT NULL,
    CONSTRAINT [DSKnt_Primary] PRIMARY KEY CLUSTERED ([DSKnt_DSKntId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSKntDetalOptimaId]
    ON [CDN].[DetalStanKontrahenci]([DSKnt_OptimaId] ASC, [DSKnt_DSKntId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DSKontrahenci_InsertUpdate_Trigger
  ON CDN.DetalStanKontrahenci
  FOR INSERT,UPDATE
AS
  SET NOCOUNT ON
  IF EXISTS (SELECT * FROM inserted A, CDN.DetalStanKontrahenci B
  WHERE A.DSKnt_OptimaId = B.DSKnt_OptimaId AND B.DSKnt_OptimaId > 0 AND A.DSKnt_OptimaId > 0 AND
  A.DSKnt_DSKntId <> B.DSKnt_DSKntId)
    BEGIN
          RAISERROR('##OPT34505##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
Set NoCount Off
