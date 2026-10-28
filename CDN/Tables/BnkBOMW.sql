CREATE TABLE [CDN].[BnkBOMW] (
    [BOMW_BOMWID]         INT             IDENTITY (1, 1) NOT NULL,
    [BOMW_Kierunek]       SMALLINT        CONSTRAINT [DF_BOMW_Kierunek] DEFAULT ((1)) NOT NULL,
    [BOMW_BRaID]          INT             NULL,
    [BOMW_NumerNr]        INT             NOT NULL,
    [BOMW_NumerObcy]      NVARCHAR (256)  NOT NULL,
    [BOMW_KatID]          INT             NULL,
    [BOMW_DataDok]        DATETIME        NOT NULL,
    [BOMW_KwotaSys]       DECIMAL (15, 2) NOT NULL,
    [BOMW_KwotaRozSysMW]  DECIMAL (15, 2) NOT NULL,
    [BOMW_Kwota]          DECIMAL (15, 2) NOT NULL,
    [BOMW_KwotaRozMW]     DECIMAL (15, 2) NOT NULL,
    [BOMW_Waluta]         VARCHAR (3)     NOT NULL,
    [BOMW_KursNumer]      INT             NOT NULL,
    [BOMW_KursL]          DECIMAL (15, 4) NOT NULL,
    [BOMW_KursM]          DECIMAL (5)     NOT NULL,
    [BOMW_WgKursuMW]      TINYINT         NOT NULL,
    [BOMW_RozliczonoMW]   SMALLINT        NOT NULL,
    [BOMW_Rozliczono2MW]  SMALLINT        NOT NULL,
    [BOMW_DataRozMW]      DATETIME        NULL,
    [BOMW_DataKur]        DATETIME        NOT NULL,
    [BOMW_Opis]           NVARCHAR (254)  NOT NULL,
    [BOMW_OpeZalId]       INT             NULL,
    [BOMW_StaZalId]       INT             NULL,
    [BOMW_TS_Zal]         DATETIME        NOT NULL,
    [BOMW_OpeModId]       INT             NULL,
    [BOMW_StaModId]       INT             NULL,
    [BOMW_TS_Mod]         DATETIME        NOT NULL,
    [BOMW_NumerPelny]     AS              ([CDN].[NumerPelnyBOMW]([BOMW_BRAID],[BOMW_NUMERNR],[BOMW_KIERUNEK])),
    [BOMW_OpeModKod]      VARCHAR (20)    CONSTRAINT [DF_BOMW_OpeModKod] DEFAULT ('') NOT NULL,
    [BOMW_OpeModNazwisko] NVARCHAR (50)   CONSTRAINT [DF_BOMW_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BOMW_OpeZalKod]      VARCHAR (20)    CONSTRAINT [DF_BOMW_OpeZalKod] DEFAULT ('') NOT NULL,
    [BOMW_OpeZalNazwisko] NVARCHAR (50)   CONSTRAINT [DF_BOMW_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [BOMW_Numer]          AS              (case when [BOMW_NumerObcy]<>'' then [BOMW_NumerObcy] else [CDN].[NumerPelnyBOMW]([BOMW_BRaID],[BOMW_NumerNr],[BOMW_Kierunek]) end),
    CONSTRAINT [BOMW_Primary] PRIMARY KEY CLUSTERED ([BOMW_BOMWID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_BOMW_Kierunek] CHECK ([BOMW_Kierunek]=(1) OR [BOMW_Kierunek]=(-1)),
    CONSTRAINT [CK_BOMW_KwotaRozMW] CHECK ([BOMW_KWOTAROZMW]>=(0)),
    CONSTRAINT [CK_BOMW_KwotaRozSysMW] CHECK ([BOMW_KWOTAROZSYSMW]>=(0)),
    CONSTRAINT [FK_BOMWChron] FOREIGN KEY ([BOMW_BRaID]) REFERENCES [CDN].[BnkRachunki] ([BRa_BRaID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BOMWChron]
    ON [CDN].[BnkBOMW]([BOMW_BRaID] ASC, [BOMW_DataDok] ASC, [BOMW_BOMWID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BOMWNumeracja]
    ON [CDN].[BnkBOMW]([BOMW_BRaID] ASC, [BOMW_Kierunek] ASC, [BOMW_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BOMWKategoria]
    ON [CDN].[BnkBOMW]([BOMW_KatID] ASC, [BOMW_DataDok] ASC, [BOMW_BOMWID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BOMWRozliczono]
    ON [CDN].[BnkBOMW]([BOMW_RozliczonoMW] ASC, [BOMW_DataDok] ASC, [BOMW_BOMWID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BOMWRozliczono2]
    ON [CDN].[BnkBOMW]([BOMW_Rozliczono2MW] ASC, [BOMW_DataDok] ASC, [BOMW_BOMWID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkBOMW_InsertUpdateDelete_Trigger
  ON CDN.BnkBOMW
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
-- Sprawdzenie czy zapis nie jest rozliczony MW
  IF EXISTS (SELECT * FROM deleted WHERE BOMW_KwotaRozMW > 0 AND BOMW_Kwota>0 AND
             BOMW_BOMWID NOT IN (SELECT BOMW_BOMWID FROM inserted))
  BEGIN
    RAISERROR('##OPT32225##', 16, 1) -- RAISERROR('Nie można kasować bilansów otwarcia MW rozliczonych w Magazynie Walut.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
--Ustalenie flagi rozliczenia MW
  IF UPDATE(BOMW_RozliczonoMW) OR UPDATE(BOMW_Rozliczono2MW) OR UPDATE(BOMW_Kwota) OR UPDATE(BOMW_KwotaRozMW)
   BEGIN
    -- Zapis rozliczony całkowicie (BOMW_RozliczonoMW = 2)
        UPDATE CDN.BnkBOMW
           SET BOMW_RozliczonoMW = 2
         WHERE BOMW_BOMWID IN (SELECT BOMW_BOMWID FROM inserted WHERE BOMW_Kwota = BOMW_KwotaRozMW AND BOMW_RozliczonoMW = 1)
    -- Zapis nie rozliczony całkowicie (BOMW_RozliczonoMW = 1)
        UPDATE CDN.BnkBOMW
           SET BOMW_RozliczonoMW = 1
         WHERE BOMW_BOMWID IN (SELECT BOMW_BOMWID FROM inserted WHERE BOMW_Kwota <> BOMW_KwotaRozMW AND BOMW_RozliczonoMW = 2)
    -- Zapis rozliczony częściowo lub całkowicie (BOMW_Rozliczono2MW = 2)
        UPDATE CDN.BnkBOMW
           SET BOMW_Rozliczono2MW = 2
         WHERE BOMW_BOMWID IN (SELECT BOMW_BOMWID FROM inserted WHERE (BOMW_KwotaRozMW <> 0 OR BOMW_Kwota=0 AND BOMW_KwotaSys>0) AND BOMW_Rozliczono2MW <> 2 AND BOMW_RozliczonoMW <> 0)
    -- Zapis nie rozliczony w ogóle (BOMW_Rozliczono2MW = 1)
        UPDATE CDN.BnkBOMW
           SET BOMW_Rozliczono2MW = 1
         WHERE BOMW_BOMWID IN (SELECT BOMW_BOMWID FROM inserted WHERE BOMW_KwotaRozMW = 0 AND BOMW_Kwota>0 AND BOMW_Rozliczono2MW <> 1  AND BOMW_RozliczonoMW <> 0)
    END
  SET NOCOUNT OFF
