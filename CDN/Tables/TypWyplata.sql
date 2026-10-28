CREATE TABLE [CDN].[TypWyplata] (
    [TWP_TwpId]                  INT             IDENTITY (1, 1) NOT NULL,
    [TWP_PdpId]                  INT             NOT NULL,
    [TWP_PdzId]                  INT             NOT NULL,
    [TWP_ParentId]               INT             NULL,
    [TWP_Nazwa]                  VARCHAR (40)    NOT NULL,
    [TWP_Nazwa2]                 NVARCHAR (50)   NOT NULL,
    [TWP_NazwaPelna]             NVARCHAR (127)  NOT NULL,
    [TWP_Skrot]                  NVARCHAR (40)   NOT NULL,
    [TWP_Skrot2]                 NVARCHAR (50)   NOT NULL,
    [TWP_RodzajZrodla]           INT             NOT NULL,
    [TWP_ZalPodat]               INT             NOT NULL,
    [TWP_ImPrzelZalPodat]        TINYINT         NOT NULL,
    [TWP_Koszty]                 INT             NOT NULL,
    [TWP_KodRNA]                 INT             NOT NULL,
    [TWP_SklZUS]                 INT             NOT NULL,
    [TWP_SklZdrow]               INT             NOT NULL,
    [TWP_NiePomniejszZdrow]      TINYINT         NOT NULL,
    [TWP_Korygowana]             TINYINT         NOT NULL,
    [TWP_WchodziDoWyplaty]       TINYINT         NOT NULL,
    [TWP_UwzglMin]               TINYINT         NOT NULL,
    [TWP_UwzglNadgodz]           TINYINT         NOT NULL,
    [TWP_OkresWyplaty]           INT             NOT NULL,
    [TWP_WplywaZalPodat]         TINYINT         NOT NULL,
    [TWP_WliczUrlop]             INT             NOT NULL,
    [TWP_WliczChor]              INT             NOT NULL,
    [TWP_WliczEkwiwal]           INT             NOT NULL,
    [TWP_StOkrWartosc]           NVARCHAR (41)   NOT NULL,
    [TWP_StOkrTyp]               INT             NOT NULL,
    [TWP_ZaOkrZwolLek]           TINYINT         NOT NULL,
    [TWP_AlgAlgorytm]            INT             NOT NULL,
    [TWP_AlgPotracenie]          TINYINT         NOT NULL,
    [TWP_AlgZaokraglenie]        DECIMAL (15, 2) NOT NULL,
    [TWP_AlgPotrNieobec]         TINYINT         NOT NULL,
    [TWP_AlgOdchylki]            TINYINT         NOT NULL,
    [TWP_AlgProcWynagr]          DECIMAL (15, 2) NOT NULL,
    [TWP_AlgStaz]                TINYINT         NOT NULL,
    [TWP_AlgStOkrTyp]            INT             NOT NULL,
    [TWP_AlgStOkrWartosc]        NVARCHAR (41)   NOT NULL,
    [TWP_AlgWspolcz]             DECIMAL (15, 2) NOT NULL,
    [TWP_AlgLiczbaDni]           INT             NOT NULL,
    [TWP_AlgLiczbaGodz]          INT             NOT NULL,
    [TWP_AlgBrutto]              TINYINT         NOT NULL,
    [TWP_AlgUrlop]               TINYINT         NOT NULL,
    [TWP_AlgAutomat]             TINYINT         NOT NULL,
    [TWP_AlgProcent]             DECIMAL (15, 2) NOT NULL,
    [TWP_AlgKwota]               DECIMAL (15, 2) NOT NULL,
    [TWP_AlgUzyjKwota]           TINYINT         NULL,
    [TWP_AlgStdWspolcz]          TINYINT         NOT NULL,
    [TWP_AlgIlosc]               DECIMAL (15, 2) NOT NULL,
    [TWP_AlgIloscMies]           INT             NOT NULL,
    [TWP_AlgStdIloscMies]        TINYINT         NOT NULL,
    [TWP_KosztyProc]             DECIMAL (15, 2) NOT NULL,
    [TWP_Zmienna1]               NVARCHAR (128)  NOT NULL,
    [TWP_Zmienna2]               NVARCHAR (128)  NOT NULL,
    [TWP_AktPoWyp1]              TINYINT         NOT NULL,
    [TWP_AktPoWyp2]              TINYINT         NOT NULL,
    [TWP_PriorytetZUS]           SMALLINT        NOT NULL,
    [TWP_PriorytetFIS]           SMALLINT        NOT NULL,
    [TWP_PriorytetKoszty]        SMALLINT        NOT NULL,
    [TWP_RodzajFIS]              SMALLINT        NOT NULL,
    [TWP_Kategoria]              INT             NOT NULL,
    [TWP_Podstawowe]             TINYINT         NOT NULL,
    [TWP_Standardowy]            SMALLINT        NOT NULL,
    [TWP_Zasadnicze]             TINYINT         NOT NULL,
    [TWP_RodzajPotracenia]       TINYINT         NOT NULL,
    [TWP_Wycofany]               TINYINT         NOT NULL,
    [TWP_AlgSposobZaokr]         TINYINT         NOT NULL,
    [TWP_Priorytet]              INT             NOT NULL,
    [TWP_AlgStOkrPlusTyp]        INT             NOT NULL,
    [TWP_AlgStOkrPlusWartosc]    NVARCHAR (40)   NOT NULL,
    [TWP_AlgStazSposob]          TINYINT         NOT NULL,
    [TWP_Ulga]                   SMALLINT        NOT NULL,
    [TWP_WzrId]                  INT             NULL,
    [TWP_AlgWzorzec]             NVARCHAR (2048) NOT NULL,
    [TWP_AlgRodzaj12]            SMALLINT        NOT NULL,
    [TWP_AlgSposobPomn]          SMALLINT        NOT NULL,
    [TWP_Nieaktywny]             TINYINT         NOT NULL,
    [TWP_AlgPodstDzielGodz]      TINYINT         NOT NULL,
    [TWP_AlgGodziny]             DATETIME        NOT NULL,
    [TWP_WliczPFRON]             TINYINT         NOT NULL,
    [TWP_KosztFirma]             TINYINT         NOT NULL,
    [TWP_OpisAnalitCzasPracy]    TINYINT         NOT NULL,
    [TWP_Kopia]                  INT             NULL,
    [TWP_PozycjaRP7]             INT             NOT NULL,
    [TWP_Wskaznik]               TINYINT         NOT NULL,
    [TWP_Umowa]                  TINYINT         NOT NULL,
    [TWP_WliczanyDoGUS]          SMALLINT        NOT NULL,
    [TWP_ZalPodProc]             DECIMAL (15, 2) NOT NULL,
    [TWP_PKZP]                   TINYINT         NOT NULL,
    [TWP_SwiadczFS]              TINYINT         NOT NULL,
    [TWP_TypWaluty]              TINYINT         NOT NULL,
    [TWP_NieZapisujZerowego]     TINYINT         CONSTRAINT [DF_TWP_NieZapisujZerowego] DEFAULT ((0)) NOT NULL,
    [TWP_AlgIloscMiesWszystkie]  TINYINT         CONSTRAINT [DF_TWP_AlgIloscMiesWszystkie] DEFAULT ((0)) NOT NULL,
    [TWP_AlgGodzinyDni]          TINYINT         CONSTRAINT [DF_TWP_AlgGodzinyDni] DEFAULT ((0)) NOT NULL,
    [TWP_ImportAppId]            VARCHAR (5)     NULL,
    [TWP_ImportRowId]            VARCHAR (36)    NULL,
    [TWP_TS_Export]              DATETIME        NULL,
    [TWP_OpeZalId]               INT             NULL,
    [TWP_StaZalId]               INT             NULL,
    [TWP_TS_Zal]                 DATETIME        NOT NULL,
    [TWP_OpeModId]               INT             NULL,
    [TWP_StaModId]               INT             NULL,
    [TWP_TS_Mod]                 DATETIME        NOT NULL,
    [TWP_ZajecieWynagr]          TINYINT         CONSTRAINT [DF_TWP_ZajecieWynagr] DEFAULT ((0)) NOT NULL,
    [TWP_DoliczNaKoncu]          TINYINT         CONSTRAINT [DF_TWP_DoliczNaKoncu] DEFAULT ((0)) NOT NULL,
    [TWP_AlgKnfWspolcz]          TINYINT         CONSTRAINT [DF_TWP_AlgKnfWspolcz] DEFAULT ((0)) NOT NULL,
    [TWP_OpeModKod]              VARCHAR (20)    CONSTRAINT [DF_TWP_OpeModKod] DEFAULT ('') NOT NULL,
    [TWP_OpeModNazwisko]         NVARCHAR (50)   CONSTRAINT [DF_TWP_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [TWP_OpeZalKod]              VARCHAR (20)    CONSTRAINT [DF_TWP_OpeZalKod] DEFAULT ('') NOT NULL,
    [TWP_OpeZalNazwisko]         NVARCHAR (50)   CONSTRAINT [DF_TWP_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [TWP_WliczChorPodwojnie]     TINYINT         CONSTRAINT [DF_TWP_WliczChorPodwojnie] DEFAULT ((0)) NOT NULL,
    [TWP_NieZapisujZerowegoPKZP] TINYINT         CONSTRAINT [DF_TWP_NieZapisujZerowegoPKZP] DEFAULT ((1)) NOT NULL,
    [TWP_WykazZUSRPA]            TINYINT         CONSTRAINT [DF_TWP_WykazZUSRPA] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [TWP_Primary] PRIMARY KEY CLUSTERED ([TWP_TwpId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TWPParent] FOREIGN KEY ([TWP_ParentId]) REFERENCES [CDN].[TypWyplata] ([TWP_TwpId]),
    CONSTRAINT [FK_TWPPdpLink] FOREIGN KEY ([TWP_PdpId]) REFERENCES [CDN].[PozDeklPIT] ([PDP_PdpId]),
    CONSTRAINT [FK_TWPPdzLink] FOREIGN KEY ([TWP_PdzId]) REFERENCES [CDN].[PozDeklZUS] ([PDZ_PdzId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TWYNazwa]
    ON [CDN].[TypWyplata]([TWP_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TWPPdpLink]
    ON [CDN].[TypWyplata]([TWP_PdpId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TWPPdzLink]
    ON [CDN].[TypWyplata]([TWP_PdzId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TWPWzorzec]
    ON [CDN].[TypWyplata]([TWP_WzrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TypWyplata_Update_Trigger
  ON CDN.TypWyplata
  FOR UPDATE
AS
  SET NOCOUNT ON
    IF EXISTS (SELECT * FROM deleted WHERE deleted.TWP_Standardowy <> 0
 and deleted.TWP_Standardowy <> 600 and deleted.TWP_Standardowy <> 601
 and deleted.TWP_Standardowy <> 602 and deleted.TWP_Standardowy <> 603
 and deleted.TWP_Standardowy <> 604 and deleted.TWP_Standardowy <> 605
 and deleted.TWP_Standardowy <> 606 and deleted.TWP_Standardowy <> 607)
--    IF NOT EXISTS (SELECT * FROM deleted WHERE deleted.TWP_Standardowy IN (0,600,601,602,603,604))
    BEGIN
      RAISERROR('##OPT32555##', 16, 1)--RAISERROR('Nie można modyfikować standardowego typu składnika wypłaty. ', 16, 1)--ERR_SQL_Place_NieMoznaModyfTypuSkladnikaSTS
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TypWyplata_InsertUpdate_Trigger
  ON CDN.TypWyplata
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
--kasowanie wskaźnika wyeksportowania
if not update (TWP_TS_Export) and exists (select * from inserted where TWP_TS_Export is not null)
 update cdn.TypWyplata set TWP_TS_Export = null
  where TWP_TwpId in (select TWP_TwpId from inserted where TWP_TS_Export is not null)
--ustawianie unikalnego identyfikatora
if exists (select * from inserted where TWP_ImportRowId is null or TWP_ImportRowId = '')
 update cdn.TypWyplata set TWP_ImportRowId = newid()
  where TWP_TwpId in (select TWP_TwpId from inserted where TWP_ImportRowId is null or TWP_ImportRowId = '')
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TypWyplata_Delete_Trigger
  ON CDN.TypWyplata
  FOR DELETE
AS
  SET NOCOUNT ON
 declare @id int
 select @id = twp_twpid from deleted
 if exists (select gps_gpsid from cdn.grupypotrskladniki where gps_parentid = @id)
    begin
      RAISERROR('##OPT32550##', 16, 1)--raiserror('Nie można usunąć typu wypłaty powiązanego z grupą ograniczeń potrąceń.', 16, 1)--ERR_SQL_Place_NieMoznaUsunacTypuSkladnikaGPR 32550
      rollback tran
      set nocount off
      return
    end
    -- Sprawdzanie, czy nie skasowano kontrahenta o Id=1 (nieokreślony)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.TWP_Standardowy <> 0)
    BEGIN
      RAISERROR('##OPT32551##', 16, 1)--RAISERROR('Nie można kasować standardowego typu składnika wypłaty. ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacTypuSkladnikaSTS 32551
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 if exists (select zaw_zawid from cdn.zajeciawynagr where zaw_twpid = @id)
    begin
      RAISERROR('##OPT32552##', 16, 1)--raiserror('Nie można usunąć typu wypłaty powiązanego z zajęciami wynagrodzenia pracownika.', 16, 1)--ERR_SQL_Place_NieMoznaUsunacTypuSkladnikaZAW 32552
      rollback tran
      set nocount off
      return
    end
 if exists (select twk_twkid from cdn.typwyplatagrupaskladniki where twk_twpid = @id)
    begin
      RAISERROR('##OPT32554##', 16, 1)--raiserror('Nie można usunąć typu wypłaty powiązanego z grupami typów wypłat.', 16, 1)--ERR_SQL_Place_NieMoznaUsunacTypuSkladnikaGrupy 32554
      rollback tran
      set nocount off
      return
    end
  SET NOCOUNT OFF
