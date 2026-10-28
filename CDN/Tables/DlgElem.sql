CREATE TABLE [CDN].[DlgElem] (
    [DLE_DLEId]                            INT             IDENTITY (1, 1) NOT NULL,
    [DLE_DLNId]                            INT             NOT NULL,
    [DLE_DataOd]                           DATETIME        NULL,
    [DLE_DataDo]                           DATETIME        NULL,
    [DLE_Kraj]                             NVARCHAR (255)  NULL,
    [DLE_Waluta]                           VARCHAR (3)     NOT NULL,
    [DLE_KursNumer]                        INT             NOT NULL,
    [DLE_KursL]                            DECIMAL (15, 4) NOT NULL,
    [DLE_KursM]                            DECIMAL (5)     NOT NULL,
    [DLE_KwotaSys]                         DECIMAL (15, 2) NOT NULL,
    [DLE_KwotaWal]                         DECIMAL (15, 2) NOT NULL,
    [DLE_TerminPlatnosci]                  DATETIME        NULL,
    [DLE_FPlId]                            INT             NULL,
    [DLE_GenerujPlatnoscKB]                SMALLINT        NULL,
    [DLE_IloscGodzinDelegacji]             DATETIME        NULL,
    [DLE_DietyIlosc]                       DECIMAL (15, 4) NULL,
    [DLE_DietyKwota]                       DECIMAL (15, 2) NULL,
    [DLE_RyczaltDojazdyIlosc]              INT             NULL,
    [DLE_RyczaltDojazdyKwota]              DECIMAL (15, 2) NULL,
    [DLE_RyczaltNoclegiIlosc]              INT             NULL,
    [DLE_RyczaltNoclegiKwota]              DECIMAL (15, 2) NULL,
    [DLE_RyczaltNoclegiAuto]               SMALLINT        NULL,
    [DLE_RyczaltDojazdyAuto]               SMALLINT        NULL,
    [DLE_NumerRejestracyjny]               VARCHAR (20)    NULL,
    [DLE_TypPojazdu]                       SMALLINT        NULL,
    [DLE_PojazdStawkaZaKilometr]           DECIMAL (15, 4) NULL,
    [DLE_PojazdIloscKilometrow]            INT             NULL,
    [DLE_PojazdKoszt]                      DECIMAL (15, 2) NULL,
    [DLE_IloscSniadan]                     INT             NULL,
    [DLE_IloscObiadow]                     INT             NULL,
    [DLE_IloscKolacji]                     INT             NULL,
    [DLE_RazemRyczaltDojazdy]              DECIMAL (15, 2) NULL,
    [DLE_RazemRyczaltNoclegi]              DECIMAL (15, 2) NULL,
    [DLE_RazemRyczaltDiety]                DECIMAL (15, 2) NULL,
    [DLE_RazemInneWydatki]                 DECIMAL (15, 2) NULL,
    [DLE_RazemWydatki]                     DECIMAL (15, 2) NULL,
    [DLE_RazemZaliczka]                    DECIMAL (15, 2) NULL,
    [DLE_RazemWydatkiBilety]               DECIMAL (15, 2) NULL,
    [DLE_RazemWydatkiNoclegi]              DECIMAL (15, 2) NULL,
    [DLE_RazemWydatkiInne]                 DECIMAL (15, 2) NULL,
    [DLE_RazemWydatkiBiletyIlosc]          INT             NULL,
    [DLE_RazemWydatkiNoclegiIlosc]         INT             NULL,
    [DLE_RazemWydatkiInneIlosc]            INT             NULL,
    [DLE_Opis]                             NVARCHAR (255)  NULL,
    [DLE_WymagaPrzeliczenia]               SMALLINT        CONSTRAINT [DF_DLE_WymagaPrzeliczenia] DEFAULT ((0)) NOT NULL,
    [DLE_Zrodlo]                           INT             CONSTRAINT [DF_DLE_Zrodlo] DEFAULT ((0)) NOT NULL,
    [DLE_GenerujZapisKB]                   SMALLINT        NULL,
    [DLE_ZapisKbBRaAkronim]                VARCHAR (20)    NULL,
    [DLE_Rozliczono]                       DECIMAL (15, 2) NULL,
    [DLE_Pozostaje]                        DECIMAL (15, 2) NULL,
    [DLE_KatId]                            INT             NULL,
    [DLE_Kategoria]                        NVARCHAR (50)   NULL,
    [DLE_RodzajEtapu]                      SMALLINT        CONSTRAINT [DF_DLE_RodzajEtapu] DEFAULT ((1)) NOT NULL,
    [DLE_KsiRazemRyczaltDojazdySys]        DECIMAL (15, 2) NULL,
    [DLE_KsiRazemRyczaltNoclegiSys]        DECIMAL (15, 2) NULL,
    [DLE_KsiRazemRyczaltDietySys]          DECIMAL (15, 2) NULL,
    [DLE_KsiRazemInneWydatkiSys]           DECIMAL (15, 2) NULL,
    [DLE_KsiRazemZaliczkaSys]              DECIMAL (15, 2) NULL,
    [DLE_KsiRazemZaliczka]                 DECIMAL (15, 2) NULL,
    [DLE_RoznicaKursowa]                   DECIMAL (15, 2) NULL,
    [DLE_KsiWaluta]                        VARCHAR (3)     NULL,
    [DLE_KsiKursNumer]                     INT             NULL,
    [DLE_KsiKursL]                         DECIMAL (15, 4) NULL,
    [DLE_KsiKursM]                         DECIMAL (5)     NULL,
    [DLE_KsiKwotaSys]                      DECIMAL (15, 2) NULL,
    [DLE_KsiKwotaWal]                      DECIMAL (15, 2) NULL,
    [DLE_RyczaltDojazdyDworzecAuto]        SMALLINT        NULL,
    [DLE_RyczaltDojazdyDworzecIlosc]       DECIMAL (15, 2) NULL,
    [DLE_RyczaltDojazdyDworzecKwota]       DECIMAL (15, 2) NULL,
    [DLE_RyczaltPobytSzpitalAuto]          SMALLINT        NULL,
    [DLE_RyczaltPobytSzpitalIlosc]         INT             NULL,
    [DLE_RyczaltPobytSzpitalKwota]         DECIMAL (15, 2) NULL,
    [DLE_RyczaltPobytSzpitalKwotaSys]      DECIMAL (15, 2) NULL,
    [DLE_KsiRyczaltPobytSzpitalKwota]      DECIMAL (15, 2) NULL,
    [DLE_KsiRyczaltPobytSzpitalKwotaSys]   DECIMAL (15, 2) NULL,
    [DLE_RozliczenieSys]                   SMALLINT        CONSTRAINT [DF_DLE_RozliczenieSys] DEFAULT ((0)) NOT NULL,
    [DLE_WyplataZaliczkiSys]               SMALLINT        CONSTRAINT [DF_DLE_WyplataZaliczkiSys] DEFAULT ((0)) NOT NULL,
    [DLE_KsiDataDok]                       DATETIME        NULL,
    [DLE_KsiDataKur]                       DATETIME        NULL,
    [DLE_DataDok]                          DATETIME        NULL,
    [DLE_DataKur]                          DATETIME        NULL,
    [DLE_DataPoniesieniaKosztu]            SMALLINT        CONSTRAINT [DF_DLE_DataPoniesieniaKosztu] DEFAULT ((1)) NOT NULL,
    [DLE_KursRozliczenia]                  SMALLINT        CONSTRAINT [DF_DLE_KursRozliczenia] DEFAULT ((1)) NOT NULL,
    [DLE_GodzinaOd]                        DATETIME        NULL,
    [DLE_GodzinaDo]                        DATETIME        NULL,
    [DLE_SumujWyjazdPrzyjazd]              SMALLINT        CONSTRAINT [DF_DLE_SumujWyjazdPrzyjazd] DEFAULT ((0)) NOT NULL,
    [DLE_IloscGodzinWyjazd]                DATETIME        NULL,
    [DLE_IloscGodzinPrzyjazd]              DATETIME        NULL,
    [DLE_StawkaDiety]                      DECIMAL (15, 2) NULL,
    [DLE_StawkaTyp]                        SMALLINT        NULL,
    [DLE_DietyKwotaSys]                    DECIMAL (15, 2) NULL,
    [DLE_RyczaltNoclegiKwotaSys]           DECIMAL (15, 2) NULL,
    [DLE_RyczaltDojazdyKwotaSys]           DECIMAL (15, 2) NULL,
    [DLE_PojazdKosztSys]                   DECIMAL (15, 2) NULL,
    [DLE_RyczaltDojazdyDworzecKwotaSys]    DECIMAL (15, 2) NULL,
    [DLE_RazemRyczaltDojazdySys]           DECIMAL (15, 2) NULL,
    [DLE_RazemRyczaltNoclegiSys]           DECIMAL (15, 2) NULL,
    [DLE_RazemRyczaltDietySys]             DECIMAL (15, 2) NULL,
    [DLE_RazemInneWydatkiSys]              DECIMAL (15, 2) NULL,
    [DLE_RazemWydatkiSys]                  DECIMAL (15, 2) NULL,
    [DLE_RazemZaliczkaSys]                 DECIMAL (15, 2) NULL,
    [DLE_KsiDietyKwotaSys]                 DECIMAL (15, 2) NULL,
    [DLE_KsiDietyKwota]                    DECIMAL (15, 2) NULL,
    [DLE_KsiRyczaltNoclegiKwotaSys]        DECIMAL (15, 2) NULL,
    [DLE_KsiRyczaltNoclegiKwota]           DECIMAL (15, 2) NULL,
    [DLE_KsiRyczaltDojazdyKwotaSys]        DECIMAL (15, 2) NULL,
    [DLE_KsiRyczaltDojazdyKwota]           DECIMAL (15, 2) NULL,
    [DLE_KsiPojazdKosztSys]                DECIMAL (15, 2) NULL,
    [DLE_KsiPojazdKoszt]                   DECIMAL (15, 2) NULL,
    [DLE_KsiRyczaltDojazdyDworzecKwotaSys] DECIMAL (15, 2) NULL,
    [DLE_KsiRyczaltDojazdyDworzecKwota]    DECIMAL (15, 2) NULL,
    [DLE_KsiRazemWydatkiSys]               DECIMAL (15, 2) NULL,
    [DLE_KsiRazemWydatki]                  DECIMAL (15, 2) NULL,
    [DLE_KsiRazemRyczaltDojazdy]           DECIMAL (15, 2) NULL,
    [DLE_KsiRazemRyczaltNoclegi]           DECIMAL (15, 2) NULL,
    [DLE_KsiRazemRyczaltDiety]             DECIMAL (15, 2) NULL,
    [DLE_KsiRazemInneWydatki]              DECIMAL (15, 2) NULL,
    [DLE_KwotaRozliczenia]                 DECIMAL (15, 2) NULL,
    [DLE_KwotaRozliczeniaSys]              DECIMAL (15, 2) NULL,
    [DLE_KsiKwotaRozliczenia]              DECIMAL (15, 2) NULL,
    [DLE_KsiKwotaRozliczeniaSys]           DECIMAL (15, 2) NULL,
    [DLE_RazemDiety]                       DECIMAL (15, 2) NULL,
    [DLE_RazemDietySys]                    DECIMAL (15, 2) NULL,
    [DLE_KsiRazemDiety]                    DECIMAL (15, 2) NULL,
    [DLE_KsiRazemDietySys]                 DECIMAL (15, 2) NULL,
    CONSTRAINT [DLE_Primary] PRIMARY KEY CLUSTERED ([DLE_DLEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DlgElemDlgNag] FOREIGN KEY ([DLE_DLNId]) REFERENCES [CDN].[DlgNag] ([DLN_DLNId]) ON DELETE CASCADE
);


GO
CREATE TRIGGER CDN.DlgElem_Delete_Trigger
 ON CDN.DlgElem
 FOR DELETE
AS
 SET NOCOUNT ON
 SET ARITHABORT ON
 Declare @DokId Int
 Declare skasowane Cursor Local Fast_Forward For Select DLE_DLEId From deleted
 Open skasowane
 While 1=1
 Begin
  Fetch Next From skasowane InTo @DokId
  If @@Fetch_Status <> 0 Break
  Execute CDN.KasujRozliczenia 108, @DokId
 End
 Close skasowane
 Deallocate skasowane
 DELETE CDN.BnkZdarzenia
 FROM CDN.BnkZdarzenia, deleted
 WHERE deleted.DLE_DLEID = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=108)
 IF EXISTS(
  SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
  ON deleted.DLE_DLEID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=108)
 )
 DELETE CDN.KwotyDodatkowe
 FROM CDN.KwotyDodatkowe, deleted
 WHERE deleted.DLE_DLEID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=108)
 SET NOCOUNT OFF
