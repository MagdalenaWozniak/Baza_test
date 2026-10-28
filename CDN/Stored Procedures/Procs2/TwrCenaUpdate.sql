CREATE PROCEDURE cdn.TwrCenaUpdate
@twrId  INT,
@numerCeny INT,
@wartosc DECIMAL(17,4),
@waluta  VARCHAR(3),
@rejestrOperacji INT
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @twrKod VARCHAR(40), @twrTyp INT
 SELECT TOP 1 @twrKod = Twr_Kod, @twrTyp = Twr_Typ FROM cdn.Towary WHERE Twr_TwrId = @twrId
 IF @twrTyp = 0 AND @numerCeny = 1  GOTO KONIEC --  dla usługi nie ustawiamy ceny zakupu
 IF @waluta = ''
  UPDATE cdn.TwrCeny SET TwC_Wartosc = @wartosc WHERE TwC_TwrID = @twrId AND TwC_TwCNumer = @numerCeny
 ELSE
  UPDATE cdn.TwrCeny SET TwC_Wartosc = @wartosc, TwC_Waluta = @waluta WHERE TwC_TwrID = @twrId AND TwC_TwCNumer = @numerCeny
    IF @rejestrOperacji = 1
    BEGIN
  IF @twrKod IS NULL SET @twrKod = ''
        EXEC [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @twrKod, 2, '';
    END
KONIEC:
 SET NOCOUNT OFF
END
