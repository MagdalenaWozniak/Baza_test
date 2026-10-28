CREATE TABLE [CDN].[Towary] (
    [Twr_TwrId]                               INT             IDENTITY (1, 1) NOT NULL,
    [Twr_Typ]                                 TINYINT         NOT NULL,
    [Twr_Produkt]                             SMALLINT        NOT NULL,
    [Twr_Kod]                                 VARCHAR (50)    NOT NULL,
    [Twr_PLU]                                 NVARCHAR (18)   CONSTRAINT [DF_Twr_PLU] DEFAULT ('') NOT NULL,
    [Twr_NumerKat]                            NVARCHAR (40)   NOT NULL,
    [Twr_SWW]                                 VARCHAR (20)    NOT NULL,
    [Twr_EAN]                                 VARCHAR (40)    NOT NULL,
    [Twr_Nazwa]                               NVARCHAR (255)  NOT NULL,
    [Twr_NazwaFiskalna]                       NVARCHAR (40)   CONSTRAINT [DF_Twr_NazwaFiskalna] DEFAULT ('') NOT NULL,
    [Twr_TwGGIDNumer]                         INT             NOT NULL,
    [Twr_URL]                                 VARCHAR (254)   NOT NULL,
    [Twr_KatId]                               INT             NULL,
    [Twr_Kategoria]                           VARCHAR (50)    NOT NULL,
    [Twr_KatZakId]                            INT             NULL,
    [Twr_KategoriaZak]                        VARCHAR (50)    NOT NULL,
    [Twr_Opis]                                NVARCHAR (MAX)  NOT NULL,
    [Twr_EdycjaNazwy]                         TINYINT         NOT NULL,
    [Twr_KopiujOpis]                          TINYINT         NOT NULL,
    [Twr_EdycjaOpisu]                         TINYINT         NOT NULL,
    [Twr_JM]                                  NVARCHAR (20)   NOT NULL,
    [Twr_JMCalkowite]                         TINYINT         NOT NULL,
    [Twr_JMZ]                                 NVARCHAR (20)   CONSTRAINT [DF_Twr_JMZ] DEFAULT ('') NOT NULL,
    [Twr_JMPrzelicznikL]                      DECIMAL (15, 2) CONSTRAINT [DF_Twr_JMPrzelicznikL] DEFAULT ((1)) NOT NULL,
    [Twr_JMPrzelicznikM]                      DECIMAL (7)     CONSTRAINT [DF_Twr_JMPrzelicznikM] DEFAULT ((1)) NOT NULL,
    [Twr_Kaucja]                              TINYINT         NOT NULL,
    [Twr_TwCNumer]                            INT             NOT NULL,
    [Twr_UdostepniajWCenniku]                 TINYINT         NOT NULL,
    [Twr_Waluta]                              VARCHAR (3)     NOT NULL,
    [Twr_KursNumer]                           INT             NOT NULL,
    [Twr_KursL]                               DECIMAL (15, 4) NOT NULL,
    [Twr_KursM]                               DECIMAL (5)     NOT NULL,
    [Twr_MinCenaMarza]                        DECIMAL (15, 3) NOT NULL,
    [Twr_TypMinimum]                          TINYINT         NOT NULL,
    [Twr_KosztUslugiWal]                      DECIMAL (17, 4) NOT NULL,
    [Twr_KosztUslugi]                         DECIMAL (17, 4) NOT NULL,
    [Twr_KosztUslugiTyp]                      TINYINT         NOT NULL,
    [Twr_KosztKGO]                            DECIMAL (15, 2) CONSTRAINT [DF_Twr_KosztKGO] DEFAULT ((0)) NOT NULL,
    [Twr_SONId]                               INT             NULL,
    [Twr_KntId]                               INT             NULL,
    [Twr_KodDostawcy]                         NVARCHAR (50)   NOT NULL,
    [Twr_ProducentKod]                        NVARCHAR (50)   CONSTRAINT [DF_Twr_ProducentKod] DEFAULT ('') NOT NULL,
    [Twr_IloscMin]                            DECIMAL (15, 4) NOT NULL,
    [Twr_IloscMinJM]                          NVARCHAR (20)   NOT NULL,
    [Twr_IloscMax]                            DECIMAL (15, 4) NOT NULL,
    [Twr_IloscMaxJM]                          NVARCHAR (20)   NOT NULL,
    [Twr_IloscZam]                            DECIMAL (15, 4) NOT NULL,
    [Twr_IloscZamJM]                          NVARCHAR (20)   NOT NULL,
    [Twr_Stawka]                              DECIMAL (5, 2)  NOT NULL,
    [Twr_Flaga]                               SMALLINT        NOT NULL,
    [Twr_Zrodlowa]                            DECIMAL (5, 2)  NOT NULL,
    [Twr_StawkaExport]                        DECIMAL (5, 2)  NOT NULL,
    [Twr_FlagaExport]                         SMALLINT        NOT NULL,
    [Twr_ZrodlowaExport]                      DECIMAL (5, 2)  NOT NULL,
    [Twr_StawkaZak]                           DECIMAL (5, 2)  NOT NULL,
    [Twr_FlagaZak]                            SMALLINT        NOT NULL,
    [Twr_ZrodlowaZak]                         DECIMAL (5, 2)  NOT NULL,
    [Twr_Prog]                                TINYINT         NOT NULL,
    [Twr_Upust]                               TINYINT         NOT NULL,
    [Twr_UpustData]                           TINYINT         NOT NULL,
    [Twr_UpustDataOd]                         INT             NULL,
    [Twr_UpustDataDo]                         INT             NULL,
    [Twr_UpustGodz]                           TINYINT         NOT NULL,
    [Twr_UpustGodzOd]                         INT             NULL,
    [Twr_UpustGodzDo]                         INT             NULL,
    [Twr_BezRabatu]                           TINYINT         NOT NULL,
    [Twr_MarzaMin]                            DECIMAL (5, 2)  NOT NULL,
    [Twr_NieAktywny]                          TINYINT         NOT NULL,
    [Twr_ESklep]                              TINYINT         NULL,
    [Twr_KCNId]                               INT             NULL,
    [Twr_Masa]                                DECIMAL (15, 3) NOT NULL,
    [Twr_PrdID]                               INT             NULL,
    [Twr_MrkID]                               INT             NULL,
    [Twr_IGaleriaKatId]                       INT             NULL,
    [Twr_ESklepBezRabatu]                     SMALLINT        CONSTRAINT [DF_Twr_EsklepBezRabatu] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepStatus]                        SMALLINT        CONSTRAINT [DF_Twr_EsklepStatus] DEFAULT ((1)) NOT NULL,
    [Twr_ESklepDostepnosc]                    SMALLINT        CONSTRAINT [DF_Twr_EsklepDostepnosc] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepKalkulacjaDostaw]              TINYINT         CONSTRAINT [DF_Twr_ESklepKalkulacjaDostaw] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepKalkulacjaDostawWartosc]       DECIMAL (15, 2) CONSTRAINT [DF_Twr_ESklepKalkulacjaDostawWartosc] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFlaga_Nowosc]                  TINYINT         CONSTRAINT [DF_Twr_ESklepFlaga_Nowosc] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFlaga_Promocja]                TINYINT         CONSTRAINT [DF_Twr_ESklepFlaga_Promocja] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFlaga_ProduktzGazetki]         TINYINT         CONSTRAINT [DF_Twr_ESklepFlaga_ProduktzGazetki] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFlaga_ProduktPolecany]         TINYINT         CONSTRAINT [DF_Twr_ESklepFlaga_ProduktPolecany] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFlaga_Wyprzedaz]               TINYINT         CONSTRAINT [DF_Twr_ESklepFlaga_Wyprzedaz] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFlaga_SuperJakosc]             TINYINT         CONSTRAINT [DF_Twr_ESklepFlaga_SuperJakosc] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFlaga_SuperCena]               TINYINT         CONSTRAINT [DF_Twr_ESklepFlaga_SuperCena] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFlaga_NajlepiejOceniany]       TINYINT         CONSTRAINT [DF_Twr_ESklepFlaga_NajlepiejOceniany] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFlaga_RekomendacjaSprzedawcy]  TINYINT         CONSTRAINT [DF_Twr_ESklepFlaga_RekomendacjaSprzedawcy] DEFAULT ((0)) NOT NULL,
    [Twr_ESklepFantomID]                      INT             NULL,
    [Twr_WagaKG]                              DECIMAL (15, 4) CONSTRAINT [DF_Twr_WagaKG] DEFAULT ((0)) NULL,
    [Twr_KrajPochodzenia]                     NVARCHAR (2)    NOT NULL,
    [Twr_JmPomPrzelicznikL]                   DECIMAL (15, 2) NOT NULL,
    [Twr_JmPomPrzelicznikM]                   DECIMAL (7)     NOT NULL,
    [Twr_OpeZalID]                            INT             NULL,
    [Twr_StaZalId]                            INT             NULL,
    [Twr_TS_Zal]                              DATETIME        NOT NULL,
    [Twr_OpeModID]                            INT             NULL,
    [Twr_StaModId]                            INT             NULL,
    [Twr_TS_XL]                               DATETIME        NULL,
    [Twr_TS_Mod]                              DATETIME        NOT NULL,
    [Twr_GIDTyp]                              SMALLINT        NULL,
    [Twr_GIDFirma]                            INT             NULL,
    [Twr_GIDNumer]                            INT             NULL,
    [Twr_GIDLp]                               SMALLINT        NULL,
    [Twr_Akcyza]                              TINYINT         CONSTRAINT [DF_Twr_Akcyza] DEFAULT ((0)) NOT NULL,
    [Twr_AkcyzaJMPomPrzelicznikL]             DECIMAL (15, 2) CONSTRAINT [DF_Twr_AkcyzaJMPomPrzelicznikL] DEFAULT ((1)) NOT NULL,
    [Twr_AkcyzaJMPomPrzelicznikM]             INT             CONSTRAINT [DF_Twr_AkcyzaJMPomPrzelicznikM] DEFAULT ((1)) NOT NULL,
    [Twr_AkcyzaOpal]                          DECIMAL (15, 2) CONSTRAINT [DF_Twr_AkcyzaOpal] DEFAULT ((0)) NOT NULL,
    [Twr_AkcyzaStawka]                        DECIMAL (15, 2) CONSTRAINT [DF_Twr_AkcyzaStawka] DEFAULT ((0)) NOT NULL,
    [Twr_OdwrotneObciazenie]                  TINYINT         CONSTRAINT [DF_Twr_OdwrotneObciazenie] DEFAULT ((0)) NOT NULL,
    [Twr_Mobile]                              TINYINT         CONSTRAINT [DF_Twr_Mobile] DEFAULT ((1)) NOT NULL,
    [Twr_PobieranieSkladnikowFSUslugaZlozona] TINYINT         CONSTRAINT [DF_Twr_PobieranieSkladnikowFSUslugaZlozona] DEFAULT ((0)) NOT NULL,
    [TwR_KosztUslugiOld]                      DECIMAL (17, 4) CONSTRAINT [DF_TwR_KosztUslugiOld] DEFAULT ((0)) NOT NULL,
    [TwR_WalutaZakOld]                        VARCHAR (3)     CONSTRAINT [DF_TwR_WalutaZakOld] DEFAULT ('') NOT NULL,
    [TwR_KursLZakOld]                         DECIMAL (15, 4) CONSTRAINT [DF_TwR_KursLZakOld] DEFAULT ((0)) NOT NULL,
    [TwR_KursMZakOld]                         DECIMAL (5)     CONSTRAINT [DF_TwR_KursMZakOld] DEFAULT ((0)) NOT NULL,
    [Twr_OpeModKod]                           VARCHAR (20)    CONSTRAINT [DF_Twr_OpeModKod] DEFAULT ('') NOT NULL,
    [Twr_OpeModNazwisko]                      NVARCHAR (50)   CONSTRAINT [DF_Twr_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Twr_OpeZalKod]                           VARCHAR (20)    CONSTRAINT [DF_Twr_OpeZalKod] DEFAULT ('') NOT NULL,
    [Twr_OpeZalNazwisko]                      NVARCHAR (50)   CONSTRAINT [DF_Twr_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [Twr_CenaZCzteremaMiejscami]              TINYINT         CONSTRAINT [DF_Twr_CenaZCzteremaMiejscami] DEFAULT ((0)) NOT NULL,
    [Twr_AutoKodGrupaTowarowa]                TINYINT         CONSTRAINT [DF_Twr_AutoKodGrupaTowarowa] DEFAULT ((0)) NOT NULL,
    [Twr_AutoKodSeria]                        VARCHAR (40)    CONSTRAINT [DF_Twr_AutoKodSeria] DEFAULT ('') NOT NULL,
    [Twr_AutoKodWartosc]                      VARCHAR (50)    CONSTRAINT [DF_Twr_AutoKodWartosc] DEFAULT ('') NOT NULL,
    [Twr_AutoKodNumer]                        INT             CONSTRAINT [DF_Twr_AutoKodNumer] DEFAULT ((0)) NOT NULL,
    [Twr_Sent]                                TINYINT         CONSTRAINT [DF_Twr_Sent] DEFAULT ((0)) NOT NULL,
    [Twr_JMSentPrzelicznikL]                  DECIMAL (15, 2) CONSTRAINT [DF_Twr_JMSentPrzelicznikL] DEFAULT ((1)) NOT NULL,
    [Twr_JMSentPrzelicznikM]                  DECIMAL (7)     CONSTRAINT [DF_Twr_JMSentPrzelicznikM] DEFAULT ((1)) NOT NULL,
    [Twr_SentMasaBrutto]                      DECIMAL (15, 2) CONSTRAINT [DF_Twr_SentMasaBrutto] DEFAULT ((0)) NOT NULL,
    [Twr_SentKodOdpadu]                       NVARCHAR (6)    CONSTRAINT [DF_Twr_SentKodOdpadu] DEFAULT ('') NOT NULL,
    [Twr_SJRodzajPaliwa]                      NVARCHAR (500)  CONSTRAINT [DF_Twr_SJRodzajPaliwa] DEFAULT ('') NOT NULL,
    [Twr_SJSystemCertyfikacji]                NVARCHAR (500)  CONSTRAINT [DF_Twr_SJSystemCertyfikacji] DEFAULT ('') NOT NULL,
    [Twr_SJPopiol]                            NVARCHAR (15)   CONSTRAINT [DF_Twr_SJPopiol] DEFAULT ('') NOT NULL,
    [Twr_SJPopiolMin]                         NVARCHAR (10)   CONSTRAINT [DF_Twr_SJPopiolMin] DEFAULT ('') NOT NULL,
    [Twr_SJPopiolMax]                         NVARCHAR (10)   CONSTRAINT [DF_Twr_SJPopiolMax] DEFAULT ('') NOT NULL,
    [Twr_SJCzesciLotne]                       NVARCHAR (15)   CONSTRAINT [DF_Twr_SJCzesciLotne] DEFAULT ('') NOT NULL,
    [Twr_SJCzesciLotneMin]                    NVARCHAR (10)   CONSTRAINT [DF_Twr_SJCzesciLotneMin] DEFAULT ('') NOT NULL,
    [Twr_SJCzesciLotneMax]                    NVARCHAR (10)   CONSTRAINT [DF_Twr_SJCzesciLotneMax] DEFAULT ('') NOT NULL,
    [Twr_SJWartoscOpalowa]                    NVARCHAR (15)   CONSTRAINT [DF_Twr_SJWartoscOpalowa] DEFAULT ('') NOT NULL,
    [Twr_SJWartoscOpalowaMin]                 NVARCHAR (10)   CONSTRAINT [DF_Twr_SJWartoscOpalowaMin] DEFAULT ('') NOT NULL,
    [Twr_SJWartoscOpalowaMax]                 NVARCHAR (10)   CONSTRAINT [DF_Twr_SJWartoscOpalowaMax] DEFAULT ('') NOT NULL,
    [Twr_SJZdolnoscSpiekania]                 NVARCHAR (15)   CONSTRAINT [DF_Twr_SJZdolnoscSpiekania] DEFAULT ('') NOT NULL,
    [Twr_SJZdolnoscSpiekaniaMin]              NVARCHAR (10)   CONSTRAINT [DF_Twr_SJZdolnoscSpiekaniaMin] DEFAULT ('') NOT NULL,
    [Twr_SJZdolnoscSpiekaniaMax]              NVARCHAR (10)   CONSTRAINT [DF_Twr_SJZdolnoscSpiekaniaMax] DEFAULT ('') NOT NULL,
    [Twr_SJWymiarZiarna]                      NVARCHAR (15)   CONSTRAINT [DF_Twr_SJWymiarZiarna] DEFAULT ('') NOT NULL,
    [Twr_SJWymiarZiarnaMin]                   NVARCHAR (10)   CONSTRAINT [DF_Twr_SJWymiarZiarnaMin] DEFAULT ('') NOT NULL,
    [Twr_SJWymiarZiarnaMax]                   NVARCHAR (10)   CONSTRAINT [DF_Twr_SJWymiarZiarnaMax] DEFAULT ('') NOT NULL,
    [Twr_SJZawartoscPodziarna]                NVARCHAR (15)   CONSTRAINT [DF_Twr_SJZawartoscPodziarna] DEFAULT ('') NOT NULL,
    [Twr_SJZawartoscPodziarnaMin]             NVARCHAR (10)   CONSTRAINT [DF_Twr_SJZawartoscPodziarnaMin] DEFAULT ('') NOT NULL,
    [Twr_SJZawartoscPodziarnaMax]             NVARCHAR (10)   CONSTRAINT [DF_Twr_SJZawartoscPodziarnaMax] DEFAULT ('') NOT NULL,
    [Twr_SJZawartoscNadziarna]                NVARCHAR (15)   CONSTRAINT [DF_Twr_SJZawartoscNadziarna] DEFAULT ('') NOT NULL,
    [Twr_SJZawartoscNadziarnaMin]             NVARCHAR (10)   CONSTRAINT [DF_Twr_SJZawartoscNadziarnaMin] DEFAULT ('') NOT NULL,
    [Twr_SJZawartoscNadziarnaMax]             NVARCHAR (10)   CONSTRAINT [DF_Twr_SJZawartoscNadziarnaMax] DEFAULT ('') NOT NULL,
    [Twr_SJZawartoscWilgoci]                  NVARCHAR (15)   CONSTRAINT [DF_Twr_SJZawartoscWilgoci] DEFAULT ('') NOT NULL,
    [Twr_SJZawartoscWilgociMin]               NVARCHAR (10)   CONSTRAINT [DF_Twr_SJZawartoscWilgociMin] DEFAULT ('') NOT NULL,
    [Twr_SJZawartoscWilgociMax]               NVARCHAR (10)   CONSTRAINT [DF_Twr_SJZawartoscWilgociMax] DEFAULT ('') NOT NULL,
    [Twr_SplitPay]                            TINYINT         CONSTRAINT [DF_Twr_SplitPay] DEFAULT ((0)) NOT NULL,
    [Twr_KV7ID]                               INT             CONSTRAINT [DF_Twr_KV7ID] DEFAULT ((0)) NOT NULL,
    [Twr_OpiekunID]                           INT             NULL,
    [Twr_OpiekunTyp]                          SMALLINT        NULL,
    [Twr_JMWysCm]                             SMALLINT        NULL,
    [Twr_JMSzerCm]                            SMALLINT        NULL,
    [Twr_JMDlugCm]                            SMALLINT        NULL,
    CONSTRAINT [Twr_Primary] PRIMARY KEY CLUSTERED ([Twr_TwrId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwrDostawca] FOREIGN KEY ([Twr_KntId]) REFERENCES [CDN].[Kontrahenci] ([Knt_KntId]),
    CONSTRAINT [FK_Twrkategoria] FOREIGN KEY ([Twr_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_TwrKategoriaZak] FOREIGN KEY ([Twr_KatZakId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_TwrKodCN] FOREIGN KEY ([Twr_KCNId]) REFERENCES [CDN].[KodyCN] ([KCN_KCNId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwrKod]
    ON [CDN].[Towary]([Twr_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwrGrupKod]
    ON [CDN].[Towary]([Twr_TwGGIDNumer] ASC, [Twr_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwrEAN]
    ON [CDN].[Towary]([Twr_EAN] ASC, [Twr_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwrNrKat]
    ON [CDN].[Towary]([Twr_NumerKat] ASC, [Twr_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwrNazwa]
    ON [CDN].[Towary]([Twr_Nazwa] ASC, [Twr_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrGrupaDomyslna]
    ON [CDN].[Towary]([Twr_TwGGIDNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [Twrkategoria]
    ON [CDN].[Towary]([Twr_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrKategoriaZak]
    ON [CDN].[Towary]([Twr_KatZakId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrProduktTyp]
    ON [CDN].[Towary]([Twr_Produkt] ASC, [Twr_Typ] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrNieaktywne]
    ON [CDN].[Towary]([Twr_NieAktywny] ASC)
    INCLUDE([Twr_TwrId], [Twr_Kod], [Twr_Typ], [Twr_Produkt], [Twr_GIDNumer]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrGIDNumer]
    ON [CDN].[Towary]([Twr_GIDNumer] ASC)
    INCLUDE([Twr_TwrId], [Twr_Kod], [Twr_Typ], [Twr_Produkt]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrDostawca]
    ON [CDN].[Towary]([Twr_KntId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwrKodDostawcy]
    ON [CDN].[Towary]([Twr_KodDostawcy] ASC, [Twr_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrGID]
    ON [CDN].[Towary]([Twr_GIDTyp] ASC, [Twr_GIDNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrKodCN]
    ON [CDN].[Towary]([Twr_KCNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrSON]
    ON [CDN].[Towary]([Twr_SONId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrProducent]
    ON [CDN].[Towary]([Twr_PrdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrMarka]
    ON [CDN].[Towary]([Twr_MrkID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrIGaleriaKategoria]
    ON [CDN].[Towary]([Twr_IGaleriaKatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwrGridLookupFilter]
    ON [CDN].[Towary]([Twr_Kod] ASC, [Twr_TwrId] ASC)
    INCLUDE([Twr_NieAktywny], [Twr_Nazwa], [Twr_EAN]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwrAutoKodNr]
    ON [CDN].[Towary]([Twr_AutoKodSeria] ASC, [Twr_AutoKodNumer] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.Towary_Delete_Trigger
  On CDN.Towary
  For Delete
As
Set NoCount On
-- Sprawdzenie, czy towar nie jest wzięty na urządzenie
  IF EXISTS (SELECT * FROM cdn.SrsUrzadzenia  JOIN deleted ON SrU_TwrId=deleted.Twr_TwrId)
    BEGIN
      RAISERROR('##OPT34553##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy towar nie jest wzięty na zlecenie
  IF EXISTS (SELECT * FROM cdn.SrsZlecenia JOIN deleted ON SrZ_ZbiorczeTwrIdCzesci=deleted.Twr_TwrId WHERE SrZ_ZbiorczeFaCzesci=1)
  OR EXISTS (SELECT * FROM cdn.SrsZlecenia JOIN deleted ON SrZ_ZbiorczeTwrIdCzynnosci=deleted.Twr_TwrId WHERE SrZ_ZbiorczeFaCzynnosci=1)
    BEGIN
      RAISERROR('##OPT34554##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (SELECT * FROM cdn.SrsCzesci  JOIN deleted ON SrC_TwrId=deleted.Twr_TwrId)
    BEGIN
      RAISERROR('##OPT34554##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (SELECT * FROM cdn.SrsCzynnosci JOIN deleted ON SrY_TwrId=deleted.Twr_TwrId)
    BEGIN
      RAISERROR('##OPT34554##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy towar nie jest wysłany do ESklepu
  IF EXISTS (SELECT * FROM deleted where Twr_GidFirma = 1)
    BEGIN
      if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 ) and exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1)
  RAISERROR('##OPT34555##', 16, 1)
      else
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 )
   RAISERROR('##OPT34556##', 16, 1)
      else
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1 )
   RAISERROR('##OPT34557##', 16, 1)
      else
  RAISERROR('##OPT34555##', 16, 1)
      --RAISERROR('Pozycja cennika nie może być wykasowana. Nie można usunąć towaru, który został wysłany do E-Sklepu.', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy towar nie jest wysłany do detalu
  IF EXISTS (SELECT * FROM deleted where Twr_GidFirma = 2)
    BEGIN
      RAISERROR('##OPT34558##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  IF EXISTS (SELECT * FROM cdn.ZestawyTwrSkladniki  JOIN deleted ON ZTS_TwrId=deleted.Twr_TwrId)
    BEGIN
      RAISERROR('##OPT34559##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy towar nie jest wykorzystany na ofercie
  IF EXISTS (SELECT * FROM cdn.OfertyElem  JOIN deleted ON OfL_TwrId=deleted.Twr_TwrId)
    BEGIN
      RAISERROR('##OPT34560##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
   IF EXISTS (SELECT * FROM cdn.OfertyElemCeny  JOIN deleted ON OfC_TwrId=deleted.Twr_TwrId)
    BEGIN
      RAISERROR('##OPT34560##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy towar nie jest zamiennikiem
 IF EXISTS (SELECT * FROM cdn.Zamienniki  JOIN deleted ON deleted.Twr_TwrId = ZAM_TwrId) or EXISTS (SELECT * FROM cdn.Zamienniki  JOIN deleted ON deleted.Twr_TwrId = ZAM_ZamTwrId)
    BEGIN
      RAISERROR('##OPT34561##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- obsługa kasowania rabatow dla towarów
Delete From CDN.Rabaty Where
 Rab_Typ In (4, 6, 8, 11, 12, 13) And
 Rab_TwrId In (Select Twr_TwrId From deleted)
Delete From CDN.TwrGrupy
Where TwG_GIDTyp = 16
 AND TwG_Kod In (Select Twr_Kod From deleted)
-- obsługa kaskadowego kasowania przywiązania towaru do grup
 DELETE CDN.TwrGrupy
    FROM CDN.TwrGrupy, deleted
    WHERE
   TwG_GIDTyp  = 16
  AND TwG_Kod  = deleted.Twr_Kod
-- obsługa kasowania z wzorca faktur cyklicznych
DELETE CDN.FaCyklTwrKnt FROM CDN.FaCyklTwrKnt A JOIN CDN.FaCyklElem B ON  A.FcT_FcEId=B.FCE_FcEID
WHERE FcE_TwrId In (Select Twr_TwrId From deleted)
Delete From CDN.FaCyklElem Where FcE_TwrId In (Select Twr_TwrId From deleted)
-- obsługa kasowania załączników
DELETE FROM CDN.DaneBinarneLinki WHERE DBL_TwrId IN (SELECT Twr_TwrId FROM deleted)
 -- Usuwanie wymiarów analitycznych
  DECLARE @WADokumentTyp int = 0;
  select @WADokumentTyp=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Towary';
 if exists(select * from CDN.WymiaryWartosci where WyW_DokumentTyp = @WADokumentTyp and WyW_DokumentId in (select deleted.Twr_TwrId from deleted))
  delete from CDN.WymiaryWartosci where WyW_DokumentTyp = @WADokumentTyp
  and WyW_DokumentId in (select deleted.Twr_TwrId from deleted)
Set NoCount Off

GO
CREATE TRIGGER CDN.Towary_DeleteHandler
  ON CDN.Towary
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.TwrJm INNER JOIN deleted
   ON deleted.Twr_GIDTyp = CDN.TwrJm.TwJ_TwrTyp
   AND deleted.Twr_GIDFirma = CDN.TwrJm.TwJ_TwrFirma
   AND deleted.Twr_GIDNumer = CDN.TwrJm.TwJ_TwrNumer
  )
  DELETE CDN.TwrJm
  FROM CDN.TwrJm, deleted
  WHERE
   deleted.Twr_GIDTyp = CDN.TwrJm.TwJ_TwrTyp
  AND deleted.Twr_GIDFirma = CDN.TwrJm.TwJ_TwrFirma
  AND deleted.Twr_GIDNumer = CDN.TwrJm.TwJ_TwrNumer
    IF EXISTS(
   SELECT * FROM CDN.TwrDost INNER JOIN deleted
   ON deleted.Twr_GIDTyp = CDN.TwrDost.TWD_TwrTyp
   AND deleted.Twr_GIDFirma = CDN.TwrDost.TWD_TwrFirma
   AND deleted.Twr_GIDNumer = CDN.TwrDost.TWD_TwrNumer
  )
  DELETE CDN.TwrDost
  FROM CDN.TwrDost, deleted
  WHERE
   deleted.Twr_GIDTyp = CDN.TwrDost.TWD_TwrTyp
  AND deleted.Twr_GIDFirma = CDN.TwrDost.TWD_TwrFirma
  AND deleted.Twr_GIDNumer = CDN.TwrDost.TWD_TwrNumer
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Towary_After_Insert_Trigger
ON CDN.Towary
AFTER INSERT
AS
 SET NOCOUNT ON
 declare @dokumentTypGrupuTowarowe int = 0;
 select @dokumentTypGrupuTowarowe = ID from CDN.ListaDokumentowWymiarowanych() where nazwa = 'Grupy towarowe';
 declare @dokumentTypTowary int = 0;
 select @dokumentTypTowary = ID from CDN.ListaDokumentowWymiarowanych() where nazwa = 'Towary';
  declare @ID int
  declare @GrupaGIDNUmer int
  declare @twgID int
 DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR
 SELECT TwR_TwRID, Twr_TwGGIDNumer FROM inserted
 OPEN Dodane
 WHILE 1=1
 begin
  FETCH NEXT FROM Dodane INTO @ID, @GrupaGIDNUmer
  IF @@FETCH_STATUS <> 0 BREAK
  select @twgID=TwG_TwGID from CDN.TwrGrupy where TwG_GIDNumer = @GrupaGIDNUmer and TwG_GIDTyp = -16
  if @twgID is not null
  begin
   insert into CDN.WymiaryWartosci (WyW_WyyId, WyW_Guid, WyW_Wartosc, WyW_DokumentTyp, WyW_DokumentId, WyW_Procent, WyW_Kwota, WyW_SlownikId)
   select WyW_WyyId, WyW_Guid, WyW_Wartosc, @dokumentTypTowary, @ID, WyW_Procent, WyW_Kwota, WyW_SlownikId from CDN.WymiaryWartosci
   where  WyW_DokumentTyp = @dokumentTypGrupuTowarowe and WyW_DokumentId = @twgID
   order by WyW_Guid;
  end
 end
 Close Dodane
 Deallocate Dodane
 SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Towary_InsertUpdate_Trigger
ON CDN.Towary
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
declare
@Kod NVarchar(40),
@JM NVarchar(20),
@Komunikat NVarchar(555)
  If Update (Twr_Kod) Or Update (Twr_EAN)
    Begin
      If Exists (
        Select * From inserted A, CDN.Towary B Where
          A.Twr_EAN   = B.Twr_EAN And A.Twr_EAN <> '' And
           A.Twr_TwrId   <> B.Twr_TwrId)
   Or Exists (
         Select * From inserted A, CDN.TwrEAN B Where
          A.Twr_EAN   = B.TwE_EAN And A.Twr_EAN <> '' And
           A.Twr_TwrId   <> B.TwE_TwrId)
      Or Exists (
        Select * From inserted A, CDN.Towary B Where
           A.Twr_EAN   = B.Twr_Kod And
           A.Twr_TwrId   <> B.Twr_TwrId)
      Or Exists (
        Select * From inserted A, CDN.Towary B Where
           A.Twr_Kod   = B.Twr_EAN And
           A.Twr_TwrId   <> B.Twr_TwrId)
     Or Exists (
        Select * From inserted A, CDN.TwrEAN B Where
           A.Twr_Kod   = B.TwE_EAN And
           A.Twr_TwrId   <> B.TwE_TwrId)
        Begin
          RaisError ('##OPT32345##', 16,1)
          RollBack Tran
          Return
        End
    End
  If Update (Twr_NumerKat) And Not Exists (Select * From CDN.Firma Where Fir_Numer=1470 And Fir_Wartosc='4')
    Begin
      If Exists (
        Select * From inserted A, CDN.Towary B Where
          A.Twr_NumerKat  = B.Twr_NumerKat And
          A.Twr_NumerKat <> '' And
          A.Twr_TwrId    <> B.Twr_TwrId)
        Begin
          RaisError ('##OPT34551##', 16,1)
          RollBack Tran
          Return
        End
    End
-- Sprawdzanie flagi esklep towaru i zestawu
-- Sprawdzanie duplikacji identyfikatora GID
IF UPDATE (Twr_JM)
  BEGIN
    UPDATE CDN.ProdSkladniki SET PdS_JM = inserted.Twr_JM
    FROM inserted
    JOIN deleted ON inserted.Twr_TwrId = deleted.Twr_TwrId
    JOIN CDN.ProdSkladniki ON CDN.ProdSkladniki.PdS_TwrId = inserted.Twr_TwrId
    WHERE CDN.ProdSkladniki.PdS_JM = deleted.Twr_JM
 UPDATE CDN.ZestawyTwrSkladniki SET ZTS_Jm = inserted.Twr_JM
    FROM inserted
    JOIN deleted ON inserted.Twr_TwrId = deleted.Twr_TwrId
    JOIN CDN.ZestawyTwrSkladniki ON CDN.ZestawyTwrSkladniki.ZTS_TwrId = inserted.Twr_TwrId
    WHERE CDN.ZestawyTwrSkladniki.ZTS_JM = deleted.Twr_JM
  END
If Update (Twr_KosztUslugiWal) Or Update (Twr_Waluta)
  Update CDN.TwrCeny Set
    TwC_Wartosc = Twr_KosztUslugiWal, TwC_Waluta  = Twr_Waluta
  From inserted
  Join CDN.TwrCeny On Twr_TwrId = TwC_TwrId
  Where Twr_Typ = 0 And Twr_KosztUslugiTyp = 1
    And (TwC_Wartosc <> Twr_KosztUslugiWal Or TwC_Waluta <> Twr_Waluta)
    And TwC_TwCNumer = 1
If Not Exists (Select * From CDN.Firma Where Fir_Numer=1470 And Fir_Wartosc='4')
UPDATE CDN.Towary SET Twr_GIDNumer = Twr_TwrID WHERE Twr_TwrID IN (SELECT Twr_TwrID FROM inserted)
-- Aktualizacja FaCyklElem
If Update (Twr_Kod)
 Update CDN.FaCyklElem SET FcE_Kod = Twr_Kod From inserted B Join CDN.FaCyklElem  On FcE_TwrId = B.Twr_TwrId
/*  DECLARE
    -- zmienne pomocnicze dla kursora
    @Twr_TwrId       INT,
    @Twr_KosztUslugi DECIMAL(15,2)
  SET NOCOUNT ON
  DECLARE T CURSOR LOCAL FAST_FORWARD FOR
    SELECT B.Twr_TwrId, B.Twr_KosztUslugi
      FROM deleted A JOIN inserted B ON A.Twr_TwrId = B.Twr_TwrId
      WHERE B.Twr_Typ = 0 AND A.Twr_KosztUslugi <> B.Twr_KosztUslugi
    OPEN T
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM T INTO @Twr_TwrId, @Twr_KosztUslugi
        IF @@FETCH_STATUS <> 0 BREAK
          UPDATE cdn.TwrCeny  SET TwC_Wartosc = @Twr_KosztUslugi  WHERE TwC_TwrId = @Twr_TwrId AND TwC_TwCNumer = 1
      END
    CLOSE T
  DEALLOCATE T
*/
 if UPDATE(Twr_ESklepFantomID)
    begin
    If Exists (
        Select * From inserted Where Twr_TwrId = Twr_ESklepFantomID and ISNULL(Twr_ESklepFantomID,0)>0
         )
        begin
            RaisError ('##OPT34552##', 16,1)
            RollBack Tran
            Return
        end
    end
 If Update (Twr_nieaktywny) or  Update (Twr_ESklepFantomID)
    begin
      update cdn.danebinarne set dab_ts_mod = getdate()
       where dab_dabid in (select twa_dabid from cdn.twratrybuty where not twa_dabid is null and twa_twrid in (select twr_twrid from inserted where Twr_nieaktywny = 0))
   update cdn.twrgrupy set TwG_GIDNumer = TwG_GIDNumer
       where TwG_GIDNumer in (select twr_twrid from inserted join cdn.TwrESklep on Twes_TwrID = twr_twrid where Twes_udostepnij = 1 and Twr_nieaktywny = 0) and TwG_GIDTyp = 16
    end
  If Update (Twr_nieaktywny)
    begin
     update cdn.twrgrupy set TwG_GIDNumer = TwG_GIDNumer
   where TwG_GIDNumer in (select twr_twrid from cdn.Towary where Twr_ESklepFantomID in (select twr_twrid from inserted where Twr_NieAktywny = 1)) and TwG_GIDTyp = 16
     update Twr  set TwTS_TS_ModESklep = GETDATE() from CDN.TwrTSModEsklep Twr
     join cdn.Towary on TwTS_TwrId = Twr_TwrId
   where Twr_ESklepFantomID in (select twr_twrid from inserted where Twr_NieAktywny = 1)
     insert into  CDN.TwrTSModEsklep
     select Twr_TwrId,GETDATE() from cdn.towary
     left join CDN.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
   where TwTS_TwrId is null and Twr_ESklepFantomID in (select twr_twrid from inserted where Twr_NieAktywny = 1)
  update cdn.Towary set Twr_ESklepFantomID = null/*,Twr_ts_mod = getdate()*/  where Twr_ESklepFantomID in (select twr_twrid from inserted where Twr_NieAktywny = 1)
    end
 If Update (Twr_CenaZCzteremaMiejscami)
    begin
     update cdn.rabaty set rab_cena = round(rab_cena,2) where Rab_Typ in(11,12,13)and Rab_TwrId
     in (select twr_twrid from inserted where Twr_CenaZCzteremaMiejscami = 0)
     update cdn.ZestawyTwr set ZTw_Wartosc= round(ZTw_Wartosc,2),ZTw_TS_Mod = getdate() where ZTw_TypRabatu = 1 and ZTw_TwrId
     in (select twr_twrid from inserted where Twr_CenaZCzteremaMiejscami = 0)
     update cdn.ZestawyTwrSkladniki set ZTs_Wartosc= round(ZTs_Wartosc,2) where ZTs_TypRabatu in (1,2) and ZTS_TwrId
     in (select twr_twrid from inserted where Twr_CenaZCzteremaMiejscami = 0)
    end
  SET NOCOUNT OFF
