CREATE  PROCEDURE [CDN].[DetalStan_AktualizujTowary]
 @StanDetalID int,
 @OptimaId int,
 @Kod nvarchar(50),
 @NumerKat nvarchar(40),
 @SWW nvarchar(20),
 @EAN nvarchar(40),
 @Nazwa nvarchar(255),
 @Opis nvarchar(254),
 @JM nvarchar(20),
 @JMCalkowite tinyint,
 @Kaucja tinyint,
 @Cena decimal(17, 4),
 @Waluta nvarchar(3),
 @SONId int,
 @Stawka decimal(5, 2),
    @Flaga smallint,
    @KntId int,
    @NieAktywny tinyint,
    @Typ tinyint,
    @DateTSSynchr datetime,
    @DateTSSynchrNew datetime
AS
SET NOCOUNT ON
DECLARE
    @DST_Id INT
  SELECT @DST_Id = DSTwr_DSTwrId
    FROM CDN.DetalStanTowary
    WHERE DSTwr_OptimaId = @OptimaId and DSTwr_StanDetalID = @StanDetalID
  IF @DST_Id IS NULL
    BEGIN
       IF @NieAktywny = 0
       INSERT INTO CDN.DetalStanTowary (DSTwr_StanDetalID,
                                        DSTwr_OptimaId,
          DSTwr_Kod,
          DSTwr_NumerKat,
          DSTwr_SWW,
          DSTwr_EAN,
          DSTwr_Nazwa,
          DSTwr_Opis,
          DSTwr_JM,
          DSTwr_JMCalkowite,
          DSTwr_Kaucja,
          DSTwr_Cena,
          DSTwr_Waluta,
          DSTwr_SONId,
          DSTwr_Stawka,
          DSTwr_Flaga,
          DSTwr_NieAktywny,
                                        DSTwr_Typ,
          DSTwr_KntId,
          DSTwr_TS_Mod
                                        )
  VALUES (
                @StanDetalID,
                @OptimaId,
    @Kod,
    @NumerKat,
    @SWW,
    @EAN,
    @Nazwa,
    @Opis,
    @JM,
    @JMCalkowite,
    @Kaucja,
    @Cena,
    @Waluta,
    ISNULL(@SONId,0),
    @Stawka,
    @Flaga,
    @NieAktywny,
                @Typ,
                @KntId,
                @DateTSSynchrNew)
    SELECT @DST_Id = DSTwr_DSTwrId
    FROM CDN.DetalStanTowary
    WHERE DSTwr_OptimaId = @OptimaId and DSTwr_StanDetalID = @StanDetalID
    END
  ELSE
 BEGIN
     UPDATE  CDN.DetalStanTowary
   SET  DSTwr_Kod =@Kod,
   DSTwr_NumerKat =@NumerKat,
   DSTwr_SWW =@SWW,
   DSTwr_EAN =@EAN,
   DSTwr_Nazwa =@Nazwa,
   DSTwr_Opis =@Opis,
   DSTwr_JM =@JM,
   DSTwr_JMCalkowite =@JMCalkowite,
   DSTwr_Kaucja =@Kaucja,
   DSTwr_Cena =@Cena,
   DSTwr_Waluta = @Waluta,
   DSTwr_SONId =ISNULL(@SONId,0),
   DSTwr_Stawka =@Stawka,
   DSTwr_Flaga =@Flaga,
   DSTwr_NieAktywny =@NieAktywny,
            DSTwr_Typ = @Typ,
            DSTwr_KntId = @KntId,
            DSTwr_TS_Mod = @DateTSSynchrNew
  WHERE (@DST_Id = DSTwr_DSTwrId)
      END
 IF @DST_Id IS NOT NULL
 BEGIN
--usunięcie nieużywanych jm
 DELETE t
 FROM [CDN].[DetalStanTwrJMZ] t
 left join [CDN].[TwrJMZ] ON [TwJZ_TwrID] = @OptimaId and [TwJZ_eSklepID] = 0 and [DSTJZ_DSTwrId] = @DST_Id and [TwJZ_JM] = [DSTJZ_JM]
 WHERE [DSTJZ_DSTwrId] = @DST_Id and [TwJZ_TwrID] is null
--aktualizacja jm
 UPDATE  CDN.DetalStanTwrJMZ
 SET
  DSTJZ_JMPrzelicznikL =TwJZ_JMPrzelicznikL,
  DSTJZ_JMPrzelicznikM =TwJZ_JMPrzelicznikM
 FROM  CDN.DetalStanTwrJMZ DetalJMZ
 INNER JOIN CDN.TwrJMZ OptimaJMZ
 ON
  OptimaJMZ.TwJZ_TwrID = @OptimaId and OptimaJMZ.TwJZ_eSklepID = 0
  and DetalJMZ.DSTJZ_DSTwrId = @DST_Id
  and OptimaJMZ.TwJZ_JM = DetalJMZ.DSTJZ_JM
--dodanie nowych jm
 INSERT INTO CDN.DetalStanTwrJMZ
  (DSTJZ_DSTwrId,
  DSTJZ_JM,
  DSTJZ_JMPrzelicznikL,
  DSTJZ_JMPrzelicznikM
  )
 SELECT
  @DST_Id,
  TwJZ_JM,
  TwJZ_JMPrzelicznikL,
  TwJZ_JMPrzelicznikM
 FROM [CDN].[TwrJMZ]
 left join [CDN].[DetalStanTwrJMZ] ON [TwJZ_TwrID] = @OptimaId and [TwJZ_eSklepID] = 0 and [DSTJZ_DSTwrId] = @DST_Id and [TwJZ_JM] = [DSTJZ_JM]
 WHERE [TwJZ_TwrID] = @OptimaId and [TwJZ_eSklepID] = 0 and [DSTJZ_DSTwrId] is null
 --usunięcie nieużywanych EAN
 DELETE t
 FROM [CDN].[DetalStanTwrEan] t
 left join [CDN].[TwrEAN] ON [TwE_TwrID] = @OptimaId and [DSTwE_DSTwrId] = @DST_Id and [DSTwE_EAN] = [TwE_EAN]
 WHERE [DSTwE_DSTwrId] = @DST_Id and [TwE_TwrID] is null
--aktualizacja EAN
 UPDATE  CDN.DetalStanTwrEan
 SET
  DSTwE_Opis =TwE_Opis,
  DSTwE_Domyslny =TwE_Domyslny,
  DSTwE_JM = TwE_JM
 FROM  CDN.DetalStanTwrEan DetalEAN
 INNER JOIN CDN.TwrEAN OptimaEAN
 ON
  OptimaEAN.TwE_TwrID = @OptimaId
  and DetalEAN.DSTwE_DSTwrId = @DST_Id
  and OptimaEAN.TwE_EAN = DetalEAN.DSTwE_EAN
--dodanie nowych EAN
 INSERT INTO CDN.DetalStanTwrEan
  (DSTwE_DSTwrId,
  DSTwE_EAN,
  DSTwE_Opis,
  DSTwE_Domyslny,
  DSTwE_JM
  )
 SELECT
  @DST_Id,
  TwE_EAN,
  TwE_Opis,
  TwE_Domyslny,
  TwE_JM
 FROM [CDN].[TwrEAN]
 left join [CDN].[DetalStanTwrEan] ON [TwE_TwrID] = @OptimaId and [DSTwE_DSTwrId] = @DST_Id and [DSTwE_EAN] = [TwE_EAN]
 WHERE [TwE_TwrID] = @OptimaId and [DSTwE_DSTwrId] is null
END
  SET NOCOUNT OFF
