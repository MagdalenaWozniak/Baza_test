CREATE PROCEDURE CDN.KompresujElementy(@IDDok int)
 as
BEGIN
 SET NOCOUNT ON
  DECLARE @Ilosc decimal(15,4)
  DECLARE @CenaW decimal(17,4)
  DECLARE @Cena0 decimal(17,4)
  DECLARE @KatID integer
  DECLARE @TwrNazwa NVARCHAR(255)
  DECLARE @TwrOpis NVARCHAR(1024)
  DECLARE @JM NVARCHAR(20)
  DECLARE @StawkaVAT decimal(15,4)
  DECLARE @Lp integer
  DECLARE ELEMENTY CURSOR FAST_FORWARD FOR
 select sum(TrE_iloscjm), TrE_cenaw, TrE_cena0, TrE_stawka, ISNULL(TrE_katid,0), TrE_twrnazwa, TrE_twropis, TrE_jm from CDN.traelem  where TrE_TrNId = @IDDok group by TrE_twrid, TrE_cenaw, TrE_cena0, TrE_stawka, TrE_katid, TrE_twrnazwa, TrE_twropis, TrE_jm
  BEGIN
    SET @Lp = 1
    OPEN ELEMENTY
    WHILE 1 = 1
    BEGIN
      FETCH NEXT FROM ELEMENTY INTO @Ilosc, @CenaW, @Cena0, @StawkaVAT, @KatID, @TwrNazwa, @TwrOpis, @JM
      IF @@FETCH_STATUS <> 0 BREAK
 update CDN.traelem set TrE_iloscjm = @Ilosc, TrE_lp = @Lp, TrE_LpPow = @Lp where TrE_TrNId = @IDDok and TrE_cenaw = @cenaW and TrE_stawka = @stawkavat and TrE_cena0 = @Cena0 and ISNULL(TrE_katid,0) = @KatID and TrE_twrnazwa = @TwrNazwa and TrE_twropis = @TwrOpis and TrE_jm = @JM
 delete from CDN.traelem where TrE_treid not in (select top 1 TrE_treid from CDN.traelem where TrE_TrNId = @IDDok and TrE_cenaw = @cenaW and TrE_stawka = @stawkavat and TrE_cena0 = @Cena0 and ISNULL(TrE_katid,0) = @KatID and TrE_twrnazwa = @TwrNazwa and TrE_twropis = @TwrOpis and TrE_jm = @JM) and TrE_TrNId = @IDDok and TrE_cenaw = @cenaW and TrE_stawka = @stawkavat and TrE_cena0 = @Cena0 and ISNULL(TrE_katid,0) = @KatID and TrE_twrnazwa = @TwrNazwa and TrE_twropis = @TwrOpis and TrE_jm = @JM
 SET @Lp=@Lp+1
    END
   END
   CLOSE ELEMENTY
   DEALLOCATE ELEMENTY
 SET NOCOUNT OFF
END
