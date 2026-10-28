CREATE TABLE [CDN].[BONag] (
    [BON_BONId]            INT             IDENTITY (1, 1) NOT NULL,
    [BON_OObId]            INT             NOT NULL,
    [BON_OObPrevId]        INT             NULL,
    [BON_Bufor]            TINYINT         NOT NULL,
    [BON_DataDok]          DATETIME        NOT NULL,
    [BON_DDfId]            INT             NOT NULL,
    [BON_NumerString]      VARCHAR (31)    NOT NULL,
    [BON_NumerNr]          INT             NOT NULL,
    [BON_NumerPelny]       AS              ([CDN].[FN_NUMERPELNY]([BON_NUMERNR],[BON_NUMERSTRING])),
    [BON_KatId]            INT             NULL,
    [BON_Kategoria]        VARCHAR (50)    NOT NULL,
    [BON_Korekta]          TINYINT         NOT NULL,
    [BON_BilansZamkniecia] TINYINT         NOT NULL,
    [BON_KwotaWN]          DECIMAL (15, 2) NOT NULL,
    [BON_KwotaMA]          DECIMAL (15, 2) NOT NULL,
    [BON_OpeZalID]         INT             NULL,
    [BON_StaZalId]         INT             NULL,
    [BON_TS_Zal]           DATETIME        NOT NULL,
    [BON_OpeModID]         INT             NULL,
    [BON_StaModId]         INT             NULL,
    [BON_TS_Mod]           DATETIME        NOT NULL,
    [BON_OpeModKod]        VARCHAR (20)    CONSTRAINT [DF_BON_OpeModKod] DEFAULT ('') NOT NULL,
    [BON_OpeModNazwisko]   NVARCHAR (50)   CONSTRAINT [DF_BON_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BON_OpeZalKod]        VARCHAR (20)    CONSTRAINT [DF_BON_OpeZalKod] DEFAULT ('') NOT NULL,
    [BON_OpeZalNazwisko]   NVARCHAR (50)   CONSTRAINT [DF_BON_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [BON_Primary] PRIMARY KEY CLUSTERED ([BON_BONId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BONDokDef] FOREIGN KEY ([BON_DDfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_BONKategorie] FOREIGN KEY ([BON_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_BONOkres] FOREIGN KEY ([BON_OObId]) REFERENCES [CDN].[OkresyObrach] ([OOb_OObID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BONOkres]
    ON [CDN].[BONag]([BON_OObId] ASC, [BON_NumerPelny] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BONDokDef]
    ON [CDN].[BONag]([BON_DDfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BONKategorie]
    ON [CDN].[BONag]([BON_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BONOkresPrev]
    ON [CDN].[BONag]([BON_OObPrevId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BONNumer]
    ON [CDN].[BONag]([BON_NumerString] ASC, [BON_NumerNr] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BONag_Update_Trigger
  ON CDN.BONag
  FOR UPDATE
AS
SET NOCOUNT ON
IF UPDATE(BON_Bufor) OR UPDATE (BON_BilansZamkniecia) OR UPDATE (BON_NumerString) OR UPDATE (BON_NumerNr)
BEGIN
  DECLARE @NumerNr    INT
  DECLARE @NumerPelny NVarchar(30)
  DECLARE @DelBufor   SMALLINT
  DECLARE @InsBufor   SMALLINT
  DECLARE @DelKorekta SMALLINT
  DECLARE @InsKorekta SMALLINT
  DECLARE @AccId      INT
  DECLARE @AccPrevId  INT
  DECLARE @KwotaWn    NUMERIC(15,2)
  DECLARE @KwotaMa    NUMERIC(15,2)
  DECLARE @KwotaWnWal NUMERIC(15,2)
  DECLARE @KwotaMaWal NUMERIC(15,2)
  DECLARE @BOEID      INT
  DECLARE @Opis       NVarchar(50)
  DECLARE Elementy CURSOR LOCAL FAST_FORWARD FOR
   SELECT BOE_BOEID, inserted.BON_Kategoria, inserted.BON_NumerNr, inserted.BON_NumerPelny, inserted.BON_Bufor, deleted.BON_Bufor, inserted.BON_BilansZamkniecia, deleted.BON_BilansZamkniecia, BOE_AccId, BOE_AccPrevId, BOE_KwotaWn, BOE_KwotaMa, BOE_KwotaWnWal, BOE_KwotaMaWal
   FROM CDN.BOElem JOIN inserted ON inserted.BON_BONId = CDN.BOElem.BOE_BONId
                   JOIN deleted  ON deleted.BON_BONId  = inserted.BON_BONId
   WHERE    inserted.BON_Bufor              <> deleted.BON_Bufor
        OR  inserted.BON_BilansZamkniecia   <> deleted.BON_BilansZamkniecia
        OR  inserted.BON_BilansZamkniecia   <> deleted.BON_BilansZamkniecia
        OR  inserted.BON_NumerPelny         <> deleted.BON_NumerPelny
        OR  inserted.BON_NumerNr            <> deleted.BON_NumerNr
        OR  inserted.BON_kategoria          <> deleted.BON_kategoria
  OPEN Elementy
  WHILE 1 = 1
  BEGIN
    FETCH NEXT FROM Elementy INTO @BOEID, @Opis, @NumerNr, @NumerPelny, @InsBufor, @DelBufor, @InsKorekta, @DelKorekta, @AccId, @AccPrevId, @KwotaWn, @KwotaMa, @KwotaWnWal, @KwotaMaWal
    IF @@FETCH_STATUS <> 0 BREAK
    -- Aktualizacja daty i bufora w rozrachunkach i numeru dokumentu
        update CDN.KsiRozrachunki
        set KRo_Bufor       = @InsBufor,
            KRo_NrDziennika = @NumerPelny,
            KRo_NrKsiegi = @NumerPelny,
            KRo_IdentKsieg = @NumerPelny,
            KRo_Opis        = @Opis
        where CDN.KsiRozrachunki.KRo_BOEID = @BOEID
        update CDN.KsiRozrachunki
        set KRo_Dokument = @NumerPelny
        from
        CDN.KsiRozrachunki
        inner join CDN.BOElem on (KRo_Typ = 2 and KRo_BOEID = BOE_BOEID)
        where
        KRo_BOEID = @BOEID and BOE_Dokument = ''
    -- Aktualizacja w bieżącym okresie
    IF @DelBufor <> @InsBufor
      UPDATE CDN.Obroty
        SET
          Obr_ObrotyWn      = Obr_ObrotyWn    + (CASE WHEN @DelBufor = 0 THEN -@KwotaWn    WHEN @InsBufor = 0 THEN @KwotaWn    ELSE 0 END),
          Obr_ObrotyMa      = Obr_ObrotyMa    + (CASE WHEN @DelBufor = 0 THEN -@KwotaMa    WHEN @InsBufor = 0 THEN @KwotaMa    ELSE 0 END),
          Obr_ObrotyWnWal   = Obr_ObrotyWnWal + (CASE WHEN @DelBufor = 0 THEN -@KwotaWnWal WHEN @InsBufor = 0 THEN @KwotaWnWal ELSE 0 END),
          Obr_ObrotyMaWal   = Obr_ObrotyMaWal + (CASE WHEN @DelBufor = 0 THEN -@KwotaMaWal WHEN @InsBufor = 0 THEN @KwotaMaWal ELSE 0 END)
        WHERE Obr_RokMies IS NULL AND Obr_Typ = 1 AND Obr_AccId = @AccId
     -- Aktualizacja w poprzednim okresie
    IF @DelKorekta = 1 AND @AccPrevId IS NOT NULL
      UPDATE CDN.Obroty
        SET
          Obr_ObrotyWnBufor    = Obr_ObrotyWnBufor    - @KwotaWn,
          Obr_ObrotyMaBufor    = Obr_ObrotyMaBufor    - @KwotaMa,
          Obr_ObrotyWn         = Obr_ObrotyWn         - (CASE WHEN @DelBufor = 0 THEN @KwotaWn ELSE 0 END),
          Obr_ObrotyMa         = Obr_ObrotyMa         - (CASE WHEN @DelBufor = 0 THEN @KwotaMa ELSE 0 END),
          Obr_ObrotyWnBuforWal = Obr_ObrotyWnBuforWal - @KwotaWnWal,
          Obr_ObrotyMaBuforWal = Obr_ObrotyMaBuforWal - @KwotaMaWal,
          Obr_ObrotyWnWal      = Obr_ObrotyWnWal      - (CASE WHEN @DelBufor = 0 THEN @KwotaWnWal ELSE 0 END),
          Obr_ObrotyMaWal      = Obr_ObrotyMaWal      - (CASE WHEN @DelBufor = 0 THEN @KwotaMaWal ELSE 0 END)
        WHERE Obr_RokMies IS NULL AND Obr_Typ = 2 AND Obr_AccId = @AccPrevId
    IF @InsKorekta = 1 AND @AccPrevId IS NOT NULL
    BEGIN
      IF NOT EXISTS (SELECT * FROM CDN.Obroty WHERE Obr_RokMies IS NULL AND Obr_Typ = 2 AND Obr_AccId = @AccPrevId)
        INSERT INTO CDN.Obroty (Obr_AccId,  Obr_RokMies, Obr_Typ, Obr_ObrotyWn, Obr_ObrotyMa, Obr_ObrotyWnBufor, Obr_ObrotyMaBufor, Obr_ObrotyWnWal, Obr_ObrotyMaWal, Obr_ObrotyWnBuforWal, Obr_ObrotyMaBuforWal)
                        VALUES (@AccPrevId, Null,        2,       0,            0,            0,                 0,                 0,               0,               0,                    0)
      UPDATE CDN.Obroty
        SET
          Obr_ObrotyWnBufor    = Obr_ObrotyWnBufor    + @KwotaWn,
          Obr_ObrotyMaBufor    = Obr_ObrotyMaBufor    + @KwotaMa,
          Obr_ObrotyWn         = Obr_ObrotyWn         + (CASE WHEN @InsBufor = 0 THEN @KwotaWn ELSE 0 END),
          Obr_ObrotyMa         = Obr_ObrotyMa         + (CASE WHEN @InsBufor = 0 THEN @KwotaMa ELSE 0 END),
          Obr_ObrotyWnBuforWal = Obr_ObrotyWnBuforWal + @KwotaWnWal,
          Obr_ObrotyMaBuforWal = Obr_ObrotyMaBuforWal + @KwotaMaWal,
          Obr_ObrotyWnWal      = Obr_ObrotyWnWal      + (CASE WHEN @InsBufor = 0 THEN @KwotaWnWal ELSE 0 END),
          Obr_ObrotyMaWal      = Obr_ObrotyMaWal      + (CASE WHEN @InsBufor = 0 THEN @KwotaMaWal ELSE 0 END)
        WHERE Obr_RokMies IS NULL AND Obr_Typ = 2 AND Obr_AccId = @AccPrevId
    END
  END
END
SET NOCOUNT OFF
