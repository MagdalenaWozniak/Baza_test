CREATE PROCEDURE [CDN].[TodaySumProc]
 (@InfKod NVARCHAR(20), @OpeId Int, @Data DateTime, @BlokRozlPrac Int, @OPBK NVARCHAR(200), @RetValue NVARCHAR(200) OUTPUT)
AS
Begin
Declare @Wynik NVARCHAR(50)--Decimal (15,2)
Set @Wynik = '0'
Declare @OO_BraId TinyInt
If Exists (Select * From CDN.Firma Where Fir_Numer=1470 And Fir_Wartosc='4')
 Set @OO_BraId = 2
Else
 Set @OO_BraId = 0
Declare @MyId Int
Set @MyId = 0
Declare @DaysBefore Int
Declare @DaysAfter Int
Declare @SetDaysBefore Int
Declare @SetDaysAfter Int
Set @DaysBefore = 30
Set @DaysAfter = 30
Set @SetDaysBefore = 1
Set @SetDaysAfter = 1
-- Stan środków pieniężnych
If @InfKod = 'STAN KASY'
 Set @Wynik =
  convert( NVARCHAR(50), CAST( (Select IsNull(SUM(BRp_PrzychodySys - BRp_RozchodySys + BRp_RoznicaKursowaSysMW), 0)
  From CDN.BnkRaporty Join CDN.BnkRachunki On BRa_BRaID = BRp_BRaID
  Where CDN.ZakazDoRachunku(BRa_BRaID, @OpeId) = 0
    And BRa_Nieaktywny = 0
    And BRa_BRaId <> @OO_BraId)
 +
 (Select IsNull(SUM(BRa_SaldoBOSys), 0)
  From CDN.BnkRachunki
  Where CDN.ZakazDoRachunku(BRa_BRaID, @OpeId) = 0
    And BRa_Nieaktywny = 0
    And BRa_BRaId <> @OO_BraId) AS money), 120 )
-- Należności/zobowiązania przeterminowane
If @InfKod In ('NAL. PRZETERM.', 'ZOB. PRZETERM.')
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(BZd_KwotaSys - BZd_KwotaRozSys), 0.00) as money ), 120 )
 From CDN.BnkZdarzenia
 Join CDN.BnkRachunki On BRa_BRaId=BZd_BRaId
 Where CDN.ZakazDoRachunku(BRa_BRaID, @OpeId) = 0
   AND (BZd_PodmiotTyp<>3 OR @BlokRozlPrac = 0)
   And BZd_Rozliczono = 1
   And BZd_Kierunek = Case @InfKod When 'NAL. PRZETERM.' Then 1 Else -1 End
   And BZd_DataReal < @Data
   And BRa_BRaId <> @OO_BraId
-- Dokumenty przychodowe przeterminowane do VAT
If @InfKod = 'PRZYCH.KOREKTA.VAT'
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(Case when DDf_KierunekOrg = 1 AND BZd_Kierunek = -1 then -1 else 1 end *(BZd_KwotaSys - BZd_KwotaRozSys)), 0.00) as money ), 120 )
 From CDN.BnkZdarzenia
JOIN CDN.BnkRachunki ON bra_braid=bzd_braid
JOIN CDN.Podmiotyview ON pod_podmiottyp=bzd_podmiottyp and pod_podid=bzd_podmiotid
JOIN CDN.DokDefinicje ON DDf_DDfID=BZd_DDfID
Where BZd_Rozliczono = 1
  AND BZd_Stan > 0
  AND (DDf_KierunekOrg = 1 OR DDf_KierunekOrg = 0 AND BZd_DokumentTyp = 1)
  AND (BZd_Kierunek = DDf_KierunekOrg)
  AND (BZd_DokumentTyp IN (1, 101, 2))
  AND (YEAR(@Data) >= 2019 AND DATEDIFF(day, bzd_Termin, @Data) >= 90 OR YEAR(@Data) < 2019 AND DATEDIFF(day, bzd_Termin, @Data) >= 150)
  AND YEAR(DATEADD(day, 150, bzd_Termin)) >= 2013
  AND (BZd_Kierunek < 0 OR YEAR(BZd_DataDok) >= YEAR(@Data) - 2)
  AND (BZd_PodmiotTyp<>3 OR @BlokRozlPrac = 0)
  AND CDN.ZakazDoRachunku(BRa_BRaID, @OpeId) = 0
  AND BRa_Nieaktywny = 0
  AND BRa_BRaId <> @OO_BraId
