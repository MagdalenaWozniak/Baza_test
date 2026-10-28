CREATE TABLE [CDN].[TwrGrupy] (
    [TwG_TwGID]           INT            IDENTITY (1, 1) NOT NULL,
    [TwG_GIDTyp]          SMALLINT       NOT NULL,
    [TwG_GIDFirma]        INT            NULL,
    [TwG_GIDNumer]        INT            NOT NULL,
    [TwG_GIDLp]           SMALLINT       NULL,
    [TwG_GrOTyp]          SMALLINT       NOT NULL,
    [TwG_GrOFirma]        INT            NULL,
    [TwG_GrONumer]        INT            NOT NULL,
    [TwG_GrOLp]           SMALLINT       NULL,
    [TwG_Kod]             VARCHAR (50)   NOT NULL,
    [TwG_Nazwa]           NVARCHAR (255) NOT NULL,
    [TwG_CzasModyfikacji] INT            NULL,
    [TwG_eSklepLp]        INT            NULL,
    CONSTRAINT [TwG_Primary] PRIMARY KEY CLUSTERED ([TwG_TwGID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [TwGGID]
    ON [CDN].[TwrGrupy]([TwG_GIDTyp] ASC, [TwG_GIDNumer] ASC, [TwG_GrOTyp] ASC, [TwG_GrONumer] ASC)
    INCLUDE([TwG_TwGID], [TwG_Kod], [TwG_Nazwa]) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwGKod]
    ON [CDN].[TwrGrupy]([TwG_GrOTyp] ASC, [TwG_GrONumer] ASC, [TwG_GIDTyp] ASC, [TwG_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwGGIDKod]
    ON [CDN].[TwrGrupy]([TwG_GIDTyp] ASC, [TwG_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwGNazwa]
    ON [CDN].[TwrGrupy]([TwG_GrOTyp] ASC, [TwG_GrONumer] ASC, [TwG_GIDTyp] ASC, [TwG_Nazwa] ASC, [TwG_GIDNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE    TRIGGER CDN.TwrGrupyInsertUpdate_CzasModyfikacji
  ON CDN.TwrGrupy
  FOR INSERT, UPDATE
AS
BEGIN
SET NOCOUNT ON
  UPDATE CDN.TwrGrupy SET TwG_CzasModyfikacji = DATEDIFF(s,CONVERT(datetime,'1990-01-01',120),GETDATE())
       FROM  CDN.TwrGrupy T JOIN inserted I ON T.TwG_GIDNumer = I.TwG_GIDNumer AND T.TwG_GIDTyp = I.TwG_GIDTyp
   update cdn.danebinarne set dab_ts_mod = getdate()
       where dab_dabid in (select DBL_DabId from CDN.DaneBinarneLinki where not DBL_DabId is null and DBL_TwrID in (
       select i.TwG_GidNumer from inserted i
       left join deleted d on d.TwG_TwGID = i.TwG_TwGID
       where i.TwG_GidTyp = 16 and isnull(d.TwG_GrONumer,-5) <> i.TwG_GrONumer
       ))
SET NOCOUNT OFF
END

GO
CREATE TRIGGER [CDN].[TwrLinkiDelete] ON [CDN].[TwrGrupy]
FOR     DELETE
AS
SET NOCOUNT ON
DECLARE @GidTyp SMALLINT
DECLARE @GidFirma INT
DECLARE @GidNumer INT
DECLARE @GroTyp SMALLINT
DECLARE @GroFirma INT
DECLARE @GroNumer INT
DECLARE @prevcount INT
DECLARE @count INT
DECLARE TriggerCursor CURSOR FOR
SELECT TWG_GIDTyp,TWG_GIDFirma,TWG_GIDNumer,
        TWG_GROTyp,TWG_GROFirma,
        TWG_GRONumer FROM DELETED
OPEN TriggerCursor
FETCH NEXT FROM TriggerCursor INTO @GIDTyp,@GIDFirma,@GIDNumer,@GROTyp,@GROFirma,@GRONumer
WHILE @@FETCH_STATUS = 0
BEGIN
        SET     @prevcount=0
        SET     @count=-1
        --tu z DELETED oczywiscie
        CREATE TABLE #gronumery(GN INT,C INT)
        IF (@GIDTyp=-16)
        BEGIN
        INSERT INTO     #gronumery exec CDN.TwrRodzice @GroNumer
        --INSERT INTO CDN.TwrLinki SELECT TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,-16,@GROFirma,GN,0,0,0 FROM (SELECT CDN.TwrLinki.TWL_GIDTyp,CDN.TwrLinki.TWL_GIDFirma,CDN.TwrLinki.TWL_GIDNumer,CDN.TwrLinki.TWL_GIDLp,GN,Linki.TWL_GRONumer AS GRO FROM CDN.TwrLinki RIGHT OUTER JOIN #gronumery ON TWL_GRONumer=@GIDNumer LEFT OUTER JOIN CDN.TwrLinki AS Linki ON Linki.TWL_GIDNumer=CDN.TwrLinki.TWL_GIDNumer AND Linki.TWL_GRONumer=GN) SelectWewn WHERE GRO IS NULL
        UPDATE CDN.TwrLinki     --update dla wszystkich elementow nalezacych do grupy, ktora zostala usunieta
        SET     TWL_LiczbaPowtorzen=TWL_LiczbaPowtorzen-(SELECT (C)     FROM #gronumery WHERE TWL_GRONumer=GN),
        TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TWL_GRONumer IN (SELECT GN FROM #gronumery)     AND
        TWL_GIDNumer IN (SELECT TWL_GIDNumer FROM CDN.TwrLinki WHERE TWL_GRONumer=@GIDNumer)
        DELETE FROM     CDN.TwrLinki WHERE TWL_LiczbaPowtorzen=0
        TRUNCATE TABLE #gronumery
        --DROP TABLE #gronumery
        END
--      IF (@GIDTyp=16)
--      BEGIN
        INSERT INTO     #gronumery exec CDN.TwrRodzice @GroNumer
        --INSERT INTO CDN.TwrLinki SELECT TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,-16,@GROFirma,GN,0,0,0 FROM (SELECT CDN.TwrLinki.TWL_GIDTyp,CDN.TwrLinki.TWL_GIDFirma,CDN.TwrLinki.TWL_GIDNumer,CDN.TwrLinki.TWL_GIDLp,GN,Linki.TWL_GRONumer AS GRO FROM CDN.TwrLinki RIGHT OUTER JOIN #gronumery ON TWL_GRONumer=@GIDNumer LEFT OUTER JOIN CDN.TwrLinki AS Linki ON Linki.TWL_GIDNumer=CDN.TwrLinki.TWL_GIDNumer AND Linki.TWL_GRONumer=GN) SelectWewn WHERE GRO IS NULL
        UPDATE CDN.TwrLinki     --update dla wszystkich elementow nalezacych do grupy, ktora zostala usunieta
        SET     TWL_LiczbaPowtorzen=TWL_LiczbaPowtorzen-(SELECT (C)     FROM #gronumery WHERE TWL_GRONumer=GN),
        TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TWL_GRONumer IN (SELECT GN FROM #gronumery)     AND
        TWL_GIDNumer=@GIDNumer AND TWL_GIDTyp=@GIDTyp
        UPDATE CDN.TwrLinki     --ustawienie liscia
        SET     TWL_Lisc=0,TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TwL_GiDTyp = @GidTyp AND
        TwL_GiDFirma = @GidFirma AND
        TwL_GiDNumer = @GidNumer AND
        TwL_GroTyp = @GroTyp AND
        TwL_GroFirma = @GroFirma AND
        TwL_GroNumer =@GROnumer
        DELETE FROM     CDN.TwrLinki WHERE TWL_LiczbaPowtorzen=0 AND TWL_GIDTyp = @GIDTyp
        DROP TABLE #gronumery
--      END
        FETCH NEXT FROM TriggerCursor INTO @GIDTyp,@GIDFirma,@GIDNumer,@GROTyp,@GROFirma,@GRONumer
END
CLOSE TriggerCursor
DEALLOCATE TriggerCursor

GO
CREATE TRIGGER CDN.TwrGrupy_Delete_Trigger
  ON CDN.TwrGrupy
  FOR DELETE
AS
SET NOCOUNT ON
-- obsługa sprawdzania czy nie kasujemy Grupy Głównej (TwG_TwGID = 0)
IF EXISTS (SELECT * FROM deleted WHERE deleted.TwG_TwGId = 0)
  BEGIN
    RAISERROR('##OPT34544##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.TwrGrupy, kasowanie grupy z towarem
IF EXISTS (
  SELECT * FROM CDN.TwrGrupy A, deleted
  WHERE A.TwG_GrONumer = deleted.TwG_GIDNumer and deleted.TwG_GIDTyp = -16 and A.TwG_GIDTyp = 16
  )
  BEGIN
    RAISERROR('##OPT34545##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.TwrGrupy, kasowanie grupy z grupą podrzędną
IF EXISTS (
  SELECT * FROM CDN.TwrGrupy A, deleted
  WHERE A.TwG_GrONumer = deleted.TwG_GIDNumer and deleted.TwG_GIDTyp = -16 and A.TwG_GIDTyp = -16
  )
  BEGIN
    RAISERROR('##OPT34546##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- kontrola grup w konfiguracji
    IF EXISTS (SELECT DSta_TwGGIDNumer FROM cdn.DetalStanowiska WHERE DSta_TwGGIDNumer in (SELECT deleted.TwG_GIDNumer FROM deleted where TwG_GIDTyp = -16))
    BEGIN
      RAISERROR('##OPT34547##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT ESS_TwGNumer FROM cdn.eSklepStanowiska WHERE ESS_TwGNumer in (SELECT deleted.TwG_GIDNumer FROM deleted where TwG_GIDTyp = -16))
    BEGIN
      RAISERROR('##OPT34548##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- obsługa usuwania rabatów kasowanej grupy
  DELETE FROM CDN.Rabaty WHERE
        Rab_TwrID IN (SELECT TWG_GIDNumer FROM deleted WHERE TWG_GIDTyp = -16 ) AND Rab_Typ IN (3, 5, 7);
-- obsługa czasu modyfikacji
  UPDATE CDN.TwrGrupy SET TwG_CzasModyfikacji = DATEDIFF(s,CONVERT(datetime,'1990-01-01',120),GETDATE())
       FROM  CDN.TwrGrupy T JOIN deleted D ON T.TwG_GIDNumer = D.TwG_GrONumer AND T.TwG_GIDTyp = D.TwG_GrOTyp
  WHERE D.TwG_GIDTyp=-16
  UPDATE CDN.TwrGrupy SET TwG_CzasModyfikacji = DATEDIFF(s,CONVERT(datetime,'1990-01-01',120),GETDATE())
       FROM  CDN.TwrGrupy T JOIN deleted D ON T.TwG_GIDNumer = D.TwG_GIDNumer AND T.TwG_GIDTyp = D.TwG_GIDTyp
  WHERE D.TwG_GIDTyp=16
-- jak kasujemy grupe z towaru ktory jest wyslany do detalu
if exists(SELECT TWG_GIDNumer FROM deleted
join cdn.towary on twr_twrid = twg_gidnumer
WHERE TWG_GIDTyp = 16 and  Twr_GIdfirma = 2)
begin
Update CDN.DetalStanowiska SET DSta_TS_SynchroTwr = '1900-01-01 00:00:00.000'
end
 -- Usuwanie wymiarów analitycznych
  DECLARE @WADokumentTyp int = 0;
  select @WADokumentTyp=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Grupy towarowe';
 if exists(select * from CDN.WymiaryWartosci where WyW_DokumentTyp = @WADokumentTyp and WyW_DokumentId in (select deleted.TwG_TwGId from deleted))
  delete from CDN.WymiaryWartosci where WyW_DokumentTyp = @WADokumentTyp
  and WyW_DokumentId in (select deleted.TwG_TwGId from deleted)
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TwrGrupy_After_Insert_Trigger
ON CDN.TwrGrupy
AFTER INSERT
AS
 SET NOCOUNT ON
 declare @dokumentTypGrupyTowarowe int = 0;
 declare @dokumentTypTowary int = 0;
 declare @dokumentTyp int = 0;
 select @dokumentTypGrupyTowarowe = ID from CDN.ListaDokumentowWymiarowanych() where nazwa = 'Grupy towarowe';
 declare @ID int;
 declare @SrcID int;
 declare @Typ int;
 declare @ParentId int;
 declare @TwrId int;
 DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR
 SELECT TwG_TwGID, TwG_GrONumer, TwG_GIDTyp, TwG_GIDNumer FROM inserted
 OPEN Dodane
 WHILE 1=1
 begin
  FETCH NEXT FROM Dodane INTO @ID, @ParentId, @Typ, @TwrId
  IF @@FETCH_STATUS <> 0 BREAK
      if @Typ < 0
      begin
        set @dokumentTyp = @dokumentTypGrupyTowarowe;
        select @SrcID = TwG_TwGID from CDN.TwrGrupy where TwG_GIDTyp=-16 and TwG_GIDNumer = @ParentId;
        insert into CDN.WymiaryWartosci (WyW_WyyId, WyW_Guid, WyW_Wartosc, WyW_DokumentTyp, WyW_DokumentId, WyW_Procent, WyW_Kwota, WyW_SlownikId, WyW_LpPozycji)
        SELECT WyW_WyyId, WyW_Guid, WyW_Wartosc, WyW_DokumentTyp, @ID, WyW_Procent, WyW_Kwota, WyW_SlownikId, WyW_LpPozycji
        FROM CDN.WymiaryWartosci
        where WyW_DokumentTyp = @dokumentTyp and WyW_DokumentId = @SrcID
        order by WyW_Guid;
      end
 end
 Close Dodane
 Deallocate Dodane
 SET NOCOUNT OFF

GO
CREATE TRIGGER [CDN].[TwrLinkiInsert] ON [CDN].[TwrGrupy]
FOR     INSERT
AS
SET NOCOUNT ON
DECLARE @GidTyp SMALLINT
DECLARE @GidFirma INT
DECLARE @GidNumer INT
DECLARE @GroTyp SMALLINT
DECLARE @GroFirma INT
DECLARE @GroNumer INT
DECLARE @prevcount INT
DECLARE @count INT
DECLARE TriggerCursor CURSOR FOR
SELECT TWG_GIDTyp,TWG_GIDFirma,TWG_GIDNumer,
        TWG_GROTyp,TWG_GROFirma,
        TWG_GRONumer FROM INSERTED
OPEN TriggerCursor
FETCH NEXT FROM TriggerCursor INTO @GIDTyp,@GIDFirma,@GIDNumer,@GROTyp,@GROFirma,@GRONumer
WHILE @@FETCH_STATUS = 0
BEGIN
        SET     @prevcount=0
        SET     @count=-1
        --tu z INSERTED oczywiscie
        CREATE TABLE #gronumery(GN INT,C INT)
        IF (@GIDTyp=-16)
        BEGIN
        INSERT INTO     #gronumery exec CDN.TwrRodzice @GroNumer
        IF ((SELECT     COUNT(*) FROM CDN.TwrLinki WHERE TWL_GRONumer=@GIDNumer)>0)
        BEGIN
        INSERT INTO     CDN.TwrLinki (TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,TWL_GrOTyp,TWL_GrOFirma,TWL_GrONumer,TWL_GrOLp,TWL_Lisc,TWL_LiczbaPowtorzen,TWL_TStampDataMod)
        SELECT  TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,-16,@GROFirma,GN,0,0,0,DATEDIFF(S,'19900101',GETDATE()) FROM (SELECT CDN.TwrLinki.TWL_GIDTyp,CDN.TwrLinki.TWL_GIDFirma,CDN.TwrLinki.TWL_GIDNumer,CDN.TwrLinki.TWL_GIDLp,GN,Linki.TWL_GRONumer    AS GRO FROM     CDN.TwrLinki RIGHT OUTER JOIN #gronumery ON     TWL_GRONumer=@GIDNumer LEFT     OUTER JOIN CDN.TwrLinki AS Linki ON     Linki.TWL_GIDNumer=CDN.TwrLinki.TWL_GIDNumer AND Linki.TWL_GIDTyp=CDN.TwrLinki.TWL_GIDTyp AND Linki.TWL_GRONumer=GN) SelectWewn WHERE GRO IS    NULL
        UPDATE CDN.TwrLinki     --update dla wszystkich elementow nalezacych do grupy, ktora zostala wstawiona
        SET     TWL_LiczbaPowtorzen=TWL_LiczbaPowtorzen+(SELECT (C)     FROM #gronumery WHERE TWL_GRONumer=GN),
        TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TWL_GRONumer IN (SELECT GN FROM #gronumery)     AND
        TWL_GIDNumer IN (SELECT TWL_GIDNumer FROM CDN.TwrLinki WHERE TWL_GRONumer=@GIDNumer)
        END
        TRUNCATE TABLE #gronumery
        --DROP TABLE #gronumery
        END
--      IF (@GIDTyp=16)
--      BEGIN
        INSERT INTO     #gronumery exec CDN.TwrRodzice @GroNumer
        INSERT INTO     CDN.TwrLinki (TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,TWL_GrOTyp,TWL_GrOFirma,TWL_GrONumer,TWL_GrOLp,TWL_Lisc,TWL_LiczbaPowtorzen,TWL_TStampDataMod)
                SELECT @GIDTyp,@GIDFirma,@GIDNumer,0,-16,@GROFirma,GN,0,0,0,DATEDIFF( S , '19900101' , GETDATE()) FROM
                (SELECT @GIDNumer as GIDNr,GN,Linki.TWL_GRONumer as     GRO     FROM #gronumery
                LEFT OUTER JOIN CDN.TwrLinki AS Linki ON Linki.TWL_GIDNumer=@GIDNumer AND Linki.TWL_GIDTyp=@GIDTyp
                AND     Linki.TWL_GRONumer=GN) SelectWewn WHERE GRO     IS NULL  --insert brakujacych rekordow to TwrLinki
        UPDATE CDN.TwrLinki     -- dodanie odpowiedniej LP
        SET     TWL_LiczbaPowtorzen=TWL_LiczbaPowtorzen+(SELECT c FROM #gronumery WHERE GN=TWL_GRONumer),
        TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TwL_GiDTyp = @GidTyp AND
        TwL_GiDFirma = @GidFirma AND
        TwL_GiDNumer = @GidNumer AND
        TwL_GroTyp = @GroTyp AND
        TwL_GroFirma = @GroFirma AND
        TwL_GroNumer IN (SELECT GN FROM #gronumery)
        UPDATE CDN.TwrLinki     --ustawienie liscia
        SET     TWL_Lisc=1,TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TwL_GiDTyp = @GidTyp AND
        TwL_GiDFirma = @GidFirma AND
        TwL_GiDNumer = @GidNumer AND
        TwL_GroTyp = @GroTyp AND
        TwL_GroFirma = @GroFirma AND
        TwL_GroNumer =@GROnumer
        DROP TABLE #gronumery
--      END
        FETCH NEXT FROM TriggerCursor INTO @GIDTyp,@GIDFirma,@GIDNumer,@GROTyp,@GROFirma,@GRONumer
END
CLOSE TriggerCursor
DEALLOCATE TriggerCursor

GO
CREATE TRIGGER [CDN].[RO_TwrGrupy_InsertUpdateDelete_Trigger]
  ON [CDN].[TwrGrupy]
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
  DECLARE
  @TwG_TWGID INT,
  @TwG_Kod NVARCHAR(254),
  @TwG_CzasModyfikacji INT,
  @TypOperacji INT
  --select * from inserted
  DECLARE Dodane Cursor Local Fast_Forward For
  SELECT
  TwG_TWGID,
  TwG_Kod, TwG_CzasModyfikacji
  FROM inserted where TwG_GIDTyp = -16 and TwG_GrOTyp = -16
  Open Dodane
  While 1=1
  BEGIN
  Fetch Next From Dodane Into
   @TwG_TWGID,
   @TwG_Kod,@TwG_CzasModyfikacji
  If @@Fetch_Status <> 0 Break
 IF EXISTS(select * from deleted where deleted.TwG_TWGID = @TwG_TWGID)
   BEGIN
  SET @TypOperacji = 2
   END
   ELSE -- dodany
  SET @TypOperacji = 1
  if UPDATE(TwG_Kod) or UPDATE(TwG_Nazwa)
 EXEC CDN.RejestrOperacjiDodaj 1173, 0, @TwG_TWGID, @TwG_Kod, @TypOperacji, ''
  END
  DECLARE Usuniete Cursor Local Fast_Forward For
  SELECT
  TwG_TWGID,
  TwG_Kod
  FROM deleted where TwG_GIDTyp = -16 and TwG_GrOTyp = -16
  Open Usuniete
  While 1=1
  BEGIN
  Fetch Next From Usuniete Into
    @TwG_TWGID,
   @TwG_Kod
  If @@Fetch_Status <> 0 Break
   IF NOT EXISTS(select * from inserted where inserted.TwG_TWGID = @TwG_TWGID)
   BEGIN
  EXEC CDN.RejestrOperacjiDodaj 1173, 0, @TwG_TWGID, @TwG_Kod, 3, ''
   END
  END
  Close Dodane
  Close Usuniete
  Deallocate Dodane
  Deallocate Usuniete
  SET NOCOUNT OFF

GO
CREATE TRIGGER [CDN].[TwrLinkiUpdate] ON [CDN].[TwrGrupy]
FOR     UPDATE
AS
SET NOCOUNT ON
IF NOT (UPDATE(TwG_GIDTyp) OR UPDATE(TwG_GIDFirma) OR UPDATE(TwG_GIDNumer) OR UPDATE(TwG_GIDLp) OR
                UPDATE(TwG_GrOTyp) OR UPDATE(TwG_GrOFirma) OR UPDATE(TwG_GrONumer) OR UPDATE(TwG_GrOLp))
                RETURN
DECLARE @GidTyp SMALLINT
DECLARE @GidFirma INT
DECLARE @GidNumer INT
DECLARE @GroTyp SMALLINT
DECLARE @GroFirma INT
DECLARE @GroNumer INT
DECLARE @prevcount INT
DECLARE @count INT
DECLARE TriggerCursorDeleted CURSOR FOR
SELECT TWG_GIDTyp,TWG_GIDFirma,TWG_GIDNumer,
        TWG_GROTyp,TWG_GROFirma,
        TWG_GRONumer FROM DELETED
DECLARE TriggerCursorInserted CURSOR FOR
SELECT TWG_GIDTyp,TWG_GIDFirma,TWG_GIDNumer,
        TWG_GROTyp,TWG_GROFirma,
        TWG_GRONumer FROM INSERTED
OPEN TriggerCursorDeleted
OPEN TriggerCursorInserted
FETCH NEXT FROM TriggerCursorDeleted INTO @GIDTyp,@GIDFirma,@GIDNumer,@GROTyp,@GROFirma,@GRONumer
WHILE @@FETCH_STATUS = 0
BEGIN
        SET     @prevcount=0
        SET     @count=-1
        CREATE TABLE #gronumery(GN INT,C INT)
        IF (@GIDTyp=-16)
        BEGIN
        INSERT INTO     #gronumery exec CDN.TwrRodzice @GroNumer
        --INSERT INTO CDN.TwrLinki SELECT TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,-16,@GROFirma,GN,0,0,0 FROM (SELECT CDN.TwrLinki.TWL_GIDTyp,CDN.TwrLinki.TWL_GIDFirma,CDN.TwrLinki.TWL_GIDNumer,CDN.TwrLinki.TWL_GIDLp,GN,Linki.TWL_GRONumer AS GRO FROM CDN.TwrLinki RIGHT OUTER JOIN #gronumery ON TWL_GRONumer=@GIDNumer LEFT OUTER JOIN CDN.TwrLinki AS Linki ON Linki.TWL_GIDNumer=CDN.TwrLinki.TWL_GIDNumer AND Linki.TWL_GRONumer=GN) SelectWewn WHERE GRO IS NULL
        UPDATE CDN.TwrLinki     --update dla wszystkich elementow nalezacych do grupy, ktora zostala usunieta
        SET     TWL_LiczbaPowtorzen=TWL_LiczbaPowtorzen-(SELECT (C)     FROM #gronumery WHERE TWL_GRONumer=GN),
        TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TWL_GRONumer IN (SELECT GN FROM #gronumery)     AND
        TWL_GIDNumer IN (SELECT TWL_GIDNumer FROM CDN.TwrLinki WHERE TWL_GRONumer=@GIDNumer)
        DELETE FROM     CDN.TwrLinki WHERE TWL_LiczbaPowtorzen=0
        TRUNCATE TABLE #gronumery
        END
--      IF (@GIDTyp=16)
--      BEGIN
        INSERT INTO     #gronumery exec CDN.TwrRodzice @GroNumer
        --INSERT INTO CDN.TwrLinki SELECT TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,-16,@GROFirma,GN,0,0,0 FROM (SELECT CDN.TwrLinki.TWL_GIDTyp,CDN.TwrLinki.TWL_GIDFirma,CDN.TwrLinki.TWL_GIDNumer,CDN.TwrLinki.TWL_GIDLp,GN,Linki.TWL_GRONumer AS GRO FROM CDN.TwrLinki RIGHT OUTER JOIN #gronumery ON TWL_GRONumer=@GIDNumer LEFT OUTER JOIN CDN.TwrLinki AS Linki ON Linki.TWL_GIDNumer=CDN.TwrLinki.TWL_GIDNumer AND Linki.TWL_GRONumer=GN) SelectWewn WHERE GRO IS NULL
        UPDATE CDN.TwrLinki     --update dla wszystkich elementow nalezacych do grupy, ktora zostala usunieta
        SET     TWL_LiczbaPowtorzen=TWL_LiczbaPowtorzen-(SELECT (C)     FROM #gronumery WHERE TWL_GRONumer=GN),
        TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TWL_GRONumer IN (SELECT GN FROM #gronumery)     AND
        TWL_GIDNumer=@GIDNumer AND TWL_GIDTyp = @GIDTyp
        UPDATE CDN.TwrLinki     --ustawienie liscia
        SET     TWL_Lisc=0,TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TwL_GiDTyp = @GidTyp AND
        TwL_GiDFirma = @GidFirma AND
        TwL_GiDNumer = @GidNumer AND
        TwL_GroTyp = @GroTyp AND
        TwL_GroFirma = @GroFirma AND
        TwL_GroNumer =@GROnumer
        DELETE FROM     CDN.TwrLinki WHERE TWL_LiczbaPowtorzen=0 AND TwL_GIDTyp = @GIDTyp
--      END
        --SELECT @GIDTyp=TWG_GIDTyp,@GIDFirma=TWG_GIDFirma,@GIDNumer=TWG_GIDNumer,
        --      @GROTyp=TWG_GROTyp,@GROFirma=TWG_GROFirma,
        --      @GRONumer=TWG_GRONumer FROM INSERTED WHERE
        FETCH NEXT FROM TriggerCursorInserted INTO @GIDTyp,@GIDFirma,@GIDNumer,@GROTyp,@GROFirma,@GRONumer
        SET     @prevcount=0
        SET     @count=-1
        --tu z INSERTED oczywiscie
        DELETE FROM     #gronumery
        IF (@GIDTyp=-16)
        BEGIN
        INSERT INTO     #gronumery exec CDN.TwrRodzice @GroNumer
        IF ((SELECT     COUNT(*) FROM CDN.TwrLinki WHERE TWL_GRONumer=@GIDNumer)>0)
        BEGIN
        INSERT INTO     CDN.TwrLinki (TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,TWL_GrOTyp,TWL_GrOFirma,TWL_GrONumer,TWL_GrOLp,TWL_Lisc,TWL_LiczbaPowtorzen,TWL_TStampDataMod)
        SELECT  TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,-16,@GROFirma,GN,0,0,0,DATEDIFF(S,'19900101',GETDATE()) FROM (SELECT CDN.TwrLinki.TWL_GIDTyp,CDN.TwrLinki.TWL_GIDFirma,CDN.TwrLinki.TWL_GIDNumer,CDN.TwrLinki.TWL_GIDLp,GN,Linki.TWL_GRONumer    AS GRO FROM     CDN.TwrLinki RIGHT OUTER JOIN #gronumery ON     TWL_GRONumer=@GIDNumer LEFT     OUTER JOIN CDN.TwrLinki AS Linki ON     Linki.TWL_GIDNumer=CDN.TwrLinki.TWL_GIDNumer AND Linki.TWL_GIDTyp=CDN.TwrLinki.TWL_GIDTyp AND Linki.TWL_GRONumer=GN)    SelectWewn WHERE GRO IS NULL
        UPDATE CDN.TwrLinki     --update dla wszystkich elementow nalezacych do grupy, ktora zostala wstawiona
        SET     TWL_LiczbaPowtorzen=TWL_LiczbaPowtorzen+(SELECT (C)     FROM #gronumery WHERE TWL_GRONumer=GN),
        TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TWL_GRONumer IN (SELECT GN FROM #gronumery)     AND
        TWL_GIDNumer IN (SELECT TWL_GIDNumer FROM CDN.TwrLinki WHERE TWL_GRONumer=@GIDNumer)
        END
        TRUNCATE TABLE #gronumery
        --DROP TABLE #gronumery
        END
--      IF (@GIDTyp=16)
--      BEGIN
        INSERT INTO     #gronumery exec CDN.TwrRodzice @GroNumer
        INSERT INTO     CDN.TwrLinki (TWL_GIDTyp,TWL_GIDFirma,TWL_GIDNumer,TWL_GIDLp,TWL_GrOTyp,TWL_GrOFirma,TWL_GrONumer,TWL_GrOLp,TWL_Lisc,TWL_LiczbaPowtorzen,TWL_TStampDataMod)
                SELECT @GIDTyp,@GIDFirma,@GIDNumer,0,-16,@GROFirma,GN,0,0,0,DATEDIFF(S,'19900101',GETDATE()) FROM
                (SELECT @GIDNumer as GIDNr,GN,Linki.TWL_GRONumer as     GRO     FROM #gronumery
                LEFT OUTER JOIN CDN.TwrLinki AS Linki ON Linki.TWL_GIDNumer=@GIDNumer AND Linki.TWL_GIDTyp=@GIDTyp
                AND     Linki.TWL_GRONumer=GN) SelectWewn WHERE GRO     IS NULL  --insert brakujacych rekordow to TwrLinki
        UPDATE CDN.TwrLinki     -- dodanie odpowiedniej LP
        SET     TWL_LiczbaPowtorzen=TWL_LiczbaPowtorzen+(SELECT c FROM #gronumery WHERE GN=TWL_GRONumer),
        TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TwL_GiDTyp = @GidTyp AND
        TwL_GiDFirma = @GidFirma AND
        TwL_GiDNumer = @GidNumer AND
        TwL_GroTyp = @GroTyp AND
        TwL_GroFirma = @GroFirma AND
        TwL_GroNumer IN (SELECT GN FROM #gronumery)
        UPDATE CDN.TwrLinki     --ustawienie liscia
        SET     TWL_Lisc=1,TWL_TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
        WHERE
        TwL_GiDTyp = @GidTyp AND
        TwL_GiDFirma = @GidFirma AND
        TwL_GiDNumer = @GidNumer AND
        TwL_GroTyp = @GroTyp AND
        TwL_GroFirma = @GroFirma AND
        TwL_GroNumer =@GROnumer
        DROP TABLE #gronumery
--      END
        FETCH NEXT FROM TriggerCursorDeleted INTO @GIDTyp,@GIDFirma,@GIDNumer,@GROTyp,@GROFirma,@GRONumer
END
CLOSE TriggerCursorDeleted
CLOSE TriggerCursorInserted
DEALLOCATE TriggerCursorDeleted
DEALLOCATE TriggerCursorInserted
