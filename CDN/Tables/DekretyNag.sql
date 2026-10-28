CREATE TABLE [CDN].[DekretyNag] (
    [DeN_DeNId]               INT             IDENTITY (1, 1) NOT NULL,
    [DeN_Typ]                 INT             NOT NULL,
    [DeN_OObId]               INT             NOT NULL,
    [DeN_DziId]               INT             NOT NULL,
    [DeN_Dziennik]            VARCHAR (20)    NOT NULL,
    [DeN_OrgID]               INT             NULL,
    [DeN_Storno]              TINYINT         NULL,
    [DeN_NrDziennika]         INT             NOT NULL,
    [DeN_NrKsiegi]            INT             NOT NULL,
    [DeN_IdentKsieg]          VARCHAR (50)    NOT NULL,
    [DeN_IdentKsiegNumeracja] VARCHAR (50)    NULL,
    [DeN_IdentKsiegDDfID]     INT             NULL,
    [DeN_Bufor]               TINYINT         NOT NULL,
    [DeN_DataDok]             DATETIME        NOT NULL,
    [DeN_DataWys]             DATETIME        NOT NULL,
    [DeN_DataOpe]             DATETIME        NOT NULL,
    [DeN_Dokument]            VARCHAR (256)   NOT NULL,
    [DeN_PodmiotTyp]          SMALLINT        NULL,
    [DeN_PodmiotId]           INT             NULL,
    [DeN_KatId]               INT             NULL,
    [DeN_Kategoria]           VARCHAR (256)   NOT NULL,
    [DeN_KwotaWn]             DECIMAL (15, 2) NOT NULL,
    [DeN_KwotaMa]             DECIMAL (15, 2) NOT NULL,
    [DeN_Zrodlo]              TINYINT         NOT NULL,
    [DeN_WzorzecTyp]          SMALLINT        NULL,
    [DeN_WzorzecId]           INT             NULL,
    [DeN_OpeZalID]            INT             NULL,
    [DeN_StaZalId]            INT             NULL,
    [DeN_TS_Zal]              DATETIME        NOT NULL,
    [DeN_OpeModID]            INT             NULL,
    [DeN_StaModId]            INT             NULL,
    [DeN_TS_Mod]              DATETIME        NOT NULL,
    [DeN_Korekta]             TINYINT         CONSTRAINT [DF_DeN_Korekta] DEFAULT ((0)) NOT NULL,
    [DeN_OpisKorekta]         NVARCHAR (254)  NULL,
    [DeN_DDfId]               INT             NULL,
    [DeN_NumerNr]             INT             NULL,
    [DeN_NumerString]         NVARCHAR (31)   NULL,
    [DeN_NumerPelny]          AS              ([CDN].[FN_NUMERPELNY]([DeN_NumerNr],[DeN_NumerString])),
    [DeN_TypRozliczenia]      TINYINT         NULL,
    [DeN_KorektaZaplaconych]  TINYINT         CONSTRAINT [DF_DeN_KorektaZaplaconych] DEFAULT ((0)) NOT NULL,
    [DeN_TS_ModB]             DATETIME        NULL,
    [DeN_IdentKsiegStr]       AS              ([CDN].[IdentKsiStr]([DeN_IdentKsieg],[DeN_IdentKsiegNumeracja])),
    [DeN_IdentKsiegNr]        AS              ([CDN].[IdentKsiNr]([DeN_IdentKsieg],[DeN_IdentKsiegNumeracja])),
    [DeN_OpeModKod]           VARCHAR (20)    CONSTRAINT [DF_DeN_OpeModKod] DEFAULT ('') NOT NULL,
    [DeN_OpeModNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_DeN_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [DeN_OpeZalKod]           VARCHAR (20)    CONSTRAINT [DF_DeN_OpeZalKod] DEFAULT ('') NOT NULL,
    [DeN_OpeZalNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_DeN_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [DeN_Primary] PRIMARY KEY CLUSTERED ([DeN_DeNId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DeNKategoria] FOREIGN KEY ([DeN_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_DeNPodmiot] FOREIGN KEY ([DeN_PodmiotId], [DeN_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DeNPodmiot]
    ON [CDN].[DekretyNag]([DeN_PodmiotId] ASC, [DeN_PodmiotTyp] ASC, [DeN_DataDok] ASC, [DeN_DeNId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DeNKategoria]
    ON [CDN].[DekretyNag]([DeN_KatId] ASC, [DeN_DataDok] ASC, [DeN_DeNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DeNDziennikChrono]
    ON [CDN].[DekretyNag]([DeN_Typ] ASC, [DeN_DziId] ASC, [DeN_DataDok] ASC, [DeN_Bufor] ASC, [DeN_NrDziennika] ASC, [DeN_DeNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DeNKsiegaChrono]
    ON [CDN].[DekretyNag]([DeN_Typ] ASC, [DeN_OObId] ASC, [DeN_DataDok] ASC, [DeN_Bufor] ASC, [DeN_NrKsiegi] ASC, [DeN_DeNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeNDziennikNumer]
    ON [CDN].[DekretyNag]([DeN_Typ] ASC, [DeN_DziId] ASC, [DeN_Bufor] ASC, [DeN_NrDziennika] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeNKsiegaNumer]
    ON [CDN].[DekretyNag]([DeN_Typ] ASC, [DeN_OObId] ASC, [DeN_Bufor] ASC, [DeN_NrKsiegi] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeNOryginal]
    ON [CDN].[DekretyNag]([DeN_OrgID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeNWzorzec]
    ON [CDN].[DekretyNag]([DeN_WzorzecId] ASC, [DeN_WzorzecTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeNIdentKsieg]
    ON [CDN].[DekretyNag]([DeN_IdentKsieg] ASC, [DeN_IdentKsiegStr] ASC, [DeN_IdentKsiegNr] ASC)
    INCLUDE([DeN_DeNId], [DeN_Storno]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeN_DETA]
    ON [CDN].[DekretyNag]([DeN_Typ] ASC, [DeN_OObId] ASC, [DeN_Bufor] ASC, [DeN_DziId] ASC, [DeN_DeNId] ASC)
    INCLUDE([DeN_Storno], [DeN_NrDziennika], [DeN_NrKsiegi], [DeN_DataDok], [DeN_Dokument], [DeN_Kategoria], [DeN_IdentKsieg]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DeNNumerPelny]
    ON [CDN].[DekretyNag]([DeN_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DekretyNag_InsertUpdate_Trigger
  ON CDN.DekretyNag
  FOR INSERT, UPDATE
AS
Set NoCount On
Declare
 @DeNId           Int,
 @DziId           Int,
 @OObId           Int,
 @OrgId           Int,
 @Typ             Int,
 @Dziennik        NVarchar(20),
 @DataDok         DateTime,
 @Bufor           Int,
 @NrKsiegi        Int,
 @NrDziennika     Int,
 @Storno          Int,
 @PodmiotTyp      Int,
 @PodId           Int,
 @IdentKsieg      NVarchar(50),
 @IdentKsiegStr   NVarchar(50),
 @IdentKsiegNr    Int,
 @JestRenumeracja Int,
 @NumeracjaCiagla Int,
 @DataMin         DateTime,
 @DataMax         DateTime,
 @Zrodlo          Int,
 @DeNId2          Int,
 @WzorzecTyp      Int,
 @WzorzecId       Int,
 @PrzekroczonoZakresDat Int,
 @DefiniowalnySchematID_DDfID INT,
 @DefiniowalnySchematID_Numeracja NVARCHAR(50),
 @DefiniowalnySchematID_Symbol NVARCHAR(5),
 @Rejestr   NVARCHAR(20),
 @NumerString  NVarchar(30),
 @Dokument   NVarchar(30),
 @NumerPelny  NVarchar(30),
 @TypRozliczenia int,
 @InsertMode  int,
 @EditMode   int
 if not Exists(select * from deleted) and Exists(select * from inserted)
 begin
  set @InsertMode = 1
  set @EditMode = 0
 end
 else
 begin
  set @InsertMode = 0
  set @EditMode = 1
 end
Declare Dodane Cursor Local Fast_Forward For
 Select
  DeN_DeNId       ,
  DeN_DziId       ,
  DeN_OObId       ,
  DeN_OrgId       ,
  DeN_Typ    ,
  DeN_Dziennik    ,
  DeN_DataDok     ,
  DeN_Bufor       ,
  DeN_NrKsiegi    ,
  DeN_NrDziennika ,
  DeN_Storno      ,
  DeN_PodmiotTyp  ,
  DeN_PodmiotId   ,
  DeN_WzorzecTyp  ,
  DeN_WzorzecId   ,
  DeN_IdentKsieg  ,
  DeN_IdentKsiegNr,
  DeN_IdentKsiegStr,
  DeN_NumerPelny,
  DeN_Dokument,
  DeN_TypRozliczenia,
  DeN_NumerPelny
 From inserted
 Order By DeN_OObId, DeN_DataDok, DeN_Bufor, DeN_NrKsiegi, DeN_DeNId
Open Dodane
While 1=1
  Begin
Fetch Next From Dodane InTo
     @DeNId       ,
     @DziId       ,
     @OObId       ,
     @OrgId       ,
  @Typ         ,
     @Dziennik    ,
     @DataDok     ,
     @Bufor       ,
     @NrKsiegi    ,
     @NrDziennika ,
     @Storno      ,
     @PodmiotTyp  ,
     @PodId       ,
     @WzorzecTyp  ,
     @WzorzecId   ,
     @IdentKsieg  ,
     @IdentKsiegNr,
     @IdentKsiegStr,
  @NumerString,
  @Dokument,
  @TypRozliczenia,
  @NumerPelny
    If @@Fetch_Status <> 0 Break
 -- Sprawdzenie unikalności Numeru Pełnego DeN_NumerPelny
 If @Typ = 2 and @NumerPelny Is Not Null
 begin
  if exists (select * from cdn.DekretyNag where IsNull(DeN_Storno,0) = IsNull(@Storno,0) and DeN_NumerPelny = @NumerPelny and DeN_deNId <> @DeNId)
  begin
   exec CDN.RiseOptimaException 32596, 's', @NumerPelny
  end
 end
 -- Ograniczenia czasowe do przechowywania zapisów w buforze
 If @InsertMode <> 0 And @Typ = 2
 Begin
  Set @PrzekroczonoZakresDat = CDN.PrzekroczonyZakresDatWBuforze(@DataDok, @OObId, @Bufor)
  If @PrzekroczonoZakresDat = 1
  Begin
   exec CDN.RiseOptimaException 30189
   RollBack Tran
   Return
  End
 End
    -- Sprawdzenie dekretu powizanego
    If @OrgId Is Not Null
      If Not Exists (Select * From CDN.DekretyNag Where DeN_DeNId = @OrgId)
     Begin
    exec CDN.RiseOptimaException 32597
          RollBack Tran
          Return
     End
    -- Kontrola symbolu dziennika
    If Update (DeN_DziId) Or Update (DeN_Dziennik) Or Update (DeN_OObId)
      If Not Exists (Select * From CDN.Dzienniki Where Dzi_DziId = @DziId And Dzi_OObId = @OObId And Dzi_Symbol = @Dziennik)
        Begin
    exec CDN.RiseOptimaException 32598
          RollBack Tran
          Return
        End
    -- Kontrola okresu obrachunkowego
    If Update (DeN_OObId) Or Update (DeN_DataDok)
      If Not Exists (Select * From CDN.OkresyObrach Where OOb_OObId = @OObId And @DataDok Between OOb_DataOtw And OOb_DataKoncowa)
        Begin
    exec CDN.RiseOptimaException 32599
          RollBack Tran
          Return
        End
    -- Aktualizacja daty i bufora w rozrachunkach
    If @Typ = 2 And (Update (DeN_DataDok) Or Update (DeN_Bufor))
 And Exists (select * from CDN.DekretyElem where DeE_Rozrachunki = 1 and DeE_DeNId = @DeNId)
        update CDN.KsiRozrachunki
        set KRo_DataDokumentu = @DataDok,
            KRo_Bufor         = @Bufor
        from CDN.KsiRozrachunki
        inner join CDN.DekretyElem on (CDN.KsiRozrachunki.KRo_DeEID = CDN.DekretyElem.DeE_DeEID)
        inner join CDN.DekretyNag  on (CDN.DekretyElem.DeE_DeNID    = CDN.DekretyNag.DeN_DeNID)
        where CDN.DekretyNag.DeN_DeNID = @DeNId
    -- Aktualizacja daty i bufora w subelementach księgowania (DekretyKonta)
    If @Typ = 2 And (Update (DeN_DataDok) Or Update (DeN_Bufor))
      If Exists (Select * From CDN.DekretyKonta Where DeK_DeNId = @DeNId And (DeK_DataDok <> @DataDok Or DeK_Bufor <> @Bufor))
        Update CDN.DekretyKonta Set DeK_DataDok = @DataDok, DeK_Bufor = @Bufor
        Where DeK_DeNId = @DeNId And (DeK_DataDok <> @DataDok Or DeK_Bufor <> @Bufor)
    -- Sprawdzenie unikalności numeru księgi
    If @Typ = 2 And @Bufor = 0 And @NrKsiegi <> 0 And (Update (DeN_NrKsiegi) Or Update (DeN_Bufor) Or Update (DeN_OObId))
      If Exists (
        Select * From CDN.DekretyNag
        Where DeN_Typ = 2 And DeN_OObId = @OObId And DeN_Bufor = 0 And DeN_NrKsiegi = @NrKsiegi And DeN_DeNId <> @DeNId
        )
        Begin
    exec CDN.RiseOptimaException 32600
          RollBack Tran
          Return
        End
    -- Sprawdzenie unikalności numeru dziennika cząstkowego
    If @Typ = 2 And @Bufor = 0 And @NrDziennika <> 0 And (Update (DeN_NrDziennika) Or Update (DeN_Bufor) Or Update (DeN_DziId))
      If Exists (
        Select * From CDN.DekretyNag
        Where DeN_Typ = 2 And DeN_DziId = @DziId And DeN_Bufor = 0 And DeN_NrDziennika = @NrDziennika And DeN_DeNId <> @DeNId
        )
        Begin
    exec CDN.RiseOptimaException 32601
          RollBack Tran
          Return
        End
    -- Zależności czasowe
    If @Typ = 2 And (Update (DeN_Bufor) Or Update (DeN_OObId) Or Update (DeN_DataDok))
      Begin
        If Exists (Select * From CDN.DekretyNag Where DeN_Typ = 2 And DeN_OObId = @OObId And DeN_Bufor = 0 And DeN_DataDok > @DataDok)
          Begin
   exec CDN.RiseOptimaException 32602
            RollBack Tran
            Return
          End
        If @Bufor = 0
          If Exists ( Select * From CDN.DekretyNag Where DeN_Typ = 2 And DeN_OObId = @OObId And DeN_Bufor = 1 And DeN_DataDok < @DataDok )
            Begin
     exec CDN.RiseOptimaException 32603
              RollBack Tran
              Return
            End
      End
    -- Tu jest renumeracja
    If @Typ = 2 And (@NrKsiegi = 0 Or @NrDziennika = 0)
    Begin
        Set @JestRenumeracja = 0
        If @NrKsiegi = 0
          Begin -- Początek numeracji dziennika głównego
            Set @JestRenumeracja = 1
            If @Bufor = 0
              Select @NrKsiegi = IsNull(MAX(DeN_NrKsiegi),0)+1 From CDN.DekretyNag Where DeN_Typ = 2 And DeN_OObId = @OObId And DeN_Bufor = 0
            Else
              Select @NrKsiegi = MAX(NumerKsiegi)+1 From
                             (     Select IsNull(MAX(DeN_NrKsiegi),0) As NumerKsiegi From CDN.DekretyNag Where DeN_Typ = 2 And DeN_OObId = @OObId AND DeN_Bufor = 0
                             Union Select IsNull(MAX(DeN_NrKsiegi),0) As NumerKsiegi From CDN.DekretyNag Where DeN_Typ = 2 And DeN_OObId = @OObId AND DeN_Bufor = 1) As T1
          End
        If @NrDziennika = 0
          Begin -- Początek numeracji dziennika cząstokowego
            Set @JestRenumeracja = 1
            SELECT @NumeracjaCiagla = (SELECT OOb_CiaglaNumeracjaDC FROM CDN.OkresyObrach WHERE OOb_OObId = @OObId)
            If @NumeracjaCiagla = 1  -- Numeracja ciągla w roku
              BEGIN
                IF @Bufor = 0
                  SELECT @NrDziennika = IsNull(MAX(DeN_NrDziennika),0)+1 FROM CDN.DekretyNag WHERE DeN_Typ = 2 And DeN_DziID = @DziId AND DeN_Bufor = 0
                ELSE
                  SELECT @NrDziennika = MAX(NumerDziennika)+1 FROM
                                    (     SELECT IsNull(MAX(DeN_NrDziennika),0) As NumerDziennika FROM CDN.DekretyNag WHERE DeN_Typ = 2 And DeN_DziID = @DziId AND DeN_Bufor = 0
                                    UNION SELECT IsNull(MAX(DeN_NrDziennika),0) As NumerDziennika FROM CDN.DekretyNag WHERE DeN_Typ = 2 And DeN_DziID = @DziId AND DeN_Bufor = 1 ) As T1
              END
            ELSE  -- Numeracja ciągla w miesiącu
              BEGIN
                SET @DataMin = DATEADD(DAY, 1-DAY(@DataDok), @DataDok)
                SET @DataMax = DATEADD(DAY, -DAY(DATEADD(MONTH,1,@DataDok)), DATEADD(MONTH,1,@DataDok))
                IF @Bufor = 0
                  SELECT @NrDziennika = IsNull(MAX(DeN_NrDziennika),0)+1 FROM CDN.DekretyNag WHERE DeN_Typ = 2 And DeN_DziID = @DziId AND DeN_Bufor = 0 AND DeN_DataDok BETWEEN @DataMin AND @DataMax
                ELSE
                  SELECT @NrDziennika = MAX(NumerDziennika)+1 FROM
                                    (     SELECT IsNull(MAX(DeN_NrDziennika),0) As NumerDziennika FROM CDN.DekretyNag WHERE DeN_Typ = 2 And DeN_DziID = @DziId AND DeN_Bufor = 0 AND DeN_DataDok BETWEEN @DataMin AND @DataMax
                                    UNION SELECT IsNull(MAX(DeN_NrDziennika),0) As NumerDziennika FROM CDN.DekretyNag WHERE DeN_Typ = 2 And DeN_DziID = @DziId AND DeN_Bufor = 1 AND DeN_DataDok BETWEEN @DataMin AND @DataMax ) As T1
              END
          END  -- Koniec numeracji dziennika
        If @Typ = 2 And @JestRenumeracja = 1
  Begin
            UPDATE CDN.DekretyNag SET DeN_NrKsiegi=@NrKsiegi, DeN_NrDziennika = @NrDziennika WHERE DeN_DeNId = @DeNId
            -- aktualizacja numeru dzinnika i numeru księgi w rozrachunkach
   if Exists (select * from CDN.DekretyElem where DeE_Rozrachunki = 1 and DeE_DeNId = @DeNId)
    update CDN.KsiRozrachunki
    set KRo_NrDziennika  = CDN.DekretyNag.DeN_Dziennik + '/' + convert(NVarchar(10), CDN.DekretyNag.DeN_NrDziennika),
     KRo_NrKsiegi  = convert(NVarchar(30), CDN.DekretyNag.DeN_NrKsiegi),
     KRo_NumerDziennika = CDN.DekretyNag.DeN_NrDziennika
    from CDN.KsiRozrachunki
    inner join CDN.DekretyElem on (CDN.KsiRozrachunki.KRo_DeEID = CDN.DekretyElem.DeE_DeEID)
    inner join CDN.DekretyNag  on (CDN.DekretyElem.DeE_DeNID    = CDN.DekretyNag.DeN_DeNID)
    where CDN.DekretyNag.DeN_DeNID = @DeNId
  End
    End
 -- nadanie numeru dokumentu dla kompensat i różnic kursowych
 -- tylko dla nowo dodanych, pomijamu edycje
 if @TypRozliczenia is Not Null and not Exists(select * from deleted) and Exists(select * from inserted)
 begin
  if Len(@Dokument) > 0
   Set @Dokument = @NumerString + ', ' + @Dokument
  else
   Set @Dokument = @NumerString
  update CDN.DekretyNag Set DeN_Dokument = @Dokument where DeN_DeNId = @DeNId
 end
    -- usunięcie rozliczeń z dekretów oryginalnych i z KB
    if @Typ = 2 And Update(DeN_Storno) and IsNull(@OrgId, 0) <> 0 And @Storno = 1
    begin
  --potrzebujemy funkcji która będzie usuwac rozliczenie KB bez zgłaszania wyjątków, tak aby nei doszło do wycofania trancakcji.
  --if exists(select KRo_KRoId from cdn.KsiRozrachunki join cdn.DekretyElem on (KRo_DeEId = DeE_DeEId) join cdn.BnkRozKwoty on (BRK_KRoID = KRo_KRoId) where DeE_DeNId = @OrgId)
  --or
  --exists (select KRo_RozliczenieId from cdn.KsiRozrachunki join cdn.DekretyElem on (KRo_DeEId = DeE_DeEId) join cdn.BnkRozKwoty on (BRK_KRoID = KRo_KRoId) where DeE_DeNId = @OrgId)
  --begin
  -- delete from cdn.BnkRozKwoty where BRK_KRoID in (
  -- select KRo_KRoId from cdn.KsiRozrachunki join cdn.DekretyElem on (KRo_DeEId = DeE_DeEId)
  -- where DeE_DeNId = @OrgId
  -- union
  -- select KRo_RozliczenieId from cdn.KsiRozrachunki join cdn.DekretyElem on (KRo_DeEId = DeE_DeEId)
  -- where DeE_DeNId = @OrgId
  -- )
  --end
        execute CDN.KRo_KasujRozliczenia 1, @OrgId, @OObId, 1
    end
    -- Obsługa "odksięgowania" zapisów źródłowych przy wykonywaniu storna
    If @Typ = 2 And Update(DeN_Bufor) And IsNull(@OrgId, 0) <> 0 And @Storno = 1 And @Bufor=0
    Begin
        Declare Storna Cursor Local Fast_Forward For
        Select DeN_DeNId, DeN_Zrodlo From CDN.DekretyNag Where DeN_DeNId = @OrgId And DeN_Zrodlo<>0
        Open Storna
        While 1=1
          Begin
            Fetch Next From Storna InTo @DeNId2, @Zrodlo
            If @@Fetch_Status<>0 Break
            If @Zrodlo In (1, 2) -- TraNag i związane VatNag
              Begin
                -- Disabluje triggery, zeby nie updatowal rekurencyjnie
                Alter Table CDN.TraNag Disable Trigger All
                Alter Table CDN.VatNag Disable Trigger All
                Update CDN.TraNag Set TrN_DekId = Null Where TrN_DekId = @DeNId2
                Update CDN.VatNag Set VaN_DekId = Null Where VaN_DekId = @DeNId2
                Alter Table CDN.TraNag Enable Trigger All
                Alter Table CDN.VatNag Enable Trigger All
              End
            If @Zrodlo = 3 -- AutoRozlicz
              Update CDN.AutoRozlicz Set AuR_DekId = Null Where AuR_DekId = @DeNId2
            If @Zrodlo = 5 -- WyplatyNag
              Update CDN.WyplatyNag  Set WyN_DekId = Null Where WyN_DekId = @DeNId2
            If @Zrodlo = 6 -- DeklNag
              Update CDN.DeklNag     Set DkN_DekId = Null Where DkN_DekId = @DeNId2
            If @Zrodlo = 7 -- TrwaleHist
              Update CDN.TrwaleHist  Set SrH_DekId = Null Where SrH_DekId = @DeNId2
            If @Zrodlo = 9 -- BnkRaporty
              Update CDN.BnkRaporty  Set BRp_DekId = Null Where BRp_DekId = @DeNId2
            If @Zrodlo = 10 -- ListyPlac
              Update CDN.ListyPlac   Set LPL_DekId = Null Where LPL_DekId = @DeNId2
            If @Zrodlo = 11 -- NotyOdsNag
              Update CDN.NotyOdsNag  Set NON_DekId = Null Where NON_DekId = @DeNId2
            If @Zrodlo = 12 -- EwidDodNag
              Update CDN.EwidDodNag  Set EDN_DekId = Null Where EDN_DekId = @DeNId2
            If @Zrodlo in (13,44,50) -- BnkRozKwoty
             Begin
              Update CDN.BnkRozKwoty Set BRK_DekId  = Null Where BRK_DekId  = @DeNId2
              Update CDN.BnkRozKwoty Set BRK_Dek2Id = Null Where BRK_Dek2Id = @DeNId2
             End
            If @Zrodlo = 41  -- PrzeszacWalutNag 1 dekret
             Begin
                    if exists(  select * from CDN.PrzeszacWalutNag
           where PWN_DekID=@DeNId2 and PWN_NextDekID is not null)
                    begin
      exec CDN.RiseOptimaException 32604
               RollBack Tran
                 Return
                    end
                    Update CDN.PrzeszacWalutNag Set PWN_DekID   = Null Where PWN_DekID   = @DeNId2
             End
            If @Zrodlo = 42 -- PrzeszacWalutNag 2 dekret
             Begin
      Update CDN.PrzeszacWalutNag Set PWN_NextDekID = Null Where PWN_NextDekID = @DeNId2
      Update CDN.PrzeszacWalutNag Set PWN_DekID   = Null Where PWN_DekID     = @DeNId2
             End
            If @Zrodlo = 43 -- Różnica kursowa MW
             Begin
      Update CDN.BnkRozKwotyMW Set BRKMW_DekId  = Null Where BRKMW_DekId  = @DeNId2
                        Update CDN.BnkRozKwotyMW Set BRKMW_Dek2Id = Null Where BRKMW_Dek2Id = @DeNId2
             End
            If @Zrodlo = 49 -- Nota odsetkowa
             Begin
      Update CDN.KsiDokNag Set KDN_DekId = Null Where KDN_DekID  = @DeNId2
             End
            If @Zrodlo = 50 -- kompesnaty
             Begin
      Update CDN.KompensatyNag Set KPN_DekID = Null Where KPN_DekID  = @DeNId2
             End
            If @Zrodlo = 108 -- delegacje
             Begin
      Update CDN.DlgNag Set DLN_DekID = Null Where DLN_DekID  = @DeNId2
             End
          End
        Close Storna
        Deallocate Storna
        -- Skasowanie wskaznika zrodla w stornowanym zapisie
        Update CDN.DekretyNag Set DeN_Zrodlo = 0 Where DeN_DeNId = @OrgId And DeN_Zrodlo<>0
        -- Skasowanie informacji o źródłowych dokumentach elementów dekretu
        Update CDN.DekretyElem set DeE_DokumentTyp = NULL, DeE_DokumentId = NULL, DeE_BZdID = NULL
        where
        DeE_DeNID = @OrgId
  -- skasowanie informacji na rozliczeniach kb do rozrachunku
    End
    -- Aktualizacja danych odnoszących się do dzinników w rozrachunkach
 If Update (DeN_DziId)  or Update (DeN_Dziennik) or Update (DeN_NrDziennika) or Update (DeN_NrKsiegi)
 begin
  if Exists(select * from deleted) and Exists (select * from CDN.DekretyElem where DeE_Rozrachunki = 1 and DeE_DeNId = @DeNId)
  begin
   update CDN.KsiRozrachunki set  KRo_Dziennik = @Dziennik,
           KRo_NrDziennika = @Dziennik,
           KRo_NumerDziennika = @NrDziennika,
           KRo_NrKsiegi = @NrKsiegi
   from CDN.KsiRozrachunki
   inner join CDN.DekretyElem on (CDN.KsiRozrachunki.KRo_DeEID = CDN.DekretyElem.DeE_DeEID)
   inner join CDN.DekretyNag  on (CDN.DekretyElem.DeE_DeNID    = CDN.DekretyNag.DeN_DeNID)
   where CDN.DekretyNag.DeN_DeNID = @DeNId
  end
 end
    -- Ustawienie identyfikatora ksiegowego
    If @IdentKsieg = 'AUTO'
   Begin
        Set @IdentKsieg = ''
   End
    If Update (DeN_IdentKsieg)
  if @Typ = 2
  begin
    If @OrgId Is Not Null
   Begin
   -- dokument powiązany, więc nadajemy ten sam Id co oryginalnemu
    Select @IdentKsieg = DeN_IdentKsieg From CDN.DekretyNag Where DeN_DeNId = @OrgId
    Update CDN.DekretyNag Set DeN_IdentKsieg = @IdentKsieg Where DeN_DeNId = @DeNId And DeN_IdentKsieg <> @IdentKsieg
   End
    Else
   Begin
     If (@IdentKsieg = '' Or SubString(@IdentKsieg, 1, 2) = '0/')
    Begin
     SELECT @DefiniowalnySchematID_DDfID=CDN.CzyUzywacDefniowalnegoSchematuID(@DataDok)
     IF( @DefiniowalnySchematID_DDfID <> 0)
     BEGIN
      -- Definiowalny schemat numeracji ID księgowego
      SELECT  @DefiniowalnySchematID_Numeracja=DDf_Numeracja,@DefiniowalnySchematID_Symbol=Ddf_Symbol
      FROM CDN.DokDefinicje
      WHERE DDf_DDfID = @DefiniowalnySchematID_DDfID
      IF(SUBSTRING(@IdentKsieg, 1, 2) = '0/') -- księgowania ustawiają IdentKsieg po staremu! Tutaj go poprawimy.
       SET @Rejestr = REVERSE(SUBSTRING(REVERSE(@IdentKsieg), 0, CHARINDEX('/',REVERSE(@IdentKsieg))))
      ELSE
       SET @Rejestr = @Dziennik
      SET @IdentKsieg = CDN.PodajIDKsiegowe(@DataDok, @Rejestr, @OObID, @DefiniowalnySchematID_DDfID, 1);
      UPDATE CDN.DekretyNag SET DeN_IdentKsieg=@IdentKsieg, DeN_IdentKsiegDDfID=@DefiniowalnySchematID_DDfID, DeN_IdentKsiegNumeracja=@DefiniowalnySchematID_Numeracja
      WHERE DeN_DeNId = @DeNId
      if Exists(select * from deleted) and Exists (select * from CDN.DekretyElem where DeE_Rozrachunki = 1 and DeE_DeNId = @DeNId)
      begin
       update CDN.KsiRozrachunki
       set KRo_IdentKsieg = @IdentKsieg
       from CDN.KsiRozrachunki
       inner join CDN.DekretyElem on (CDN.KsiRozrachunki.KRo_DeEID = CDN.DekretyElem.DeE_DeEID)
       inner join CDN.DekretyNag  on (CDN.DekretyElem.DeE_DeNID    = CDN.DekretyNag.DeN_DeNID)
       where CDN.DekretyNag.DeN_DeNID = @DeNId and KRo_IdentKsieg <> @IdentKsieg
      end
     END
     ELSE
     BEGIN
      -- zwykły schemat numeracji ID księgowego
      If @IdentKsieg = ''
       Set @IdentKsiegStr = SubString(Convert(NVarchar(4), Year(@DataDok)),3,2) + '/' + @Dziennik
      Else
       Set @IdentKsiegStr = SubString(@IdentKsieg,3,28)
      Select @IdentKsiegNr = IsNull(Max(DeN_IdentKsiegNr),0)+1 From CDN.DekretyNag Where DeN_IdentKsiegStr = @IdentKsiegStr
      Update CDN.DekretyNag
      Set DeN_IdentKsieg = LTrim(Str(@IdentKsiegNr)) + '/' + @IdentKsiegStr
      Where DeN_DeNId = @DeNId
      if Exists(select * from deleted) and Exists (select * from CDN.DekretyElem where DeE_Rozrachunki = 1 and DeE_DeNId = @DeNId)
      begin
       update CDN.KsiRozrachunki
       set KRo_IdentKsieg = LTrim(Str(@IdentKsiegNr)) + '/' + @IdentKsiegStr
       from CDN.KsiRozrachunki
       inner join CDN.DekretyElem on (CDN.KsiRozrachunki.KRo_DeEID = CDN.DekretyElem.DeE_DeEID)
       inner join CDN.DekretyNag  on (CDN.DekretyElem.DeE_DeNID    = CDN.DekretyNag.DeN_DeNID)
       where CDN.DekretyNag.DeN_DeNID = @DeNId and KRo_IdentKsieg <> LTrim(Str(@IdentKsiegNr)) + '/' + @IdentKsiegStr
      end
     END
    End
     Else
    Begin
      -- Kontrola duplikacji identyfikatora
      If Exists (
      Select * From CDN.DekretyNag a Join CDN.DekretyNag b
      -- On a.DeN_IdentKsiegStr = b.DeN_IdentKsiegStr And a.DeN_IdentKsiegNr = b.DeN_IdentKsiegNr
      On a.DeN_IdentKsieg = b.DeN_IdentKsieg
      Where a.DeN_DeNId = @DeNId And b.DeN_DeNId <> @DeNId
      And IsNull(b.DeN_Storno,0) = 0 and b.DeN_Typ = 2
      And Not Exists (Select * From CDN.DekretyNag c Where b.DeN_DeNId = c.DeN_OrgId And IsNull(c.DeN_Storno,0) = 1)
      )
     Begin
       exec CDN.RiseOptimaException 32605, 's', @IdentKsieg
       RollBack Tran
       Return
     End
     if Exists(select * from deleted) and Exists (select * from CDN.DekretyElem where DeE_Rozrachunki = 1 and DeE_DeNId = @DeNId)
     begin
      update CDN.KsiRozrachunki
      set KRo_IdentKsieg = @IdentKsieg
      from CDN.KsiRozrachunki
      inner join CDN.DekretyElem on (CDN.KsiRozrachunki.KRo_DeEID = CDN.DekretyElem.DeE_DeEID)
      inner join CDN.DekretyNag  on (CDN.DekretyElem.DeE_DeNID    = CDN.DekretyNag.DeN_DeNID)
      where CDN.DekretyNag.DeN_DeNID = @DeNId and KRo_IdentKsieg <> @IdentKsieg
     end
    End
   End
  end
  else
  begin
   Select @IdentKsiegNr = IsNull(Max(DeN_IdentKsiegNr),0)+1 From CDN.DekretyNag Where DeN_OObID = @OObID and DeN_Typ = 1
   Update CDN.DekretyNag Set DeN_IdentKsieg = LTrim(Str(@IdentKsiegNr)) Where DeN_DeNId = @DeNId
  end
  End
Close Dodane
Deallocate Dodane
Set NoCount Off

GO
Create Trigger CDN.DekretyNag_Delete_Trigger
  On CDN.DekretyNag
  For Delete
As
Set NoCount On
-- Obsługa kaskadowego uaktualniania ("odksięgowania") zapisów źródłowych
If Exists (Select * From Deleted Where DeN_Zrodlo <> 0)
Begin
 Declare @DeNId Int, @Zrodlo Int, @Info NVarchar(100), @UsunPreDekret Int
 SELECT @UsunPreDekret=ISNULL(CAST(Fir_Wartosc AS INT),0) FROM CDN.Firma WHERE Fir_Numer=2162
 Declare Skasowane Cursor Local Fast_Forward For Select DeN_DeNId, DeN_Zrodlo From Deleted Where DeN_Zrodlo <> 0
 Open Skasowane
 While 1=1
 Begin
  Fetch Next From Skasowane InTo @DeNId, @Zrodlo
  If @@Fetch_Status<>0 Break
  -- Sprawdzenie istnienia powiązania z innym dekretem
  If Exists (Select * From CDN.DekretyNag Where DeN_OrgId=@DeNId)
   Begin
    Select Top 1 @Info = Case DeN_Storno When 1 Then 'storno ' Else 'dekret powiązany ' End
     + LTrim(Str(DeN_NrKsiegi)) + Case DeN_Bufor When 1 Then '(b) (' Else ' (' End
     + DeN_Dokument + ' z ' + Convert (NVarchar(10), DeN_DataDok, 120) + ')'
    From CDN.DekretyNag Where DeN_OrgId=@DeNId
    exec CDN.RiseOptimaException 32606, 's', @Info
    If @@TranCount<>0 RollBack Tran
    Set NoCount Off
    Return
   End
  If @Zrodlo In (1, 2) -- TraNag i związane VatNag
  Begin
   Alter Table CDN.TraNag Disable Trigger All
   Alter Table CDN.VatNag Disable Trigger All
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.VatNag Where VaN_DekId = @DeNId and VaN_PreDekId is NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select VaN_PreDekId from CDN.VatNag where VaN_DekID = @DeNId)
    if exists(select * from CDN.TraNag Where TrN_DekId = @DeNId and TrN_PreDekId is NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select TrN_PreDekId from CDN.TraNag where TrN_DekId = @DeNId)
    if exists(select * from CDN.TraNag Where TrN_DekId = @DeNId)
     Update CDN.TraNag Set TrN_DekId = Null, TrN_PreDekId = Null Where TrN_DekId = @DeNId
    if exists(select * from CDN.VatNag Where VaN_DekId = @DeNId)
     Update CDN.VatNag Set VaN_DekId = Null, VaN_PreDekId = Null Where VaN_DekId = @DeNId
   end
   else
   begin
    if exists(select * from CDN.TraNag Where TrN_DekId = @DeNId)
     Update CDN.TraNag Set TrN_DekId = Null Where TrN_DekId = @DeNId
    if exists(select * from CDN.VatNag Where VaN_DekId = @DeNId)
     Update CDN.VatNag Set VaN_DekId = Null Where VaN_DekId = @DeNId
   end
   if exists(select * from CDN.TraNag Where TrN_PreDekId = @DeNId)
    Update CDN.TraNag Set TrN_PreDekId = Null Where TrN_PreDekId = @DeNId
   if exists(select * from CDN.VatNag Where VaN_PreDekId = @DeNId)
    Update CDN.VatNag Set VaN_PreDekId = Null Where VaN_PreDekId = @DeNId
   Alter Table CDN.TraNag Enable Trigger All
   Alter Table CDN.VatNag Enable Trigger All
  End
  If @Zrodlo = 3 -- AutoRozlicz
  begin
   Update CDN.AutoRozlicz Set AuR_DekId = Null Where AuR_DekId = @DeNId
  end
  If @Zrodlo = 5 -- WyplatyNag
  begin
   Update CDN.WyplatyNag Set WyN_DekId = Null Where WyN_DekId = @DeNId
  end
  If @Zrodlo = 6 -- DeklNag
  begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.DeklNag Where DkN_DekId = @DeNId and DkN_PreDekId is NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select DkN_PreDekId from CDN.DeklNag where DkN_DekId = @DeNId)
    if exists(select * from CDN.DeklNag Where DkN_DekId = @DeNId)
     Update CDN.DeklNag Set DkN_DekId = Null, DkN_PreDekId = Null Where DkN_DekId = @DeNId
   end
   else
   begin
    if exists(select * from CDN.DeklNag Where DkN_DekId = @DeNId)
     Update CDN.DeklNag Set DkN_DekId = Null Where DkN_DekId = @DeNId
   end
   if exists(select * from CDN.DeklNag Where DkN_PreDekId = @DeNId)
    Update CDN.DeklNag Set DkN_PreDekId = Null Where DkN_PreDekId = @DeNId
  end
  If @Zrodlo = 7 -- TrwaleHist
  begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.TrwaleHist Where SrH_DekId = @DeNId and SrH_PreDekId is NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select SrH_PreDekId from CDN.TrwaleHist where SrH_DekId = @DeNId)
    if exists(select * from CDN.TrwaleHist Where SrH_DekId = @DeNId)
     Update CDN.TrwaleHist Set SrH_DekId = Null, SrH_PreDekId = Null Where SrH_DekId = @DeNId
   end
   else
   begin
    if exists(select * from CDN.TrwaleHist Where SrH_DekId = @DeNId)
     update CDN.TrwaleHist Set SrH_DekId = Null Where SrH_DekId = @DeNId
   end
   if exists(select * from CDN.TrwaleHist Where SrH_PreDekId = @DeNId)
    Update CDN.TrwaleHist Set SrH_PreDekId = Null Where SrH_PreDekId = @DeNId
  end
  If @Zrodlo = 9 -- BnkRaporty
  begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.BnkRaporty Where BRp_DekId = @DeNId and BRp_PreDekId is NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select BRp_PreDekId from CDN.BnkRaporty where BRp_DekId = @DeNId)
    if exists(select * from CDN.BnkRaporty Where BRp_DekId = @DeNId)
     Update CDN.BnkRaporty Set BRp_DekId = Null, BRp_PreDekId = Null Where BRp_DekId = @DeNId
   end
   else
   begin
    if exists(select * from CDN.BnkRaporty Where BRp_DekId = @DeNId)
     Update CDN.BnkRaporty Set BRp_DekId = Null Where BRp_DekId = @DeNId
   end
   if exists(select * from CDN.BnkRaporty Where BRp_PreDekId = @DeNId)
    Update CDN.BnkRaporty Set BRp_PreDekId = Null Where BRp_PreDekId = @DeNId
  end
  If @Zrodlo = 10 -- ListyPlac
  begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.ListyPlac Where LPL_DekId = @DeNId and LPL_PreDekId IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select LPL_PreDekId from CDN.ListyPlac where LPL_DekId = @DeNId)
    if exists(select * from CDN.ListyPlac Where LPL_DekId = @DeNId)
     Update CDN.ListyPlac Set LPL_DekId = Null, LPL_PreDekId = Null Where LPL_DekId = @DeNId
   end
   else
   begin
    if exists(select * from CDN.ListyPlac Where LPL_DekId = @DeNId)
     Update CDN.ListyPlac Set LPL_DekId = Null Where LPL_DekId = @DeNId
   end
   if exists(select * from CDN.ListyPlac Where LPL_PreDekId = @DeNId)
    Update CDN.ListyPlac Set LPL_PreDekId = Null Where LPL_PreDekId = @DeNId
  end
  If @Zrodlo = 11 -- NotyOdsNag
  begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.NotyOdsNag Where NON_DekId = @DeNId and NON_PreDekId IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select NON_PreDekId from CDN.NotyOdsNag where NON_DekId = @DeNId)
    if exists(select * from CDN.NotyOdsNag Where NON_DekId = @DeNId)
     Update CDN.NotyOdsNag Set NON_DekId = Null, NON_PreDekId = Null Where NON_DekId = @DeNId
   end
   else
   begin
    if exists(select * from CDN.NotyOdsNag Where NON_DekId = @DeNId)
     Update CDN.NotyOdsNag Set NON_DekId = Null Where NON_DekId = @DeNId
   end
   if exists(select * from CDN.NotyOdsNag Where NON_PreDekId = @DeNId)
    Update CDN.NotyOdsNag Set NON_PreDekId = Null Where NON_PreDekId = @DeNId
  end
  If @Zrodlo = 12 -- EwdiDodNag
  begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.EwidDodNag Where EDN_DekId = @DeNId and EDN_PreDekId IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select EDN_PreDekId from CDN.EwidDodNag where EDN_DekId = @DeNId)
    if exists(select * from CDN.EwidDodNag Where EDN_DekId = @DeNId)
     Update CDN.EwidDodNag Set EDN_DekId = Null, EDN_PreDekId = Null  Where EDN_DekId = @DeNId
   end
   else
   begin
    if exists(select * from CDN.EwidDodNag Where EDN_DekId = @DeNId)
     Update CDN.EwidDodNag Set EDN_DekId = Null Where EDN_DekId = @DeNId
   end
   if exists(select * from CDN.EwidDodNag Where EDN_PreDekId = @DeNId)
    Update CDN.EwidDodNag Set EDN_PreDekId = Null Where EDN_PreDekId = @DeNId
  end
  If @Zrodlo in (13,44,50) -- BnkRozKwoty
          Begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.BnkRozKwoty Where BRK_DekId  = @DeNId and BRK_PreDekId IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select BRK_PreDekId  from CDN.BnkRozKwoty where BRK_DekId  = @DeNId)
    if exists(select * from CDN.BnkRozKwoty Where BRK_Dek2Id = @DeNId and BRK_PreDek2Id IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select BRK_PreDek2Id from CDN.BnkRozKwoty where BRK_Dek2Id = @DeNId)
    if exists(select * from CDN.BnkRozKwoty Where BRK_DekId  = @DeNId)
     Update CDN.BnkRozKwoty Set BRK_DekId  = Null, BRK_PreDekId  = Null Where BRK_DekId  = @DeNId
    if exists(select * from CDN.BnkRozKwoty Where BRK_Dek2Id = @DeNId)
     Update CDN.BnkRozKwoty Set BRK_Dek2Id = Null, BRK_PreDek2Id = Null Where BRK_Dek2Id = @DeNId
   end
   else
   begin
    if exists(select * from CDN.BnkRozKwoty Where BRK_DekId  = @DeNId)
     Update CDN.BnkRozKwoty Set BRK_DekId  = Null Where BRK_DekId  = @DeNId
    if exists(select * from CDN.BnkRozKwoty Where BRK_Dek2Id = @DeNId)
     Update CDN.BnkRozKwoty Set BRK_Dek2Id = Null Where BRK_Dek2Id = @DeNId
   end
   if exists(select * from CDN.BnkRozKwoty Where BRK_PreDekId  = @DeNId)
    Update CDN.BnkRozKwoty Set BRK_PreDekId  = Null Where BRK_PreDekId  = @DeNId
   if exists(select * from CDN.BnkRozKwoty Where BRK_PreDek2Id = @DeNId)
    Update CDN.BnkRozKwoty Set BRK_PreDek2Id = Null Where BRK_PreDek2Id = @DeNId
          End
  If @Zrodlo = 41 -- PrzeszacWalutNag 1 dekret
  Begin
    if exists(select * from CDN.PrzeszacWalutNag
   where PWN_DekID=@DeNId and PWN_NextDekID is not null)
   begin
    exec CDN.RiseOptimaException 32607
                RollBack Tran
         Return
   end
      Update CDN.PrzeszacWalutNag Set PWN_DekID = Null Where PWN_DekID = @DeNId
  End
  If @Zrodlo = 42 -- PrzeszacWalutNag 2 dekret
  Begin
   Update CDN.PrzeszacWalutNag Set PWN_NextDekID = Null Where PWN_NextDekID = @DeNId
   Update CDN.PrzeszacWalutNag Set PWN_DekID   = Null Where PWN_DekID     = @DeNId
  End
  If @Zrodlo = 43 -- Różnica kursowa MW
  Begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.BnkRozKwotyMW Where BRKMW_DekId = @DeNId and BRKMW_PreDekId IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select BRKMW_PreDekId from CDN.BnkRozKwotyMW where BRKMW_DekId = @DeNId)
    if exists(select * from CDN.BnkRozKwotyMW Where BRKMW_Dek2Id = @DeNId and BRKMW_PreDekId IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select BRKMW_PreDekId from CDN.BnkRozKwotyMW where BRKMW_Dek2Id = @DeNId)
    if exists(select * from CDN.BnkRozKwotyMW Where BRKMW_DekId = @DeNId)
     Update CDN.BnkRozKwotyMW Set BRKMW_DekId  = Null, BRKMW_PreDekId = Null Where BRKMW_DekId = @DeNId
    if exists(select * from CDN.BnkRozKwotyMW Where BRKMW_Dek2Id = @DeNId)
     Update CDN.BnkRozKwotyMW Set BRKMW_Dek2Id = Null, BRKMW_PreDekId = Null Where BRKMW_Dek2Id = @DeNId
   end
   else
   begin
    if exists(select * from CDN.BnkRozKwotyMW Where BRKMW_DekId = @DeNId)
     Update CDN.BnkRozKwotyMW Set BRKMW_DekId  = Null Where BRKMW_DekId = @DeNId
    if exists(select * from CDN.BnkRozKwotyMW Where BRKMW_Dek2Id = @DeNId)
     Update CDN.BnkRozKwotyMW Set BRKMW_Dek2Id = Null Where BRKMW_Dek2Id = @DeNId
   end
   if exists(select * from CDN.BnkRozKwotyMW Where BRKMW_PreDekId = @DeNId)
    Update CDN.BnkRozKwotyMW Set BRKMW_PreDekId  = Null Where BRKMW_PreDekId = @DeNId
  End
  If @Zrodlo = 49 -- Nota odsetkowa
  Begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.KsiDokNag Where KDN_DekID = @DeNId and KDN_PreDekId IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select KDN_PreDekId from CDN.KsiDokNag where KDN_DekId = @DeNId)
    if exists(select * from CDN.KsiDokNag Where KDN_DekID = @DeNId)
     Update CDN.KsiDokNag Set KDN_DekId = Null, KDN_PreDekId = Null Where KDN_DekID  = @DeNId
   end
   else
   begin
    if exists(select * from CDN.KsiDokNag Where KDN_DekID = @DeNId)
     Update CDN.KsiDokNag Set KDN_DekId = Null Where KDN_DekID = @DeNId
   end
   if exists(select * from CDN.KsiDokNag Where KDN_PreDekId  = @DeNId)
    Update CDN.KsiDokNag Set KDN_PreDekId = Null Where KDN_PreDekId = @DeNId
  End
  If @Zrodlo = 50 -- kompensata
  Begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.KompensatyNag Where KPN_DekID = @DeNId and KPN_PreDekID IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select KPN_PreDekID from CDN.KompensatyNag where KPN_DekID = @DeNId)
    if exists(select * from CDN.KompensatyNag Where KPN_DekID = @DeNId)
     Update CDN.KompensatyNag Set KPN_DekID = Null, KPN_PreDekID = Null Where KPN_DekID  = @DeNId
   end
   else
   begin
    if exists(select * from CDN.KompensatyNag Where KPN_DekID = @DeNId)
     Update CDN.KompensatyNag Set KPN_DekID = Null Where KPN_DekID = @DeNId
   end
   if exists(select * from CDN.KompensatyNag Where KPN_PreDekID  = @DeNId)
    Update CDN.KompensatyNag Set KPN_PreDekID = Null Where KPN_PreDekID = @DeNId
  End
  If @Zrodlo = 108 -- delegacja
  Begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.DlgNag Where DLN_DekID = @DeNId and DLN_PreDekID IS NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select DLN_PreDekID from CDN.DlgNag where DLN_DekID = @DeNId)
    if exists(select * from CDN.DlgNag Where DLN_DekID = @DeNId)
     Update CDN.DlgNag Set DLN_DekID = Null, DLN_PreDekID = Null Where DLN_DekID  = @DeNId
   end
   else
   begin
    if exists(select * from CDN.DlgNag Where DLN_DekID = @DeNId)
     Update CDN.DlgNag Set DLN_DekID = Null Where DLN_DekID = @DeNId
   end
   if exists(select * from CDN.DlgNag Where DLN_PreDekID  = @DeNId)
    Update CDN.DlgNag Set DLN_PreDekID = Null Where DLN_PreDekID = @DeNId
  End
  If @Zrodlo = 222 -- KB Ponaglenie zaplaty
  begin
   if @UsunPreDekret <> 0
   begin
    if exists(select * from CDN.BnkDokNag Where BDN_DekID = @DeNId and BDN_PreDekID is NOT NULL)
     delete from cdn.DekretyNag where DeN_DeNId in (select BDN_DekID from CDN.BnkDokNag where BDN_DekID = @DeNId)
    if exists(select * from CDN.BnkDokNag Where BDN_DekID = @DeNId)
     Update CDN.BnkDokNag Set BDN_DekID = Null, BDN_PreDekID = Null Where BDN_DekID = @DeNId
   end
   else
   begin
    if exists(select * from CDN.BnkDokNag Where BDN_DekID = @DeNId)
     Update CDN.BnkDokNag Set BDN_DekID = Null Where BDN_DekID = @DeNId
   end
   if exists(select * from CDN.BnkDokNag Where BDN_PreDekID = @DeNId)
    Update CDN.BnkDokNag Set BDN_PreDekID = Null Where BDN_PreDekID = @DeNId
  end
 End
 Close Skasowane
 Deallocate Skasowane
 -- opis analityczny
 DECLARE @WADokumentTyp int = 0;
 select @WADokumentTyp=id from CDN.ListaDokumentowWymiarowanych() where nazwa='Polecenie księgowania';
 if exists(select WyW_WyWID from CDN.WymiaryWartosci join deleted D on (D.DeN_DeNId = WyW_DokumentId) where WyW_DokumentTyp = @WADokumentTyp)
  delete from CDN.WymiaryWartosci where WyW_WyWID in (select WyW_WyWID from CDN.WymiaryWartosci join deleted D on (D.DeN_DeNId = WyW_DokumentId) where WyW_DokumentTyp = @WADokumentTyp);
End
-- Skasowanie relacji do dokumentów z biblioteki  (RZ )
DELETE CDN.DokRelacje
FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1006 AND DoR_DokumentId=deleted.DeN_DeNId
Set NoCount Off

GO
CREATE TRIGGER CDN.DekretyNag_InsertUpdateHandler
  ON CDN.DekretyNag
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
    IF EXISTS (SELECT * FROM inserted WHERE inserted.DeN_WzorzecTyp=21)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.SchKsiNag ON
                    inserted.DeN_WzorzecId = CDN.SchKsiNag.SKN_SKNId
              WHERE CDN.SchKsiNag.SKN_SKNId IS NULL AND (inserted.DeN_WzorzecTyp=21)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=SchKsiNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
    IF EXISTS (SELECT * FROM inserted WHERE inserted.DeN_WzorzecTyp=22)
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.OkresoweNag ON
                    inserted.DeN_WzorzecId = CDN.OkresoweNag.OkN_OkNId
              WHERE CDN.OkresoweNag.OkN_OkNId IS NULL AND (inserted.DeN_WzorzecTyp=22)
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=OkresoweNag##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
