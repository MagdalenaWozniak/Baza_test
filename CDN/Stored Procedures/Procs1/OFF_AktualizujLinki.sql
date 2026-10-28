CREATE PROCEDURE cdn.OFF_AktualizujLinki
  @KT CHAR(1)
AS
BEGIN
SET NOCOUNT ON
  DECLARE
    @GIDTyp   SMALLINT,
    @GIDNumer INT,
    @GIDLp    SMALLINT,
    @GrOTyp   SMALLINT,
    @GrONumer INT,
    @GrOLp    SMALLINT,
    @Poziom   INT
  DECLARE  @GIDFirma INT
  SELECT  @GIDFirma = 0
  IF @KT = 'T'
    TRUNCATE TABLE CDN.TwrLinki
  ELSE IF @KT = 'K'
    TRUNCATE TABLE CDN.KntLinki
  ELSE IF @KT = 'S'
    TRUNCATE TABLE CDN.SrtLinki
  ELSE IF @KT = 'F'
    TRUNCATE TABLE CDN.FrmLinki
  IF @KT = 'T'
   begin
   IF NOT EXISTS (SELECT * FROM cdn.TwrGrupy WHERE TwG_GIDNumer = 0 AND TwG_GroNumer = -1)
   BEGIN
  RAISERROR('##OPT34494##', 16, 1)
  SET NOCOUNT OFF
  RETURN
   END
   IF exists (select * from cdn.TwrGrupy Dziecko where  Dziecko.TwG_GrONumer >= 0 and not exists (select * from cdn.TwrGrupy ojciec where ojciec.TwG_GIDNumer = Dziecko.TwG_GrONumer) )
   BEGIN
  RAISERROR('##OPT34495##', 16, 1)
  SET NOCOUNT OFF
  RETURN
   END
  end
 IF @KT = 'K' AND NOT EXISTS (SELECT * FROM CDN.KntGrupy WHERE KnG_GIDTyp = -32 AND KnG_GIDNumer = 0 AND KnG_GroNumer = -1)
     BEGIN
     INSERT INTO CDN.KntGrupy(KnG_GIDTyp, KnG_GIDFirma, KnG_GIDNumer, KnG_GIDLp, KnG_GrOTyp, KnG_GrOFirma, KnG_GrONumer, KnG_GrOLp, KnG_Akronim, KnG_CzasModyfikacji)
     VALUES(-32, 0,0,0,-32,0,-1,0,'Grupa Główna', DATEDIFF(S,'19900101',GETDATE()))
     END
  -- same grupy
  CREATE TABLE #G (GIDTyp SMALLINT, GIDNumer INT, GIDLp SMALLINT, GrOTyp SMALLINT, GrONumer INT, GrOLp SMALLINT, Poziom INT )
  -- rejestr grup, które zostały obrobione (do sumowania, żeby ich nie sumować ponownie)
  SELECT GIDTyp, GIDNumer, GIDLp INTO #G1 FROM #G
  -- dodajemy grupy na razie z poziomem 0
  IF @KT = 'T'
    INSERT INTO #G (GIDTyp, GIDNumer, GIDLp, GrOTyp, GrONumer, GrOLp, Poziom )
    SELECT  TwG_GIDTyp, TwG_GIDNumer, 0, TwG_GrOTyp, TwG_GrONumer, 0,  0  FROM cdn.TwrGrupy  WHERE TwG_GIDTyp = -16
  ELSE IF @KT = 'K'
    INSERT INTO #G (GIDTyp, GIDNumer, GIDLp, GrOTyp, GrONumer, GrOLp, Poziom )
    SELECT  KnG_GIDTyp, KnG_GIDNumer, 0, KnG_GrOTyp, KnG_GrONumer, 0, 0  FROM cdn.KnTGrupy  WHERE KnG_GIDTyp = -32
  ELSE IF @KT = 'S'
    INSERT INTO #G (GIDTyp, GIDNumer, GIDLp, GrOTyp, GrONumer, GrOLp, Poziom )
    SELECT  SrG_GIDTyp, SrG_GIDNumer, 0, SrG_GrOTyp, SrG_GrONumer, 0, 0  FROM cdn.SrtGrupy  WHERE SrG_GIDTyp = -368
  ELSE IF @KT = 'F'
    INSERT INTO #G (GIDTyp, GIDNumer, GIDLp, GrOTyp, GrONumer, GrOLp, Poziom )
    SELECT DISTINCT FrS_GIDTyp, FrS_GIDNumer, FrS_GIDLp, FrS_GrOTyp, FrS_GrONumer, FrS_GrOLp, 0
    FROM cdn.FrmStruktura WHERE FrS_GIDTyp = -4272 --AND FrS_GIDLp = 0 --AND FrS_ID NOT IN(1,2,3)
