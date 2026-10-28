CREATE TABLE [CDN].[TraSElem] (
    [TrS_TrSID]        INT             IDENTITY (1, 1) NOT NULL,
    [TrS_TrEId]        INT             NOT NULL,
    [TrS_TrSIdDost]    INT             NULL,
    [TrS_WyborDostaw]  TINYINT         CONSTRAINT [DF_TrS_WyborDostaw] DEFAULT ((0)) NULL,
    [TrS_TrEIdWydania] INT             CONSTRAINT [DF_TrS_TrEIdWydania] DEFAULT ((0)) NULL,
    [TrS_ZwrId]        INT             NULL,
    [TrS_TwrId]        INT             NOT NULL,
    [TrS_MagId]        INT             NOT NULL,
    [TrS_Rodzaj]       INT             NOT NULL,
    [TrS_Typ]          TINYINT         NOT NULL,
    [TrS_Metoda]       TINYINT         NOT NULL,
    [TrS_DataOpe]      DATETIME        NOT NULL,
    [TrS_Ilosc]        DECIMAL (15, 4) NOT NULL,
    [TrS_Wartosc]      DECIMAL (15, 2) NOT NULL,
    [TrS_Cena]         DECIMAL (17, 4) NOT NULL,
    CONSTRAINT [TrS_Primary] PRIMARY KEY CLUSTERED ([TrS_TrSID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TrSDostawa] FOREIGN KEY ([TrS_TrSIdDost]) REFERENCES [CDN].[TraSElem] ([TrS_TrSID]),
    CONSTRAINT [FK_TrSTowar] FOREIGN KEY ([TrS_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId])
);


GO
CREATE NONCLUSTERED INDEX [TrSTrEIdWydania]
    ON [CDN].[TraSElem]([TrS_TrEIdWydania] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrSZwrot]
    ON [CDN].[TraSElem]([TrS_ZwrId] ASC, [TrS_TrSID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrSTraElem]
    ON [CDN].[TraSElem]([TrS_TrEId] ASC, [TrS_TrSID] ASC)
    INCLUDE([TrS_Rodzaj], [TrS_Ilosc], [TrS_Wartosc], [TrS_ZwrId]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrSTowar]
    ON [CDN].[TraSElem]([TrS_TwrId] ASC, [TrS_MagId] ASC, [TrS_DataOpe] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrSDostawa]
    ON [CDN].[TraSElem]([TrS_TrSIdDost] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TraSElem_InsertUpdateDelete_Trigger
  ON cdn.TraSElem
  FOR INSERT, UPDATE, DELETE
AS
  DECLARE
    -- zmienne pomocnicze dla kursora
    @TrS_TrSId      INT,
    @TrS_TrEId      INT,
    @TrS_TrSIdDost  INT,
    @TrS_ZwrId      INT,
    @TrS_TwrId      INT,
    @TrS_MagId      INT,
    @TrS_Rodzaj     INT,
    @TrS_Typ        INT,
    @TrS_Metoda     INT,
    @TrS_DataOpe    DATETIME,
    @TrS_Ilosc      DECIMAL(15,4),
    @TrS_Wartosc    DECIMAL(15,2),
    @TrS_Cena       DECIMAL(17,4)
  SET NOCOUNT ON
 IF  UPDATE( TrS_WyborDostaw )
 AND NOT UPDATE( TrS_TrEId)
 AND NOT UPDATE( TrS_TrSIdDost)
 AND NOT UPDATE( TrS_TrEIdWydania)
 AND NOT UPDATE( TrS_ZwrId)
 AND NOT UPDATE( TrS_TwrId)
 AND NOT UPDATE( TrS_MagId)
 AND NOT UPDATE( TrS_Rodzaj)
 AND NOT UPDATE( TrS_Typ)
 AND NOT UPDATE( TrS_Metoda)
 AND NOT UPDATE( TrS_DataOpe)
 AND NOT UPDATE( TrS_Ilosc)
 AND NOT UPDATE( TrS_Wartosc)
 AND NOT UPDATE( TrS_Cena)
 return
  -- subelementy kasowane
  DECLARE Kasowane CURSOR LOCAL FAST_FORWARD FOR
    SELECT                             TrS_TrSId,  TrS_TrEId,  TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,  TrS_Ilosc,  TrS_Wartosc,  TrS_Cena
    FROM deleted
    ORDER BY TrS_Typ DESC, TrS_TrSId DESC
    OPEN Kasowane
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM Kasowane INTO @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena
        IF @@FETCH_STATUS <> 0 BREAK
          EXECUTE CDN.AktualizujTwrZasoby 2, @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena
      END
    CLOSE Kasowane
  DEALLOCATE Kasowane
  -- subelementy dodawane
  DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
    SELECT                             TrS_TrSId,  TrS_TrEId,  TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,  TrS_Ilosc,  TrS_Wartosc,  TrS_Cena
    FROM inserted
    ORDER BY TrS_Typ DESC, TrS_TrSId DESC
    OPEN Dodawane
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM Dodawane INTO @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena
        IF @@FETCH_STATUS <> 0 BREAK
          EXECUTE CDN.AktualizujTwrZasoby 1, @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena
          --IF @TrS_Rodzaj in(308000,308011,309000)
          --   EXECUTE CDN.UstawStatusRezerwacji @TrS_TrEId
      END
    CLOSE Dodawane
  DEALLOCATE Dodawane
  SET NOCOUNT OFF
