CREATE procedure CDN.KRo_RozrachunkiNieRozliczone
 @DataBiezaca   nvarchar(255),  -- 1
 @KontoId    int,    -- 2
 @KontoRozliczajaceId int,    -- 3
 @DataDokumentu   nvarchar(255),  -- 4
 @TerminPlatnosci  nvarchar(255),  -- 5
 @Dokument    nvarchar(256),  -- 6
 @Opis     nvarchar(255),  -- 7
 @IdKsiegowy    nvarchar(255),  -- 8
 @Waluta     nvarchar(255),  -- 9
 @Bufor     nvarchar(255),  --10
 @CzesciowoCalkowicie nvarchar(255),  --11
 @PozostajeWnMa   nvarchar(255),  --12
 @OdsetkiNalezne   int,    --13
 @OdsetkiOdZobowiazan int     --14
As
 SET NOCOUNT ON
 declare @command    nvarchar(4000)
 declare @sql     nvarchar(4000)
 declare @where     nvarchar(4000); Set @where = ''
 declare @kontoWhere    nvarchar(4000)
 declare @kontoWhereLike    nvarchar(4000)
 declare @accAnalityka   int
 declare @accNumer    nvarchar(50)
 declare @KwotaRozliczeniauField nvarchar(50)
 declare @kwotaDokumentuField nvarchar(50)
 declare @SumaRozliczen   nvarchar(50)
 declare @PozostajeWn   nvarchar(200)
 declare @PozostajeMa   nvarchar(200)
 declare @DoRozliczenia   nvarchar(200)
 declare @PodstawaOdsetek nvarchar(512)
 declare @PoTerminie    nvarchar(256)
 declare @Przeterminowane  nvarchar(256)
 if @Waluta = '1=1' or Len(@Waluta) = 0
 begin
  Set @KwotaRozliczeniauField = 'child.KRo_Kwota as KwotaRozliczenia'
  Set @kwotaDokumentuField = 'child.KRo_KwotaDok as KwotaDokumentu'
  Set @SumaRozliczen   = 'child.KRo_SumRozliczen as SumaRozliczen'
  Set @PozostajeWn   = 'case when child.KRo_Strona = 1 then child.KRo_KwotaDok - child.KRo_SumRozliczen else NULL end as PozostajeWn'
  Set @PozostajeMa   = 'case when child.KRo_Strona = 2 then child.KRo_KwotaDok - child.KRo_SumRozliczen else NULL end as PozostajeMa'
  Set @DoRozliczenia   = 'child.KRo_KwotaDok - child.KRo_SumRozliczen as DoRozliczenia'
  if @OdsetkiNalezne <> 0 and @OdsetkiOdZobowiazan <> 0
   Set @PodstawaOdsetek  = 'case when child.KRo_Strona = 1 then (child.KRo_KwotaDok - child.KRo_SumRozliczen) else -(child.KRo_KwotaDok - child.KRo_SumRozliczen) end'
  else if @OdsetkiNalezne <> 0
   Set @PodstawaOdsetek  = 'case when child.KRo_Strona = 1 then (child.KRo_KwotaDok - child.KRo_SumRozliczen) else 0 end'
  else if @OdsetkiOdZobowiazan <> 0
   Set @PodstawaOdsetek  = 'case when child.KRo_Strona = 1 then 0 else -(child.KRo_KwotaDok - child.KRo_SumRozliczen) end'
  else
   Set @PodstawaOdsetek  = '0'
 end
 else
 begin
  Set @KwotaRozliczeniauField = 'child.KRo_KwotaWal as KwotaRozliczenia'
  Set @kwotaDokumentuField = 'child.KRo_KwotaDokWal as KwotaDokumentu'
  Set @SumaRozliczen   = 'child.KRo_SumRozliczenWal as SumaRozliczen'
  Set @PozostajeWn   = 'case when child.KRo_Strona = 1 then child.KRo_KwotaDokWal - child.KRo_SumRozliczenWal else NULL end as PozostajeWn'
  Set @PozostajeMa   = 'case when child.KRo_Strona = 2 then child.KRo_KwotaDokWal - child.KRo_SumRozliczenWal else NULL end as PozostajeMa'
  Set @DoRozliczenia   = 'child.KRo_KwotaDokWal - child.KRo_SumRozliczenWal as DoRozliczenia'
  if @OdsetkiNalezne <> 0 and @OdsetkiOdZobowiazan <> 0
   Set @PodstawaOdsetek  = 'case when child.KRo_Strona = 1 then (child.KRo_KwotaDokWal - child.KRo_SumRozliczenWal) else -(child.KRo_KwotaDokWal - child.KRo_SumRozliczenWal) end'
  else if (@OdsetkiNalezne <> 0)
   Set @PodstawaOdsetek  = 'case when child.KRo_Strona = 1 then (child.KRo_KwotaDokWal - child.KRo_SumRozliczenWal) else 0 end'
  else if @OdsetkiOdZobowiazan <> 0
   Set @PodstawaOdsetek  = 'case when child.KRo_Strona = 1 then 0 else -(child.KRo_KwotaDokWal - child.KRo_SumRozliczenWal) end'
  else
   Set @PodstawaOdsetek  = '0'
 end
 Set @PodstawaOdsetek = 'case when '+@DataBiezaca+' > CDN.fn_GetWorkingDayAfter(child.KRo_TerminPlatnosci) then ' + @PodstawaOdsetek +  ' else 0 end'
 Set @PodstawaOdsetek = @PodstawaOdsetek + ' as PodstawaOdsetek'
 Set @PoTerminie  = 'case when '+@DataBiezaca+' > CDN.fn_GetWorkingDayAfter(child.KRo_TerminPlatnosci) then DATEDIFF(DAY, CDN.fn_GetWorkingDayAfter(child.KRo_TerminPlatnosci), '+@DataBiezaca+') else NULL end as PoTerminie'
 Set @Przeterminowane= 'case when '+@DataBiezaca+' > CDN.fn_GetWorkingDayAfter(child.KRo_TerminPlatnosci) then ''T'' else NULL end as Przeterminowane'
 /*
 PoTerminie
 Odsetki
 */
 CREATE TABLE #kh_rozrachunki (
  Id int not null identity(1, 1) primary key,
  ParentId   int default NULL,
  TreeLevel   int default 1,
  RozliczenieId  int default 0, -- wymagane przez COdsetkiKB
  NieNaliczajOdsetek int default 0, -- wymagane przez COdsetkiKB,
  --RS_OdsetkiKwota  decimal(15, 2) default NULL,
  DataRozliczenia  DateTime default (GetDate()),-- wymagane przez COdsetkiKB,
  KRo_KRoId int,
  KRo_Typ smallint,
  KRo_Dokument varchar(256),
  KRo_DataDokumentu datetime,
  KRo_DataOperacji datetime,
  KRo_TerminPlatnosci datetime,
  KRo_DataRozliczenia datetime,
  KRo_KwotaDok decimal(15, 2),
  KRo_Kwota decimal(15, 2),
  KRo_SumRozliczen decimal(15, 2),
  KRo_DeEId int,
  KRo_Bufor tinyint,
  KRo_Storno tinyint,
  KRo_BOEId int,
  KRo_RozliczenieId int,
  KRo_Strona int,
  KRo_KwotaDokWal decimal(15, 2),
  KRo_KwotaWal decimal(15, 2),
  KRo_SumRozliczenWal decimal(15, 2),
  KRo_Waluta nvarchar(3),
  KRo_DataRoz datetime,
  KRo_IdentKsieg varchar(50),
  KRo_Konto nvarchar(50),
  KRo_KontoIdx nvarchar(50),
  KRo_KontoPrzeciw nvarchar(50),
  KRo_NrDziennika nvarchar(30),
  KRo_NrKsiegi nvarchar(30),
  KRo_Opis nvarchar(50),
  KRo_OObId int,
  KRo_Dziennik nvarchar(30),
  KRo_NumerDziennika int,
  KwotaRozliczenia decimal(15, 2),
  KwotaDokumentu decimal(15, 2),
  SumaRozliczen decimal(15, 2),
  PozostajeWn decimal(15, 2),
  PozostajeMa decimal(15, 2),
  DoRozliczenia decimal(15, 2),
  PodstawaOdsetek decimal(15, 2),
  CiaglaNumeracjaDC int,
  NumerKsiegi nvarchar(50),
  NrDziennika nvarchar(50),
  NrDziennikaCzastkowego nvarchar(50),
  PoTerminie int,
  Odsetki Decimal(15,2),
  Przeterminowane nvarchar(1),
  SaldoWn decimal(15,2) default 0,
  SaldoMa decimal(15,2) default 0
 )
 if Len(@DataDokumentu) > 0
 begin
  Set @where =  @where + ' and ' + @DataDokumentu
 end
 if Len(@TerminPlatnosci) > 0
 begin
  Set @where =  @where + ' and ' + @TerminPlatnosci
 end
 if Len(@Dokument) > 0
 begin
  Set @where = @where + ' and ' + @Dokument
 end
 if Len(@Opis) > 0
 begin
  Set @where = @where + ' and ' + @Opis
 end
 if Len(@IdKsiegowy) > 0
 begin
  Set @where = @where + ' and ' + @IdKsiegowy
 end
 if Len(@Waluta) > 0
 begin
  Set @where = @where + ' and ' + @Waluta
 end
 if Len(@Bufor) > 0
 begin
  Set @where = @where + ' and ' + @Bufor
 end
 if Len(@CzesciowoCalkowicie) > 0
 begin
  Set @where = @where + ' and ' + @CzesciowoCalkowicie
 end
 if Len(@PozostajeWnMa) > 0
 begin
  Set @where = @where + ' and ' + @PozostajeWnMa
 end
 Set @kontoWhereLike = NULL;
 if IsNull(@KontoId,0) <> 0
 begin
  select @accAnalityka = Acc_Analityka, @accNumer = acc_numer from cdn.Konta where Acc_AccId = @KontoId
  Set @kontoWhere = ' and KRo_Konto=''' + @accNumer + '''';
  if IsNull(@accAnalityka, 0) = 0
   Set @kontoWhereLike = ' and KRo_Konto like ''' + @accNumer + '-%''';
  /*
  if @accAnalityka = 1
   Set @kontoWhere = ' and KRo_Konto=''' + @accNumer + '''';
  else
   Set @kontoWhere = ' and KRo_Konto like ''' + @accNumer + '%''';
  */
 end
 set @sql = 'insert into #kh_rozrachunki '
   + '(DataRozliczenia, KRo_KRoId,KRo_Typ,KRo_Dokument,KRo_DataDokumentu,KRo_DataOperacji,KRo_TerminPlatnosci,KRo_DataRozliczenia,KRo_KwotaDok,KRo_Kwota,KRo_SumRozliczen,KRo_DeEId, '
   + 'KRo_Bufor,KRo_Storno,KRo_BOEId,KRo_RozliczenieId,KRo_Strona,KRo_KwotaDokWal,KRo_KwotaWal,KRo_SumRozliczenWal,KRo_Waluta,KRo_DataRoz,KRo_IdentKsieg, '
   + 'KRo_Konto,KRo_KontoIdx,KRo_KontoPrzeciw,KRo_NrDziennika,KRo_NrKsiegi,KRo_Opis,KRo_OObId,KRo_Dziennik,KRo_NumerDziennika,'
   + 'KwotaRozliczenia, KwotaDokumentu, SumaRozliczen, PozostajeWn, PozostajeMa, DoRozliczenia, PodstawaOdsetek, CiaglaNumeracjaDC, NumerKsiegi, NrDziennika, NrDziennikaCzastkowego, PoTerminie, Przeterminowane) '
   + 'select '
   + @DataBiezaca + ','
   + 'child.KRo_KRoId,child.KRo_Typ,child.KRo_Dokument,child.KRo_DataDokumentu,child.KRo_DataOperacji,child.KRo_TerminPlatnosci,child.KRo_DataRozliczenia,child.KRo_KwotaDok,child.KRo_Kwota,child.KRo_SumRozliczen,child.KRo_DeEId, '
   + 'child.KRo_Bufor,child.KRo_Storno,child.KRo_BOEId,child.KRo_RozliczenieId,child.KRo_Strona,child.KRo_KwotaDokWal,child.KRo_KwotaWal,child.KRo_SumRozliczenWal,child.KRo_Waluta,child.KRo_DataRoz,child.KRo_IdentKsieg, '
   + 'child.KRo_Konto,child.KRo_KontoIdx,child.KRo_KontoPrzeciw,child.KRo_NrDziennika,child.KRo_NrKsiegi,child.KRo_Opis,child.KRo_OObId,child.KRo_Dziennik,child.KRo_NumerDziennika,'
   + @KwotaRozliczeniauField + ','
   + @kwotaDokumentuField + ','
   + @SumaRozliczen + ','
   + @PozostajeWn + ','
   + @PozostajeMa + ','
   +   @DoRozliczenia + ','
   +   @PodstawaOdsetek + ','
   + 'OOb_CiaglaNumeracjaDC, '
   + 'case when child.KRo_Typ = 1 then substring( child.KRo_Nrksiegi, CHARINDEX(''/'', child.KRo_Nrksiegi)+1, case CHARINDEX(''/'', child.KRo_Nrksiegi, CHARINDEX(''/'', child.KRo_Nrksiegi)+1) when 0 then len(child.KRo_Nrksiegi) else CHARINDEX(''/'', child.KRo_Nrksiegi, CHARINDEX(''/'', child.KRo_Nrksiegi)+1) - CHARINDEX(''/'', child.KRo_Nrksiegi) -1 end) else child.KRo_Nrksiegi end as NumerKsiegi,'
   + 'case when child.KRo_Bufor <> 0 then child.KRo_NrKsiegi + '' B'' else child.KRo_NrKsiegi end as NrDziennika,'
   + 'RTRIM(case when child.KRo_BOEId is not null then child.Kro_NrKsiegi when OOb_CiaglaNumeracjaDC=1 then child.KRo_Dziennik+ ''/'' + convert (char, child.KRo_NumerDziennika) else child.KRo_Dziennik+ ''/'' + convert(char(7), child.KRo_DataDokumentu, 111) + ''/'' + convert (char, child.KRo_NumerDziennika) end) as NrDziennikaCzastkowego, '
   + @PoTerminie + ','
   + @Przeterminowane+ ' '
   + 'from cdn.KsiRozrachunki as child '
   + 'left outer join CDN.OkresyObrach on (child.KRo_OObID = OOb_OObId) '
   + 'where child.KRo_RozliczenieId Is Null and KRo_KwotaDok != 0 and KRo_KwotaDok <> KRo_SumRozliczen '
 Set @command = @sql + @kontoWhere + @where
 Execute dbo.sp_executesql @command
 if @kontoWhereLike is not null
 begin
  Set @command = @sql + @kontoWhereLike + @where
  Execute dbo.sp_executesql @command
 end
 Set @kontoWhereLike = NULL;
 if IsNull(@KontoRozliczajaceId,0) <> 0 And  IsNull(@KontoId,0) <>  IsNull(@KontoRozliczajaceId,0)
 begin
  select @accAnalityka = Acc_Analityka, @accNumer = acc_numer from cdn.Konta where Acc_AccId = @KontoRozliczajaceId
    declare @kontoWherePre    nvarchar(255) = ' and not exists(select * from #kh_rozrachunki D where D.KRo_DeEId = child.KRo_DeEId) '
                                                + ' and not exists(select * from #kh_rozrachunki B where B.KRo_BoEId = child.KRo_BoEId) ';
  Set @kontoWhere =  @kontoWherePre + ' and KRo_Konto=''' + @accNumer + '''';
  if IsNull(@accAnalityka, 0) = 0
   Set @kontoWhereLike =  @kontoWherePre + ' and KRo_Konto like ''' + @accNumer + '-%''';
  /*
  if @accAnalityka = 1
   Set @kontoWhere =  @kontoWhere + ' and KRo_Konto=''' + @accNumer + '''';
  else
   Set @kontoWhere =  @kontoWhere + ' and KRo_Konto like ''' + @accNumer + '%''';
  */
  Set @command = @sql + @kontoWhere + @where
  Execute dbo.sp_executesql @command
  if @kontoWhereLike is not null
  begin
   Set @command = @sql + @kontoWhereLike + @where
   Execute dbo.sp_executesql @command
  end
 end
 set @sql = 'insert into #kh_rozrachunki ('
   + 'DataRozliczenia, ParentId,TreeLevel,KRo_KRoId,KRo_Typ,KRo_Dokument,KRo_DataDokumentu,KRo_DataOperacji,KRo_TerminPlatnosci,KRo_DataRozliczenia,KRo_KwotaDok,KRo_Kwota,KRo_SumRozliczen,KRo_DeEId,'
   + 'KRo_Bufor,KRo_Storno,KRo_BOEId,KRo_RozliczenieId,KRo_Strona,KRo_KwotaDokWal,KRo_KwotaWal,KRo_SumRozliczenWal,KRo_Waluta,KRo_DataRoz,KRo_IdentKsieg,KRo_Konto,'
   + 'KRo_KontoIdx,KRo_KontoPrzeciw,KRo_NrDziennika,KRo_NrKsiegi,KRo_Opis,KRo_OObId,KRo_Dziennik,KRo_NumerDziennika,'
   + 'KwotaRozliczenia, KwotaDokumentu, SumaRozliczen, PozostajeWn, PozostajeMa, CiaglaNumeracjaDC, NumerKsiegi, NrDziennika, NrDziennikaCzastkowego, PoTerminie, Przeterminowane) '
   + 'select '
   + @DataBiezaca + ','
   + 'parent.Id,2,child.KRo_KRoId,child.KRo_Typ,child.KRo_Dokument,child.KRo_DataDokumentu,child.KRo_DataOperacji,child.KRo_TerminPlatnosci,child.KRo_DataRozliczenia,child.KRo_KwotaDok,'
   + 'child.KRo_Kwota,child.KRo_SumRozliczen,child.KRo_DeEId,child.KRo_Bufor,child.KRo_Storno,child.KRo_BOEId,child.KRo_RozliczenieId,child.KRo_Strona,child.KRo_KwotaDokWal,'
   + 'child.KRo_KwotaWal,child.KRo_SumRozliczenWal,child.KRo_Waluta,child.KRo_DataRoz,child.KRo_IdentKsieg,child.KRo_Konto,child.KRo_KontoIdx,child.KRo_KontoPrzeciw,'
   + 'child.KRo_NrDziennika,child.KRo_NrKsiegi,child.KRo_Opis,child.KRo_OObId,child.KRo_Dziennik,child.KRo_NumerDziennika,'
   + @KwotaRozliczeniauField + ','
   + @kwotaDokumentuField + ','
   + @SumaRozliczen + ','
   + @PozostajeWn + ','
   + @PozostajeMa + ','
   + 'OOb_CiaglaNumeracjaDC, '
   + 'case when child.KRo_Typ = 1 then substring( child.KRo_Nrksiegi, CHARINDEX(''/'', child.KRo_Nrksiegi)+1, case CHARINDEX(''/'', child.KRo_Nrksiegi, CHARINDEX(''/'', child.KRo_Nrksiegi)+1) when 0 then len(child.KRo_Nrksiegi) else CHARINDEX(''/'', child.KRo_Nrksiegi, CHARINDEX(''/'', child.KRo_Nrksiegi)+1) - CHARINDEX(''/'', child.KRo_Nrksiegi) -1 end) else child.KRo_Nrksiegi end as NumerKsiegi,'
   + 'case when child.KRo_Bufor <> 0 then child.KRo_NrKsiegi + '' B'' else child.KRo_NrKsiegi end as NrDziennika,'
   + 'RTRIM(case when child.KRo_BOEId is not null then child.Kro_NrKsiegi when OOb_CiaglaNumeracjaDC=1 then child.KRo_Dziennik+ ''/'' + convert (char, child.KRo_NumerDziennika) else child.KRo_Dziennik+ ''/'' + convert(char(7), child.KRo_DataDokumentu, 111) + ''/'' + convert (char, child.KRo_NumerDziennika) end) as NrDziennikaCzastkowego, '
   + @PoTerminie + ','
   + @Przeterminowane+ ' '
   + 'from '
   + '#kh_rozrachunki parent '
   + 'join cdn.KsiRozrachunki RR on (parent.KRo_DeEId = RR.KRo_DeEId) '
   + 'join cdn.KsiRozrachunki child on (RR.KRo_KRoId = child.KRo_RozliczenieId) '
   + 'left outer join CDN.OkresyObrach on (child.KRo_OObID = OOb_OObId) '
   + 'where parent.ParentId is Null '
 Execute dbo.sp_executesql @sql
 set @sql = 'insert into #kh_rozrachunki ('
   + 'DataRozliczenia, ParentId,TreeLevel,KRo_KRoId,KRo_Typ,KRo_Dokument,KRo_DataDokumentu,KRo_DataOperacji,KRo_TerminPlatnosci,KRo_DataRozliczenia,KRo_KwotaDok,KRo_Kwota,KRo_SumRozliczen,KRo_DeEId,'
   + 'KRo_Bufor,KRo_Storno,KRo_BOEId,KRo_RozliczenieId,KRo_Strona,KRo_KwotaDokWal,KRo_KwotaWal,KRo_SumRozliczenWal,KRo_Waluta,KRo_DataRoz,KRo_IdentKsieg,KRo_Konto,'
   + 'KRo_KontoIdx,KRo_KontoPrzeciw,KRo_NrDziennika,KRo_NrKsiegi,KRo_Opis,KRo_OObId,KRo_Dziennik,KRo_NumerDziennika,'
   + 'KwotaRozliczenia, KwotaDokumentu, SumaRozliczen, PozostajeWn, PozostajeMa, CiaglaNumeracjaDC, NumerKsiegi, NrDziennika, NrDziennikaCzastkowego) '
   + 'select '
   + @DataBiezaca + ','
   + 'parent.Id,2,child.KRo_KRoId,child.KRo_Typ,child.KRo_Dokument,child.KRo_DataDokumentu,child.KRo_DataOperacji,child.KRo_TerminPlatnosci,child.KRo_DataRozliczenia,child.KRo_KwotaDok,'
   + 'child.KRo_Kwota,child.KRo_SumRozliczen,child.KRo_DeEId,child.KRo_Bufor,child.KRo_Storno,child.KRo_BOEId,child.KRo_RozliczenieId,child.KRo_Strona,child.KRo_KwotaDokWal,'
   + 'child.KRo_KwotaWal,child.KRo_SumRozliczenWal,child.KRo_Waluta,child.KRo_DataRoz,child.KRo_IdentKsieg,child.KRo_Konto,child.KRo_KontoIdx,child.KRo_KontoPrzeciw,'
   + 'child.KRo_NrDziennika,child.KRo_NrKsiegi,child.KRo_Opis,child.KRo_OObId,child.KRo_Dziennik,child.KRo_NumerDziennika, '
   + @KwotaRozliczeniauField + ','
   + @kwotaDokumentuField + ','
   + @SumaRozliczen + ','
   + @PozostajeWn + ','
   + @PozostajeMa + ','
   + 'OOb_CiaglaNumeracjaDC, '
   + 'case when child.KRo_Typ = 1 then substring( child.KRo_Nrksiegi, CHARINDEX(''/'', child.KRo_Nrksiegi)+1, case CHARINDEX(''/'', child.KRo_Nrksiegi, CHARINDEX(''/'', child.KRo_Nrksiegi)+1) when 0 then len(child.KRo_Nrksiegi) else CHARINDEX(''/'', child.KRo_Nrksiegi, CHARINDEX(''/'', child.KRo_Nrksiegi)+1) - CHARINDEX(''/'', child.KRo_Nrksiegi) -1 end) else child.KRo_Nrksiegi end as NumerKsiegi,'
   + 'case when child.KRo_Bufor <> 0 then child.KRo_NrKsiegi + '' B'' else child.KRo_NrKsiegi end as NrDziennika,'
   + 'RTRIM(case when child.KRo_BOEId is not null then child.Kro_NrKsiegi when OOb_CiaglaNumeracjaDC=1 then child.KRo_Dziennik+ ''/'' + convert (char, child.KRo_NumerDziennika) else child.KRo_Dziennik+ ''/'' + convert(char(7), child.KRo_DataDokumentu, 111) + ''/'' + convert (char, child.KRo_NumerDziennika) end) as NrDziennikaCzastkowego '
   + 'from '
   + '#kh_rozrachunki parent '
   + 'join cdn.KsiRozrachunki RR on (parent.KRo_BoEId = RR.KRo_BoEId) '
   + 'join cdn.KsiRozrachunki child on (RR.KRo_KRoId = child.KRo_RozliczenieId) '
   + 'left outer join CDN.OkresyObrach on (child.KRo_OObID = OOb_OObId) '
   + 'where parent.ParentId is Null '
 Execute dbo.sp_executesql @sql
 -- Wyliczenie Sald
 declare @SaldoWn decimal (15,2)
 declare @SaldoMa decimal (15,2)
 select @SaldoWn = Sum(IsNull(PozostajeWn,0)), @SaldoMa = Sum(IsNull(PozostajeMa,0)) from #kh_rozrachunki where TreeLevel = 1
 Update #kh_rozrachunki Set SaldoWn=@SaldoWn, SaldoMa=@SaldoMa where Id = 1
 select * from #kh_rozrachunki
 drop table #kh_rozrachunki
 SET NOCOUNT OFF