-- Dokumenty rozchodowe przeterminowane do VAT
If @InfKod = 'ROZCH.KOREKTA.VAT'
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(Case when DDf_KierunekOrg = -1 AND BZd_Kierunek = 1 then -1 else 1 end *(BZd_KwotaSys - BZd_KwotaRozSys)), 0.00) as money ), 120 )
 From CDN.BnkZdarzenia
JOIN CDN.BnkRachunki ON bra_braid=bzd_braid
JOIN CDN.Podmiotyview ON pod_podmiottyp=bzd_podmiottyp and pod_podid=bzd_podmiotid
JOIN CDN.DokDefinicje ON DDf_DDfID=BZd_DDfID
Where BZd_Rozliczono = 1
  AND BZd_Stan > 0
  AND DDf_KierunekOrg = -1
  AND (BZd_Kierunek = DDf_KierunekOrg)
  AND (BZd_DokumentTyp IN (1, 101, 2))
  AND (YEAR(@Data) >= 2019 AND DATEDIFF(day, bzd_Termin, @Data) >= 90 OR YEAR(@Data) < 2019 AND DATEDIFF(day, bzd_Termin, @Data) >= 150)
  AND YEAR(DATEADD(day, 150, bzd_Termin)) >= 2013
  AND (BZd_Kierunek < 0 OR YEAR(BZd_DataDok) >= YEAR(@Data) - 2)
  AND (BZd_PodmiotTyp<>3 OR @BlokRozlPrac = 0)
  AND CDN.ZakazDoRachunku(BRa_BRaID, @OpeId) = 0
  AND BRa_Nieaktywny = 0
  AND BRa_BRaId <> @OO_BraId
-- Dokumenty rozchodowe przeterminowane do dochodowego
If @InfKod = 'ROZCH.KOREKTA.DOCH.'
BEGIN
 CREATE TABLE #Result
 (ProcID INT, DokKBID INT, Termin VARCHAR(10), Rejestr NVARCHAR(5), Nr_dokumentu NVARCHAR(255), Kod_Kontrahenta NVARCHAR(21),
  poTerminie30 INT,
  Kwota DECIMAL(15,2), KwotaSys DECIMAL(15,2))
 INSERT INTO #Result
 SELECT ProcID = 23014, DokKBID = BZd_BZdID,
 max(convert(varchar(10), BZd_Termin, 120)) as Termin,
 BRa_Symbol as Rejestr,
 max(CASE WHEN BZd_NumerObcy<>'' THEN BZd_NumerObcy ELSE (CASE WHEN BZd_NumerPelny<>'' THEN BZd_NumerPelny ELSE BZd_Opis END) END) as Nr_dokumentu,
 max(pod_Kod) as Kod_Kontrahenta,
 max(datediff(day, bzd_Termin, @Data - 89)) as poTerminie30,
 sum(-BZd_Kierunek * Case BRa_Waluta When '' Then BZd_KwotaSys - BZd_KwotaRozSys Else BZd_Kwota - BZd_KwotaRoz End) as Kwota,
 sum(-BZd_Kierunek * (BZd_KwotaSys - BZd_KwotaRozSys)) as KwotaSys
 FROM CDN.BnkZdarzenia
 JOIN CDN.BnkRachunki ON bra_braid=bzd_braid
 JOIN CDN.Podmiotyview ON pod_podmiottyp=bzd_podmiottyp and pod_podid=bzd_podmiotid
 JOIN CDN.Kontrahenci ON Knt_KntID = BZd_PodmiotID
 JOIN CDN.DokDefinicje ON DDf_DDfID=BZd_DDfID
 WHERE bzd_rozliczono = 1
  AND BZd_DokumentTyp NOT IN (0, 27, 28, 39, 40)
  AND DDf_KierunekOrg = -1
  AND (BZd_PodmiotTyp<>3 OR @BlokRozlPrac = 0)
  AND BRa_Nieaktywny = 0
  AND BRa_BRaId <> @OO_BraId
  AND BZd_PodmiotTyp = 1 AND Knt_Finalny = 0 AND Knt_Export IN (0, 5) AND Knt_PowiazanyUoV = 0
  AND BZd_Termin>CONVERT(datetime, '2019-12-31', 120)
  AND BZd_DataWys>CONVERT(datetime, '2017-12-31', 120)
  AND DATEDIFF(day, BZd_Termin, @Data - 89) > 0
  AND CDN.ZakazDoRachunku(BRa_BRaID, @OpeId ) = 0
 GROUP BY BRa_Symbol, BZd_BZdID
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(KwotaSys), 0.00) as money ), 120 ) FROM #Result
 DROP TABLE #Result
