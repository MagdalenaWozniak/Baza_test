CREATE TABLE [CDN].[DekretyElem] (
    [DeE_DeEId]             INT             IDENTITY (1, 1) NOT NULL,
    [DeE_DeNId]             INT             NOT NULL,
    [DeE_Lp]                INT             NOT NULL,
    [DeE_DataWys]           DATETIME        NOT NULL,
    [DeE_DataOpe]           DATETIME        NOT NULL,
    [DeE_Dokument]          VARCHAR (256)   NOT NULL,
    [DeE_DataKur]           DATETIME        NOT NULL,
    [DeE_SlownikTyp]        SMALLINT        NULL,
    [DeE_SlownikId]         INT             NULL,
    [DeE_KatId]             INT             NULL,
    [DeE_Kategoria]         VARCHAR (256)   NOT NULL,
    [DeE_Kwota]             DECIMAL (15, 2) NOT NULL,
    [DeE_KwotaWal]          DECIMAL (15, 2) NOT NULL,
    [DeE_Waluta]            VARCHAR (3)     NOT NULL,
    [DeE_KursNumer]         INT             NOT NULL,
    [DeE_FPlID]             INT             NULL,
    [DeE_Platnosci]         INT             NOT NULL,
    [DeE_Termin]            DATETIME        NULL,
    [DeE_KursL]             DECIMAL (15, 4) NOT NULL,
    [DeE_KursM]             DECIMAL (5)     NOT NULL,
    [DeE_AccWnId]           INT             NULL,
    [DeE_AccMaId]           INT             NULL,
    [DeE_KontoWn]           VARCHAR (50)    NOT NULL,
    [DeE_KontoMa]           VARCHAR (50)    NOT NULL,
    [DeE_DokumentTyp]       SMALLINT        NULL,
    [DeE_DokumentId]        INT             NULL,
    [DeE_Rozrachunki]       INT             NULL,
    [DeE_TerminRoz]         DATETIME        NULL,
    [DeE_StatusRozrachunku] INT             NULL,
    [DeE_Korekta]           TINYINT         CONSTRAINT [DF_DeE_Korekta] DEFAULT ((0)) NOT NULL,
    [DeE_BZdId]             INT             NULL,
    [DeE_BezRozliczenia]    SMALLINT        NULL,
    CONSTRAINT [DeE_Primary] PRIMARY KEY CLUSTERED ([DeE_DeEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeEKategoria] FOREIGN KEY ([DeE_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_DeENaglowek] FOREIGN KEY ([DeE_DeNId]) REFERENCES [CDN].[DekretyNag] ([DeN_DeNId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [DeENaglowek]
    ON [CDN].[DekretyElem]([DeE_DeNId] ASC, [DeE_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeEPodmiot]
    ON [CDN].[DekretyElem]([DeE_SlownikId] ASC, [DeE_SlownikTyp] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [DeEKategoria]
    ON [CDN].[DekretyElem]([DeE_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeEDokument]
    ON [CDN].[DekretyElem]([DeE_DokumentId] ASC, [DeE_DokumentTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeEBZdId]
    ON [CDN].[DekretyElem]([DeE_BZdId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeE_DETA]
    ON [CDN].[DekretyElem]([DeE_DeEId] ASC, [DeE_Rozrachunki] ASC, [DeE_AccWnId] ASC, [DeE_AccMaId] ASC, [DeE_DeNId] ASC)
    INCLUDE([DeE_Dokument], [DeE_Kategoria], [DeE_Waluta], [DeE_KontoWn], [DeE_KontoMa]) WITH (FILLFACTOR = 100);


GO
CREATE     TRIGGER CDN.DekretyElem_InsertUpdateDelete_Trigger
  ON CDN.DekretyElem
  FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE
   @DeEId         INT,
   @DeNId         INT,
   @AccWnId       INT,
   @AccMaId       INT,
   @DataDok       DATETIME,
   @DataOpe       DATETIME,
   @DataKur       DATETIME,
   @Bufor         SMALLINT,
   @Storno        SMALLINT,
   @Kwota         NUMERIC(15,2),
   @KwotaWal      NUMERIC(15,2),
   @Waluta        NVarchar(3),
   @AccWaluta     NVarchar(3),
   @DataNag       DATETIME,
   @BuforNag      SMALLINT,
   @DziId         INT,
   @KontoWn       NVarchar(50),
   @KontoMa       NVarchar(50),
   @AccKontoWn    NVarchar(50),
   @AccKontoMa    NVarchar(50),
   @Analityka     SMALLINT,
   @AccOObId      INT,
   @DeNOObId      INT,
   @AccSlownik    INT,
   @DataWys       DateTime,
   @Dokument      NVarchar(256),
   @SlownikTyp    SmallInt,
   @SlownikId     Int,
   @PodmiotTyp    SmallInt,
   @PodmiotId     Int,
   @KatId         Int,
   @Kategoria     NVarchar(50),
   @KursNumer     Int,
   @KursL         Decimal(15,4),
   @KursM         Decimal(5,0),
   @FPlId         Int,
   @Platnosci     Int,
   @OpeId         Int,
   @StaId         Int,
   @DDfId         Int,
   @Rozrachunkowe TinyInt,
   @KierunekWn    Int,
   @KierunekMa    Int,
   @KwotaBZd      Decimal(15,2),
   @KwotaWalBZd   Decimal(15,2),
   @Termin        DateTime,
   @Rozrachunki   Int,
   @NrDziennika   Int,
   @Dziennik      NVarchar(50),
   @NrKsiegi   NVarchar(30),
   @IdentKsieg   NVarchar(50),
   @TerminRoz     DATETIME,
   @MyIdentity    Int,
   @UpdateMode   Int,
   @NumerString    NVarchar(30),
   @DokumentNag    NVarchar(256),
   @TypRozliczenia int,
   @DeNKatId  int,
   @DeNKategoria NVarchar(50),
   @DeNDataDok  DateTime,
   @InsertMode  int
-- Zapamiętanie Identity (dodawane są rekordy do innych tabel, a potrzebujemy po insercie na tej tabeli
-- odczytać jakie mamy ID
    set @MyIdentity = NULL
    if exists (select * from Inserted) and not exists (select * from deleted)
    begin
        set @MyIdentity = @@Identity
  set @InsertMode = 1
    end
--
    if exists (SELECT * FROM Inserted) and exists(select * from deleted)
  set @UpdateMode = 1
    IF EXISTS (SELECT * FROM deleted)
 and not exists(select * from Inserted)
 begin
        declare @dokument_kasowany NVarchar(255)
     if exists( select * from
     deleted join CDN.KsiRozrachunki on (deleted.DeE_DeEID = KRo_DeEID)
     where KRo_RozliczenieID is not NULL)
     begin
      select top 1 @dokument_kasowany = deleted.DeE_Dokument from
      deleted join CDN.KsiRozrachunki on (deleted.DeE_DeEID = KRo_DeEID)
      where KRo_RozliczenieID is not NULL
   exec CDN.RiseOptimaException 32585, 's', @dokument_kasowany
      ROLLBACK TRAN
            RETURN
     end
        if exists(
                    select * from
     CDN.KsiRozrachunki L left outer join  CDN.KsiRozrachunki R on (L.KRo_KRoID = R.KRo_RozliczenieID)
                    join deleted on (deleted.DeE_DeEID = L.KRo_DeEID)
                    where
                    --(L.KRo_DeEID = @DeEId)
                    --and
                    exists(
                            select * from CDN.KsiDokElem join CDN.KsiDokNag on (KDE_KDNID = KDN_KDNID)
                            where
       KDN_Bufor <> -1 and KDN_Typ = 113 and (KDE_KRoID = L.KRo_KRoID or KDE_KRoID = L.KRo_RozliczenieID)
                            or
                            KDN_Typ in (111, 112) and (KDE_DeEID = L.KRo_DeEID or KDE_BoEID = L.KRo_BoEID or KDE_DeEID = R.KRo_DeEID or KDE_BoEID = R.KRo_BoEID)
                                )
        )
        begin
      select top 1 @dokument_kasowany = deleted.DeE_Dokument from
      deleted join CDN.KsiDokElem on (deleted.DeE_DeEID = KDE_DeEID)
   exec CDN.RiseOptimaException 32586, 's', @dokument_kasowany
            if @@TranCount<>0 ROLLBACK TRAN
      RETURN
        end
 end
-- Aktualizacja skasowanych
 IF EXISTS (SELECT * FROM deleted)
 BEGIN
  DELETE FROM CDN.DekretyKonta WHERE DeK_DeEId IN (SELECT DeE_DeEId FROM deleted)
  IF NOT EXISTS (SELECT * FROM inserted)
  BEGIN
    Declare @PlatnosciDeleted int
    Declare @RozrachunkiDeleted int
    Declare skasowane Cursor Local Fast_Forward For
    Select DeE_DeEId, DeE_Platnosci, DeE_Rozrachunki From deleted Where DeE_Platnosci = 1 or DeE_Rozrachunki = 1
    Open skasowane
    While 1=1
    Begin
      Fetch Next From skasowane InTo @DeEId, @PlatnosciDeleted, @RozrachunkiDeleted
      If @@Fetch_Status <> 0 Break
      if @PlatnosciDeleted = 1
      begin
              Execute CDN.KasujRozliczenia 27, @DeEId
              Execute CDN.KasujRozliczenia 28, @DeEId
      end
      if @RozrachunkiDeleted = 1
      begin
       Execute CDN.KRo_AktualizujRozrachunek 0, 0, NULL, NULL, NULL, '', '', '', 0, '', '', 0.00, 0.00, NULL, '', '', '', @DeEId, NULL, '', 0, 0
      end
    End
    Close skasowane
    Deallocate skasowane
  END
     If EXISTS (SELECT * FROM inserted join deleted on (inserted.DeE_DeEID = deleted.DeE_DeEID) where inserted.DeE_Rozrachunki = 0 and deleted.DeE_Rozrachunki = 1)
     Begin
            Declare skasowane Cursor Local Fast_Forward For
            Select deleted.DeE_DeEId FROM inserted join deleted on (inserted.DeE_DeEID = deleted.DeE_DeEID) where inserted.DeE_Rozrachunki = 0 and deleted.DeE_Rozrachunki = 1
            Open skasowane
            While 1=1
            Begin
                Fetch Next From skasowane InTo @DeEId
                If @@Fetch_Status <> 0 Break
          Execute CDN.KRo_AktualizujRozrachunek 0, 0, NULL, NULL, NULL, '', '', '', 0, '', '', 0.00, 0.00, NULL, '', '', '', @DeEId, NULL, '', 0, 0
            End
            Close skasowane
            Deallocate skasowane
        End
 END
  IF EXISTS (SELECT * FROM inserted)
  BEGIN
    DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR
      SELECT
          DeE_DeEId,
          DeE_DeNId,
          DeE_AccWnId,
          DeE_AccMaId,
          DeE_KontoWn,
          DeE_KontoMa,
          DeE_Kwota,
          DeE_KwotaWal,
          DeE_Waluta,
          DeN_DataDok,
    DeE_DataOpe,
          DeE_TerminRoz,
          DeE_DataKur,
          DeE_DataWys,
          DeE_Dokument,
          Case When IsNull(DeE_SlownikTyp,0) In (1,2,3,4,5) Then DeE_SlownikTyp Else DeN_PodmiotTyp End,
          Case When IsNull(DeE_SlownikTyp,0) In (1,2,3,4,5) Then DeE_SlownikId  Else DeN_PodmiotId  End,
          DeE_KatId,
          DeE_Kategoria,
          DeE_KursNumer,
          DeE_KursL,
          DeE_KursM,
          DeE_FPlId,
          DeE_Platnosci,
          DeE_Termin,
    DeE_Rozrachunki,
          DeN_Dziennik,
          DeN_NrDziennika,
          DeN_NrKsiegi,
          DeN_IdentKsieg,
          DeN_DziId,
          DeN_Bufor,
          DeN_Storno,
          DeN_OpeModId,
          DeN_StaModId,
    DeN_NumerPelny,
    DeN_Dokument,
    DeN_TypRozliczenia,
    DeN_OObId,
    DeN_KatId,
    DeN_Kategoria,
    DeN_DataDok
       FROM inserted Join CDN.DekretyNag On DeE_DeNId = DeN_DeNId where DeN_Typ=2
    OPEN Dodane
    WHILE 1 = 1
      BEGIN
        FETCH NEXT FROM Dodane INTO
          @DeEId,
          @DeNId,
          @AccWnId,
          @AccMaId,
          @KontoWn,
          @KontoMa,
          @Kwota,
          @KwotaWal,
          @Waluta,
          @DataDok,
    @DataOpe,
          @TerminRoz,
        @DataKur,
          @DataWys,
          @Dokument,
          @SlownikTyp,
          @SlownikId,
          @KatId,
          @Kategoria,
          @KursNumer,
          @KursL,
          @KursM,
          @FPlId,
          @Platnosci,
          @Termin,
    @Rozrachunki,
          @Dziennik,
          @NrDziennika,
          @NrKsiegi,
          @IdentKsieg,
          @DziId,
          @Bufor,
          @Storno,
          @OpeId,
          @StaId,
    @NumerString,
    @DokumentNag,
    @TypRozliczenia,
    @DeNOObId,
    @DeNKatId,
    @DeNKategoria,
    @DeNDataDok
        IF @@FETCH_STATUS <> 0 BREAK
  --SELECT @DeNOObId = DeN_OObId FROM CDN.DekretyNag WHERE DeN_DeNId = @DeNId
  -- nadanie numeru dokumentu dla kompensat i różnic kursowych
  -- tylko dla nowo dodanych, pomijamu edycje
  if @TypRozliczenia is Not Null and @InsertMode = 1
  begin
   Set @KatId = @DeNKatId
   Set @Kategoria = @DeNKategoria
   Set @DataDok = @DeNDataDok
   if Len(@DokumentNag) > 0
    Set @Dokument = @DokumentNag
   update CDN.DekretyElem set DeE_Dokument = @Dokument,
          DeE_KatId = @KatId,
          DeE_Kategoria = @Kategoria,
          DeE_DataWys = @DataDok,
          DeE_DataOpe = @DataDok,
          DeE_DataKur = @DataDok,
          DeE_Termin = @DataDok,
          DeE_TerminRoz = @DataDok
   where DeE_DeEID = @DeEId
  end
  -- Obsluga rozrachunkow
     -- set @Dziennik = @Dziennik+'/'+@NrDziennika
  if @Rozrachunki <> 0 or @UpdateMode = 1
  begin
   if exists(select * from CDN.Konta
      where
       Acc_AccID = @AccWnId
      and Acc_Rozrachunkowe = 1
      and Acc_Analityka = 1
      and Acc_Slownik   = 0)
   begin
    execute CDN.KRo_AktualizujRozrachunek   @DeNOObId,
               @Rozrachunki,
               @DataDok,
               @DataOpe,
               @TerminRoz,
               @Dokument,
               @Dziennik,
               @Dziennik,
               @NrDziennika,
               @NrKsiegi,
               @IdentKsieg,
               @Kwota,
               @KwotaWal,
               @Waluta,
               @KontoWn,
               NULL,
               @KontoMa,
               @DeEId,
               NULL,
               @Kategoria,
               @Bufor,
               @Storno;
   end
   if exists(select * from CDN.Konta
      where
       Acc_AccID = @AccMaId
      and Acc_Rozrachunkowe = 1
      and Acc_Analityka = 1
      and Acc_Slownik = 0)
   begin
    execute CDN.KRo_AktualizujRozrachunek   @DeNOObId,
               @Rozrachunki,
               @DataDok,
               @DataOpe,
               @TerminRoz,
               @Dokument,
               @Dziennik,
               @Dziennik,
               @NrDziennika,
               @NrKsiegi,
               @IdentKsieg,
               @Kwota,
               @KwotaWal,
               @Waluta,
               NULL,
               @KontoMa,
               @KontoWn,
               @DeEId,
               NULL,
               @Kategoria,
               @Bufor,
               @Storno;
   end
  end
        -- end of: Obsluga rozrachunkow
        -- Obsługa płatności
        IF IsNull(@Platnosci, 0) = 0
          Begin
            IF EXISTS (Select * From CDN.BnkZdarzenia Where BZd_DokumentTyp In (27) And BZd_DokumentId = @DeEId)
   begin
    exec cdn.UsunZdarzeniaKBDokumentu 27, @DeEId
    --DELETE From CDN.BnkZdarzenia Where BZd_DokumentTyp In (27, 28) And BZd_DokumentId = @DeEId
   end
            IF EXISTS (Select * From CDN.BnkZdarzenia Where BZd_DokumentTyp In (28) And BZd_DokumentId = @DeEId)
   begin
    exec cdn.UsunZdarzeniaKBDokumentu 28, @DeEId
    --DELETE From CDN.BnkZdarzenia Where BZd_DokumentTyp In (27, 28) And BZd_DokumentId = @DeEId
   end
          End
        SET @KwotaBZd    = ABS(@Kwota)
        SET @KwotaWalBZd = ABS(@KwotaWal)
        IF @Kwota >= 0
          BEGIN
            SET @KierunekWn = 1
            SET @KierunekMa = -1
          END
        ELSE
          BEGIN
            SET @KierunekWn = -1
            SET @KierunekMa = 1
          END
        IF IsNull(@SlownikTyp,0) Not In (1,2,3,4,5)
          BEGIN
            SET @SlownikTyp = 1
            SET @SlownikId  = 1
          END
        -- Sprawdzenie poprawności numeru konta
        IF @AccWnId IS NOT NULL
          BEGIN
            SET @AccKontoWn = NULL
            SELECT @AccKontoWn = Acc_Numer, @Analityka = Acc_Analityka, @AccOObId = Acc_OObId, @AccWaluta = Acc_Waluta, @AccSlownik = Acc_Slownik, @Rozrachunkowe = Acc_Rozrachunkowe, @PodmiotTyp = Case When IsNull(Acc_SlownikTyp,0) In (1,2,3,4,5) Then Acc_SlownikTyp Else @SlownikTyp End, @PodmiotId = Case When IsNull(Acc_SlownikTyp,0) In (1,2,3,4,5) Then Acc_SlownikId Else @SlownikId End
             FROM CDN.Konta WHERE Acc_AccId = @AccWnId
            IF @AccKontoWn IS NULL
              BEGIN
    exec CDN.RiseOptimaException 32587
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
            IF @Analityka = 0
              BEGIN
    exec CDN.RiseOptimaException 32588, 's', @AccKontoWn
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
            IF NOT (@AccOObId = @DeNOObId)
              BEGIN
    exec CDN.RiseOptimaException 32589, 's', @AccKontoWn
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
            IF NOT (@AccWaluta = @Waluta)
              BEGIN
    exec CDN.RiseOptimaException 32590, 's', @AccKontoWn
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
            IF NOT (@AccSlownik = 0)
              BEGIN
    exec CDN.RiseOptimaException 32591, 's', @AccKontoWn
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
           -- Obsługa płatności
           IF @Platnosci = 1
             BEGIN
               IF @Rozrachunkowe = 1
                 BEGIN
                    if not exists (select * from deleted where deleted.DeE_DeEID = @DeEId)
                    or exists(select * from
                    deleted join inserted on (deleted.DeE_DeEID = inserted.DeE_DeEID)
                    where
                    (
                     IsNull(inserted.DeE_SlownikTyp,0) <> IsNull(deleted.DeE_SlownikTyp,0) or
                     IsNull(inserted.DeE_SlownikId,0)  <> IsNull(deleted.DeE_SlownikId,0) or
      inserted.DeE_DataWys <> deleted.DeE_DataWys  or
                     inserted.DeE_Dokument <> deleted.DeE_Dokument  or
                     inserted.DeE_KatId  <> deleted.DeE_KatId  or
                     inserted.DeE_Kategoria <> deleted.DeE_Kategoria or
                     inserted.DeE_Kwota  <> deleted.DeE_Kwota  or
                     inserted.DeE_KwotaWal <> deleted.DeE_KwotaWal  or
                     inserted.DeE_Waluta  <> deleted.DeE_Waluta  or
                     inserted.DeE_KursNumer <> deleted.DeE_KursNumer or
                     inserted.DeE_FPlID  <> deleted.DeE_FPlID  or
                     inserted.DeE_Platnosci <> deleted.DeE_Platnosci or
                     inserted.DeE_KursL  <> deleted.DeE_KursL  or
                     inserted.DeE_KursM  <> deleted.DeE_KursM  or
                     inserted.DeE_AccWnId <> deleted.DeE_AccWnId  or
                     inserted.DeE_Termin  <> deleted.DeE_Termin )
                    and inserted.DeE_DeEID = @DeEId)
                     BEGIN
                       SELECT @DDfId = Case When IsNumeric(Fir_Wartosc) = 1 Then Cast (Fir_Wartosc As Int) Else Null End From CDN.Firma Where Fir_Numer = 1727
                       IF @DDfId Is Null Or Not Exists (Select * From CDN.DokDefinicje Where DDf_DDfId = @DDfId And DDf_Klasa = 202)
                         SELECT @DDfId = MIN (DDf_DDfId) From CDN.DokDefinicje Where DDf_Klasa = 202
                       execute CDN.DodajBnkZdarzenie
                         @DokumentTyp        = 27,
                         @DokumentID         = @DeEId,
                         @NumerPelny         = @Dokument,
                         @NumerObcy          = @Dokument,
                         @PodmiotTyp         = @PodmiotTyp,
                         @PodmiotID          = @PodmiotId,
                         @DDfID              = @DDfId,
                         @Kierunek           = @KierunekWn,
                         @KatID              = @KatId,
                         @FPlId              = @FPlId,
                         @DataDok            = @DataWys,
                 @DataKur            = @DataKur,
                         @KwotaSys           = @KwotaBZd,
                         @Kwota              = @KwotaWalBZd,
                         @Waluta             = @Waluta,
                         @KursNumer          = @KursNumer,
                         @KursL              = @KursL,
                         @KursM              = @KursM,
                         @Stan               = 1,
                         @Opis               = @Kategoria,
                         @OpeId              = @OpeId,
                         @StaId              = @StaId,
                         @Termin             = @Termin
                     END
                 END
               ELSE
                 BEGIN
                   IF EXISTS (Select * From CDN.BnkZdarzenia Where BZd_DokumentTyp = 27 And BZd_DokumentId = @DeEId)
     exec cdn.UsunZdarzeniaKBDokumentu 27, @DeEId
                     --DELETE From CDN.BnkZdarzenia Where BZd_DokumentTyp = 27 And BZd_DokumentId = @DeEId
                 END
             END
          END
        ELSE
          BEGIN
            SET    @AccKontoWn = ''
            IF EXISTS (Select * From CDN.BnkZdarzenia Where BZd_DokumentTyp = 27 And BZd_DokumentId = @DeEId)
    exec cdn.UsunZdarzeniaKBDokumentu 27, @DeEId
              --DELETE From CDN.BnkZdarzenia Where BZd_DokumentTyp = 27 And BZd_DokumentId = @DeEId
          END
        IF @AccMaId IS NOT NULL
          BEGIN
            SET @AccKontoMa = NULL
            SELECT @AccKontoMa = Acc_Numer, @Analityka = Acc_Analityka, @AccOObId = Acc_OObId, @AccWaluta = Acc_Waluta, @AccSlownik = Acc_Slownik, @Rozrachunkowe = Acc_Rozrachunkowe, @PodmiotTyp = Case When IsNull(Acc_SlownikTyp,0) In (1,2,3,4,5) Then Acc_SlownikTyp Else @SlownikTyp End, @PodmiotId = Case When IsNull(Acc_SlownikTyp,0) In (1,2,3,4,5) Then Acc_SlownikId Else @SlownikId End
              FROM CDN.Konta WHERE Acc_AccId = @AccMaId
            IF @AccKontoMa IS NULL
              BEGIN
    exec CDN.RiseOptimaException 32592
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
            IF @Analityka = 0
              BEGIN
    exec CDN.RiseOptimaException 32593, 's', @AccKontoMa
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
            IF NOT (@AccOObId = @DeNOObId)
              BEGIN
    exec CDN.RiseOptimaException 32594, 's', @AccKontoMa
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
            IF NOT (@AccWaluta = @Waluta)
              BEGIN
    exec CDN.RiseOptimaException 32590, 's', @AccKontoMa
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
            IF NOT (@AccSlownik = 0)
              BEGIN
    exec CDN.RiseOptimaException 32595, 's', @AccKontoMa
                ROLLBACK TRAN
                SET NOCOUNT OFF
                RETURN
              END
           -- Obsługa płatności
           IF @Platnosci = 1
             BEGIN
               IF @Rozrachunkowe = 1
                 BEGIN
                    if not exists (select * from deleted where deleted.DeE_DeEID = @DeEId)
                    or exists(select * from
                    deleted join inserted on deleted.DeE_DeEID = inserted.DeE_DeEID
                    where
                    (
                     IsNull(inserted.DeE_SlownikTyp,0) <> IsNull(deleted.DeE_SlownikTyp,0) or
                     IsNull(inserted.DeE_SlownikId,0)  <> IsNull(deleted.DeE_SlownikId,0) or
      inserted.DeE_DataWys <> deleted.DeE_DataWys  or
                     inserted.DeE_Dokument <> deleted.DeE_Dokument  or
                     inserted.DeE_KatId  <> deleted.DeE_KatId  or
                     inserted.DeE_Kategoria <> deleted.DeE_Kategoria or
                     inserted.DeE_Kwota  <> deleted.DeE_Kwota  or
                     inserted.DeE_KwotaWal <> deleted.DeE_KwotaWal  or
                     inserted.DeE_Waluta  <> deleted.DeE_Waluta  or
                     inserted.DeE_KursNumer <> deleted.DeE_KursNumer or
                     inserted.DeE_FPlID  <> deleted.DeE_FPlID  or
                     inserted.DeE_Platnosci <> deleted.DeE_Platnosci or
                     inserted.DeE_KursL  <> deleted.DeE_KursL  or
                     inserted.DeE_KursM  <> deleted.DeE_KursM  or
                     inserted.DeE_AccMaId <> deleted.DeE_AccMaId  or
                     inserted.DeE_Termin  <> deleted.DeE_Termin )
                    and inserted.DeE_DeEID = @DeEId)
                     BEGIN
                       SELECT @DDfId = Case When IsNumeric(Fir_Wartosc) = 1 Then Cast (Fir_Wartosc As Int) Else Null End From CDN.Firma Where Fir_Numer = 1730
                       IF @DDfId Is Null Or Not Exists (Select * From CDN.DokDefinicje Where DDf_DDfId = @DDfId And DDf_Klasa = 201)
                         SELECT @DDfId = MIN (DDf_DDfId) From CDN.DokDefinicje Where DDf_Klasa = 201
                       execute CDN.DodajBnkZdarzenie
                         @DokumentTyp        = 28,
                         @DokumentID         = @DeEId,
                         @NumerPelny         = @Dokument,
                         @NumerObcy          = @Dokument,
                         @PodmiotTyp         = @PodmiotTyp,
                         @PodmiotID          = @PodmiotId,
                         @DDfID              = @DDfId,
                         @Kierunek           = @KierunekMa,
                         @KatID              = @KatId,
                         @FPlId              = @FPlId,
                         @DataDok            = @DataWys,
       @DataKur            = @DataKur,
                         @KwotaSys           = @KwotaBZd,
                         @Kwota              = @KwotaWalBZd,
                         @Waluta             = @Waluta,
                         @KursNumer          = @KursNumer,
                         @KursL              = @KursL,
                         @KursM              = @KursM,
                         @Stan               = 1,
                         @Opis               = @Kategoria,
                         @OpeId              = @OpeId,
                         @StaId              = @StaId,
                         @Termin             = @Termin
                     END
                 END
               ELSE
    BEGIN
                   IF EXISTS (Select * From CDN.BnkZdarzenia Where BZd_DokumentTyp = 28 And BZd_DokumentId = @DeEId)
     exec cdn.UsunZdarzeniaKBDokumentu 28, @DeEId
                     --DELETE From CDN.BnkZdarzenia Where BZd_DokumentTyp = 28 And BZd_DokumentId = @DeEId
                 END
             END
          END
        ELSE
          BEGIN
            SET    @AccKontoMa = ''
            IF EXISTS (Select * From CDN.BnkZdarzenia Where BZd_DokumentTyp = 28 And BZd_DokumentId = @DeEId)
    exec cdn.UsunZdarzeniaKBDokumentu 28, @DeEId
    --DELETE From CDN.BnkZdarzenia Where BZd_DokumentTyp = 28 And BZd_DokumentId = @DeEId
          END
        -- Aktualizacja błędnie wypełnionego numeru konta
        IF @KontoWn <> @AccKontoWn OR @KontoMa <> @AccKontoMa
          UPDATE CDN.DekretyElem SET DeE_KontoWn = @AccKontoWn, DeE_KontoMa = @AccKontoMa WHERE DeE_DeEId = @DeEId
        -- Dodawanie DekretyKonta
        IF @AccWnId IS NOT NULL
        INSERT INTO CDN.DekretyKonta (DeK_DeEId, DeK_DeNId, DeK_DziId, DeK_AccId, DeK_Strona, DeK_DataDok, DeK_Kwota, DeK_KwotaWal, DeK_Waluta, DeK_Bufor)
                              VALUES (@DeEId,    @DeNId,    @DziId,     @AccWnId, 1,          @DataDok,    @Kwota,    @KwotaWal,    @Waluta,    @Bufor)
        IF @AccMaId IS NOT NULL
        INSERT INTO CDN.DekretyKonta (DeK_DeEId, DeK_DeNId, DeK_DziId, DeK_AccId, DeK_Strona, DeK_DataDok, DeK_Kwota, DeK_KwotaWal, DeK_Waluta, DeK_Bufor)
                              VALUES (@DeEId,    @DeNId,    @DziId,     @AccMaId, 2,          @DataDok,    @Kwota,    @KwotaWal,    @Waluta,    @Bufor)
      END
    CLOSE Dodane
    DEALLOCATE Dodane
  END
    -- Odtworzenie Identity
    if @MyIdentity is not NULL
    begin
        exec CDN.UstawIdentity @NewIdentity=@MyIdentity
    end
SET NOCOUNT OFF

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[DekretyElem_InsertUpdateDelete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
CREATE TRIGGER CDN.DekretyElem_InsertUpdateHandler
  ON CDN.DekretyElem
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.DeE_SlownikTyp IN (1,2,3,4,5))
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.PodmiotyView ON
                    inserted.DeE_SlownikId = CDN.PodmiotyView.Pod_PodId
                AND inserted.DeE_SlownikTyp = CDN.PodmiotyView.Pod_PodmiotTyp
              WHERE CDN.PodmiotyView.Pod_PodmiotTyp IS NULL AND (inserted.DeE_SlownikTyp IN (1,2,3,4,5))
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=PodmiotyView##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.DeE_DokumentTyp =8)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.Wyplaty ON
                    inserted.DeE_DokumentId = CDN.Wyplaty.WPL_WplId
              WHERE CDN.Wyplaty.WPL_WplId IS NULL AND (inserted.DeE_DokumentTyp =8)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=Wyplaty##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.DeE_DokumentTyp =14)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkZapisy ON
                    inserted.DeE_DokumentId = CDN.BnkZapisy.BZp_BZpId
              WHERE CDN.BnkZapisy.BZp_BZpId IS NULL AND (inserted.DeE_DokumentTyp =14)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkZapisy##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.DekretyElem_DeleteHandler
  ON CDN.DekretyElem
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.BnkZdarzenia INNER JOIN deleted
   ON deleted.DeE_DeEId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp In (27,28))
  )
  DELETE CDN.BnkZdarzenia
  FROM CDN.BnkZdarzenia, deleted
  WHERE deleted.DeE_DeEId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp In (27,28))
SET NOCOUNT OFF
