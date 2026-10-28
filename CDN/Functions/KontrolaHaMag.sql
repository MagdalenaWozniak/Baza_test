CREATE FUNCTION CDN.KontrolaHaMag ( @TrN_TrNId INT,@KontrolaMarzy INT, @KontrolaDostaw INT )
  RETURNS     NVARCHAR(250)
  AS
  BEGIN
    -- zmienne pomocnicze
    DECLARE
      @TrE_TwrKod        NVARCHAR(50),
      @TrE_TwrNazwa      NVARCHAR(50),
   @Pde_TwrKod        NVARCHAR(50),
      @Pde_TwrNazwa      NVARCHAR(50),
      @TrN_NumerPelny    NVARCHAR(31),
      @TrN_MagZrdId      INT,
      @TrN_Rodzaj        INT,
      @TrN_TypDokumentu  INT,
   @TrN_Fiskalna   TINYINT,
      @TrN_TypNB   TINYINT,
      @TrN_DataOpe       DATETIME,
      @TrE_TrEId         INT,
      @TwR_MinCenaMarza  DECIMAL(15,2),
      @TwR_TypMinimum    TINYINT,
      @TrN_Korekta       TINYINT,
      @TrE_WartoscNetto  DECIMAL(15,2),
      @TrE_WartoscZakupu DECIMAL(15,2),
      @TrE_Rabat         DECIMAL(15,2),
      @TwC_Marza         DECIMAL(15,2),
      @TwC_MarzaWStu     DECIMAL(15,2),
      @TrE_Ilosc         DECIMAL(15,4),
      @TrE_IloscJM       DECIMAL(15,4),
      @TrE_Cena0WD       DECIMAL(17,4),
      @TrE_CenaWWD       DECIMAL(17,4),
      @Rabat             DECIMAL(15,2),
      @MarzaWStu         INT,
      @Typ               INT,
      @Trn_TrsTyp        INT,
      @TrN_FaID          INT,
      @TrN_GIDFirma      INT,
      @Komunikat         NVARCHAR(250),
      @Stawka            NVARCHAR(10),
      @Wartosc           NVARCHAR(17),
      @StawkaDuplikat    NVARCHAR(40)
   DECLARE @MagaId TABLE (MagId INT)
        INSERT INTO @MagaId (MagId )
          SELECT TrE_MagId
          FROM CDN.TraElem
          WHERE TrE_TrNId = @TrN_TrNId
        INSERT INTO @MagaId (MagId )
          SELECT pde_magid
          FROM CDN.ProdElem
          JOIN CDN.TraElem  ON TrE_TrEId = Pde_TrEId
          WHERE TrE_TrNId = @TrN_TrNId
   SET @Komunikat = ''
    -- przeczytanie rodzaju
    SELECT TOP 1
      @TrN_Rodzaj = TrN_Rodzaj,
      @TrN_MagZrdId = TrN_MagZrdId,
      @TrN_Korekta  = TrN_Korekta,
      @TrN_DataOpe  = TrN_DataOpe,
      @TrN_TypDokumentu = TrN_TypDokumentu,
      @Trn_TrsTyp  = Trn_TrsTyp,
      @TrN_FaID  = TrN_FaID,
      @TrN_GIDFirma = ISNULL(TrN_GIDFirma,0) ,
   @TrN_Fiskalna = TrN_Fiskalna,
      @TrN_TypNB = TrN_TypNB
    FROM CDN.TraNag
    WHERE TrN_TrNId = @TrN_TrNId
    --  kontrola, czy towary z zapisywanego dokumetnu występują na BOM-ie o dacie większej niż data dokumentu
    IF ( @TrN_Rodzaj NOT IN  ( 302100, 305100, 301100 ) ) AND ( CONVERT(INT, @TrN_Rodzaj/1000) NOT IN (322, 321) ) -- nie sprawdzamy dla dokumentów pierwotnych i wewnętrznych
      BEGIN
        DECLARE @TwrIdBOM TABLE (TwrId INT, NumerPelny NVARCHAR(31))
        INSERT INTO @TwrIdBOM (TwrId, NumerPelny )
          SELECT TrE_TwrId, TrN_NumerPelny
          FROM CDN.TraElem
           JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
        WHERE TrN_TypDokumentu = 310
          AND TrN_Rodzaj = 310000
          AND TrN_MagZrdId in( select * from @MagaId)
          AND TrE_MagId in( select * from @MagaId)
          AND TrN_Bufor = 0
          AND TrN_DataOpe > @TrN_DataOpe
        GROUP BY TrE_TwrId, TrN_NumerPelny
