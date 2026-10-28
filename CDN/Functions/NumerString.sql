CREATE     FUNCTION CDN.NumerString
(
  @TrN_Rodzaj        INT,          -- Rodzaj dokumentu
  @TrN_OpeZalId      INT,          -- Operator inicjujący dokument do numeracji
  @TrN_StaZalId      INT,          -- Stanowisko, na którym zainicjowano dokument
  @TrN_MagZrdId      INT,          -- Id magazynu do numeracji
  @TrN_DataDok       DATETIME,     -- data dokumentu do numeracji
  @SeriaOperatora    NVARCHAR(5),    -- seria operatora
  @SymbolZewn     NVARCHAR(5) = NULL ,
  @TrN_Rejestr      NVARCHAR(20) = '' ,  --
  @SchematZewn      NVARCHAR(50) = NULL
)
RETURNS NVARCHAR(31)
AS
  BEGIN
  DECLARE
    @TrN_DDFId        INT,
    @TrN_NumerString  NVARCHAR(31),
    -- dla numeru dokumentu
    @DDF_Numeracja         NVARCHAR(50),
    @Symbol                NVARCHAR(20),
    @RokKal                INT,
    @Miesiac               CHAR(2),
    @RokObr                NVARCHAR(5),
    @Rejestr               NVARCHAR(20),
    @Magazyn               NVARCHAR(5)
  -- id numeru domyslnego dla dokumentu
 declare @et_seria nvarchar(20)
 if @TrN_Rodzaj = 909410
  set @et_seria = @TrN_Rejestr
   IF(IsNull(@SymbolZewn, '') = '')
   SET @TrN_DDFId = CDN.DomyslnaDefinicja(@TrN_Rodzaj)
   ELSE
 SELECT @TrN_DDfId = DDf_DDfId
 FROM CDN.DokDefinicje
 WHERE DDf_Symbol = @SymbolZewn
  -- domyślny rejestr
  IF ISNULL(@SeriaOperatora,'') = ''
  BEGIN
    SET @Rejestr = CDN.DomyslnaSeria(@TrN_Rodzaj)
    IF ISNULL(@Rejestr,'') = ''
    BEGIN
     IF(@TrN_Rodzaj in (909092, 909093))
  SET @Rejestr = @TrN_Rejestr
     ELSE
  SET @Rejestr = (SELECT TOP 1 Gru_Nazwa FROM cdn.Grupy WHERE Gru_Typ = CONVERT(INT, @TrN_Rodzaj/1000) ORDER BY Gru_Nazwa )
    END
    SET @Rejestr = ISNULL(@Rejestr,'')
  END
  ELSE
    SET @Rejestr = @SeriaOperatora
 if @TrN_Rodzaj = 909410
  set @Rejestr = @et_seria
  -- Numer
  SET @Symbol  = ISNULL(( SELECT DDF_Symbol FROM cdn.DokDefinicje WHERE DDF_DDFId = @TrN_DDfId ),'')
  SET @RokKal  = YEAR(@TrN_DataDok)
  SET @RokObr  = ISNULL(( SELECT TOP 1 OOb_Symbol FROM cdn.okresyobrach WHERE @TrN_DataDok BETWEEN OOb_DataOtw AND DATEADD(day,-1, DATEADD(MONTH, OOb_Dlugosc, OOb_DataOtw))),'')
--  SET @Miesiac = MONTH(@TrN_DataDok)
  SET @Miesiac = CONVERT( CHAR(2), MONTH(@TrN_DataDok))
  SET @Miesiac = CASE WHEN CONVERT (INT, @Miesiac) BETWEEN 1 AND 9 THEN '0' + @Miesiac ELSE @Miesiac END
  SET @Magazyn = ISNULL(( SELECT TOP 1 Mag_Rejestr FROM cdn.Magazyny WHERE Mag_MagId = @TrN_MagZrdId ),'')
  SET @Rejestr = ISNULL(@Rejestr, '')
  -- dla Offline dokumenty WZ/PZ do FA/FZ nie maja miec serii zeby rozpoznac te wystawione recznie(maja serie) i powstale z FA/FZ
  -- IF (@TrN_Rodzaj=306004 or @TrN_Rodzaj=306006 or @TrN_Rodzaj=307004) and ( SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1470 ) = 4
  -- SET @Rejestr = ''
  -- zamiana poszczegolnych symboli w stringu na odpowiednie wartosci
  IF IsNull(@SchematZewn, '') = ''
   SET @DDF_Numeracja    = ( SELECT DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDFId = @TrN_DDfId )
  ELSE
 SET @DDF_Numeracja = @SchematZewn
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@symbol' , @Symbol  )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rok_kal', @RokKal  )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rok_obr', @RokObr  )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@miesiac', @Miesiac )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rejestr', @Rejestr )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@magazyn', @Magazyn )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@brak/'  , ''       )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '/@brak'  , ''       )
  SET @TrN_NumerString  = CONVERT ( NVARCHAR(31),     @DDF_Numeracja      )
  -- obcinanie ostatniego slasha
  IF SUBSTRING(REVERSE(@TrN_NumerString),1,1) = '/'
    SET @TrN_NumerString = SUBSTRING ( @TrN_NumerString, 1, LEN(@TrN_NumerString) - 1 )
  RETURN @TrN_NumerString
 END