END
-- Dokumenty rozchodowe przeterminowane do dochodowego
If @InfKod = 'PRZYCH.KOREKTA.DOCH.'
BEGIN
 CREATE TABLE #ResultRozch
 (ProcID INT, DokKBID INT, Termin VARCHAR(10), Rejestr NVARCHAR(5), Nr_dokumentu NVARCHAR(255), Kod_Kontrahenta NVARCHAR(21),
  poTerminie30 INT,
  Kwota DECIMAL(15,2), KwotaSys DECIMAL(15,2))
 INSERT INTO #ResultRozch
 SELECT ProcID = 23014, DokKBID = BZd_BZdID,
 max(convert(varchar(10), BZd_Termin, 120)) as Termin,
 BRa_Symbol as Rejestr,
 max(CASE WHEN BZd_NumerObcy<>'' THEN BZd_NumerObcy ELSE (CASE WHEN BZd_NumerPelny<>'' THEN BZd_NumerPelny ELSE BZd_Opis END) END) as Nr_dokumentu,
 max(pod_Kod) as Kod_Kontrahenta,
 max(datediff(day, bzd_Termin, @Data - 89)) as poTerminie30,
 sum(BZd_Kierunek * Case BRa_Waluta When '' Then BZd_KwotaSys - BZd_KwotaRozSys Else BZd_Kwota - BZd_KwotaRoz End) as Kwota,
 sum(BZd_Kierunek * (BZd_KwotaSys - BZd_KwotaRozSys)) as KwotaSys
 FROM CDN.BnkZdarzenia
 JOIN CDN.BnkRachunki ON bra_braid=bzd_braid
 JOIN CDN.Podmiotyview ON pod_podmiottyp=bzd_podmiottyp and pod_podid=bzd_podmiotid
 JOIN CDN.Kontrahenci ON Knt_KntID = BZd_PodmiotID
 JOIN CDN.DokDefinicje ON DDf_DDfID=BZd_DDfID
 WHERE bzd_rozliczono = 1
  AND BZd_DokumentTyp NOT IN (0, 27, 28, 39, 40)
  AND DDf_KierunekOrg = 1
  AND (BZd_PodmiotTyp<>3 OR @BlokRozlPrac = 0)
  AND BRa_Nieaktywny = 0
  AND BRa_BRaId <> @OO_BraId
  AND BZd_PodmiotTyp = 1 AND Knt_Finalny = 0 AND Knt_Export IN (0, 5) AND Knt_PowiazanyUoV = 0
  AND BZd_Termin>CONVERT(datetime, '2019-12-31', 120)
  AND BZd_DataWys>CONVERT(datetime, '2017-12-31', 120)
  AND DATEDIFF(day, BZd_Termin, @Data - 89) > 0
  AND CDN.ZakazDoRachunku(BRa_BRaID, @OpeId ) = 0
 GROUP BY BRa_Symbol, BZd_BZdID
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(KwotaSys), 0.00) as money ), 120 ) FROM #ResultRozch
 DROP TABLE #ResultRozch
