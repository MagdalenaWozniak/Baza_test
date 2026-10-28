create procedure cdn.DodajDokumentDoTeczkiPracownika @praId int, @eteId int, @opeId int, @nazwa nvarchar(256), @nazwapliku nvarchar(256), @path nvarchar(256), @podpisany tinyint, @out int output, @target smallint output, @targetpath nvarchar(512) output
as
begin
 declare @dkmId int
 if (select count(DKM_DkmId) from cdn.DaneKadMod where DKM_Nazwa = @nazwa and DKM_Rodzaj = 11) = 0
 begin
  insert into cdn.DaneKadMod (DKM_Nazwa, DKM_Rodzaj, DKM_Robotnicze, DKM_Opis) values (@nazwa, 11, 0, '')
  set @dkmId =  (select scope_identity())
 end
 else
 begin
  select @dkmId = DKM_DkmId from cdn.DaneKadMod where DKM_Nazwa = @nazwa and DKM_Rodzaj = 11
 end
 --definicja dokumentu
 declare @ddfId int, @schemat nvarchar(50), @klasa int, @maxnr int, @nrstr nvarchar(31), @nrpel nvarchar(30)
 declare @DefaultDefDok int, @symbol nvarchar(5), @rejestr nvarchar(20), @set_rejestr tinyint
 select @DefaultDefDok = Fir_Wartosc from CDN.Firma where Fir_Numer = 2970
 set @set_rejestr = 0
 set @klasa = 410
 if @DefaultDefDok > 0
 begin
  set @ddfId = @DefaultDefDok
  select @schemat = DDF_Numeracja, @symbol = DDf_Symbol from cdn.DokDefinicje where DDF_Klasa = @klasa and DDf_DDfID = @DefaultDefDok
  if exists(select DDf_DDfID from cdn.DokDefinicje where DDF_Klasa = @klasa and DDf_DDfID = @DefaultDefDok and DDF_Numeracja like '%@rejestr%')
  begin
   select @rejestr = Fir_Wartosc from CDN.Firma where Fir_Numer = 2971
   if len(@rejestr) > 0
    set @set_rejestr = 1
  end
 end
 else
  select @ddfId = DDF_DdfId, @schemat = DDF_Numeracja, @symbol = DDf_Symbol from cdn.DokDefinicje where DDF_Klasa = @klasa and DDF_Symbol = 'EDOK'
 declare @datadok date
 set @datadok = getdate()
 if @set_rejestr > 0
  set @nrstr = CDN.NumerString(909410, 1/*@OpeId*/, 1, 1, convert(datetime, @datadok, 120), '', @symbol, @rejestr, @schemat)
 else
  set @nrstr = CDN.NumerString(909410, 1/*@OpeId*/, 1, 1, convert(datetime, @datadok, 120), '', @symbol, default, @schemat)
 select @maxnr = max(PRT_NumerNr) from cdn.PracTeczki where PRT_NumerString = @nrstr and PRT_NumerNr >= 0
 set @maxnr = isnull(@maxnr, 0) + 1
 declare @opeKod nvarchar(20), @opeNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @opeId, @opeKod out, @opeNazwisko out
 declare @parent int, @rodzajlokalizacji int
 declare @sql nvarchar(512), @param nvarchar(30)
 declare @CfgDataBase nvarchar(128), @CfgServer nvarchar(128)
 select @CfgDataBase = sys_wartosc from cdn.systemcdn where sys_id = 1002
    select @CfgServer = sys_wartosc from cdn.systemcdn where sys_id = 1001
 declare @etenazwa nvarchar(64)
 if @eteId > 0
 begin
  set @sql = 'select @etenazwa0 = ETE_Nazwa from ['+@CfgServer+'].['+@CfgDataBase+'].cdn.ETeczki where ETE_EteId = @eteid0'
  exec sp_executesql @sql, N' @eteid0 int, @etenazwa0 nvarchar(64) output', @eteid0 = @eteId, @etenazwa0 = @etenazwa output
 end
 else
  set @etenazwa = ''
 declare @tytul nvarchar(128)
 if @dkmId > 0
  select @tytul = DKM_Nazwa from cdn.DaneKadMod where DKM_DkmId = @dkmId and DKM_Rodzaj = 11
 else
  set @tytul = ''
 set @sql = 'select @parent = CFK_CfkId from ['+@CfgServer+'].['+@CfgDataBase+'].cdn.CfgKlucze where CFK_Nazwa = @param'
 exec sp_executesql @sql, N' @param nvarchar(30), @parent int output', @param = 'eTeczka', @parent = @parent output
 set @sql = 'select @rodzajlokalizacji = isnull(CFW_Wartosc, 0) from ['+@CfgServer+'].['+@CfgDataBase+'].cdn.CfgKlucze join ['+@CfgServer+'].['+@CfgDataBase+'].cdn.CfgWartosci on CFK_CfkId = CFW_CfkId where CFK_Nazwa = @param and CFK_ParentId = @parent'
 exec sp_executesql @sql, N' @param nvarchar(30), @parent int, @rodzajlokalizacji int output', @param = 'Parametry zapisu', @parent = @parent, @rodzajlokalizacji = @rodzajlokalizacji output
 declare @file nvarchar(512)
 set @file = ''
 if @rodzajlokalizacji = 2
 begin
  set @sql = 'select @file = CFW_Wartosc from ['+@CfgServer+'].['+@CfgDataBase+'].cdn.CfgKlucze join ['+@CfgServer+'].['+@CfgDataBase+'].cdn.CfgWartosci on CFK_CfkId = CFW_CfkId where CFK_Nazwa = @param and CFK_ParentId = @parent'
  exec sp_executesql @sql, N' @param nvarchar(30), @parent int, @file nvarchar(512) output', @param = 'Parametry zapisu - IBARD', @parent = @parent, @file = @file output
  if @file = '' or @file is null
  begin
   --declare @s1 nvarchar(128)
   --set @s1 = 'Nie podano ścieżki zapisu dokumentu do e-teczki w konfiguracji (przechowywanie plików w IBARD).'--ERR_SQL_Place_NiePodanoSciezkiIBARD 32478
   RAISERROR('##OPT32478##', 16, 1)--raiserror(@s1, 16, 1)
   return
  end
  set @file = @file + '/'
 end
 else if @rodzajlokalizacji = 1
 begin
  set @sql = 'select @file = CFW_Wartosc from ['+@CfgServer+'].['+@CfgDataBase+'].cdn.CfgKlucze join ['+@CfgServer+'].['+@CfgDataBase+'].cdn.CfgWartosci on CFK_CfkId = CFW_CfkId where CFK_Nazwa = @param and CFK_ParentId = @parent'
  exec sp_executesql @sql, N' @param nvarchar(30), @parent int, @file nvarchar(512) output', @param = 'Parametry zapisu - dysk', @parent = @parent, @file = @file output
  if @file = '' or @file is null
  begin
   --declare @s2 nvarchar(128)
   --set @s2 = 'Nie podano ścieżki zapisu dokumentu do e-teczki w konfiguracji (przechowywanie plików na dysku lokalnym).'--ERR_SQL_Place_NiePodanoSciezkiDysk
   RAISERROR('##OPT32479##', 16, 1)--raiserror(@s2, 16, 1)
   return
  end
  set @file = @file + '\'
 end
 insert into cdn.PracTeczki
  (
   [PRT_PraId],
   [PRT_DdfId],
   [PRT_EteId],
   [PRT_DkmId],
   [PRT_EteNazwa],
   [PRT_NumerString],
   [PRT_NumerNr],
   [PRT_DataDok],
   [PRT_Tytul],
   [PRT_TytulId],
   [PRT_Opis],
   [PRT_NumerObcy],
   [PRT_DabId],
   [PRT_OpeZalId],
   [PRT_StaZalId],
   [PRT_TS_Zal],
   [PRT_OpeModId],
   [PRT_StaModId],
   [PRT_TS_Mod],
   [PRT_OpeModKod],
   [PRT_OpeModNazwisko],
   [PRT_OpeZalKod],
   [PRT_OpeZalNazwisko]
  )
  values
  (
   @praId,
   @ddfId,
   @eteId,
   @dkmId,
   @etenazwa,
   @nrstr,
   @maxnr,
   @datadok,
   @tytul,
   @dkmId,
   '',
   '',
   null,
   @opeId,
   null,
   getdate(),
   @opeId,
   null,
   getdate(),
   @opeKod,
   @opeNazwisko,
   @opeKod,
   @opeNazwisko
  )
  declare @prtId int
  set @prtId = (select scope_identity())
  declare @db_name nvarchar(128)
  select @db_name = SYS_Wartosc from cdn.SystemCDN where SYS_Id = 1
  set @file = @file + @db_name
  if @rodzajlokalizacji = 2
   set @file = @file + '/'
  else
   set @file = @file + '\'
  declare @preId int, @f_pesel nvarchar(32), @f_nip nvarchar(32), @f_paszport nvarchar(32), @f_nipzagr nvarchar(32), @f_nrwaktach nvarchar(64), @f_kod nvarchar(32)
  select top 1 @f_pesel = isnull(PRE_Pesel, ''), @f_nip = isnull(PRE_NipE, ''), @f_paszport = isnull(PRE_Paszport, ''), @f_nipzagr = isnull(PRE_PODNipZagraniczny, ''), @f_nrwaktach = isnull(PRE_NrwAktach, ''), @f_kod = isnull(PRE_Kod, '') from cdn.PracEtaty where PRE_PraId = @praId and PRE_DataOd < getdate() and PRE_DataDo > getdate()
  if @f_pesel <> ''
   set @file = @file + @f_pesel
  else if @f_nip <> ''
  begin
   if @f_nip <> '9999999999'
    set @file = @file + @f_nip
  end
  else if @f_paszport <> ''
   set @file = @file + @f_paszport
  else if @f_nipzagr <> ''
   set @file = @file + @f_nipzagr
  else if @f_nrwaktach <> ''
   set @file = @file + @f_nrwaktach
  else
   set @file = @file + @f_kod
  if @rodzajlokalizacji is null
   set @rodzajlokalizacji = 0
  declare @filefull nvarchar(512)
  set @filefull = @file + '\' + @nazwapliku
  if @rodzajlokalizacji = 2
   set @filefull = @file + '/' + @nazwapliku
  set @target = @rodzajlokalizacji
  if @filefull is null
   set @filefull = ''
  if @rodzajlokalizacji = 0
   set @filefull = ''
  set @targetpath = @filefull
  declare @filemode int
  if @rodzajlokalizacji = 0
   set @filemode = 2
  if @rodzajlokalizacji = 1
   set @filemode = 21
  if @rodzajlokalizacji = 2
   set @filemode = 6
  declare @wbazie int
  if @filemode = 6
   set @wbazie = 2
  else
  begin
   if @rodzajlokalizacji = 1
    set @wbazie = 0
   else
    set @wbazie = 1
  end
  insert into cdn.PracTeczkiDokumenty
   (
    [PTD_PrtId],
    [PTD_Nazwa],
    [PTD_RodzajLokalizacji],
    [PTD_Sciezka],
    [PTD_DabId],
    [PTD_Podpis],
    [PTD_FileMode],
    [PTD_NazwaPliku],
    [PTD_Wersja],
    [PTD_Archiwalny],
    [PTD_WBazie],
    [PTD_StaEditId],
    [PTD_OpeEditId],
    [PTD_OpeZalID],
    [PTD_StaZalId],
    [PTD_TS_Zal],
    [PTD_OpeModID],
    [PTD_StaModId],
    [PTD_TS_Mod],
    [PTD_OpeModKod],
    [PTD_OpeModNazwisko],
    [PTD_OpeZalKod],
    [PTD_OpeZalNazwisko]
   )
   values
   (
    @prtId,
    @nazwa,
    @rodzajlokalizacji,
    @filefull,
    null,
    @podpisany,
    @filemode,
    @nazwapliku,
    1,
    0,
    @wbazie,
    null,
    @opeid,
    @opeid,
    null,
    getdate(),
    @opeid,
    null,
    getdate(),
    @opeKod,
    @opeNazwisko,
    @opeKod,
    @opeNazwisko
   )
 set @out =  (select scope_identity())
end
