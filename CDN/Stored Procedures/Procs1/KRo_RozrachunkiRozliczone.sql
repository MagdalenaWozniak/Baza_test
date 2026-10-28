CREATE procedure CDN.KRo_RozrachunkiRozliczone
 @KontoId    int,    -- 1
 @KontoRozliczajaceId int,    -- 2
 @RozneKonta    int,    -- 3
 @DataDokumentu   nvarchar(255),  -- 4
 @TerminPlatnosci  nvarchar(255),  -- 5
 @Dokument    nvarchar(256),  -- 6
 @Opis     nvarchar(255),  -- 7
 @IdKsiegowy    nvarchar(255),  -- 8
 @Waluta     nvarchar(255),  -- 9
 @Bufor     nvarchar(255),  --10
 @CzesciowoCalkowicie nvarchar(255),  --11
 @StronaWn    int,    --12
 @StronaMa    int     --13
As
 SET NOCOUNT ON
 declare @sql     nvarchar(4000)
 declare @where     nvarchar(4000); Set @where = ''
 declare @kontoWhere    nvarchar(4000)
 declare @kontoWhereLike   nvarchar(4000)
 declare @accAnalityka   int
 declare @accNumer    nvarchar(50)
 declare @KwotaRozliczeniaField nvarchar(50)
 declare @kwotaDokumentuField nvarchar(50)
 declare @SumaRozliczen   nvarchar(50)
 declare @Rozliczono    nvarchar(200)
 declare @RozliczonoWn   nvarchar(200)
 declare @RozliczonoMa   nvarchar(200)
 declare @NumerKsiegi   nvarchar(500)
 declare @NrDziennika   nvarchar(500)
 declare @NrDziennikaCzastkowego nvarchar(500)
 declare @Zwloka     nvarchar(256)
 Set @NumerKsiegi    = 'case when KRo_Typ = 1 then substring( KRo_Nrksiegi, CHARINDEX(''/'', KRo_Nrksiegi)+1, case CHARINDEX(''/'', KRo_Nrksiegi, CHARINDEX(''/'', KRo_Nrksiegi)+1) when 0 then len(KRo_Nrksiegi) else CHARINDEX(''/'', KRo_Nrksiegi, CHARINDEX(''/'', KRo_Nrksiegi)+1) - CHARINDEX(''/'', KRo_Nrksiegi) -1 end) else KRo_Nrksiegi end'
 Set @NrDziennika    = 'case when KRo_Bufor <> 0 then KRo_NrKsiegi + '' B'' else KRo_NrKsiegi end'
 Set @NrDziennikaCzastkowego  = 'RTRIM(case when KRo_BOEId is not null then Kro_NrKsiegi when OOb_CiaglaNumeracjaDC=1 then KRo_Dziennik+ ''/'' + convert (char, KRo_NumerDziennika) else KRo_Dziennik+ ''/'' + convert(char(7), KRo_DataDokumentu, 111) + ''/'' + convert (char, KRo_NumerDziennika) end)'
 Set @Zwloka      = 'case when child.KRo_DataRoz > CDN.fn_GetWorkingDayAfter(child.KRo_TerminPlatnosci) then DATEDIFF(DAY, CDN.fn_GetWorkingDayAfter(child.KRo_TerminPlatnosci), child.KRo_DataRoz) else NULL end'
 if @Waluta = '1=1' or Len(@Waluta) = 0
 begin
  Set @KwotaRozliczeniaField  = 'KRo_Kwota'
  Set @kwotaDokumentuField = 'KRo_KwotaDok'
  Set @SumaRozliczen   = 'KRo_SumRozliczen'
  Set @Rozliczono    = 'case when ParentId Is Null then KRo_SumRozliczen else KRo_Kwota end'
  Set @RozliczonoWn   = 'case when KRo_Strona = 1 then '+@Rozliczono+' else NULL end'
  Set @RozliczonoMa   = 'case when KRo_Strona = 2 then '+@Rozliczono+' else NULL end'
 end
 else
 begin
  Set @KwotaRozliczeniaField = 'KRo_KwotaWal'
  Set @kwotaDokumentuField = 'KRo_KwotaDokWal'
  Set @SumaRozliczen   = 'KRo_SumRozliczenWal'
  Set @Rozliczono    = 'case when ParentId Is Null then KRo_SumRozliczenWal else KRo_KwotaWal end'
  Set @RozliczonoWn   = 'case when KRo_Strona = 1 then '+@Rozliczono+' else NULL end'
  Set @RozliczonoMa   = 'case when KRo_Strona = 2 then '+@Rozliczono+' else NULL end'
 end
 /*
 if @RozneKonta <> 0
 begin
  if @KontoId <> 0 and @KontoRozliczajaceId <> 0 and @KontoId <> @KontoRozliczajaceId
   Set @RozneKonta = 1
  else
   Set @RozneKonta = 0
 end
 */
 CREATE TABLE #kh_rozrachunki (
  Id int not null identity(1, 1) primary key,
  ParentId int default NULL,
  TreeLevel int default 1,
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
  KRo_Waluta varchar(3),
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
  RozliczonoWn decimal(15, 2),
  RozliczonoMa decimal(15, 2),
  CiaglaNumeracjaDC int,
  NumerKsiegi nvarchar(50),
  NrDziennika nvarchar(50),
  NrDziennikaCzastkowego nvarchar(50),
  Zwloka int,
  Report_Order int
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
 if @StronaWn <> 0 and @StronaMa = 0
 begin
  Set @where = @where + ' and KRo_Strona = 1'
 end
 else
 if @StronaWn = 0 and @StronaMa <> 0
 begin
 Set @where = @where + ' and KRo_Strona = 2'
 end
 Set @kontoWhereLike = NULL;
 if IsNull(@KontoId, 0) <> 0
 begin
  select @accAnalityka = Acc_Analityka, @accNumer = acc_numer from cdn.Konta where Acc_AccId = @KontoId
  Set @kontoWhere = ' and KRo_Konto=''' + @accNumer + '''';
  if IsNull(@accAnalityka,0) = 0
   Set @kontoWhereLike = ' and KRo_Konto like ''' + @accNumer + '-%''';
  /*
  if @accAnalityka = 1
   Set @kontoWhere = ' and KRo_Konto=''' + @accNumer + '''';
  else
   Set @kontoWhere = ' and KRo_Konto like ''' + @accNumer + '%''';
  */
 end
 Set @sql = 'insert into #kh_rozrachunki (KRo_DeEId) '
   + 'select Distinct KRo_DeEId from cdn.KsiRozrachunki '
   + 'where KRo_DeEId is not Null and KRo_RozliczenieId Is Not Null'
   + @kontoWhere
   + @where
   + ' order by 1 '
 Execute dbo.sp_executesql @sql
 if @kontoWhereLike is not null
 begin
  Set @sql = 'insert into #kh_rozrachunki (KRo_DeEId) '
    + 'select Distinct KRo_DeEId from cdn.KsiRozrachunki '
    + 'where KRo_DeEId is not Null and KRo_RozliczenieId Is Not Null'
    + @kontoWhereLike
    + @where
    + ' order by 1 '
  Execute dbo.sp_executesql @sql
 end
 Set @sql = 'insert into #kh_rozrachunki (KRo_BoEId) '
   + 'select Distinct KRo_BoEId from cdn.KsiRozrachunki '
   + 'where KRo_BoEId is not Null and KRo_RozliczenieId Is Not Null'
   + @kontoWhere
   + @where
   + ' order by 1'
 Execute dbo.sp_executesql @sql
 if @kontoWhereLike is not null
 begin
  Set @sql = 'insert into #kh_rozrachunki (KRo_BoEId) '
    + 'select Distinct KRo_BoEId from cdn.KsiRozrachunki '
    + 'where KRo_BoEId is not Null and KRo_RozliczenieId Is Not Null'
    + @kontoWhereLike
    + @where
    + ' order by 1'
  Execute dbo.sp_executesql @sql
 end
 Set @kontoWhereLike = NULL;
 if IsNull(@KontoRozliczajaceId,0) <> 0 and IsNull(@KontoId, 0) <> IsNull(@KontoRozliczajaceId,0)
 begin
  select @accAnalityka = Acc_Analityka, @accNumer = acc_numer from cdn.Konta where Acc_AccId = @KontoRozliczajaceId
  Set @kontoWhere = ' and cdn.KsiRozrachunki.KRo_Konto=''' + @accNumer + '''';
  if IsNull(@accAnalityka,0) = 0
   Set @kontoWhereLike = ' and cdn.KsiRozrachunki.KRo_Konto like ''' + @accNumer + '-%''';
  /*
  if @accAnalityka = 1
   Set @kontoWhere = ' and cdn.KsiRozrachunki.KRo_Konto=''' + @accNumer + '''';
  else
   Set @kontoWhere = ' and cdn.KsiRozrachunki.KRo_Konto like ''' + @accNumer + '%''';
  */
  Set @sql = 'insert into #kh_rozrachunki (KRo_DeEId) '
    + 'select Distinct cdn.KsiRozrachunki.KRo_DeEId from cdn.KsiRozrachunki  '
    + 'where cdn.KsiRozrachunki.KRo_DeEId is not Null and cdn.KsiRozrachunki.KRo_RozliczenieId Is Not Null'
    +   ' and not exists(select * from #kh_rozrachunki E where E.KRo_DeEId = cdn.KsiRozrachunki.KRo_DeEId) '
    + @kontoWhere
    + @where
    + ' order by 1 '
  Execute dbo.sp_executesql @sql
  if @kontoWhereLike is not null
  begin
   Set @sql = 'insert into #kh_rozrachunki (KRo_DeEId) '
     + 'select Distinct cdn.KsiRozrachunki.KRo_DeEId from cdn.KsiRozrachunki  '
     + 'where cdn.KsiRozrachunki.KRo_DeEId is not Null and cdn.KsiRozrachunki.KRo_RozliczenieId Is Not Null'
     +   ' and not exists(select * from #kh_rozrachunki E where E.KRo_DeEId = cdn.KsiRozrachunki.KRo_DeEId) '
     + @kontoWhereLike
     + @where
     + ' order by 1 '
   Execute dbo.sp_executesql @sql
  end
  Set @sql = 'insert into #kh_rozrachunki (KRo_BoEId) '
    + 'select Distinct cdn.KsiRozrachunki.KRo_BoEId from cdn.KsiRozrachunki  '
    + 'where cdn.KsiRozrachunki.KRo_BoEId is not Null and cdn.KsiRozrachunki.KRo_RozliczenieId Is Not Null'
    +   ' and not exists(select * from #kh_rozrachunki E where E.KRo_BoEId = cdn.KsiRozrachunki.KRo_BoEId) '
    + @kontoWhere
    + @where
    + ' order by 1'
  Execute dbo.sp_executesql @sql
  if @kontoWhereLike is not null
  begin
   Set @sql = 'insert into #kh_rozrachunki (KRo_BoEId) '
     + 'select Distinct cdn.KsiRozrachunki.KRo_BoEId from cdn.KsiRozrachunki  '
     + 'where cdn.KsiRozrachunki.KRo_BoEId is not Null and cdn.KsiRozrachunki.KRo_RozliczenieId Is Not Null'
     +   ' and not exists(select * from #kh_rozrachunki E where E.KRo_BoEId = cdn.KsiRozrachunki.KRo_BoEId) '
     + @kontoWhereLike
     + @where
     + ' order by 1'
   Execute dbo.sp_executesql @sql
  end
 end
 Set @sql = 'update  #kh_rozrachunki Set '
   + '#kh_rozrachunki.KRo_KRoId = child.KRo_KRoId, '
   + '#kh_rozrachunki.KRo_Typ = child.KRo_Typ, '
   + '#kh_rozrachunki.KRo_Dokument = child.KRo_Dokument, '
   + '#kh_rozrachunki.KRo_DataDokumentu = child.KRo_DataDokumentu, '
   + '#kh_rozrachunki.KRo_DataOperacji = child.KRo_DataOperacji, '
   + '#kh_rozrachunki.KRo_TerminPlatnosci = child.KRo_TerminPlatnosci, '
   + '#kh_rozrachunki.KRo_DataRozliczenia = child.KRo_DataRozliczenia, '
   + '#kh_rozrachunki.KRo_KwotaDok = child.KRo_KwotaDok, '
   + '#kh_rozrachunki.KRo_Kwota = child.KRo_Kwota, '
   + '#kh_rozrachunki.KRo_SumRozliczen = child.KRo_SumRozliczen, '
   --+ '#kh_rozrachunki.KRo_DeEId = child.KRo_DeEId, '
   + '#kh_rozrachunki.KRo_Bufor = child.KRo_Bufor, '
   + '#kh_rozrachunki.KRo_Storno = child.KRo_Storno, '
   + '#kh_rozrachunki.KRo_BOEId = child.KRo_BOEId, '
   + '#kh_rozrachunki.KRo_RozliczenieId = child.KRo_RozliczenieId, '
   + '#kh_rozrachunki.KRo_Strona = child.KRo_Strona, '
   + '#kh_rozrachunki.KRo_KwotaDokWal = child.KRo_KwotaDokWal, '
   + '#kh_rozrachunki.KRo_KwotaWal = child.KRo_KwotaWal, '
   + '#kh_rozrachunki.KRo_SumRozliczenWal = child.KRo_SumRozliczenWal, '
   + '#kh_rozrachunki.KRo_Waluta = child.KRo_Waluta, '
   + '#kh_rozrachunki.KRo_DataRoz = child.KRo_DataRoz, '
   + '#kh_rozrachunki.KRo_IdentKsieg = child.KRo_IdentKsieg, '
   + '#kh_rozrachunki.KRo_Konto = child.KRo_Konto, '
   + '#kh_rozrachunki.KRo_KontoIdx = child.KRo_KontoIdx, '
   + '#kh_rozrachunki.KRo_KontoPrzeciw = child.KRo_KontoPrzeciw, '
   + '#kh_rozrachunki.KRo_NrDziennika = child.KRo_NrDziennika, '
   + '#kh_rozrachunki.KRo_NrKsiegi = child.KRo_NrKsiegi, '
   + '#kh_rozrachunki.KRo_Opis = child.KRo_Opis, '
   + '#kh_rozrachunki.KRo_OObId = child.KRo_OObId, '
   + '#kh_rozrachunki.KRo_Dziennik = child.KRo_Dziennik, '
   + '#kh_rozrachunki.KRo_NumerDziennika = child.KRo_NumerDziennika, '
   + '#kh_rozrachunki.Zwloka = ' + @Zwloka + ' '
   + 'from  #kh_rozrachunki '
   + 'cross apply  (select top 1 * from cdn.KsiRozrachunki RR where #kh_rozrachunki.KRo_DeEId = RR.KRo_DeEId and RR.KRo_RozliczenieId is not null) as child'
 Execute dbo.sp_executesql @sql
 Set @sql = 'update  #kh_rozrachunki Set '
   + '#kh_rozrachunki.KRo_KRoId = child.KRo_KRoId, '
   + '#kh_rozrachunki.KRo_Typ = child.KRo_Typ, '
   + '#kh_rozrachunki.KRo_Dokument = child.KRo_Dokument, '
   + '#kh_rozrachunki.KRo_DataDokumentu = child.KRo_DataDokumentu, '
   + '#kh_rozrachunki.KRo_DataOperacji = child.KRo_DataOperacji, '
   + '#kh_rozrachunki.KRo_TerminPlatnosci = child.KRo_TerminPlatnosci, '
   + '#kh_rozrachunki.KRo_DataRozliczenia = child.KRo_DataRozliczenia, '
   + '#kh_rozrachunki.KRo_KwotaDok = child.KRo_KwotaDok, '
   + '#kh_rozrachunki.KRo_Kwota = child.KRo_Kwota, '
   + '#kh_rozrachunki.KRo_SumRozliczen = child.KRo_SumRozliczen, '
   + '#kh_rozrachunki.KRo_DeEId = child.KRo_DeEId, '
   + '#kh_rozrachunki.KRo_Bufor = child.KRo_Bufor, '
   + '#kh_rozrachunki.KRo_Storno = child.KRo_Storno, '
   --+ '#kh_rozrachunki.KRo_BOEId = child.KRo_BOEId, '
   + '#kh_rozrachunki.KRo_RozliczenieId = child.KRo_RozliczenieId, '
   + '#kh_rozrachunki.KRo_Strona = child.KRo_Strona, '
   + '#kh_rozrachunki.KRo_KwotaDokWal = child.KRo_KwotaDokWal, '
   + '#kh_rozrachunki.KRo_KwotaWal = child.KRo_KwotaWal, '
   + '#kh_rozrachunki.KRo_SumRozliczenWal = child.KRo_SumRozliczenWal, '
   + '#kh_rozrachunki.KRo_Waluta = child.KRo_Waluta, '
   + '#kh_rozrachunki.KRo_DataRoz = child.KRo_DataRoz, '
   + '#kh_rozrachunki.KRo_IdentKsieg = child.KRo_IdentKsieg, '
   + '#kh_rozrachunki.KRo_Konto = child.KRo_Konto, '
   + '#kh_rozrachunki.KRo_KontoIdx = child.KRo_KontoIdx, '
   + '#kh_rozrachunki.KRo_KontoPrzeciw = child.KRo_KontoPrzeciw, '
   + '#kh_rozrachunki.KRo_NrDziennika = child.KRo_NrDziennika, '
   + '#kh_rozrachunki.KRo_NrKsiegi = child.KRo_NrKsiegi, '
   + '#kh_rozrachunki.KRo_Opis = child.KRo_Opis, '
   + '#kh_rozrachunki.KRo_OObId = child.KRo_OObId, '
   + '#kh_rozrachunki.KRo_Dziennik = child.KRo_Dziennik, '
   + '#kh_rozrachunki.KRo_NumerDziennika = child.KRo_NumerDziennika, '
   + '#kh_rozrachunki.Zwloka = ' + @Zwloka + ' '
   + 'from  #kh_rozrachunki '
   + 'cross apply  (select top 1 * from cdn.KsiRozrachunki RR where #kh_rozrachunki.KRo_BoEId = RR.KRo_BoEId and RR.KRo_RozliczenieId is not null) as child'
 Execute dbo.sp_executesql @sql
 set @where = ''
 --if @RozneKonta <> 0 Set @where = ' and RR.KRo_KontoIdx <> child.KRo_KontoIdx'
 Set @sql = 'insert into #kh_rozrachunki ( '
   + 'ParentId, '
   + 'TreeLevel, '
   + 'KRo_KRoId,  '
   + 'KRo_Typ,  '
   + 'KRo_Dokument, '
   + 'KRo_DataDokumentu, '
   + 'KRo_DataOperacji, '
   + 'KRo_TerminPlatnosci, '
   + 'KRo_DataRozliczenia, '
   + 'KRo_KwotaDok, '
   + 'KRo_Kwota, '
   + 'KRo_SumRozliczen, '
   + 'KRo_DeEId, '
   + 'KRo_Bufor, '
   + 'KRo_Storno, '
   + 'KRo_BOEId, '
   + 'KRo_RozliczenieId, '
   + 'KRo_Strona, '
   + 'KRo_KwotaDokWal, '
   + 'KRo_KwotaWal, '
   + 'KRo_SumRozliczenWal, '
   + 'KRo_Waluta, '
   + 'KRo_DataRoz, '
   + 'KRo_IdentKsieg, '
   + 'KRo_Konto, '
   + 'KRo_KontoIdx, '
   + 'KRo_KontoPrzeciw, '
   + 'KRo_NrDziennika, '
   + 'KRo_NrKsiegi, '
   + 'KRo_Opis, '
   + 'KRo_OObId, '
   + 'KRo_Dziennik, '
   + 'KRo_NumerDziennika ) '
   + 'select R.Id, '
   + '2, '
   + 'child.KRo_KRoId,  '
   + 'child.KRo_Typ,  '
   + 'child.KRo_Dokument, '
   + 'child.KRo_DataDokumentu, '
   + 'child.KRo_DataOperacji, '
   + 'child.KRo_TerminPlatnosci, '
   + 'child.KRo_DataRozliczenia, '
   + 'child.KRo_KwotaDok, '
   + 'child.KRo_Kwota, '
   + 'child.KRo_SumRozliczen, '
   + 'child.KRo_DeEId, '
   + 'child.KRo_Bufor, '
   + 'child.KRo_Storno, '
   + 'child.KRo_BOEId, '
   + 'child.KRo_RozliczenieId, '
   + 'child.KRo_Strona, '
   + 'child.KRo_KwotaDokWal, '
   + 'child.KRo_KwotaWal, '
   + 'child.KRo_SumRozliczenWal, '
   + 'child.KRo_Waluta, '
   + 'child.KRo_DataRoz, '
   + 'child.KRo_IdentKsieg, '
   + 'child.KRo_Konto, '
   + 'child.KRo_KontoIdx, '
   + 'child.KRo_KontoPrzeciw, '
   + 'child.KRo_NrDziennika, '
   + 'child.KRo_NrKsiegi, '
   + 'child.KRo_Opis, '
   + 'child.KRo_OObId, '
   + 'child.KRo_Dziennik, '
   + 'child.KRo_NumerDziennika from #kh_rozrachunki R '
   + 'join CDN.KsiRozrachunki RR on (R.KRo_DeEId = RR.KRo_DeEId) '
   + 'join CDN.KsiRozrachunki child on (RR.KRo_KRoId = child.KRo_RozliczenieId) '
   +   'where R.ParentId Is Null' + @where
 Execute dbo.sp_executesql @sql
 Set @sql = 'insert into #kh_rozrachunki ( '
   + 'ParentId, '
   + 'TreeLevel, '
   + 'KRo_KRoId,  '
   + 'KRo_Typ,  '
   + 'KRo_Dokument, '
   + 'KRo_DataDokumentu, '
   + 'KRo_DataOperacji, '
   + 'KRo_TerminPlatnosci, '
   + 'KRo_DataRozliczenia, '
   + 'KRo_KwotaDok, '
   + 'KRo_Kwota, '
   + 'KRo_SumRozliczen, '
   + 'KRo_DeEId, '
   + 'KRo_Bufor, '
   + 'KRo_Storno, '
   + 'KRo_BOEId, '
   + 'KRo_RozliczenieId, '
   + 'KRo_Strona, '
   + 'KRo_KwotaDokWal, '
   + 'KRo_KwotaWal, '
   + 'KRo_SumRozliczenWal, '
   + 'KRo_Waluta, '
   + 'KRo_DataRoz, '
   + 'KRo_IdentKsieg, '
   + 'KRo_Konto, '
   + 'KRo_KontoIdx, '
   + 'KRo_KontoPrzeciw, '
   + 'KRo_NrDziennika, '
   + 'KRo_NrKsiegi, '
   + 'KRo_Opis, '
   + 'KRo_OObId, '
   + 'KRo_Dziennik, '
   + 'KRo_NumerDziennika ) '
   + 'select R.Id, '
   + '2, '
   + 'child.KRo_KRoId,  '
   + 'child.KRo_Typ,  '
   + 'child.KRo_Dokument, '
   + 'child.KRo_DataDokumentu, '
   + 'child.KRo_DataOperacji, '
   + 'child.KRo_TerminPlatnosci, '
   + 'child.KRo_DataRozliczenia, '
   + 'child.KRo_KwotaDok, '
   + 'child.KRo_Kwota, '
   + 'child.KRo_SumRozliczen, '
   + 'child.KRo_DeEId, '
   + 'child.KRo_Bufor, '
   + 'child.KRo_Storno, '
   + 'child.KRo_BOEId, '
   + 'child.KRo_RozliczenieId, '
   + 'child.KRo_Strona, '
   + 'child.KRo_KwotaDokWal, '
   + 'child.KRo_KwotaWal, '
   + 'child.KRo_SumRozliczenWal, '
   + 'child.KRo_Waluta, '
   + 'child.KRo_DataRoz, '
   + 'child.KRo_IdentKsieg, '
   + 'child.KRo_Konto, '
   + 'child.KRo_KontoIdx, '
   + 'child.KRo_KontoPrzeciw, '
   + 'child.KRo_NrDziennika, '
   + 'child.KRo_NrKsiegi, '
   + 'child.KRo_Opis, '
   + 'child.KRo_OObId, '
   + 'child.KRo_Dziennik, '
   + 'child.KRo_NumerDziennika from #kh_rozrachunki R '
   + 'join CDN.KsiRozrachunki RR on (R.KRo_BoEId = RR.KRo_BoEId) '
   + 'join CDN.KsiRozrachunki child on (RR.KRo_KRoId = child.KRo_RozliczenieId) '
   +   'where R.ParentId Is Null' + @where
 Execute dbo.sp_executesql @sql
 if @RozneKonta <> 0
 begin
  Set @sql = 'delete from #kh_rozrachunki where Id In (Select A.Id from #kh_rozrachunki as A join #kh_rozrachunki as B on (A.ParentId = B.Id) where A.KRo_KontoIdx = B.KRo_KontoIdx)'
  Execute dbo.sp_executesql @sql
  Set @sql = 'delete from #kh_rozrachunki where Id Not In  ( Select A.Id from #kh_rozrachunki as A join #kh_rozrachunki as B on (A.Id = B.ParentId)'
               + ' union all '
               + ' Select A.Id from #kh_rozrachunki as A join #kh_rozrachunki as B on (A.ParentId = B.Id) '
               + ')'
  --Set @sql = 'delete from #kh_rozrachunki where Id Not In (Select A.Id from #kh_rozrachunki as B where A.Id = #kh_rozrachunki.Id)'
  Execute dbo.sp_executesql @sql
 end
 Set @sql = 'update #kh_rozrachunki '
   + 'set '
   + 'CiaglaNumeracjaDC = OOb_CiaglaNumeracjaDC, '
   + 'KwotaRozliczenia = '  + @KwotaRozliczeniaField + ','
   + 'KwotaDokumentu = '   + @kwotaDokumentuField + ','
   + 'SumaRozliczen = '   + @SumaRozliczen + ','
   + 'RozliczonoWn = '   + @RozliczonoWn + ','
   + 'RozliczonoMa = '   + @RozliczonoMa + ','
   + 'NumerKsiegi = '   + @NumerKsiegi + ','
   + 'NrDziennika = '   + @NrDziennika + ','
   + 'NrDziennikaCzastkowego = ' + @NrDziennikaCzastkowego + ' '
   + 'from #kh_rozrachunki left outer join CDN.OkresyObrach on (KRo_OObID = OOb_OObId)'
 Execute dbo.sp_executesql @sql
 Set @sql = 'update #kh_rozrachunki set Report_Order = IsNull(ParentId, Id)'
 Execute dbo.sp_executesql @sql
 select * from #kh_rozrachunki order by Report_Order, Id
 drop table #kh_rozrachunki
 SET NOCOUNT ON