END
-- Należności/zobowiązania na dziś/jutro
If @InfKod In ('NAL. DO REAL. DZIS.', 'ZOB. DO REAL. DZIS.', 'NAL. DO REAL. JUTRO', 'ZOB. DO REAL. JUTRO')
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(BZd_KwotaSys - BZd_KwotaRozSys), 0.00) as money ), 120 )
 From CDN.BnkZdarzenia
 Join CDN.BnkRachunki On BRa_BRaId=BZd_BRaId
 Where CDN.ZakazDoRachunku(BRa_BRaID, @OpeId) = 0
   AND (BZd_PodmiotTyp<>3 OR @BlokRozlPrac = 0)
   And BZd_Rozliczono = 1
   And BZd_Kierunek = Case When @InfKod In ('NAL. DO REAL. DZIS.', 'NAL. DO REAL. JUTRO') Then 1 Else -1 End
   And BZd_DataReal = @Data + Case When @InfKod In ('NAL. DO REAL. JUTRO', 'ZOB. DO REAL. JUTRO') Then 1 Else 0 End
   And BRa_BRaId <> @OO_BraId
-- Faktury sprzedaży dzisiejsze
If @InfKod In ('FA SPR. DZISIAJ')
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(TrN_RazemNetto), 0.00) as money ), 120 )
 From CDN.TraNag
 Where TrN_Bufor = 0
   And TrN_TypDokumentu In (302, 305)
   And TrN_DataOpe = @Data
-- Faktury zakupu dzisiejsze
If @InfKod In ('FA ZAK. DZISIAJ')
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(TrN_RazemNetto), 0.00) as money ), 120 )
 From CDN.TraNag
 Where TrN_Bufor = 0
   And TrN_TypDokumentu In (301)
   And TrN_DataOpe = @Data
If @InfKod In ('INTRASTAT DO REAL.', 'KP INTRASTAT DO REAL', 'KH INTRASTAT DO REAL')
 Begin
  Set @Data = DateAdd(month, -1, @Data)
  If Exists (Select * From CDN.Firma Where Fir_Numer = 1647 And Fir_Wartosc = '1')
  And Not Exists (Select * From CDN.IntrastatNag Where IsN_Rok = Year(@Data) And IsN_Miesiac = Month(@Data) And IsN_Blokada = 1)
   Set @Wynik = '1'
 End
-- Deklaracja VAT-7
If @InfKod In ('KP VAT-7 DO REAL.', 'KH VAT-7 DO REAL.')
 Begin
  Set @Data = DateAdd(month, -1, @Data)
  If
   -- Sprawdzenie kwartalnego rozliczania deklaracji - albo miesięczna, albo kwartał
   (Month(@Data) IN(3,6,9,12) OR NOT EXISTS (Select * From CDN.CfgKlucze Join CDN.CfgWartosci On CFK_CFKId = CFW_CFKId Where CFK_nazwa='Rozliczanie VAT kwartalnie' And CFW_Wartosc = '1' And @Data Between CFK_OkresOd And CFK_OkresDo) )
   -- Sprawdzenie istnienia deklaracji
   AND NOT EXISTS (Select * From CDN.DeklNag Where DkN_TypDeklar = 1 And DkN_Zablokowana = 1 And DkN_Finalna = 1 And DkN_RokMiesiac = 100 * Year (@Data) + Month(@Data))
    Set @Wynik = '1'
 End
-- Deklaracja PIT-5, 5L
If @InfKod In ('KP PIT-5 DO REAL.', 'KH PIT-5 DO REAL.')
 Begin
  Set @Data = DateAdd(month, -1, @Data)
  Select @Wynik = LTrim(Str(Count(*))) From CDN.PracKod Join CDN.PracEtaty On PRA_PRAID = PRE_PRAID And PRE_DataDo = Convert(DateTime, '2999-12-31', 120)
  Where PRE_TypPracownika = 1 And Not Exists (
    Select * From CDN.DeklNag Where DkN_TypDeklar In (2,12)
    And DkN_PraId = PRA_PRAID
    And DkN_Zablokowana = 1 And DkN_RokMiesiac = 100 * Year (@Data) + Month(@Data))
 End
