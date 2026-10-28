CREATE TABLE [CDN].[BnkRozKwoty] (
    [BRK_BRKID]                   INT             IDENTITY (1, 1) NOT NULL,
    [BRK_Kwota]                   DECIMAL (15, 2) NOT NULL,
    [BRK_KwotaSysL]               DECIMAL (15, 2) NOT NULL,
    [BRK_KwotaSysP]               DECIMAL (15, 2) NOT NULL,
    [BRK_RoznicaKursowaSys]       DECIMAL (15, 2) NOT NULL,
    [BRK_DDfId]                   INT             NOT NULL,
    [BRK_NumerString]             VARCHAR (31)    NOT NULL,
    [BRK_NumerNr]                 INT             NOT NULL,
    [BRK_NumerPelny]              AS              ([CDN].[FN_NUMERPELNY]([BRK_NUMERNR],[BRK_NUMERSTRING])),
    [BRK_DataDok]                 DATETIME        NOT NULL,
    [BRK_Zwloka]                  INT             NOT NULL,
    [BRK_LDokTyp]                 SMALLINT        NULL,
    [BRK_LDokID]                  INT             NULL,
    [BRK_PDokTyp]                 SMALLINT        NULL,
    [BRK_PDokID]                  INT             NULL,
    [BRK_LPodTyp]                 INT             NULL,
    [BRK_LPodID]                  INT             NULL,
    [BRK_PPodTyp]                 INT             NULL,
    [BRK_PPodID]                  INT             NULL,
    [BRK_LBRaID]                  INT             NULL,
    [BRK_PBRaID]                  INT             NULL,
    [BRK_RozliczenieAutomatyczne] TINYINT         NULL,
    [BRK_ZapisAutomatyczny]       SMALLINT        NULL,
    [BRK_Waluta]                  VARCHAR (3)     NULL,
    [BRK_LNumer]                  NVARCHAR (256)  NULL,
    [BRK_PNumer]                  NVARCHAR (256)  NULL,
    [BRK_LKwota]                  DECIMAL (15, 2) NULL,
    [BRK_PKwota]                  DECIMAL (15, 2) NULL,
    [BRK_DekId]                   INT             NULL,
    [BRK_Dek2Id]                  INT             NULL,
    [BRK_PreDekID]                INT             NULL,
    [BRK_PreDek2ID]               INT             NULL,
    [BRK_KPRId]                   INT             NULL,
    [BRK_KolumnaKPR]              TINYINT         NOT NULL,
    [BRK_KontoWn1]                VARCHAR (50)    NOT NULL,
    [BRK_KontoMa1]                VARCHAR (50)    NOT NULL,
    [BRK_KontoWn2]                VARCHAR (50)    NOT NULL,
    [BRK_KontoMa2]                VARCHAR (50)    NOT NULL,
    [BRK_AutoOffLine]             SMALLINT        NOT NULL,
    [BRK_TS_Export]               DATETIME        NULL,
    [BRK_ImportAppId]             VARCHAR (5)     NULL,
    [BRK_ImportRowId]             VARCHAR (36)    NOT NULL,
    [BRK_OpeZalId]                INT             NULL,
    [BRK_StaZalId]                INT             NULL,
    [BRK_TS_Zal]                  DATETIME        NOT NULL,
    [BRK_OpeModId]                INT             NULL,
    [BRK_StaModId]                INT             NULL,
    [BRK_TS_Mod]                  DATETIME        NOT NULL,
    [BRK_DokumentLP]              AS              ([CDN].[BRKDokumentLP]([BRK_LDokTyp],[BRK_LDokId],[BRK_PDokTyp],[BRK_PDokId])),
    [BRK_LWynagrodzenie]          AS              ([CDN].[CzyWynagrodzenie]([BRK_LDokTyp],[BRK_LDokId])),
    [BRK_PWynagrodzenie]          AS              ([CDN].[CzyWynagrodzenie]([BRK_PDokTyp],[BRK_PDokId])),
    [BRK_RycID]                   INT             NULL,
    [BRK_KolumnaRyc]              TINYINT         NOT NULL,
    [BRK_KRoID]                   INT             NULL,
    [BRK_DleID]                   INT             NULL,
    [BRK_ZakID]                   INT             NULL,
    [BRK_OpeModKod]               VARCHAR (20)    CONSTRAINT [DF_BRK_OpeModKod] DEFAULT ('') NOT NULL,
    [BRK_OpeModNazwisko]          NVARCHAR (50)   CONSTRAINT [DF_BRK_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BRK_OpeZalKod]               VARCHAR (20)    CONSTRAINT [DF_BRK_OpeZalKod] DEFAULT ('') NOT NULL,
    [BRK_OpeZalNazwisko]          NVARCHAR (50)   CONSTRAINT [DF_BRK_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [BRK_Primary] PRIMARY KEY CLUSTERED ([BRK_BRKID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_BRK_Kwota] CHECK ([BRK_KWOTA]>(0)),
    CONSTRAINT [FK_BRKDokDef] FOREIGN KEY ([BRK_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID])
);


GO
CREATE NONCLUSTERED INDEX [BRKPodmiotL]
    ON [CDN].[BnkRozKwoty]([BRK_LPodID] ASC, [BRK_LPodTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKPodmiotP]
    ON [CDN].[BnkRozKwoty]([BRK_PPodID] ASC, [BRK_PPodTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKDokDef]
    ON [CDN].[BnkRozKwoty]([BRK_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKNumer]
    ON [CDN].[BnkRozKwoty]([BRK_NumerString] ASC, [BRK_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRKNumerPelny]
    ON [CDN].[BnkRozKwoty]([BRK_NumerPelny] ASC, [BRK_BRKID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKDekrety]
    ON [CDN].[BnkRozKwoty]([BRK_DekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKDekrety2]
    ON [CDN].[BnkRozKwoty]([BRK_Dek2Id] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKPreDekrety]
    ON [CDN].[BnkRozKwoty]([BRK_PreDekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKPreDekrety2]
    ON [CDN].[BnkRozKwoty]([BRK_PreDek2ID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKKPR]
    ON [CDN].[BnkRozKwoty]([BRK_KPRId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKRyc]
    ON [CDN].[BnkRozKwoty]([BRK_RycID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKKRoID]
    ON [CDN].[BnkRozKwoty]([BRK_KRoID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKDleID]
    ON [CDN].[BnkRozKwoty]([BRK_DleID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRKGUID]
    ON [CDN].[BnkRozKwoty]([BRK_ImportRowId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRKChrono]
    ON [CDN].[BnkRozKwoty]([BRK_DataDok] ASC, [BRK_BRKID] ASC)
    INCLUDE([BRK_Kwota], [BRK_KwotaSysL], [BRK_KwotaSysP], [BRK_LDokTyp], [BRK_LDokID], [BRK_PDokTyp], [BRK_PDokID], [BRK_Waluta]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKDokL]
    ON [CDN].[BnkRozKwoty]([BRK_LDokTyp] ASC, [BRK_LDokID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKDokP]
    ON [CDN].[BnkRozKwoty]([BRK_PDokTyp] ASC, [BRK_PPodID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKDokDataL]
    ON [CDN].[BnkRozKwoty]([BRK_LDokTyp] ASC, [BRK_LDokID] ASC, [BRK_DataDok] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKDokDataP]
    ON [CDN].[BnkRozKwoty]([BRK_PDokTyp] ASC, [BRK_PDokID] ASC, [BRK_DataDok] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRKRozKur]
    ON [CDN].[BnkRozKwoty]([BRK_RoznicaKursowaSys] ASC, [BRK_NumerPelny] ASC, [BRK_BRKID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRKAuto]
    ON [CDN].[BnkRozKwoty]([BRK_ZapisAutomatyczny] ASC)
    INCLUDE([BRK_BRKID], [BRK_DataDok]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkRozKwoty_InsertUpdateDelete_Trigger
  ON CDN.BnkRozKwoty
  FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
IF EXISTS(SELECT * FROM inserted) OR EXISTS(SELECT * FROM deleted)
BEGIN
-- Sprawdzenie kasowania zaksiegowanych rekordow
If Not Exists (Select * From inserted)
Begin
 If Exists (Select * From deleted Where BRK_DekId Is Not Null Or BRK_KPRId Is Not Null Or BRK_RycID Is Not Null)
  Begin
   RAISERROR('##OPT32259##', 16, 1) -- RAISERROR('Nie można kasować zaksięgowanych różnic kursowych.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  End
 If Exists (Select * From deleted Where BRK_Dek2Id Is Not Null)
  Begin
   RAISERROR('##OPT32260##', 16, 1) -- RAISERROR('Nie można kasować zaksięgowanych rozliczeń.', 16, 1)
   ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  End
End
-- Sprawdzenie ustawienia kolumn związanych z podmiotem
IF EXISTS (select * from inserted where isnull(brk_lpodTyp, 0)=0)
 RAISERROR('##OPT32242##%%kolumna%%=BRK_LPodTyp##', 16, 1) -- RAISERROR('Nie ustawiono kolumny BRK_LPodTyp na rozliczeniu K/B.', 16, 1)
IF EXISTS (select * from inserted where isnull(brk_lpodid, 0)=0)
 RAISERROR('##OPT32242##%%kolumna%%=BRK_LPodID##', 16, 1) -- RAISERROR('Nie ustawiono kolumny BRK_LPodID na rozliczeniu K/B.', 16, 1)
IF EXISTS (select * from inserted where isnull(brk_ppodTyp, 0)=0)
 RAISERROR('##OPT32242##%%kolumna%%=BRK_PPodTyp##', 16, 1) -- RAISERROR('Nie ustawiono kolumny BRK_PPodTyp na rozliczeniu K/B.', 16, 1)
IF EXISTS (select * from inserted where isnull(brk_ppodid, 0)=0)
 RAISERROR('##OPT32242##%%kolumna%%=BRK_PPodID##', 16, 1) -- RAISERROR('Nie ustawiono kolumny BRK_PPodID na rozliczeniu K/B.', 16, 1)
-- Usunięcie zapisów z BnkRozRelacje
--Usuwam stare BnkRozRelacje
IF EXISTS (SELECT * FROM deleted)
  DELETE FROM CDN.BnkRozRelacje WHERE CDN.BnkRozRelacje.BRR_BRKId IN (SELECT deleted.BRK_BRKId FROM deleted)
-- Dodanie zapisów do BnkRozRelacje
IF EXISTS (SELECT * FROM inserted)
BEGIN
  -- Dodanie relacji "od lewej do prawej"
  INSERT INTO CDN.BnkRozRelacje(BRR_BRKID, BRR_ZDokTyp, BRR_ZDokID, BRR_DDokTyp, BRR_DDokID)
                         SELECT BRK_BRKId, BRK_LDokTyp, BRK_LDokID, BRK_PDokTyp, BRK_PDokID FROM inserted
  -- Dodanie relacji "od prawej do lewej"
  INSERT INTO CDN.BnkRozRelacje(BRR_BRKID, BRR_ZDokTyp, BRR_ZDokID, BRR_DDokTyp, BRR_DDokID)
                         SELECT BRK_BRKId, BRK_PDokTyp, BRK_PDokID, BRK_LDokTyp, BRK_LDokID FROM inserted
-- Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
  IF EXISTS
    (SELECT * FROM inserted WHERE BRK_DekId IS NOT NULL AND NOT EXISTS (SELECT * FROM CDN.DekretyNag WHERE DeN_Zrodlo in (13,44,50) AND BRK_DekID = DeN_DeNID ))
  OR EXISTS
    (SELECT * FROM inserted WHERE BRK_Dek2Id IS NOT NULL AND NOT EXISTS (SELECT * FROM CDN.DekretyNag WHERE DeN_Zrodlo in (13,44,50) AND BRK_Dek2ID = DeN_DeNID ))
    BEGIN
  RAISERROR('##OPT32242##%%tabela%%=DekretyNag##', 16, 1) -- RAISERROR('1 Brak wartości w tabeli nadrzędnej (DekretyNag) ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
   END
-- Sprawdzanie obecności wierszy w tabeli nadrzędnej ZapisyKPR
  IF EXISTS
    (SELECT * FROM inserted
     LEFT OUTER JOIN CDN.ZapisyKPR ON BRK_KPRID = KPR_KPRId AND KPR_Zrodlo = 13
     WHERE KPR_KPRId IS NULL
     AND BRK_KPRID IS NOT NULL
    )
    BEGIN
  RAISERROR('##OPT32242##%%tabela%%=ZapisyKPR##', 16, 1) -- RAISERROR('Brak wartości w tabeli nadrzędnej (ZapisyKPR) ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
   END
-- Sprawdzenie unikalnosci NumerPelny
  If Exists (
    Select * From inserted i Join CDN.BnkRozKwoty b On i.BRK_NumerPelny = b.BRK_NumerPelny
    Where i.BRK_NumerNr<>-1 And i.BRK_BRKId <> b.BRK_BRKId
    )
    BEGIN
  RAISERROR('##OPT32262##%%indeks%%=NumerPelny##', 16, 1) -- RAISERROR('Duplikacja klucza NumerPelny ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
   END
END
--Aktualizacja zapisów źródłowych
DECLARE @BRKID       INT
DECLARE @DokTyp      INT
DECLARE @DokId       INT
DECLARE @Kwota       NUMERIC(15,2)
DECLARE @KwotaRoz    NUMERIC(15,2)
DECLARE @KwotaSys    NUMERIC(15,2)
DECLARE @KwotaRozSys NUMERIC(15,2)
DECLARE @DataRoz     DATETIME
DECLARE @Rozliczono  INT
DECLARE @Rozliczono2 INT
DECLARE @Kierunek    INT
DECLARE @LewyPrawy   INT
DECLARE @NumerDok    NVarchar(256)
DECLARE @BRaID        INT
DECLARE @ZapisAutomatyczny  SMALLINT
DECLARE @Waluta       NVarchar(3)
DECLARE @Numer        NVarchar(256)
--Kursor zawiera DokTyp i DokId wszystkich zmienionych dokumentów
DECLARE RozKwotyUpdated CURSOR LOCAL FAST_FORWARD FOR
  SELECT inserted.BRK_BRKID, inserted.BRK_LDokTyp, inserted.BRK_LDokId, 1 FROM inserted
  UNION
  SELECT inserted.BRK_BRKID, inserted.BRK_PDokTyp, inserted.BRK_PDokId, 2 FROM inserted
  UNION
  SELECT deleted.BRK_BRKID,  deleted.BRK_LDokTyp,  deleted.BRK_LDokId, 1  FROM deleted
  UNION
  SELECT deleted.BRK_BRKID,  deleted.BRK_PDokTyp,  deleted.BRK_PDokId, 2  FROM deleted
OPEN RozKwotyUpdated;
FETCH NEXT FROM RozKwotyUpdated INTO @BRKID, @DokTyp, @DokId, @LewyPrawy;
--Aktualizacja kolejnych dokumentów
WHILE @@FETCH_STATUS = 0
BEGIN
  IF @DokTyp = 1
  BEGIN
    --Pobieram dokument rozliczany z BnkZdarzenia
    SELECT @Kwota = BZd_Kwota, @KwotaSys = BZd_KwotaSys, @Rozliczono = BZd_Rozliczono, @Rozliczono2 = BZd_Rozliczono2, @Kierunek = BZd_Kierunek, @NumerDok = Case When BZd_NumerObcy <> '' Then BZd_NumerObcy Else BZd_NumerPelny End, @BRaID = BZd_BRaID, @ZapisAutomatyczny = 0, @Waluta = BZd_Waluta, @Numer = BZd_Numer  FROM CDN.BnkZdarzenia WHERE BZd_BZdId = @DokId
    --Sprawdzam, czy mogę rozliczyć BnkZdarzenia z BnkZdarzenia
    IF EXISTS (SELECT * FROM CDN.BnkRozRelacje JOIN CDN.BnkZdarzenia
               ON BRR_DDokId = BZd_BZdId
               WHERE BRR_ZDokTyp = @DokTyp AND BRR_ZDokId = @DokId AND BRR_DDokTyp = 1 AND BZd_Kierunek <> -@Kierunek)
    BEGIN
  RAISERROR('##OPT32263##', 16, 1) -- RAISERROR('Rozliczenie dokumentów niemożliwe', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    --Sprawdzam, czy mogę rozliczyć BnkZdarzenia z BnkZapisy
    IF EXISTS (SELECT * FROM CDN.BnkRozRelacje JOIN CDN.BnkZapisy
               ON BRR_DDokId = BZp_BZpId
               WHERE BRR_ZDokTyp = @DokTyp AND BRR_ZDokId = @DokId AND BRR_DDokTyp = 2 AND BZp_Kierunek <> @Kierunek)
    BEGIN
  RAISERROR('##OPT32263##', 16, 1) -- RAISERROR('Rozliczenie dokumentów niemożliwe', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
  ELSE
  BEGIN
    --Pobieram dokument rozliczany z BnkZapisy
    SELECT @Kwota = BZp_Kwota, @KwotaSys = BZp_KwotaSys, @Rozliczono = BZp_Rozliczono, @Rozliczono2 = BZp_Rozliczono2, @Kierunek = BZp_Kierunek, @NumerDok = Case When BZp_NumerObcy <> '' Then BZp_NumerObcy Else BZp_NumerPelny End, @BRaID = BZp_BRaID, @ZapisAutomatyczny = BZp_ZapisAutomatyczny, @Waluta = BZp_Waluta, @Numer = BZp_Numer FROM CDN.BnkZapisy WHERE BZp_BZpId = @DokId
    --Sprawdzam, czy mogę rozliczyć BnkZapisy z BnkZdarzenia
    IF EXISTS (SELECT * FROM CDN.BnkRozRelacje JOIN CDN.BnkZdarzenia
               ON BRR_DDokId = BZd_BZdId
               WHERE BRR_ZDokTyp = @DokTyp AND BRR_ZDokId = @DokId AND BRR_DDokTyp = 1 AND BZd_Kierunek <> @Kierunek)
    BEGIN
      RAISERROR('##OPT32263##', 16, 1) -- RAISERROR('Rozliczenie dokumentów niemożliwe', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    --Sprawdzam, czy mogę rozliczyć BnkZapisy z BnkZapisy
    IF EXISTS (SELECT * FROM CDN.BnkRozRelacje JOIN CDN.BnkZapisy
               ON BRR_DDokId = BZp_BZpId
               WHERE BRR_ZDokTyp = @DokTyp AND BRR_ZDokId = @DokId AND BRR_DDokTyp = 2 AND BZp_Kierunek <> -@Kierunek)
    BEGIN
      RAISERROR('##OPT32263##', 16, 1) -- RAISERROR('Rozliczenie dokumentów niemożliwe', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
  -- Ustawienie pól redundantnych względem BnkRozKwotyView (optymalizacja na MSSQL 2005)
  IF @LewyPrawy=1
    Update CDN.BnkRozKwoty Set BRK_LBRaID = @BRaID, BRK_Waluta = @Waluta, BRK_ZapisAutomatyczny = @ZapisAutomatyczny, BRK_LNumer = @Numer, BRK_LKwota = @Kwota Where BRK_BRKId = @BRKId
  ELSE
    Update CDN.BnkRozKwoty Set BRK_PBRaID = @BRaID, BRK_Waluta = @Waluta, BRK_ZapisAutomatyczny = @ZapisAutomatyczny, BRK_PNumer = @Numer, BRK_PKwota = @Kwota Where BRK_BRKId = @BRKId
  --Obliczam sumę rozliczeń dla danego dokumentu
  SELECT
  @KwotaRoz = IsNull(SUM(BRK_Kwota),0),
  @KwotaRozSys = IsNull(SUM(Case When BRK_LDokTyp = @DokTyp And BRK_LDokId = @DokId Then BRK_KwotaSysL When BRK_PDokTyp = @DokTyp And BRK_PDokId = @DokId Then BRK_KwotaSysP Else 0 End),0),
  @DataRoz  = MAX(BRK_DataDok)
  FROM CDN.BnkRozRelacje JOIN CDN.BnkRozKwoty ON BRR_BRKId = BRK_BRKId
  WHERE BRR_ZDokTyp = @DokTyp AND BRR_ZDokId = @DokId
  --Sprawdzam, czy suma rozliczeń mieści się we właściwym przedziale
  IF @KwotaRoz < 0
  BEGIN
    RAISERROR('##OPT32264##', 16, 1) -- RAISERROR('Kwota rozliczana nie może być ujemna.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  IF @KwotaRoz > @Kwota
  BEGIN
    IF @Rozliczono = 2
  RAISERROR('##OPT32265##%%dokument%%=%s##', 16, 1, @NumerDok) -- RAISERROR('Dokument %s został już całkowicie rozliczony.', 16, 1, @NumerDok)
    ELSE
  RAISERROR('##OPT32266##%%dokument%%=%s##', 16, 1, @NumerDok) -- RAISERROR('Przekroczono wartość kwoty do rozliczenia %s.', 16, 1, @NumerDok)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
  -- ustawianie statusu rozliczenia dokumentu
  IF @Rozliczono = 0  -- Dokument nie podlega rozliczeniu
    BEGIN
  RAISERROR('##OPT32267##%%dokument%%=%s##', 16, 1, @NumerDok) -- RAISERROR('Dokument %s nie podlega rozliczeniu', 16, 1, @NumerDok)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  --Sprawdzam, jak ustawić status rozliczenia
  IF @KwotaRoz = @Kwota SET @Rozliczono  = 2 ELSE SET @Rozliczono  = 1
  IF @KwotaRoz <>0      SET @Rozliczono2 = 2 ELSE SET @Rozliczono2 = 1
  DECLARE @NiesynchroniczneZejscieDoZera TINYINT
  IF @KwotaRoz = @Kwota AND @KwotaRozSys <> @KwotaSys
    SELECT @NiesynchroniczneZejscieDoZera = 1
  ELSE
    SELECT @NiesynchroniczneZejscieDoZera = 0
  DECLARE @RozKurUpdated TINYINT
  IF UPDATE(BRK_RoznicaKursowaSys)
    SELECT @RozKurUpdated = 1
  ELSE
    SELECT @RozKurUpdated = 0
  Declare @MaxNr Int
  IF @NiesynchroniczneZejscieDoZera <> 0
    AND @RozKurUpdated = 0
      -- Korektę kwoty sys i różnicy kursowej robimy tylko gdy obiekt rozliczenia NIE ustawił jawnie różnicy kursowej.
      -- Jeśli ustawił, to pewnie wie co robi - za chwilę mogą być updatowane kolejne rozliczenia i ważne żeby na końcu wszystko się zgadzało - w takim przypadku nie mieszamy w obliczeniach obiektu (TFSID=13780)
    BEGIN
-- Korekta synchronicznego zejścia kwoty do 0
      DECLARE @Korekta Decimal(15,2), @Znak SmallInt
      Set @Korekta = @KwotaSys - @KwotaRozSys
      Set @KwotaRozSys = @KwotaSys
      IF @DokTyp = 1
        Select @Znak = -BZd_Kierunek From CDN.BnkZdarzenia Where BZd_BZdId = @DokId
      ELSE
        Select @Znak = BZp_Kierunek  From CDN.BnkZapisy    Where BZp_BZpId = @DokId
      IF @LewyPrawy=1
        UPDATE CDN.BnkRozKwoty Set
          BRK_KwotaSysL = BRK_KwotaSysL + @Korekta,
          BRK_RoznicaKursowaSys = BRK_RoznicaKursowaSys + @Znak * @Korekta
        Where BRK_BRKId= @BRKId
      ELSE
        UPDATE CDN.BnkRozKwoty Set
          BRK_KwotaSysP = BRK_KwotaSysP + @Korekta,
          BRK_RoznicaKursowaSys = BRK_RoznicaKursowaSys + @Znak * @Korekta
        Where BRK_BRKId= @BRKId
      If Exists (Select * From CDN.BnkRozKwoty Where BRK_BRKId = @BRKId And BRK_RoznicaKursowaSys <>0 And BRK_NumerNr=-1)
        Begin
          Select @MaxNr = IsNull(Max(BRK_NumerNr),0) + 1 From CDN.BnkRozKwoty
            Where BRK_NumerString = (Select BRK_NumerString From CDN.BnkRozKwoty Where BRK_BRKId=@BRKId)
          Update CDN.BnkRozKwoty Set BRK_NumerNr = @MaxNr Where BRK_BRKId = @BRKId
        End
    END -- Korekta synchronicznego zejścia kwoty do 0
    -- Powyżej zawęziliśmy liczbę przypadków, w których wykonywany jest kod poprawkowy synchronicznego zejścia do zera kwot pozostałych do rozliczenia.
    -- W tych "wyrzuconych" z obsługi przypadkach trzeba jeszcze ustawić ewentualny numer RK (cd TFSID=13780)
  IF @NiesynchroniczneZejscieDoZera <> 0 AND @RozKurUpdated = 1
    BEGIN
      If Exists (Select * From CDN.BnkRozKwoty Where BRK_BRKId = @BRKId And BRK_RoznicaKursowaSys <>0 And BRK_NumerNr=-1)
        Begin
          Select @MaxNr = IsNull(Max(BRK_NumerNr),0) + 1 From CDN.BnkRozKwoty
            Where BRK_NumerString = (Select BRK_NumerString From CDN.BnkRozKwoty Where BRK_BRKId=@BRKId)
          Update CDN.BnkRozKwoty Set BRK_NumerNr = @MaxNr Where BRK_BRKId = @BRKId
        End
    END
  --Aktualizuję dokument
  IF @DokTyp = 1
   BEGIN
    UPDATE CDN.BnkZdarzenia SET BZd_KwotaRoz = @KwotaRoz, BZd_KwotaRozSys = @KwotaRozSys, BZd_Rozliczono = @Rozliczono, BZd_Rozliczono2 = @Rozliczono2, BZd_DataRoz = @DataRoz WHERE BZd_BZdId = @DokId
    --Wywolanie generacji VatTab7 dla rejestrow Vat
    EXECUTE CDN.RozliczenieVatTab7 @DokId
   END
  ELSE
    UPDATE CDN.BnkZapisy    SET BZp_KwotaRoz = @KwotaRoz, BZp_KwotaRozSys = @KwotaRozSys, BZp_Rozliczono = @Rozliczono, BZp_Rozliczono2 = @Rozliczono2, BZp_DataRoz = @DataRoz WHERE BZp_BZpId = @DokId
  FETCH NEXT FROM RozKwotyUpdated INTO @BRKID, @DokTyp, @DokId, @LewyPrawy;
END
CLOSE RozKwotyUpdated
If Not Exists (Select * From inserted)
 If Exists (Select * From deleted Where BRK_AutoOffLine = 1)
  Begin
   Delete From CDN.BnkZapisy Where BZp_AutoOffLine = 1 And BZp_BZpId In (Select BRK_PDokId From deleted Where BRK_AutoOffLine = 1 And BRK_PDokTyp = 2)
   Delete From CDN.BnkZapisy Where BZp_AutoOffLine = 1 And BZp_BZpId In (Select BRK_LDokId From deleted Where BRK_AutoOffLine = 1 And BRK_LDokTyp = 2)
  End
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where IsNull(BRK_ImportRowId,'') = '')
  Update CDN.BnkRozKwoty Set BRK_ImportRowId = NewId()
  Where BRK_BRKId In (Select BRK_BRKId From inserted Where IsNull(BRK_ImportRowId,'') = '')
END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkRozKwoty_DeleteHandler
  ON CDN.BnkRozKwoty
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.BRK_BRKID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=13)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.BRK_BRKID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=13)
    IF EXISTS(SELECT D.BRK_PreDekID FROM Deleted D WHERE D.BRK_PreDekID IS NOT NULL)
  DELETE CDN.DekretyNag
  FROM CDN.DekretyNag, deleted
  WHERE deleted.BRK_PreDekId = CDN.DekretyNag.DeN_DeNID
SET NOCOUNT OFF
