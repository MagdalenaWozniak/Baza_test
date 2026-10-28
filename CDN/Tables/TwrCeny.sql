CREATE TABLE [CDN].[TwrCeny] (
    [TwC_TwCID]         INT             IDENTITY (1, 1) NOT NULL,
    [TwC_TwrID]         INT             NOT NULL,
    [TwC_TwCNumer]      INT             NOT NULL,
    [TwC_Typ]           TINYINT         NOT NULL,
    [TwC_Wartosc]       DECIMAL (17, 4) NOT NULL,
    [TwC_Waluta]        VARCHAR (3)     NOT NULL,
    [TwC_Aktualizacja]  TINYINT         NOT NULL,
    [TwC_Zaokraglenie]  DECIMAL (7, 4)  NOT NULL,
    [TwC_Marza]         DECIMAL (7, 2)  NOT NULL,
    [TwC_MarzaWStu]     DECIMAL (7, 2)  NOT NULL,
    [TwC_Offset]        DECIMAL (7, 4)  NOT NULL,
    [TwC_TwrTyp]        SMALLINT        NULL,
    [TwC_TwrFirma]      INT             NULL,
    [TwC_TwrNumer]      INT             NULL,
    [TwC_TwrLp]         SMALLINT        NULL,
    [TwC_DokID]         INT             CONSTRAINT [DF_TwC_DokID] DEFAULT ((0)) NOT NULL,
    [TwC_WartoscZakOld] DECIMAL (17, 4) CONSTRAINT [DF_TwC_WartoscZakOld] DEFAULT ((0)) NOT NULL,
    [TwC_Punkty]        INT             CONSTRAINT [DF_TwC_Punkty] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [TwC_Primary] PRIMARY KEY CLUSTERED ([TwC_TwCID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwCTowar] FOREIGN KEY ([TwC_TwrID]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwCTowar]
    ON [CDN].[TwrCeny]([TwC_TwrID] ASC, [TwC_TwCNumer] ASC)
    INCLUDE([TwC_Wartosc], [TwC_Waluta]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwCTwrGID]
    ON [CDN].[TwrCeny]([TwC_TwrTyp] ASC, [TwC_TwrFirma] ASC, [TwC_TwrNumer] ASC, [TwC_TwrLp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TwrCeny_InsertUpdate_Trigger
ON CDN.TwrCeny
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  If Not Exists (Select * From deleted)
    Update CDN.TwrCeny Set
    TwC_Wartosc = Twr_KosztUslugiWal, TwC_Waluta  = Twr_Waluta
    From CDN.TwrCeny
    Join inserted On inserted.TwC_TwCId = CDN.TwrCeny.TwC_TwCId
    Join CDN.Towary On inserted.TwC_TwrId = Twr_TwrId
    Where Twr_Typ = 0 And Twr_KosztUslugiTyp = 1
    And (inserted.TwC_Wartosc <> Twr_KosztUslugiWal Or inserted.TwC_Waluta <> Twr_Waluta)
    And inserted.TwC_TwCNumer = 1
-- Uuzpełnienie tabeli przecen
  Declare @TwrID Int, @TwCNumer Int, @Wartosc Decimal(17,4), @Waluta NVarchar(3), @Data DateTime, @WartoscP Decimal(17,4), @WalutaP NVarchar(3), @DataP DateTime
  Declare Dodane Cursor Local Fast_Forward For
   Select TwC_TwrID, TwC_TwCNumer, TwC_Wartosc, TwC_Waluta From inserted
  Open Dodane
  While 1=1
   Begin
    Fetch Next From Dodane InTo @TwrID, @TwCNumer, @Wartosc, @Waluta
    If @@Fetch_Status <> 0 Break
    If Exists (Select * From CDN.TwrPrzeceny Where TPC_TwrId=@TwrId And TPC_TwCNumer=@TwCNumer)
     Begin
      Set @Data = Convert (DateTime, Convert(Char(10), GetDate(), 120), 120)
      Select Top 1 @WartoscP = TPC_Wartosc, @WalutaP = TPC_Waluta, @DataP = TPC_Data
       From CDN.TwrPrzeceny
       Where TPC_TwrId = @TwrId And TPC_TwCNumer = @TwCNumer And TPC_Data <= @Data
       Order By TPC_TwrId, TPC_TwCNumer, TPC_Data DESC
      If @Wartosc = @WartoscP And @Waluta = @WalutaP Continue
      If @DataP = @Data
       Update CDN.TwrPrzeceny Set TPC_Wartosc = @Wartosc, TPC_Waluta = @Waluta
         Where TPC_TwrId = @TwrId And TPC_TwCNumer = @TwCNumer And TPC_Data = @Data
      Else
       Insert InTo CDN.TwrPrzeceny (TPC_TwrID, TPC_TwCNumer, TPC_Data, TPC_Wartosc, TPC_Waluta)
                            Values (@TwrId,    @TwCNumer,    @Data,    @Wartosc,    @Waluta   )
     End
    Else
     Insert InTo CDN.TwrPrzeceny (
      TPC_TwrID,
      TPC_TwCNumer,
      TPC_Data,
      TPC_Wartosc,
      TPC_Waluta
     )
     Values (
      @TwrId,
      @TwCNumer,
      Convert(DateTime, '1900-01-01', 120),
      @Wartosc,
      @Waluta
     )
   End
  Close Dodane
  Deallocate Dodane
  update cdn.towary set twr_ts_mod = getdate() where twr_twrid in ( select distinct twc_twrid From inserted)
    -- modyfikujemy zestawy zeby poszły do esklep jak sie ceny zmienia
  update CDN.ZestawyTwr set ZTw_TS_Mod = getdate() where ZTw_TwrId in ( select distinct twc_twrid From inserted)
  update Zestawy set ZTw_TS_Mod = getdate()from CDN.ZestawyTwr Zestawy join cdn.ZestawyTwrSkladniki on ZTw_ZTwId = zts_ztwid where ZTs_TwrId in ( select distinct twc_twrid From inserted)
  SET NOCOUNT OFF
