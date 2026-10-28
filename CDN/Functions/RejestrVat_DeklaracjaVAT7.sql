
--* gSkrypt.sOpis = $Tworzenie procedury CDN.RejestrVat_DeklaracjaVAT7$
-->

CREATE FUNCTION [CDN].[RejestrVat_DeklaracjaVAT7]( @Rok INT, @Miesiac INT, @Nieokreslony INT, @Typ INT, @CalyKwartal INT)
RETURNS
  @Wyniki TABLE(VaN_VaNID INT, VaN_Lp INT, VaN_RokMies INT,VaN_DataZap DATETIME, VaN_Dokument VARCHAR(256), VaN_IdentKsieg VARCHAR(50), VaN_KntNazwa1 NVARCHAR(50),
  VaN_Kategoria VARCHAR(50), Netto DECIMAL(15,2), VAT DECIMAL(15,2), VaN_Rejestr NVARCHAR(20), VaN_Typ SMALLINT, VaN_DeklRokMies INT, Va7_RokMiesiac INT,
  VaN_KpRID INT, VaN_RycID INT, VaN_DekID INT, VaN_KntNipE VARCHAR(20), VaN_KntNipKraj VARCHAR(2), VaN_Pesel NVARCHAR(11),
  VaN_Export TINYINT, VaN_Finalny TINYINT, VaN_Rolnik TINYINT, VaN_Detal TINYINT, VaN_Fiskalna TINYINT, VaN_Wewnetrzna TINYINT, VaN_RozliczacVATUE TINYINT, VaN_PodatekVat TINYINT,
  VaT_RodzajZakupu SMALLINT, VaT_Odliczenia SMALLINT, VaT_Flaga SMALLINT, VaT_Stawka DECIMAL(5,2), VatZD tinyint, VaN_ZakID INT, VaN_KatID INT, VaT_KatID INT, VaT_Kat2ID INT )
AS
BEGIN
DECLARE @RokMiesMin INT, @RokMiesMax INT
IF @CalyKwartal = 0
BEGIN
 SET @RokMiesMin = 100 * @Rok + @Miesiac
 SET @RokMiesMax = 100 * @Rok + @Miesiac
END
ELSE IF @CalyKwartal = 2
BEGIN
 SET @RokMiesMin = 100 * @Rok + 1;
 SET @RokMiesMax = 100 * @Rok + 12;
END
ELSE
BEGIN
 SET @RokMiesMax = 100 * @Rok + (@Miesiac + (3-@Miesiac%3)%3)
 SET @RokMiesMin = @RokMiesMax - 2
 IF(@Rok = 2004)
 BEGIN
  IF @Miesiac IN (1,2,3,4)
  BEGIN
   SET @RokMiesMin = 200401;
   SET @RokMiesMax = 200404;
  END
  ELSE IF @Miesiac IN (5,6)
  BEGIN
   SET @RokMiesMin = 200405;
   SET @RokMiesMax = 200406;
  END
 END
END
DECLARE @MetodyRozliczVAT TABLE ( _Metoda INT, _Okres INT PRIMARY KEY )
INSERT INTO @MetodyRozliczVAT(_Metoda, _Okres)
SELECT CAST(CFW_Wartosc AS INT) AS _Metoda, YEAR (CFK_OkresOd)*100 + MONTH(CFK_OkresOd) AS _Okres
FROM CDN.CfgWartosci left outer join CDN.CfgKlucze ON (CFW_CfkId = CFK_CfkId)
WHERE CFK_Nazwa = 'Metoda rozliczania VAT'
ORDER BY YEAR (CFK_OkresOd)*100 + MONTH (CFK_OkresOd)
IF @Nieokreslony = 1
 INSERT INTO @Wyniki
 SELECT VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
  VaN_Kategoria, SUM( VT.VaT_NettoDoVAT) AS Netto, SUM( VT.VaT_VatDoVAT) AS VAT, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies, VaN_DeklRokMies,
  VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
  VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
   VT.VaT_RodzajZakupu,  VT.VaT_Odliczenia,  VT.VaT_Flaga,  VT.VaT_Stawka, 0, VaN_ZakID, VaN_KatID,  VT.VaT_KatID,  VT.VaT_Kat2ID
 FROM CDN.VatNag INNER JOIN CDN.VatTab VT ON VaN_VaNID = VT.VaT_VaNID
 LEFT OUTER JOIN (CDN.DokKodyJPKV7 join CDN.KodyJPKV7 on (DKV7_KV7ID = KV7_KV7ID and (KV7_Kod='FP' or KV7_Kod='ZakupVAT_Marza'))) on (VaN_VaNID = DKV7_ParentID and DKV7_ParentTyp=2) 
 LEFT OUTER JOIN CDN.VatTab IVT ON IVT.VaT_VaNID = VaN_VaNID AND VaN_Rodzaj = 5 AND VaN_RazemNetto = 0 AND VaN_RazemVAT = 0 AND IVT.VaT_StawkaSymbol != 'NP' AND IVT.VaT_Netto < 0
 WHERE VaN_RozliczacVat7 = 0 AND VaN_Typ = @Typ AND (VaN_DataOpe < CONVERT(DATETIME, '2020-10-01', 120) OR DKV7_DKV7ID IS NULL OR VaN_Rodzaj = 10) 
 --AND CDN.UjemnyVat_Marza(VaN_VaNId) = 0
 GROUP BY VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
  VaN_Kategoria, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies,
  VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
  VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
   VT.VaT_RodzajZakupu,  VT.VaT_Odliczenia,  VT.VaT_Flaga,  VT.VaT_Stawka, VaN_ZakID, VaN_KatID,  VT.VaT_KatID,  VT.VaT_Kat2ID
   HAVING COUNT(IVT.VaT_VaTID) = 0
