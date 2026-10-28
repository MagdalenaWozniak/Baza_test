CREATE TABLE [CDN].[DokDefinicje] (
    [DDf_DDfID]           INT            IDENTITY (1, 1) NOT NULL,
    [DDf_Klasa]           INT            NOT NULL,
    [DDf_Symbol]          VARCHAR (5)    NOT NULL,
    [DDf_Nazwa]           NVARCHAR (256) NOT NULL,
    [DDf_Nieaktywna]      TINYINT        CONSTRAINT [DF_DDf_Nieaktywna] DEFAULT ((0)) NOT NULL,
    [DDf_Numeracja]       NVARCHAR (50)  NOT NULL,
    [DDf_SeriaOperatora]  TINYINT        NOT NULL,
    [DDf_PowDDfID]        INT            NULL,
    [DDf_PowSeria]        NVARCHAR (5)   NULL,
    [DDf_KatalogObdId]    INT            NULL,
    [DDf_TS_Export]       DATETIME       NULL,
    [DDf_ImportAppId]     VARCHAR (5)    NULL,
    [DDf_ImportRowId]     VARCHAR (36)   NULL,
    [DDf_ImportSchematID] INT            NULL,
    [DDf_OpeZalID]        INT            NULL,
    [DDf_StaZalId]        INT            NULL,
    [DDf_TS_Zal]          DATETIME       NOT NULL,
    [DDf_OpeModID]        INT            NULL,
    [DDf_StaModId]        INT            NULL,
    [DDf_TS_Mod]          DATETIME       NOT NULL,
    [DDf_KierunekOrg]     AS             (case when [DDF_KLASA]=(650) OR [DDF_KLASA]=(600) OR [DDF_KLASA]=(313) OR [DDF_KLASA]=(307) OR [DDF_KLASA]=(301) OR [DDF_KLASA]=(224) OR [DDF_KLASA]=(201) OR [DDF_KLASA]=(117) OR [DDF_KLASA]=(114) OR [DDF_KLASA]=(102) then (-1) when [DDF_KLASA]=(314) OR [DDF_KLASA]=(308) OR [DDF_KLASA]=(306) OR [DDF_KLASA]=(305) OR [DDF_KLASA]=(302) OR [DDF_KLASA]=(221) OR [DDF_KLASA]=(202) OR [DDF_KLASA]=(101) then (1) else (0) end),
    [DDf_OpeModKod]       VARCHAR (20)   CONSTRAINT [DF_DDf_OpeModKod] DEFAULT ('') NOT NULL,
    [DDf_OpeModNazwisko]  NVARCHAR (50)  CONSTRAINT [DF_DDf_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DDf_OpeZalKod]       VARCHAR (20)   CONSTRAINT [DF_DDf_OpeZalKod] DEFAULT ('') NOT NULL,
    [DDf_OpeZalNazwisko]  NVARCHAR (50)  CONSTRAINT [DF_DDf_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [DDf_Primary] PRIMARY KEY CLUSTERED ([DDf_DDfID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DDfSymbol]
    ON [CDN].[DokDefinicje]([DDf_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DDfKlasa]
    ON [CDN].[DokDefinicje]([DDf_Klasa] ASC, [DDf_Symbol] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DDfGUID]
    ON [CDN].[DokDefinicje]([DDf_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DokDefinicje_InsertUpdate_Trigger
  ON CDN.DokDefinicje
  FOR INSERT,UPDATE
AS
  SET NOCOUNT ON
IF (SELECT COUNT (*) FROM
  (SELECT d.DDf_Symbol FROM CDN.DokDefinicje d INNER JOIN inserted i on d.DDf_Symbol = i.DDf_Symbol
  WHERE d.DDf_Nieaktywna = 0
  GROUP BY d.DDf_Symbol
  HAVING COUNT(*) > 1
  ) AS InnerSelect ) > 0
 BEGIN
  RAISERROR('##OPT32295##', 16, 1) -- RAISERROR('Nie można mieć aktywnych dwóch definicji dokumentów o takim samym symbolu', 16,1);
  SET NOCOUNT OFF
  ROLLBACK TRAN
  RETURN
 END
-- Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji
  IF EXISTS (SELECT * FROM deleted
             JOIN inserted ON deleted.DDf_DDfId = inserted.DDf_DDfId
             WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
            )
  BEGIN
  -- Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w TraNag
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.TraNag ON deleted.DDf_DDfId = CDN.TraNag.TrN_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32296##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w nagłówkach transakcji (TraNag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w DetalStanowiska
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdPa
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32297##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdFS
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32297##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdKP
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32297##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdKW
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32297##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdPKA
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32297##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w BnkRaporty
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.BnkRachunki ON deleted.DDf_DDfId = CDN.BnkRachunki.BRa_DDfId
               JOIN CDN.BnkRaporty ON CDN.BnkRaporty.BRp_BRaID=CDN.BnkRachunki.BRa_BRaId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32298##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w rachunkach bankowych (BnkRachunki). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w BnkZapisy
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.BnkZapisy ON deleted.DDf_DDfId = CDN.BnkZapisy.BZp_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32299##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w zapisach kasowo-bankowych (BnkZapisy). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w BnkZdarzenia
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.BnkZdarzenia ON deleted.DDf_DDfId = CDN.BnkZdarzenia.BZd_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32300##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w zdarzeniach kasowo-bankowych (BnkZdarzenia). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w BnkDokNag
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.BnkDokNag ON deleted.DDf_DDfId = CDN.BnkDokNag.BDN_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32301##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w dokumentach kasowo-bankowych (BnkDokNag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w BnkRozKwoty
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.BnkRozKwoty ON deleted.DDf_DDfId = CDN.BnkRozKwoty.BRK_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32302##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w różnicach kursowych (BnkRozKwoty). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w BnkRozKwotyMW
    IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.BnkRozKwotyMW ON deleted.DDf_DDfId = CDN.BnkRozKwotyMW.BRKMW_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32303##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w różnicach kursowych MW (BnkRozKwotyMW). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w EWidDodNag
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.EwidDodNag ON deleted.DDf_DDfId = CDN.EwidDodNag.EDN_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32304##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w ewidencji dodatkowej(EwidDodNag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w ListyPlac, Umowy i DodatkiHist
    if exists (select * from deleted
               join inserted on deleted.ddf_ddfid = inserted.ddf_ddfid
               join cdn.listyplac on deleted.ddf_ddfid = cdn.listyplac.lpl_ddfid
               where deleted.ddf_symbol<>inserted.ddf_symbol or deleted.ddf_numeracja<>inserted.ddf_numeracja or deleted.ddf_klasa<>inserted.ddf_klasa
              )
    begin
      RAISERROR('##OPT32305##', 16, 1) -- raiserror('Definicja dokumentu jest używana w listach płac. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      rollback tran
      set nocount off
      return
    end
    if exists (select * from deleted
               join inserted on deleted.ddf_ddfid = inserted.ddf_ddfid
               join cdn.umowy on deleted.ddf_ddfid = cdn.umowy.umw_listaplacsymbol
               where deleted.ddf_symbol<>inserted.ddf_symbol or deleted.ddf_numeracja<>inserted.ddf_numeracja or deleted.ddf_klasa<>inserted.ddf_klasa
              )
    begin
      RAISERROR('##OPT32306##', 16, 1) -- raiserror('Definicja dokumentu jest używana w umowach cywilnoprawnych pracownika. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      rollback tran
      set nocount off
      return
    end
 if exists (select * from deleted
               join inserted on deleted.ddf_ddfid = inserted.ddf_ddfid
               join cdn.umowy on deleted.ddf_ddfid = cdn.umowy.umw_ddfid
               where deleted.ddf_symbol<>inserted.ddf_symbol or deleted.ddf_numeracja<>inserted.ddf_numeracja or deleted.ddf_klasa<>inserted.ddf_klasa
              )
    begin
      RAISERROR('##OPT32306##', 16, 1) -- raiserror('Definicja dokumentu jest używana w umowach cywilnoprawnych pracownika. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      rollback tran
      set nocount off
      return
    end
    if exists (select * from deleted
               join inserted on deleted.ddf_ddfid = inserted.ddf_ddfid
               join cdn.dodatkihist on deleted.ddf_ddfid = cdn.dodatkihist.doh_listaplacsymbol
               where deleted.ddf_symbol<>inserted.ddf_symbol or deleted.ddf_numeracja<>inserted.ddf_numeracja or deleted.ddf_klasa<>inserted.ddf_klasa
              )
    begin
      RAISERROR('##OPT32307##', 16, 1) -- raiserror('Definicja dokumentu jest używana w dodatkach pracownika. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      rollback tran
      set nocount off
      return
    end
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w NotyOdsNag
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.NotyOdsNag ON deleted.DDf_DDfId = CDN.NotyOdsNag.NON_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32308##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w notach odsetkowych(NotyOdsNag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w KsiDokNag
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.KsiDokNag ON deleted.DDf_DDfId = CDN.KsiDokNag.KDN_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32309##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w dokumentach księgowych(KsiDokNag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w BONag
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.BONag ON deleted.DDf_DDfId = CDN.BONag.BON_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32310##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w dokumentach bilansu otwarcia(BONag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w CRMKontakty
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.CRMKontakty ON deleted.DDf_DDfId = CDN.CRMKontakty.CRK_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32311##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w kontaktach CRM(CRMKontakty). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w OfertyDok
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.OfertyDok ON deleted.DDf_DDfId = CDN.OfertyDok.OfD_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32312##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w tabeli OfertyDok. Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w DokNag
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.DokNag ON deleted.DDf_DDfId = CDN.DokNag.DON_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32313##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w obiegu dokumentów(DokNag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w Wyplaty
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.Wyplaty ON deleted.DDf_DDfId = CDN.Wyplaty.WPL_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32314##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w wypłatach(Wyplaty). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w SrsZlecenia
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.SrsZlecenia ON deleted.DDf_DDfId = CDN.SrsZlecenia.SrZ_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32315##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w zleceniach serwisowych(SrsZlecenia). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w FaCyklNag
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.FaCyklNag ON deleted.DDf_DDfId = CDN.FaCyklNag.FCN_DdfID
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32316##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w fakturach cyklicznych(FaCyklNag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w DlgNag
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.DlgNag ON deleted.DDf_DDfId = CDN.DlgNag.DlN_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32317##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w delegacjach (DlgNag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji wykorzystanej w DekretyNag
  IF EXISTS (SELECT * FROM deleted
               JOIN inserted   ON deleted.DDf_DDfId = inserted.DDf_DDfId
               JOIN CDN.DekretyNag ON deleted.DDf_DDfId = CDN.DekretyNag.DeN_DDfId
               WHERE deleted.DDf_Symbol<>inserted.DDf_Symbol OR deleted.DDf_Numeracja<>inserted.DDf_Numeracja OR deleted.DDf_Klasa<>inserted.DDf_Klasa
              )
    BEGIN
      RAISERROR('##OPT32318##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana w kompensatach/różnicach kursowych (DekretyNag). Nie można zmieniać jej symbolu, schematu numeracji ani klasy.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Kasowanie wskanika wyeksportowania
If Not Update (DDf_TS_Export) And Exists (Select * From inserted Where DDf_TS_Export Is Not Null)
  Update CDN.DokDefinicje Set DDf_TS_Export = Null Where DDf_DDfId In (Select DDf_DDfId From inserted Where DDf_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where DDf_ImportRowId Is Null Or DDf_ImportRowId = '')
  Update CDN.DokDefinicje Set DDf_ImportRowId = NewId()
  Where DDf_DDfId In (Select DDf_DDfId From inserted Where DDf_ImportRowId Is Null Or DDf_ImportRowId = '')
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.DokDefinicje_Delete_Trigger
  ON CDN.DokDefinicje
  FOR DELETE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy zmieniono symbol, numerację lub klasę w definicji
   IF EXISTS (SELECT * FROM deleted
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdPa
              )
    BEGIN
      RAISERROR('##OPT32319##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej. ',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT * FROM deleted
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdFS
              )
    BEGIN
      RAISERROR('##OPT32319##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT * FROM deleted
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdKP
              )
    BEGIN
      RAISERROR('##OPT32319##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT * FROM deleted
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdKW
              )
    BEGIN
      RAISERROR('##OPT32319##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT * FROM deleted
               JOIN CDN.DetalStanowiska  ON deleted.DDf_DDfId = CDN.DetalStanowiska.dsta_ddfIdPKA
              )
    BEGIN
      RAISERROR('##OPT32319##', 16, 1) -- RAISERROR('Definicja dokumentu jest używana na stanowiskach Detalu lub sprzedaży mobilnej.',16,1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  if exists (select * from deleted
               join cdn.listyplac  on deleted.ddf_ddfid = cdn.listyplac.lpl_ddfid
              )
    begin
      RAISERROR('##OPT32320##', 16, 1) -- raiserror('Nie można usunąć rekordu. Definicja dokumentu jest używana w listach płac.',16,1)
      rollback tran
      set nocount off
      return
    end
  if exists (select * from deleted
               join cdn.umowy  on deleted.ddf_ddfid = cdn.umowy.umw_listaplacsymbol
              )
    begin
      RAISERROR('##OPT32321##', 16, 1) -- raiserror('Nie można usunąć rekordu. Definicja dokumentu jest używana w umowach cywilnoprawnych pracownika.',16,1)
      rollback tran
      set nocount off
      return
    end
  if exists (select * from deleted
               join cdn.dodatkihist  on deleted.ddf_ddfid = cdn.dodatkihist.doh_listaplacsymbol
              )
    begin
      RAISERROR('##OPT32322##', 16, 1) -- raiserror('Nie można usunąć rekordu. Definicja dokumentu jest używana w dodatkach pracownika.',16,1)
      rollback tran
      set nocount off
      return
    end
  SET NOCOUNT OFF
