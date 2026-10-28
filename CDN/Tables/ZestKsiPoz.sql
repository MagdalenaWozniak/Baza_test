CREATE TABLE [CDN].[ZestKsiPoz] (
    [ZKP_ZKPId]        INT             IDENTITY (1, 1) NOT NULL,
    [ZKP_ZKNId]        INT             NOT NULL,
    [ZKP_ParId]        INT             NULL,
    [ZKP_Lp]           INT             NOT NULL,
    [ZKP_Nazwa]        NVARCHAR (255)  NOT NULL,
    [ZKP_Znak]         SMALLINT        NOT NULL,
    [ZKP_Definicja]    NVARCHAR (2000) NOT NULL,
    [ZKP_BrakKontroli] TINYINT         NOT NULL,
    [ZKP_Poziom]       SMALLINT        NOT NULL,
    [ZKP_Lisc]         TINYINT         NOT NULL,
    [ZKP_Numeracja]    NVARCHAR (4)    CONSTRAINT [DF_ZKP_NUMERACJA] DEFAULT ('AUTO') NOT NULL,
    [ZKP_SFId]         INT             NULL,
    [ZKP_Numer]        AS              ([CDN].[ZestKsiNumer]([ZKP_ZKPId])),
    [ZKP_Segment]      AS              ([CDN].[ZestKsiSegment]([ZKP_ZKPId])),
    CONSTRAINT [ZKP_Primary] PRIMARY KEY CLUSTERED ([ZKP_ZKPId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ZKPParrent] FOREIGN KEY ([ZKP_ParId]) REFERENCES [CDN].[ZestKsiPoz] ([ZKP_ZKPId]),
    CONSTRAINT [FK_ZKPZestawienie] FOREIGN KEY ([ZKP_ZKNId]) REFERENCES [CDN].[ZestKsiNag] ([ZKN_ZKNId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [ZKPZestawienie]
    ON [CDN].[ZestKsiPoz]([ZKP_ZKNId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ZKPParrent]
    ON [CDN].[ZestKsiPoz]([ZKP_ParId] ASC, [ZKP_Lp] ASC, [ZKP_ZKPId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.ZestKsiPoz_Delete_Trigger
  ON CDN.ZestKsiPoz
  FOR DELETE
AS
SET NOCOUNT ON
DECLARE @ZKPId       INT
DECLARE @ParId       INT
DECLARE @Lisc        SMALLINT
DECLARE @LiscTmp     SMALLINT
DECLARE @IsDefinicja SMALLINT
-- Kasowanie wyników
DELETE FROM CDN.ZestKsiWyniki WHERE ZKW_ZKPId IN (SELECT ZKP_ZKPId FROM deleted)
DECLARE Usuniete CURSOR LOCAL FAST_FORWARD FOR
 SELECT
  ZKP_ZKPId,
  ZKP_ParId
 FROM deleted
OPEN Usuniete
WHILE 1=1
 BEGIN
  FETCH NEXT FROM Usuniete INTO
                         @ZKPId,
                         @ParId
  IF @@FETCH_STATUS <> 0 BREAK
  -- Aktualizacja "ojca" który stał się liściem
  IF @ParId IS NOT NULL
    BEGIN
      IF EXISTS (SELECT * FROM CDN.ZestKsiPoz WHERE ZKP_ParId = @ZKPId)
       SET @LiscTmp = 0
      ELSE
       SET @LiscTmp = 1
      SELECT @Lisc = ZKP_Lisc, @IsDefinicja = CASE ZKP_Definicja WHEN '' THEN 0 ELSE 1 END
        FROM CDN.ZestKsiPoz WHERE ZKP_ZKPId = @ParId
      IF @Lisc <> @LiscTmp OR (@IsDefinicja = 1 AND @LiscTmp = 0)
        UPDATE CDN.ZestKsiPoz
          SET ZKP_Lisc = @LiscTmp, ZKP_Definicja = CASE @LiscTmp WHEN 0 THEN '' ELSE ZKP_Definicja END
          WHERE ZKP_ZKPId = @ParId
  END
 END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.ZestKsiPoz_InsertUpdate_Trigger
  ON CDN.ZestKsiPoz
  FOR INSERT, UPDATE
AS
SET NOCOUNT ON
DECLARE @ZKPId       INT
DECLARE @ParId       INT
DECLARE @ParTmpId    INT
DECLARE @Poziom      SMALLINT
DECLARE @PoziomTmp   SMALLINT
DECLARE @Lisc        SMALLINT
DECLARE @LiscTmp     SMALLINT
DECLARE @IsDefinicja SMALLINT
DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR
 SELECT
  ZKP_ZKPId,
  ZKP_ParId,
  ZKP_Poziom,
  ZKP_Lisc,
  CASE ZKP_Definicja WHEN '' THEN 0 ELSE 1 END
 FROM inserted
OPEN Dodane
WHILE 1=1
 BEGIN
  FETCH NEXT FROM Dodane INTO
                         @ZKPId,
                         @ParId,
                         @Poziom,
                         @Lisc,
                         @IsDefinicja
  IF @@FETCH_STATUS <> 0 BREAK
  -- Sprawdzenie i aktualizacja Poziom i Lisc
  SET @ParTmpId = @ParId
  SET @PoziomTmp = 1
  WHILE @ParTmpId IS NOT NULL
    BEGIN
      SELECT @ParTmpId = ZKP_ParId FROM CDN.ZestKsiPoz WHERE ZKP_ZKPId = @ParTmpId
      SET @PoziomTmp = @PoziomTmp + 1
    END
  IF EXISTS (SELECT * FROM CDN.ZestKsiPoz WHERE ZKP_ParId = @ZKPId) SET @LiscTmp = 0 ELSE SET @LiscTmp = 1
  --IF @Poziom <> @PoziomTmp OR @Lisc <> @LiscTmp OR (@IsDefinicja = 1 AND @LiscTmp = 0)
  IF @Poziom <> @PoziomTmp OR @Lisc <> @LiscTmp OR @LiscTmp = 0
    UPDATE CDN.ZestKsiPoz
 --SET ZKP_Poziom = @PoziomTmp, ZKP_Lisc = @LiscTmp, ZKP_Definicja = CASE @LiscTmp WHEN 0 THEN '' ELSE ZKP_Definicja END
    SET ZKP_Poziom = @PoziomTmp, ZKP_Lisc = @LiscTmp
    WHERE ZKP_ZKPId = @ZKPId
  -- Sprawdzenie i aktualizacja Lisc na koncie nadrzędnym
  IF EXISTS (SELECT * FROM CDN.ZestKsiPoz WHERE ZKP_ZKPId = @ParId AND (ZKP_Lisc = 1 OR ZKP_Definicja <> ''))
    --UPDATE CDN.ZestKsiPoz SET ZKP_Lisc = 0, ZKP_Definicja = '' WHERE ZKP_ZKPId = @ParId
 UPDATE CDN.ZestKsiPoz SET ZKP_Lisc = 0 WHERE ZKP_ZKPId = @ParId
 END
 SET NOCOUNT OFF
