CREATE TABLE [CDN].[SenditAdresyNadawcze] (
    [SAN_SANID]                  INT            IDENTITY (1, 1) NOT NULL,
    [SAN_Kod]                    NVARCHAR (20)  NOT NULL,
    [SAN_Nazwa]                  NVARCHAR (254) NOT NULL,
    [SAN_Ulica]                  NVARCHAR (254) NOT NULL,
    [SAN_NrDomu]                 NVARCHAR (254) NOT NULL,
    [SAN_NrMieszkania]           NVARCHAR (254) NOT NULL,
    [SAN_Miasto]                 NVARCHAR (254) NOT NULL,
    [SAN_KodPocztowy]            VARCHAR (254)  NOT NULL,
    [SAN_Domyslny]               TINYINT        NOT NULL,
    [SAN_Korespondencyjny]       TINYINT        NOT NULL,
    [SAN_PunktOdbioruOsobistego] TINYINT        CONSTRAINT [DF_SAN_PunktOdbioruOsobistego] DEFAULT ((0)) NOT NULL,
    [SAN_Nazwa2]                 NVARCHAR (254) CONSTRAINT [DF_SAN_Nazwa2] DEFAULT ('') NOT NULL,
    [SAN_KrajISO]                NVARCHAR (2)   CONSTRAINT [DF_SAN_KrajISO] DEFAULT ('') NOT NULL,
    [SAN_Wojewodztwo]            NVARCHAR (50)  CONSTRAINT [DF_SAN_Wojewodztwo] DEFAULT ('') NOT NULL,
    [SAN_Telefon]                NVARCHAR (20)  CONSTRAINT [DF_SAN_Telefon] DEFAULT ('') NOT NULL,
    [SAN_TelefonGSM]             NVARCHAR (20)  CONSTRAINT [DF_SAN_TelefonGSM] DEFAULT ('') NOT NULL,
    [SAN_DlugoscGeograficzna]    NVARCHAR (15)  CONSTRAINT [DF_SAN_DlugoscGeograficzna] DEFAULT ('') NOT NULL,
    [SAN_SzerokoscGeograficzna]  NVARCHAR (15)  CONSTRAINT [DF_SAN_SzerokoscGeograficzna] DEFAULT ('') NOT NULL,
    [SAN_UrzadNadaniaKod]        NVARCHAR (255) CONSTRAINT [DF_SAN_UrzadNadaniaKod] DEFAULT ('') NOT NULL,
    [SAN_UrzadNadaniaAdres]      NVARCHAR (255) CONSTRAINT [DF_SAN_UrzadNadaniaAdres] DEFAULT ('') NOT NULL,
    [SAN_PaczkomatKod]           NVARCHAR (255) CONSTRAINT [DF_SAN_PaczkomatKod] DEFAULT ('') NOT NULL,
    [SAN_PaczkomatAdres]         NVARCHAR (255) CONSTRAINT [DF_SAN_PaczkomatAdres] DEFAULT ('') NOT NULL,
    [SAN_IdMiejscaDostawy]       NVARCHAR (50)  CONSTRAINT [DF_SAN_IdMiejscaDostawy] DEFAULT ('') NOT NULL,
    [SAN_IdUrzadzenGrzewczych]   NVARCHAR (100) CONSTRAINT [DF_SAN_IdUrzadzenGrzewczych] DEFAULT ('') NOT NULL,
    [SAN_OsobaImie]              NVARCHAR (100) CONSTRAINT [DF_SAN_OsobaImie] DEFAULT ('') NOT NULL,
    [SAN_OsobaTelefon]           NVARCHAR (100) CONSTRAINT [DF_SAN_OsobaTelefon] DEFAULT ('') NOT NULL,
    [SAN_OsobaEmail]             NVARCHAR (100) CONSTRAINT [DF_SAN_OsobaEmail] DEFAULT ('') NOT NULL,
    [SAN_MagId]                  INT            CONSTRAINT [DF_SAN_MagId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [SAN_Primary] PRIMARY KEY CLUSTERED ([SAN_SANID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE TRIGGER CDN.SenditAdresyNadawcze_Delete_Trigger
  ON CDN.SenditAdresyNadawcze
  FOR DELETE
AS
  SET NOCOUNT ON
  Set ArithAbort On
--Sprawdzanie, czy dokument może byc skasowany
    IF EXISTS (SELECT * FROM deleted WHERE deleted.SAN_SANID =1 )
        BEGIN
          RAISERROR('##OPT34531##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
      IF EXISTS (SELECT * FROM deleted WHERE deleted.SAN_Domyslny =1 )
        BEGIN
          RAISERROR('##OPT34532##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
       IF EXISTS (SELECT * FROM deleted WHERE deleted.SAN_Korespondencyjny =1 )
        BEGIN
          RAISERROR('##OPT34533##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
       IF EXISTS( SELECT * FROM deleted join cdn.eSklepAdresyNadawczeRelacje on ESAN_SANOptimaID = san_sanid )
        BEGIN
          RAISERROR('##OPT34534##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
  Set NoCount Off
