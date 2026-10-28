Create procedure CDN.AktualizujCennik
@TwCNumer as int,
@SelectZero as int
AS
BEGIN
  SET NOCOUNT ON ;
  SET XACT_ABORT ON;
  SET ANSI_WARNINGS OFF
  DECLARE @TwrId INT
  DECLARE @TwrTyp INT
  DECLARE @TwrKosztUslugi DECIMAL (17,4)
  DECLARE @TwrKosztUslugiTyp TINYINT
  DECLARE @TwrStawka DECIMAL(5,2)
  DECLARE @MarzaWStu DECIMAL(5,2)
  DECLARE @WStu INT
  DECLARE @CenaZakupu DECIMAL(17,4)
  DECLARE @TwcWartosc DECIMAL(17,4)
  DECLARE @TwcWaluta NVARCHAR(3)
  DECLARE @TwcTyp INT
  DECLARE @DfcTyp INT
  DECLARE @DfcWaluta NVARCHAR(3)
  DECLARE @DfcZaokraglenie DECIMAL(7,4)
  DECLARE @DfcOffSET DECIMAL(7,4)
  DECLARE @DfcMarza DECIMAL(5,2)
  DECLARE @DfcAktualizacja INT
  DECLARE @KursL DECIMAL(15,4)
  DECLARE @KursM DECIMAL(5,0)
  DECLARE @KursLZak DECIMAL(15,4)
  DECLARE @KursMZak DECIMAL(5,0)
  DECLARE @KursDomyslny INT
  DECLARE @WalSys   NVARCHAR(3)
  DECLARE @ServerCfgString  NVARCHAR(512)
  DECLARE @BazaCfgString  NVARCHAR(512)
  DECLARE @ParamDefinition   NVARCHAR(500)
  DECLARE @sqltxt nvarchar(1000),@TmpSrvName sysname
  DECLARE @DfcZaokraglenieTmp DECIMAL(7,4)
  DECLARE @sqltxtnot NVARCHAR (1000)
  DECLARE @sqltxtkur nvarchar(1000)
  DECLARE @Licznik INT
  DECLARE @Max INT
  DECLARE @TwrCenaZCzteremaMiejscami TINYINT
  DECLARE @Towary TABLE (TwrCount INT IDENTITY(1,1), TwrId INT, TwrTyp INT, TwrStawka DECIMAL (5,2),
                         TwrKosztUslugi DECIMAL (17,4), TwrKosztUslugiTyp TINYINT,TwrCenaZCzteremaMiejscami TINYINT PRIMARY KEY (TwrCount,TwrId))
  IF NOT EXISTS (SELECT name FROM dbo.sysobjects WHERE NAME LIKE '%notowania%')
    BEGIN
       SELECT @ServerCfgString = SYS_Wartosc FROM cdn.SystemCdn WHERE SYS_ID = 1001
       SELECT @BazaCfgString   = SYS_Wartosc FROM cdn.SystemCdn WHERE SYS_ID = 1002
       SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS sysname)
       IF CAST ( SERVERPROPERTY ('InstanceName') AS sysname ) <> ''
       SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS sysname)
       SET @sqltxt = 'SELECT @symbol = WNa_Symbol FROM ['
       IF @ServerCfgString <> @TmpSrvName
       SET @sqltxt = @sqltxt + @ServerCfgString +'].['
       SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.WalNazwy WHERE WNa_WNaID=1'
       SET @ParamDefinition = N'@symbol NVARCHAR(3) OUTPUT';
       EXEC sp_executesql @sqltxt, @ParamDefinition, @symbol=@WalSys OUTPUT
       SET @sqltxtkur = 'SELECT @kursdom = Kon_Wartosc FROM ['
       IF @ServerCfgString <> @TmpSrvName
       SET @sqltxtkur = @sqltxtkur + @ServerCfgString +'].['
       SET @sqltxtkur = @sqltxtkur + @BazaCfgString+'].CDN.Konfig WHERE Kon_Numer=260'
       SET @ParamDefinition = N'@kursdom integer OUTPUT';
       EXEC sp_executesql @sqltxtkur, @ParamDefinition, @kursdom=@KursDomyslny OUTPUT
       SELECT @WStu = isnull(Fir_Wartosc,0) FROM CDN.Firma WHERE Fir_Numer = 1624
       SELECT @DfcTyp = dfc_typ, @DfcWaluta = Dfc_waluta, @DfcZaokraglenie = Dfc_Zaokraglenie, @DfcOffSET = Dfc_OffSET, @DfcMarza = Dfc_Marza, @DfcAktualizacja = Dfc_Aktualizacja  FROM cdn.defceny WHERE dfc_Lp = @TwCNumer
       SET @DfcZaokraglenieTmp =
                      CASE @DfcZaokraglenie
         when 0.0001 then  4
                         when 0.0005 then  3
          when 0.001 then  3
                         when 0.005 then  2
                         when 0.01 then  2
                         when 0.05 then  1
                         when 0.1  then  1
                         when 0.5  then  0
                         when 1    then  0
                         when 5    then -1
                         when 10   then -2
                      END
  -- zaokraglanie dla polowek wg. wzoru: ROUND(@wartosc/0.5,@zaokraglenie)*0.5
      SET @sqltxtnot = '['
      IF @ServerCfgString <> @TmpSrvName
      SET @sqltxtnot = @sqltxtnot + @ServerCfgString +'].['
      SET @sqltxtnot = @sqltxtnot + @BazaCfgString+'].CDN.PobierzNotowania '''', '+convert(nvarchar(10),@KursDomyslny)+','''+ convert(NVARCHAR(10),getdate(),120)+''',1'
      CREATE TABLE dbo.#Notowania  ( Systemowa TINYINT, Waluta NVARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
      INSERT INTO  dbo.#Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
      EXEC sp_executesql @sqltxtnot
    END
 INSERT INTO @Towary (TwrId, TwrTyp, TwrStawka, TwrKosztUslugi, TwrKosztUslugiTyp,TwrCenaZCzteremaMiejscami)
 SELECT Twr_TwrId, Twr_Typ, Twr_Stawka, Twr_KosztUslugi, Twr_KosztUslugiTyp,Twr_CenaZCzteremaMiejscami
 FROM cdn.Towary
 LEFT JOIN cdn.TwrCeny ON Twr_TwrId = TwC_TwrId AND TwC_TwCNumer = @TwCNumer
 GROUP by Twr_TwrId, Twr_Typ, Twr_Stawka, Twr_KosztUslugi, Twr_KosztUslugiTyp,Twr_CenaZCzteremaMiejscami
 HAVING Count(TwC_TwCNumer) = 0
  SELECT @Licznik = 1
  SELECT @Max = Max(TwrCount) FROM @Towary
BEGIN TRANSACTION
  WHILE 1=1 AND @Licznik < = @Max
   BEGIN
  set @TwcWartosc = 0  --WiNi
  set @KursL = 1
  set @KursM = 1
  set @CenaZakupu = 0
  set @KursLZak = 1
  set @KursMZak =1
        SELECT @TwrId = TwrId, @TwrTyp = TwrTyp, @TwrStawka = TwrStawka, @TwrKosztUslugi = TwrKosztUslugi, @TwrKosztUslugiTyp = TwrKosztUslugiTyp,@TwrCenaZCzteremaMiejscami = TwrCenaZCzteremaMiejscami
        FROM @Towary WHERE TwrCount = @Licznik
        SELECT @CenaZakupu = ISNULL(Twc_Wartosc,0), @TwcTyp = Twc_Typ, @TwcWaluta = Twc_Waluta FROM CDN.TwrCeny WHERE Twc_TwcNumer = 1 and Twc_TwrId = @TwrId
        SELECT @KursLZak =  ISNULL(KursL,1), @KursMZak = ISNULL(KursM,1) FROM dbo.#Notowania WHERE KursNumer = @KursDomyslny AND Waluta = @TwcWaluta
        SELECT @KursL =  ISNULL(KursL,1), @KursM = ISNULL(KursM,1) FROM dbo.#Notowania WHERE KursNumer = @KursDomyslny AND Waluta = @DfcWaluta
          IF @TwrTyp <> 1 AND @TwrKosztUslugiTyp = 1
            SET @CenaZakupu = round(@TwrKosztUslugi/(@KursLZak/@KursMZak),case when @TwrCenaZCzteremaMiejscami = 1 then 4 else 2 end)
             ELSE IF @TwrTyp <> 1 AND @TwrKosztUslugiTyp <> 1
            SET @CenaZakupu = 0
          IF @TwrTyp = 1 OR (@TwrTyp <> 1 AND @TwrKosztUslugiTyp = 1) AND (@DfcMarza > 0 AND @CenaZakupu > 0) -- wartosc aktualizowana kiedy towar lub usluga z typem = 1
        BEGIN
            IF (@TwcWaluta <> @WalSys AND @DfcWaluta = @WalSys) OR (@TwcWaluta <> @WalSys AND @DfcWaluta <> @WalSys) OR (@TwcWaluta = @WalSys AND @DfcWaluta <> @WalSys)
          BEGIN
            IF @WStu = 0 -- marza WStu = 1
            BEGIN
              IF @TwcTyp <> @DfcTyp -- typ netto/brutto rozny dla ceny Z i S
              BEGIN
                IF @DfcTyp = 1 -- cena netto
                IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
                SET @TwcWartosc = (ROUND((@CenaZakupu*@KursLZak/@KursMZak*(1+@DfcMarza/100)/(@KursL/@KursM))/0.5,@DfcZaokraglenieTmp)*0.5+@DfcOffSET)/(1+@TwrStawka/100)
                 ELSE
                SET @TwcWartosc = (ROUND(@CenaZakupu*@KursLZak/@KursMZak*(1+@DfcMarza/100)/(@KursL/@KursM),@DfcZaokraglenieTmp)+@DfcOffSET)/(1+@TwrStawka/100)
                 ELSE        -- cena brutto
                BEGIN
                  IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
                  SET @TwcWartosc = ((ROUND((@CenaZakupu*@KursLZak/@KursMZak*(1+@DfcMarza/100)*(1+@TwrStawka/100)/(@KursL/@KursM))/0.5, @DfcZaokraglenieTmp)*0.5+@DfcOffSET))
                   ELSE
                  SET @TwcWartosc = ((ROUND(@CenaZakupu*@KursLZak/@KursMZak*(1+@DfcMarza/100)*(1+@TwrStawka/100)/(@KursL/@KursM), @DfcZaokraglenieTmp)+@DfcOffSET))
                  IF @TwcWartosc < 0
                  SET @TwcWartosc = 0
                END
              END
            ELSE  -- typ netto/brutto identyczny dla ceny Z i S
              BEGIN
                IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
                SET @TwcWartosc = (ROUND((@CenaZakupu*@KursLZak/@KursMZak*(1+@DfcMarza/100)/(@KursL/@KursM))/0.5,@DfcZaokraglenieTmp)*0.5+@DfcOffSET)
                 ELSE
                SET @TwcWartosc = (ROUND(@CenaZakupu*@KursLZak/@KursMZak*(1+@DfcMarza/100)/(@KursL/@KursM),@DfcZaokraglenieTmp)+@DfcOffSET)
                IF @TwcWartosc < 0
                SET @TwcWartosc = 0
              END
          END
             ELSE
              BEGIN
               IF @TwcTyp <> @DfcTyp
                BEGIN
                  IF @DfcTyp = 1
                  IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
                  SET @TwcWartosc = (ROUND((@CenaZakupu*@KursLZak/@KursMZak/(1-@DfcMarza/100)/(@KursL/@KursM))/0.5, @DfcZaokraglenieTmp)*0.5+@DfcOffSET)/(1+@TwrStawka/100)
                   ELSE
                 SET @TwcWartosc = (ROUND(@CenaZakupu*@KursLZak/@KursMZak/(1-@DfcMarza/100)/(@KursL/@KursM), @DfcZaokraglenieTmp)+@DfcOffSET)/(1+@TwrStawka/100)
                   ELSE
                     BEGIN
                      IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
                      SET @TwcWartosc = ROUND((@CenaZakupu*@KursLZak/@KursMZak/(1-@DfcMarza/100)*(1+@TwrStawka/100)/(@KursL/@KursM))/0.5, @DfcZaokraglenieTmp)*0.5 + @DfcOffSET
                       ELSE
                      SET @TwcWartosc = ROUND(@CenaZakupu*@KursLZak/@KursMZak/(1-@DfcMarza/100)*(1+@TwrStawka/100)/(@KursL/@KursM), @DfcZaokraglenieTmp) + @DfcOffSET
                      IF @TwcWartosc < 0
                      SET @TwcWartosc = 0
                     END
                END
                 ELSE
                   BEGIN
                    IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
                    SET @TwcWartosc = ROUND((@CenaZakupu*@KursLZak/@KursMZak/(1-@DfcMarza/100)/(@KursL/@KursM))/0.5, @DfcZaokraglenieTmp)*0.5 + @DfcOffSET
                     ELSE
                    SET @TwcWartosc = ROUND(@CenaZakupu*@KursLZak/@KursMZak/(1-@DfcMarza/100)/(@KursL/@KursM), @DfcZaokraglenieTmp) + @DfcOffSET
                    IF @TwcWartosc < 0
                    SET @TwcWartosc = 0
                   END
              END
          END
        ELSE
         BEGIN
          IF @WStu = 0
            BEGIN
             IF @TwcTyp <> @DfcTyp
               BEGIN
                IF @DfcTyp = 1
                IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
                SET @TwcWartosc = (ROUND((@CenaZakupu*(1+@DfcMarza/100))/0.5,@DfcZaokraglenieTmp)*0.5+@DfcOffSET)/(1+@TwrStawka/100)
                 ELSE
                SET @TwcWartosc = (ROUND(@CenaZakupu*(1+@DfcMarza/100),@DfcZaokraglenieTmp)+@DfcOffSET)/(1+@TwrStawka/100)
                 ELSE
                  BEGIN
                    IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
                    SET @TwcWartosc = ((ROUND((@CenaZakupu*(1+@DfcMarza/100)*(1+@TwrStawka/100))/0.5, @DfcZaokraglenieTmp)*0.5+@DfcOffSET))
                     ELSE
                    SET @TwcWartosc = ((ROUND(@CenaZakupu*(1+@DfcMarza/100)*(1+@TwrStawka/100), @DfcZaokraglenieTmp)+@DfcOffSET))
                    IF @TwcWartosc < 0
                    SET @TwcWartosc = 0
                  END
               END
            ELSE
             BEGIN
              IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
              SET @TwcWartosc = (ROUND((@CenaZakupu*(1+@DfcMarza/100))/0.5,@DfcZaokraglenieTmp)*0.5+@DfcOffSET)
               ELSE
              SET @TwcWartosc = (ROUND(@CenaZakupu*(1+@DfcMarza/100),@DfcZaokraglenieTmp)+@DfcOffSET)
              IF @TwcWartosc < 0
              SET @TwcWartosc = 0
             END
         END
     ELSE
      BEGIN
       IF @TwcTyp <> @DfcTyp
        BEGIN
          IF @DfcTyp = 1 --cena netto
          IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
          SET @TwcWartosc = (ROUND((@CenaZakupu/(1-@DfcMarza/100))/0.5, @DfcZaokraglenieTmp)*0.5+@DfcOffSET)/(1+@TwrStawka/100)
           ELSE
          SET @TwcWartosc = (ROUND(@CenaZakupu/(1-@DfcMarza/100), @DfcZaokraglenieTmp)+@DfcOffSET)/(1+@TwrStawka/100)
           ELSE
             BEGIN
               IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
               SET @TwcWartosc = ROUND((@CenaZakupu/(1-@DfcMarza/100)*(1+@TwrStawka/100))/0.5, @DfcZaokraglenieTmp)*0.5 + @DfcOffSET
                ELSE
               SET @TwcWartosc = ROUND(@CenaZakupu/(1-@DfcMarza/100)*(1+@TwrStawka/100), @DfcZaokraglenieTmp) + @DfcOffSET
               IF @TwcWartosc < 0
              SET @TwcWartosc = 0
             END
        END
         ELSE
           BEGIN
            IF @DfcZaokraglenie in (0.0005,0.005,0.05, 0.5, 5)
            SET @TwcWartosc = ROUND((@CenaZakupu/(1-@DfcMarza/100))/0.5, @DfcZaokraglenieTmp)*0.5 + @DfcOffSET
              ELSE
            SET @TwcWartosc = ROUND(@CenaZakupu/(1-@DfcMarza/100), @DfcZaokraglenieTmp) + @DfcOffSET
             IF @TwcWartosc < 0
             SET @TwcWartosc = 0
          END
        END
      END
    END
   ELSE
    BEGIN
     SET @TwcWartosc = ISNULL(@CenaZakupu,0)
    END
   set @TwcWartosc = isnull(@TwcWartosc,0)  --WiNi
 set @KursL = isnull(@KursL,0)
 set @KursM = isnull(@KursM,1)
 set @CenaZakupu = isnull(@CenaZakupu,0)
 set @KursLZak = isnull(@KursLZak,0)
 set @KursMZak =isnull(@KursMZak,1)
      INSERT INTO CDN.TwrCeny(TwC_TwrID,TwC_TwCNumer,TwC_Typ,TwC_Wartosc,TwC_Waluta,TwC_Aktualizacja,TwC_Zaokraglenie,TwC_Marza,TwC_MarzaWStu,TwC_OffSET)
      SELECT @TwrId, DfC_Lp, DfC_Typ, CASE WHEN @DfCMarza = 0 and @DfCAktualizacja = 0 THEN 0 ELSE @TwcWartosc END , DfC_Waluta, DfC_Aktualizacja,       DfC_Zaokraglenie,
        CASE WHEN @DfCMarza = 0 and @DfCAktualizacja = 0
                THEN -100
                  ELSE DfC_Marza END,
        CASE WHEN (@WStu = 0 and (@CenaZakupu=0 or @TwcWartosc=0)) OR (@WStu=1 and (@CenaZakupu=0 or @TwcWartosc=0))
                THEN -100
                  ELSE
        CASE WHEN @DfCTyp=1
                THEN (@TwcWartosc*(@KursL/@KursM) - @CenaZakupu*@KursLZak/@KursMZak)/(@TwcWartosc*(@KursL/@KursM)/100)
                   ELSE
                     (@TwcWartosc / (1+@TwrStawka/100)*(@KursL/@KursM) - @CenaZakupu*@KursLZak/@KursMZak)/(@TwcWartosc / (1+@TwrStawka/100)*(@KursL/@KursM)/100)
                  END
                    END,  DfC_OffSET
            FROM  CDN.DefCeny WHERE DfC_Lp = @TwCNumer
      IF @Licznik > @max BREAK
       SELECT @Licznik = @Licznik + 1
   END
       IF @@Error <> 0
          ROLLBACK TRAN
           ELSE
          COMMIT TRAN
 DROP TABLE #Notowania
SET NOCOUNT OFF
SET XACT_ABORT OFF;
SET ANSI_WARNINGS ON
END
IF @SelectZero = 1
 SELECT 0
