create Procedure [CDN].[SynchronizujCentraPracownikaWXL] @PreId int
as
begin
set nocount on
declare @WspolpracaZXl bit
set @WspolpracaZXl = (select CFW_Wartosc from cdn.CfgWartosci join cdn.CfgKlucze on CFK_CfkId = CFW_CfkId where CFK_Nazwa like 'Wsp%praca z XL')
if @WspolpracaZXl = 1
begin try
declare @SerwerBazyXL nvarchar(4000)
declare @BazaDanychXL nvarchar(4000)
set @SerwerBazyXL = (select CFW_Wartosc from cdn.CfgWartosci join cdn.CfgKlucze on CFK_CfkId = CFW_CfkId where CFK_Nazwa = 'Serwer bazy XL')
set @BazaDanychXL = (select CFW_Wartosc from cdn.CfgWartosci join cdn.CfgKlucze on CFK_CfkId = CFW_CfkId where CFK_Nazwa = 'Baza danych XL')
IF ISNULL(@SerwerBazyXL, '') LIKE ''
               OR ISNULL(@BazaDanychXL, '') LIKE ''
                BEGIN
                    RAISERROR ('##OPT32410##', 16, 1);
                    RETURN;
                END
            ELSE
begin
 declare @SqlCommandStart nvarchar(max)
 declare @lGenGIDFirma int
 declare @SqlCommand nvarchar(max)
 declare @Params nvarchar(max)
 declare @tab as Table (col varchar(max))
 declare @val nvarchar(max)
 -- GID FIRMA --
 set @SqlCommandStart = N'exec ['+@SerwerBazyXL+ N'].['+@BazaDanychXL+ N'].CDN.'
 set @SqlCommand = @SqlCommandStart + N'PobierzKonfiguracjeXl'
 insert into @tab EXECUTE sp_executesql @SqlCommand
 set @val = (select col from @tab)
 set @lGenGIDFirma = (select sum(case when id = 2  then val * 65536  else (case when id = 3  then val * 256  else (case when id = 4  then val else 0  end) end) end) from CDN.Split(@val,'.'))
  declare @spr as Table (ilosc int)
 set @SqlCommand  = N'select count(*) from ['+@SerwerBazyXL+ N'].['+@BazaDanychXL+ N'].sys.procedures where name = ''ZnajdzDzialStrPodleglosciowej'' and type = ''P'''
 insert into @spr execute sp_executesql @SqlCommand
 if not exists (select * from @spr where ilosc = 1)
  return
 declare @prac int
 set @prac = (select PRE_PraId from cdn.pracetaty where PRE_PreId = @PreId)
 DECLARE Elementy CURSOR LOCAL FAST_FORWARD
      FOR select pre_preid from cdn.PracEtaty where PRE_PraId = @prac order by PRE_DataOd asc
     OPEN Elementy
     while 1 = 1
     begin
      FETCH NEXT FROM Elementy INTO @PreId
      IF @@fetch_status <> 0
        BREAK
 declare @PRCGID_Typ int
 declare @PRCGID_Numer int
 declare @PRCGID_Firma  int
 declare @PRCGID_Lp  int
 declare @Prc_Imie1     nvarchar(400)
 declare @Prc_Imie2     nvarchar(400)
 declare @Prc_Nazwisko  nvarchar(400)
 declare @OkresOd  datetime
 declare @dtMin   datetime
 declare @dtMax   datetime
 declare @CntId   int
 declare @sKod nvarchar(400)
 declare @PraId int
 declare @Imie nvarchar(400)
 declare @Nazwisko nvarchar(400)
 declare @ImieINazwisko nvarchar(400)
 set @dtMin = (select convert(datetime,'1900-01-01',120))
 set @dtMax = (select convert(datetime,'2999-12-30',120))
 select @sKod = Pre_Kod, @PraId = Pre_PraId, @OkresOd = Pre_DataOd, @Imie = PRE_Imie1, @Nazwisko = PRE_Nazwisko, @CntId = PRE_CntId from cdn.pracetaty where pre_preid = @PreId
 set @ImieINazwisko = @Imie + ' ' + @Nazwisko
 declare @tab2 as Table (prc_optimaid int, prc_gidtyp int, prc_gidnumer int, prc_gidfirma int, prc_gidlp int, Prc_Imie1 nvarchar(400),
 Prc_Imie2 nvarchar(400), Prc_Nazwisko nvarchar(400))
 delete @tab2
 set @SqlCommand  = @SqlCommandStart + N'ZnajdzPracownikaPoID2 @1, @2'
 set @Params   = N'@1 int, @2 nvarchar(400)'
 insert into @tab2 execute sp_executesql @SqlCommand, @Params, @PraId, @sKod
 select @PRCGID_Typ  = prc_gidtyp,
  @PRCGID_Numer = prc_gidnumer,
  @PRCGID_Firma = prc_gidfirma,
  @PRCGID_Lp  = prc_gidlp,
  @Prc_Imie1  = Prc_Imie1,
  @Prc_Imie2  = Prc_Imie2,
  @Prc_Nazwisko = Prc_Nazwisko from @tab2