-- Rezerwacje/zamówienia przeterminowane
If @InfKod In ('REZER. PRZETERM.', 'ZAMOW. PRZETERM.')
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(TrN_RazemNetto), 0.00) as money ), 120 )
 From CDN.TraNag
 --LEFT OUTER JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId and TrR_FaTyp <> Case @InfKod When 'REZER. PRZETERM.' Then 309 Else 308 End
 Where TrN_Bufor = 0
   And TrN_TypDokumentu = Case @InfKod When 'REZER. PRZETERM.' Then 308 Else 309 End
   AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 3
   And TrN_DataWys < @Data
-- Rezerwacje/zamówienia na dziś
If @InfKod In ('REZERWACJE DZIS.', 'ZAMÓWIENIA DZIS.')
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(TrN_RazemNetto), 0.00) as money ), 120 )
 From CDN.TraNag
 --LEFT OUTER JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId and TrR_FaTyp <> Case @InfKod When 'REZER. PRZETERM.' Then 309 Else 308 End
 Where TrN_Bufor = 0
   And TrN_TypDokumentu = Case @InfKod When 'REZERWACJE DZIS.' Then 308 Else 309 End
   AND ISNULL(TrN_ZwroconoCalaIlosc,0) < 3
   And TrN_DataWys = @Data
If @InfKod In ('WZ BEZ FAKTUR')
 Select @Wynik = convert( NVARCHAR(50), CAST( IsNull(Sum(TrN_RazemNetto), 0.00) as money ), 120 )
 From CDN.TraNag
 LEFT OUTER JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId and TrR_FaTyp <> 308
 Where TrN_Bufor = 0
   And TrN_TypDokumentu = 306
   And TrR_FaId IS NULL
   AND TrN_Korekta = 0
   AND TrN_DataDok >= DateAdd(Day, -6, @Data)
   AND TrN_DataDok < @Data
-- Wygasające umowy o pracę
If @InfKod In ('WYGAS. UMOWY O PRACĘ')
BEGIN
 Set @MyId = 145
 Set @DaysBefore = 5
 Set @DaysAfter = 5
 Set @SetDaysBefore = 1
 Set @SetDaysAfter = 1
 exec [CDN].[TodayTmiDays] @OPBK, @MyId, @SetDaysBefore output, @DaysBefore output, @SetDaysAfter output, @DaysAfter output
 Select @Wynik = Str(IsNull(Count(PRA_PRAId), 0), 20)
 from cdn.PracKod
  join cdn.PracEtaty as p on pra_praid = p.pre_praid
  join cdn.PracEtaty as pe on p.pre_praid = pe.pre_praid
  join cdn.ZakazyDoWydzialowView on pe.pre_dzlid = dzlid
 where
  p.pre_datado >= convert(datetime, '2999-12-30',120)
  and
  p.pre_zatrudnionydo >= (@Data - @DaysAfter)
  and
  p.pre_zatrudnionydo <= (@Data + @DaysBefore)
  and
  @Data between pe.pre_dataod and pe.pre_datado
  and
  opeid = @OpeId
  and
  pracview is null
END
-- Wygasające uprawnienia pracowników
If @InfKod In ('WYG. UPR. PRACOWNIK')
BEGIN
 Set @MyId = 202
 Set @DaysBefore = 30
 Set @DaysAfter = 30
 Set @SetDaysBefore = 1
 Set @SetDaysAfter = 1
 exec [CDN].[TodayTmiDays] @OPBK, @MyId, @SetDaysBefore output, @DaysBefore output, @SetDaysAfter output, @DaysAfter output
 Select @Wynik = Str(IsNull(Count(p.PRE_PRAId), 0), 20)
 From CDN.Uprawnienia
     join cdn.danekadmod on upr_dkmid = dkm_dkmid
     join cdn.pracetaty as p on p.pre_praid = upr_praid
  join cdn.PracEtaty as pe on p.pre_praid = pe.pre_praid
  join cdn.ZakazyDoWydzialowView on pe.pre_dzlid = dzlid
 where
    p.pre_datado > convert(datetime, '2990-12-31', 120)
  and
  p.pre_zatrudnionydo > upr_kurstermin
    and
    dkm_robotnicze <> 0
    and
    (
   upr_kurstermin >= (@Data - @DaysAfter)
   and
   upr_kurstermin <= (@Data + @DaysBefore)
    )
    and
  @Data between pe.pre_dataod and pe.pre_datado
  and
  opeid = @OpeId
  and
  pracview is null
