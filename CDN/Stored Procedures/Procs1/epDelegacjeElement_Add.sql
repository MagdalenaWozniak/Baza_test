CREATE procedure [CDN].[epDelegacjeElement_Add]
@DelegacjaId  int,
@IloscSniadan  int,
@IloscObiadow  int,
@IloscKolacji  int,
@NumerRejestracyjny nvarchar(20),
@Opis    nvarchar(255)
As
 Set NOCOUNT ON
 if IsNull(@DelegacjaId, 0) = 0
 BEGIN
  RAISERROR('epDelegacjeElement_Add. Parametr @DelegacjaId jest wymagany.', 16, 1)
  SET NOCOUNT OFF
  RETURN
 END
 if @Opis is Null Set @Opis = ''
  declare @KatId          int = NULL;
  declare @Kategoria      nvarchar(50) = NULL;
 declare @DataOd DateTime; set @DataOd = GETDATE();
 declare @DataDo DateTime; set @DataDo = GETDATE();
 declare @Termin int; set @Termin = NULL;
 declare @FPlId int; set @FPlId = NULL;
 if exists(SELECT * FROM CDN.FormyPlatnosci WHERE FpL_Nieaktywny=0 and FpL_Typ = 1 and FpL_Nazwa='gotówka')
  SELECT TOP 1 @FPlId = Fpl_FPLID, @Termin= Fpl_Termin FROM CDN.FormyPlatnosci WHERE FpL_Nieaktywny=0 and FpL_Typ = 1 and FpL_Nazwa='gotówka';
 else
  SELECT TOP 1 @FPlId = Fpl_FPLID, @Termin= Fpl_Termin FROM CDN.FormyPlatnosci WHERE FpL_Nieaktywny=0 ORDER BY FPL_Nazwa;
 if @FPlId is Null
 begin
  RAISERROR('epDelegacjeElement_Add. Brak aktywnej formy płatnościo o typie gotówka.', 16, 1)
  SET NOCOUNT OFF
  RETURN
 end
 set @IloscSniadan  = IsNull(@IloscSniadan,   0);
 set @IloscObiadow  = IsNull(@IloscObiadow,   0);
 set @IloscKolacji  = IsNull(@IloscKolacji,   0);
 set @NumerRejestracyjny = IsNull(@NumerRejestracyjny, '');
 declare @TerminPlatnosci DateTime;
 declare @DataRozliczenia DateTime;
 select @TerminPlatnosci = DLN_DataRozliczenia+@Termin,
          @DataRozliczenia = DLN_DataRozliczenia,
          @KatId = DLN_KatId,
          @Kategoria = DLN_Kategoria
          from CDN.DlgNag where DLN_DLNID = @DelegacjaId
 -- KNF_STAWKA_POWYZEJ_900 L"/Program/Księgowość/Samochody/Powyżej 900"
 -- KNF_STAWKA_DO_900  L"/Program/Księgowość/Samochody/Do 900"
 -- KNF_STAWKA_MOTOCYKL  L"/Program/Księgowość/Samochody/Motocykl"
 -- KNF_STAWKA_MOTOROWER L"/Program/Księgowość/Samochody/Motorower"
 -- #define e_mk_nTypSamochodPow900       1L
 -- #define e_mk_nTypSamochodDo900        2L
 -- #define e_mk_nTypSamochodMotocykl       3L
 -- #define e_mk_nTypSamochodMotorower       4L
 declare @TypPojazduString nvarchar(255);  set @TypPojazduString = 'Powyżej 900';
 declare @TypPojazdu smallint;     set @TypPojazdu = 1;
 declare @PojazdStawkaZaKilometr decimal(15,4);  set @PojazdStawkaZaKilometr = 0.8358;
 if len(@NumerRejestracyjny) > 0 and exists (select * from CDN.AutoEwid where AuE_Rejestracja = @NumerRejestracyjny)
 begin
  select @TypPojazdu = AuE_KlasaPoj from CDN.AutoEwid where AuE_Rejestracja = @NumerRejestracyjny
  if @TypPojazdu = 1 set @TypPojazduString = 'Powyżej 900';
  else if @TypPojazdu = 2 set @TypPojazduString = 'Do 900';
  else if @TypPojazdu = 3 set @TypPojazduString = 'Motocykl';
  else if @TypPojazdu = 4 set @TypPojazduString = 'Motorower';
 end
 exec CDN.CfgWartoscAsDecimal @DataRozliczenia, @TypPojazduString, @Result = @PojazdStawkaZaKilometr OUTPUT;
 declare @sql nvarchar(2048)
 set @sql = 'declare @DataOd DateTime; Set @DataOd = ' + CDN.Date2String(@DataOd, 120, 0) + ';'
   + 'declare @DataDo DateTime; Set @DataDo = ' + CDN.Date2String(@DataDo, 120, 0) + ';'
   + 'declare @TerminPlatnosci DateTime; Set @TerminPlatnosci = ' + CDN.Date2String(@TerminPlatnosci, 120, 0) + ';'
   + 'declare @IloscGodzinDelegacji DateTime; Set @IloscGodzinDelegacji = Convert(DateTime, ''1899-12-30 00:00:00.000'',120);'
   + 'exec CDN.epDelegacjeElementy_Insert ' +  convert(nvarchar, @DelegacjaId)  + ','
   + ISNULL(convert(nvarchar, @KatId), 'NULL')  + ','
   +   '''' + ISNULL(@Kategoria, '') + '''' + ','
   + '@DataOd,'
   + '@DataDo,'
   + '''PL'','
   + ''''','
   + '3,'
   + '1,'
   + '1,'
   + '0,'
   + '0,'
   + convert(nvarchar, @FPlId)  + ','
   + '@TerminPlatnosci,'
   + '1,'
   + '@IloscGodzinDelegacji,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   +   '''' + @NumerRejestracyjny + '''' + ','
   + convert(nvarchar, @TypPojazdu)  + ','
   + convert(nvarchar, @PojazdStawkaZaKilometr)  + ','
   + '0,'
   + '0,'
   + convert(nvarchar, @IloscSniadan)  + ','
   + convert(nvarchar, @IloscObiadow)  + ','
   + convert(nvarchar, @IloscKolacji)  + ','
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + '0,'
   + ''''+REPLACE(@Opis, '''', '''''''''')+''''
 Execute dbo.sp_executesql @sql
 declare @DelagacjaElementId int; set @DelagacjaElementId = 0;
 if @@ERROR = 0 set @DelagacjaElementId = IsNull(IDENT_CURRENT('CDN.DlgElem'), 0);
 SET NOCOUNT OFF
 set @sql = 'select ' + convert(nvarchar, @DelagacjaElementId) + ' as DelagacjaElementId'
 Execute dbo.sp_executesql @sql