IF EXISTS (SELECT * FROM @TwrIdBOM)  and @TrN_Rodzaj not in (320000,302200)
BEGIN
        SELECT TOP 1
          @TrE_TwrKod     = TrE_TwrKod,
          @TrE_TwrNazwa   = substring(max(TrE_TwrNazwa),0,30),
          @TrN_NumerPelny = NumerPelny
        FROM CDN.TraElem
--        JOIN CDN.TraNag DOKN ON DOKE.TrE_TrNId = DOKN.TrN_TrNId
--        JOIN CDN.TraElem BOME ON BOME.TrE_TwrId = DOKE.TrE_TwrId
--        JOIN CDN.TraNag BOMN  ON BOME.TrE_TrNId = BOMN.TrN_TrNId AND DOKN.TrN_MagZrdId = BOMN.TrN_MagZrdId
          JOIN @TwrIdBOM ON TwrId =TrE_TwrId
        WHERE TrE_TrNId = @TrN_TrNId
--          AND BOMN.TrN_Rodzaj = 310000
--          AND BOMN.TrN_Bufor = 0
--          AND BOMN.TrN_DataOpe > DOKE.TrE_DataOpe
        GROUP BY TrE_TwrKod, NumerPelny
        IF @TrE_TwrKod IS NOT NULL
          BEGIN
            --SET @Komunikat = 'Zapis niemożliwy. Towar ' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ '] występuje na bilansie otwarcia nr ' + @TrN_NumerPelny + '. Data BOM jest późniejsza niż data transakcji. '
   SET @Komunikat = '##OPT34316##%s1%=' +@TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']%s2%=' + @TrN_NumerPelny + '##'
            RETURN @Komunikat
          END
      END
END
    -- kontrola, czy zapisywany towar nie występuje na nieprzekształconym arkuszu inwntaryzacyjnym
    IF @TrN_Rodzaj NOT IN ( 301004, 302004, 306004, 307004, 306006, 302008, 302009, 320008, 320009, 305008, 307010, 301011, 309008, 309009, 305004, 302005, 306005, 305005, 306007, 301005, 307005, 301006, 307006, 302002, 302003, 320200, 308011, 306008, 306010, 308008, 308009, 308010, 302200, 302202, 322000, 322021, 321022, 350000, 350008, 350009, 345000,312008,304008,307003, 307011 )
      BEGIN
       DECLARE @TwrIdAI TABLE (TwrId INT, NumerPelny NVARCHAR(31))
        INSERT INTO @TwrIdAI (TwrId, NumerPelny )
          SELECT TrE_TwrId, TrN_NumerPelny
          FROM CDN.TraElem
           JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
        WHERE TrN_TypDokumentu = 311
          AND TrN_Rodzaj = 311000
          AND TrN_MagZrdId in( select * from @MagaId)
          AND TrE_MagId in( select * from @MagaId)
          AND TrN_Bufor = 0
          AND TrN_TrNId <> @TrN_TrNId
        GROUP BY TrE_TwrId, TrN_NumerPelny
IF EXISTS (SELECT * FROM @TwrIdAI)
BEGIN
        SELECT TOP 1
          @TrE_TwrKod        = TrE_TwrKod,
          @TrE_TwrNazwa      = substring(max(TrE_TwrNazwa),0,30),
          @TrN_NumerPelny    = NumerPelny
        FROM CDN.TraElem
--          JOIN CDN.TraNag DOKN ON DOKE.TrE_TrNId = DOKN.TrN_TrNId
--          JOIN CDN.TraElem AIE ON AIE.TrE_TwrId = DOKE.TrE_TwrId
--          JOIN CDN.TraNag AIN  ON AIE.TrE_TrNId = AIN.TrN_TrNId AND DOKN.TrN_MagZrdId = AIN.TrN_MagZrdId
         JOIN @TwrIdAI ON TwrId = TrE_TwrId
        WHERE TrE_TrNId = @TrN_TrNId
