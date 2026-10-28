CREATE PROCEDURE CDN.AktualizujStawkiVatHaMag
  @TrnId INT      -- id dokumentu
AS
SET NOCOUNT ON
declare
 @TrEID int ,
 @TreTwrId int,
 @TrnTypNB tinyint,
 @TrnPlatElemSys tinyint,
 @TrnKursL decimal (15,4),
 @TrnKursM decimal (5,0),
 @TrnRodzaj int,
 @whereParam NVARCHAR(1024)
IF (exists(select TrN_TrNID from CDN.TraNag where TrN_TrNID = @TrnId and
 TrN_Bufor = 1 and TrN_Korekta = 0 and TrN_TypDokumentu in (302,305,301,308,309,320,306,307,322) and
TrN_Rodzaj NOT IN (302004, 301004,302006, 302009, 306010, 305004, 301050)))
BEGIN
select @TrnTypNB = TrN_TypNB,
  @TrnPlatElemSys = TrN_PlatElemWalSys,
  @TrnKursL = TrN_KursL,
  @TrnKursM = TrN_KursM,
  @TrnRodzaj = TrN_Rodzaj from CDN.TraNag where TrN_TrNID = @TrnId
DECLARE AktualizowaneElementy CURSOR LOCAL FAST_FORWARD FOR
  SELECT
Tre_treId,
TrE_TwrId
  FROM CDN.TraElem where tre_trnId = @trnId
   OPEN AktualizowaneElementy
       WHILE 1=1
BEGIN
 FETCH NEXT FROM AktualizowaneElementy INTO
 @TrEID,
 @TreTwrId
   IF @@FETCH_STATUS <> 0 BREAK
  EXEC CDN.AktualizujStawkeVATTraElem
 @TrEID,
 @TreTwrId,
 @TrnTypNB,
 @TrnPlatElemSys,
 @TrnKursL,
 @TrnKursM,
 @TrnRodzaj
END
CLOSE AktualizowaneElementy
DEALLOCATE AktualizowaneElementy
SELECT @whereParam = 'trn_trnid = ' + convert(varchar(15),@TrnId)
exec cdn.RejestrOperacjiDodajEx @ObiektTyp = 'trn_typdokumentu', @ObiektSubTyp = '0', @ObiektID = 'trn_trnid', @ObiektNazwa = 'trn_numerpelny',
     @OperacjaTyp = 2, @Opis = '''Aktualizacja stawek vat''', @From = 'cdn.tranag', @Where = @whereParam
EXEC CDN.AktualizujTraVATTraNag @TrnId
--splitpay
 update CDN.TraNag set TrN_WartoscSP =
    isnull((select SUM(TrE_WartoscBrutto) from CDN.TraElem where TrE_TrNId = @TrnId and TrE_SplitPay = 1 and TrE_Flaga != 4),0)
    where TrN_TrNID = @TrnId
select 1;
END
ELSE
select 0;
SET NOCOUNT OFF
