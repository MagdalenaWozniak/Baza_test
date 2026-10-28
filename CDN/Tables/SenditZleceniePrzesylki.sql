CREATE TABLE [CDN].[SenditZleceniePrzesylki] (
    [SZL_SZLID]                        INT             IDENTITY (1, 1) NOT NULL,
    [SZL_DDfId]                        INT             NOT NULL,
    [SZL_FaId]                         INT             NOT NULL,
    [SZL_NumerNr]                      INT             NOT NULL,
    [SZL_NumerString]                  VARCHAR (31)    NOT NULL,
    [SZL_NumerPelny]                   AS              ([CDN].[FN_NUMERPELNY]([SZL_NUMERNR],[SZL_NUMERSTRING])),
    [SZL_Bufor]                        SMALLINT        NOT NULL,
    [SZL_DataDok]                      DATETIME        NOT NULL,
    [SZL_OpiekunTyp]                   SMALLINT        NULL,
    [SZL_OpiekunId]                    INT             NULL,
    [SZL_SANID]                        INT             NULL,
    [SZL_SANUlica]                     NVARCHAR (40)   NOT NULL,
    [SZL_SANNrDomu]                    NVARCHAR (10)   NOT NULL,
    [SZL_SANNrLokalu]                  NVARCHAR (10)   NOT NULL,
    [SZL_SANMiasto]                    NVARCHAR (40)   NOT NULL,
    [SZL_SANKodPocztowy]               VARCHAR (10)    NOT NULL,
    [SZL_SANTelefon]                   VARCHAR (20)    NULL,
    [SZL_SANEmail]                     NVARCHAR (127)  NULL,
    [SZL_OdbiorcaTyp]                  SMALLINT        NULL,
    [SZL_OdbID]                        INT             NULL,
    [SZL_OdbNazwa]                     NVARCHAR (250)  NOT NULL,
    [SZL_OdbUlica]                     NVARCHAR (40)   NOT NULL,
    [SZL_OdbNrDomu]                    NVARCHAR (10)   NOT NULL,
    [SZL_OdbNrLokalu]                  NVARCHAR (10)   NOT NULL,
    [SZL_OdbMiasto]                    NVARCHAR (40)   NOT NULL,
    [SZL_OdbKodPocztowy]               VARCHAR (10)    NOT NULL,
    [SZL_OdbTelefon]                   VARCHAR (20)    NULL,
    [SZL_OdbEmail]                     NVARCHAR (127)  NULL,
    [SZL_Odebral]                      NVARCHAR (40)   NOT NULL,
    [SZL_FirmaKurierskaID]             INT             NOT NULL,
    [SZL_OpcjePobranie]                TINYINT         NOT NULL,
    [SZL_OpcjeKwotaPobrania]           DECIMAL (15, 2) NOT NULL,
    [SZL_OpcjeZwrotPotwierdzenia]      TINYINT         NOT NULL,
    [SZL_OpcjeUbezpieczenie]           TINYINT         NOT NULL,
    [SZL_OpcjeKwotaUbezpieczenia]      DECIMAL (15, 2) NOT NULL,
    [SZL_DataWyslania]                 DATETIME        NOT NULL,
    [SZL_DataKurierOD]                 DATETIME        NOT NULL,
    [SZL_DataKurierDo]                 DATETIME        NOT NULL,
    [SZL_NumerZleceniaSendit]          NVARCHAR (254)  NOT NULL,
    [SZL_NumerProtokoluOdbioru]        NVARCHAR (254)  NOT NULL,
    [SZL_NumerZleceniaOdbioru]         NVARCHAR (254)  NOT NULL,
    [SZL_StatusKey]                    NVARCHAR (254)  NOT NULL,
    [SZL_Status]                       NVARCHAR (254)  NOT NULL,
    [SZL_DataStatusu]                  DATETIME        NOT NULL,
    [SZL_Uwagi]                        NVARCHAR (1024) NOT NULL,
    [SZL_Koszt]                        DECIMAL (15, 2) NOT NULL,
    [SZL_OpeZalID]                     INT             NULL,
    [SZL_StaZalId]                     INT             NULL,
    [SZL_TS_Zal]                       DATETIME        NOT NULL,
    [SZL_OpeModID]                     INT             NULL,
    [SZL_StaModId]                     INT             NULL,
    [SZL_TS_Mod]                       DATETIME        NOT NULL,
    [SZL_OpeModKod]                    VARCHAR (20)    CONSTRAINT [DF_SZL_OpeModKod] DEFAULT ('') NOT NULL,
    [SZL_OpeModNazwisko]               NVARCHAR (50)   CONSTRAINT [DF_SZL_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SZL_OpeZalKod]                    VARCHAR (20)    CONSTRAINT [DF_SZL_OpeZalKod] DEFAULT ('') NOT NULL,
    [SZL_OpeZalNazwisko]               NVARCHAR (50)   CONSTRAINT [DF_SZL_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [SZL_TypKuriera]                   INT             CONSTRAINT [DF_SZL_TypKuriera] DEFAULT ((1)) NOT NULL,
    [SZL_BladWalidacji]                NVARCHAR (MAX)  CONSTRAINT [DF_SZL_BladWalidacji] DEFAULT ('') NOT NULL,
    [SZL_NrListuPrzewozowego]          NVARCHAR (MAX)  CONSTRAINT [DF_SZL_NrListuPrzewozowego] DEFAULT ('') NOT NULL,
    [SZL_Platnik]                      INT             CONSTRAINT [DF_SZL_Platnik] DEFAULT ((0)) NOT NULL,
    [SZL_NumerPlatnika]                NVARCHAR (254)  CONSTRAINT [DF_SZL_NumerPlatnika] DEFAULT ('') NOT NULL,
    [SZL_PrzesylkaDoOddzialu]          INT             CONSTRAINT [DF_SZL_PrzesylkaDoOddzialu] DEFAULT ((0)) NOT NULL,
    [SZL_OdbAdresKorespondencyjny]     INT             CONSTRAINT [DF_SZL_OdbAdresKorespondencyjny] DEFAULT ((0)) NOT NULL,
    [SZL_Zawartosc]                    INT             CONSTRAINT [DF_SZL_Zawartosc] DEFAULT ((0)) NOT NULL,
    [SZL_ZawartoscTekst]               NVARCHAR (254)  CONSTRAINT [DF_SZL_ZawartoscTekst] DEFAULT ('') NOT NULL,
    [SZL_Referencje]                   INT             CONSTRAINT [DF_SZL_Referencje] DEFAULT ((0)) NOT NULL,
    [SZL_ReferencjeTekst]              NVARCHAR (254)  CONSTRAINT [DF_SZL_ReferencjeTekst] DEFAULT ('') NOT NULL,
    [SZL_DokumentyZwrotne]             INT             CONSTRAINT [DF_SZL_DokumentyZwrotne] DEFAULT ((0)) NOT NULL,
    [SZL_DokumentyZwrotneTekst]        NVARCHAR (254)  CONSTRAINT [DF_SZL_DokumentyZwrotneTekst] DEFAULT ('') NOT NULL,
    [SZL_PrzesylkaZwrotna]             INT             CONSTRAINT [DF_SZL_PrzesylkaZwrotna] DEFAULT ((0)) NOT NULL,
    [SZL_OdbSANID]                     INT             NULL,
    [SZL_SANNazwa]                     NVARCHAR (250)  CONSTRAINT [DF_SZL_SANNazwa] DEFAULT ('') NOT NULL,
    [SZL_TypPaczkiDPD]                 INT             CONSTRAINT [DF_SZL_TypPaczkiDPD] DEFAULT ((0)) NOT NULL,
    [SZL_Preawizacja]                  TINYINT         CONSTRAINT [DF_SZL_Preawizacja] DEFAULT ((0)) NOT NULL,
    [SZL_Serwis]                       TINYINT         CONSTRAINT [DF_SZL_Serwis] DEFAULT ((0)) NOT NULL,
    [SZL_OdbiorWPunkcie]               TINYINT         CONSTRAINT [DF_SZL_OdbiorWPunkcie] DEFAULT ((0)) NOT NULL,
    [SZL_OdbiorWPunkcieId]             NVARCHAR (50)   CONSTRAINT [DF_SZL_OdbiorWPunkcieId] DEFAULT ('') NOT NULL,
    [SZL_OdbiorWPunkcieNazwa]          NVARCHAR (255)  CONSTRAINT [DF_SZL_OdbiorWPunkcieNazwa] DEFAULT ('') NOT NULL,
    [SZL_OdbiorWPunkcieAdres]          NVARCHAR (255)  CONSTRAINT [DF_SZL_OdbiorWPunkcieAdres] DEFAULT ('') NOT NULL,
    [SZL_SposobPobrania]               TINYINT         CONSTRAINT [DF_SZL_SposobPobrania] DEFAULT ((0)) NOT NULL,
    [SZL_TytulPrzelewu]                NVARCHAR (255)  CONSTRAINT [DF_SZL_TytulPrzelewu] DEFAULT ('') NOT NULL,
    [SZL_DokumentyZwrotneTyp]          TINYINT         CONSTRAINT [DF_SZL_DokumentyZwrotneTyp] DEFAULT ((0)) NOT NULL,
    [SZL_PotwierdzenieOdbioru]         TINYINT         CONSTRAINT [DF_SZL_PotwierdzenieOdbioru] DEFAULT ((0)) NOT NULL,
    [SZL_PotwierdzenieOdbioruTyp]      TINYINT         CONSTRAINT [DF_SZL_PotwierdzenieOdbioruTyp] DEFAULT ((0)) NOT NULL,
    [SZL_PotwierdzenieOdbioruIlosc]    TINYINT         CONSTRAINT [DF_SZL_PotwierdzenieOdbioruIlosc] DEFAULT ((0)) NOT NULL,
    [SZL_EPO]                          TINYINT         CONSTRAINT [DF_SZL_EPO] DEFAULT ((0)) NOT NULL,
    [SZL_PotwierdzenieDoreczenia]      TINYINT         CONSTRAINT [DF_SZL_PotwierdzenieDoreczenia] DEFAULT ((0)) NOT NULL,
    [SZL_PotwierdzenieDoreczeniaTyp]   TINYINT         CONSTRAINT [DF_SZL_PotwierdzenieDoreczeniaTyp] DEFAULT ((0)) NOT NULL,
    [SZL_UrzadNadaniaKod]              NVARCHAR (255)  CONSTRAINT [DF_SZL_UrzadNadaniaKod] DEFAULT ('') NOT NULL,
    [SZL_UrzadNadaniaAdres]            NVARCHAR (255)  CONSTRAINT [DF_SZL_UrzadNadaniaAdres] DEFAULT ('') NOT NULL,
    [SZL_PlikZlecenia]                 NVARCHAR (255)  CONSTRAINT [DF_SZL_PlikZlecenia] DEFAULT ('') NOT NULL,
    [SZL_NrTransakcjiOdbioru]          NVARCHAR (255)  CONSTRAINT [DF_SZL_NrTransakcjiOdbioru] DEFAULT ('') NOT NULL,
    [SZL_OpcjeDeklarowanaWartosc]      TINYINT         CONSTRAINT [DF_SZL_OpcjeDeklarowanaWartosc] DEFAULT ((0)) NOT NULL,
    [SZL_OpcjeDeklarowanaWartoscKwota] DECIMAL (15, 2) CONSTRAINT [DF_SZL_OpcjeDeklarowanaWartoscKwota] DEFAULT ((0)) NOT NULL,
    [SZL_OpiekunNazwa]                 NVARCHAR (100)  CONSTRAINT [DF_SZL_OpiekunNazwa] DEFAULT ('') NOT NULL,
    [SZL_AllegroTransactionId]         NVARCHAR (255)  CONSTRAINT [DF_SZL_AllegroTransactionId] DEFAULT ('') NOT NULL,
    [SZL_AllegroUserId]                NVARCHAR (255)  CONSTRAINT [DF_SZL_AllegroUserId] DEFAULT ('') NOT NULL,
    [SZL_DostawaWWeekend]              TINYINT         CONSTRAINT [DF_SZL_DostawaWWeekend] DEFAULT ((0)) NOT NULL,
    [SZL_DokZrodlowe]                  NVARCHAR (MAX)  CONSTRAINT [DF_SZL_DokZrodlowe] DEFAULT ('') NOT NULL,
    [SZL_DokZrodloweTyp]               INT             CONSTRAINT [DF_SZL_DokZrodloweTyp] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [SZL_Primary] PRIMARY KEY CLUSTERED ([SZL_SZLID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SZLDokDef] FOREIGN KEY ([SZL_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SZLNumer]
    ON [CDN].[SenditZleceniePrzesylki]([SZL_NumerString] ASC, [SZL_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER [CDN].[SenditZleceniePrzesylki_InsertUpdate_Trigger]
ON [CDN].[SenditZleceniePrzesylki]
FOR UPDATE
AS
  SET NOCOUNT ON
  Set ArithAbort On
  If Update (SZL_NrListuPrzewozowego)
  begin
    update CDN.TraNag set TrN_NrListuPrzewozowego =
 case when len(TrN_NrListuPrzewozowego) >0 then SUBSTRING(TrN_NrListuPrzewozowego + ','+ inserted.SZL_NrListuPrzewozowego, 0, 150)  else SUBSTRING(inserted.SZL_NrListuPrzewozowego, 0, 150) end,
  TrN_NrListuPrzewozowegoTypKuriera =
   case when inserted.SZL_TypKuriera = 1 then  7
    when inserted.SZL_TypKuriera = 2 then 7
    when inserted.SZL_TypKuriera = 3 then 4
    when inserted.SZL_TypKuriera = 4 and SZL_TypPaczkiDPD NOT IN(0,1)  then 6
    when inserted.SZL_TypKuriera = 4 and SZL_TypPaczkiDPD IN(0,1)  then 15
    when inserted.SZL_TypKuriera = 5 then 5
    when inserted.SZL_TypKuriera = 6 then 5
    else 0
   end
 FROM inserted
 join cdn.DokRelacje on DoR_DokumentTyp = 370 and DoR_DokumentId = inserted.SZL_SZLID
 Join CDN.TraNag  On TrN_TrNID = DoR_ParentId AND TrN_TypDokumentu = DoR_ParentTyp
 where len(inserted.SZL_NrListuPrzewozowego) > 0
 select * into #TmpIns from inserted
 exec [CDN].[RejestrOperacjiDodajEx]
 'TrN_TypDokumentu' ,
 '0' ,
 'TrN_TrNID' ,
 'TrN_NumerPelny' ,
 2 ,
 '''''',
 '#TmpIns
  join cdn.DokRelacje on DoR_DokumentTyp = 370 and DoR_DokumentId = #TmpIns.SZL_SZLID
  Join CDN.TraNag  On TrN_TrNID = DoR_ParentId AND TrN_TypDokumentu = DoR_ParentTyp',
 'len(#TmpIns.SZL_NrListuPrzewozowego) > 0'
  END
  Set NoCount Off

GO
CREATE TRIGGER CDN.SenditZleceniePrzesylki_Delete_Trigger
  ON CDN.SenditZleceniePrzesylki
  FOR DELETE
AS
  SET NOCOUNT ON
  Set ArithAbort On
--Sprawdzanie, czy dokument może byc skasowany
    IF EXISTS (SELECT * FROM deleted WHERE deleted.SZL_NumerZleceniaSendit <> '' )
        BEGIN
          RAISERROR('##OPT34535##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
 IF EXISTS (SELECT * FROM deleted WHERE deleted.SZL_NrListuPrzewozowego <> '' )
        BEGIN
          RAISERROR('##OPT34535##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
-- relacje do dokumentów
 DELETE CDN.DokRelacje FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=370 AND DoR_DokumentId IN (SELECT SZL_SZLId FROM deleted)
 DELETE CDN.DokRelacje FROM CDN.DokRelacje JOIN deleted ON DoR_ParentTyp=370   AND DoR_ParentId   IN (SELECT SZL_SZLId FROM deleted)
  Set NoCount Off