--          AND AIN.TrN_Rodzaj = 311000
--          AND AIN.TrN_Bufor = 0
--          AND AIN.TrN_TrNId <> @TrN_TrNId
        GROUP BY TrE_TwrKod, NumerPelny
        IF @TrE_TwrKod IS NOT NULL
          BEGIN
            --SET @Komunikat = 'Zapis niemożliwy. Towar '  + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+  '] występuje na nieprzekształconym arkuszu inwentaryzacyjnym nr ' + @TrN_NumerPelny + '. Należy anulować arkusz inwentaryzacyjny lub skasować dokument znajdujący się w buforze.'
   SET @Komunikat = '##OPT34317##%s1%=' + @TrE_TwrKod+' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']%s2%=' + @TrN_NumerPelny + '##'
            RETURN @Komunikat
          END
  SELECT TOP 1
          @TrE_TwrKod        = Twr_Kod,
          @TrE_TwrNazwa      = substring(max(Twr_Nazwa),0,30),
          @TrN_NumerPelny    = NumerPelny
        FROM CDN.ProdElem
        JOIN CDN.TraElem  ON TrE_TrEId = Pde_TrEId
        JOIN CDN.Towary ON Pde_TwrId = Twr_TwrID
         JOIN @TwrIdAI ON TwrId = Pde_TwrId
        WHERE tre_typdokumentu = 317 and TrE_TrNId = @TrN_TrNId
        GROUP BY Twr_Kod, NumerPelny
        IF @TrE_TwrKod IS NOT NULL
          BEGIN
            --SET @Komunikat = 'Zapis niemożliwy. Towar '  + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+  '] występuje na nieprzekształconym arkuszu inwentaryzacyjnym nr ' + @TrN_NumerPelny + '. Należy anulować arkusz inwentaryzacyjny lub skasować dokument znajdujący się w buforze.'
   SET @Komunikat = '##OPT34317##%s1%=' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']%s2%=' + @TrN_NumerPelny + '##'
            RETURN @Komunikat
          END
      END
END
if  @TrN_Rodzaj = 302202
begin
select @Wartosc = ''
select top 1 @Stawka = case when trv_Flaga = 4 then 'NP' else case when trv_Flaga = 1 then  'ZW' else convert(NVARCHAR(5),trv_stawka)+' %' end end,
@Wartosc = convert(NVARCHAR(15),SUM(ISNULL(trv_nettowal,0))  + SUM(ISNULL(trv_vatwal,0)))
 from
(select trv_stawka,trv_Flaga,Trv_Zrodlowa,
SUM(ISNULL(trv_netto,0)) as trv_netto,
SUM(ISNULL(trv_vat,0)) as trv_vat,
SUM(ISNULL(trv_nettowal,0)) as trv_nettowal,
SUM(ISNULL(trv_vatwal,0)) as trv_vatwal
from cdn.travat
where  trv_trnid in (select trn_zwrid from cdn.tranag where trn_trnid = @TrN_TrNId and trn_bufor <> -1)  or trv_trnid in (select trn_trnid from cdn.tranag where trn_zwrid in(select trn_zwrid from cdn.tranag where trn_trnid = @TrN_TrNId and trn_bufor <> -1) and trn_bufor <> -1)
GROUP BY trv_stawka,Trv_Zrodlowa,trv_Flaga
union all
select trz_stawka as trv_stawka,trz_Flaga as trv_Flaga,Trz_Zrodlowa as Trv_Zrodlowa,
 - SUM(ISNULL(trz_kwotanettosys,0)) as trv_netto,
 - SUM(ISNULL(trz_kwotavatsys,0)) as trv_vat,
 - SUM(ISNULL(trz_kwotanetto,0)) as trv_nettowal,
 - SUM(ISNULL(trz_kwotavat,0)) as  trv_vatwal
from CDN.TraFakZaliczkowe
join cdn.tranag on trz_trnid = trn_trnid
where trz_fzid in (select trn_zwrid from cdn.tranag where trn_trnid = @TrN_TrNId and trn_bufor <> -1) and TrZ_Uwzgledniac = 1 and  trn_bufor <> -1
GROUP BY trz_stawka,Trz_Zrodlowa,trz_Flaga)  a
GROUP BY trv_stawka,Trv_Zrodlowa,trv_Flaga
having  SUM(ISNULL(trv_nettowal,0))  + SUM(ISNULL(trv_vatwal,0)) < 0
     if @Wartosc <> ''
     begin
  --SET @Komunikat = 'Faktura zaliczkowa jest częściowo rozliczona na fakturach finalnych. Dla stawki vat:' + @Stawka + ' zmniejsz wartość o ' + @Wartosc
  SET @Komunikat = '##OPT34318##%s1%=' + @Stawka+ '%s2%=' + @Wartosc + '##'
  RETURN @Komunikat
     end
