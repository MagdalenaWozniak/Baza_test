-- Ustawienie PLU i Nazwy fiskalnej na podstawie kodu i nazwy
CREATE PROCEDURE [CDN].[UstawTwrPLUiNazweFisk]
@twrId INT, @UsunKod INT, @UsunNazwe INT, @KopiujKod INT,@KopiujNazwe INT, @SkrocNazwe INT, @IloscZnakow INT
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE
 @komunikat NVARCHAR(255),
 @PLU NVARCHAR(18),
 @NazwaFiskalna NVARCHAR(40),
 @PLUOld NVARCHAR(18),
 @NazwaFiskalnaOld NVARCHAR(40),
 @Kod NVARCHAR(50)
 if @IloscZnakow = 0
    set @IloscZnakow = 40
 select @PLUOld = '',@NazwaFiskalnaOld = ''
 select @PLUOld = Twr_PLU,@NazwaFiskalnaOld = Twr_NazwaFiskalna, @PLU = substring(twr_kod,1,18),@NazwaFiskalna = substring(twr_nazwa,1,@IloscZnakow),@Kod = Twr_Kod from cdn.towary where twr_twrid = @twrId
 SET @komunikat = ''
 SELECT @komunikat = Twr_Kod FROM cdn.Towary WHERE TwR_TwRId=@twrId
if @UsunKod = 1
 BEGIN
 update cdn.towary set twr_PLU =  '', Twr_TS_mod = GetDate() where twr_twrid = @twrId
 exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
 END
if @UsunNazwe = 1
 BEGIN
 update cdn.towary set Twr_NazwaFiskalna =  '', Twr_TS_mod = GetDate() where twr_twrid = @twrId
 exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
 END
 if @KopiujKod = 1
 BEGIN
  if len(@PLUOld) <> 0
  begin
    SET @komunikat = '##OPT34433##%TwrKod%=' + @komunikat+ '##'--@komunikat + SPACE(2) + 'Istnieje już PLU.'
 if @KopiujNazwe = 1
 BEGIN
  if len(@NazwaFiskalnaOld) <> 0
  begin
  SET @komunikat = '##OPT34434##%TwrKod%=' + @komunikat+ '##'--@komunikat + SPACE(2) + 'Istnieje już nazwa fisklana.'
  GOTO KONIEC
  end
  update cdn.towary set Twr_NazwaFiskalna =  @NazwaFiskalna, Twr_TS_mod = GetDate() where twr_twrid = @twrId
  exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
 END
    GOTO KONIEC
  end
  IF ISNUMERIC(@PLU) = 0
  BEGIN
     SET @komunikat = '##OPT34435##%TwrKod%=' + @komunikat+ '##'--@komunikat + SPACE(2) + 'kod nie jest numeryczny.'
 if @KopiujNazwe = 1
 BEGIN
  if len(@NazwaFiskalnaOld) <> 0
  begin
  SET @komunikat = '##OPT34434##%TwrKod%=' + @komunikat+ '##'--@komunikat + SPACE(2) + 'Istnieje już nazwa fisklana.'
  GOTO KONIEC
  end
  update cdn.towary set twr_NazwaFiskalna =  @NazwaFiskalna, Twr_TS_mod = GetDate() where twr_twrid = @twrId
  exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
 END
     GOTO KONIEC
  END
    IF NOT EXISTS (select twr_twrid from cdn.towary where twr_PLU =  @PLU and twr_twrid <> @twrId)
 begin
  update cdn.towary set twr_PLU =  @PLU, Twr_TS_mod = GetDate() where twr_twrid = @twrId
  exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
 end
    ELSE
    BEGIN
      SET @komunikat = '##OPT34436##%TwrKod%=' + @komunikat+ '##'--@komunikat + SPACE(2) + 'PLU nie jest unikalne.'
 if @KopiujNazwe = 1
 BEGIN
  if len(@NazwaFiskalnaOld) <> 0
  begin
  SET @komunikat = '##OPT34434##%TwrKod%=' + @komunikat+ '##'--@komunikat + SPACE(2) + 'Istnieje już nazwa fisklana.'
  GOTO KONIEC
  end
  update cdn.towary set twr_NazwaFiskalna =  @NazwaFiskalna, Twr_TS_mod = GetDate() where twr_twrid = @twrId
  exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
 END
      GOTO KONIEC
    END
 END
 if @KopiujNazwe = 1
 BEGIN
  if len(@NazwaFiskalnaOld) <> 0
  begin
  SET @komunikat =  '##OPT34434##%TwrKod%=' + @komunikat+ '##'--@komunikat + SPACE(2) + 'Istnieje już nazwa fisklana.'
  GOTO KONIEC
  end
  update cdn.towary set twr_NazwaFiskalna =  @NazwaFiskalna, Twr_TS_mod = GetDate() where twr_twrid = @twrId
  exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
 END
 IF @@ERROR = 0
  SET @komunikat = '##OPT34437##%TwrKod%=' + @komunikat+ '##'--@komunikat + SPACE(2) + ' ustawiono dane. '
KONIEC:
SET NOCOUNT OFF;
 SELECT @komunikat
END
