CREATE TABLE [CDN].[Konta] (
    [Acc_AccId]           INT           IDENTITY (1, 1) NOT NULL,
    [Acc_KorektaKosztow]  TINYINT       CONSTRAINT [DF_Acc_KorektaKosztow] DEFAULT ((0)) NOT NULL,
    [Acc_KontrolaBudzetu] TINYINT       NOT NULL,
    [Acc_ParId]           INT           NULL,
    [Acc_Numer]           VARCHAR (50)  NOT NULL,
    [Acc_NumerIdx]        VARCHAR (50)  NOT NULL,
    [Acc_Segment]         NVARCHAR (20) NOT NULL,
    [Acc_Nazwa]           NVARCHAR (50) NOT NULL,
    [Acc_Nazwa2]          NVARCHAR (50) NULL,
    [Acc_Waluta]          VARCHAR (3)   NOT NULL,
    [Acc_OObId]           INT           NOT NULL,
    [Acc_TypKonta]        TINYINT       NOT NULL,
    [Acc_Rozrachunkowe]   TINYINT       NOT NULL,
    [Acc_KontrolaSalda]   TINYINT       NOT NULL,
    [Acc_Slownik]         SMALLINT      NOT NULL,
    [Acc_SlownikGrupa]    TINYINT       NOT NULL,
    [Acc_NextAccId]       INT           NULL,
    [Acc_SlownikTyp]      SMALLINT      NULL,
    [Acc_SlownikId]       INT           NULL,
    [Acc_NieAktywne]      TINYINT       NOT NULL,
    [Acc_Poziom]          SMALLINT      NOT NULL,
    [Acc_Analityka]       TINYINT       NOT NULL,
    [Acc_OpeZalID]        INT           NULL,
    [Acc_StaZalId]        INT           NULL,
    [Acc_TS_Zal]          DATETIME      NOT NULL,
    [Acc_OpeModID]        INT           NULL,
    [Acc_StaModId]        INT           NULL,
    [Acc_TS_Mod]          DATETIME      NOT NULL,
    [Acc_BezRozliczenia]  TINYINT       CONSTRAINT [DF_Acc_BezRozliczenia] DEFAULT ((0)) NOT NULL,
    [Acc_OpeModKod]       VARCHAR (20)  CONSTRAINT [DF_Acc_OpeModKod] DEFAULT ('') NOT NULL,
    [Acc_OpeModNazwisko]  NVARCHAR (50) CONSTRAINT [DF_Acc_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Acc_OpeZalKod]       VARCHAR (20)  CONSTRAINT [DF_Acc_OpeZalKod] DEFAULT ('') NOT NULL,
    [Acc_OpeZalNazwisko]  NVARCHAR (50) CONSTRAINT [DF_Acc_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [Acc_PrevAccId]       INT           NULL,
    CONSTRAINT [Acc_Primary] PRIMARY KEY CLUSTERED ([Acc_AccId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccNumer] FOREIGN KEY ([Acc_OObId]) REFERENCES [CDN].[OkresyObrach] ([OOb_OObID]) ON DELETE CASCADE,
    CONSTRAINT [FK_AccParrent] FOREIGN KEY ([Acc_ParId]) REFERENCES [CDN].[Konta] ([Acc_AccId])
);


GO
CREATE NONCLUSTERED INDEX [AccOObId]
    ON [CDN].[Konta]([Acc_OObId] ASC, [Acc_AccId] ASC, [Acc_NieAktywne] ASC)
    INCLUDE([Acc_ParId], [Acc_Numer], [Acc_Nazwa], [Acc_Segment], [Acc_KorektaKosztow], [Acc_Analityka]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [AccBudzet]
    ON [CDN].[Konta]([Acc_KontrolaBudzetu] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AccParrent]
    ON [CDN].[Konta]([Acc_ParId] ASC, [Acc_Segment] ASC, [Acc_AccId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AccNumer]
    ON [CDN].[Konta]([Acc_OObId] ASC, [Acc_NumerIdx] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [AccPodmiot]
    ON [CDN].[Konta]([Acc_SlownikId] ASC, [Acc_SlownikTyp] ASC, [Acc_ParId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AccNazwa]
    ON [CDN].[Konta]([Acc_OObId] ASC, [Acc_Nazwa] ASC, [Acc_AccId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [AccNextOkres]
    ON [CDN].[Konta]([Acc_NextAccId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AccKorektaKosztow]
    ON [CDN].[Konta]([Acc_KorektaKosztow] ASC, [Acc_AccId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AccGridLookupFilter]
    ON [CDN].[Konta]([Acc_Numer] ASC, [Acc_AccId] ASC)
    INCLUDE([Acc_NieAktywne], [Acc_OObId]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Konta_Insert_Trigger
  ON CDN.Konta
  FOR INSERT
AS
SET NOCOUNT ON
 insert into CDN.KontaZakazy
 select Inserted.Acc_AccId, AcZ_OpeId
 from Inserted join cdn.KontaZakazy on (Inserted.Acc_ParId = AcZ_AccId)
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Konta_After_Insert_Trigger
ON CDN.Konta
AFTER INSERT
AS
 SET NOCOUNT ON
 declare @dokumentTyp int = 0;
 select @dokumentTyp = ID from CDN.ListaDokumentowWymiarowanych() where nazwa = 'Konto księgowe';
 declare @accId int;
 declare @ParentId int;
 DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR
 SELECT Acc_AccId, Acc_ParId FROM inserted
 OPEN Dodane
 WHILE 1=1
 begin
  FETCH NEXT FROM Dodane INTO @accId, @ParentId
  IF @@FETCH_STATUS <> 0 BREAK
  if not exists(select * from CDN.WymiaryWartosci where WyW_DokumentTyp = @dokumentTyp and WyW_DokumentId = @accId)
   insert into CDN.WymiaryWartosci (WyW_WyyId, WyW_Guid, WyW_Wartosc, WyW_DokumentTyp, WyW_DokumentId, WyW_Procent, WyW_Kwota, WyW_SlownikId, WyW_LpPozycji)
   SELECT WyW_WyyId, WyW_Guid, WyW_Wartosc, WyW_DokumentTyp, @accId, WyW_Procent, WyW_Kwota, WyW_SlownikId, WyW_LpPozycji
   FROM CDN.WymiaryWartosci
   where WyW_DokumentTyp = @dokumentTyp and WyW_DokumentId = @ParentId
   order by WyW_WyWId;
--   exec CDN.AktualizujOpisAnalitycznyNaKatach @ParentId;
 end
 Close Dodane
 Deallocate Dodane
 SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Konta_InsertUpdateHandler
  ON CDN.Konta
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.Acc_SlownikTyp In (1,2,3,4,5))
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.PodmiotyView ON
                    inserted.Acc_SlownikId = CDN.PodmiotyView.Pod_PodId
                AND inserted.Acc_SlownikTyp = CDN.PodmiotyView.Pod_PodmiotTyp
              WHERE CDN.PodmiotyView.Pod_PodmiotTyp IS NULL AND (inserted.Acc_SlownikTyp In (1,2,3,4,5))
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=PodmiotyView##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Konta_InsertUpdate_Trigger
  ON CDN.Konta
  FOR INSERT, UPDATE
AS
SET NOCOUNT ON
DECLARE @AccId     INT
DECLARE @ParId     INT
DECLARE @SlownikTyp    INT
DECLARE @SlownikId    INT
DECLARE @Segment    NVarchar(20)
DECLARE @Numer     NVarchar(50)
DECLARE @NumerIdx    NVarchar(50)
DECLARE @NumerTmp    NVarchar(50)
DECLARE @NumerIdxTmp   NVarchar(50)
DECLARE @Nazwa                  NVarchar(50)
DECLARE @Poziom     SMALLINT
DECLARE @PoziomTmp    SMALLINT
DECLARE @Analityka    SMALLINT
DECLARE @AnalitykaTmp   SMALLINT
DECLARE @OObId     INT
DECLARE @ParOObId    INT
DECLARE @ParNumer    NVarchar(50)
DECLARE @NextAccId    INT
DECLARE @NieAktywne    INT
DECLARE @Waluta     NVarchar(3)
DECLARE @KontrolaBudzetu     INT
DECLARE @Rozrachunkowe          INT
DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR
 SELECT
  Acc_AccId,
  Acc_ParId,
  Acc_OObId,
  Acc_SlownikTyp,
  Acc_SlownikId,
  Acc_Segment,
  Acc_Numer,
  Acc_NumerIdx,
  Acc_Nazwa,
  Acc_Poziom,
  Acc_Analityka,
  Acc_NextAccId,
  Acc_NieAktywne,
  Acc_Waluta,
  Acc_KontrolaBudzetu,
  Acc_Rozrachunkowe
 FROM inserted
OPEN Dodane
WHILE 1=1
 BEGIN
  FETCH NEXT FROM Dodane INTO
                         @AccId,
                         @ParId,
                         @OObId,
                         @SlownikTyp,
                         @SlownikId,
                         @Segment,
                         @Numer,
                         @NumerIdx,
                         @Nazwa,
                         @Poziom,
                         @Analityka,
                         @NextAccId,
                         @NieAktywne,
                         @Waluta,
             @KontrolaBudzetu,
                         @Rozrachunkowe
  IF @@FETCH_STATUS <> 0 BREAK
  -- Sprawdzenie, czy numer nie zawiera znaków '-', '.', ''''
  IF CHARINDEX(' ', @Segment) <> 0 OR CHARINDEX('-', @Segment) <> 0 OR CHARINDEX('.', @Segment) <> 0 OR CHARINDEX('''', @Segment ) <> 0
    BEGIN
      exec CDN.RiseOptimaException 32619, 's', @Segment
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  -- sprawdzenie, czy ustawiono wartość w kolumnie Acc_Rozrachunkowe oraz czy jednocześnie
  -- edytowane konto nie jest stroną w dekrecie w którym konto przeciwstawne również jest rozrachunkowe.
    if @Rozrachunkowe=1 and exists (SELECT * FROM deleted WHERE Acc_AccId = @AccId and (Acc_Rozrachunkowe = 0 or Acc_Rozrachunkowe is NULL))
        begin
            if exists(select * from deleted
            join CDN.DekretyElem PKWN On (deleted.Acc_AccID = PKWN.DeE_AccWnID)
            join CDN.Konta AccMa On (AccMa.Acc_AccID = PKWN.DeE_AccMaID and AccMa.Acc_Rozrachunkowe=1)
            where deleted.Acc_AccID = @AccId)
                or
              exists(select * from deleted
            join CDN.DekretyElem PKMA On (deleted.Acc_AccID = PKMA.DeE_AccMaID)
            join CDN.Konta AccWn On (AccWn.Acc_AccID = PKMA.DeE_AccWnID and AccWn.Acc_Rozrachunkowe=1)
            where deleted.Acc_AccID = @AccId)
            begin
    exec CDN.RiseOptimaException 32620, 's', @Numer
            end
        end
  -- Sprawdzenie, czy zmieniono numer konta
  IF EXISTS (SELECT * FROM deleted WHERE Acc_AccId = @AccId AND Acc_Segment <> @Segment)
 BEGIN
   -- Sprawdzenie, czy na koncie lub analityce są księgowania
   If Exists ( Select * From CDN.KontaAnalityczne(@AccId, 1) Join CDN.DekretyKonta On Anl_AccId = DeK_AccId )
   Or Exists ( Select * From CDN.KontaAnalityczne(@AccId, 1) Join CDN.BOElem On Anl_AccId = BOE_AccId )
   Or Exists ( Select * From CDN.KontaAnalityczne(@AccId, 1) Join CDN.BOElem On Anl_AccId = BOE_AccPrevId )
     Begin
    exec CDN.RiseOptimaException 32632, 's', @Numer
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
     End
   Else
     Begin
        -- Sprawdzenie, czy konto posiada analitykę
    IF EXISTS (SELECT * FROM CDN.Konta WHERE Acc_ParId = @AccId)
      Update CDN.Konta Set
       Acc_NumerIdx = CDN.NumerKonta (Acc_AccId),
       Acc_Numer    = Replace(CDN.NumerKonta (Acc_AccId), '.', '-')
                      Where Acc_AccId In (Select Anl_AccId From CDN.KontaAnalityczne (@AccId, 1))
                        And Acc_AccId <> @AccId
     End
    END
    -- Sprawdzenie, czy konto i ojciec należą do jednego okresu obrachunkowego
    IF @ParId IS NOT NULL
      BEGIN
        SELECT @ParOObId = Acc_OObId, @ParNumer = Acc_Numer FROM CDN.Konta WHERE Acc_AccId = @ParId
        IF NOT @OObId = @ParOObId
          BEGIN
   exec CDN.RiseOptimaException 32621, 's', @ParNumer
            ROLLBACK TRAN
            SET NOCOUNT OFF
            RETURN
          END
        -- Sprawdzenie, czy na koncie nadrzędnym nie ma księgowań
        IF   EXISTS (SELECT * FROM CDN.DekretyKonta WHERE DeK_AccId     = @ParId)
          OR EXISTS (SELECT * FROM CDN.BOElem       WHERE BOE_AccId     = @ParId)
          OR EXISTS (SELECT * FROM CDN.BOElem       WHERE BOE_AccPrevId = @ParId)
          BEGIN
   exec CDN.RiseOptimaException 32633, 's', @ParNumer
            ROLLBACK TRAN
            SET NOCOUNT OFF
            RETURN
          END
        -- Czy konto nadrzędne nie jest słownikowe a podrzędne niewalutowe
        IF EXISTS (SELECT * FROM CDN.Konta A JOIN CDN.Konta B ON A.Acc_ParId = B.Acc_AccId WHERE A.Acc_AccId = @AccId AND B.Acc_SlownikTyp <> 0 AND A.Acc_Waluta = '')
          BEGIN
   exec CDN.RiseOptimaException 32622, 's', @ParNumer
            ROLLBACK TRAN
            SET NOCOUNT OFF
            RETURN
          END
        -- Sprawdzenie, czy nie istnieją dwie analityki dla jednego poziomu
        IF @SlownikId IS NOT NULL
          IF EXISTS (SELECT * FROM CDN.Konta WHERE Acc_ParId = @ParId AND Acc_SlownikTyp = @SlownikTyp AND Acc_SlownikId = @SlownikId AND Acc_Waluta = @Waluta AND Acc_AccId <> @AccId)
            BEGIN
     exec CDN.RiseOptimaException 32623, 's', @ParNumer
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
            END
      END
  -- Sprawdzenie, czy istneje konto w okresie następnym
  IF @NextAccId IS NOT NULL
    IF NOT EXISTS (SELECT * FROM CDN.Konta WHERE Acc_AccId = @NextAccId)
      BEGIN
  exec CDN.RiseOptimaException 32624
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
      END
  -- Sprawdzenie i aktualizacja Numer, Poziom, Analityka
  SET @NumerIdxTmp = CDN.NumerKonta (@AccId)
  SET @NumerTmp    = REPLACE(@NumerIdxTmp, '.', '-')
  SET @PoziomTmp = CDN.PoziomKonta (@AccId)
  IF EXISTS (SELECT * FROM CDN.Konta WHERE Acc_ParId = @AccId) SET @AnalitykaTmp = 0 ELSE SET @AnalitykaTmp = 1
  IF @NumerIdx <> @NumerIdxTmp OR @Numer <> @NumerTmp OR @Poziom <> @PoziomTmp OR @Analityka <> @AnalitykaTmp
    UPDATE CDN.Konta
    SET Acc_Numer = @NumerTmp, Acc_NumerIdx = @NumerIdxTmp, Acc_Poziom = @PoziomTmp, Acc_Analityka = @AnalitykaTmp
    WHERE Acc_AccId = @AccId
  -- Sprawdzenie i aktualizacja Analityka na koncie nadrzędnym
  IF EXISTS (SELECT * FROM CDN.Konta WHERE Acc_AccId = @ParId AND Acc_Analityka = 1)
    UPDATE CDN.Konta SET Acc_Analityka = 0 WHERE Acc_AccId = @ParId
  -- Sprawdzenie i skasowanie obrotw z konta nadrzdnego
  IF EXISTS (SELECT * FROM CDN.Obroty WHERE Obr_AccId = @ParId)
    Delete From CDN.Obroty Where Obr_AccId = @ParId
  -- Sprawdzenie nieaktywnosci konta
  If (@NieAktywne = 0 or @Nieaktywne = 2)
   Begin
    -- Sprawdzenie, czy nadrzędne nie jest nieaktywne
    If @ParId Is Not Null And Exists (Select * From CDN.Konta Where Acc_AccId = @ParId And Acc_NieAktywne <> 0)
      BEGIN
  exec CDN.RiseOptimaException 32625, 's', @ParNumer
        ROLLBACK TRAN
        SET NOCOUNT OFF
        RETURN
      END
    If (@Nieaktywne = 2) -- Aktualizować podrzędne
      Begin
        -- Aktualizacja bieżącego
        Update CDN.Konta Set Acc_Nieaktywne = 0 Where Acc_AccId = @AccId
        -- Aktualizacja podrzędnych
        Update CDN.Konta Set Acc_NieAktywne = 0 Where Acc_NieAktywne = 1 And Acc_AccId In (Select Anl_AccId From CDN.KontaAnalityczne (@AccId, 1))
      End
   End
  Else
   Begin
    -- Aktualizacja podrzędnych
    Update CDN.Konta Set Acc_NieAktywne = 1 Where Acc_NieAktywne = 0 And Acc_AccId In (Select Anl_AccId From CDN.KontaAnalityczne (@AccId, 1))
   End
 -- Sprawdzenie czy konto nadrzędnenie jest objęte kontrolą budżetu
  If EXISTS(select * from CDN.Konta     where Acc_KontrolaBudzetu<>0 and Acc_AccId = @ParId)
  Or EXISTS(select * from CDN.BudzetNag where BuN_AccId = @ParId)
   Begin
     exec CDN.RiseOptimaException 32625, 's', @ParNumer
     ROLLBACK TRAN
     SET NOCOUNT OFF
     RETURN
   End
  -- Sprawdzenie czy konta walutowe maja zdefiniowane dokumenty budżetowe
  If @Waluta<>'' and @Waluta<>'PLN' and @KontrolaBudzetu<>0 and EXISTS(select * from CDN.BudzetNag where BuN_AccId = @AccId)
   Begin
     exec CDN.RiseOptimaException 32627, 's', @ParNumer
     ROLLBACK TRAN
     SET NOCOUNT OFF
     RETURN
   End
    update CDN.KsiDokNag set KDN_KontoNazwa = @Nazwa
    where KDN_AccID = @AccID and KDN_KontoNazwa <> @Nazwa
 END
 SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Konta_Delete_Trigger
  ON CDN.Konta
  FOR DELETE
AS
SET NOCOUNT ON
DECLARE @AccId        INT
DECLARE @ParId        INT
DECLARE @Analityka    SMALLINT
DECLARE @AnalitykaTmp SMALLINT
DECLARE @Numer     NVarchar(50)
DECLARE Usuniete CURSOR LOCAL FAST_FORWARD FOR
 SELECT
  Acc_AccId,
  Acc_ParId,
 Acc_Numer
 FROM deleted
OPEN Usuniete
WHILE 1=1
BEGIN
  FETCH NEXT FROM Usuniete INTO
                         @AccId,
                         @ParId,
             @Numer
  IF @@FETCH_STATUS <> 0 BREAK
 -- kontrola integralności z tabelą BudzetNag,
 -- nie można dopuścić do usunięcia konta jeśli istnieją rekordy
 -- w tabeli CDN.BudzetNag. Constrain Restrict nie wchodzi w grę
 -- ze względu na nieczytelny komunikat dla usera.
 IF EXISTS (SELECT * FROM CDN.BudzetNag where BuN_AccID = @AccId)
 BEGIN
  exec CDN.RiseOptimaException 32628, 's', @Numer
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
 IF EXISTS (SELECT * FROM CDN.KsiDokNag where KDN_Typ = 111 and KDN_AccID = @AccId)
 BEGIN
  exec CDN.RiseOptimaException 32629, 's', @Numer
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
 IF EXISTS (SELECT * FROM CDN.KsiDokNag where KDN_Typ = 112 and KDN_AccID = @AccId)
 BEGIN
  exec CDN.RiseOptimaException 32630, 's', @Numer
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
 IF EXISTS (SELECT * FROM CDN.KsiDokNag where KDN_Typ = 113 and KDN_AccID = @AccId)
 BEGIN
  exec CDN.RiseOptimaException 32631, 's', @Numer
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
 -- Aktualizacja "ojca" który stał się analityką
 IF @ParId IS NOT NULL
 BEGIN
  IF EXISTS (SELECT * FROM CDN.Konta WHERE Acc_ParId = @ParId)
   SET @AnalitykaTmp = 0
  ELSE
   SET @AnalitykaTmp = 1
  SELECT @Analityka = Acc_Analityka FROM CDN.Konta WHERE Acc_AccId = @ParId
  IF @Analityka <> @AnalitykaTmp
        UPDATE CDN.Konta SET Acc_Analityka = @AnalitykaTmp WHERE Acc_AccId = @ParId
 END
 -- Usuwanie wskaźnika z konta w okresie następnym
 IF EXISTS (Select * From CDN.Konta Where Acc_NextAccId = @AccId)
  UPDATE CDN.Konta Set Acc_NextAccId = Null WHERE Acc_NextAccId = @AccId
 delete from CDN.KontaZakazy where AcZ_AccId = @AccId;
 -- Usuwanie wymiarów analitycznych
 DECLARE @WADokumentTyp int = 0;
 select @WADokumentTyp=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Konto księgowe';
 if exists(select * from CDN.WymiaryWartosci where WyW_DokumentTyp=@WADokumentTyp and WyW_DokumentId = @AccId)
  delete from CDN.WymiaryWartosci where WyW_DokumentTyp=@WADokumentTyp and WyW_DokumentId = @AccId;
END
SET NOCOUNT OFF
