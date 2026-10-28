--* gSkrypt.sOpis = $Tworzenie procedury SetTwrKgo$
CREATE PROCEDURE CDN.SetTwrKgo
@twrId INT, @kgo DECIMAL(15, 2)
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @komunikat NVARCHAR(255)
 SET @komunikat = ''
 SELECT @komunikat = Twr_Kod FROM cdn.Towary WHERE TwR_TwRId=@twrId
 IF EXISTS(SELECT * FROM cdn.Towary WHERE TwR_Kaucja=1 AND TwR_TwRId=@twrId)
 BEGIN
  SET @komunikat = '##OPT34430##%%TwrKod%%=' + @komunikat+ '##'--@komunikat + SPACE(2) + 'karta cennikowa oznaczona jako KAUCJA. Nie można ustawić KGO.'
  GOTO KONIEC
 END
 IF EXISTS(SELECT * FROM cdn.Towary WHERE TwR_Typ=0 AND TwR_TwRId=@twrId)
 BEGIN
  SET @komunikat = '##OPT34431##%%TwrKod%%=' + @komunikat+ '##'--@komunikat + SPACE(2) + 'karta cennikowa oznaczona jako USŁUGA. Nie można ustawić KGO.'
  GOTO KONIEC
 END
 UPDATE cdn.Towary SET Twr_KosztKGO=@kgo WHERE TwR_TwRId=@twrId
 IF @@ERROR = 0
 begin
  exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @komunikat, 2, '';
  SET @komunikat = '##OPT34432##%%TwrKod%%=' + @komunikat+ '%%Kwota%%=' + CAST(@kgo AS NVARCHAR(20))+ '##'--@komunikat + SPACE(2) + 'zapisano KGO w kwocie: ' + CAST(@kgo AS NVARCHAR(20))
 end
KONIEC:
SET NOCOUNT OFF;
 SELECT @komunikat
END
