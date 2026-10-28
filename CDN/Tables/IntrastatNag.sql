CREATE TABLE [CDN].[IntrastatNag] (
    [IsN_IsNId]                        INT             IDENTITY (1, 1) NOT NULL,
    [IsN_ZwrId]                        INT             NULL,
    [IsN_Typ]                          TINYINT         NOT NULL,
    [IsN_Rodzaj]                       TINYINT         NOT NULL,
    [IsN_Czesciowa]                    TINYINT         NOT NULL,
    [IsN_Automatyczna]                 TINYINT         NOT NULL,
    [IsN_KursNumer]                    INT             NOT NULL,
    [IsN_UrzadCelnyKod]                NVARCHAR (8)    NOT NULL,
    [IsN_Rok]                          SMALLINT        NOT NULL,
    [IsN_Miesiac]                      TINYINT         NOT NULL,
    [IsN_Numer]                        INT             NOT NULL,
    [IsN_Wersja]                       INT             NOT NULL,
    [IsN_Blokada]                      TINYINT         NOT NULL,
    [IsN_PodNazwa1]                    NVARCHAR (50)   NOT NULL,
    [IsN_PodNazwa2]                    NVARCHAR (50)   NOT NULL,
    [IsN_PodNazwa3]                    NVARCHAR (250)  NOT NULL,
    [IsN_PodKraj]                      NVARCHAR (40)   NOT NULL,
    [IsN_PodWojewodztwo]               NVARCHAR (40)   NOT NULL,
    [IsN_PodPowiat]                    NVARCHAR (40)   NOT NULL,
    [IsN_PodGmina]                     NVARCHAR (40)   NOT NULL,
    [IsN_PodUlica]                     NVARCHAR (40)   NOT NULL,
    [IsN_PodNrDomu]                    NVARCHAR (10)   NOT NULL,
    [IsN_PodNrLokalu]                  NVARCHAR (10)   NOT NULL,
    [IsN_PodMiasto]                    NVARCHAR (40)   NOT NULL,
    [IsN_PodKodPocztowy]               VARCHAR (10)    NOT NULL,
    [IsN_PodPoczta]                    NVARCHAR (40)   NOT NULL,
    [IsN_PodAdres2]                    NVARCHAR (40)   NOT NULL,
    [IsN_PodNipKraj]                   VARCHAR (2)     NOT NULL,
    [IsN_PodNipE]                      NVARCHAR (20)   NOT NULL,
    [IsN_PodRegon]                     VARCHAR (14)    NOT NULL,
    [IsN_ZglTyp]                       SMALLINT        NULL,
    [IsN_ZglId]                        INT             NULL,
    [IsN_ZglNazwa1]                    NVARCHAR (50)   NOT NULL,
    [IsN_ZglNazwa2]                    NVARCHAR (50)   NOT NULL,
    [IsN_ZglNazwa3]                    NVARCHAR (250)  NOT NULL,
    [IsN_ZglKraj]                      NVARCHAR (40)   NOT NULL,
    [IsN_ZglWojewodztwo]               NVARCHAR (40)   NOT NULL,
    [IsN_ZglPowiat]                    NVARCHAR (40)   NOT NULL,
    [IsN_ZglGmina]                     NVARCHAR (40)   NOT NULL,
    [IsN_ZglUlica]                     NVARCHAR (40)   NOT NULL,
    [IsN_ZglNrDomu]                    NVARCHAR (10)   NOT NULL,
    [IsN_ZglNrLokalu]                  NVARCHAR (10)   NOT NULL,
    [IsN_ZglMiasto]                    NVARCHAR (40)   NOT NULL,
    [IsN_ZglKodPocztowy]               VARCHAR (10)    NOT NULL,
    [IsN_ZglPoczta]                    NVARCHAR (40)   NOT NULL,
    [IsN_ZglAdres2]                    NVARCHAR (40)   NOT NULL,
    [IsN_ZglRegon]                     VARCHAR (14)    NOT NULL,
    [IsN_ZglNipKraj]                   VARCHAR (2)     NOT NULL,
    [IsN_ZglNipE]                      NVARCHAR (20)   NOT NULL,
    [IsN_WypImie]                      NVARCHAR (50)   NOT NULL,
    [IsN_WypNazwisko]                  NVARCHAR (50)   NOT NULL,
    [IsN_WypTelefon]                   VARCHAR (50)    NOT NULL,
    [IsN_WypFax]                       VARCHAR (50)    NOT NULL,
    [IsN_WypEmail]                     NVARCHAR (50)   NOT NULL,
    [IsN_Miejscowosc]                  NVARCHAR (50)   NOT NULL,
    [IsN_TS_Export]                    DATETIME        NULL,
    [IsN_DataWypelnienia]              DATETIME        NULL,
    [IsN_OpeZalId]                     INT             NULL,
    [IsN_StaZalId]                     INT             NULL,
    [IsN_TS_Zal]                       DATETIME        NOT NULL,
    [IsN_OpeModId]                     INT             NULL,
    [IsN_StaModId]                     INT             NULL,
    [IsN_TS_Mod]                       DATETIME        NOT NULL,
    [IsN_EDekl_RefID]                  NVARCHAR (240)  NULL,
    [IsN_EDekl_Status]                 INT             NULL,
    [IsN_EDekl_StatusOpis]             NVARCHAR (1000) NULL,
    [IsN_EDekl_Podmiot]                NVARCHAR (1000) NULL,
    [IsN_EDekl_DokumentID]             VARCHAR (240)   NULL,
    [IsN_EDekl_DataWplyniecia]         NVARCHAR (50)   NULL,
    [IsN_EDekl_SkrotDokumentu]         NVARCHAR (240)  NULL,
    [IsN_EDekl_SkrotStruktury]         NVARCHAR (240)  NULL,
    [IsN_EDekl_StrukturaLogiczna]      NVARCHAR (240)  NULL,
    [IsN_EDekl_NIP1]                   VARCHAR (50)    NULL,
    [IsN_EDekl_NIP2]                   VARCHAR (50)    NULL,
    [IsN_EDekl_SigningTime]            NVARCHAR (50)   NULL,
    [IsN_EDekl_StempelCzasu]           NVARCHAR (240)  NULL,
    [IsN_EDekl_OperatorWysylajacy]     INT             NULL,
    [IsN_EDekl_OperatorPobierajacyUPO] INT             NULL,
    [IsN_EDekl_DataWyslania]           DATETIME        NULL,
    [IsN_EDekl_DataOdebraniaUPO]       DATETIME        NULL,
    [IsN_EDekl_KodUrzedu]              VARCHAR (6)     NULL,
    [IsN_EDekl_NrWlasny]               NVARCHAR (240)  NULL,
    [IsN_OpeModKod]                    VARCHAR (20)    CONSTRAINT [DF_IsN_OpeModKod] DEFAULT ('') NOT NULL,
    [IsN_OpeModNazwisko]               NVARCHAR (50)   CONSTRAINT [DF_IsN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [IsN_OpeZalKod]                    VARCHAR (20)    CONSTRAINT [DF_IsN_OpeZalKod] DEFAULT ('') NOT NULL,
    [IsN_OpeZalNazwisko]               NVARCHAR (50)   CONSTRAINT [DF_IsN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [IsN_Netto]                        AS              ([CDN].[FNISN_WARTOSC]([ISN_ISNID])),
    [IsN_IloscPozycji]                 AS              ([CDN].[FNISN_ILOSC]([ISN_ISNID])),
    CONSTRAINT [IsN_Primary] PRIMARY KEY CLUSTERED ([IsN_IsNId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_IsNZglaszajacy] FOREIGN KEY ([IsN_ZglId], [IsN_ZglTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IsNNumer]
    ON [CDN].[IntrastatNag]([IsN_Typ] ASC, [IsN_Rok] ASC, [IsN_Miesiac] ASC, [IsN_Numer] ASC, [IsN_Wersja] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [IsNZglaszajacy]
    ON [CDN].[IntrastatNag]([IsN_ZglId] ASC, [IsN_ZglTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.IntrastatNag_Delete_Trigger
  ON CDN.IntrastatNag
  FOR DELETE
AS
  SET NOCOUNT ON
  Set ArithAbort On
--Sprawdzanie, czy dokument może byc skasowany (jest w buforze)
  IF EXISTS (SELECT * FROM deleted WHERE deleted.IsN_Blokada = 1 )
  BEGIN
    RAISERROR('##OPT34513##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa relacji w tabeli CDN.TraNag
  UPDATE CDN.TraNag SET TrN_IsNID = null WHERE TrN_IsNID IN (SELECT IsN_IsNID FROM deleted)
-- obsługa kasowania wierszy z tabeli CDN.RptObrazy2
  DELETE CDN.RptObrazy2
  FROM CDN.RptObrazy2 JOIN deleted on deleted.IsN_IsNID = CDN.RptObrazy2.Rpo2_DokumentId
  WHERE
      CDN.RptObrazy2.Rpo2_DokumentTyp=110
 SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.IntrastatNag_Update_Trigger
  ON CDN.IntrastatNag
  FOR UPDATE
AS
  SET NOCOUNT ON
-- Obsługa "odblokowania" deklaracji
  IF UPDATE (IsN_Blokada)
  BEGIN
  -- obsługa kasowania wierszy z tabeli CDN.RptObrazy2
  DELETE CDN.RptObrazy2
  FROM CDN.RptObrazy2 JOIN deleted on deleted.IsN_IsNID = CDN.RptObrazy2.Rpo2_DokumentId
  WHERE
      CDN.RptObrazy2.Rpo2_DokumentTyp=110
  END
  SET NOCOUNT OFF
