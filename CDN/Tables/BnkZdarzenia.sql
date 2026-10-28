CREATE TABLE [CDN].[BnkZdarzenia] (
    [BZd_BZdID]                     INT             IDENTITY (1, 1) NOT NULL,
    [BZd_RelTyp]                    SMALLINT        NULL,
    [BZd_RelID]                     INT             NULL,
    [BZd_PrwTyp]                    SMALLINT        NULL,
    [BZd_PrwID]                     INT             NULL,
    [BZd_BRaID]                     INT             NULL,
    [BZd_DDfID]                     INT             NULL,
    [BZd_DokumentTyp]               SMALLINT        NULL,
    [BZd_DokumentID]                INT             NULL,
    [BZd_NumerPelny]                NVARCHAR (256)  NOT NULL,
    [BZd_NumerObcy]                 NVARCHAR (256)  NOT NULL,
    [BZd_PodmiotTyp]                SMALLINT        NOT NULL,
    [BZd_PodmiotID]                 INT             NOT NULL,
    [BZd_PodmiotRachunekLp]         INT             NOT NULL,
    [BZd_BNaID]                     INT             NULL,
    [BZd_RachunekNr]                NVARCHAR (51)   NOT NULL,
    [BZd_IBAN]                      SMALLINT        NOT NULL,
    [BZd_KatID]                     INT             NULL,
    [BZd_FPlId]                     INT             NULL,
    [BZd_DataDok]                   DATETIME        NOT NULL,
    [BZd_Termin]                    DATETIME        NOT NULL,
    [BZd_DataReal]                  DATETIME        NOT NULL,
    [BZd_KwotaSys]                  DECIMAL (15, 2) NOT NULL,
    [BZd_KwotaRozSys]               DECIMAL (15, 2) NOT NULL,
    [BZd_Kwota]                     DECIMAL (15, 2) NOT NULL,
    [BZd_KwotaRoz]                  DECIMAL (15, 2) NOT NULL,
    [BZd_Waluta]                    VARCHAR (3)     NOT NULL,
    [BZd_WalutaDok]                 VARCHAR (3)     NOT NULL,
    [BZd_KursNumer]                 INT             NOT NULL,
    [BZd_KursL]                     DECIMAL (15, 4) NOT NULL,
    [BZd_KursM]                     DECIMAL (5)     NOT NULL,
    [BZd_DataRoz]                   DATETIME        NULL,
    [BZd_Kierunek]                  SMALLINT        NOT NULL,
    [BZd_DataKur]                   DATETIME        NOT NULL,
    [BZd_Zwloka]                    SMALLINT        NOT NULL,
    [BZd_Priorytet]                 SMALLINT        NOT NULL,
    [BZd_Rozliczono]                SMALLINT        NOT NULL,
    [BZd_Rozliczono2]               SMALLINT        NOT NULL,
    [BZd_Stan]                      SMALLINT        NOT NULL,
    [BZd_NieNaliczajOdsetek]        TINYINT         CONSTRAINT [DF_BZd_NieNaliczajOdsetek] DEFAULT ((0)) NOT NULL,
    [BZd_ElixirO1]                  VARCHAR (35)    NOT NULL,
    [BZd_ElixirO2]                  VARCHAR (35)    NOT NULL,
    [BZd_ElixirO3]                  VARCHAR (35)    NOT NULL,
    [BZd_ElixirO4]                  VARCHAR (35)    NOT NULL,
    [BZd_Opis]                      NVARCHAR (254)  NOT NULL,
    [BZd_KontoPrzeciwstawne]        NVARCHAR (50)   NOT NULL,
    [BZd_OpeWysId]                  INT             NULL,
    [BZd_TS_Wys]                    DATETIME        NULL,
    [BZd_OpePotwId]                 INT             NULL,
    [BZd_TS_Potw]                   DATETIME        NULL,
    [BZd_TS_Export]                 DATETIME        NULL,
    [BZd_ImportAppId]               VARCHAR (5)     NULL,
    [BZd_ImportRowId]               VARCHAR (36)    NULL,
    [BZd_IdSynchro]                 INT             NULL,
    [BZd_TypDokumentuKB]            AS              ((1)),
    [BZd_OpeZalId]                  INT             NULL,
    [BZd_CDCIdent]                  NVARCHAR (255)  NULL,
    [BZd_CDCDataWyslania]           DATETIME        NULL,
    [BZd_CDCOpeID]                  INT             NULL,
    [BZd_CDCKodKomunikatu]          NVARCHAR (8)    NULL,
    [BZd_CDCKomunikat]              NVARCHAR (255)  NULL,
    [BZd_CDCDataKomunikatu]         DATETIME        NULL,
    [BZd_Srw]                       SMALLINT        NULL,
    [Bzd_WindykacjaSchematId]       INT             NULL,
    [BZd_StaZalId]                  INT             NULL,
    [BZd_TS_Zal]                    DATETIME        NOT NULL,
    [BZd_StaModId]                  INT             NULL,
    [BZd_OpeModId]                  INT             NULL,
    [BZd_TS_Mod]                    DATETIME        NOT NULL,
    [BZd_KomornikZajecieWynagr]     TINYINT         CONSTRAINT [DF_BZd_KomornikZajecieWynagr] DEFAULT ((0)) NOT NULL,
    [BZd_PrzelewSEPA]               TINYINT         CONSTRAINT [DF_BZd_PrzelewSEPA] DEFAULT ((0)) NOT NULL,
    [BZd_OpeModKod]                 VARCHAR (20)    CONSTRAINT [DF_BZd_OpeModKod] DEFAULT ('') NOT NULL,
    [BZd_OpeModNazwisko]            NVARCHAR (50)   CONSTRAINT [DF_BZd_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BZd_OpeZalKod]                 VARCHAR (20)    CONSTRAINT [DF_BZd_OpeZalKod] DEFAULT ('') NOT NULL,
    [BZd_OpeZalNazwisko]            NVARCHAR (50)   CONSTRAINT [DF_BZd_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [BZd_ExpImpID]                  VARCHAR (13)    NULL,
    [BZd_URaID]                     INT             NULL,
    [BZd_CDCIdentPrzelewuBank]      NVARCHAR (35)   NULL,
    [BZd_SplitPay]                  TINYINT         CONSTRAINT [DF_BZd_SplitPay] DEFAULT ((0)) NOT NULL,
    [BZd_SplitPayNipE]              NVARCHAR (20)   NULL,
    [BZd_SplitPayKwotaVAT]          DECIMAL (15, 2) NULL,
    [BZd_SplitPayNrDok]             NVARCHAR (30)   NULL,
    [BZd_CDCSendPaymentsXMLRequest] NVARCHAR (MAX)  NULL,
    [BZd_TerminR]                   DATETIME        NULL,
    [BZd_WeryfRach_IdOdpytania]     NVARCHAR (16)   NULL,
    [BZd_DataWys]                   DATETIME        NULL,
    [BZd_Numer]                     AS              (case when [BZD_NUMEROBCY]<>'' then [BZD_NUMEROBCY] when [BZD_NUMERPELNY]<>'' then [BZD_NUMERPELNY] else CONVERT([nvarchar](256),[BZD_OPIS],(0)) end),
    CONSTRAINT [BZd_Primary] PRIMARY KEY CLUSTERED ([BZd_BZdID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_BZd_Kierunek] CHECK ([BZD_KIERUNEK]=(1) OR [BZD_KIERUNEK]=(0) OR [BZD_KIERUNEK]=(-1)),
    CONSTRAINT [CK_BZd_Kwota] CHECK ([BZD_KWOTA]>(0)),
    CONSTRAINT [CK_BZd_KwotaRoz] CHECK ([BZD_KWOTAROZ]>=(0)),
    CONSTRAINT [CK_BZd_KwotaRozSys] CHECK ([BZD_KWOTAROZSYS]>=(0)),
    CONSTRAINT [CK_BZd_KwotaSys] CHECK ([BZD_KWOTASYS]>(0)),
    CONSTRAINT [FK_BRpPlatnosc] FOREIGN KEY ([BZd_FPlId]) REFERENCES [CDN].[FormyPlatnosci] ([FPl_FPlId]),
    CONSTRAINT [FK_BZdBank] FOREIGN KEY ([BZd_BNaID]) REFERENCES [CDN].[BnkNazwy] ([BNa_BNaId]),
    CONSTRAINT [FK_BZdDokDefinicja] FOREIGN KEY ([BZd_DDfID]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_BZdKategoria] FOREIGN KEY ([BZd_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_BZdPodmiot] FOREIGN KEY ([BZd_PodmiotID], [BZd_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_BZdRachunek] FOREIGN KEY ([BZd_BRaID]) REFERENCES [CDN].[BnkRachunki] ([BRa_BRaID]),
    CONSTRAINT [FK_BZdUrzRachunek] FOREIGN KEY ([BZd_URaID]) REFERENCES [CDN].[UrzRachunki] ([URa_URaId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdDataReal]
    ON [CDN].[BnkZdarzenia]([BZd_Rozliczono] ASC, [BZd_DataReal] ASC, [BZd_BZdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdDataReal2]
    ON [CDN].[BnkZdarzenia]([BZd_Rozliczono2] ASC, [BZd_DataReal] ASC, [BZd_BZdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdRachunek]
    ON [CDN].[BnkZdarzenia]([BZd_BRaID] ASC, [BZd_Rozliczono] ASC, [BZd_DataReal] ASC, [BZd_BZdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdRachunek2]
    ON [CDN].[BnkZdarzenia]([BZd_BRaID] ASC, [BZd_Rozliczono2] ASC, [BZd_DataReal] ASC, [BZd_BZdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdPodmiot]
    ON [CDN].[BnkZdarzenia]([BZd_PodmiotID] ASC, [BZd_PodmiotTyp] ASC, [BZd_Rozliczono] ASC, [BZd_DataReal] ASC, [BZd_BZdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdPodmiot2]
    ON [CDN].[BnkZdarzenia]([BZd_PodmiotID] ASC, [BZd_PodmiotTyp] ASC, [BZd_Rozliczono2] ASC, [BZd_DataReal] ASC, [BZd_BZdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdKntLista]
    ON [CDN].[BnkZdarzenia]([BZd_PodmiotTyp] ASC, [BZd_Kierunek] ASC, [BZd_Rozliczono] ASC, [BZd_DataReal] ASC)
    INCLUDE([BZd_PodmiotID], [BZd_KwotaSys], [BZd_KwotaRozSys], [BZd_Waluta]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdBank]
    ON [CDN].[BnkZdarzenia]([BZd_BNaID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdFormaPl]
    ON [CDN].[BnkZdarzenia]([BZd_FPlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdKategoria2]
    ON [CDN].[BnkZdarzenia]([BZd_KatID] ASC, [BZd_Rozliczono2] ASC, [BZd_DataReal] ASC, [BZd_BZdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdDokDefinicja]
    ON [CDN].[BnkZdarzenia]([BZd_DDfID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdKategoria]
    ON [CDN].[BnkZdarzenia]([BZd_KatID] ASC, [BZd_Rozliczono] ASC, [BZd_DataReal] ASC, [BZd_BZdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdZrodlo]
    ON [CDN].[BnkZdarzenia]([BZd_DokumentID] ASC, [BZd_DokumentTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdPierwotny]
    ON [CDN].[BnkZdarzenia]([BZd_PrwID] ASC, [BZd_PrwTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdGUID]
    ON [CDN].[BnkZdarzenia]([BZd_ImportRowId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [BZdPodWalKierRoz]
    ON [CDN].[BnkZdarzenia]([BZd_PodmiotTyp] ASC, [BZd_PodmiotID] ASC, [BZd_Waluta] ASC, [BZd_Kierunek] ASC, [BZd_Rozliczono] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdDokTyp]
    ON [CDN].[BnkZdarzenia]([BZd_DokumentTyp] ASC)
    INCLUDE([BZd_BZdID], [BZd_DokumentID], [BZd_FPlId], [BZd_Termin], [BZd_KwotaSys]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdBRaKierRozReal]
    ON [CDN].[BnkZdarzenia]([BZd_BRaID] ASC, [BZd_Kierunek] ASC, [BZd_Rozliczono] ASC, [BZd_DataReal] ASC)
    INCLUDE([BZd_PodmiotTyp], [BZd_KwotaSys], [BZd_KwotaRozSys]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdBRaRozDokStan]
    ON [CDN].[BnkZdarzenia]([BZd_BRaID] ASC, [BZd_Rozliczono] ASC, [BZd_DokumentTyp] ASC, [BZd_Stan] ASC)
    INCLUDE([BZd_DDfID], [BZd_PodmiotTyp], [BZd_PodmiotID], [BZd_DataDok], [BZd_Termin], [BZd_KwotaSys], [BZd_KwotaRozSys], [BZd_Kierunek]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZdRozDokStan]
    ON [CDN].[BnkZdarzenia]([BZd_Rozliczono] ASC, [BZd_DokumentTyp] ASC, [BZd_Stan] ASC)
    INCLUDE([BZd_DDfID], [BZd_PodmiotTyp], [BZd_PodmiotID], [BZd_DataDok], [BZd_Termin], [BZd_KwotaSys], [BZd_KwotaRozSys], [BZd_Kierunek]) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZdExpImpID]
    ON [CDN].[BnkZdarzenia]([BZd_ExpImpID] ASC, [BZd_BZdID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkZdarzeniaAlias_InsertUpdateHandler
  ON CDN.BnkZdarzenia
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_DokumentTyp In (39,40))
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BOElem ON
                    inserted.BZd_DokumentId = CDN.BOElem.BOE_BOEId
              WHERE CDN.BOElem.BOE_BOEId IS NULL AND (inserted.BZd_DokumentTyp In (39,40))
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BOElem##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkZdarzenia_DeleteHandler
  ON CDN.BnkZdarzenia
  FOR DELETE
AS
SET NOCOUNT ON
    -- obsługa sprawdzania relacji restrict do tabeli CDN.BOElem
    IF EXISTS
       ( SELECT * FROM CDN.BOElem, deleted
          WHERE
                deleted.BZd_BZdId = CDN.BOElem.BOE_DokumentId
       AND (CDN.BOElem.BOE_DokumentTyp=1)
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=BOElem##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- obsługa sprawdzania relacji restrict do tabeli CDN.BnkDokElem
    IF EXISTS
       ( SELECT * FROM CDN.BnkDokElem, deleted
          WHERE
                deleted.BZd_BZdId = CDN.BnkDokElem.BDE_DokId
       AND (CDN.BnkDokElem.BDE_DokTyp=1)
       )
    BEGIN
      RAISERROR('##OPT32059##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- obsługa sprawdzania relacji restrict do tabeli CDN.BnkRozRelacje
    IF EXISTS
       ( SELECT * FROM CDN.BnkRozRelacje, deleted
          WHERE
                deleted.BZd_BZdId = CDN.BnkRozRelacje.BRR_ZDokID
       AND (CDN.BnkRozRelacje.BRR_ZDokTyp=1)
       )
    BEGIN
   DECLARE @pozwolKasowacRozliczone INT
   SELECT @pozwolKasowacRozliczone = IsNull(CASE WHEN Fir_Wartosc = '1' THEN 1 ELSE 0 END, 0) FROM cdn.Firma WHERE Fir_Numer = 1394
   IF @pozwolKasowacRozliczone = 0
   BEGIN
    RAISERROR('##OPT32058##%%1%%=BnkRozRelacje##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
   END
   --ELSE - usunięcie roliczeń wykona BnkZdarzenia_Delete_Trigger
    END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkZdarzenia_InsertUpdate_Trigger
  ON CDN.BnkZdarzenia
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Sprawdzenie czy kwota rozliczenia nie jest większa od kwoty dokumentu
  IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_Kwota<inserted.BZd_KwotaRoz)
  BEGIN
    RAISERROR('##OPT32284##', 16, 1) -- RAISERROR('Kwota rozliczenia jest większa od kwoty dokumentu.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
--Sprawdzenie, czy nie rozliczamy dokumentu w buforze
  IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_Stan = 0 AND inserted.BZd_KwotaRoz <> 0)
    BEGIN
      RAISERROR('##OPT32292##', 16, 1) -- RAISERROR('Nie można rozliczać dokumentu będącego w buforze', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- TFS 128801
    IF UPDATE(BZd_Kierunek) OR UPDATE(BZd_Kwota) OR UPDATE(BZd_KwotaSys)
    BEGIN
  IF EXISTS (
      SELECT Bzp_Kierunek FROM inserted
      INNER JOIN CDN.BnkRozKwoty ON BRK_LDokTyp = 1 AND BRK_LDokID = inserted.bzd_bzdid AND BRK_PDokTyp = 2
      INNER JOIN CDN.BnkZapisy ON  BZp_BZpID = BRK_PDokID
      WHERE BZp_Kierunek <> inserted.bzd_Kierunek
      UNION ALL
      SELECT Bzp_Kierunek FROM inserted
      INNER JOIN CDN.BnkRozKwoty ON BRK_PDokTyp = 1 AND BRK_PDokID = inserted.bzd_bzdid AND BRK_LDokTyp = 2
      INNER JOIN CDN.BnkZapisy ON BZp_BZpID = BRK_LDokID
      WHERE BZp_Kierunek <> inserted.bzd_Kierunek
      UNION ALL
      SELECT Zd.Bzd_Kierunek FROM inserted
      INNER JOIN CDN.BnkRozKwoty ON BRK_LDokTyp = 1 AND BRK_LDokID = inserted.bzd_bzdid AND BRK_PDokTyp = 1
      INNER JOIN CDN.BnkZdarzenia Zd ON Zd.BZd_BZdID = BRK_PDokID
      WHERE Zd.BZd_Kierunek <> -inserted.bzd_Kierunek
      UNION ALL
      SELECT Zd.Bzd_Kierunek FROM inserted
      INNER JOIN CDN.BnkRozKwoty ON BRK_PDokTyp = 1 AND BRK_PDokID = inserted.bzd_bzdid AND BRK_LDokTyp = 1
      INNER JOIN CDN.BnkZdarzenia Zd ON Zd.BZd_BZdID = BRK_LDokID
      WHERE Zd.BZd_Kierunek <> -inserted.bzd_Kierunek
  )
  BEGIN
    RAISERROR('##OPT32293##', 16, 1) -- RAISERROR('Rozliczenie dokumentów niemożliwe - niezgodne kierunki', 16, 1)
    --RAISERROR(N'%d, %d, %d, %d', 16, 1, @ThisDokTyp, @RozlDokTyp, @ThisKierunek, @RozlKierunek)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
 END
  -- TFS 128801 (end)
-- Sprawdzanie ustawień związanych ze Split payment
 IF UPDATE (BZd_Rozliczono) OR UPDATE (BZd_SplitPay)
 BEGIN
 IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_SplitPay <> 0 AND inserted.BZd_Rozliczono = 0)
  BEGIN
   RAISERROR('##OPT32294##', 16, 1) -- RAISERROR('Parametr split payment może być nie może być zaznaczony dla płatności nie podlegających rozliczeniu.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  END
 END
--Ustalenie relacji do kontrahenta nieokreślonego
  IF UPDATE(BZd_PodmiotTyp) OR UPDATE(BZd_PodmiotId)
    IF EXISTS (SELECT * FROM inserted
               WHERE IsNull(BZd_PodmiotTyp ,0) = 0 OR IsNull(BZd_PodmiotId ,0) = 0)
      BEGIN
        UPDATE CDN.BnkZdarzenia
           SET BZd_PodmiotTyp = 1, BZd_PodmiotId = 1
         WHERE BZd_BZdId IN (SELECT BZd_BZdId FROM inserted WHERE IsNull(BZd_PodmiotTyp ,0) = 0 OR IsNull(BZd_PodmiotId ,0) = 0)
      END
--Ustalenie flagi rozliczenia
  IF UPDATE(BZd_Rozliczono) OR UPDATE(BZd_Rozliczono2) OR UPDATE(BZd_Kwota) OR UPDATE(BZd_KwotaRoz)
   BEGIN
   -- Ustawienie rozliczonych całkowicie (BZd_Rozliczono = 2)
        UPDATE CDN.BnkZdarzenia
           SET BZd_Rozliczono = 2,
               BZd_Stan       = 3
         WHERE BZd_BZdId IN (SELECT BZd_BZdId FROM inserted WHERE BZd_Kwota = BZd_KwotaRoz AND BZd_Rozliczono = 1 OR (BZd_Rozliczono = 2 AND BZd_Stan <> 3))
   -- Ustawienie nie rozliczonych całkowicie (BZd_Rozliczono = 1)
        UPDATE CDN.BnkZdarzenia
           SET BZd_Rozliczono = 1
         WHERE BZd_BZdId IN (SELECT BZd_BZdId FROM inserted WHERE BZd_Kwota <> BZd_KwotaRoz AND BZd_Rozliczono = 2)
   -- Ustawienie nie podlegających rozliczeniu (BZd_Rozliczono2 = 0)
        UPDATE CDN.BnkZdarzenia
           SET BZd_Rozliczono2 = 0
         WHERE BZd_BZdId IN (SELECT BZd_BZdId FROM inserted WHERE BZd_Rozliczono2 <> 0 AND BZd_Rozliczono = 0)
   -- Ustawienie rozliczonych częściowo lub całkowicie (BZd_Rozliczono2 = 2)
        UPDATE CDN.BnkZdarzenia
           SET BZd_Rozliczono2 = 2
         WHERE BZd_BZdId IN (SELECT BZd_BZdId FROM inserted WHERE BZd_KwotaRoz <> 0 AND BZd_Rozliczono2 <> 2 AND BZd_Rozliczono <> 0)
   -- Ustawienie nie rozliczonych w ogóle (BZd_Rozliczono2 = 1)
        UPDATE CDN.BnkZdarzenia
           SET BZd_Rozliczono2 = 1
         WHERE BZd_BZdId IN (SELECT BZd_BZdId FROM inserted WHERE BZd_KwotaRoz = 0 AND BZd_Rozliczono2 <> 1 AND BZd_Rozliczono <> 0)
    END
-- Kasowanie wskanika wyeksportowania przy otwieraniu
If Update (BZd_Stan) And Exists (Select * From inserted Where BZd_TS_Export Is Not Null And BZd_Stan = 0)
  Update CDN.BnkZdarzenia Set BZd_TS_Export = Null Where BZd_BZdId In (Select BZd_BZdId From inserted Where BZd_TS_Export Is Not Null And BZd_Stan = 0)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where BZd_ImportRowId Is Null Or BZd_ImportRowId = '')
  Update CDN.BnkZdarzenia Set BZd_ImportRowId = NewId()
  Where BZd_BZdId In (Select BZd_BZdId From inserted Where BZd_ImportRowId Is Null Or BZd_ImportRowId = '')
-- Aktualizacja limitu kredytu kontrahenta
If Update (BZd_PodmiotTyp) Or Update (BZd_PodmiotId) Or Update (BZd_Rozliczono) Or Update (BZd_Kierunek)
Or Update (BZd_KwotaSys) Or Update (BZd_KwotaRozSys)
Begin
 Update CDN.Kontrahenci
 Set Knt_LimitKredytuWykorzystany = Knt_LimitKredytuWykorzystany - BZd_ZmianaLimitu,
     Knt_TS_Export = Knt_TS_Export
 From
 CDN.Kontrahenci
 Join (Select BZd_PodmiotId, BZd_ZmianaLimitu = Sum (BZd_Kierunek * (BZd_KwotaSys - BZd_KwotaRozSys))
       From deleted
       Where BZd_PodmiotTyp = 1 And BZd_Rozliczono > 0
       Group By BZd_PodmiotId) As TmpBZd On Knt_KntID = BZd_PodmiotId
 Update CDN.Kontrahenci
 Set Knt_LimitKredytuWykorzystany = Knt_LimitKredytuWykorzystany + BZd_ZmianaLimitu,
     Knt_TS_Export = Knt_TS_Export
 From
 CDN.Kontrahenci
 Join (Select BZd_PodmiotId, BZd_ZmianaLimitu = Sum (BZd_Kierunek * (BZd_KwotaSys - BZd_KwotaRozSys))
       From inserted
       Where BZd_PodmiotTyp = 1 And BZd_Rozliczono > 0
       Group By BZd_PodmiotId) As TmpBZd On Knt_KntID = BZd_PodmiotId
End
-- Przepisanie podmiotu na rozliczenia
  IF UPDATE(BZd_PodmiotTyp) OR UPDATE(BZd_PodmiotID) OR UPDATE(BZd_Kwota)
  BEGIN
    UPDATE CDN.BnkRozKwoty
    SET BRK_LPodTyp = Tmp.BZd_PodmiotTyp, BRK_LPodID = Tmp.BZd_PodmiotID, BRK_LKwota = Tmp.BZd_Kwota
    FROM CDN.BnkRozKwoty
    JOIN (SELECT BZd_BZdID, BZd_PodmiotTyp, BZd_PodmiotID, BZd_Kwota FROM inserted) AS Tmp
    ON BRK_LDokTyp=1 AND BRK_LDokID=Tmp.BZd_BZdID
    UPDATE CDN.BnkRozKwoty
    SET BRK_PPodTyp = BZd_PodmiotTyp, BRK_PPodID = BZd_PodmiotID, BRK_PKwota = Tmp.BZd_Kwota
    FROM CDN.BnkRozKwoty
    JOIN (SELECT BZd_BZdID, BZd_PodmiotTyp, BZd_PodmiotID, BZd_Kwota FROM inserted) AS Tmp
    ON BRK_PDokTyp=1 AND BRK_PDokID=Tmp.BZd_BZdID
  END
-- Przepisanie numeru dokumentu na rozliczenia i rozliczenia MW
  IF UPDATE(BZd_NumerPelny) OR UPDATE(BZd_NumerObcy)
  BEGIN
    UPDATE CDN.BnkRozKwoty
    SET BRK_LNumer = CASE WHEN IsNull(Tmp.BZd_NumerObcy, '')<>'' THEN Tmp.BZd_NumerObcy ELSE Tmp.BZd_NumerPelny END
    FROM CDN.BnkRozKwoty
    JOIN (SELECT BZd_BZdID, BZd_NumerPelny, BZd_NumerObcy FROM inserted) AS Tmp
    ON BRK_LDokTyp = 1 AND BRK_LDokID = Tmp.BZd_BZdID
 WHERE BRK_LNumer <> CASE WHEN IsNull(Tmp.BZd_NumerObcy, '')<>'' THEN Tmp.BZd_NumerObcy ELSE Tmp.BZd_NumerPelny END
    UPDATE CDN.BnkRozKwoty
    SET BRK_PNumer = CASE WHEN IsNull(Tmp.BZd_NumerObcy, '')<>'' THEN Tmp.BZd_NumerObcy ELSE Tmp.BZd_NumerPelny END
    FROM CDN.BnkRozKwoty
    JOIN (SELECT BZd_BZdID, BZd_NumerPelny, BZd_NumerObcy FROM inserted) AS Tmp
    ON BRK_PDokTyp = 1 AND BRK_PDokID = Tmp.BZd_BZdID
 WHERE BRK_PNumer <> CASE WHEN IsNull(Tmp.BZd_NumerObcy, '')<>'' THEN Tmp.BZd_NumerObcy ELSE Tmp.BZd_NumerPelny END
  END
    IF UPDATE(BZd_Termin)
  UPDATE cdn.BnkZdarzenia SET BZd_TerminR = cdn.fn_GetWorkingDayAfter(BZd_Termin)
   WHERE BZd_BZdId IN (SELECT I.BZd_BZdId FROM inserted I)
 UPDATE cdn.bnkzdarzenia SET BZd_DataWys = (SELECT TrN_DataWys FROM cdn.TraNag WHERE TrN_TrNID = BZd_DokumentID) WHERE BZd_BZdId IN (SELECT I.BZd_BZdId FROM inserted I WHERE I.BZd_DokumentTyp = 1)
 UPDATE cdn.bnkzdarzenia SET BZd_DataWys = (SELECT VaN_DataWys FROM cdn.VatNag WHERE VaN_VaNID = BZd_DokumentID) WHERE BZd_BZdId IN (SELECT I.BZd_BZdId FROM inserted I WHERE I.BZd_DokumentTyp = 2)
 UPDATE cdn.bnkzdarzenia SET BZd_DataWys = (SELECT EDN_DataWys FROM cdn.EwidDodNag WHERE EDN_EDNID = BZd_DokumentID) WHERE BZd_BZdId IN (SELECT I.BZd_BZdId FROM inserted I WHERE I.BZd_DokumentTyp = 12)
 UPDATE cdn.bnkzdarzenia SET BZd_DataWys = BZd_DataDok WHERE BZd_BZdId IN (SELECT I.BZd_BZdId FROM inserted I WHERE I.BZd_DokumentTyp NOT IN (1, 2, 12))
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkZdarzenia_Delete_Trigger
  ON CDN.BnkZdarzenia
  FOR DELETE
AS
  SET NOCOUNT ON
 DECLARE @pozwolKasowacRozliczone INT
 SELECT @pozwolKasowacRozliczone = IsNull(CASE WHEN Fir_Wartosc = '1' THEN 1 ELSE 0 END, 0) FROM cdn.Firma WHERE Fir_Numer = 1394
-- Sprawdzenie czy zdarzenie nie jest rozliczone
  IF EXISTS (SELECT * FROM deleted WHERE BZd_Rozliczono2 > 1)
  BEGIN
  IF @pozwolKasowacRozliczone = 0
  BEGIN
   RAISERROR('##OPT32290##', 16, 1) -- RAISERROR('Nie można kasować zdarzeń rozliczonych.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  END
 ELSE
  -- zalogowanie usunięcia różnic kursowych związanych z usuwanymi zdarzeniami
   CREATE TABLE #BZdIDs0 (ID INT)
   INSERT INTO #BZdIDs0 SELECT deleted.BZd_BZdID FROM deleted
   EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1126',
    @ObiektSubTyp = '0',
    @ObiektID = 'BRK_BRKID',
    @ObiektNazwa = 'BRK_NumerPelny',
    @OperacjaTyp = 3, -- usunięcie
    @Opis = '''''',
    @From = 'cdn.BnkRozKwoty',
    @Where = 'BRK_BRKID IN (SELECT A.BRK_BRKID FROM cdn.BnkRozKwoty A JOIN #BZdIDs0 ON A.BRK_LDokTyp = 1 AND A.BRK_LDokID = ID OR A.BRK_PDokTyp = 1 AND A.BRK_PDokID = ID WHERE A.BRK_RoznicaKursowaSys <> 0)'
  DROP TABLE #BZdIDs0
    -- zalogowanie odrozliczenia zapisów KB rozliczających usuwane zdarzenia
  CREATE TABLE #BZpIDs (ID INT)
  INSERT INTO #BZpIDs
   SELECT BRK_LDokID FROM cdn.BnkRozKwoty WHERE BRK_LDokTyp = 2 AND BRK_PDokTyp = 1 AND BRK_PDokID IN (SELECT d.BZd_BZdID FROM deleted d WHERE NOT EXISTS (SELECT i.BZd_BZdID FROM inserted i WHERE i.BZd_BZdID = d.BZd_BZdID))
  UNION ALL
   SELECT BRK_PDokID FROM cdn.BnkRozKwoty WHERE BRK_PDokTyp = 2 AND BRK_LDokTyp = 1 AND BRK_LDokID IN (SELECT d.BZd_BZdID FROM deleted d WHERE NOT EXISTS (SELECT i.BZd_BZdID FROM inserted i WHERE i.BZd_BZdID = d.BZd_BZdID))
  EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1000',
         @ObiektSubTyp = 'BZp_Kierunek',
         @ObiektID = 'BZp_BZpID',
         @ObiektNazwa = 'BZp_NumerPelny',
         @OperacjaTyp = 111, -- OptimaOperationType_OdRozliczenieKB
         @Opis = '''''',
         @From = 'cdn.BnkZapisy',
         @Where = 'BZp_BZpID IN (SELECT ID FROM #BZpIDs)'
  DROP TABLE #BZpIDs
    -- zalogowanie odrozliczenia zdarzeń KB rozliczających usuwane zdarzenia
  CREATE TABLE #BZdIDs (ID INT)
  INSERT INTO #BZdIDs
   SELECT BRK_LDokID FROM cdn.BnkRozKwoty WHERE BRK_LDokTyp = 1 AND BRK_PDokTyp = 1 AND BRK_PDokID IN (SELECT d.BZd_BZdID FROM deleted d WHERE NOT EXISTS (SELECT i.BZd_BZdID FROM inserted i WHERE i.BZd_BZdID = d.BZd_BZdID))
  UNION ALL
   SELECT BRK_PDokID FROM cdn.BnkRozKwoty WHERE BRK_PDokTyp = 1 AND BRK_LDokTyp = 1 AND BRK_LDokID IN (SELECT d.BZd_BZdID FROM deleted d WHERE NOT EXISTS (SELECT i.BZd_BZdID FROM inserted i WHERE i.BZd_BZdID = d.BZd_BZdID))
  EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1001',
         @ObiektSubTyp = 'BZd_Kierunek',
         @ObiektID = 'BZd_BZdID',
         @ObiektNazwa = 'CASE WHEN BZd_NumerPelny<>'''' THEN BZd_NumerPelny ELSE (CASE WHEN BZd_DokumentTyp = 0 THEN BZd_NumerObcy ELSE '''' END) END',
         @OperacjaTyp = 111, -- OptimaOperationType_OdRozliczenieKB
         @Opis = '''''',
         @From = 'cdn.BnkZdarzenia',
         @Where = 'BZd_BZdID IN (SELECT ID FROM #BZdIDs)'
  DROP TABLE #BZdIDs
  DELETE cdn.BnkRozKwoty WHERE
   BRK_LDokTyp = 1 AND BRK_LDokID IN (SELECT d.BZd_BZdID FROM deleted d WHERE NOT EXISTS (SELECT i.BZd_BZdID FROM inserted i WHERE i.BZd_BZdID = d.BZd_BZdID))
   OR
   BRK_PDokTyp = 1 AND BRK_PDokID IN (SELECT d.BZd_BZdID FROM deleted d WHERE NOT EXISTS (SELECT i.BZd_BZdID FROM inserted i WHERE i.BZd_BZdID = d.BZd_BZdID))
 END
-- Sprawdzenie czy zdarzenie nie jest wysłane do realizacji
  IF EXISTS (SELECT * FROM deleted WHERE BZd_Stan > 1 AND BZd_DokumentTyp Not In (2,12,108))
  BEGIN
    RAISERROR('##OPT32291##', 16, 1) -- RAISERROR('Nie można kasować zdarzeń zrealizowanych lub wysłanych do banku.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Aktualizacja limitu kredytu kontrahenta
Update CDN.Kontrahenci
 Set Knt_LimitKredytuWykorzystany = Knt_LimitKredytuWykorzystany - BZd_ZmianaLimitu,
     Knt_TS_Export = Knt_TS_Export
From
 CDN.Kontrahenci
 Join (Select BZd_PodmiotId, BZd_ZmianaLimitu = Sum (BZd_Kierunek * BZd_KwotaSys)
       From deleted
       Where BZd_PodmiotTyp = 1 And BZd_Rozliczono > 0
       Group By BZd_PodmiotId) As TmpBZd On Knt_KntID = BZd_PodmiotId
-- Skasowanie relacji do dokumentów  (WiNi)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1001 AND DoR_DokumentId=deleted.BZd_BZdId
  SET NOCOUNT OFF

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[BnkZdarzenia_Delete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
CREATE TRIGGER CDN.BnkZdarzenia_InsertUpdateHandler
  ON CDN.BnkZdarzenia
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_DokumentTyp In (27,28))
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.DekretyElem ON
                    inserted.BZd_DokumentId = CDN.DekretyElem.DeE_DeEId
              WHERE CDN.DekretyElem.DeE_DeEId IS NULL AND (inserted.BZd_DokumentTyp In (27,28))
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=DekretyElem##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_DokumentTyp=12)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.EwidDodNag ON
                    inserted.BZd_DokumentId = CDN.EwidDodNag.EDN_EDNID
              WHERE CDN.EwidDodNag.EDN_EDNID IS NULL AND (inserted.BZd_DokumentTyp=12)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=EwidDodNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_DokumentTyp=11)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.NotyOdsNag ON
                    inserted.BZd_DokumentId = CDN.NotyOdsNag.NON_NONId
              WHERE CDN.NotyOdsNag.NON_NONId IS NULL AND (inserted.BZd_DokumentTyp=11)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=NotyOdsNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_DokumentTyp=6)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.DeklNag ON
                    inserted.BZd_DokumentId = CDN.DeklNag.DkN_DkNID
              WHERE CDN.DeklNag.DkN_DkNID IS NULL AND (inserted.BZd_DokumentTyp=6)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=DeklNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_DokumentTyp=8)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.Wyplaty ON
                    inserted.BZd_DokumentId = CDN.Wyplaty.WPL_WplId
              WHERE CDN.Wyplaty.WPL_WplId IS NULL AND (inserted.BZd_DokumentTyp=8)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=Wyplaty##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_DokumentTyp In (1,101))
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.TraNag ON
                    inserted.BZd_DokumentId = CDN.TraNag.TrN_TrNID
              WHERE CDN.TraNag.TrN_TrNID IS NULL AND (inserted.BZd_DokumentTyp In (1,101))
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=TraNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BZd_DokumentTyp=2)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.VatNag ON
                    inserted.BZd_DokumentId = CDN.VatNag.VaN_VaNID
              WHERE CDN.VatNag.VaN_VaNID IS NULL AND (inserted.BZd_DokumentTyp=2)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=VatNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
