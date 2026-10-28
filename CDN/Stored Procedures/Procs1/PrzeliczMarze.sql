CREATE PROCEDURE cdn.PrzeliczMarze
@twrId  INT,
@numerCeny INT,
@walutaSystemowa VARCHAR(3)
AS
BEGIN
 SET NOCOUNT ON
 IF @numerCeny = 1 GOTO KONIEC
 DECLARE @cenaZakupu DECIMAL(17,4), @wartosc DECIMAL(17,4), @marza DECIMAL(17,2), @marzaWStu DECIMAL(17,2), @offset DECIMAL(7,4), @cenaZCzteremaMiejscami INT
 ,@stawkaVat DECIMAL(5,2), @typCenyZakupu INT, @typCeny INT, @cenaNominalna DECIMAL(17,4), @cenaBrutto DECIMAL(17,4), @kursDlaCenyZakupu DECIMAL(15,6)
 ,@usluga INT, @kosztUslugi DECIMAL(17,4), @walutaTwr VARCHAR(3), @waluta VARCHAR(3),@kursWal DECIMAL(15,6), @wStu INT
 DECLARE @kursL DECIMAL(15,4), @kursM DECIMAL(5,0), @dataNotowania DATETIME, @err INT
 SELECT TOP 1 @wartosc = TwC_Wartosc,
    @marza = TwC_Marza,
    @marzaWStu = TwC_MarzaWStu,
    @offset = TwC_Offset,
    @waluta = TwC_Waluta,
    @typCeny = TwC_Typ
 FROM cdn.TwrCeny WHERE TwC_TwrId = @twrId AND TwC_TwCNumer = @numerCeny
 SELECT TOP 1 @cenaZCzteremaMiejscami = Twr_CenaZCzteremaMiejscami,
     @stawkaVat = Twr_Stawka,
     @kursL = Twr_KursL,
     @kursM = Twr_KursM,
     @usluga = CASE WHEN Twr_Typ = 0 THEN 1 ELSE 0 END,
     @kosztUslugi = Twr_KosztUslugi,
     @walutaTwr = Twr_Waluta
 FROM cdn.Towary WHERE Twr_TwrID = @twrId
 IF @kursM IS NULL SET @kursM = 1
 SET @kursDlaCenyZakupu = @kursL/@kursM
 IF @kursDlaCenyZakupu IS NULL SET @kursDlaCenyZakupu = 1
 IF @kursDlaCenyZakupu = 0 SET @kursDlaCenyZakupu = 1
 SELECT TOP 1 @cenaZakupu = CASE WHEN @usluga = 0 THEN TwC_Wartosc ELSE @kosztUslugi/@kursDlaCenyZakupu END,
     @typCenyZakupu = TwC_Typ
 FROM cdn.TwrCeny WHERE TwC_TwrID = @twrId AND TwC_TwCNumer = 1
    SELECT @wStu = isNull(Fir_Wartosc,0) FROM CDN.Firma WHERE Fir_Numer = 1624
 IF @cenaZakupu <= 0
 BEGIN
  SET @marza = -100
  GOTO USTAW
 END
 IF @waluta = @walutaTwr
 BEGIN
  SET @kursWal = @kursDlaCenyZakupu
 END
 ElSE
 BEGIN
  IF @waluta = @walutaSystemowa
  BEGIN
   SET @kursWal = 1
  END
  ELSE
  BEGIN
   SET @dataNotowania = GetDate()
   SET @kursL = NULL
   SET @kursM = NULL
   EXEC [CDN].PobierzKursWaluty @waluta, @dataNotowania, @kursL OUTPUT, @kursM OUTPUT, @err OUTPUT
   IF @err > 0
   BEGIN
    --SET @errText = cdn.PobierzKursWalutyErr(@walutaB, @dataNotowania, @err)
    GOTO KONIEC
   END
   IF @kursM = 0 SET @kursM = 1
   SET @kursWal = @kursL/@kursM
  END
 END
 IF @kursWal <= 0 OR @kursDlaCenyZakupu <= 0 GOTO KONIEC
 DECLARE @r4 INT
 SET @r4 = 2
 IF @cenaZCzteremaMiejscami = 1 SET @r4 = 4
 SET @cenaNominalna = (ROUND(@wartosc, @r4) - ROUND(@offset, @r4))
 IF @typCeny = 1 -- e_op_nCenaNetto
  SET @cenaBrutto = ROUND(@cenaNominalna * (1+@stawkaVat/100), @r4)
 ELSE
  SET @cenaBrutto = ROUND(@cenaNominalna / (1+@stawkaVat/100), @r4)
 IF @wStu = 1
 BEGIN
  SET @cenaNominalna = (ROUND(@wartosc, @r4) - ROUND(@offset, @r4)) * @kursWal
  IF @cenaNominalna = 0
  BEGIN
   SET @marzaWStu = -100
   SET @marza = -100
   GOTO USTAW
  END
  IF @typCenyZakupu = @typCeny
  BEGIN
   SET @cenaNominalna = ROUND((ROUND(@wartosc, @r4) - ROUND(@offset, @r4)) * @kursWal, @r4)
   SET @marzaWStu = ROUND(100 * (1 - (@cenaZakupu * @kursDlaCenyZakupu / @cenaNominalna)), 2)
   IF @marzaWStu > 99.99 SET @marzaWStu = 100
   SET @marza = @marzaWStu * (@cenaNominalna/(@cenaZakupu * @kursDlaCenyZakupu))
   GOTO USTAW
  END
  SET @marzaWStu = ROUND(100 * (1 - (@cenaZakupu * @kursDlaCenyZakupu/(@cenaBrutto * @kursWal))),2);
  IF @marzaWStu > 99.99 SET @marzaWStu = 100
  SET @marza = ROUND( (@marzaWStu * @cenaBrutto * @kursWal)/(@cenaZakupu * @kursDlaCenyZakupu),2);
  GOTO USTAW
 END
 IF @wStu = 0 -- OD STU
 BEGIN
  SET @cenaNominalna = (ROUND(@wartosc, @r4) - ROUND(@offset, @r4)) * @kursWal
  IF @typCenyZakupu = @typCeny
   SET @marza = ROUND(100 * ((@cenaNominalna /(@cenaZakupu * @kursDlaCenyZakupu))-1), 2)
  ELSE
   SET @marza = ROUND(100 * ( ((@cenaBrutto * @kursWal)/(@cenaZakupu * @kursDlaCenyZakupu) ) -1), 2);
  IF @marza = -100 OR @cenaNominalna = 0
  BEGIN
   SET @marzaWStu = -100
   GOTO USTAW
  END
  IF @typCenyZakupu = @typCeny  SET @cenaBrutto = ROUND(@wartosc, @r4) - ROUND(@offset, @r4)
  SET @marzaWStu = (@marza * (@cenaZakupu * @kursDlaCenyZakupu))/(@cenaBrutto * @kursWal);
  GOTO USTAW
 END
USTAW:
 IF @marza = -0 SET @marza = 0
 IF @marzaWStu = -0 SET @marzaWStu = 0
 IF @marza > 99999.99 SET @marza = 99999.99;
 IF @marza < -99999.99 SET @marza = -99999.99;
 IF @marzaWStu > 99.99 SET @marzaWStu = 100;
 IF @marzaWStu < -99.99 SET @marzaWStu = -100;
 UPDATE cdn.TwrCeny SET
  TwC_Marza = @marza,
  TwC_MarzaWStu = @marzaWStu
 WHERE TwC_TwrId = @twrId AND TwC_TwCNumer = @numerCeny
KONIEC:
 SET NOCOUNT OFF
END