-- Grupie głównej ustawiamy poziom na 1
 IF @KT = 'T'
  UPDATE #G SET Poziom =1 WHERE GIDTyp=-16 AND GIDNumer=0
 ELSE IF @KT = 'K'
  UPDATE #G SET Poziom =1 WHERE GIDTyp=-32 AND GIDNumer=0
 ELSE  IF @KT = 'S'
  UPDATE #G SET Poziom =1 WHERE GIDTyp=-368 AND GIDNumer=0
 ELSE  IF @KT = 'F'
  UPDATE #G SET Poziom =1 FROM #G JOIN CDN.FrmStruktura ON FrS_GIDTyp = GIDTyp AND FrS_GIDNumer=GIDNumer AND FrS_GIDLp = GIDLp
  WHERE FrS_ID IN(1,2,3) --FrS_GIDTyp = -4272
-- Czyszczenie Grup z elementów (towarów,kontrahentów, ...)
-- które nie mają ojca (#G ma już praojca) i nie są grupą główną
  IF @KT = 'T'
    DELETE cdn.TwrGrupy FROM cdn.TwrGrupy
    LEFT OUTER JOIN #G ON TwG_GrOTyp = GIDTyp AND TwG_GrONumer = GIDNumer AND TwG_GrOLp = GIDLp
    WHERE TwG_GIDTyp = 16 AND GIDTyp IS NULL --AND GIDTyp<>-1
  ELSE IF @KT = 'K'
    DELETE cdn.KntGrupy FROM cdn.KntGrupy
    LEFT OUTER JOIN #G ON KnG_GrOTyp = GIDTyp AND KnG_GrONumer = GIDNumer AND KnG_GrOLp = GIDLp
    WHERE KnG_GIDTyp = 32 AND GIDTyp IS NULL --AND GIDTyp<>-1  --AB  TID:103839
  ELSE IF @KT = 'S'
    DELETE cdn.SrtGrupy FROM cdn.SrtGrupy
    LEFT OUTER JOIN #G ON SrG_GrOTyp = GIDTyp AND SrG_GrONumer = GIDNumer AND SrG_GrOLp = GIDLp
    WHERE SrG_GIDTyp = 368 AND GIDTyp IS NULL --AND GIDTyp<>-1  --AB  TID:103839
  ELSE IF @KT = 'F'
    DELETE cdn.FrmStruktura FROM cdn.FrmStruktura
    LEFT OUTER JOIN #G ON FrS_GrOTyp = GIDTyp AND FrS_GrONumer = GIDNumer AND FrS_GrOLp = GIDLp
    WHERE (FrS_GIDTyp = 944 or FrS_GIDTyp = 128) AND GIDTyp IS NULL
  -- same elementy
  CREATE TABLE #L (GIDTyp SMALLINT, GIDNumer INT, GIDLp SMALLINT, GrOTyp SMALLINT, GrONumer INT, GrOLp SMALLINT, Lisc SMALLINT, LiczbaPowtorzen SMALLINT )
  -- dodajemy pozostałe elementy na razie z poziomem 0 (za wyjątkiem grupy głównej)
  IF @KT = 'T'
    INSERT INTO #L (GIDTyp, GIDNumer, GIDLp, GrOTyp, GrONumer, GrOLp, Lisc, LiczbaPowtorzen )
    SELECT TwG_GIDTyp, TwG_GIDNumer, TwG_GIDLp, TwG_GrOTyp, TwG_GrONumer, TwG_GrOLp, 1, 1
    FROM cdn.TwrGrupy WHERE TwG_GIDNumer>0
  ELSE IF @KT = 'K'
    INSERT INTO #L (     GIDTyp,     GIDNumer,     GIDLp,     GrOTyp,     GrONumer,     GrOLp, Lisc, LiczbaPowtorzen )
    SELECT  KnG_GIDTyp, KnG_GIDNumer, KnG_GIDLp, KnG_GrOTyp, KnG_GrONumer, KnG_GrOLp,    1,               1
    FROM cdn.KntGrupy WHERE KnG_GIDNumer>0 or (KnG_GIDNumer=0 and KnG_GidTyp = 32)
  ELSE IF @KT = 'S'
    INSERT INTO #L (     GIDTyp,     GIDNumer,     GIDLp,     GrOTyp,     GrONumer,     GrOLp, Lisc, LiczbaPowtorzen )
    SELECT         SrG_GIDTyp, SrG_GIDNumer, SrG_GIDLp, SrG_GrOTyp, SrG_GrONumer, SrG_GrOLp,    1,               1
    FROM cdn.SrtGrupy WHERE SrG_GIDNumer>0
  ELSE IF @KT = 'F'
    INSERT INTO #L (     GIDTyp,     GIDNumer,     GIDLp,     GrOTyp,     GrONumer,     GrOLp, Lisc, LiczbaPowtorzen )
    SELECT         FrS_GIDTyp, FrS_GIDNumer, FrS_GIDLp, FrS_GrOTyp, FrS_GrONumer, FrS_GrOLp,    1,               1
    FROM cdn.FrmStruktura --WHERE FrS_GIDLp = 0
  -- uzupelnianie poziomów w tabeli #G (jedziemy od góry)
  SET @Poziom = 1
  WHILE 1=1
  BEGIN
      -- jesli nie ma niewypełnionych poziomów, to koniec
      IF NOT EXISTS ( SELECT * FROM #G WHERE Poziom = 0 ) BREAK
      -- update poziomu dla grup będących dziećmi danego ojca
      UPDATE #G SET Poziom = @Poziom + 1
        WHERE GrONumer IN ( SELECT GIDNumer FROM #G WHERE Poziom = @Poziom )
      SET @Poziom = @Poziom + 1
  END
  -- uzupełnianie tabeli TwrLinki
  -- kursor po poziomach od najniższego (tj. najwyższego )
  DECLARE P CURSOR LOCAL FAST_FORWARD FOR
  SELECT Poziom FROM #G GROUP BY Poziom ORDER BY Poziom DESC
    OPEN P
    WHILE 1=1
      BEGIN
        FETCH NEXT FROM P INTO @Poziom
        IF @@FETCH_STATUS <> 0 BREAK
        -- STOP jeśli jesteśmy na najwyższym poziomie (praojciec został zupdatowany w poprzednim okrążeniu)
        IF @Poziom = 1 BREAK
        -- pętla po ojcach danego poziomu
        DECLARE O CURSOR LOCAL FAST_FORWARD FOR
        SELECT GrOTyp, GrONumer, GrOLp FROM #G WHERE Poziom = @Poziom GROUP BY GrOTyp, GrONumer, GrOLp
          OPEN O
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM O INTO @GrOTyp, @GrONumer, @GrOLp
              IF @@FETCH_STATUS <> 0 BREAK
              -- modyfikujemy tylko tych ojców, którzy nie byli jeszcze modyfikowani (nie są grupami linkowanymi i nie byli jeszcze modyfikowani)
              IF EXISTS ( SELECT * FROM #G1 WHERE GIDTyp = @GrOTyp AND GIDNumer = @GrONumer AND GIDLp = @GrOLp )
                BREAK
              -- kopia towarów należących do ojca
              SELECT * INTO #O FROM #L WHERE GrOTyp = @GrOTyp AND GrONumer = @GrONumer AND GrOLp = @GrOLp
              DELETE           FROM #L WHERE GrOTyp = @GrOTyp AND GrONumer = @GrONumer AND GrOLp = @GrOLp
              -- pętla po dzieciach (grupach) jednego ojca w celu zupdatowania ojca
              DECLARE D CURSOR LOCAL FAST_FORWARD FOR
              SELECT GIDTyp, GIDNumer, GIDLp FROM #G WHERE GrOTyp = @GrOTyp AND GrONumer = @GrONumer AND GrOLp = @GrOLp GROUP BY GIDTyp, GIDNumer, GIDLp
                OPEN D
                WHILE 1=1
                  BEGIN
                    FETCH NEXT FROM D INTO @GIDTyp, @GIDNumer, @GIDLp
                    IF @@FETCH_STATUS <> 0 BREAK
                    -- uzupełnienie rejestru grup obrabianych
                    INSERT INTO #G1 SELECT @GIDTyp, @GIDNumer, @GIDLp
                    -- kopia towarów aktualnego dziecka
                    SELECT * INTO #D FROM #L WHERE GrOTyp = @GIDTyp AND GrONumer = @GIDNumer AND GrOLp = @GIDLp
                    -- update LiczbaPowtorzen ojca - sumowanie ilości powtórzeń dla towarów które istnieją u ojca i u dziecka
                    UPDATE #O SET #O.LiczbaPowtorzen = #O.LiczbaPowtorzen + #D.LiczbaPowtorzen
                      FROM #O JOIN #D ON #O.GIDTyp = #D.GIDTyp AND #O.GIDNumer = #D.GIDNumer AND #O.GIDLp = #D.GIDLp
                    -- insert do grupy ojca - dodanie towarów, które nie istnieją u ojca, a istnieją u dziecka
                    INSERT INTO #O (GIDTyp,    GIDNumer,    GIDLp,  GrOTyp,  GrONumer,  GrOLp, Lisc,    LiczbaPowtorzen )
                      SELECT         #D.GIDTyp, #D.GIDNumer, #D.GIDLp, @GroTyp, @GrONumer, @GrOLp,    0, #D.LiczbaPowtorzen
                        FROM #D LEFT OUTER JOIN #O ON #O.GIDTyp = #D.GIDTyp AND #O.GIDNumer = #D.GIDNumer AND #O.GIDLp = #D.GIDLp
                        WHERE #O.GIDTyp IS NULL
                    -- aktualne dziecko nie jest już potrzebne
                    DROP TABLE #D
                  END
                CLOSE D
              DEALLOCATE D
              -- kopia gotowego ojca z powrotem do #L i drop ojca
              INSERT INTO #L SELECT * FROM #O
              DROP TABLE #O
            END
          CLOSE O
        DEALLOCATE O
      END
    CLOSE P
  DEALLOCATE P
  DECLARE @TStampDataMod INT
  SET @TStampDataMod = DATEDIFF(S,'19900101',GETDATE())
  IF @KT = 'T'
  INSERT INTO cdn.TwrLinki (TwL_GIDTyp, TwL_GIDFirma, TwL_GIDNumer, TwL_GIDLp, TwL_GrOTyp, TwL_GrOFirma, TwL_GrONumer, TwL_GrOLp, TwL_Lisc, TwL_LiczbaPowtorzen, TwL_TStampDataMod)
    SELECT GIDTyp, @GIDFirma, GIDNumer, GIDLp, GrOTyp, @GIDFirma, GrONumer, GrOLp, Lisc, LiczbaPowtorzen, @TStampDataMod FROM #L
  ELSE IF @KT = 'K'
  INSERT INTO cdn.KntLinki (KnL_GIDTyp, KnL_GIDFirma, KnL_GIDNumer, KnL_GIDLp, KnL_GrOTyp, KnL_GrOFirma, KnL_GrONumer, KnL_GrOLp, KnL_Lisc, KnL_LiczbaPowtorzen, KnL_TStampDataMod)
    SELECT GIDTyp, @GIDFirma, GIDNumer, GIDLp, GrOTyp, @GIDFirma, GrONumer, GrOLp, Lisc, LiczbaPowtorzen, @TStampDataMod FROM #L
  ELSE IF @KT = 'S'
  INSERT INTO cdn.SrtLinki (SRL_GIDTyp, SRL_GIDFirma, SRL_GIDNumer, SRL_GIDLp, SRL_GrOTyp, SRL_GrOFirma, SRL_GrONumer, SRL_GrOLp, SRL_Lisc, SRL_LiczbaPowtorzen, SRL_TStampDataMod)
    SELECT GIDTyp, @GIDFirma, GIDNumer, GIDLp, GrOTyp, @GIDFirma, GrONumer, GrOLp, Lisc, LiczbaPowtorzen, @TStampDataMod FROM #L
  ELSE IF @KT = 'F'
  INSERT INTO cdn.FrmLinki (FRL_GIDTyp, FRL_GIDFirma, FRL_GIDNumer, FRL_GIDLp, FRL_GrOTyp, FRL_GrOFirma, FRL_GrONumer, FRL_GrOLp, FRL_Lisc, FRL_LiczbaPowtorzen, FRL_TStampDataMod)
    SELECT GIDTyp, @GIDFirma, GIDNumer, GIDLp, GrOTyp, @GIDFirma, GrONumer, GrOLp, Lisc, LiczbaPowtorzen, @TStampDataMod FROM #L
  DROP TABLE #G1
  DROP TABLE #G
  DROP TABLE #L
SET NOCOUNT OFF
END
