CREATE TABLE [CDN].[BnkRaporty] (
    [BRp_BRpID]               INT             IDENTITY (1, 1) NOT NULL,
    [BRp_BRaID]               INT             NULL,
    [BRp_DDfID]               INT             NULL,
    [BRp_NumerNr]             INT             NOT NULL,
    [BRp_NumerString]         VARCHAR (31)    NOT NULL,
    [BRp_NumerPelny]          AS              ([CDN].[FN_NUMERPELNY]([BRP_NUMERNR],[BRP_NUMERSTRING])),
    [BRp_NumerObcy]           NVARCHAR (256)  NOT NULL,
    [BRp_DataDok]             DATETIME        NOT NULL,
    [BRp_DataZam]             DATETIME        NULL,
    [BRp_Zamkniety]           TINYINT         NOT NULL,
    [BRp_DekID]               INT             NULL,
    [BRp_PreDekID]            INT             NULL,
    [BRp_SaldoBO]             DECIMAL (15, 2) NOT NULL,
    [BRp_Przychody]           DECIMAL (15, 2) NOT NULL,
    [BRp_Rozchody]            DECIMAL (15, 2) NOT NULL,
    [BRp_SaldoBOSys]          DECIMAL (15, 2) NOT NULL,
    [BRp_PrzychodySys]        DECIMAL (15, 2) NOT NULL,
    [BRp_RozchodySys]         DECIMAL (15, 2) NOT NULL,
    [BRp_RoznicaKursowaSysMW] DECIMAL (15, 2) NOT NULL,
    [BRp_CDCWB]               TINYINT         NULL,
    [BRp_TS_Export]           DATETIME        NULL,
    [BRp_ImportAppId]         VARCHAR (5)     NULL,
    [BRp_ImportRowId]         VARCHAR (36)    NULL,
    [BRp_OpeZalID]            INT             NULL,
    [BRp_StaZalId]            INT             NULL,
    [BRp_TS_Zal]              DATETIME        NOT NULL,
    [BRp_OpeModID]            INT             NULL,
    [BRp_StaModId]            INT             NULL,
    [BRp_TS_Mod]              DATETIME        NOT NULL,
    [BRp_GIDTyp]              SMALLINT        NULL,
    [BRp_GIDFirma]            INT             NULL,
    [BRp_GIDNumer]            INT             NULL,
    [BRp_GIDLp]               SMALLINT        NULL,
    [BRp_OpeModKod]           VARCHAR (20)    CONSTRAINT [DF_BRp_OpeModKod] DEFAULT ('') NOT NULL,
    [BRp_OpeModNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_BRp_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BRp_OpeZalKod]           VARCHAR (20)    CONSTRAINT [DF_BRp_OpeZalKod] DEFAULT ('') NOT NULL,
    [BRp_OpeZalNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_BRp_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [BRp_Primary] PRIMARY KEY CLUSTERED ([BRp_BRpID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BRpDokDefinicja] FOREIGN KEY ([BRp_DDfID]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_BRpRaport] FOREIGN KEY ([BRp_BRaID]) REFERENCES [CDN].[BnkRachunki] ([BRa_BRaID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRpRaport]
    ON [CDN].[BnkRaporty]([BRp_BRaID] ASC, [BRp_DataDok] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRpRaportZam]
    ON [CDN].[BnkRaporty]([BRp_BRaID] ASC, [BRp_DataDok] ASC, [BRp_Zamkniety] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRpNumeracja]
    ON [CDN].[BnkRaporty]([BRp_NumerString] ASC, [BRp_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRpNumerPelny]
    ON [CDN].[BnkRaporty]([BRp_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRpDokDefinicja]
    ON [CDN].[BnkRaporty]([BRp_DDfID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRpDekID]
    ON [CDN].[BnkRaporty]([BRp_DekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRpPreDekID]
    ON [CDN].[BnkRaporty]([BRp_PreDekID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BRpGUID]
    ON [CDN].[BnkRaporty]([BRp_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BRpGID]
    ON [CDN].[BnkRaporty]([BRp_GIDTyp] ASC, [BRp_GIDFirma] ASC, [BRp_GIDNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkRaporty_DeleteHandler
  ON CDN.BnkRaporty
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.BRp_BRpID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=9)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.BRp_BRpID = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=9)
    IF EXISTS(SELECT D.BRp_PreDekID FROM Deleted D WHERE D.BRp_PreDekID IS NOT NULL)
  DELETE CDN.DekretyNag
  FROM CDN.DekretyNag, deleted
  WHERE deleted.BRp_PreDekId = CDN.DekretyNag.DeN_DeNID
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkRaporty_Delete_Trigger
  ON CDN.BnkRaporty
  FOR DELETE
AS
  IF EXISTS (SELECT * FROM deleted WHERE BRp_Zamkniety=1)
  BEGIN
    RAISERROR('##OPT32257##', 16, 1) -- RAISERROR('Raport zamknięty - usunięcie nie jest możliwe.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
DECLARE @Raport INT
DECLARE @Rachunek INT
DECLARE @Zamkniety SMALLINT
DECLARE @DataOtw DATETIME
DECLARE @DataZam DATETIME
DECLARE @SaldoBO DECIMAL(15,2)
DECLARE @Przychody DECIMAL(15,2)
DECLARE @Rozchody DECIMAL(15,2)
DECLARE @SaldoBOSys DECIMAL(15,2)
DECLARE @PrzychodySys DECIMAL(15,2)
DECLARE @RozchodySys DECIMAL(15,2)
DECLARE @NastepnyRaport INT
DECLARE @PoprzedniZamkniety INT
DECLARE @NoweSaldoBO DECIMAL(15,2)
DECLARE @NoweSaldoBOSys DECIMAL(15,2)
-- Sprawdzenie relacji czasowych, ustawianie kwot
  DECLARE CursorDeleted CURSOR LOCAL FAST_FORWARD FOR
    SELECT deleted.BRp_BRpID, deleted.BRp_BRaID, deleted.BRp_Zamkniety, deleted.BRp_DataDok, deleted.BRp_DataZam,
           deleted.BRp_SaldoBO, deleted.BRp_Przychody, deleted.BRp_Rozchody,
           deleted.BRp_SaldoBOSys, deleted.BRp_PrzychodySys, deleted.BRp_RozchodySys
           FROM deleted
  OPEN CursorDeleted;
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM CursorDeleted INTO @Raport, @Rachunek, @Zamkniety, @DataOtw, @DataZam,
                                       @SaldoBO, @Przychody, @Rozchody,
                                       @SaldoBOSys, @PrzychodySys, @RozchodySys
    IF @@FETCH_STATUS <> 0 BREAK
    -- Usuwanie otwartego raportu - aktualizacja salda BO następnego (zapewne otwartego) raportu jeśli bezpośrednio
    -- przed usuwanym jest raport zamknięty albo usuwamy pierwszy otwarty raport
    IF @Zamkniety=0
    BEGIN
      SET @NastepnyRaport = (SELECT TOP 1 BRp_BRpID FROM CDN.BnkRaporty
                             WHERE BRp_BRaID=@Rachunek AND BRp_DataDok>@DataOtw ORDER BY BRp_BRaID, BRp_DataDok)
      IF @NastepnyRaport is not null
      BEGIN
        SELECT TOP 1 @PoprzedniZamkniety = BRp_Zamkniety, @NoweSaldoBO = BRp_SaldoBO+BRp_Przychody-BRp_Rozchody,
          @NoweSaldoBOSys = BRp_SaldoBOSys+BRp_PrzychodySys-BRp_RozchodySys+BRp_RoznicaKursowaSysMW
        FROM CDN.BnkRaporty
        WHERE BRp_BRaID=@Rachunek AND BRp_DataDok<@DataOtw ORDER BY BRp_BRaID, BRp_DataDok DESC
        IF @NoweSaldoBO is null --usuwamy pierwszy raport
          SELECT @NoweSaldoBO = BRa_SaldoBO, @NoweSaldoBOSys = BRa_SaldoBOSys FROM CDN.BnkRachunki WHERE BRa_BRaID=@Rachunek
        IF @PoprzedniZamkniety=0 SELECT @NoweSaldoBO = 0, @NoweSaldoBOSys = 0
        IF @PoprzedniZamkniety=1 OR @PoprzedniZamkniety is null
        BEGIN
          UPDATE CDN.BnkRaporty SET BRp_SaldoBO=@NoweSaldoBO, BRp_SaldoBOSys=@NoweSaldoBOSys  WHERE BRp_BRpID=@NastepnyRaport AND (BRp_SaldoBO<>@NoweSaldoBO OR BRp_SaldoBOSys<>@NoweSaldoBOSys)
          IF @@ERROR <> 0
          BEGIN
   RAISERROR('##OPT32258##', 16, 1) -- RAISERROR('Błąd aktualizacji salda początkowego następnego raportu przy usuwaniu otwartego raportu.', 16, 1)
            ROLLBACK TRAN
            SET NOCOUNT OFF
            RETURN
          END
        END
      END
    END
    ELSE
    BEGIN
  RAISERROR('##OPT32257##', 16, 1) -- RAISERROR('Raport został zamknięty.', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
  CLOSE CursorDeleted
-- Skasowanie relacji do dokumentów  (WiNi)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1122 AND DoR_DokumentId=deleted.BRp_BRpID
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BnkRaporty_InsertUpdate_Trigger
  ON CDN.BnkRaporty
  FOR INSERT, UPDATE
AS
SET NOCOUNT ON
DECLARE @Raport INT
DECLARE @Rachunek INT
DECLARE @Zamkniety SMALLINT
DECLARE @DataOtw DATETIME
DECLARE @DataZam DATETIME
DECLARE @SaldoBO DECIMAL(15,2)
DECLARE @SaldoBOSys DECIMAL(15,2)
DECLARE @Przychody DECIMAL(15,2)
DECLARE @Rozchody DECIMAL(15,2)
DECLARE @PrzychodySys DECIMAL(15,2)
DECLARE @RozchodySys DECIMAL(15,2)
DECLARE @RoznicaKursowaSysMW DECIMAL(15,2)
DECLARE @NastepnyRaport INT
DECLARE @PoprzedniZamkniety SMALLINT
DECLARE @NoweSaldoBO DECIMAL(15,2)
DECLARE @NoweSaldoBOSys DECIMAL(15,2)
DECLARE @NumerPelny NVarchar(30)
DECLARE @NumerNr INT
DECLARE @NumerString NVarchar(31)
DECLARE @TrN_Numer_Pa NVarchar(30), @TrN_Numer_FA NVarchar(30)
-- Sprawdzanie duplikacji identyfikatora GID
  If Update (BRp_GIDTyp) Or Update (BRp_GIDFirma) Or Update (BRp_GIDNumer)
    Begin
      If Exists (
        Select * From inserted A, CDN.BnkRaporty B Where
          A.BRp_GIDTyp   = B.BRp_GIDTyp   And
          A.BRp_GIDFirma = B.BRp_GIDFirma And
          A.BRp_GIDNumer = B.BRp_GIDNumer And
          A.BRp_BRpId   <> B.BRp_BRpId    And
          IsNull(A.BRp_GIDTyp, 0) <> 0    And
          IsNull(A.BRp_GIDFirma, 0) <> 0  And
          IsNull(A.BRp_GIDNumer, 0) <> 0)
        Begin
   RAISERROR('##OPT32230##', 16, 1) -- RaisError ('Duplikacja identyfikatora GID', 16,1)
          RollBack Tran
          Return
        End
    End
--Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.DekretyNag ON
                    inserted.BRp_DekID       = CDN.DekretyNag.DeN_DeNId
              WHERE CDN.DekretyNag.DeN_DeNId IS NULL
                AND inserted.BRp_DekID IS NOT NULL
           )
        BEGIN
   RAISERROR('##OPT32242##%%tabela%%=DekretyNag##', 16, 1) -- RAISERROR('Brak wartości w tabeli nadrzędnej (DekretyNag) ', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
-- Sprawdzenie czy zamknięty raport ma ustawioną datę zamknięcia
  IF EXISTS (SELECT * FROM inserted WHERE inserted.BRp_Zamkniety=1 AND inserted.BRp_DataZam is null)
  BEGIN
 RAISERROR('##OPT32243##', 16, 1) -- RAISERROR('Nieokreślona data zamknięcia raportu.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie czy data zamknięcia jest niemniejsza od daty otwarcia
  IF EXISTS (SELECT * FROM inserted WHERE inserted.BRp_DataZam is NOT null AND
               inserted.BRp_DataZam<inserted.BRp_DataDok)
  BEGIN
 RAISERROR('##OPT32244##', 16, 1) -- RAISERROR('Data zamknięcia raportu wcześniejsza od jego daty otwarcia.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie czy raport nie ma zapisów przed datą otwarcia
  IF UPDATE(BRp_DataDok)
  BEGIN
    IF EXISTS (SELECT * FROM inserted JOIN CDN.BnkZapisy ON inserted.BRp_BRpID=BZp_BRpID
               WHERE BZp_DataDok<inserted.BRp_DataDok)
    BEGIN
  RAISERROR('##OPT32245##', 16, 1) -- RAISERROR('Istnieje zapis raportu wcześniejszy niż data otwarcia raportu.', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
-- Sprawdzenie czy raport nie ma zapisów po dacie zamknięcia
  IF UPDATE(BRp_DataZam)
  BEGIN
    IF EXISTS (SELECT * FROM inserted JOIN CDN.BnkZapisy ON inserted.BRp_BRpID=BZp_BRpID
               WHERE inserted.BRp_DataZam is not null AND BZp_DataDok>inserted.BRp_DataZam)
    BEGIN
      RAISERROR('##OPT32246##', 16, 1)  -- RAISERROR('Istnieje zapis raportu późniejszy niż data zamknięcia raportu.', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
-- Sprawdzenie czy definicja dokumentu jest identyczna jak w rachunku
  IF EXISTS (SELECT * FROM inserted JOIN CDN.BnkRachunki ON inserted.BRp_BRaID = CDN.BnkRachunki.BRa_BRaID
             WHERE inserted.BRp_DDfId <> CDN.BnkRachunki.BRa_DDfId)
  BEGIN
    RAISERROR('##OPT32247##', 16, 1) -- RAISERROR('Definicje dokumentu w rachunku i raporcie są różne.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie relacji czasowych, ustawianie kwot
  DECLARE CursorInserted CURSOR LOCAL FAST_FORWARD FOR
    SELECT BRp_BRpID, BRp_BRaID, BRp_Zamkniety, BRp_DataDok, BRp_DataZam,
           BRp_SaldoBO, BRp_SaldoBOSys, BRp_Przychody, BRp_Rozchody, BRp_PrzychodySys, BRp_RozchodySys, BRp_RoznicaKursowaSysMW,
           BRp_NumerPelny, BRp_NumerNr, BRp_NumerString
           FROM inserted
  OPEN CursorInserted
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM CursorInserted INTO @Raport, @Rachunek, @Zamkniety, @DataOtw, @DataZam,
                                        @SaldoBO, @SaldoBOSys, @Przychody, @Rozchody, @PrzychodySys, @RozchodySys, @RoznicaKursowaSysMW,
          @NumerPelny, @NumerNr, @NumerString
    IF @@FETCH_STATUS <> 0 BREAK
    -- Sprawdzenie czy wcześniejszy raport ma ustaloną datę zamknięcia
    IF EXISTS (SELECT * FROM CDN.BnkRaporty
               WHERE BRp_BRaID=@Rachunek AND BRp_DataDok < @DataOtw AND BRp_DataZam IS NULL)
    BEGIN
      RAISERROR('##OPT32248##', 16, 1) -- RAISERROR('Wcześniejszy raport nie ma ustalonej daty zamknięcia.', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- Sprawdzenie czy data zamknięcia nie jest NULL-em w przypadku, gdy istnieją późniejsze raporty
    IF @DataZam IS NULL
       IF EXISTS (SELECT * FROM CDN.BnkRaporty
               WHERE BRp_BRaID=@Rachunek AND BRp_DataDok > @DataOtw)
       BEGIN
         RAISERROR('##OPT32249##', 16, 1) -- RAISERROR('Raport musi mieć ustaloną datę zamknięcia, ponieważ istnieją raporty późniejsze.', 16, 1)
         ROLLBACK TRAN
         SET NOCOUNT OFF
         RETURN
       END
    -- Sprawdzenie czy raport nie nakłada się czasowo z innym
    IF EXISTS (SELECT * FROM CDN.BnkRaporty
               WHERE BRp_BRaID=@Rachunek AND BRp_BRpID<>@Raport AND
                    (BRp_DataZam IS NOT NULL AND @DataOtw    BETWEEN BRp_DataDok AND BRp_DataZam OR
                     @DataZam    IS NOT NULL AND BRp_DataDok BETWEEN @DataOtw    AND @DataZam))
    BEGIN
      RAISERROR('##OPT32250##', 16, 1) -- RAISERROR('Raport nakłada się czasowo na inny raport.', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- Sprawdzenie czy po otwartym raporcie nie ma raportów zamkniętych
 /*
    IF @Zamkniety=0
      IF EXISTS (SELECT * FROM CDN.BnkRaporty
                WHERE BRp_BRaID=@Rachunek AND BRp_Zamkniety=1 AND BRp_DataDok>@DataOtw)
      BEGIN
        RAISERROR('Po raporcie otwartym występuje raport zamknięty.', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
      END
 */
    -- Sprawdzenie czy dla O!O czy nie istnieje już raport z późniejszą datą. (ZG)
    IF ( Select TOP 1 ISNULL(MAX(CONVERT(NVarchar(1), Fir_Wartosc)),'') From CDN.Firma Where Fir_Numer=1470 ) = '4'
      BEGIN
        IF ( UPDATE(BRp_NumerNr) OR UPDATE(BRp_DataDok) OR UPDATE(BRp_NumerString) )
          BEGIN
            DECLARE
             @NumerNrMin DATETIME,
             @NumerNrMax DATETIME
            SELECT TOP 1 @NumerNrMin = ISNULL(BRp_NumerNr,0) FROM cdn.BnkRaporty WHERE BRp_NumerString = @NumerString AND BRp_DataDok < @DataOtw ORDER BY BRp_DataDok DESC
            SELECT TOP 1 @NumerNrMax = ISNULL(BRp_NumerNr,0) FROM cdn.BnkRaporty WHERE BRp_NumerString = @NumerString AND BRp_DataDok > @DataOtw ORDER BY BRp_DataDok
            IF NOT ( @NumerNr BETWEEN @NumerNrMin AND @NumerNrMax )
              BEGIN
                RAISERROR('##OPT32251##', 16, 1) -- RAISERROR('Kolejność numerów niezgodna z kolejnością dat.', 16, 1)
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
          END
        IF UPDATE (BRp_Zamkniety) AND @Zamkniety = 1
          BEGIN
            SET @TrN_Numer_Pa = Null; SET @TrN_Numer_Fa = Null
            SELECT Top 1 @TrN_Numer_Pa = A.TrN_NumerPelny, @TrN_Numer_Fa = B.TrN_NumerPelny FROM CDN.BnkZapisy
              JOIN CDN.BnkRozRelacje On BRR_ZDokTyp = 2 AND BRR_ZDokId = BZp_BZpId
              JOIN CDN.BnkZdarzenia  On BRR_DDokTyp = 1 AND BRR_DDokId = BZd_BZdId
              JOIN CDN.TraNag A      On BZd_DokumentTyp = 1 AND BZd_DokumentId = A.TrN_TrNId
              JOIN CDN.TraNagRelacje On A.TrN_TrNId = TrR_TrNId
              JOIN CDN.TraNag B      On B.TrN_TrNId =  TrR_FAId
              WHERE BZp_BRpId = @Raport AND A.TrN_TypDokumentu = 305 AND B.TrN_TypDokumentu = 302 AND B.TrN_Bufor <> 0
            IF @TrN_Numer_Pa Is Not Null
                BEGIN
     RAISERROR('##OPT32251##%%paragon%%=%s%%faktura%%=%s##', 16, 1, @TrN_Numer_Pa, @TrN_Numer_Fa) -- RAISERROR('W raporcie występuje zapis do paragonu %s powiązanego z fakturą %s w buforze.', 16, 1, @TrN_Numer_Pa, @TrN_Numer_Fa)
                  ROLLBACK TRAN
                  SET NOCOUNT OFF
                  RETURN
                END
          END
      END
    -- Sprawdzenie czy przed zamykanym raportem nie ma raportów otwartych
 /*
    IF @Zamkniety=1
      IF EXISTS (SELECT * FROM CDN.BnkRaporty
                WHERE BRp_BRaID=@Rachunek AND BRp_Zamkniety=0 AND BRp_DataDok<@DataOtw)
      BEGIN
        RAISERROR('Przed raportem zamkniętym występuje raport otwarty.', 16, 1)
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
      END
   */
    -- Ustawianie salda BO otwartego raportu
    IF @Zamkniety=0 AND
      (NOT UPDATE(BRp_SaldoBO) AND NOT UPDATE(BRp_SaldoBOSys) OR NOT EXISTS (SELECT * FROM deleted WHERE deleted.BRp_BRpID=@raport)) -- warunek aby trigger nie zapętlił się (nie wywołał się sam)
      BEGIN
        SELECT TOP 1 @PoprzedniZamkniety = BRp_Zamkniety, @NoweSaldoBO = BRp_SaldoBO+BRp_Przychody-BRp_Rozchody,
            @NoweSaldoBOSys = BRp_SaldoBOSys+BRp_PrzychodySys-BRp_RozchodySys+BRp_RoznicaKursowaSysMW
        FROM CDN.BnkRaporty
        WHERE BRp_BRaID=@Rachunek AND BRp_DataDok<@DataOtw ORDER BY BRp_BRaID, BRp_DataDok DESC
        IF @PoprzedniZamkniety is null -- pierwszy raport danego rachunku
          SELECT @NoweSaldoBO = BRa_SaldoBO, @NoweSaldoBOSys = BRa_SaldoBOSys FROM CDN.BnkRachunki WHERE BRa_BRaID=@Rachunek
        ELSE
          IF @PoprzedniZamkniety=0 SELECT @NoweSaldoBO = 0, @NoweSaldoBOSys = 0
        IF @NoweSaldoBO is null    SET @NoweSaldoBO = 0
        IF @NoweSaldoBOSys is null SET @NoweSaldoBOSys = 0
        UPDATE CDN.BnkRaporty SET BRp_SaldoBO=@NoweSaldoBO, BRp_SaldoBOSys=@NoweSaldoBOSys WHERE BRp_BRpID=@Raport -- AND BRp_SaldoBO<>@NoweSaldoBO
        IF @@ERROR <> 0
        BEGIN
          RAISERROR('##OPT32253##', 16, 1) -- RAISERROR('Błąd aktualizacji salda początkowego raportu.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
      END
    -- Zerowanie BO następnego raportu, po otwartym
    IF @Zamkniety=0 AND
      (NOT UPDATE(BRp_SaldoBO) AND NOT UPDATE(BRp_SaldoBOSys) OR NOT EXISTS (SELECT * FROM deleted WHERE deleted.BRp_BRpID=@raport)) -- warunek aby trigger nie zapętlił się (nie wywołał się sam)
    BEGIN
      SET @NastepnyRaport =
      (SELECT TOP 1 BRp_BRpID FROM CDN.BnkRaporty
       WHERE BRp_BRaID=@Rachunek AND BRp_DataDok>@DataOtw ORDER BY BRp_BRaID, BRp_DataDok)
      IF @NastepnyRaport is not null
      BEGIN
        UPDATE CDN.BnkRaporty SET BRp_SaldoBO=0, BRp_SaldoBOSys=0 WHERE BRp_BRpID=@NastepnyRaport -- AND BRp_SaldoBO<>0
        IF @@ERROR <> 0
        BEGIN
   RAISERROR('##OPT32254##', 16, 1) -- RAISERROR('Błąd zerowania salda początkowego następnego raportu.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
      END
    END
    -- Aktualizacja BO następnego raportu, po zamkniętym
    IF @Zamkniety=1 AND
      (NOT UPDATE(BRp_SaldoBO) AND NOT UPDATE(BRp_SaldoBOSys) OR NOT EXISTS (SELECT * FROM deleted WHERE deleted.BRp_BRpID=@raport)) -- warunek aby trigger nie zapętlił się (nie wywołał się sam)
    BEGIN
      SET @NastepnyRaport =
      (SELECT TOP 1 BRp_BRpID FROM CDN.BnkRaporty
       WHERE BRp_BRaID=@Rachunek AND BRp_DataDok>@DataOtw ORDER BY BRp_BRaID, BRp_DataDok)
      IF @NastepnyRaport is not null
      BEGIN
        UPDATE CDN.BnkRaporty SET BRp_SaldoBO=@SaldoBO+@Przychody-@Rozchody, BRp_SaldoBOSys=@SaldoBOSys+@PrzychodySys-@RozchodySys+@RoznicaKursowaSysMW WHERE BRp_BRpID=@NastepnyRaport -- AND BRp_SaldoBO<>@SaldoBO+@Przychody-@Rozchody
        IF @@ERROR <> 0
        BEGIN
   RAISERROR('##OPT32255##', 16, 1) -- RAISERROR('Błąd aktualizacji salda początkowego następnego raportu (po zamkniętym).', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
      END
    END
    -- Sprawdzenie unikalności numeru raportu
    IF EXISTS (SELECT * FROM CDN.BnkRaporty WHERE BRp_NumerPelny = @NumerPelny AND BRp_BRpId <> @Raport)
    BEGIN
  RAISERROR('##OPT32256##', 16, 1) -- RAISERROR('Istnieje już raport o podanym numerze. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  END
  CLOSE CursorInserted;
-- Kasowanie wskanika wyeksportowania przy otwieraniu
If Update (BRp_Zamkniety) And Exists (Select * From inserted Where BRp_TS_Export Is Not Null And BRp_Zamkniety = 0)
 Begin
  Update CDN.BnkRaporty Set BRp_TS_Export = Null Where BRp_BRpId In (Select BRp_BRpId From inserted Where BRp_TS_Export Is Not Null And BRp_Zamkniety = 0)
  Update CDN.BnkZapisy  Set BZp_TS_Export = Null Where BZp_BRpId In (Select BRp_BRpId From inserted Where BRp_TS_Export Is Not Null And BRp_Zamkniety = 0)
 End
If Update (BRp_TS_Export)
 Begin
  Update CDN.BnkZapisy Set BZp_TS_Export = BRp_TS_Export
   From CDN.BnkZapisy Join inserted On BZp_BRpId = BRp_BRpId Where IsNull(BZp_TS_Export, Convert(datetime, '1900-01-01', 120)) <> IsNull(BRp_TS_Export, Convert(datetime, '1900-01-01', 120))
 End
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where BRp_ImportRowId Is Null Or BRp_ImportRowId = '')
  Update CDN.BnkRaporty Set BRp_ImportRowId = NewId()
  Where BRp_BRpId In (Select BRp_BRpId From inserted Where BRp_ImportRowId Is Null Or BRp_ImportRowId = '')
-- aktualizacja BRpAgregaty (9.0)
-- kasowanie agregatów przy otwieraniu raportu
IF EXISTS ( SELECT * FROM deleted )
  DELETE FROM CDN.BRpAgregaty WHERE BAg_BRpId IN ( SELECT D.BRp_BRpId FROM inserted I JOIN deleted D ON I.BRp_BRpId = D.BRp_BRpId WHERE I.BRp_Zamkniety <> 1 AND D.BRp_Zamkniety = 1 )
-- budowanie agregatów przy zamykaniu raportu
IF EXISTS ( SELECT * FROM inserted )
  BEGIN
    DECLARE @BrP_BrPId INT
    DECLARE U CURSOR LOCAL FAST_FORWARD FOR
      SELECT I.BRp_BRpId FROM inserted I JOIN deleted D ON I.BRp_BRpId = D.BRp_BRpId WHERE I.BRp_Zamkniety = 1 AND D.BRp_Zamkniety <> 1
      OPEN U
        WHILE 1=1
        BEGIN
          FETCH NEXT FROM U INTO @BrP_BrPId
          IF @@FETCH_STATUS <> 0 BREAK
          EXEC CDN.AktualizujBRpAgregaty @BRp_BRpId
        END
      CLOSE U
    DEALLOCATE U
  END