declare @FRSGRO_Typ  int
declare @FRSGRO_Numer int
declare @FRSGRO_Firma int
declare @FRSGRO_Lp  int
set @FRSGRO_Typ  = -4272
set @FRSGRO_Numer = 3
set @FRSGRO_Firma = @lGenGIDFirma
set @FRSGRO_Lp  = 0
declare @tab4 as Table (typ int, numer int, firma int, lp int, id int, nazwa nvarchar(400),opis nvarchar(400), strtyp smallint)
delete @tab4
 set @SqlCommand  = @SqlCommandStart + N'ZnajdzDzialStrPodleglosciowej @1, @2, @3, @4,@5,@6'
 set @Params   = N'@1 int, @2 int, @3 int, @4 int, @5 int, @6 nvarchar(400)'
 insert into @tab4 execute sp_executesql @SqlCommand, @Params, @CntId, 0,0, 0, 0, ''
 if (exists (select * from @tab4))
 begin
 select @FRSGRO_Typ = typ, @FRSGRO_Numer = numer, @FRSGRO_Firma = firma, @FRSGRO_Lp = lp from @tab4
 end
 declare @tab3 as Table (znaleziono int)
 delete @tab3
 set @SqlCommand  = @SqlCommandStart + N'ZnajdzPrcStrPodleglosciowej @1, @2, @3, @4'
 set @Params   = N'@1 int, @2 int, @3 int, @4 int'
 insert into @tab3 execute sp_executesql @SqlCommand, @Params, @PRCGID_Typ, @PRCGID_Numer,@PRCGID_Firma,@PRCGID_Lp
 if exists (select * from @tab3 where znaleziono = 1)
 begin
 if @OkresOd = @dtMin
 begin
   set @SqlCommand  = @SqlCommandStart + N'AktualizujPRCStrPodl @1, @2, @3, @4,@5,@6,@7, @8,@9,@10,@11'
    set @Params   = N'@1 nvarchar(400), @2 nvarchar(400), @3 int, @4 int, @5 int, @6 int,@7 int, @8 nvarchar(400), @9 int, @10 int, @11 nvarchar(40)'
    execute sp_executesql @SqlCommand, @Params, @sKod, @ImieINazwisko,@FRSGRO_Typ,@FRSGRO_Numer,@FRSGRO_Firma,@FRSGRO_Lp,@PRCGID_Typ,@PRCGID_Numer,
    @PRCGID_Firma, @PRCGID_Lp, ''
  end
  else
  begin
  set @SqlCommand  = @SqlCommandStart + N'AktualizujCentraPracownika @0,@1, @2'
  set @Params   = N'@0 Int,@1 int, @2 datetime'
  execute sp_executesql @SqlCommand, @Params,@CntId, @PraId,@OkresOd
  end
end
else
begin
declare @tab5 as Table (frsId int, frsGidNumer int)
 delete @tab5
 set @SqlCommand  = @SqlCommandStart + N'PobierzMaxFrs'
 insert into @tab5 execute sp_executesql @SqlCommand
 declare @FRSGID_Id int
 set @FRSGID_Id = (select frsId from @tab5)
 set @FRSGID_Id  = @FRSGID_Id + 1
 set @SqlCommand  = @SqlCommandStart + N'DodajDzialStrPodl @0,@1, @2, @3, @4,@5,@6,@7, @8,@9,@10,@11,@12,@13'
  set @Params   = N'@0 Int,@1 int, @2 int, @3 int, @4 int, @5 varchar(400), @6 varchar(400),@7 int, @8 int, @9 int, @10 int,@11 int, @12 varchar(400), @13 tinyint'
  execute sp_executesql @SqlCommand, @Params,@FRSGID_Id,@PRCGID_Typ,@PRCGID_Numer,@PRCGID_Firma,@PRCGID_Lp,@sKod,@ImieINazwisko,@FRSGRO_Typ,@FRSGRO_Numer,@FRSGRO_Lp,
         @CntId,-1,'',0
end
end
CLOSE Elementy
 DEALLOCATE Elementy
end
 end try
 begin catch
  RAISERROR ('##OPT32410##',16,1);
  return;
 end catch
 set nocount off
end
