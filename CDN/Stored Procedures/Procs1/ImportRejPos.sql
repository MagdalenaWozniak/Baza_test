CREATE PROCEDURE CDN.ImportRejPos
@DokId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@VaT_Lp int,
@Kat_KodSzczegol nvarchar(20),
@Kat_ImportRowId nvarchar(36),
@Kat_KodSzczegol2 nvarchar(20),
@Kat_ImportRowId2 nvarchar(36),
@VaT_Stawka decimal(5, 2),
@VaT_Flaga smallint,
@VaT_NettoWal decimal(15, 2),
@VaT_VatWal decimal(15, 2),
@VaT_Netto decimal(15, 2),
@VaT_VAT decimal(15, 2),
@VaT_NettoDoVAT decimal(15,2),
@VaT_VatDoVAT decimal(15,2),
@VaT_RodzajZakupu smallint,
@VaT_Odliczenia smallint,
@VaT_KolumnaKPR nvarchar(50),
@VaT_KolumnaRYC nvarchar(15),
@VaT_KatOpis nvarchar(50),
@VaT_Kat2Opis nvarchar(50),
@WKu_Symbol nvarchar(5),
@VaN_KursLDoVAT decimal(15,4),
@VaN_KursMDoVAT decimal(5,0),
@VaN_DataKurDoVAT nvarchar(10),
@Modul nvarchar(20),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE @KatId int,
   @Kat2Id int,
   @Zrodlowa decimal(5,2),
   @DeklVat7 int,
   @RejTyp int,
   @RokMies int,
   @KPiR tinyint,
   @KatKPIR tinyint,
   @KolRyc tinyint,
   @Odlicz smallint,
   @PodzielOdlicz1 smallint,
   @PodzielOdliczProcent1 decimal(5,2),
   @PodzielOdlicz2 smallint,
   @PodzielOdliczProcent2 decimal(5,2),
   @KatTyp smallint,
   @wewnetrzna tinyint,
   @KatOpis nvarchar(50),
   @Kat2Opis nvarchar(50)
 SET @Zrodlowa = 0.00
 DECLARE @TypRejestru INT
 DECLARE @KntRolnik TINYINT
 DECLARE @KntVatCzynny TINYINT
 DECLARE @KntFinalny TINYINT
 DECLARE @VaNDokument NVARCHAR(256)
 DECLARE @VaNPodmiotTyp INT
 DECLARE @VaNKatID INT
 SELECT @DeklVat7 = VaN_RozliczacVat7, @RejTyp = VaN_Typ, @RokMies = VaN_DeklRokMies, @TypRejestru = VaN_Typ, @wewnetrzna = VaN_Wewnetrzna, @KntRolnik = VaN_Rolnik, @KntVatCzynny = VaN_PodatekVat, @KntFinalny = VaN_Finalny,
  @VaNDokument = VaN_Dokument, @VaNPodmiotTyp = VaN_PodmiotTyp, @VaNKatID = VaN_KatID
 FROM CDN.VatNag
 WHERE VaN_VaNId = @DokId
 IF(@VaT_NettoDoVAT is NULL OR
  @VaT_VatDoVAT is NULL OR
  @WKu_Symbol is NULL OR
  @VaN_KursLDoVAT is NULL OR
  @VaN_KursMDoVAT is NULL OR
  @VaN_DataKurDoVAT is NULL)
 BEGIN
  SET @VaT_NettoDoVAT = @VaT_Netto
  SET @VaT_VatDoVAT = @VaT_Vat
  UPDATE CDN.VatNag SET
   VaN_KursNumerDoVat = VaN_KursNumer,
   VaN_KursLDoVAT = VaN_KursL,
   VaN_KursMDoVAT = VaN_KursM,
   VaN_DataKurDoVAT = VaN_DataKur
  WHERE VaN_VaNId = @DokId
 END
 SET @KatOpis = ''
 SET @Kat2Opis = ''
 DECLARE @KategoriaZNaglowka TINYINT
 SELECT @KategoriaZNaglowka = 0
 IF(@Kat_ImportRowId is not NULL OR @Kat_KodSzczegol is not NULL)
 BEGIN
  SELECT @KatId = Kat_KatId, @KatTyp = Kat_Typ, @KatKPiR = Kat_KolumnaKPIR, @KolRyc = Kat_KolumnaRycz,
  @Odlicz = Kat_Odliczenia, @PodzielOdlicz1 = Kat_PodzielOdliczenia, @PodzielOdliczProcent1 = Kat_PodzielOdliczeniaProcent,
  @KatOpis = Kat_Opis
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowId
  IF @KatId is NULL
  BEGIN
   SELECT @KatId = Kat_KatId, @KatTyp = Kat_Typ, @KatKPIR = Kat_KolumnaKPIR, @KolRyc = Kat_KolumnaRycz,
   @Odlicz = Kat_Odliczenia, @PodzielOdlicz1 = Kat_PodzielOdliczenia, @PodzielOdliczProcent1 = Kat_PodzielOdliczeniaProcent,
   @KatOpis = Kat_Opis
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegol
   IF @KatId is NULL
    --SET @Warnings = 'Brak kategorii ' + @Kat_KodSzczegol + ' dla pozycji w bazie docelowej. Kategoria nie została zaimportowana\'
    SET @Warnings = '##OPT33184##%%kategoria%%=' + IsNull(@Kat_KodSzczegol, '') + '##\'
  END
 END
 ELSE IF @VaNPodmiotTyp = 1 AND (SELECT IsNull(Fir_Wartosc, '') FROM cdn.Firma WHERE Fir_Numer = 3139) = '1'
 BEGIN
  SELECT @KatID = @VaNKatID
  IF @KatID IS NOT NULL
  BEGIN
   DECLARE @KatRodzaj INT
   SELECT @KatRodzaj = NULL
   SELECT @KatTyp = Kat_Typ, @KatKPiR = Kat_KolumnaKPIR, @KolRyc = Kat_KolumnaRycz,
   @Odlicz = Kat_Odliczenia, @PodzielOdlicz1 = Kat_PodzielOdliczenia, @PodzielOdliczProcent1 = Kat_PodzielOdliczeniaProcent,
   @KatRodzaj = Kat_RodzajZakupu,
   @KatOpis = Kat_Opis
   FROM CDN.Kategorie
   WHERE Kat_KatID = @KatID
   SELECT @KategoriaZNaglowka = 1
   IF IsNull(@KatRodzaj, 0) <> 0 AND @Modul = 'Rejestr Vat - OCR'
    SELECT @VaT_RodzajZakupu = @KatRodzaj
   IF @Modul = 'Rejestr Vat - OCR'AND @Odlicz = 2
    SET @VaT_Odliczenia = 2
  END
 END
 IF(@Kat_ImportRowId2 is not NULL OR @Kat_KodSzczegol2 is not NULL)
 BEGIN
  SELECT @Kat2Id = Kat_KatId, @PodzielOdlicz2 = Kat_PodzielOdliczenia, @PodzielOdliczProcent2 = Kat_PodzielOdliczeniaProcent, @Kat2Opis = Kat_Opis
  FROM CDN.Kategorie
  WHERE Kat_ImportRowId = @Kat_ImportRowId2
  IF @Kat2Id is NULL
  BEGIN
   SELECT @Kat2Id = Kat_KatId, @PodzielOdlicz2 = Kat_PodzielOdliczenia, @PodzielOdliczProcent2 = Kat_PodzielOdliczeniaProcent, @Kat2Opis = Kat_Opis
   FROM CDN.Kategorie
   WHERE Kat_KodSzczegol = @Kat_KodSzczegol2
   IF @Kat2Id is NULL
    --SET @Warnings = 'Brak kategorii ' + @Kat_KodSzczegol2 + ' dla pozycji w bazie docelowej. Kategoria nie została zaimportowana\'
    SET @Warnings = '##OPT33184##%%kategoria%%=' + @Kat_KodSzczegol2 + '##\'
  END
 END
 IF(@VaT_KolumnaKPR is NULL OR @VaT_KolumnaKPR = '')
 BEGIN
  SET @KPiR = IsNull(@KatKPiR, case @RejTyp when 1 then 3 when 2 then 1 end)
  IF @KatTyp = 1 AND @RejTyp = 2
   SET @KPiR = 1
  IF @KatTyp = 2 AND @RejTyp = 1
   SET @KPiR = 3
 END
 ELSE
 BEGIN
  IF(@RejTyp = 2)
  BEGIN
   SET @KPiR = case @VaT_KolumnaKPR
       when 'Sprzedaż' then 1
       when 'Sprzedaz' then 1
       when 'Pozostałe' then 2
       when 'Pozostale' then 2
       when 'Inne' then 7
       when 'Zaszłości' then 8
       when 'Zaszlosci' then 8
       when 'Koszty B+R' then 9
       when 'Nie księgować' then 0
       when 'Nie ksiegowac' then 0
      end
  END
  ELSE
  IF(@RejTyp = 1)
  BEGIN
   SET @KPiR = case @VaT_KolumnaKPR
       when 'Towary' then 3
       when 'Uboczne' then 4
       when 'Reklama' then 5
       when 'Wynagrodzenia' then 6
       when 'Inne' then 7
       when 'Zaszłości' then 8
       when 'Zaszlosci' then 8
       when 'Towary + koszty B+R' then 9
       when 'Uboczne + koszty B+R' then 10
       when 'Wynagrodzenia + koszty B+R' then 11
       when 'Inne + koszty B+R' then 12
       when 'Nie księgować' then 0
       when 'Nie ksiegowac' then 0
      end
  END
 END
 IF(@VaT_KolumnaRYC is NULL OR @VaT_KolumnaRYC = '')
  SET @KolRyc = IsNull(@KolRyc, 3)
 ELSE
 BEGIN
  SET @KolRyc = case @VaT_KolumnaRYC
      when 'Nie księgować' then 0
      when 'Nie ksiegowac' then 0
      when '8.50'    then 1
      when '5.50'    then 2
      when '3.00'    then 3
      when '20.00'   then 4
      when '17.00'   then 5
      when '10.00'   then 6
      when '2.00'    then 7
      when '12.50'   then 8
      else 0
      end
 END
 IF @VaT_Odliczenia is NULL
 BEGIN
  IF @KntRolnik = 0 AND (@KntVatCzynny = 0 OR @KntFinalny = 1)
   SET @VaT_Odliczenia = 0
  ELSE
   SET @VaT_Odliczenia = @Odlicz
 END
 IF @RejTyp = 1
 BEGIN
  IF @wewnetrzna = 1
   SET @VaT_Odliczenia = 1
  ELSE
  IF @Modul = 'Handel' AND @VaT_Odliczenia IS NULL  --jeśli faktura zakupowa z modułu Faktury
  BEGIN
   IF @KntRolnik = 0 AND (@KntVatCzynny = 0 OR @KntFinalny = 1)
    SET @VaT_Odliczenia = 0
   ELSE
   BEGIN
    IF @KatId is NULL Or @KatTyp = 2
     SET @VaT_Odliczenia = 1
    ELSE IF (SELECT Knt_Rolnik
     FROM CDN.Kontrahenci
     WHERE Knt_KntId = (SELECT VaN_PodId
          FROM CDN.VaTNag
          WHERE VaN_VaNId = @DokId)) = 1
     BEGIN
      SET @VaT_Odliczenia = case (SELECT Fpl_Typ
        FROM CDN.FormyPlatnosci
        WHERE Fpl_FplId = (SELECT VaN_FplId
             FROM CDN.VatNag
             WHERE VaN_VaNId = @DokId))
       when 2 then 1
       when 1 then 0
       end
     END
    END
  END
 END
 DECLARE @RodzajZakupuParam SMALLINT,
   @OdliczeniaParam smallint,
   @StawkaSymbolParam NVARCHAR(10),
   @KatOpisParam nvarchar(50),
   @Kat2OpisParam nvarchar(50)
 SELECT @RodzajZakupuParam = case @RejTyp when 2 then case @VaT_RodzajZakupu when 0 then 4 else @VaT_RodzajZakupu end else @VaT_RodzajZakupu end
 SELECT @OdliczeniaParam = IsNull(@VaT_Odliczenia, 0)
 SELECT @StawkaSymbolParam = CDN.KodStawkiVat(@TypRejestru, @VaT_Flaga, @VaT_Stawka)
 IF (@KategoriaZNaglowka = 1 AND @VaT_KatOpis = '')
  SELECT @KatOpisParam = @KatOpis -- jeśli pobrano kategorię z nagłówka to w przypadku istnienia w pliku tagu z opisem kategorii z pustą wartością, pobieramy ten opis z kategorii (pobranej z nagłówka)
 ELSE
  SELECT @KatOpisParam = IsNull(@VaT_KatOpis, @KatOpis)
 SELECT @Kat2OpisParam = IsNull(@VaT_Kat2Opis, @Kat2Opis)
 IF ((@Modul = 'Handel' OR @Modul = 'Rejestr Vat - OCR') AND @RejTyp = 1)
 BEGIN
  -- W pozycjach pochodzących z faktur zakupu z modułu Handel musimy uwzględnić podział odliczeń.
  -- Ten podział odliczeń na jednych pozycjach może być włączony (wówczas rozbijamy takie pozycje na dwie), a na innych - nie. Ponieważ na danej pozycji nie wiemy czy na poprzednich/następnych
  -- był/będzie podział odliczeń, musimy założyć, że tak, a więc nie możemy przepisywać @VAT_Lp z pliku tylko musimy na bieżąco autonumerować (nawet jak dla danej pozycji nie ma podziału odliczeń).
  DECLARE @PodzielOdlicz smallint
  IF @PodzielOdlicz1<>0 OR @PodzielOdlicz2<>0
   SET @PodzielOdlicz = 1
  ELSE
   SET @PodzielOdlicz = 0
  IF @PodzielOdlicz = 0 -- ta pozycja nie ma podziału odliczeń, więc zapisujemy to, co przychodzi w parametrach z wyjątkiem Lp, które zawsze autonumerujemy
   EXEC cdn.ImportRejPosAddRecord @DokId, null, @VaT_Stawka, @VaT_Flaga, @Zrodlowa, @RodzajZakupuParam, @OdliczeniaParam,
    @VaT_NettoWal, @VaT_VATWal, @VaT_Netto, @VaT_VAT, @VaT_NettoDoVAT, @VaT_VatDoVAT,
    @StawkaSymbolParam, @KatID, @KatOpisParam, @Kat2ID, @Kat2OpisParam, @KPiR, @KolRyc
  ELSE
  BEGIN
   DECLARE @KnfPodzialOdliczenVAT TINYINT
   SELECT @KnfPodzialOdliczenVAT = Fir_Wartosc from cdn.firma where fir_numer=3007
   DECLARE @PodzielOdliczProcent decimal(5,2)
   IF @PodzielOdlicz1<>0
    SET @PodzielOdliczProcent = @PodzielOdliczProcent1
   ELSE -- IF @PodzielOdlicz2<>0
    SET @PodzielOdliczProcent = @PodzielOdliczProcent2
   DECLARE @VaT_NettoWalParamSrc decimal(15, 2),
     @VaT_VATWalParamSrc decimal(15, 2),
     @VaT_NettoParamSrc decimal(15, 2),
     @VaT_VATParamSrc decimal(15, 2),
     @VaT_NettoDoVATParamSrc decimal(15,2),
     @VaT_VatDoVATParamSrc decimal(15, 2),
     @VaT_NettoWalParamTrg decimal(15, 2),
     @VaT_VATWalParamTrg decimal(15, 2),
     @VaT_NettoParamTrg decimal(15, 2),
     @VaT_VATParamTrg decimal(15, 2),
     @VaT_NettoDoVATParamTrg decimal(15,2),
     @VaT_VatDoVATParamTrg decimal(15, 2)
   IF @KnfPodzialOdliczenVAT = 1
   BEGIN
    SELECT @VaT_NettoWalParamSrc = (@VaT_NettoWal * @PodzielOdliczProcent) / 100.00
    SELECT @VaT_NettoWalParamTrg = @VaT_NettoWal - @VaT_NettoWalParamSrc
    SELECT @VaT_VATWalParamSrc = (@VaT_Stawka * @VaT_NettoWalParamSrc) / 100.00
    SELECT @VaT_VATWalParamTrg = @VaT_VATWal - @VaT_VATWalParamSrc
    SELECT @VaT_NettoParamSrc = (@VaT_Netto * @PodzielOdliczProcent) / 100.00
    SELECT @VaT_NettoParamTrg = @VaT_Netto - @VaT_NettoParamSrc
    SELECT @VaT_VATParamSrc = (@VaT_Stawka * @VaT_NettoParamSrc) / 100.00
    SELECT @VaT_VATParamTrg = @VaT_VAT - @VaT_VATParamSrc
    SELECT @VaT_NettoDoVATParamSrc = (@VaT_NettoDoVAT * @PodzielOdliczProcent) / 100.00
    SELECT @VaT_NettoDoVATParamTrg = @VaT_NettoDoVAT - @VaT_NettoDoVATParamSrc
    SELECT @VaT_VATDoVATParamSrc = (@VaT_Stawka * @VaT_NettoDoVATParamSrc) / 100.00
    SELECT @VaT_VATDoVATParamTrg = @VaT_VATDoVAT - @VaT_VATDoVATParamSrc
    DECLARE @OdliczeniaParamSrc TINYINT,
      @OdliczeniaParamTrg TINYINT
    SELECT @OdliczeniaParamSrc = @OdliczeniaParam, @OdliczeniaParamTrg = @OdliczeniaParam
    IF (@VaT_VATParamSrc > 0 AND @VaT_VATParamSrc >= @VaT_VATParamTrg) OR (@VaT_VATParamSrc < 0 AND @VaT_VATParamSrc <= @VaT_VATParamTrg)
     SELECT @OdliczeniaParamSrc = 0
    ELSE -- IF @VaT_VATParamSrc < @VaT_VATParamTrg
     SELECT @OdliczeniaParamTrg = 0
    EXEC cdn.ImportRejPosAddRecord @DokId, null, @VaT_Stawka, @VaT_Flaga, @Zrodlowa, @RodzajZakupuParam, @OdliczeniaParamSrc,
     @VaT_NettoWalParamSrc, @VaT_VATWalParamSrc, @VaT_NettoParamSrc, @VaT_VATParamSrc, @VaT_NettoDoVATParamSrc, @VaT_VatDoVATParamSrc,
     @StawkaSymbolParam, @KatID, @KatOpisParam, @Kat2ID, @Kat2OpisParam, @KPiR, @KolRyc
    EXEC cdn.ImportRejPosAddRecord @DokId, null, @VaT_Stawka, @VaT_Flaga, @Zrodlowa, @RodzajZakupuParam, @OdliczeniaParamTrg,
     @VaT_NettoWalParamTrg, @VaT_VATWalParamTrg, @VaT_NettoParamTrg, @VaT_VATParamTrg, @VaT_NettoDoVATParamTrg, @VaT_VatDoVATParamTrg,
     @StawkaSymbolParam, @KatID, @KatOpisParam, @Kat2ID, @Kat2OpisParam, @KPiR, @KolRyc
   END
   ELSE IF @KnfPodzialOdliczenVAT = 2
   BEGIN
    DECLARE @VatSAV DECIMAL(15,2)
    SELECT @VaT_NettoWalParamSrc = @VaT_NettoWal
    SELECT @VaT_NettoWalParamTrg = 0
    SELECT @VaT_VATWalParamSrc = (@VaT_VatWal * @PodzielOdliczProcent) / 100.00
    SELECT @VaT_VATWalParamTrg = @VaT_VatWal - @VaT_VATWalParamSrc
    IF (@VaT_VATWalParamSrc > 0 AND @VaT_VATWalParamSrc > @VaT_VATWalParamTrg) OR (@VaT_VATWalParamSrc < 0 AND @VaT_VATWalParamSrc < @VaT_VATWalParamTrg)
    BEGIN
     SELECT @VatSAV = @VaT_VATWalParamSrc
     SELECT @VaT_VATWalParamSrc = @VaT_VATWalParamTrg
     SELECT @VaT_VATWalParamTrg = @VatSAV
    END
    SELECT @VaT_NettoParamSrc = @VaT_Netto
    SELECT @VaT_NettoParamTrg = 0
    SELECT @VaT_VATParamSrc = (@VaT_Vat * @PodzielOdliczProcent) / 100.00
    SELECT @VaT_VATParamTrg = @VaT_Vat - @VaT_VATParamSrc
    IF (@VaT_VATParamSrc > 0 AND @VaT_VATParamSrc > @VaT_VATParamTrg) OR (@VaT_VATParamSrc < 0 AND @VaT_VATParamSrc < @VaT_VATParamTrg)
    BEGIN
     SELECT @VatSAV = @VaT_VATParamSrc
     SELECT @VaT_VATParamSrc = @VaT_VATParamTrg
     SELECT @VaT_VATParamTrg = @VatSAV
    END
    SELECT @VaT_NettoDoVATParamSrc = @VaT_NettoDoVAT
    SELECT @VaT_NettoDoVATParamTrg = 0
    SELECT @VaT_VATDoVATParamSrc = (@VaT_VatDoVat * @PodzielOdliczProcent) / 100.00
    SELECT @VaT_VATDoVATParamTrg = @VaT_VatDoVat - @VaT_VATDoVATParamSrc
    IF (@VaT_VATDoVATParamSrc > 0 AND @VaT_VATDoVATParamSrc > @VaT_VATDoVATParamTrg) OR (@VaT_VATDoVATParamSrc < 0 AND @VaT_VATDoVATParamSrc < @VaT_VATDoVATParamTrg)
    BEGIN
     SELECT @VatSAV = @VaT_VATDoVATParamSrc
     SELECT @VaT_VATDoVATParamSrc = @VaT_VATDoVATParamTrg
     SELECT @VaT_VATDoVATParamTrg = @VatSAV
    END
    EXEC cdn.ImportRejPosAddRecord @DokId, null, @VaT_Stawka, @VaT_Flaga, @Zrodlowa, @RodzajZakupuParam, @OdliczeniaParam,
     @VaT_NettoWalParamSrc, @VaT_VATWalParamSrc, @VaT_NettoParamSrc, @VaT_VATParamSrc, @VaT_NettoDoVATParamSrc, @VaT_VatDoVATParamSrc,
     @StawkaSymbolParam, @KatID, @KatOpisParam, @Kat2ID, @Kat2OpisParam, @KPiR, @KolRyc
    EXEC cdn.ImportRejPosAddRecord @DokId, null, @VaT_Stawka, @VaT_Flaga, @Zrodlowa, @RodzajZakupuParam, 0,
     @VaT_NettoWalParamTrg, @VaT_VATWalParamTrg, @VaT_NettoParamTrg, @VaT_VATParamTrg, @VaT_NettoDoVATParamTrg, @VaT_VatDoVATParamTrg,
     @StawkaSymbolParam, @KatID, @KatOpisParam, @Kat2ID, @Kat2OpisParam, @KPiR, @KolRyc
   END
  END
 END
 ELSE
  -- Nie z Handlu lub nie FZ; zostawiamy jak było (uwzględniamy też ewentualnie przekazane Lp)
  EXEC cdn.ImportRejPosAddRecord @DokId, @VAT_Lp, @VaT_Stawka, @VaT_Flaga, @Zrodlowa, @RodzajZakupuParam, @OdliczeniaParam,
   @VaT_NettoWal, @VaT_VATWal, @VaT_Netto, @VaT_VAT, @VaT_NettoDoVAT, @VaT_VatDoVAT,
   @StawkaSymbolParam, @KatID, @KatOpisParam, @Kat2ID, @Kat2OpisParam, @KPiR, @KolRyc
END
