CREATE TABLE [CDN].[BnkRozKwotyMW] (
    [BRKMW_BRKMWID]           INT             IDENTITY (1, 1) NOT NULL,
    [BRKMW_BRaID]             INT             NULL,
    [BRKMW_Kwota]             DECIMAL (15, 2) NOT NULL,
    [BRKMW_KwotaSysL]         DECIMAL (15, 2) NOT NULL,
    [BRKMW_KwotaSysP]         DECIMAL (15, 2) NOT NULL,
    [BRKMW_RoznicaKursowaSys] DECIMAL (15, 2) NOT NULL,
    [BRKMW_DDfId]             INT             NOT NULL,
    [BRKMW_NumerString]       VARCHAR (31)    NOT NULL,
    [BRKMW_NumerNr]           INT             NOT NULL,
    [BRKMW_NumerPelny]        AS              ([CDN].[FN_NUMERPELNY]([BRKMW_NUMERNR],[BRKMW_NUMERSTRING])),
    [BRKMW_DataDok]           DATETIME        NOT NULL,
    [BRKMW_LDokTyp]           SMALLINT        NULL,
    [BRKMW_LDokID]            INT             NULL,
    [BRKMW_PDokTyp]           SMALLINT        NULL,
    [BRKMW_PDokID]            INT             NULL,
    [BRKMW_Waluta]            VARCHAR (3)     NULL,
    [BRKMW_LPodTyp]           INT             NULL,
    [BRKMW_LPodID]            INT             NULL,
    [BRKMW_PPodTyp]           INT             NULL,
    [BRKMW_PPodID]            INT             NULL,
    [BRKMW_LNumer]            NVARCHAR (256)  NULL,
    [BRKMW_PNumer]            NVARCHAR (256)  NULL,
    [BRKMW_DekId]             INT             NULL,
    [BRKMW_Dek2Id]            INT             NULL,
    [BRKMW_PreDekID]          INT             NULL,
    [BRKMW_KPRId]             INT             NULL,
    [BRKMW_KolumnaKPR]        TINYINT         NOT NULL,
    [BRKMW_KontoWn1]          VARCHAR (50)    NOT NULL,
    [BRKMW_KontoMa1]          VARCHAR (50)    NOT NULL,
    [BRKMW_OpeZalId]          INT             NULL,
    [BRKMW_StaZalId]          INT             NULL,
    [BRKMW_TS_Zal]            DATETIME        NOT NULL,
    [BRKMW_OpeModId]          INT             NULL,
    [BRKMW_StaModId]          INT             NULL,
    [BRKMW_TS_Mod]            DATETIME        NOT NULL,
    [BRKMW_LWynagrodzenie]    AS              ([CDN].[CzyWynagrodzenie]([BRKMW_LDokTyp],[BRKMW_LDokId])),
    [BRKMW_PWynagrodzenie]    AS              ([CDN].[CzyWynagrodzenie]([BRKMW_PDokTyp],[BRKMW_PDokId])),
    [BRKMW_RycID]             INT             NULL,
    [BRKMW_KolumnaRyc]        TINYINT         NOT NULL,
    [BRKMW_ZakID]             INT             NULL,
    [BRKMW_OpeModKod]         VARCHAR (20)    CONSTRAINT [DF_BRKMW_OpeModKod] DEFAULT ('') NOT NULL,
    [BRKMW_OpeModNazwisko]    NVARCHAR (50)   CONSTRAINT [DF_BRKMW_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BRKMW_OpeZalKod]         VARCHAR (20)    CONSTRAINT [DF_BRKMW_OpeZalKod] DEFAULT ('') NOT NULL,
    [BRKMW_OpeZalNazwisko]    NVARCHAR (50)   CONSTRAINT [DF_BRKMW_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [BRKMW_Primary] PRIMARY KEY CLUSTERED ([BRKMW_BRKMWID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_BRKMW_Kwota] CHECK ([BRKMW_KWOTA]>(0)),
    CONSTRAINT [FK_BRKMWDokDef] FOREIGN KEY ([BRKMW_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID])
);


GO
CREATE NONCLUSTERED INDEX [BRKMWDokDef]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWNumer]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_NumerString] ASC, [BRKMW_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRKMWNumerPelny]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_NumerPelny] ASC, [BRKMW_BRKMWID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWDekrety]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_DekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWDekrety2]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_Dek2Id] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWPreDekrety]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_PreDekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWKPR]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_KPRId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWRyc]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_RycID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRKMWChrono]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_BRaID] ASC, [BRKMW_DataDok] ASC, [BRKMW_BRKMWID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWDokL]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_LDokID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWDokP]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_PDokTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWDokDataL]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_LDokID] ASC, [BRKMW_DataDok] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKMWDokDataP]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_PDokTyp] ASC, [BRKMW_PDokID] ASC, [BRKMW_DataDok] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRKMWRozKur]
    ON [CDN].[BnkRozKwotyMW]([BRKMW_RoznicaKursowaSys] ASC, [BRKMW_NumerPelny] ASC, [BRKMW_BRKMWID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkRozKwotyMW_DeleteHandler
  ON CDN.BnkRozKwotyMW
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(SELECT D.BRKMW_PreDekID FROM Deleted D WHERE D.BRKMW_PreDekID IS NOT NULL)
  DELETE CDN.DekretyNag
  FROM CDN.DekretyNag, deleted
  WHERE deleted.BRKMW_PreDekID = CDN.DekretyNag.DeN_DeNID
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkRozKwotyMW_InsertUpdateDelete_Trigger
  ON CDN.BnkRozKwotyMW
  FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
IF EXISTS(SELECT * FROM inserted) OR EXISTS(SELECT * FROM deleted)
BEGIN
-- Sprawdzenie kasowania zaksiegowanych rekordow
If Not Exists (Select * From inserted)
Begin
 If Exists (Select * From deleted Where BRKMW_DekId Is Not Null Or BRKMW_KPRId Is Not Null Or BRKMW_RycID Is Not Null)
  Begin
 RAISERROR('##OPT32268##', 16, 1) -- RAISERROR('Nie można kasować zaksięgowanych różnic kursowych w Magazynie Walut.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  End
 If Exists (Select * From deleted Where BRKMW_Dek2Id Is Not Null)
  Begin
   RAISERROR('##OPT32269##', 16, 1) -- RAISERROR('Nie można kasować zaksięgowanych rozliczeń w Magazynie Walut.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  End
End
-- Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
  IF EXISTS
    (SELECT * FROM inserted WHERE BRKMW_DekId IS NOT NULL AND NOT EXISTS (SELECT * FROM CDN.DekretyNag WHERE DeN_Zrodlo = 43 AND BRKMW_DekID = DeN_DeNID ))
  OR EXISTS
    (SELECT * FROM inserted WHERE BRKMW_Dek2Id IS NOT NULL AND NOT EXISTS (SELECT * FROM CDN.DekretyNag WHERE DeN_Zrodlo = 43 AND BRKMW_Dek2ID = DeN_DeNID ))
    BEGIN
      RAISERROR('##OPT32242##%%tabela%%=DekretyNag##', 16, 1) -- RAISERROR('Brak wartości w tabeli nadrzędnej (DekretyNag) ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
   END
-- Sprawdzanie obecności wierszy w tabeli nadrzędnej ZapisyKPR
  IF EXISTS
    (SELECT * FROM inserted
     LEFT OUTER JOIN CDN.ZapisyKPR ON BRKMW_KPRID = KPR_KPRId AND KPR_Zrodlo = 43
     WHERE KPR_KPRId IS NULL
     AND BRKMW_KPRID IS NOT NULL
    )
    BEGIN
      RAISERROR('##OPT32242##%%tabela%%=ZapisyKPR##', 16, 1) -- RAISERROR('Brak wartości w tabeli nadrzędnej (ZapisyKPR) ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
   END
-- Sprawdzenie unikalnosci NumerPelny
  If Exists (
    Select * From inserted i Join CDN.BnkRozKwotyMW b On i.BRKMW_NumerPelny = b.BRKMW_NumerPelny
    Where i.BRKMW_NumerNr<>-1 And i.BRKMW_BRKMWId <> b.BRKMW_BRKMWId
    )
    BEGIN
      RAISERROR('##OPT32262##%%indeks%%=NumerPelny##', 16, 1) -- RAISERROR('Duplikacja klucza NumerPelny ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
   END
--RAISERROR('bbbbb.', 16, 1)
--Aktualizacja zapisów źródłowych
DECLARE @BRKMWID        INT
DECLARE @LDokTyp        INT
DECLARE @LDokId         INT
DECLARE @PDokTyp        INT
DECLARE @PDokId         INT
DECLARE @LKwota         NUMERIC(15,2)
DECLARE @LKwotaRozMW    NUMERIC(15,2)
DECLARE @LKwotaSys      NUMERIC(15,2)
DECLARE @LKwotaRozSysMW NUMERIC(15,2)
DECLARE @PKwota         NUMERIC(15,2)
DECLARE @PKwotaRozMW    NUMERIC(15,2)
DECLARE @PKwotaSys      NUMERIC(15,2)
DECLARE @PKwotaRozSysMW NUMERIC(15,2)
DECLARE @LDataRozMW     DATETIME
DECLARE @PDataRozMW     DATETIME
DECLARE @LRozliczonoMW  INT
DECLARE @LRozliczono2MW INT
DECLARE @PRozliczonoMW  INT
DECLARE @PRozliczono2MW INT
DECLARE @LKierunek      INT
DECLARE @PKierunek      INT
DECLARE @LNumerDok      NVarchar(256)
DECLARE @PNumerDok      NVarchar(256)
DECLARE @LNumer         NVarchar(256)
DECLARE @PNumer         NVarchar(256)
DECLARE @LPodTyp        INT
DECLARE @PPodTyp        INT
DECLARE @LPodID         INT
DECLARE @PPodID         INT
DECLARE @LZapisAutomatyczny  SMALLINT
DECLARE @PZapisAutomatyczny  SMALLINT
DECLARE @LBRaID         INT
DECLARE @PBRaID         INT
DECLARE @LWaluta        NVarchar(3)
DECLARE @PWaluta        NVarchar(3)
--Kursor zawiera DokTyp i DokId wszystkich zmienionych dokumentów
DECLARE RozKwotyUpdated CURSOR LOCAL FAST_FORWARD FOR
  SELECT inserted.BRKMW_BRKMWID, inserted.BRKMW_LDokTyp, inserted.BRKMW_LDokId, inserted.BRKMW_PDokTyp, inserted.BRKMW_PDokId FROM inserted
  UNION
  SELECT deleted.BRKMW_BRKMWID, deleted.BRKMW_LDokTyp, deleted.BRKMW_LDokId, deleted.BRKMW_PDokTyp, deleted.BRKMW_PDokId FROM deleted
OPEN RozKwotyUpdated;
FETCH NEXT FROM RozKwotyUpdated INTO @BRKMWID, @LDokTyp, @LDokId, @PDokTyp, @PDokId;
--Aktualizacja kolejnych dokumentów
WHILE @@FETCH_STATUS = 0
BEGIN
  IF @LDokTyp<>2 AND @LDokTyp<>3 AND EXISTS (SELECT * FROM inserted WHERE inserted.BRKMW_BRKMWID = @BRKMWID)
  BEGIN
    RAISERROR('##OPT32270##', 16, 1) -- RAISERROR('Dokument po lewej stronie rozliczenia Magazynu Walut musi być zapisem kasowym/bankowym lub bilansem otwarcia Magazynu Walut.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  IF @LDokTyp=3
  SELECT @LKwota = BOMW_Kwota, @LKwotaSys = BOMW_KwotaSys, @LRozliczonoMW = BOMW_RozliczonoMW, @LRozliczono2MW = BOMW_Rozliczono2MW, @LKierunek = BOMW_Kierunek,
  @LNumerDok = Case When BOMW_NumerObcy <> '' Then BOMW_NumerObcy Else BOMW_NumerPelny End, @LNumer = BOMW_Numer,
  @LPodTyp = 0, @LPodID = 0,
  @LBRaID = BOMW_BRaID, @LZapisAutomatyczny = 0,  @LWaluta = BOMW_Waluta
  FROM CDN.BnkBOMW WHERE BOMW_BOMWId = @LDokId
 ELSE
  SELECT @LKwota = BZp_Kwota, @LKwotaSys = BZp_KwotaSys, @LRozliczonoMW = BZp_RozliczonoMW, @LRozliczono2MW = BZp_Rozliczono2MW, @LKierunek = BZp_Kierunek,
  @LNumerDok = Case When BZp_NumerObcy <> '' Then BZp_NumerObcy Else BZp_NumerPelny End, @LNumer = BZp_Numer,
  @LPodTyp = BZp_PodmiotTyp, @LPodID = BZp_PodmiotID,
  @LBRaID = BZp_BRaID, @LZapisAutomatyczny = BZp_ZapisAutomatyczny,  @LWaluta = BZp_Waluta
  FROM CDN.BnkZapisy WHERE BZp_BZpId = @LDokId
  IF @LKierunek<>-1 AND EXISTS (SELECT * FROM inserted WHERE inserted.BRKMW_BRKMWID = @BRKMWID)
  BEGIN
    RAISERROR('##OPT32270##', 16, 1) -- RAISERROR('Dokument po lewej stronie rozliczenia Magazynu Walut musi być zapisem KW lub bilansem otwarcia BOMWKW Magazynu Walut.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  IF @PDokTyp<>2 AND @PDokTyp<>3 AND EXISTS (SELECT * FROM inserted WHERE inserted.BRKMW_BRKMWID = @BRKMWID)
  BEGIN
    RAISERROR('##OPT32271##', 16, 1) -- RAISERROR('Dokument po prawej stronie rozliczenia Magazynu Walut musi być zapisem kasowym/bankowym lub bilansem otwarcia Magazynu Walut.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  IF @PDokTyp=3
  BEGIN
    --Pobieram dokument rozliczany z BnkBOMW
    SELECT @PKwota = BOMW_Kwota, @PKwotaSys = BOMW_KwotaSys, @PRozliczonoMW = BOMW_RozliczonoMW, @PRozliczono2MW = BOMW_Rozliczono2MW, @PKierunek = 1,
    @PNumerDok = Case When BOMW_NumerObcy <> '' Then BOMW_NumerObcy Else BOMW_NumerPelny End, @PNumer = BOMW_Numer,
    @PPodTyp = 0, @PPodID = 0,
    @PBRaID = BOMW_BRaID, @PZapisAutomatyczny = 0, @PWaluta = BOMW_Waluta
    FROM CDN.BnkBOMW WHERE BOMW_BOMWId = @PDokId
  END
  ELSE
  BEGIN
    --Pobieram dokument rozliczany z BnkZapisy
    SELECT @PKwota = BZp_Kwota, @PKwotaSys = BZp_KwotaSys, @PRozliczonoMW = BZp_RozliczonoMW, @PRozliczono2MW = BZp_Rozliczono2MW, @PKierunek = BZp_Kierunek,
    @PNumerDok = Case When BZp_NumerObcy <> '' Then BZp_NumerObcy Else BZp_NumerPelny End, @PNumer = BZp_Numer,
    @PPodTyp = BZp_PodmiotTyp, @PPodID = BZp_PodmiotID,
    @PBRaID = BZp_BRaID, @PZapisAutomatyczny = BZp_ZapisAutomatyczny, @PWaluta = BZp_Waluta
    FROM CDN.BnkZapisy WHERE BZp_BZpId = @PDokId
  END
  IF @PBRaID<>@LBRaID
  BEGIN
    RAISERROR('##OPT32272##', 16, 1) -- RAISERROR('Dokumenty rozliczane w Magazynie Walut muszą należeć do tego samego rejestru.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  IF @PWaluta<>@LWaluta
  BEGIN
    RAISERROR('##OPT32273##', 16, 1) -- RAISERROR('Dokumenty rozliczane w Magazynie Walut muszą mieć tą samą walutę.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  UPDATE CDN.BnkRozKwotyMW Set BRKMW_BRaID = @LBRaID, BRKMW_Waluta = @LWaluta, BRKMW_LNumer = @LNumer, BRKMW_PNumer = @PNumer,
  BRKMW_LPodTyp = @LPodTyp, BRKMW_LPodID = @LPodID, BRKMW_PPodTyp = @PPodTyp, BRKMW_PPodID = @PPodID
  Where BRKMW_BRKMWId = @BRKMWId
  --Obliczam sumę rozliczeń dla danego dokumentu
  SELECT
  @LKwotaRozMW = IsNull(SUM(BRKMW_Kwota),0),
  @LKwotaRozSysMW = IsNull(SUM(BRKMW_KwotaSysL),0),
  @LDataRozMW  = MAX(BRKMW_DataDok)
  FROM CDN.BnkRozKwotyMW
  WHERE BRKMW_LDokTyp = @LDokTyp AND BRKMW_LDokId = @LDokId
  --Sprawdzam, czy suma rozliczeń mieści się we właściwym przedziale
  IF @LKwotaRozMW < 0
  BEGIN
    RAISERROR('##OPT32274##', 16, 1) -- RAISERROR('Kwota rozliczana Magazynu Walut nie może być ujemna (dokument KW).', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  IF @LKwotaRozMW > @LKwota
  BEGIN
    IF @LRozliczonoMW = 2
       RAISERROR('##OPT32275##%%dokument%%=%s##', 16, 1, @LNumerDok) -- RAISERROR('Dokument %s został już całkowicie rozliczony w Magazynie Walut.', 16, 1, @LNumerDok)
    ELSE
       RAISERROR('##OPT32276##%%dokument%%=%s##', 16, 1, @LNumerDok) -- RAISERROR('Przekroczono wartość kwoty do rozliczenia %s w Magazynie Walut.', 16, 1, @LNumerDok)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  SELECT
  @PKwotaRozMW = IsNull(SUM(BRKMW_Kwota),0),
  @PKwotaRozSysMW = IsNull(SUM(BRKMW_KwotaSysP),0),
  @PDataRozMW  = MAX(BRKMW_DataDok)
  FROM CDN.BnkRozKwotyMW
  WHERE BRKMW_PDokTyp = @PDokTyp AND BRKMW_PDokId = @PDokId
  --Sprawdzam, czy suma rozliczeń mieści się we właściwym przedziale
  IF @PKwotaRozMW < 0
  BEGIN
    RAISERROR('##OPT32277##', 16, 1) -- RAISERROR('Kwota rozliczana w Magazynie Walut nie może być ujemna (dokument KP/BOMW).', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  IF @PKwotaRozMW > @PKwota
  BEGIN
    IF @PRozliczonoMW = 2
       RAISERROR('##OPT32275##%%dokument%%=%s##', 16, 1, @LNumerDok) -- RAISERROR('Dokument %s został już całkowicie rozliczony w Magazynie Walut.', 16, 1, @PNumerDok)
    ELSE
       RAISERROR('##OPT32276##%%dokument%%=%s##', 16, 1, @LNumerDok) -- RAISERROR('Przekroczono wartość kwoty do rozliczenia %s w Magazynie Walut.', 16, 1, @PNumerDok)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  --Sprawdzam, jak ustawić status rozliczenia
  IF @PKwotaRozMW = @PKwota SET @PRozliczonoMW  = 2 ELSE SET @PRozliczonoMW = 1
  IF @PKwotaRozMW <> 0      SET @PRozliczono2MW = 2 ELSE SET @PRozliczono2MW = 1
  --Aktualizuję dokumenty
    IF @LDokTyp=3
  UPDATE CDN.BnkBOMW SET BOMW_KwotaRozMW = @LKwotaRozMW, BOMW_KwotaRozSysMW = @LKwotaRozSysMW, BOMW_RozliczonoMW = @LRozliczonoMW, BOMW_Rozliczono2MW = @LRozliczono2MW, BOMW_DataRozMW = @LDataRozMW WHERE BOMW_BOMWId = @LDokId
 ELSE
  UPDATE CDN.BnkZapisy SET BZp_KwotaRozMW = @LKwotaRozMW, BZp_KwotaRozSysMW = @LKwotaRozSysMW, BZp_RozliczonoMW = @LRozliczonoMW, BZp_Rozliczono2MW = @LRozliczono2MW, BZp_DataRozMW = @LDataRozMW WHERE BZp_BZpId = @LDokId
  IF @PDokTyp=3
    UPDATE CDN.BnkBOMW SET BOMW_KwotaRozMW = @PKwotaRozMW, BOMW_KwotaRozSysMW = @PKwotaRozSysMW, BOMW_RozliczonoMW = @PRozliczonoMW, BOMW_Rozliczono2MW = @PRozliczono2MW, BOMW_DataRozMW = @PDataRozMW WHERE BOMW_BOMWId = @PDokId
  ELSE
    UPDATE CDN.BnkZapisy SET BZp_KwotaRozMW = @PKwotaRozMW, BZp_KwotaRozSysMW = @PKwotaRozSysMW, BZp_RozliczonoMW = @PRozliczonoMW, BZp_Rozliczono2MW = @PRozliczono2MW, BZp_DataRozMW = @PDataRozMW WHERE BZp_BZpId = @PDokId
  FETCH NEXT FROM RozKwotyUpdated INTO @BRKMWID, @LDokTyp, @LDokId, @PDokTyp, @PDokId;
END
CLOSE RozKwotyUpdated
--Aktualizacja różnicy kursowej MW raportu przy kasowaniu rozliczeń MW
  IF EXISTS (SELECT * FROM deleted)
  BEGIN
    UPDATE CDN.BnkRaporty
    SET
    CDN.BnkRaporty.BRp_RoznicaKursowaSysMW =
    CDN.BnkRaporty.BRp_RoznicaKursowaSysMW -
    (SELECT SUM(deleted.BRKMW_RoznicaKursowaSys) FROM deleted WHERE CDN.BnkRaporty.BRp_BRaID=deleted.BRKMW_BRaID AND deleted.BRKMW_DataDok>=CDN.BnkRaporty.Brp_DataDok AND (CDN.BnkRaporty.Brp_DataZam Is Null OR deleted.BRKMW_DataDok<=CDN.BnkRaporty.Brp_DataZam))
    FROM deleted JOIN CDN.BnkRaporty ON (CDN.BnkRaporty.BRp_BRaID=deleted.BRKMW_BRaID AND deleted.BRKMW_DataDok>=CDN.BnkRaporty.Brp_DataDok AND (CDN.BnkRaporty.Brp_DataZam Is Null OR deleted.BRKMW_DataDok<=CDN.BnkRaporty.Brp_DataZam))
    JOIN CDN.BnkRachunki ON CDN.BnkRachunki.BRa_BRaID=CDN.BnkRaporty.BRp_BRaID
  END
--Aktualizacja różnicy kursowej MW raportu przy dodawaniu/edycji rozliczeń MW
  UPDATE CDN.BnkRaporty
  SET
  CDN.BnkRaporty.BRp_RoznicaKursowaSysMW =
  CDN.BnkRaporty.BRp_RoznicaKursowaSysMW +
  (SELECT SUM(inserted.BRKMW_RoznicaKursowaSys) FROM inserted WHERE CDN.BnkRaporty.BRp_BRaID=inserted.BRKMW_BRaID AND inserted.BRKMW_DataDok>=CDN.BnkRaporty.Brp_DataDok AND (CDN.BnkRaporty.Brp_DataZam Is Null OR inserted.BRKMW_DataDok<=CDN.BnkRaporty.Brp_DataZam))
  FROM inserted JOIN CDN.BnkRaporty ON (CDN.BnkRaporty.BRp_BRaID=inserted.BRKMW_BRaID AND inserted.BRKMW_DataDok>=CDN.BnkRaporty.Brp_DataDok AND (CDN.BnkRaporty.Brp_DataZam Is Null OR inserted.BRKMW_DataDok<=CDN.BnkRaporty.Brp_DataZam))
  JOIN CDN.BnkRachunki ON CDN.BnkRachunki.BRa_BRaID=CDN.BnkRaporty.BRp_BRaID
END
SET NOCOUNT OFF
