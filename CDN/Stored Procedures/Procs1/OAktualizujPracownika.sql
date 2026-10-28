create procedure cdn.OAktualizujPracownika
 @OptimaID INT,
 @OptimaKod nvarchar(20),
 @OptimaImie1 nvarchar(30),
 @OptimaImie2 nvarchar(30),
 @OptimaNazwisko nvarchar(40),
 @OptimaMLDMiasto nvarchar(40),
 @OptimaMLDPoczta nvarchar(40),
 @OptimaMLDKodPocztowy nvarchar(10),
 @OptimaMLDUlica nvarchar(40),
 @OptimaMLDNrDomu nvarchar(10),
 @OptimaMLDNrLokalu nvarchar(10),
 @OptimaHDKTelefon1 nvarchar(20),
 @OptimaNipE nvarchar(13),
 @OptimaPesel nvarchar(11),
 @OptimaHDKTelefon2 nvarchar(20),
 @OptimaHDKEmail nvarchar(127),
 @lOptimaIDWydzialu INT,
 @OptimaArchiwalny int = null
 as
 set nocount on
if exists (select * from sysobjects where name = 'Synch2015 ' And xtype = 'p')
 begin
 declare @set int
 exec cdn.Synch2015 @pWynik = @set OUTPUT
 if @set = 1
  return
 end
else
 return
  declare @Throw nvarchar(256)
  set @Throw = ''
  declare @s nvarchar(128)
  declare @PraId int
  declare @adresDzial nvarchar(400)
  set @adresDzial = (select DZL_AdresWezla from cdn.Dzialy where DZL_DzlId = @lOptimaIDWydzialu)
  set @PraId = @OptimaID
  if NOT exists (select PRA_praID from cdn.PracKod
   where PRA_praID = @OptimaID)
  begin
   set @Throw = '##OPT32384##'
   raiserror(@Throw, 16, 1)
   return
  end
  if @PraId > 0
   begin try
   if @OptimaMLDMiasto is NULL
    set @OptimaMLDMiasto = (select PRE_MLDMiasto from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
   if @OptimaMLDPoczta is NULL
    set @OptimaMLDPoczta = (select PRE_MLDPoczta from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
   if @OptimaMLDKodPocztowy is NULL
    set @OptimaMLDKodPocztowy = (select PRE_MLDKodPocztowy from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
   if @OptimaMLDUlica is NULL
    set @OptimaMLDUlica = (select PRE_MLDUlica from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
   if @OptimaMLDNrDomu is NULL
    set @OptimaMLDNrDomu = (select PRE_MLDNrDomu from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
   if @OptimaMLDNrLokalu is NULL
    set @OptimaMLDNrLokalu = (select PRE_MLDNrLokalu from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
    if @OptimaHDKTelefon1 is NULL
    set @OptimaHDKTelefon1 = (select PRE_HDKTelefon1 from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
   if @OptimaNipE is NULL
    set @OptimaNipE = (select PRE_NipE from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
    if @OptimaPesel is NULL
    set @OptimaPesel = (select PRE_Pesel from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
   if @OptimaHDKTelefon2 is NULL
    set @OptimaHDKTelefon2 = (select PRE_HDKTelefon2 from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
 if @OptimaHDKEmail is NULL
    set @OptimaHDKEmail = (select PRE_HDKEmail from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
    declare @DataUrodzenia datetime
    if (len(@OptimaPesel) > 0) and (((select PRE_DataUr from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120)) is null) or ((select top 1 PRE_DataUr from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120)) = convert(datetime, '1899-12-30', 120)))
     set @DataUrodzenia = CDN.PobierzDateUrodzenia(@OptimaPesel)
    else
     set @DataUrodzenia = (select top 1 PRE_DataUr from cdn.PracEtaty where PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120))
 if @OptimaArchiwalny is not null
  update cdn.PracKod
   set PRA_Kod = @OptimaKod, PRA_Archiwalny = @OptimaArchiwalny
   where PRA_PraId = @PraId
 else
  update cdn.PracKod
   set PRA_Kod = @OptimaKod
   where PRA_PraId = @PraId
 declare @OpeId int
 set @OpeId = cdn.GetXLOperatorID()
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
    update cdn.PracEtaty
     set
      PRE_Kod = @OptimaKod,
      PRE_Nazwisko = @OptimaNazwisko,
      PRE_Imie1 = @OptimaImie1,
      PRE_Imie2 = @OptimaImie2,
      PRE_NipE = @OptimaNipE,
      PRE_Pesel = @OptimaPesel,
      PRE_MLDUlica = @OptimaMLDUlica,
      PRE_MLDNrDomu = @OptimaMLDNrDomu,
      PRE_MLDNrLokalu = @OptimaMLDNrLokalu,
      PRE_MLDMiasto = @OptimaMLDMiasto,
      PRE_MLDKodPocztowy = @OptimaMLDKodPocztowy,
      PRE_MLDPoczta = @OptimaMLDPoczta,
      PRE_HDKTelefon1  = @OptimaHDKTelefon1,
      PRE_HDKTelefon2 = @OptimaHDKTelefon2,
      PRE_HDKEmail = @OptimaHDKEmail,
      PRE_DataUr = @DataUrodzenia,
      Pre_DzlId = @lOptimaIDWydzialu,
      PRE_OpeModId = @OpeId,
   PRE_OpeModKod = @OpeModKod,
   PRE_OpeModNazwisko = @OpeModNazwisko,
   PRE_AdresDzialu = @adresDzial,
      PRE_TS_Mod = getdate()
     where
      PRE_PraId = @PraId and PRE_DataDo = convert(datetime, '2999-12-31', 120)
   --KO2014.2
   declare @arch int, @parentid int, @nadrzedny int
      select @arch = PRA_Archiwalny, @parentid = PRA_ParentId, @nadrzedny = PRA_Nadrzedny from cdn.PracKod where PRA_PraId = @PraId
      execute cdn.AktualizujPracIdx @PraId, @arch, @parentid, @nadrzedny
  --[logowanie]
 declare @obj_id int
 select @obj_id = PRE_PreId from CDN.PracEtaty where PRE_PRAId = @PraId
 declare @obj_name nvarchar(128)
 set @obj_name = '[' + @OptimaKod + '] ' + @OptimaImie1 + ' ' + @OptimaNazwisko
 declare @oid int
 set @oid = cdn.GetXLOperatorID()
 if @oid > 0
 begin
  exec CDN.RejestrOperacjiContextInfo @oid
  exec CDN.RejestrOperacjiDodaj 24000, 0, @obj_id, @obj_name, 2, ''
 end
   end try
   begin catch
    set @Throw = '##OPT32385##'
    raiserror(@Throw, 16, 1)
   end catch
  else
  begin
   set @Throw = '##OPT32386##'
   raiserror(@Throw, 16, 1)
  end
 set nocount off