END
-- Pracownicy do badania
If @InfKod In ('PRAC. DO BADANIA')
BEGIN
 Set @MyId = 144
 Set @DaysBefore = 30
 Set @DaysAfter = 30
 Set @SetDaysBefore = 1
 Set @SetDaysAfter = 1
 exec [CDN].[TodayTmiDays] @OPBK, @MyId, @SetDaysBefore output, @DaysBefore output, @SetDaysAfter output, @DaysAfter output
 Select @Wynik = Str(IsNull(Count(PRA_PRAId), 0), 20)
 From CDN.PracKod
  join cdn.PracEtaty as p on pra_praid = p.pre_praid
  join cdn.PracEtaty as pe on p.pre_praid = pe.pre_praid
  join cdn.ZakazyDoWydzialowView on pe.pre_dzlid = dzlid
 where
  p.pre_datado >= convert(datetime, '2999-12-30',120)
  and
  (p.pre_zatrudnionyod > convert(datetime, '1910-12-30',120))
  and
  (@Data between p.pre_zatrudnionyod and p.pre_zatrudnionydo)
  and
  (
   (
    (
     p.pre_waznoscbadanokres >= (@Data - @DaysAfter)
     and
     p.pre_waznoscbadanokres <= (@Data + @DaysBefore)
    )
    or
    (
     p.pre_waznoscbadanokres < convert(datetime, '1910-12-30',120)
    )
   )
   or
   (
    p.pre_waznoscbadanokres is null
    or
    p.pre_waznoscbadanokres > convert(datetime, '2900-12-30',120)
   )
  )
  and
  @Data between pe.pre_dataod and pe.pre_datado
  and
  opeid = @OpeId
  and
  pracview is null
END
-- Umowy nierozliczone
If @InfKod In ('UMOWY NIEROZ.')
 Select @Wynik = Str(IsNull(Count(Umw_UmwID), 0), 20)
 From CDN.Umowy
 Join CDN.PracIdx On Pri_PraId = Umw_PraId
 join cdn.PracEtaty on pri_praid = pre_praid
 join cdn.ZakazyDoWydzialowView on pre_dzlid = dzlid
 Where Pri_Typ = 20 And
   (
      umw_splacono < umw_brutto and
      umw_datado < (@Data - 10) and
      umw_datado - datepart(d, umw_datado) < (@Data - datepart(d, @Data))
   )
   and
  @Data between pre_dataod and pre_datado
  and
  opeid = @OpeId
  and
  pracview is null
