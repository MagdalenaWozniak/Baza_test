CREATE TABLE [CDN].[BOElem] (
    [BOE_BOEId]          INT             IDENTITY (1, 1) NOT NULL,
    [BOE_BONId]          INT             NOT NULL,
    [BOE_AccId]          INT             NOT NULL,
    [BOE_AccPrevId]      INT             NULL,
    [BOE_KwotaWn]        DECIMAL (15, 2) NOT NULL,
    [BOE_KwotaMa]        DECIMAL (15, 2) NOT NULL,
    [BOE_KwotaWnWal]     DECIMAL (15, 2) NOT NULL,
    [BOE_KwotaMaWal]     DECIMAL (15, 2) NOT NULL,
    [BOE_Waluta]         VARCHAR (3)     NOT NULL,
    [BOE_KursNumer]      INT             NOT NULL,
    [BOE_KursL]          DECIMAL (15, 4) NOT NULL,
    [BOE_KursM]          DECIMAL (5)     NOT NULL,
    [BOE_DokumentTyp]    SMALLINT        NULL,
    [BOE_DokumentId]     INT             NULL,
    [BOE_Platnosci]      INT             NOT NULL,
    [BOE_FPlID]          INT             NULL,
    [BOE_Termin]         DATETIME        NULL,
    [BOE_DataDok]        DATETIME        NULL,
    [BOE_DataKur]        DATETIME        NOT NULL,
    [BOE_Dokument]       VARCHAR (256)   NOT NULL,
    [BOE_Rozrachunki]    INT             NULL,
    [BOE_TerminRoz]      DATETIME        NULL,
    [BoE_BezRozliczenia] SMALLINT        NULL,
    CONSTRAINT [BOE_Primary] PRIMARY KEY CLUSTERED ([BOE_BOEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BOEKonto] FOREIGN KEY ([BOE_AccId]) REFERENCES [CDN].[Konta] ([Acc_AccId]),
    CONSTRAINT [FK_BOENaglowek] FOREIGN KEY ([BOE_BONId]) REFERENCES [CDN].[BONag] ([BON_BONId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BOENaglowek]
    ON [CDN].[BOElem]([BOE_BONId] ASC, [BOE_BOEId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BOEKonto]
    ON [CDN].[BOElem]([BOE_AccId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BOEKontoPrev]
    ON [CDN].[BOElem]([BOE_AccPrevId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BOEDokument]
    ON [CDN].[BOElem]([BOE_DokumentId] ASC, [BOE_DokumentTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BOElem_InsertUpdateDelete_Trigger
  ON CDN.BOElem
  FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE @BOEId      INT
DECLARE @BONId      INT
DECLARE @AccId      INT
DECLARE @AccPrevId  INT
DECLARE @KwotaWn    NUMERIC(15,2)
DECLARE @KwotaMa    NUMERIC(15,2)
DECLARE @KwotaWnWal NUMERIC(15,2)
DECLARE @KwotaMaWal NUMERIC(15,2)
DECLARE @Korekta    SMALLINT
DECLARE @Bufor      SMALLINT
DECLARE @Waluta     NVarchar(3)
DECLARE @WalAcc     NVarchar(3)
DECLARE @WalAccPrev NVarchar(3)
DECLARE @Platnosci   INT
DECLARE @PodmiotTyp   SMALLINT
DECLARE @PodmiotId    INT
DECLARE @DDfId        INT
DECLARE @Kierunek    INT
DECLARE @KatId        INT
DECLARE @FPlId      INT
DECLARE @DataDok   DATETIME
DECLARE @DataOpe   DATETIME
DECLARE @DataKur   DATETIME
DECLARE @Rozrachunkowe      TINYINT
DECLARE @KwotaSys   NUMERIC(15,2)
DECLARE @Kwota    NUMERIC(15,2)
DECLARE @KursNumer          INT
DECLARE @KursL              DECIMAL(15,4)
DECLARE @KursM              DECIMAL(5,0)
DECLARE @Kategoria          NVarchar(50)
DECLARE @OpeId              INT
DECLARE @StaId              INT
DECLARE @Termin             DATETIME
DECLARE @DokumentNumer     NVarchar(256)
DECLARE @BOEDokument     NVarchar(256)
DECLARE @KontoNumer    NVarchar(50)
DECLARE @OObId    Int
DECLARE @Rozrachunki        Int
DECLARE @TerminRoz   DATETIME
IF EXISTS (SELECT * FROM deleted)
and not exists(select * from Inserted)
begin
    declare @dokument_kasowany NVarchar(255)
 if exists( select * from
    deleted join CDN.KsiRozrachunki on (deleted.BOE_BOEID = KRo_BOEID)
    where KRo_RozliczenieID is not NULL)
 begin
  select top 1 @dokument_kasowany = deleted.BOE_Dokument from
  deleted join CDN.KsiRozrachunki on (deleted.BOE_BOEID = KRo_BOEID)
  where KRo_RozliczenieID is not NULL
  exec CDN.RiseOptimaException 32578, 's', @dokument_kasowany
  ROLLBACK TRAN
        RETURN
 end
    if exists(
                select * from
    CDN.KsiRozrachunki L left outer join  CDN.KsiRozrachunki R on (L.KRo_KRoID = R.KRo_RozliczenieID)
                join deleted on (deleted.BOE_BOEID = L.KRo_BOEID)
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
  select top 1 @dokument_kasowany = deleted.BOE_Dokument from
  deleted join CDN.KsiDokElem on (deleted.BOE_BOEID = KDE_BOEID)
  exec CDN.RiseOptimaException 32579, 's', @dokument_kasowany
        if @@TranCount<>0 ROLLBACK TRAN
  RETURN
    end
end
IF EXISTS (SELECT * FROM deleted)
BEGIN
  DECLARE Skasowane CURSOR LOCAL FAST_FORWARD
    FOR SELECT BOE_BOEId, BOE_BONId, BOE_AccId, BOE_AccPrevId, BOE_KwotaWn, BOE_KwotaMa, BOE_KwotaWnWal, BOE_KwotaMaWal, BOE_Platnosci, BOE_Rozrachunki
  FROM deleted
  OPEN Skasowane
  WHILE 1 = 1
  BEGIN
    FETCH NEXT FROM Skasowane INTO @BOEId, @BONId, @AccId, @AccPrevId, @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal, @Platnosci, @Rozrachunki
    IF @@FETCH_STATUS <> 0 BREAK
    SELECT @OObId = BON_OObId, @Bufor = BON_Bufor, @Korekta = BON_BilansZamkniecia FROM CDN.BONag WHERE BON_BONId = @BONId
    -- Aktualizacja obrotów w bieżącym okresie
    UPDATE CDN.Obroty
      SET
        Obr_ObrotyWnBufor    = Obr_ObrotyWnBufor    - @KwotaWn,
        Obr_ObrotyMaBufor    = Obr_ObrotyMaBufor    - @KwotaMa,
        Obr_ObrotyWn         = Obr_ObrotyWn         - (CASE WHEN @Bufor = 0 THEN @KwotaWn ELSE 0 END),
        Obr_ObrotyMa         = Obr_ObrotyMa         - (CASE WHEN @Bufor = 0 THEN @KwotaMa ELSE 0 END),
        Obr_ObrotyWnBuforWal = Obr_ObrotyWnBuforWal - @KwotaWnWal,
        Obr_ObrotyMaBuforWal = Obr_ObrotyMaBuforWal - @KwotaMaWal,
        Obr_ObrotyWnWal      = Obr_ObrotyWnWal      - (CASE WHEN @Bufor = 0 THEN @KwotaWnWal ELSE 0 END),
        Obr_ObrotyMaWal      = Obr_ObrotyMaWal      - (CASE WHEN @Bufor = 0 THEN @KwotaMaWal ELSE 0 END)
      WHERE Obr_RokMies IS NULL AND Obr_Typ = 1 AND Obr_AccId = @AccId
    -- Aktualizacja obrotów w poprzednim okresie
    IF @Korekta = 1 AND @AccPrevId IS NOT NULL
      UPDATE CDN.Obroty
        SET
          Obr_ObrotyWnBufor    = Obr_ObrotyWnBufor    - @KwotaWn,
          Obr_ObrotyMaBufor    = Obr_ObrotyMaBufor    - @KwotaMa,
          Obr_ObrotyWn         = Obr_ObrotyWn         - (CASE WHEN @Bufor = 0 THEN @KwotaWn ELSE 0 END),
          Obr_ObrotyMa         = Obr_ObrotyMa         - (CASE WHEN @Bufor = 0 THEN @KwotaMa ELSE 0 END),
          Obr_ObrotyWnBuforWal = Obr_ObrotyWnBuforWal - @KwotaWnWal,
          Obr_ObrotyMaBuforWal = Obr_ObrotyMaBuforWal - @KwotaMaWal,
          Obr_ObrotyWnWal      = Obr_ObrotyWnWal      - (CASE WHEN @Bufor = 0 THEN @KwotaWnWal ELSE 0 END),
          Obr_ObrotyMaWal      = Obr_ObrotyMaWal      - (CASE WHEN @Bufor = 0 THEN @KwotaMaWal ELSE 0 END)
        WHERE Obr_RokMies IS NULL AND Obr_Typ = 2 AND Obr_AccId = @AccPrevId
    IF NOT EXISTS (SELECT * FROM inserted)
      Begin
  -- obsługa kasowania rozrachunków, podczas usuwania BO
    if @Rozrachunki = 1
    begin
     Execute CDN.KRo_AktualizujRozrachunek 0, 0, NULL, NULL, NULL, '', '', '', 0, '', '', 0.00, 0.00, NULL,'', '', '',  NULL, @BOEId, '', 0, 0
    end
 -- obsługa kasowania rozliczeń
    if @Platnosci = 1
    begin
     Execute CDN.KasujRozliczenia 39, @BOEId
     Execute CDN.KasujRozliczenia 40, @BOEId
    end
      End
  END
  CLOSE Skasowane
  DEALLOCATE Skasowane
END
-- obsługa kasowania rozrachunków, podczas edycji BO
If EXISTS (SELECT * FROM inserted join deleted on (inserted.BoE_BoEID = deleted.BoE_BoEID) where inserted.BoE_Rozrachunki = 0 and deleted.BoE_Rozrachunki = 1)
Begin
    Declare skasowane Cursor Local Fast_Forward For
    Select deleted.BoE_BoEID FROM inserted join deleted on (inserted.BoE_BoEID = deleted.BoE_BoEID) where inserted.BoE_Rozrachunki = 0 and deleted.BoE_Rozrachunki = 1
    Open skasowane
    While 1=1
    Begin
        Fetch Next From skasowane InTo @BoEId
        If @@Fetch_Status <> 0 Break
  Execute CDN.KRo_AktualizujRozrachunek 0, 0, NULL, NULL, NULL, '', '', '', 0, '', '', 0.00, 0.00, NULL, '', '', '', NULL, @BoEId, '', 0, 0
    End
    Close skasowane
    Deallocate skasowane
End
IF EXISTS (SELECT * FROM inserted)
BEGIN
  DECLARE Dodane CURSOR LOCAL FAST_FORWARD
 FOR  SELECT  BOE_BOEId,
        BOE_BONId,
        BOE_AccId,
        BOE_AccPrevId,
        BOE_KwotaWn,
        BOE_KwotaMa,
        BOE_KwotaWnWal,
        BOE_KwotaMaWal,
        BOE_Waluta,
        BOE_KursNumer,
        BOE_KursL,
        BOE_KursM,
        BOE_Platnosci,
        BOE_FPlID,
        BOE_Termin,
        BOE_DataDok,
        BOE_DataDok,
        BOE_DataKur,
        BOE_Dokument,
        BOE_Rozrachunki,
                                BOE_TerminRoz
    FROM inserted
  OPEN Dodane
  WHILE 1 = 1
  BEGIN
  FETCH NEXT FROM Dodane INTO @BOEId,
         @BONId,
         @AccId,
         @AccPrevId,
         @KwotaWn,
         @KwotaMa,
         @KwotaWnWal,
         @KwotaMaWal,
         @Waluta,
         @KursNumer,
         @KursL,
         @KursM,
         @Platnosci,
         @FPlID,
         @Termin,
         @DataDok,
         @DataOpe,
         @DataKur,
         @BOEDokument,
         @Rozrachunki,
                                    @TerminRoz
    IF @@FETCH_STATUS <> 0 BREAK
    -- SPrawdzenie, czy nie wprowadzamy BO na konta syntetyczne
    IF   EXISTS (SELECT * FROM CDN.Konta WHERE Acc_AccId = @AccId     AND Acc_Analityka = 0)
      OR EXISTS (SELECT * FROM CDN.Konta WHERE Acc_AccId = @AccPrevId AND Acc_Analityka = 0)
      BEGIN
  exec CDN.RiseOptimaException 32580
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
      END
   -- Sprawdzenie zgodnosci waluty konta i dokumentu
 IF   UPDATE (BOE_AccId)
      OR UPDATE (BOE_AccPrevId)
      OR UPDATE (BoE_KwotaWnWal)
      OR UPDATE (BoE_KwotaMaWal)
      OR UPDATE (BoE_KwotaWn)
      OR UPDATE (BoE_KwotaMa)
      OR UPDATE (BoE_Waluta)
      OR UPDATE (BoE_KursNumer)
      OR UPDATE (BoE_KursL)
      OR UPDATE (BoE_KursM)
      OR UPDATE (BoE_Platnosci)
      OR UPDATE (BOE_FPlID)
      OR UPDATE (BoE_Termin)
      OR UPDATE (BOE_DataDok)
   OR UPDATE (BOE_DataKur)
      OR UPDATE (BOE_Dokument)
      OR UPDATE (BOE_Rozrachunki)
   OR UPDATE (BOE_BezRozliczenia)
      OR UPDATE (BOE_TerminRoz)
  Begin
   Select @WalAcc     = Acc_Waluta,
       @Rozrachunkowe  = Acc_Rozrachunkowe,
        @PodmiotTyp  = Case When IsNull(Acc_SlownikTyp,0) In (1,2,3,4,5) Then Acc_SlownikTyp Else 1 End,
       @PodmiotId   = Case When IsNull(Acc_SlownikTyp,0) In (1,2,3,4,5) Then Acc_SlownikId Else 1 End,
       @KontoNumer  = Acc_Numer
   From CDN.Konta Where Acc_AccId = @AccId
   If @AccPrevId Is Not Null
    Select @WalAccPrev = Acc_Waluta From CDN.Konta Where Acc_AccId = @AccPrevId
   Else
    Set @WalAccPrev = ''
   If @WalAcc <> @Waluta
   BEGIN
    exec CDN.RiseOptimaException 32582
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
   END
   If @WalAcc <> '' And @WalAccPrev <> '' And @WalAcc <> @WalAccPrev
   BEGIN
    exec CDN.RiseOptimaException 32581
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
   END
  End
    -- Pobranie danych z nagłówka
  SELECT  @OObId    = BON_OObId,
    @Bufor     = BON_Bufor,
    @Korekta    = BON_BilansZamkniecia,
    @KatId    = BON_KatId,
    @Kategoria      = BON_Kategoria,
    @OpeId    = BON_OpeModID,
    @StaId    = BON_StaModId,
    @DokumentNumer      = BON_NumerPelny
  FROM CDN.BONag WHERE BON_BONId = @BONId
    -- Aktualizacja obrotów w bieżącym okresie
  IF NOT EXISTS (SELECT * FROM CDN.Obroty WHERE Obr_RokMies IS NULL AND Obr_Typ = 1 AND Obr_AccId = @AccId)
      INSERT INTO CDN.Obroty (Obr_AccId, Obr_RokMies, Obr_Typ, Obr_ObrotyWn, Obr_ObrotyMa, Obr_ObrotyWnBufor, Obr_ObrotyMaBufor, Obr_ObrotyWnWal, Obr_ObrotyMaWal, Obr_ObrotyWnBuforWal, Obr_ObrotyMaBuforWal)
                      VALUES (@AccId,    Null,        1,       0,            0,            0,                 0,                 0,               0,               0,                    0)
  UPDATE CDN.Obroty
  SET
        Obr_ObrotyWnBufor    = Obr_ObrotyWnBufor    + @KwotaWn,
        Obr_ObrotyMaBufor    = Obr_ObrotyMaBufor    + @KwotaMa,
        Obr_ObrotyWn         = Obr_ObrotyWn         + (CASE WHEN @Bufor = 0 THEN @KwotaWn ELSE 0 END),
        Obr_ObrotyMa         = Obr_ObrotyMa         + (CASE WHEN @Bufor = 0 THEN @KwotaMa ELSE 0 END),
        Obr_ObrotyWnBuforWal = Obr_ObrotyWnBuforWal + @KwotaWnWal,
        Obr_ObrotyMaBuforWal = Obr_ObrotyMaBuforWal + @KwotaMaWal,
        Obr_ObrotyWnWal      = Obr_ObrotyWnWal      + (CASE WHEN @Bufor = 0 THEN @KwotaWnWal ELSE 0 END),
        Obr_ObrotyMaWal      = Obr_ObrotyMaWal      + (CASE WHEN @Bufor = 0 THEN @KwotaMaWal ELSE 0 END)
  WHERE Obr_RokMies IS NULL AND Obr_Typ = 1 AND Obr_AccId = @AccId
    -- Aktualizacja obrotów w poprzednim okresie
  IF @Korekta = 1 AND @AccPrevId IS NOT NULL
  BEGIN
   IF NOT EXISTS (SELECT * FROM CDN.Obroty WHERE Obr_RokMies IS NULL AND Obr_Typ = 2 AND Obr_AccId = @AccPrevId)
    INSERT INTO CDN.Obroty (Obr_AccId,  Obr_RokMies, Obr_Typ, Obr_ObrotyWn, Obr_ObrotyMa, Obr_ObrotyWnBufor, Obr_ObrotyMaBufor, Obr_ObrotyWnWal, Obr_ObrotyMaWal, Obr_ObrotyWnBuforWal, Obr_ObrotyMaBuforWal)
                        VALUES (@AccPrevId, Null,        2,       0,            0,            0,                 0,                 0,               0,               0,                    0)
   UPDATE CDN.Obroty
   SET
   Obr_ObrotyWnBufor    = Obr_ObrotyWnBufor    + @KwotaWn,
   Obr_ObrotyMaBufor    = Obr_ObrotyMaBufor    + @KwotaMa,
   Obr_ObrotyWn         = Obr_ObrotyWn         + (CASE WHEN @Bufor = 0 THEN @KwotaWn ELSE 0 END),
   Obr_ObrotyMa         = Obr_ObrotyMa         + (CASE WHEN @Bufor = 0 THEN @KwotaMa ELSE 0 END),
   Obr_ObrotyWnBuforWal = Obr_ObrotyWnBuforWal + @KwotaWnWal,
   Obr_ObrotyMaBuforWal = Obr_ObrotyMaBuforWal + @KwotaMaWal,
   Obr_ObrotyWnWal      = Obr_ObrotyWnWal      + (CASE WHEN @Bufor = 0 THEN @KwotaWnWal ELSE 0 END),
   Obr_ObrotyMaWal      = Obr_ObrotyMaWal      + (CASE WHEN @Bufor = 0 THEN @KwotaMaWal ELSE 0 END)
   WHERE Obr_RokMies IS NULL AND Obr_Typ = 2 AND Obr_AccId = @AccPrevId
  END
    -- obsługa rozrachunków
  DECLARE @KontoNumerIdx  NVarchar(50)
        DECLARE @NumerDokumentu NVarchar(256)
        if len(@BOEDokument) = 0
        begin
            set @NumerDokumentu = @DokumentNumer
        end
        else
        begin
            set @NumerDokumentu = @BOEDokument
        end
  select @KontoNumerIdx = Acc_NumerIdx from CDN.Konta where Acc_AccID = @AccId
  IF @KwotaWn <> 0
  BEGIN
   execute CDN.KRo_AktualizujRozrachunek   @OObId,
              @Rozrachunki,
                                                        @DataDok,
              @DataOpe,
                                                        @TerminRoz,
                                                        @NumerDokumentu,
                                                        @DokumentNumer, -- @NrDziennika
              @DokumentNumer, -- @Dziennik
              0,    -- @NrDziennika
                                                        @DokumentNumer, -- @NrKsiegi
                                                        @DokumentNumer, -- @IDKsiegowy
              @KwotaWn,
              @KwotaWnWal,
                                                        @Waluta,
              @KontoNumerIdx,
                                                        NULL,           -- kontoMA
              NULL,           -- konto przeciwstawne
              NULL,           -- DENID
              @BOEId,
              @Kategoria,
                                                        @Bufor,
                                                        0;              -- storno
  END
  IF @KwotaMa <> 0
  BEGIN
   execute CDN.KRo_AktualizujRozrachunek   @OObId,
              @Rozrachunki,
                                                        @DataDok,
              @DataOpe,
                                                        @TerminRoz,
                                                        @NumerDokumentu,
                                                        @DokumentNumer, -- @NrDziennika
              @DokumentNumer, -- @Dziennik
              0,    -- @NrDziennika
                                                        @DokumentNumer, -- @NrKsiegi
                                                        @DokumentNumer, -- @IDKsiegowy
              @KwotaMa,
              @KwotaMaWal,
                                                        @Waluta,
              NULL,           -- kontoWn
              @KontoNumerIdx, -- KontoMa
                                                        NULL,           -- Konto przeciwstawne
              NULL,           -- DENID
              @BOEId,
              @Kategoria,
                                                        @Bufor,
                                                        0;              -- storno
  END
  -- Obsługa płatności
  IF @Platnosci = 1 AND @Rozrachunkowe = 1
   BEGIN
    IF     UPDATE (BOE_AccId)
     OR UPDATE (BOE_AccPrevId)
     OR UPDATE (BoE_KwotaWnWal)
     OR UPDATE (BoE_KwotaMaWal)
     OR UPDATE (BoE_KwotaWn)
     OR UPDATE (BoE_KwotaMa)
     OR UPDATE (BoE_Waluta)
     OR UPDATE (BoE_KursNumer)
     OR UPDATE (BoE_KursL)
     OR UPDATE (BoE_KursM)
     OR UPDATE (BoE_Platnosci)
     OR UPDATE (BOE_FPlID)
     OR UPDATE (BoE_Termin)
     OR UPDATE (BOE_DataDok)
     OR UPDATE (BOE_DataKur)
     OR UPDATE (BOE_Dokument)
       BEGIN
     -- Płatnosci WN
     SELECT @DDfId = Case When IsNumeric(Fir_Wartosc) = 1 Then Cast (Fir_Wartosc As Int) Else Null End From CDN.Firma Where Fir_Numer = 1727
     IF @DDfId Is Null Or Not Exists (Select * From CDN.DokDefinicje Where DDf_DDfId = @DDfId And DDf_Klasa = 202)
      SELECT @DDfId = MIN (DDf_DDfId) From CDN.DokDefinicje Where DDf_Klasa = 202
     SET @KwotaSys = ABS(@KwotaWn)
     SET @Kwota  = ABS(@KwotaWnWal)
     IF @KwotaWn >=0
      SET @Kierunek = 1
     ELSE
      SET @Kierunek = -1
     execute CDN.DodajBnkZdarzenie
      @DokumentTyp        = 39,
                  @DokumentID         = @BoEId,
                  @NumerPelny         = @DokumentNumer,
                  @NumerObcy          = @BOEDokument,
                  @PodmiotTyp         = @PodmiotTyp,
                  @PodmiotID          = @PodmiotId,
                  @DDfID              = @DDfId,
                  @Kierunek           = @Kierunek,
                  @KatID              = @KatId,
                  @FPlId              = @FPlId,
                  @DataDok            = @DataDok,
      @DataKur            = @DataKur,
                  @KwotaSys           = @KwotaSys,
                  @Kwota              = @Kwota,
                  @Waluta             = @Waluta,
                  @KursNumer          = @KursNumer,
                  @KursL              = @KursL,
                  @KursM              = @KursM,
                  @Stan               = 1,
                  @Opis               = @Kategoria,
                  @OpeId              = @OpeId,
                  @StaId              = @StaId,
                  @Termin             = @Termin,
      @KontoPrzeciwstawne = @KontoNumer
      -- Płatnosci MA
      SELECT @DDfId = Case When IsNumeric(Fir_Wartosc) = 1 Then Cast (Fir_Wartosc As Int) Else Null End From CDN.Firma Where Fir_Numer = 1730
      IF @DDfId Is Null Or Not Exists (Select * From CDN.DokDefinicje Where DDf_DDfId = @DDfId And DDf_Klasa = 201)
               SELECT @DDfId = MIN (DDf_DDfId) From CDN.DokDefinicje Where DDf_Klasa = 201
      SET @KwotaSys = ABS(@KwotaMa)
      SET @Kwota  = ABS(@KwotaMaWal)
      IF @KwotaMa >= 0
       SET @Kierunek = -1
      ELSE
       SET @Kierunek = 1
      execute CDN.DodajBnkZdarzenie
          @DokumentTyp        = 40,
                      @DokumentID         = @BoEId,
                      @NumerPelny         = @DokumentNumer,
                      @NumerObcy          = @BOEDokument,
                      @PodmiotTyp         = @PodmiotTyp,
                      @PodmiotID          = @PodmiotId,
                      @DDfID              = @DDfId,
                      @Kierunek           = @Kierunek,
                      @KatID              = @KatId,
                      @FPlId              = @FPlId,
                      @DataDok            = @DataDok,
          @DataKur            = @DataKur,
                      @KwotaSys           = @KwotaSys,
                      @Kwota              = @Kwota,
                      @Waluta             = @Waluta,
                      @KursNumer          = @KursNumer,
                      @KursL              = @KursL,
                      @KursM              = @KursM,
                      @Stan               = 1,
                      @Opis               = @Kategoria,
                      @OpeId              = @OpeId,
                      @StaId              = @StaId,
                      @Termin             = @Termin,
          @KontoPrzeciwstawne = @KontoNumer
    END
   END
  ELSE
   BEGIN
    Execute CDN.KasujRozliczenia 39, @BOEId
    Execute CDN.KasujRozliczenia 40, @BOEId
    exec cdn.UsunZdarzeniaKBDokumentu 39, @BoEId
    exec cdn.UsunZdarzeniaKBDokumentu 40, @BoEId
    --DELETE From CDN.BnkZdarzenia Where BZd_DokumentTyp = 39 And BZd_DokumentId = @BoEId
    --DELETE From CDN.BnkZdarzenia Where BZd_DokumentTyp = 40 And BZd_DokumentId = @BoEId
   END
  END
  CLOSE Dodane
  DEALLOCATE Dodane
END
SET NOCOUNT OFF

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[BOElem_InsertUpdateDelete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
CREATE TRIGGER CDN.BOElem_InsertUpdateHandler
  ON CDN.BOElem
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BOE_DokumentTyp=2)
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkZapisy ON
                    inserted.BOE_DokumentId = CDN.BnkZapisy.BZp_BZpId
              WHERE CDN.BnkZapisy.BZp_BZpId IS NULL AND (inserted.BOE_DokumentTyp=2)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkZapisy##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.BOE_DokumentTyp=1)
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.BnkZdarzenia ON
                    inserted.BOE_DokumentId = CDN.BnkZdarzenia.BZd_BZdId
              WHERE CDN.BnkZdarzenia.BZd_BZdId IS NULL AND (inserted.BOE_DokumentTyp=1)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=BnkZdarzenia##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.BOElem_DeleteHandler
  ON CDN.BOElem
  FOR DELETE
AS
SET NOCOUNT ON
    IF EXISTS(
   SELECT * FROM CDN.BnkZdarzenia INNER JOIN deleted ON
   deleted.BOE_BOEId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp In (39,40))
  )
  DELETE CDN.BnkZdarzenia
  FROM CDN.BnkZdarzenia, deleted
  WHERE deleted.BOE_BOEId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp In (39,40))
SET NOCOUNT OFF
