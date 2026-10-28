CREATE  PROCEDURE [CDN].[ZestawienieSkladekZaplaconychOdliczonych] @PPM_Rok  INT, @PPM_PraID INT
AS
SET NOCOUNT ON
DECLARE @Month      INT
DECLARE @Year       INT
DECLARE @ImieNazwisko NVARCHAR (200)
DECLARE @Pit36SpoleczneZaplacone  DEC (15,2)
DECLARE @Pit36SpoleczneOdliczone  DEC (15,2)
DECLARE @Pit36ZdrowotneZaplacone  DEC (15,2)
DECLARE @Pit36ZdrowotneOdliczone  DEC (15,2)
DECLARE @Pit36LSpoleczneZaplacone  DEC (15,2)
DECLARE @Pit36LSpoleczneOdliczone  DEC (15,2)
DECLARE @Pit36LZdrowotneZaplacone  DEC (15,2)
DECLARE @Pit36LZdrowotneOdliczone  DEC (15,2)
DECLARE @Pit28SpoleczneZaplacone  DEC (15,2)
DECLARE @Pit28SpoleczneOdliczone  DEC (15,2)
DECLARE @Pit28ZdrowotneZaplacone  DEC (15,2)
DECLARE @Pit28ZdrowotneOdliczone  DEC (15,2)
CREATE TABLE #skladki (
 Tmp_Rok          INT,
 Tmp_Mc           INT,
 Tmp_Name   NVARCHAR (200),
 Tmp_Pit36SpoleczneZaplacone DEC (15,2),
 Tmp_Pit36SpoleczneOdliczone DEC (15,2),
 Tmp_Pit36ZdrowotneZaplacone DEC (15,2),
 Tmp_Pit36ZdrowotneOdliczone DEC (15,2),
 Tmp_Pit36LSpoleczneZaplacone DEC (15,2),
 Tmp_Pit36LSpoleczneOdliczone DEC (15,2),
 Tmp_Pit36LZdrowotneZaplacone DEC (15,2),
 Tmp_Pit36LZdrowotneOdliczone DEC (15,2),
 Tmp_Pit28SpoleczneZaplacone DEC (15,2),
 Tmp_Pit28SpoleczneOdliczone DEC(15,2),
 Tmp_Pit28ZdrowotneZaplacone DEC(15,2),
 Tmp_Pit28ZdrowotneOdliczone DEC (15,2)
 )
