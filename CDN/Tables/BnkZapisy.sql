CREATE TABLE [CDN].[BnkZapisy] (
    [BZp_BZpID]                INT             IDENTITY (1, 1) NOT NULL,
    [BZp_RelTyp]               SMALLINT        NULL,
    [BZp_RelID]                INT             NULL,
    [BZp_BRpID]                INT             NULL,
    [BZp_BRpLP]                INT             NOT NULL,
    [BZp_BRaID]                INT             NULL,
    [BZp_Typ]                  SMALLINT        NOT NULL,
    [BZp_KKrID]                INT             NULL,
    [BZp_KartaNr]              NVARCHAR (16)   NOT NULL,
    [BZp_KartaDW]              DATETIME        NULL,
    [BZp_DDfID]                INT             NULL,
    [BZp_NumerNr]              INT             NOT NULL,
    [BZp_NumerString]          VARCHAR (31)    NOT NULL,
    [BZp_NumerPelny]           AS              ([CDN].[FN_NUMERPELNY]([BZP_NUMERNR],[BZP_NUMERSTRING])),
    [BZp_NumerObcy]            NVARCHAR (256)  NOT NULL,
    [BZp_PodmiotTyp]           SMALLINT        NULL,
    [BZp_PodmiotID]            INT             NULL,
    [BZp_PodmiotRachunekLp]    INT             NOT NULL,
    [BZp_BNaID]                INT             NULL,
    [BZp_RachunekNr]           NVARCHAR (51)   NOT NULL,
    [BZp_IBAN]                 SMALLINT        NOT NULL,
    [BZp_Nazwa1]               NVARCHAR (50)   NOT NULL,
    [BZp_Nazwa2]               NVARCHAR (50)   NOT NULL,
    [BZp_Nazwa3]               NVARCHAR (250)  NOT NULL,
    [BZp_Kraj]                 NVARCHAR (40)   NOT NULL,
    [BZp_Wojewodztwo]          NVARCHAR (40)   NOT NULL,
    [BZp_Powiat]               NVARCHAR (40)   NOT NULL,
    [BZp_Gmina]                NVARCHAR (40)   NOT NULL,
    [BZp_Ulica]                NVARCHAR (40)   NOT NULL,
    [BZp_NrDomu]               NVARCHAR (10)   NOT NULL,
    [BZp_NrLokalu]             NVARCHAR (10)   NOT NULL,
    [BZp_Miasto]               NVARCHAR (40)   NOT NULL,
    [BZp_KodPocztowy]          VARCHAR (10)    NOT NULL,
    [BZp_Poczta]               NVARCHAR (40)   NOT NULL,
    [BZp_Adres2]               NVARCHAR (40)   NOT NULL,
    [BZp_KatID]                INT             NULL,
    [BZp_DataDok]              DATETIME        NOT NULL,
    [BZp_KwotaSys]             DECIMAL (15, 2) NOT NULL,
    [BZp_KwotaRozSys]          DECIMAL (15, 2) NOT NULL,
    [BZp_KwotaRozSysMW]        DECIMAL (15, 2) NOT NULL,
    [BZp_DataRoz]              DATETIME        NULL,
    [BZp_DataRozMW]            DATETIME        NULL,
    [BZp_Kwota]                DECIMAL (15, 2) NOT NULL,
    [BZp_KwotaRoz]             DECIMAL (15, 2) NOT NULL,
    [BZp_KwotaRozMW]           DECIMAL (15, 2) NOT NULL,
    [BZp_Waluta]               VARCHAR (3)     NOT NULL,
    [BZp_WalutaDok]            VARCHAR (3)     NOT NULL,
    [BZp_KursNumer]            INT             NOT NULL,
    [BZp_KursL]                DECIMAL (15, 4) NOT NULL,
    [BZp_KursM]                DECIMAL (5)     NOT NULL,
    [BZp_Kierunek]             SMALLINT        NOT NULL,
    [BZp_Rozliczono]           SMALLINT        NOT NULL,
    [BZp_RozliczonoMW]         SMALLINT        NOT NULL,
    [BZp_Rozliczono2]          SMALLINT        NOT NULL,
    [BZp_Rozliczono2MW]        SMALLINT        NOT NULL,
    [BZp_DataKur]              DATETIME        NOT NULL,
    [BZp_Opis]                 NVARCHAR (1024) NOT NULL,
    [BZp_ZapisAutomatyczny]    SMALLINT        NOT NULL,
    [BZp_AutoOffLine]          SMALLINT        NOT NULL,
    [BZp_KontoPrzeciwstawne]   NVARCHAR (50)   NOT NULL,
    [BZp_MagazynWalut]         SMALLINT        NOT NULL,
    [BZp_WgKursuMW]            SMALLINT        NOT NULL,
    [BZp_Wynagrodzenie]        TINYINT         NOT NULL,
    [BZp_KolumnaKPR]           INT             CONSTRAINT [DF_BZp_KolumnaKPR] DEFAULT ((0)) NOT NULL,
    [BZp_KPRID]                INT             NULL,
    [BZp_TS_Export]            DATETIME        NULL,
    [BZp_ImportAppId]          VARCHAR (5)     NULL,
    [BZp_ImportRowId]          VARCHAR (36)    NULL,
    [BZp_TypDokumentuKB]       AS              ((2)),
    [BZp_CDC]                  TINYINT         NULL,
    [BZp_CDCOpis]              NVARCHAR (255)  NULL,
    [BZp_OpeZalId]             INT             NULL,
    [BZp_StaZalId]             INT             NULL,
    [BZp_TS_Zal]               DATETIME        NOT NULL,
    [BZp_OpeModId]             INT             NULL,
    [BZp_StaModId]             INT             NULL,
    [BZp_TS_Mod]               DATETIME        NOT NULL,
    [BZp_Importowany]          TINYINT         CONSTRAINT [DF_BZp_Importowany] DEFAULT ((0)) NOT NULL,
    [BZp_ZakID]                INT             NULL,
    [BZp_OpeModKod]            VARCHAR (20)    CONSTRAINT [DF_BZp_OpeModKod] DEFAULT ('') NOT NULL,
    [BZp_OpeModNazwisko]       NVARCHAR (50)   CONSTRAINT [DF_BZp_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BZp_OpeZalKod]            VARCHAR (20)    CONSTRAINT [DF_BZp_OpeZalKod] DEFAULT ('') NOT NULL,
    [BZp_OpeZalNazwisko]       NVARCHAR (50)   CONSTRAINT [DF_BZp_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [BZp_ExpImpID]             VARCHAR (13)    NULL,
    [BZp_URaID]                INT             NULL,
    [BZp_CDCIdentPrzelewuBank] NVARCHAR (35)   NULL,
    [BZp_SplitPay]             TINYINT         CONSTRAINT [DF_BZp_SplitPay] DEFAULT ((0)) NOT NULL,
    [BZp_SplitPayZapisVAT]     TINYINT         CONSTRAINT [DF_BZp_SplitPayZapisVAT] DEFAULT ((0)) NOT NULL,
    [BZp_Numer]                AS              (case when [BZP_NUMEROBCY]<>'' then [BZP_NUMEROBCY] else [CDN].[FN_NUMERPELNY]([BZP_NUMERNR],[BZP_NUMERSTRING]) end),
    [BZp_CDCBnkAddInfo]        NVARCHAR (256)  NULL,
    CONSTRAINT [BZp_Primary] PRIMARY KEY CLUSTERED ([BZp_BZpID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_BZp_Kierunek] CHECK ([BZP_KIERUNEK]=(1) OR [BZP_KIERUNEK]=(0) OR [BZP_KIERUNEK]=(-1)),
    CONSTRAINT [CK_BZp_KwotaRoz] CHECK ([BZP_KWOTAROZ]>=(0)),
    CONSTRAINT [CK_BZp_KwotaRozMW] CHECK ([BZP_KWOTAROZMW]>=(0)),
    CONSTRAINT [CK_BZp_KwotaRozSys] CHECK ([BZP_KWOTAROZSYS]>=(0)),
    CONSTRAINT [CK_BZp_KwotaRozSysMW] CHECK ([BZP_KWOTAROZSYSMW]>=(0)),
    CONSTRAINT [FK_BZpBank] FOREIGN KEY ([BZp_BNaID]) REFERENCES [CDN].[BnkNazwy] ([BNa_BNaId]),
    CONSTRAINT [FK_BZpDokDefinicja] FOREIGN KEY ([BZp_DDfID]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_BZpKartaTyp] FOREIGN KEY ([BZp_KKrID]) REFERENCES [CDN].[KartyKredytowe] ([KKr_KKrId]),
    CONSTRAINT [FK_BZpKategoria] FOREIGN KEY ([BZp_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_BZpPodmiot] FOREIGN KEY ([BZp_PodmiotID], [BZp_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_BZpRachunek] FOREIGN KEY ([BZp_BRaID]) REFERENCES [CDN].[BnkRachunki] ([BRa_BRaID]),
    CONSTRAINT [FK_BZpRaport] FOREIGN KEY ([BZp_BRpID]) REFERENCES [CDN].[BnkRaporty] ([BRp_BRpID]),
    CONSTRAINT [FK_BZpUrzRachunek] FOREIGN KEY ([BZp_URaID]) REFERENCES [CDN].[UrzRachunki] ([URa_URaId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpRaport]
    ON [CDN].[BnkZapisy]([BZp_BRpID] ASC, [BZp_BRpLP] ASC, [BZp_BZpID] ASC)
    INCLUDE([BZp_KwotaSys], [BZp_Kwota], [BZp_Kierunek]) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpRachunek]
    ON [CDN].[BnkZapisy]([BZp_BRaID] ASC, [BZp_DataDok] ASC, [BZp_BZpID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpNumeracja]
    ON [CDN].[BnkZapisy]([BZp_NumerString] ASC, [BZp_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpNumerPelny]
    ON [CDN].[BnkZapisy]([BZp_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpPodmiot]
    ON [CDN].[BnkZapisy]([BZp_PodmiotID] ASC, [BZp_PodmiotTyp] ASC, [BZp_DataDok] ASC, [BZp_BZpID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZpBank]
    ON [CDN].[BnkZapisy]([BZp_BNaID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpKategoria]
    ON [CDN].[BnkZapisy]([BZp_KatID] ASC, [BZp_DataDok] ASC, [BZp_BZpID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZpDokDefinicja]
    ON [CDN].[BnkZapisy]([BZp_DDfID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpRozliczono]
    ON [CDN].[BnkZapisy]([BZp_PodmiotID] ASC, [BZp_PodmiotTyp] ASC, [BZp_Rozliczono] ASC, [BZp_DataDok] ASC, [BZp_BZpID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpRozliczono2]
    ON [CDN].[BnkZapisy]([BZp_PodmiotID] ASC, [BZp_PodmiotTyp] ASC, [BZp_Rozliczono2] ASC, [BZp_DataDok] ASC, [BZp_BZpID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZpKartaTyp]
    ON [CDN].[BnkZapisy]([BZp_KKrID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpData]
    ON [CDN].[BnkZapisy]([BZp_DataDok] ASC, [BZp_BZpID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpGUID]
    ON [CDN].[BnkZapisy]([BZp_ImportRowId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [BZpKntLista]
    ON [CDN].[BnkZapisy]([BZp_PodmiotTyp] ASC, [BZp_Kierunek] ASC, [BZp_Rozliczono] ASC)
    INCLUDE([BZp_PodmiotID], [BZp_Kwota], [BZp_KwotaRoz], [BZp_Waluta], [BZp_BZpID], [BZp_BRaID], [BZp_Wynagrodzenie]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZpBRaKierRozWyna]
    ON [CDN].[BnkZapisy]([BZp_BRaID] ASC, [BZp_Kierunek] ASC, [BZp_Rozliczono] ASC, [BZp_Wynagrodzenie] ASC)
    INCLUDE([BZp_BZpID], [BZp_BRpID], [BZp_PodmiotTyp], [BZp_PodmiotID], [BZp_DataDok], [BZp_KwotaSys], [BZp_KwotaRozSys], [BZp_Kwota], [BZp_KwotaRoz], [BZp_NumerPelny], [BZp_KPRID]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BZpZapisAuto]
    ON [CDN].[BnkZapisy]([BZp_ZapisAutomatyczny] ASC)
    INCLUDE([BZp_BZpID], [BZp_BRpID]) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BZpExpImpID]
    ON [CDN].[BnkZapisy]([BZp_ExpImpID] ASC, [BZp_BZpID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkZapisy_Delete_Trigger
  ON CDN.BnkZapisy
  FOR DELETE
AS
SET NOCOUNT ON
/*
  -- obsługa sprawdzania relacji restrict do tabeli CDN.DlgZaliczki
  IF EXISTS
     ( SELECT * FROM CDN.DlgZaliczki, deleted
        WHERE
              deleted.BZp_BZpId = CDN.DlgZaliczki.DLZ_BZpId)
  BEGIN
    --RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą DlgZaliczki). ', 16, 1)
  RAISERROR('Nie można usunąć zapisu powiązanego  z dokumentem Delegacji. Należy najpierw usunąć zapis z formularza elementu delegacji z zakładki Zaliczki. ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
*/
-- Skasowanie relacji do dokumentów
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1000 AND DoR_DokumentId=deleted.BZp_BZpID
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkZapisy_DeleteHandler
  ON CDN.BnkZapisy
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS
       ( SELECT * FROM CDN.DekretyElem, deleted
          WHERE
                deleted.BZp_BZpId = CDN.DekretyElem.DeE_DokumentId
       AND (CDN.DekretyElem.DeE_DokumentTyp =14)
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=DekretyElem##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS
       ( SELECT * FROM CDN.BOElem, deleted
          WHERE
                deleted.BZp_BZpId = CDN.BOElem.BOE_DokumentId
       AND (CDN.BOElem.BOE_DokumentTyp=2)
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
                deleted.BZp_BZpId = CDN.BnkDokElem.BDE_DokId
       AND (CDN.BnkDokElem.BDE_DokTyp=2)
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=BnkDokElem##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- obsługa sprawdzania relacji restrict do tabeli CDN.BnkRozRelacje
    IF EXISTS
       ( SELECT * FROM CDN.BnkRozRelacje, deleted
          WHERE
                deleted.BZp_BZpId = CDN.BnkRozRelacje.BRR_ZDokID
       AND (CDN.BnkRozRelacje.BRR_ZDokTyp=2)
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
    END
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.BZp_BZpId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=14)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.BZp_BZpId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=14)
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkZapisy_InsertUpdateDelete_Trigger
  ON CDN.BnkZapisy
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
Declare @BRa_Waluta_Inserted NVarchar(3)
Declare @BRa_Waluta_Deleted  NVarchar(3)
--Sprawdzenie, czy raport został zamknięty
  IF UPDATE (BZp_RelTyp) OR UPDATE(BZp_RelID) OR UPDATE(BZp_BRpID) OR UPDATE(BZp_BRpLP) OR UPDATE(BZp_BRaID) OR UPDATE(BZp_Typ)
  OR UPDATE(BZp_KartaNr) OR UPDATE(BZp_DDfID) OR UPDATE(BZp_NumerNr) OR UPDATE(BZp_NumerString) OR UPDATE(BZp_NumerObcy)
  OR UPDATE(BZp_RachunekNr) OR UPDATE(BZp_Nazwa1) OR UPDATE(BZp_Nazwa2) OR UPDATE(BZp_Kraj) OR UPDATE(BZp_Wojewodztwo)
  OR UPDATE(BZp_Powiat) OR UPDATE(BZp_Gmina) OR UPDATE(BZp_Ulica) OR UPDATE(BZp_NrDomu) OR UPDATE(BZp_NrLokalu) OR UPDATE(BZp_Miasto)
  OR UPDATE(BZp_KodPocztowy) OR UPDATE(BZp_Poczta) OR UPDATE(BZp_Adres2) OR UPDATE(BZp_DataDok)
 /* OR UPDATE(BZp_Kwota) */ OR UPDATE(BZp_Kierunek) OR UPDATE(BZp_OpeZalId) OR UPDATE(BZp_TS_Zal)
    BEGIN
   -- Zakaz dodawania w raporcie zamkniętym
      IF (EXISTS (SELECT * FROM inserted JOIN CDN.BnkRaporty ON inserted.BZp_BRpId = CDN.BnkRaporty.BRp_BRpId
          WHERE CDN.BnkRaporty.BRp_Zamkniety <> 0 AND NOT EXISTS (SELECT * FROM deleted WHERE deleted.BZp_BZpID = inserted.BZp_BZpID)))
        BEGIN
          RAISERROR('##OPT32278##', 16, 1) -- RAISERROR('Raport został zamknięty. Nie można dodawać do niego zapisów k/b.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
      -- Zakaz zmiany w raporcie zamkniętym
      IF (
     EXISTS (SELECT * FROM inserted INNER JOIN deleted ON deleted.BZp_BZpID = inserted.BZp_BZpID JOIN CDN.BnkRaporty ON CDN.BnkRaporty.BRp_BRpId = deleted.BZp_BRpId
          WHERE
          CDN.BnkRaporty.BRp_Zamkniety <> 0
          AND
          (
           (inserted.BZp_RelTyp<>deleted.BZp_RelTyp OR inserted.BZp_RelID<>deleted.BZp_RelID OR inserted.BZp_BRpID<>deleted.BZp_BRpID OR
           inserted.BZp_BRpLP<>deleted.BZp_BRpLP OR inserted.BZp_BRaID<>deleted.BZp_BRaID OR inserted.BZp_Typ<>deleted.BZp_Typ OR
           inserted.BZp_Kierunek<>deleted.BZp_Kierunek OR inserted.BZp_OpeZalId<>deleted.BZp_OpeZalId OR inserted.BZp_TS_Zal<>deleted.BZp_TS_Zal)
           OR
           inserted.BZp_ZapisAutomatyczny<>0 AND
            (inserted.BZp_NumerObcy<>deleted.BZp_NumerObcy OR inserted.BZp_RachunekNr<>deleted.BZp_RachunekNr OR inserted.BZp_DataDok<>deleted.BZp_DataDok)))
    )
        BEGIN
          RAISERROR('##OPT32279##', 16, 1) -- RAISERROR('Raport został zamknięty. Nie można zmieniać określonych właściwości jego zapisów k/b.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
  ELSE
    BEGIN
    -- Zakaz kasowania w raporcie zamkniętym
      IF (EXISTS (SELECT * FROM deleted
             JOIN   CDN.BnkRaporty
             ON     deleted.BZp_BRpId = CDN.BnkRaporty.BRp_BRpId
             WHERE  CDN.BnkRaporty.BRp_Zamkniety <> 0)) AND
         (NOT EXISTS (SELECT * FROM inserted))
        BEGIN
          RAISERROR('##OPT32280##', 16, 1) -- RAISERROR('Raport został zamknięty. Nie można usuwać jego zapisów k/b.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
    IF UPDATE(BZp_Kwota) OR UPDATE(BZp_KwotaSys)
    BEGIN
      IF (EXISTS (SELECT * FROM inserted
             WHERE inserted.BZp_KPRID <> 0)) OR
         (EXISTS (SELECT * FROM deleted
             WHERE  deleted.BZp_KPRID <> 0))
        BEGIN
          RAISERROR('##OPT32281##', 16, 1) -- RAISERROR('Nie można zmieniać kwoty zapisów zaksięgowanych (KPiR).', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
        IF (EXISTS (SELECT * FROM inserted
             JOIN   CDN.BnkRaporty
             ON     inserted.BZp_BRpId = CDN.BnkRaporty.BRp_BRpId
             WHERE  CDN.BnkRaporty.BRp_DekID <> 0)) OR
         (EXISTS (SELECT * FROM deleted
             JOIN   CDN.BnkRaporty
             ON     deleted.BZp_BRpId = CDN.BnkRaporty.BRp_BRpId
             WHERE  CDN.BnkRaporty.BRp_DekID <> 0))
        BEGIN
          RAISERROR('##OPT32282##', 16, 1) -- RAISERROR('Nie można zmieniać kwoty zapisów w zaksięgowanych raportach.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
    END
-- Sprawdzenie czy próbujemy usunąć zapis zaksięgowany do KPiR
    IF EXISTS
       ( SELECT * FROM deleted
     WHERE NOT EXISTS (SELECT * FROM inserted WHERE inserted.BZp_BZpID = deleted.BZp_BZpID) AND IsNull(deleted.BZp_KPRID, 0) <> 0
       )
    BEGIN
      RAISERROR('##OPT32283##', 16, 1) -- RAISERROR('Nie można kasować zapisów zaksięgowanych (KPiR).', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie czy kwota rozliczenia nie jest większa od kwoty dokumentu
  IF EXISTS (SELECT * FROM inserted WHERE inserted.BZp_Kwota<inserted.BZp_KwotaRoz)
  BEGIN
    RAISERROR('##OPT32284##', 16, 1) -- RAISERROR('Kwota rozliczenia jest większa od kwoty dokumentu.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie czy kwota rozliczenia MW nie jest większa od kwoty dokumentu
  IF EXISTS (SELECT * FROM inserted WHERE inserted.BZp_Kwota<inserted.BZp_KwotaRozMW)
  BEGIN
    RAISERROR('##OPT32285##', 16, 1) -- RAISERROR('Kwota rozliczenia w Magazynie Walut jest większa od kwoty dokumentu.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie czy zapis nie jest wcześniejszy niż data otwarcia raportu
  IF EXISTS (SELECT * FROM inserted JOIN CDN.BnkRaporty ON inserted.BZp_BRpID=BRp_BRpID
             WHERE inserted.BZp_DataDok<BRp_DataDok)
  BEGIN
    RAISERROR('##OPT32286##', 16, 1) -- RAISERROR('Zapis przed datą otwarcia raportu.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie czy zapis nie jest późniejszy niż data zamknięcia raportu
  IF EXISTS (SELECT * FROM inserted JOIN CDN.BnkRaporty ON inserted.BZp_BRpID=BRp_BRpID
             WHERE BRp_DataZam is not null AND inserted.BZp_DataDok>BRp_DataZam)
  BEGIN
    RAISERROR('##OPT32287##', 16, 1) -- RAISERROR('Zapis po dacie zamknięcia raportu.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie czy zapis nie jest rozliczony MW
  IF EXISTS (SELECT * FROM deleted WHERE BZp_KwotaRozMW > 0 AND BZp_Kwota>0 AND
             BZp_BZpId NOT IN (SELECT BZp_BZpId FROM inserted))
  BEGIN
    RAISERROR('##OPT32288##', 16, 1) -- RAISERROR('Nie można kasować zapisów rozliczonych w Magazynie Walut.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie czy zapis nie jest rozliczony
  IF EXISTS (SELECT * FROM deleted WHERE BZp_Rozliczono > 1 AND BZp_Kwota>0 AND --PG: BZp_Kwota=0 (dodanie warunku BZp_Kwota>0)
             BZp_BZpId NOT IN (SELECT BZp_BZpId FROM inserted))
  BEGIN
  DECLARE @pozwolKasowacRozliczone INT
    SELECT @pozwolKasowacRozliczone = IsNull(CASE WHEN Fir_Wartosc = '1' THEN 1 ELSE 0 END, 0) FROM cdn.Firma WHERE Fir_Numer = 1394
  IF @pozwolKasowacRozliczone = 0
  BEGIN
   RAISERROR('##OPT32289##', 16, 1) -- RAISERROR('Nie można kasować zapisów rozliczonych.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  END
 ELSE
   DELETE cdn.BnkRozKwoty WHERE
   BRK_LDokTyp = 2 AND BRK_LDokID IN (SELECT d.BZp_BZpID FROM deleted d WHERE NOT EXISTS (SELECT i.BZp_BZpID FROM inserted i WHERE i.BZp_BZpID = d.BZp_BZpID))
   OR
   BRK_PDokTyp = 2 AND BRK_PDokID IN (SELECT d.BZp_BZpID FROM deleted d WHERE NOT EXISTS (SELECT i.BZp_BZpID FROM inserted i WHERE i.BZp_BZpID = d.BZp_BZpID))
  END
--Ustalenie relacji do kontrahenta nieokreślonego
  IF UPDATE(BZp_PodmiotTyp) OR UPDATE(BZp_PodmiotId)
    IF EXISTS (SELECT * FROM inserted
               WHERE IsNull(BZp_PodmiotTyp ,0) = 0 OR IsNull(BZp_PodmiotId ,0) = 0)
      BEGIN
        UPDATE CDN.BnkZapisy
           SET BZp_PodmiotTyp = 1, BZp_PodmiotId = 1
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE IsNull(BZp_PodmiotTyp ,0) = 0 OR IsNull(BZp_PodmiotId ,0) = 0)
      END
--Ustalenie flagi rozliczenia
  IF UPDATE(BZp_Rozliczono) OR UPDATE(BZp_Rozliczono2) OR UPDATE(BZp_Kwota) OR UPDATE(BZp_KwotaRoz)
   BEGIN
    -- Zapis rozliczony całkowicie (BZp_Rozliczono = 2)
        UPDATE CDN.BnkZapisy
           SET BZp_Rozliczono = 2
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE BZp_Kwota = BZp_KwotaRoz AND BZp_Rozliczono = 1)
    -- Zapis nie rozliczony całkowicie (BZp_Rozliczono = 1)
        UPDATE CDN.BnkZapisy
           SET BZp_Rozliczono = 1
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE BZp_Kwota <> BZp_KwotaRoz AND BZp_Rozliczono = 2)
    -- Zapis nie podlegający rozliczeniu (BZp_Rozliczono2 = 0)
        UPDATE CDN.BnkZapisy
           SET BZp_Rozliczono2 = 0
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE BZp_Rozliczono2 <> 0 AND BZp_Rozliczono = 0)
    -- Zapis rozliczony częściowo lub całkowicie (BZp_Rozliczono2 = 2)
        UPDATE CDN.BnkZapisy
           SET BZp_Rozliczono2 = 2
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE (BZp_KwotaRoz <> 0 OR BZp_Kwota=0 AND BZp_KwotaSys>0) AND BZp_Rozliczono2 <> 2 AND BZp_Rozliczono <> 0) --PG: BZp_Kwota=0 (dodanie warunku: OR BZp_Kwota=0 AND BZp_KwotaSys>)
    -- Zapis nie rozliczony w ogóle (BZp_Rozliczono2 = 1)
        UPDATE CDN.BnkZapisy
           SET BZp_Rozliczono2 = 1
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE BZp_KwotaRoz = 0 AND BZp_Kwota>0 AND BZp_Rozliczono2 <> 1 AND BZp_Rozliczono <> 0) --PG: BZp_Kwota=0 (dodanie warunku: AND BZp_Kwota>0)
    END
--Ustalenie flagi rozliczenia MW
  IF UPDATE(BZp_RozliczonoMW) OR UPDATE(BZp_Rozliczono2MW) OR UPDATE(BZp_Kwota) OR UPDATE(BZp_KwotaRozMW)
   BEGIN
    -- Zapis rozliczony całkowicie (BZp_RozliczonoMW = 2)
        UPDATE CDN.BnkZapisy
           SET BZp_RozliczonoMW = 2
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE BZp_Kwota = BZp_KwotaRozMW AND BZp_RozliczonoMW = 1)
    -- Zapis nie rozliczony całkowicie (BZp_RozliczonoMW = 1)
        UPDATE CDN.BnkZapisy
           SET BZp_RozliczonoMW = 1
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE BZp_Kwota <> BZp_KwotaRozMW AND BZp_RozliczonoMW = 2)
    -- Zapis rozliczony częściowo lub całkowicie (BZp_Rozliczono2MW = 2)
        UPDATE CDN.BnkZapisy
           SET BZp_Rozliczono2MW = 2
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE (BZp_KwotaRozMW <> 0 OR BZp_Kwota=0 AND BZp_KwotaSys>0) AND BZp_Rozliczono2MW <> 2 AND BZp_RozliczonoMW <> 0)
    -- Zapis nie rozliczony w ogóle (BZp_Rozliczono2MW = 1)
        UPDATE CDN.BnkZapisy
           SET BZp_Rozliczono2MW = 1
         WHERE BZp_BZpId IN (SELECT BZp_BZpId FROM inserted WHERE BZp_KwotaRozMW = 0 AND BZp_Kwota>0 AND BZp_Rozliczono2MW <> 1  AND BZp_RozliczonoMW <> 0)
    END
-- Kasowanie wskanika wyeksportowania
If Not Update (BZp_TS_Export) And Exists (Select * From inserted Where BZp_TS_Export Is Not Null)
  Update CDN.BnkZapisy Set BZp_TS_Export = Null Where BZp_BZpId In (Select BZp_BZpId From inserted Where BZp_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where BZp_ImportRowId Is Null Or BZp_ImportRowId = '')
  Update CDN.BnkZapisy Set BZp_ImportRowId = NewId()
  Where BZp_BZpId In (Select BZp_BZpId From inserted Where BZp_ImportRowId Is Null Or BZp_ImportRowId = '')
-- Aktualizacja limitu kredytu kontrahenta
Update CDN.Kontrahenci
 Set Knt_LimitKredytuWykorzystany = Knt_LimitKredytuWykorzystany + BZp_ZmianaLimitu,
     Knt_TS_Export = Knt_TS_Export
 From
 CDN.Kontrahenci
 Join (Select BZp_PodmiotId, BZp_ZmianaLimitu = Sum (BZp_Kierunek * (BZp_KwotaSys - BZp_KwotaRozSys))
       From deleted
       Where BZp_PodmiotTyp = 1 And BZp_Rozliczono > 0
       Group By BZp_PodmiotId) As TmpBZp On Knt_KntId = BZp_PodmiotId
Update CDN.Kontrahenci
 Set Knt_LimitKredytuWykorzystany = Knt_LimitKredytuWykorzystany - BZp_ZmianaLimitu,
     Knt_TS_Export = Knt_TS_Export
 From
 CDN.Kontrahenci
 Join (Select BZp_PodmiotId, BZp_ZmianaLimitu = Sum (BZp_Kierunek * (BZp_KwotaSys - BZp_KwotaRozSys))
       From inserted
       Where BZp_PodmiotTyp = 1 And BZp_Rozliczono > 0
       Group By BZp_PodmiotId) As TmpBZp On Knt_KntId = BZp_PodmiotId
If (Select Count(*) From inserted Where BZp_BRpLp=0)=1
 Begin
  Declare @BRpId Int, @BZpId Int, @BRpLp Int
  Select Top 1 @BZpId = BZp_BZpId, @BRpId = BZp_BRpId From inserted Where BZp_BRpLp=0
  Select @BRpLp = IsNull(Max(BZp_BRpLp),0) + 1 From CDN.BnkZapisy Where BZp_BRpId = @BRpId
  Update CDN.BnkZapisy Set BZp_BRpLp = @BRpLp Where BZp_BZpId = @BZpId
 End
-- Przepisanie podmiotu na rozliczenia i rozliczenia MW
  IF UPDATE(BZp_PodmiotTyp) OR UPDATE(BZp_PodmiotID) OR UPDATE(BZp_Kwota)
  BEGIN
    UPDATE CDN.BnkRozKwoty
    SET BRK_LPodTyp = Tmp.BZp_PodmiotTyp, BRK_LPodID = Tmp.BZp_PodmiotID, BRK_LKwota = Tmp.BZp_Kwota
    FROM CDN.BnkRozKwoty
    JOIN (SELECT BZp_BZpID, BZp_PodmiotTyp, BZp_PodmiotID, BZp_Kwota FROM inserted) AS Tmp
    ON BRK_LDokTyp=2 AND BRK_LDokID=Tmp.BZp_BZpID
    UPDATE CDN.BnkRozKwoty
    SET BRK_PPodTyp = BZp_PodmiotTyp, BRK_PPodID = BZp_PodmiotID, BRK_PKwota = Tmp.BZp_Kwota
    FROM CDN.BnkRozKwoty
    JOIN (SELECT BZp_BZpID, BZp_PodmiotTyp, BZp_PodmiotID, BZp_Kwota FROM inserted) AS Tmp
    ON BRK_PDokTyp=2 AND BRK_PDokID=Tmp.BZp_BZpID
    IF EXISTS(SELECT inserted.BZp_BZpID FROM inserted WHERE inserted.BZp_Waluta<>'')
    BEGIN
  UPDATE CDN.BnkRozKwotyMW
  SET BRKMW_LPodTyp = Tmp.BZp_PodmiotTyp, BRKMW_LPodID = Tmp.BZp_PodmiotID
  FROM CDN.BnkRozKwotyMW
  JOIN (SELECT BZp_BZpID, BZp_PodmiotTyp, BZp_PodmiotID FROM inserted) AS Tmp
  ON BRKMW_LDokTyp=2 AND BRKMW_LDokID=Tmp.BZp_BZpID
  UPDATE CDN.BnkRozKwotyMW
  SET BRKMW_PPodTyp = BZp_PodmiotTyp, BRKMW_PPodID = BZp_PodmiotID
  FROM CDN.BnkRozKwotyMW
  JOIN (SELECT BZp_BZpID, BZp_PodmiotTyp, BZp_PodmiotID FROM inserted) AS Tmp
  ON BRKMW_PDokTyp=2 AND BRKMW_PDokID=Tmp.BZp_BZpID
 END
  END
-- Przepisanie numeru dokumentu na rozliczenia i rozliczenia MW
  IF UPDATE(BZp_NumerString) OR UPDATE(BZp_NumerNr) OR UPDATE(BZp_NumerObcy)
  BEGIN
    UPDATE CDN.BnkRozKwoty
    SET BRK_LNumer = CASE WHEN IsNull(Tmp.BZp_NumerObcy, '')<>'' THEN Tmp.BZp_NumerObcy ELSE Tmp.BZp_NumerPelny END
    FROM CDN.BnkRozKwoty
    JOIN (SELECT BZp_BZpID, BZp_NumerPelny, BZp_NumerObcy FROM inserted) AS Tmp
    ON BRK_LDokTyp = 2 AND BRK_LDokID = Tmp.BZp_BZpID
 WHERE BRK_LNumer <> CASE WHEN IsNull(Tmp.BZp_NumerObcy, '')<>'' THEN Tmp.BZp_NumerObcy ELSE Tmp.BZp_NumerPelny END
    UPDATE CDN.BnkRozKwoty
    SET BRK_PNumer = CASE WHEN IsNull(Tmp.BZp_NumerObcy, '')<>'' THEN Tmp.BZp_NumerObcy ELSE Tmp.BZp_NumerPelny END
    FROM CDN.BnkRozKwoty
    JOIN (SELECT BZp_BZpID, BZp_NumerPelny, BZp_NumerObcy FROM inserted) AS Tmp
    ON BRK_PDokTyp = 2 AND BRK_PDokID = Tmp.BZp_BZpID
 WHERE BRK_PNumer <> CASE WHEN IsNull(Tmp.BZp_NumerObcy, '')<>'' THEN Tmp.BZp_NumerObcy ELSE Tmp.BZp_NumerPelny END
    UPDATE CDN.BnkRozKwotyMW
    SET BRKMW_LNumer = CASE WHEN IsNull(Tmp.BZp_NumerObcy, '')<>'' THEN Tmp.BZp_NumerObcy ELSE Tmp.BZp_NumerPelny END
    FROM CDN.BnkRozKwotyMW
    JOIN (SELECT BZp_BZpID, BZp_NumerPelny, BZp_NumerObcy FROM inserted) AS Tmp
    ON BRKMW_LDokTyp=2 AND BRKMW_LDokID = Tmp.BZp_BZpID
 WHERE BRKMW_LNumer <> CASE WHEN IsNull(Tmp.BZp_NumerObcy, '')<>'' THEN Tmp.BZp_NumerObcy ELSE Tmp.BZp_NumerPelny END
    UPDATE CDN.BnkRozKwotyMW
    SET BRKMW_PNumer = CASE WHEN IsNull(Tmp.BZp_NumerObcy, '')<>'' THEN Tmp.BZp_NumerObcy ELSE Tmp.BZp_NumerPelny END
    FROM CDN.BnkRozKwotyMW
    JOIN (SELECT BZp_BZpID, BZp_NumerPelny, BZp_NumerObcy FROM inserted) AS Tmp
    ON BRKMW_PDokTyp = 2 AND BRKMW_PDokID = Tmp.BZp_BZpID
 WHERE BRKMW_PNumer <> CASE WHEN IsNull(Tmp.BZp_NumerObcy, '')<>'' THEN Tmp.BZp_NumerObcy ELSE Tmp.BZp_NumerPelny END
  END
  SET NOCOUNT OFF

GO
CREATE TRIGGER [CDN].[BnkZapisy_InsertUpdateDelete_PrzeliczAgregaty_Trigger]
  ON [CDN].[BnkZapisy]
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
Declare @BRa_Waluta_Inserted NVarchar(3)
Declare @BRa_Waluta_Deleted  NVarchar(3)
--Aktualizacja obrotów raportu przy kasowaniu zapisów
  IF EXISTS (SELECT deleted.BZp_BZpID FROM deleted)
  BEGIN
 SELECT @BRa_Waluta_Deleted = BRa_Waluta FROM CDN.BnkRachunki JOIN deleted ON (BRa_BRaID = deleted.BZp_BRaID)
 UPDATE CDN.BnkRaporty
 SET
 CDN.BnkRaporty.BRp_PrzychodySys =
 (SELECT IsNull(SUM(CASE BZp_Kierunek WHEN 1 THEN BZp_KwotaSys ELSE 0 END), 0) FROM cdn.BnkZapisy WHERE BZp_BRpId = CDN.BnkRaporty.BRp_BRpId),
 CDN.BnkRaporty.BRp_RozchodySys  =
 (SELECT IsNull(SUM(CASE BZp_Kierunek WHEN -1 THEN BZp_KwotaSys ELSE 0 END), 0) FROM cdn.BnkZapisy WHERE BZp_BRpId = CDN.BnkRaporty.BRp_BRpId),
 CDN.BnkRaporty.BRp_Przychody =
 (SELECT IsNull(SUM(CASE BZp_Kierunek WHEN 1 THEN (CASE @BRa_Waluta_Deleted WHEN '' THEN BZp_KwotaSys ELSE BZp_Kwota END) ELSE 0 END), 0) FROM cdn.BnkZapisy WHERE BZp_BRpId = CDN.BnkRaporty.BRp_BrpId),
 CDN.BnkRaporty.BRp_Rozchody =
 (SELECT IsNull(SUM(CASE BZp_Kierunek WHEN -1 THEN (CASE @BRa_Waluta_Deleted WHEN '' THEN BZp_KwotaSys ELSE BZp_Kwota END) ELSE 0 END), 0) FROM cdn.BnkZapisy WHERE BZp_BRpId = CDN.BnkRaporty.BRp_BrpId)
 FROM deleted JOIN CDN.BnkRaporty ON CDN.BnkRaporty.BRp_BRpId = deleted.Bzp_BRpId
 WHERE NOT EXISTS (SELECT inserted.BZp_BZpID FROM inserted WHERE inserted.BZp_BZpID = deleted.BZp_BZpID)
  END
--Aktualizacja obrotów raportu przy dodawaniu/zmianie zapisów
  IF EXISTS (SELECT inserted.BZp_BZpID FROM inserted)
    AND (UPDATE(BZp_Kwota) OR UPDATE(BZp_KwotaSys) OR UPDATE(BZp_Kierunek) OR UPDATE(BZp_Waluta))
  BEGIN
    SELECT @BRa_Waluta_Inserted = BRa_Waluta FROM CDN.BnkRachunki JOIN inserted ON (BRa_BRaID = inserted.BZp_BRaID)
 UPDATE CDN.BnkRaporty
 SET
 CDN.BnkRaporty.BRp_PrzychodySys =
 (SELECT IsNull(SUM(CASE BZp_Kierunek WHEN 1 THEN BZp_KwotaSys ELSE 0 END), 0) FROM cdn.BnkZapisy WHERE BZp_BRpId = CDN.BnkRaporty.BRp_BRpId),
 CDN.BnkRaporty.BRp_RozchodySys  =
 (SELECT IsNull(SUM(CASE BZp_Kierunek WHEN -1 THEN BZp_KwotaSys ELSE 0 END), 0) FROM cdn.BnkZapisy WHERE BZp_BRpId = CDN.BnkRaporty.BRp_BRpId),
 CDN.BnkRaporty.BRp_Przychody =
 (SELECT IsNull(SUM(CASE BZp_Kierunek WHEN 1 THEN (CASE @BRa_Waluta_Inserted WHEN '' THEN BZp_KwotaSys ELSE BZp_Kwota END) ELSE 0 END), 0) FROM cdn.BnkZapisy WHERE BZp_BRpId = CDN.BnkRaporty.BRp_BrpId),
 CDN.BnkRaporty.BRp_Rozchody =
 (SELECT IsNull(SUM(CASE BZp_Kierunek WHEN -1 THEN (CASE @BRa_Waluta_Inserted WHEN '' THEN BZp_KwotaSys ELSE BZp_Kwota END) ELSE 0 END), 0) FROM cdn.BnkZapisy WHERE BZp_BRpId = CDN.BnkRaporty.BRp_BrpId)
    FROM inserted JOIN CDN.BnkRaporty ON CDN.BnkRaporty.BRp_BRpId = inserted.Bzp_BRpId
  END
/*
--Aktualizacja obrotów raportu przy kasowaniu zapisów
  IF EXISTS (SELECT * FROM deleted)
  BEGIN
  select @BRa_Waluta_Deleted = BRa_Waluta from CDN.BnkRachunki JOIN deleted ON (BRa_BRaID=deleted.BZp_BRaID)
    UPDATE CDN.BnkRaporty
    SET
    CDN.BnkRaporty.BRp_PrzychodySys =
    CDN.BnkRaporty.BRp_PrzychodySys -
    (SELECT SUM(CASE deleted.BZp_Kierunek WHEN 1 THEN deleted.BZp_KwotaSys ELSE 0 END) FROM deleted WHERE deleted.BZp_BRpId = CDN.BnkRaporty.Brp_BrpId),
    CDN.BnkRaporty.BRp_RozchodySys  =
    CDN.BnkRaporty.BRp_RozchodySys -
    (SELECT SUM(CASE deleted.BZp_Kierunek WHEN -1 THEN deleted.BZp_KwotaSys ELSE 0 END) FROM deleted WHERE deleted.BZp_BRpId = CDN.BnkRaporty.Brp_BrpId),
    CDN.BnkRaporty.BRp_Przychody =
    CDN.BnkRaporty.BRp_Przychody -
    (SELECT SUM(CASE deleted.BZp_Kierunek WHEN 1 THEN (Case @BRa_Waluta_Deleted When '' Then deleted.BZp_KwotaSys Else deleted.BZp_Kwota End) ELSE 0 END) FROM deleted WHERE deleted.BZp_BRpId = CDN.BnkRaporty.Brp_BrpId),
    CDN.BnkRaporty.BRp_Rozchody  =
    CDN.BnkRaporty.BRp_Rozchody -
    (SELECT SUM(CASE deleted.BZp_Kierunek WHEN -1 THEN (Case @BRa_Waluta_Deleted When '' Then deleted.BZp_KwotaSys Else deleted.BZp_Kwota End) ELSE 0 END) FROM deleted WHERE deleted.BZp_BRpId = CDN.BnkRaporty.Brp_BrpId)
    FROM deleted JOIN CDN.BnkRaporty ON deleted.Bzp_BRpId = CDN.BnkRaporty.BRp_BRpId
  END
--Aktualizacja wartości nagłówka przy dodawaniu/edycji zapisów
 select @BRa_Waluta_Inserted = BRa_Waluta from CDN.BnkRachunki JOIN inserted ON (BRa_BRaID=inserted.BZp_BRaID)
  UPDATE CDN.BnkRaporty
  SET
  CDN.BnkRaporty.BRp_PrzychodySys =
  CDN.BnkRaporty.BRp_PrzychodySys +
  (SELECT SUM(CASE inserted.BZp_Kierunek WHEN 1 THEN (inserted.BZp_KwotaSys) ELSE 0 END) FROM inserted WHERE inserted.BZp_BRpId = CDN.BnkRaporty.Brp_BrpId),
  CDN.BnkRaporty.BRp_RozchodySys  =
  CDN.BnkRaporty.BRp_RozchodySys +
  (SELECT SUM(CASE inserted.BZp_Kierunek WHEN -1 THEN (inserted.BZp_KwotaSys)ELSE 0 END) FROM inserted WHERE inserted.BZp_BRpId = CDN.BnkRaporty.Brp_BrpId),
  CDN.BnkRaporty.BRp_Przychody =
  CDN.BnkRaporty.BRp_Przychody +
  (SELECT SUM(CASE inserted.BZp_Kierunek WHEN 1 THEN (Case @BRa_Waluta_Inserted When '' Then inserted.BZp_KwotaSys Else inserted.BZp_Kwota End) ELSE 0 END) FROM inserted WHERE inserted.BZp_BRpId = CDN.BnkRaporty.Brp_BrpId),
  CDN.BnkRaporty.BRp_Rozchody  =
  CDN.BnkRaporty.BRp_Rozchody +
  (SELECT SUM(CASE inserted.BZp_Kierunek WHEN -1 THEN (Case @BRa_Waluta_Inserted When '' Then inserted.BZp_KwotaSys Else inserted.BZp_Kwota End) ELSE 0 END) FROM inserted WHERE inserted.BZp_BRpId = CDN.BnkRaporty.Brp_BrpId)
  FROM inserted JOIN CDN.BnkRaporty ON inserted.Bzp_BRpId = CDN.BnkRaporty.BRp_BRpId
*/
SET NOCOUNT OFF