end
IF @KontrolaDostaw = 1 AND @TrN_GIDFirma <>2
BEGIN
    -- kontrola czy WZ do Pf nie maja raz wskazania dostaw a raz nie
    IF @TrN_Rodzaj =306010
      BEGIN
        SELECT TOP 1
          @TrE_TwrKod        = ElemWZStary.TrE_TwrKod,
          @TrE_TwrNazwa      = substring(ElemWZStary.TrE_TwrNazwa,0,30),
          @Typ               = ElemWZStary.TrE_WyborDostaw
        FROM CDN.TraElem ElemWZNowy
        JOIN CDN.TraNagRelacje relwznowy ON relwznowy.TrR_TrNId = ElemWZNowy.TrE_TrNId
        JOIN CDN.TraNagRelacje relpf ON relpf.TrR_FaId = relwznowy.TrR_TrNId AND relpf.TrR_trntyp = 320 and relpf.TrR_fatyp = 306
        JOIN CDN.TraNagRelacje relwzstary ON relwzstary.TrR_FaId = relpf.TrR_TrNId AND relwzstary.TrR_trntyp = 306
        JOIN CDN.TraElem ElemWZStary  ON relwzstary.TrR_TrNId = ElemWZStary.TrE_TrNId AND ElemWZNowy.TrE_Lppow = ElemWZStary.TrE_lppow
        WHERE ElemWZNowy.TrE_TrNId = @TrN_TrNId and relwzstary.TrR_TrNId <> @TrN_TrNId AND ElemWZNowy.TrE_wybordostaw<>ElemWZStary.TrE_wybordostaw
        and not exists (select relFA.trr_trnid from CDN.TraNagRelacje relFA where relFA.trr_trnid = relwzstary.TrR_trnid and relFA.trr_fatyp = 302)
        IF @TrE_TwrKod IS NOT NULL
          BEGIN
            IF @Typ = 1
    --SET @Komunikat = 'Zapis niemożliwy. Towar ' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ '] na wcześniejszych WZ do PF jest ze wskazaniem dostaw. Wskaż dostawę dla towaru.'
    SET @Komunikat = '##OPT34319##%s1%=' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']##'
            ELSE
    --SET @Komunikat = 'Zapis niemożliwy. Towar ' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ '] na wcześniejszych WZ do PF nie ma wskazanych dostaw. Zapisz ten towar bez wskazania dostaw.'
    SET @Komunikat = '##OPT34320##%s1%=' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']##'
            RETURN @Komunikat
          END
     END
   -- kontrola czy ma cechy dla dostaw
   IF ( ((@TrN_TypDokumentu IN  (  306, 304, 312 ) and @TrN_Rodzaj NOT IN (306006,312010) ) OR ( @TrN_TypDokumentu IN  ( 302, 305) AND @Trn_TrsTyp = 2 and @TrN_Rodzaj NOT IN (302005,302004,302100,305100,302200,302202) )  OR (@TrN_Rodzaj =302004 AND ISNULL(@TrN_FAID,0) = 0))AND @TrN_Korekta = 0
   AND EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1875 AND Fir_Wartosc  = 1 )
   AND EXISTS (SELECT TrE_TwrKod from cdn.traelem
   JOIN CDN.Twratrybuty ON Tre_Twrid = Twa_Twrid
   JOIN CDN.Towary ON Tre_Twrid = Twr_Twrid
   JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
   where tre_trnid = @TrN_TrNId  AND TrN_Bufor = 0  AND TrN_DokMosMMId = 0 and isnull(tre_WyborDostaw,0) = 0
   and Twr_typ = 1 and tre_kaucja <> 1 and tre_kaucja <> 2
   and ((Tre_lppow > 0 and @TrN_Rodzaj NOT IN (302004,305004)) OR (Tre_lppow < 0 and @TrN_Rodzaj IN (302004,305004)))
   and TwA_CzyPrzenosicNaDostawy = 1))
   begin
   select @TrE_TwrKod = TrE_TwrKod,@TrE_TwrNazwa      = substring(TrE_TwrNazwa,0,30) from cdn.traelem
   JOIN CDN.Twratrybuty on tre_twrid = twa_twrid
   JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
   JOIN CDN.Towary ON Tre_Twrid = Twr_Twrid
   where tre_trnid = @TrN_TrNId  AND TrN_Bufor = 0 and isnull(tre_WyborDostaw,0) = 0
   and Twr_typ = 1 and tre_kaucja <> 1 and tre_kaucja <> 2
   and ((Tre_lppow > 0 and @TrN_Rodzaj NOT IN (302004,305004)) OR (Tre_lppow < 0 and @TrN_Rodzaj IN (302004,305004)))
   and TwA_CzyPrzenosicNaDostawy = 1
     --SET @Komunikat = 'Zapis niemożliwy. Dla Towaru ' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ '] nie wskazano konkretnych dostaw.'
  SET @Komunikat = '##OPT34321##%s1%=' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']##'
     RETURN @Komunikat
   end
   IF ( ((@TrN_TypDokumentu IN  (  306, 304, 312 ) and @TrN_Rodzaj NOT IN (306006,312010) ) OR ( @TrN_TypDokumentu IN  ( 302, 305) AND @Trn_TrsTyp = 2 and @TrN_Rodzaj NOT IN (302005,302004,302100,305100,302200,302202) )  OR (@TrN_Rodzaj =302004 AND ISNULL(@TrN_FAID,0) = 0))AND @TrN_Korekta = 0
   and exists (
   select tre_treid from cdn.traelem
   left join cdn.traselemdost on TsD_TrEId = tre_treid
   where TsD_TsDID is not null and TrE_TrNId =  @TrN_TrNId
   group by tre_treid
   having  max(TrE_IloscJM) != sum(TsD_Ilosc)
   ))
   begin
    select @TrE_TwrKod = TrE_TwrKod,@TrE_TwrNazwa = substring(TrE_TwrNazwa,0,30) from cdn.traelem where tre_treid in(
    select max(tre_treid) from cdn.traelem
    left join cdn.traselemdost on TsD_PdEId = tre_treid
    where TsD_TsDID is not null and TrE_TrNId =  @TrN_TrNId
    group by tre_treid
    having  max(TrE_IloscJM) != sum(TsD_Ilosc))
    SET @Komunikat = '##OPT34897##%s1%=' +@TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']##'
   end
         -- kontrola czy ma cechy dla dostaw
   IF ( @TrN_TypDokumentu IN  (  317 )
   AND EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1875 AND Fir_Wartosc  = 1 )
   AND EXISTS (SELECT TrE_TwrKod from cdn.traelem
   JOIN CDN.ProdElem on PdE_TrEId = TrE_TrEID
   JOIN CDN.Twratrybuty on twa_twrid = PdE_TwrId
   JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
   JOIN CDN.Towary ON PdE_TwrId = Twr_Twrid
   where tre_trnid = @TrN_TrNId  AND TrN_Bufor = 0  AND TrN_DokMosMMId = 0 and isnull(PdE_WyborDostaw,0) = 0  and isnull(Pde_zwrid,0) = 0
   and Twr_typ = 1 and tre_kaucja <> 1 and tre_kaucja <> 2
   and TwA_CzyPrzenosicNaDostawy = 1))
   begin
   select @Pde_TwrKod = Twr_Kod,@Pde_TwrNazwa      = substring(Twr_Nazwa,0,30),@TrE_TwrKod = TrE_TwrKod,@TrE_TwrNazwa      = substring(TrE_TwrNazwa,0,30) from cdn.traelem
   JOIN CDN.ProdElem on PdE_TrEId = TrE_TrEID
   JOIN CDN.Twratrybuty on twa_twrid = PdE_TwrId
   JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
   JOIN CDN.Towary ON PdE_TwrId = Twr_Twrid
   where tre_trnid = @TrN_TrNId  AND TrN_Bufor = 0 and isnull(PdE_WyborDostaw,0) = 0  and isnull(Pde_zwrid,0) = 0
   and Twr_typ = 1 and tre_kaucja <> 1 and tre_kaucja <> 2
   and TwA_CzyPrzenosicNaDostawy = 1
     --SET @Komunikat = 'Zapis niemożliwy. Dla Towaru ' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ '] nie wskazano konkretnych dostaw.'
   SET @Komunikat = '##OPT34863##%s1%=' +@TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']%s2%=' + @Pde_TwrKod +' ['+REPLACE(@Pde_TwrNazwa,Char(13) + Char(10),' ')+ ']##'
     RETURN @Komunikat
   end
   IF ( @TrN_TypDokumentu IN  ( 301, 307, 303, 310,317 )  AND @TrN_Korekta = 0 AND @TrN_Rodzaj NOT IN (301090,301100)
   AND EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1876 AND Fir_Wartosc  = 1)
   AND EXISTS (select TrE_TwrKod from cdn.traelem
   JOIN CDN.Twratrybuty on tre_twrid = twa_twrid
   JOIN CDN.Towary ON Tre_Twrid = Twr_Twrid
   JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
   where tre_trnid = @TrN_TrNId AND TrN_Bufor = 0 and isnull(tre_WyborDostaw,0) = 0
   and ((Tre_lppow > 0 and @TrN_Rodzaj NOT IN (301004)) OR (Tre_lppow < 0 and @TrN_Rodzaj IN (301004)))
   and Twr_typ = 1 and tre_kaucja <> 1 and tre_kaucja <> 2
   and TwA_CzyPrzenosicNaDostawy = 1
   ))
   begin
   select @TrE_TwrKod = TrE_TwrKod,@TrE_TwrNazwa   = substring(TrE_TwrNazwa,0,30) from cdn.traelem
   JOIN CDN.Twratrybuty on tre_twrid = twa_twrid
   JOIN CDN.TraNag ON TrE_TrNId = TrN_TrNId
   JOIN CDN.Towary ON Tre_Twrid = Twr_Twrid
   where tre_trnid = @TrN_TrNId AND TrN_Bufor = 0 and isnull(tre_WyborDostaw,0) = 0
   and ((Tre_lppow > 0 and @TrN_Rodzaj NOT IN (301004)) OR (Tre_lppow < 0 and @TrN_Rodzaj IN (301004)))
   and Twr_typ = 1 and tre_kaucja <> 1 and tre_kaucja <> 2
   and TwA_CzyPrzenosicNaDostawy = 1
    --SET @Komunikat = 'Zapis niemożliwy. Dla Towaru ' + @TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ '] nie uzupełniono dostaw.'
 SET @Komunikat = '##OPT34322##%s1%=' +@TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']##'
      RETURN @Komunikat
   end