ELSE
 INSERT INTO @Wyniki
 SELECT VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
  VaN_Kategoria, SUM(Va7_Netto) AS Netto, SUM(Va7_Vat) AS VAT, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies, Va7_RokMiesiac,
  VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
  VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
  Va7_RodzajZakupu, Va7_Odliczenia, Va7_Flaga, Va7_Stawka, 0, VaN_ZakID, VaN_KatID, 0, 0
 FROM CDN.VatNag
 INNER JOIN CDN.VatTab7 ON VaN_VaNID = Va7_VaNID
 INNER JOIN @MetodyRozliczVAT AS Konfig ON Konfig._Okres = (SELECT TOP 1 _Okres FROM @MetodyRozliczVAT temp WHERE temp._Okres <= YEAR(VaN_DataZap)*100 + MONTH(VaN_DataZap) ORDER BY _Okres Desc)
 LEFT OUTER JOIN (CDN.DokKodyJPKV7 join CDN.KodyJPKV7 on (DKV7_KV7ID = KV7_KV7ID and (KV7_Kod='FP' or KV7_Kod='ZakupVAT_Marza'))) on (VaN_VaNID = DKV7_ParentID and DKV7_ParentTyp=2) 
 LEFT OUTER JOIN CDN.VatTab IVT ON IVT.VaT_VaNID = VaN_VaNID AND VaN_Rodzaj = 5 AND VaN_RazemNetto = 0 AND VaN_RazemVAT = 0 AND IVT.VaT_StawkaSymbol != 'NP' AND IVT.VaT_Netto < 0
 WHERE VaN_Typ = @Typ AND VaN_RozliczacVat7 = 1 AND VaN_Wewnetrzna = 0 AND (VaN_MetodaKasowa = 1 or _Metoda = 2) AND
 (
  (
   VaN_DataZap >= CONVERT(DATETIME, '2013-01-01', 120)
   OR (VaN_Typ=2 AND VaN_DataZap < CONVERT(DATETIME, '2013-01-01', 120))
  )
  AND Va7_RokMiesiac BETWEEN @RokMiesMin AND @RokMiesMax
 )
 AND (VaN_DataOpe < CONVERT(DATETIME, '2020-10-01', 120) OR DKV7_DKV7ID IS NULL)
  --AND CDN.UjemnyVat_Marza(VaN_VaNId) = 0
 GROUP BY VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
  VaN_Kategoria, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies, Va7_RokMiesiac,
  VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
  VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
  Va7_RodzajZakupu, Va7_Odliczenia, Va7_Flaga, Va7_Stawka, VaN_ZakID, VaN_KatID
  HAVING COUNT(IVT.VaT_VaTID) = 0
 UNION
 SELECT VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
  VaN_Kategoria, SUM(VT.VaT_NettoDoVAT) AS Netto, SUM(VT.VaT_VatDoVAT) AS VAT, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies, VaN_DeklRokMies,
  VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
  VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
  VT.VaT_RodzajZakupu, VT.VaT_Odliczenia, VT.VaT_Flaga, VT.VaT_Stawka, 0, VaN_ZakID, VaN_KatID, VT.VaT_KatID, VT.VaT_Kat2ID
 FROM CDN.VatNag
 INNER JOIN CDN.VatTab VT ON VaN_VaNID =  VT.VaT_VaNID
 INNER JOIN @MetodyRozliczVAT AS Konfig ON Konfig._Okres = (SELECT TOP 1 _Okres FROM @MetodyRozliczVAT temp WHERE temp._Okres <= YEAR(VaN_DataZap)*100 + MONTH(VaN_DataZap) ORDER BY _Okres Desc)
 LEFT OUTER JOIN (CDN.DokKodyJPKV7 join CDN.KodyJPKV7 on (DKV7_KV7ID = KV7_KV7ID and (KV7_Kod='FP' or KV7_Kod='ZakupVAT_Marza'))) on (VaN_VaNID = DKV7_ParentID and DKV7_ParentTyp=2) 
 LEFT OUTER JOIN CDN.VatTab IVT ON IVT.VaT_VaNID = VaN_VaNID AND VaN_Rodzaj = 5 AND VaN_RazemNetto = 0 AND VaN_RazemVAT = 0 AND IVT.VaT_StawkaSymbol != 'NP' AND IVT.VaT_Netto < 0
 WHERE VaN_Typ = @Typ AND VaN_RozliczacVat7 = 1 AND
  (
   (VaN_DeklRokMies BETWEEN @RokMiesMin AND @RokMiesMax AND (VaN_Wewnetrzna = 0 AND VaN_MetodaKasowa = 0 AND _Metoda=1 OR VaN_Wewnetrzna = 1 OR VaN_Rodzaj = 10))
   OR
   (_Metoda=2 AND VaN_Typ = 1 AND VaN_Wewnetrzna = 0 AND VaN_DataZap < CONVERT(DATETIME, '2013-01-01', 120) AND VaN_DeklRokMiesKasa BETWEEN @RokMiesMin AND @RokMiesMax)
  )
   AND (VaN_DataOpe < CONVERT(DATETIME, '2020-10-01', 120) OR DKV7_DKV7ID IS NULL)
    --AND CDN.UjemnyVat_Marza(VaN_VaNId) = 0
 GROUP BY VaN_VaNID, VaN_Lp, VaN_RokMies, VaN_DataZap, VaN_Dokument, VaN_IdentKsieg, VaN_KntNazwa1,
  VaN_Kategoria, VaN_Rejestr, VaN_Typ, VaN_DeklRokMies,
  VaN_KpRID, VaN_RycID, VaN_DekID, VaN_KntNipE, VaN_KntNipKraj, VaN_Pesel,
  VaN_Export, VaN_Finalny, VaN_Rolnik, VaN_Detal, VaN_Fiskalna, VaN_Wewnetrzna, VaN_RozliczacVATUE, VaN_PodatekVat,
  VT.VaT_RodzajZakupu, VT.VaT_Odliczenia, VT.VaT_Flaga, VT.VaT_Stawka, VaN_ZakID, VaN_KatID, VT.VaT_KatID, VT.VaT_Kat2ID
  HAVING COUNT(IVT.VaT_VaTID) = 0

  DECLARE @vatzd TABLE ( vanid INT)  
  
 if exists(select DkE_WartoscL from cdn.DeklElem join cdn.DeklNag on (DkN_DkNId = DkE_DkNId) where DkN_TypDeklar = 402 and DkE_Numer = 1 and DkE_WartoscL <> 0)
 begin
	insert into @vatzd select DkE_WartoscL from cdn.DeklElem join cdn.DeklNag on (DkN_DkNId = DkE_DkNId) where DkN_TypDeklar = 402 and DkE_Numer = 1 and DkE_WartoscL <> 0
	/*
	 update @Wyniki set VatZD = 1 where VaN_VaNID in (
	  select DkE_WartoscL from cdn.DeklElem join cdn.DeklNag on (DkN_DkNId = DkE_DkNId) where DkN_TypDeklar = 402 and DkE_Numer = 1 and DkE_WartoscL <> 0
	 )
	 */
  end
 
 if exists(select VaZ_VaNId_ZK from cdn.DeklNag join CDN.VatZD on (DkN_DkNId = VaZ_DkNId) where DkN_TypDeklar = 402 and VaZ_VaNId_ZK is Not Null)
 begin
	insert into @vatzd select Distinct VaZ_VaNId_ZK from cdn.DeklNag join CDN.VatZD on (DkN_DkNId = VaZ_DkNId) where DkN_TypDeklar = 402 and VaZ_VaNId_ZK is Not Null
	/*
	update @Wyniki set VatZD = 1 where VaN_VaNID in (
	select Distinct VaZ_VaNId_ZK from cdn.DeklNag join CDN.VatZD on (DkN_DkNId = VaZ_DkNId) where DkN_TypDeklar = 402 and VaZ_VaNId_ZK is Not Null
	)
	*/
	end

	if exists(select * from @vatzd)
	begin
		update @Wyniki set VatZD = 1 where VaN_VaNID in (select vanid from @vatzd)
	end
 
RETURN
END
--<