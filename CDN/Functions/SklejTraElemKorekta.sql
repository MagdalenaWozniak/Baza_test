CREATE  FUNCTION CDN.SklejTraElemKorekta (@TrEIdOrg INT)
RETURNS CHAR(255)
AS
BEGIN
 DECLARE @TypNB SMALLINT
  DECLARE @Wynik         CHAR(255)
  DECLARE @TrEIdZwr      INT
  DECLARE @WartoscOrg    NUMERIC(15,2)
  DECLARE @WartoscZakOrg NUMERIC(15,2)
  DECLARE @IloscOrg      NUMERIC(15,4)
  DECLARE @IloscJmOrg    NUMERIC(15,4)
  DECLARE @CenaTOrg      NUMERIC(17,4)
    DECLARE @CenaTOrgAvg      NUMERIC(17,4)
    DECLARE @CenaWOrgAvg      NUMERIC(17,4)
  DECLARE @StawkaVatOrg  NUMERIC(5,2)
  DECLARE @FlagaVatOrg   SMALLINT
  DECLARE @ZrodlowaOrg   NUMERIC(5,2)
  DECLARE @WartoscWalOrg  NUMERIC(15,4)
  DECLARE @CenaWWDOrg NUMERIC(17,4)
  DECLARE @Cena0WDOrg NUMERIC(17,4)
  DECLARE @ZaokraglajDo  SMALLINT
 SELECT @TrEIdZwr = TrE_ZwrId, @TypNB = TrE_TypNB, @ZaokraglajDo = case when TrE_CenaZCzteremaMiejscami = 1 then 4 else 2 end FROM CDN.TraElem  JOIN CDN.TraNag on Tre_TrnId = TrN_TrNId WHERE TrE_TrEId = @TrEIdOrg
 IF @TrEIdZwr IS NULL
    SET @Wynik = '' --Faktura zwykła, lub brak elementu
 ELSE
   BEGIN
     --Pobranie informacji o danych przed korektą
     SELECT
       @WartoscOrg    = CASE @TypNB WHEN 1 THEN WartoscNOrg ELSE WartoscBOrg END,
       @WartoscZakOrg = WartoscZakOrg,
       @IloscOrg      = IloscOrg,
       @IloscJmOrg    = IloscJmOrg,
       @CenaTOrg      = CenaTOrg,
       @StawkaVatOrg  = StawkaVatOrg,
       @FlagaVatOrg   = FlagaVatOrg,
       @ZrodlowaOrg   = ZrodlowaOrg,
       @WartoscWalOrg    = CASE @TypNB WHEN 1 THEN WartoscNWalOrg ELSE WartoscBWalOrg END,
       @CenaWWDOrg = CenaWWDOrg,
       @Cena0WDOrg = Cena0WDOrg,
       @CenaWOrgAvg = CenaWOrgAvg,
       @CenaTOrgAvg = CenaTOrgAvg
     FROM CDN.TraElemKorekta(@TrEIdOrg)
     --Sklejenie wyniku do postaci stringu
 SET @Wynik = STR(@WartoscOrg, 15, 2)    + STR(@WartoscZakOrg, 15, 2) + STR(@IloscOrg, 15, 4)  + STR(@IloscJmOrg, 15, 4) + STR(@CenaTOrg, 17, @ZaokraglajDo) +
              STR(@StawkaVatOrg, 6, 2)   + STR(@FlagaVatOrg, 2)       + STR(@ZrodlowaOrg, 6, 2)+
              STR(@WartoscWalOrg, 15, 2) + STR(@CenaWWDOrg, 17, @ZaokraglajDo)    + STR(@Cena0WDOrg, 17, @ZaokraglajDo)+ STR(@CenaTOrgAvg,17,@ZaokraglajDo)  + STR(@CenaWOrgAvg,17,@ZaokraglajDo)
   END
 RETURN @Wynik
END