END -- end KontrolaDostaw
    -- kontrola, czy zapisywany towar nie przekracza minimalnej marzy
    IF @KontrolaMarzy=0 AND @TrN_Korekta=0 AND @TrN_GIDFirma <>2
      BEGIN
        SELECT @MarzaWStu=Fir_Wartosc FROM CDN.firma WHERE Fir_Numer=1624
        DECLARE N CURSOR LOCAL FAST_FORWARD FOR
        SELECT TrE_TrEId,TrE_TwrKod,TwR_MinCenaMarza,TwR_TypMinimum,TrE_WartoscNetto,TrE_WartoscZakupu,TrE_Rabat,TrE_Ilosc,TrE_IloscJM,TrE_Cena0WD,TrE_CenaWWD
        FROM CDN.TraElem
        JOIN CDN.towary ON TrE_twrid=TwR_twrid
        WHERE TrE_TrNId=@TrN_TrNId AND (TrE_WartoscZakupu<>0 or (TrE_WartoscZakupu=0 and TwR_TypMinimum=2))  AND TwR_TypMinimum<>0 AND TwR_TypMinimum is NOT NULL and Tre_ZtwId = 0 and ISNULL(TrE_UslugaZlozonaId,0) = 0
             OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N INTO @TrE_TrEId,@TrE_TwrKod,@TwR_MinCenaMarza,@TwR_TypMinimum,@TrE_WartoscNetto,@TrE_WartoscZakupu,@TrE_Rabat,@TrE_Ilosc,@TrE_IloscJM,@TrE_Cena0WD,@TrE_CenaWWD
                    IF @@FETCH_STATUS <> 0 BREAK
                      IF @TwR_TypMinimum = 1
                       BEGIN
                       IF  @MarzaWStu =1
                         BEGIN
                          IF  @TrE_WartoscNetto = 0
                              SET @TwC_MarzaWStu = -100
                          ELSE
                              SET @TwC_MarzaWStu =ROUND ( ((@TrE_WartoscNetto-@TrE_WartoscZakupu)/@TrE_WartoscNetto)*100,2)
                          END
                       ELSE
                         BEGIN
                              SET @TwC_Marza = ROUND ( ((@TrE_WartoscNetto-@TrE_WartoscZakupu)/@TrE_WartoscZakupu)*100,2)
                         END
                         IF ( @TwC_Marza = -100 )  OR ( @TrE_WartoscNetto = @TrE_WartoscZakupu )
                                 SET @TwC_MarzaWStu = 100
                         ELSE IF @TrE_WartoscNetto = 0
                                 SET @TwC_MarzaWStu = -100
                         IF @MarzaWStu =1 and @TwC_MarzaWStu<@TwR_MinCenaMarza
                          BEGIN
                            --SET @Komunikat = 'Zapis niemożliwy. Towar ' + @TrE_TwrKod + ' - sprzedaż poniżej minimalnej marży.'
       SET @Komunikat = '##OPT34323##%s1%=' + @TrE_TwrKod+ '##'
                            RETURN @Komunikat
                          END
                         ELSE IF @MarzaWStu =0 and @TwC_Marza<@TwR_MinCenaMarza
                          BEGIN
                            --SET @Komunikat = 'Zapis niemożliwy. Towar ' + @TrE_TwrKod + ' - sprzedaż poniżej minimalnej marży.'
       SET @Komunikat = '##OPT34323##%s1%=' + @TrE_TwrKod+ '##'
                            RETURN @Komunikat
                          END
                       END
                      ELSE
                       BEGIN
                         IF @TrE_Ilosc = 0
                               SET @Rabat = @TrE_Rabat
                         ELSE
                            BEGIN
                               IF @TrE_Cena0WD = 0
                                  SET @Rabat  = @TrE_Rabat
                               ELSE
                                  SET @Rabat = ROUND ( (@TrE_Ilosc * @TrE_Cena0WD - @TrE_IloscJM * @TrE_CenaWWD)/(@TrE_Ilosc * @TrE_Cena0WD) * 100,2)
                               IF  @Rabat> @TrE_Rabat
                                  SET @Rabat = @TrE_Rabat
                            END
                         IF @Rabat>@TwR_MinCenaMarza
                          BEGIN
                            --SET @Komunikat = 'Zapis niemożliwy. Towar ' + @TrE_TwrKod + ' - sprzedaż powyżej maksymalnego rabatu.'
       SET @Komunikat = '##OPT34324##%s1%=' +@TrE_TwrKod+ '##'
                            RETURN @Komunikat
                          END
                       END
                 END
              CLOSE N
            DEALLOCATE N
      END
      if @TrN_Rodzaj = 306010
      BEGIN
        set @StawkaDuplikat = ''
        select top 1 @StawkaDuplikat = tre_twrkod from(
        select tre_lppow, tre_stawka,max(tre_twrkod) as tre_twrkod from cdn.traelem where tre_trnid in(select a.trr_faid from cdn.tranagrelacje a
        join cdn.tranag on a.trr_faid = trn_trnid and trn_rodzaj = 306010
        left JOIN cdn.TraNagRelacje b on TrN_TrNId = b.TrR_TrNId and  b.TrR_FaTyp = 302
        where a.trr_trnid in  (select trr_faid from cdn.tranagrelacje where trr_trnid = @TrN_TrNId  and trr_fatyp = 320) and b.TrR_FaTyp is null)
        group by tre_lppow, tre_stawka) as a
        group by tre_lppow,tre_twrkod
        having count(*)> 1
        if @StawkaDuplikat != ''
         --SET @Komunikat = 'Zapis niemożliwy. Towar ' + @StawkaDuplikat + ' - ma różne stawki VAT na dokumentach WZ. Wszystkie dokumenty WZ muszą mieć zgodne stawki VAT.'
   SET @Komunikat = '##OPT34325##%s1%=' + @StawkaDuplikat+ '##'
      END
   if exists(select * from cdn.traelem
        join cdn.tranag on TrE_TrNId = trn_trnid
        join cdn.MagazynZakazy on TrE_MagId = MaZ_MagId and TrN_OpeModID = MaZ_OpeId
        where TrN_TrNID = @TrN_TrNId)
      begin
         select top 1 @TrE_TwrKod  = Mag_Symbol from cdn.traelem
         join cdn.tranag on TrE_TrNId = trn_trnid
         join cdn.MagazynZakazy on TrE_MagId = MaZ_MagId and TrN_OpeModID = MaZ_OpeId
         join cdn.Magazyny on TrE_MagId =Mag_MagId
         where TrN_TrNID = @TrN_TrNId
         --SET @Komunikat = 'Operator ma ustawiony zakaz na magazyn '+@TrE_TwrKod+'.'
   SET @Komunikat = '##OPT34326##%s1%=' + @TrE_TwrKod+ '##'
      end
 -- fa od brutto z właczoną fiskalizacją
   if @TrN_TypDokumentu = 302  and @TrN_Rodzaj not in (320000,302200) and  @TrN_Fiskalna = 2 and      @TrN_TypNB = 2
    if exists(SELECT TrE_TwrNazwa FROM CDN.TraNag
    JOIN CDN.TraElem ON TrN_TrNId = TrE_TrNId
    WHERE TrN_Fiskalna = 2 and ROUND(TrE_IloscJm * TrE_CenaT, case when Tre_CenaZCzteremaMiejscami = 1 then 4 else 2 end) <> TrE_WartoscBrutto
    and round(TrE_CenaT,2) != TrE_CenaT and TrN_TrNId = @TrN_TrNId)
   --SET @Komunikat = 'Zaznaczono fiskalizację. Na dokumencie znajdują się towary z ceną z czterema miejscami po przecinku.'
   SET @Komunikat = '##OPT34327##'
