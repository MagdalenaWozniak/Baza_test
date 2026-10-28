CREATE PROCEDURE [CDN].[PrzeliczAgregatyBRpRejestru]
@RejestrID INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRANSACTION
  ALTER TABLE CDN.BnkRaporty Disable TRIGGER ALL
  DECLARE @BRp_Zamkniety_Prev       INT
  DECLARE @BRa_Saldo                DECIMAL (15,2)
  DECLARE @BRa_SaldoSys             DECIMAL (15,2)
  DECLARE @BRp_BRpID                INT
  DECLARE @BRp_DataDok              DATETIME
  DECLARE @BRa_Waluta               VARCHAR(3)
  DECLARE @BRp_Zamkniety            INT
  DECLARE @BRa_StanPoczatkowy       DECIMAL (15,2)
  DECLARE @BRa_StanPoczatkowySys    DECIMAL (15,2)
  DECLARE @PrzychodyCalc            DECIMAL (15,2)
  DECLARE @RozchodyCalc             DECIMAL (15,2)
  DECLARE @PrzychodyCalcSys         DECIMAL (15,2)
  DECLARE @RozchodyCalcSys          DECIMAL (15,2)
  DECLARE @RoznicaKursowaSysMWCalc  DECIMAL (15,2)
  SET @BRp_Zamkniety_Prev = NULL
  SET @BRa_Saldo          = 0
  SET @BRa_SaldoSys       = 0
  DECLARE cur_BnkRaporty CURSOR LOCAL FAST_FORWARD FOR
  SELECT
    BRp_BRpID, BRp_DataDok, BRa_Waluta, BRp_Zamkniety,
    BRa_SaldoBO     as BRa_StanPoczatkowy,
    BRa_SaldoBOSys  as BRa_StanPoczatkowySys,
    ISNULL(SUM(CASE ISNULL(BZp_Kierunek, 0) WHEN 1  THEN 1 ELSE 0 END *
      CASE BRa_Waluta WHEN '' THEN ISNULL(BZp_KwotaSys, 0) ELSE ISNULL(BZp_Kwota, 0) END), 0)   AS PrzychodyCalc,
    ISNULL(SUM(CASE ISNULL(BZp_Kierunek, 0) WHEN -1 THEN 1 ELSE 0 END *
      CASE BRa_Waluta WHEN '' THEN ISNULL(BZp_KwotaSys, 0) ELSE ISNULL(BZp_Kwota, 0) End), 0)   AS RozchodyCalc,
    ISNULL(SUM(CASE ISNULL(BZp_Kierunek, 0) WHEN 1  THEN 1 ELSE 0 END * ISNULL(BZp_KwotaSys,0)), 0) AS PrzychodyCalcSys,
    ISNULL(SUM(CASE ISNULL(BZp_Kierunek, 0) WHEN -1 THEN 1 ELSE 0 END * ISNULL(BZp_KwotaSys,0)), 0) AS RozchodyCalcSys,
    BRp_RoznicaKursowaSysMW AS RoznicaKursowaSysMWCalc
  FROM CDN.BnkRaporty
  LEFT OUTER JOIN CDN.BnkZapisy   ON (BRp_BRpID=BZp_BRpID)
  LEFT OUTER JOIN CDN.BnkRachunki ON (BRp_BRaID=BRa_BRaID)
  WHERE BRp_BRaID = @RejestrID
  GROUP BY BRp_BRpID, BRp_DataDok, BRa_Waluta, BRp_Zamkniety, BRa_SaldoBO,BRa_SaldoBOSys, BRp_RoznicaKursowaSysMW
  ORDER BY BRp_DataDok
  OPEN cur_BnkRaporty
  FETCH NEXT FROM cur_BnkRaporty INTO @BRp_BRpID,
                                      @BRp_DataDok,
                                      @BRa_Waluta,
                                      @BRp_Zamkniety,
                                      @BRa_StanPoczatkowy,
                                      @BRa_StanPoczatkowySys,
                                      @PrzychodyCalc,
                                      @RozchodyCalc,
                                      @PrzychodyCalcSys,
                                      @RozchodyCalcSys,
                                      @RoznicaKursowaSysMWCalc
  IF @@FETCH_STATUS = 0
  BEGIN
    SET @BRa_Saldo      = @BRa_StanPoczatkowy
    SET @BRa_SaldoSys   = @BRa_StanPoczatkowySys
    WHILE 1 = 1
    BEGIN
      IF (@BRp_Zamkniety_Prev IS NULL)
      BEGIN
        SET @BRa_Saldo      = @BRa_StanPoczatkowy
        SET @BRa_SaldoSys   = @BRa_StanPoczatkowySys
      END
      ELSE
        BEGIN
        IF (@BRp_Zamkniety = 0 And @BRp_Zamkniety_Prev = 0)
        BEGIN
          SET @BRa_Saldo    = 0
          SET @BRa_SaldoSys = 0
        END
      END
      UPDATE CDN.BnkRaporty SET BRp_SaldoBO = @BRa_Saldo,
                  BRp_SaldoBOSys    = @BRa_SaldoSys,
                  BRp_Przychody     = @PrzychodyCalc,
                  BRp_PrzychodySys  = @PrzychodyCalcSys,
                  BRp_Rozchody      = @RozchodyCalc,
                  BRp_RozchodySys   = @RozchodyCalcSys
      WHERE BRp_BRpId = @BRp_BRpID
      -- wyliczenie stanu poczatkowego dla kolejnego raportu
      SET @BRa_Saldo    = @BRa_Saldo    + @PrzychodyCalc    - @RozchodyCalc
      SET @BRa_SaldoSys = @BRa_SaldoSys + @PrzychodyCalcSys - @RozchodyCalcSys + @RoznicaKursowaSysMWCalc
      -- zapamiętane stanu zamknięty/otwarty
      SET @BRp_Zamkniety_Prev = @BRp_Zamkniety
      IF @@ERROR <> 0
      BEGIN
        IF @@TRANCOUNT > 0
          ROLLBACK TRAN
        BREAK
      END
      FETCH NEXT FROM cur_BnkRaporty INTO @BRp_BRpID,
                      @BRp_DataDok,
                      @BRa_Waluta,
                      @BRp_Zamkniety,
                      @BRa_StanPoczatkowy,
                      @BRa_StanPoczatkowySys,
                      @PrzychodyCalc,
                      @RozchodyCalc,
                      @PrzychodyCalcSys,
                      @RozchodyCalcSys,
                      @RoznicaKursowaSysMWCalc
      IF @@FETCH_STATUS <> 0
        BREAK
    END -- WHILE 1 = 1
  END -- IF @@FETCH_STATUS = 0
  CLOSE cur_BnkRaporty
  DEALLOCATE cur_BnkRaporty
  ALTER TABLE CDN.BnkRaporty ENABLE TRIGGER ALL
  IF @@TRANCOUNT > 0
    COMMIT TRAN
  SET NOCOUNT OFF
END
