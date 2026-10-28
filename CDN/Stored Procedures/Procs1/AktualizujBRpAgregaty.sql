CREATE PROCEDURE cdn.AktualizujBRpAgregaty @BRp_BRpId INT
AS
  SET NOCOUNT ON
  DECLARE
    @BRp_BRaId      INT,        -- rejestr aktualnego raportu
    @BRp_DataDok    DATETIME,   -- data aktualnego raportu
    @BRp_BRpId_Old  INT         -- Id poprzedniego zamkniętego raportu
  SELECT
    @BRp_BRaId   = BRp_BRaId,
    @BRp_DataDok = BRp_DataDok
  FROM cdn.BnkRaporty
  WHERE BRp_BRpId = @BRp_BRpId
  -- Id ostatniego zamkniętego raportu przed aktualnie zamykanym
  SELECT
    @BRp_BRpId_Old  = BRp_BRpId
  FROM cdn.BnkRaporty
  WHERE BRp_DataDok < @BRp_DataDok
    AND BRp_BRaId   = @BRp_BRaId
    AND BRp_Zamkniety = 1
  DELETE FROM CDN.BRpAgregaty WHERE BAg_BRpId = @BRp_BRpId
  -- kopia poprzedniego zestawu wpisów do BRpAgregaty i uzupelnienie o agregaty zapisów KB
  INSERT INTO CDN.BRpAgregaty (     BAg_BRpId,  BAg_Typ,     BAg_SaldoBOSys,      BAg_PrzychodySys,      BAg_RozchodySys )
    SELECT                      MAX(BAg_BRpId), BAg_Typ, SUM(BAg_SaldoBOSys), SUM(BAg_PrzychodySys), SUM(BAg_RozchodySys)
      FROM ( SELECT
               BAg_BRpId        = @BRp_BRpId,
               BAg_Typ          =  BAg_Typ,
               BAg_SaldoBOSys   =  ISNULL(BAg_SaldoBOSys,0) + ISNULL(BAg_PrzychodySys,0) - ISNULL(BAg_RozchodySys,0),
               BAg_PrzychodySys =  0,
               BAg_RozchodySys  =  0
             FROM CDN.BRpAgregaty
             WHERE BAg_BRpId = @BRp_BRpId_Old
             UNION ALL
             SELECT
               BAg_BRpId        = @BRp_BRpId,
               BAg_Typ          =  BZp_Typ,
               BAg_SaldoBOSys   =  0,
               BAg_PrzychodySys =  0,
               BAg_RozchodySys  =  0
             FROM CDN.BnkZapisy
             WHERE BZp_BRpId = @BRp_BRpId
             GROUP BY BZp_Typ
           ) AS BAg
      GROUP BY BAg_Typ
  -- update Przychody/Rozchody na podstawie BnkZapisy
  UPDATE cdn.BRpAgregaty SET
    BAg_PrzychodySys = BZp_PrzychodySys,
    BAg_RozchodySys  = BZp_RozchodySys
  FROM ( SELECT
           BZp_Typ          = BZp_Typ,
           BZp_PrzychodySys = SUM(ISNULL(CASE BZP_Kierunek WHEN 1 THEN BZp_KwotaSys ELSE 0            END,0)),
           BZp_RozchodySys  = SUM(ISNULL(CASE BZP_Kierunek WHEN 1 THEN 0            ELSE BZp_KwotaSys END,0))
         FROM cdn.BnkZapisy
         WHERE BZp_BRpId = @BRp_BRpId
         GROUP BY BZp_Typ
       ) AS BZp
  JOIN cdn.BRpAgregaty ON BZp_Typ = BAg_Typ
  WHERE BAg_BRpId = @BRp_BRpId
  SET NOCOUNT OFF