-- składniki ilość nie zgodna z dostawami
  if ( @TrN_TypDokumentu IN  ( 317 ) and exists (
  select PdE_PdEId from cdn.prodelem
  left join cdn.traselemdost on TsD_PdEId = PdE_PdEId
  left join cdn.traelem on tre_treid = PdE_TrEId
  where TsD_TsDID is not null and TrE_TrNId =  @TrN_TrNId
  group by PdE_PdEId
  having  max(PdE_IloscJM) != sum(TsD_Ilosc)
  ))
  begin
   select top 1 @TrE_TwrKod = Twr_Kod,@TrE_TwrNazwa = substring(Twr_Nazwa,0,30) from cdn.towary where twr_twrid in(
   select max(pde_twrid)
    from cdn.prodelem
   left join cdn.traselemdost on TsD_PdEId = PdE_PdEId
   left join cdn.traelem on tre_treid = PdE_TrEId
   where tsd_tsdid is not null and TrE_TrNId =  @TrN_TrNId
   group by PdE_PdEId
   having  max(PdE_IloscJM) != sum(TsD_Ilosc))
   SET @Komunikat = '##OPT34867##%s1%=' +@TrE_TwrKod +' ['+REPLACE(@TrE_TwrNazwa,Char(13) + Char(10),' ')+ ']##'
  end
    RETURN @Komunikat
  END