--Inicjalizuje wartosci domyslne
SET @Month = 0
WHILE @Month<12
BEGIN
 SET @Pit36SpoleczneZaplacone=0
 SET @Pit36SpoleczneOdliczone=0
 SET @Pit36ZdrowotneZaplacone=0
 SET @Pit36ZdrowotneOdliczone=0
 SET @Pit36LSpoleczneZaplacone=0
 SET @Pit36LSpoleczneOdliczone=0
 SET @Pit36LZdrowotneZaplacone=0
 SET @Pit36LZdrowotneOdliczone=0
 SET @Pit28SpoleczneZaplacone=0
 SET @Pit28SpoleczneOdliczone=0
 SET @Pit28ZdrowotneZaplacone=0
 SET @Pit28ZdrowotneOdliczone=0
 SET @Year=@PPM_Rok
 SET @Month=@Month+1
 SELECT @ImieNazwisko = PRE_Imie1 + ' ' + PRE_Nazwisko from cdn.PracEtaty where PRE_PraId=@PPM_PraId
 SELECT @Pit36SpoleczneZaplacone = cast (PPK_Wartosc as decimal (15,2)) from cdn.pracpitmies left outer join cdn.pracpitkwoty on PPK_PPMId=PPM_PPMId where PPM_PraId=@PPM_PraID and PPM_Miesiac=@Month and PPK_Numer=22300 and PPM_Rok=@Year
 SELECT @Pit36SpoleczneOdliczone = DkE_WartoscL from cdn.DeklNag left outer join cdn.DeklElem on DkN_DkNID=DkE_DkNID where DkN_TypDeklar = 2 and DkN_PraID=@PPM_PraID  and DkN_RokMiesiac = 100*@Year+@Month and DkE_Numer=22300 and DkN_Finalna=1
 SELECT @Pit36ZdrowotneZaplacone = cast (PPK_Wartosc as decimal (15,2)) from cdn.pracpitmies left outer join cdn.pracpitkwoty on PPK_PPMId=PPM_PPMId where PPM_PraId=@PPM_PraID  and PPM_Miesiac=@Month and PPK_Numer=41200 and PPM_Rok=@Year
 SELECT @Pit36ZdrowotneOdliczone = DkE_WartoscL from cdn.DeklNag left outer join cdn.DeklElem on DkN_DkNID=DkE_DkNID where DkN_TypDeklar = 2 and DkN_PraID=@PPM_PraID  and DkN_RokMiesiac = 100*@Year+@Month and DkE_Numer=28200 and DkN_Finalna=1
 SELECT @Pit36LSpoleczneZaplacone = cast (PPK_Wartosc as decimal (15,2)) from cdn.pracpitmies left outer join cdn.pracpitkwoty on PPK_PPMId=PPM_PPMId where PPM_PraId=@PPM_PraID  and PPM_Miesiac=@Month and PPK_Numer=22305 and PPM_Rok=@Year
 SELECT @Pit36LSpoleczneOdliczone = DkE_WartoscL from cdn.DeklNag left outer join cdn.DeklElem on DkN_DkNID=DkE_DkNID where DkN_TypDeklar = 12 and DkN_PraID=@PPM_PraID  and DkN_RokMiesiac = 100*@Year+@Month and DkE_Numer=22305 and DkN_Finalna=1
 SELECT @Pit36LZdrowotneZaplacone = cast (PPK_Wartosc as decimal (15,2)) from cdn.pracpitmies left outer join cdn.pracpitkwoty on PPK_PPMId=PPM_PPMId where PPM_PraId=@PPM_PraID  and PPM_Miesiac=@Month and PPK_Numer=41205 and PPM_Rok=@Year
 SELECT @Pit36LZdrowotneOdliczone = DkE_WartoscL from cdn.DeklNag left outer join cdn.DeklElem on DkN_DkNID=DkE_DkNID where DkN_TypDeklar = 12 and DkN_PraID=@PPM_PraID  and DkN_RokMiesiac = 100*@Year+@Month and DkE_Numer=41205 and DkN_Finalna=1
 SELECT @Pit28SpoleczneZaplacone = cast (PPK_Wartosc as decimal (15,2)) from cdn.pracpitmies left outer join cdn.pracpitkwoty on PPK_PPMId=PPM_PPMId where PPM_PraId=@PPM_PraID  and PPM_Miesiac=@Month and PPK_Numer=22300 and PPM_Rok=@Year
 SELECT @Pit28SpoleczneOdliczone = DkE_WartoscL from cdn.DeklNag left outer join cdn.DeklElem on DkN_DkNID=DkE_DkNID where DkN_TypDeklar = 4 and DkN_PraID=@PPM_PraID  and DkN_RokMiesiac = 100*@Year+@Month and DkE_Numer=22300 and DkN_Finalna=1
 SELECT @Pit28ZdrowotneZaplacone = cast (PPK_Wartosc as decimal (15,2)) from cdn.pracpitmies left outer join cdn.pracpitkwoty on PPK_PPMId=PPM_PPMId where PPM_PraId=@PPM_PraID  and PPM_Miesiac=@Month and PPK_Numer=41300 and PPM_Rok=@Year
 SELECT @Pit28ZdrowotneOdliczone = DkE_WartoscL from cdn.DeklNag left outer join cdn.DeklElem on DkN_DkNID=DkE_DkNID where DkN_TypDeklar = 4 and DkN_PraID=@PPM_PraID  and DkN_RokMiesiac = 100*@Year+@Month and DkE_Numer=41300 and DkN_Finalna=1
   insert into #skladki values (@Year, @Month,@ImieNazwisko, @Pit36SpoleczneZaplacone,@Pit36SpoleczneOdliczone,@Pit36ZdrowotneZaplacone,@Pit36ZdrowotneOdliczone,
        @Pit36LSpoleczneZaplacone,@Pit36LSpoleczneOdliczone,@Pit36LZdrowotneZaplacone,@Pit36LZdrowotneOdliczone,@Pit28SpoleczneZaplacone,@Pit28SpoleczneOdliczone,@Pit28ZdrowotneZaplacone,@Pit28ZdrowotneOdliczone)
END
SET NOCOUNT OFF
SELECT
 * FROM #skladki