-- Zadania zaległe/dzisiejsze/na jutro
If @InfKod In ('ZAD. ZALEGLE', 'ZAD. DZISIEJSZE', 'ZAD. JUTRZEJSZE')
 SELECT @Wynik = Str(IsNull(Count(CRK_CRKId), 0),20)
 FROM CDN.CRMKontakty
 LEFT JOIN CDN.CrmKontaktyCykl ON CrC_CrKId = CrK_CrKId AND CRC_Bufor = 1 AND CRC_Aktywny = 1
 WHERE CRK_Zadanie = 1
    AND CRK_Bufor = 1
    AND (
       -- zaległe
    (    (CRC_CRCID IS NULL     AND CRK_TerminDo < @Data And @InfKod In ('ZAD. ZALEGLE') )
  OR  (CRC_CRCID IS NOT NULL AND CRC_TerminDo < @Data And @InfKod In ('ZAD. ZALEGLE') )) OR
       -- dzisiejsze
    (    (CRC_CRCID IS NULL     AND CRK_TerminOd < @Data + 1 And CRK_TerminDo >= @Data And @InfKod In ('ZAD. DZISIEJSZE') )
  OR  (CRC_CRCID IS NOT NULL AND CRC_TerminOd < @Data + 1 And CRC_TerminDo >= @Data And @InfKod In ('ZAD. DZISIEJSZE') )) OR
       -- jutrzejsze
    (    (CRC_CRCID IS NULL     AND CRK_TerminOd < @Data + 2 And CRK_TerminDo >= @Data + 1 And @InfKod In ('ZAD. JUTRZEJSZE') )
  OR  (CRC_CRCID IS NOT NULL AND CRC_TerminOd < @Data + 2 And CRC_TerminDo >= @Data + 1 And @InfKod In ('ZAD. JUTRZEJSZE') ))
     )
 If @InfKod In ('ZAD. OPE. ZALEGLE', 'ZAD. OPE. DZISIEJSZE', 'ZAD. OPE. JUTRZEJSZE')
 Select DISTINCT @Wynik = Str(IsNull(Count(CRK_CRKId), 0), 20)
 From CDN.CRMKontakty
 LEFT JOIN CDN.CrmKontaktyCykl ON CrC_CrKId = CrK_CrKId AND CRC_Bufor = 1 AND CRC_Aktywny = 1
 Where CRK_Zadanie = 1
    And CRK_Bufor = 1
    And (
       -- zaległe
    (    (CRC_CRCID IS NULL     AND CRK_TerminDo < @Data And @InfKod In ('ZAD. OPE. ZALEGLE') )
  OR  (CRC_CRCID IS NOT NULL AND CRC_TerminDo < @Data And @InfKod In ('ZAD. OPE. ZALEGLE') )) OR
       -- dzisiejsze
    (    (CRC_CRCID IS NULL     AND CRK_TerminOd < @Data + 1 And CRK_TerminDo >= @Data And @InfKod In ('ZAD. OPE. DZISIEJSZE') )
  OR  (CRC_CRCID IS NOT NULL AND CRC_TerminOd < @Data + 1 And CRC_TerminDo >= @Data And @InfKod In ('ZAD. OPE. DZISIEJSZE') )) OR
       -- jutrzejsze
    (    (CRC_CRCID IS NULL     AND CRK_TerminOd < @Data + 2 And CRK_TerminDo >= @Data + 1 And @InfKod In ('ZAD. OPE. JUTRZEJSZE') )
  OR  (CRC_CRCID IS NOT NULL AND CRC_TerminOd < @Data + 2 And CRC_TerminDo >= @Data + 1 And @InfKod In ('ZAD. OPE. JUTRZEJSZE') ))
   )
   AND (CRK_OpiekunTyp = 8 And CRK_OpiekunID=@OpeId)
If @InfKod = 'FAKTURY CYKLICZNE'
 Select @Wynik = Str(IsNull(Count(FcN_FcNId), 0), 20)
 FROM cdn.FaCyklNag
 WHERE FcN_Nieaktywny = 0
 AND 1=CDN.CrmFaCyklDoReal(FcN_FcNId, @Data, 1)
--SrsZlecenia
--Zlecenia operatora
If @InfKod In ('ZLE. OPE. ZALEGLE', 'ZLE. OPE. DZISIEJSZE')
 Select @Wynik = CDN.SrsLiczbaZlecenDlaOperatora(@InfKod, @OpeId, @Data )
-- Deklaracje
If @InfKod In ('KP VAT-UE DO REAL.', 'KH VAT-UE DO REAL.', 'KP PIT-4 DO REAL.', 'PL PIT-4 DO REAL.', 'KH CIT-2 DO REAL.', 'PL PIT-8A DO REAL.', 'DRA DO REAL.', 'PFRON DO REAL.')
 Begin
  Set @Data = DateAdd(month, -1, @Data)
  If NOT EXISTS (
    Select * From CDN.DeklNag Where
    DkN_TypDeklar = Case @InfKod
    When 'KP VAT-UE DO REAL.' Then 11
    When 'KH VAT-UE DO REAL.' Then 11
    When 'KP PIT-4 DO REAL.'  Then 3
    When 'PL PIT-4 DO REAL.'  Then 3
    When 'KH CIT-2 DO REAL.'  Then 8
    When 'PL PIT-8A DO REAL.' Then 6
    When 'DRA DO REAL.'       Then 120
    When 'PFRON DO REAL.'     Then 300
    Else 0 End
    And DkN_Zablokowana = 1 And DkN_RokMiesiac = 100 * Year (@Data) + Month(@Data))
    Set @Wynik = '1'
 End
SET @RetValue = IsNull(@Wynik, '')
End
