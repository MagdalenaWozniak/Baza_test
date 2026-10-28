Create Procedure CDN.SynchronizujCentraXL @CntId int
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
 declare @czyGlowneCent bit
 declare @lDzialId  int
 declare @lDzialParentId int
 declare @FRSGRO_Typ  int
 declare @FRSGRO_Numer int
 declare @FRSGRO_Firma int
 declare @FRSGRO_Lp  int
 declare @FRSGID_Typ  int
 declare @FRSGID_Numer int
 declare @FRSGID_Firma int
 declare @FRSGID_Lp  int
 declare @FRSGID_Id  int
 declare @level   int
 declare @iParentId  int
 declare @sCurrWezel  nvarchar(1000)
 declare @sDzlKod  nvarchar(1000)
 declare @sDzlNazwa  nvarchar(1000)
 declare @sDzlKonto  nvarchar(1000)
 declare @sAdresWezla nvarchar(1000)
 declare @FRSNazwa  nvarchar(1000)
 declare @FRSOpis  nvarchar(1000)
 declare @Nieaktywny  int
 declare @lStrTyp  int
 set @czyGlowneCent = 0
 set @lDzialId  = 0
 set @FRSGRO_Typ  = -4272
 set @FRSGRO_Numer = 3
 set @FRSGID_Firma = @lGenGIDFirma
 set @FRSGRO_Lp  = 0
 set @level   = 2
 set @sAdresWezla = (select CNT_AdresWezla from cdn.Centra where CNT_CntId = @CntId)
 set @Nieaktywny  = (select CNT_Nieaktywny from cdn.Centra where CNT_CntId = @CntId)
 while 1 = 1
 begin
 declare @vals nvarchar(256)
 declare @it int
 set @it = 0
 set @sCurrWezel  = ''
 DECLARE Elementy CURSOR LOCAL FAST_FORWARD
      FOR select val from CDN.Split(@sAdresWezla,'.')
     OPEN Elementy
     WHILE @level > @it
     begin
      FETCH NEXT FROM Elementy INTO @vals
      IF @@fetch_status <> 0
        BREAK
      set @sCurrWezel = @sCurrWezel + @vals + '.'
      set @it = @it + 1
     end
 CLOSE Elementy
 DEALLOCATE Elementy
 set @sCurrWezel = SUBSTRING (@sCurrWezel,0, len(@sCurrWezel))
 select @sDzlKod = CNT_Kod, @sDzlNazwa = CNT_Nazwa, @lDzialId = CNT_CntId, @lDzialParentId = CNT_ParentId from cdn.Centra where CNT_AdresWezla = @sCurrWezel
 if ((@lDzialId = 3 and @sDzlKod = 'FIRMA') OR (@lDzialId = 1 and @sDzlKod = 'brak'))
  set @czyGlowneCent = 1
 declare @tab2 as Table (typ int, numer int, firma int, lp int, id int, nazwa nvarchar(400),opis nvarchar(400), strtyp smallint)
 delete @tab2
 set @SqlCommand  = @SqlCommandStart + N'ZnajdzDzialStrPodleglosciowej @1, @2, @3, @4,@5,@6'
 set @Params   = N'@1 int, @2 int, @3 int, @4 int, @5 int, @6 nvarchar(400)'
 insert into @tab2 execute sp_executesql @SqlCommand, @Params, @lDzialId, @FRSGRO_Typ,@FRSGRO_Numer, @FRSGRO_Lp, @FRSGRO_Firma, @sDzlKod
 if (exists (select * from @tab2)  and @czyGlowneCent = 0)
  begin
  select @FRSGRO_Typ = typ, @FRSGRO_Numer = numer, @FRSGRO_Firma = firma, @FRSGRO_Lp = lp, @FRSGID_Id = id, @FRSGID_Typ = typ, @FRSGID_Numer = numer,
  @FRSGID_Firma = firma, @FRSGID_Lp = lp, @FRSNazwa = nazwa, @FRSOpis = opis, @lStrTyp = strtyp from @tab2
  if @FRSNazwa = @sDzlKod
   begin
   set @SqlCommand  = @SqlCommandStart + N'AktualizujDzialStrPodl @0,@1, @2, @3, @4,@5,@6,@7, @8,@9,@10'
   set @Params   = N'@0 Int,@1 nvarchar(400), @2 nvarchar(400), @3 int, @4 int, @5 int, @6 int,@7 int, @8 nvarchar(400), @9 int, @10 int'
   execute sp_executesql @SqlCommand, @Params, @lDzialId, @sDzlKod,@sDzlNazwa, @FRSGID_Typ, @FRSGID_Numer, @FRSGID_Firma, @FRSGID_Lp, @lStrTyp,
   @sDzlKonto, @Nieaktywny,@lDzialParentId
   end
  if (@FRSNazwa <> @sDzlKod or @FRSOpis <> @sDzlNazwa)
   begin
   set @SqlCommand  = @SqlCommandStart + N'AktualizujDzialStrPodl @0, @1, @2, @3, @4,@5,@6,@7, @8,@9,@10'
   set @Params   = N'@0 Int,@1 nvarchar(400), @2 nvarchar(400), @3 int, @4 int, @5 int, @6 int,@7 int, @8 nvarchar(400), @9 int, @10 int'
   execute sp_executesql @SqlCommand, @Params, @lDzialId, @sDzlKod,@sDzlNazwa, @FRSGID_Typ, @FRSGID_Numer, @FRSGID_Firma, @FRSGID_Lp, @lStrTyp,
   @sDzlKonto, @Nieaktywny,@lDzialParentId
   end
  end
 else
  begin
  declare @tab3 as Table (col int , col2 int)
  delete @tab3
  set @SqlCommand  = @SqlCommandStart + N'PobierzMaxFrs'
  insert into @tab3 execute sp_executesql @SqlCommand
  set @FRSGID_Id  = (select col from @tab3)
  set @FRSGID_Id  = @FRSGID_Id + 1
  set @FRSGID_Typ  = -4272
  set @FRSGID_Numer = (select col2 from @tab3)
  set @FRSGID_Firma = @lGenGIDFirma
  set @FRSGID_Lp  = 0
  set @lStrTyp  = 1001
  set @sDzlKonto  = ''
   if (@lDzialId <> 3 and @lDzialId <> 1)
   begin
    set @SqlCommand  = @SqlCommandStart + N'DodajDzialStrPodl @1, @2, @3, @4,@5,@6,@7, @8,@9,@10,@11, @12,@13,@14'
    set @Params   = N'@1 int, @2 int, @3 int, @4 int, @5 int, @6 nvarchar(400),@7 nvarchar(400), @8 int , @9 int, @10 int,@11 int , @12 int, @13 nvarchar(400),@14 int'
    execute sp_executesql @SqlCommand, @Params, @FRSGID_Id, @FRSGID_Typ, @FRSGID_Numer, @FRSGID_Firma, @FRSGID_Lp, @sDzlKod, @sDzlNazwa, @FRSGRO_Typ, @FRSGRO_Numer,
           @FRSGRO_Lp,@lDzialId,@lStrTyp,@sDzlKonto, @Nieaktywny
    set @FRSGRO_Typ  = @FRSGID_Typ
    set @FRSGRO_Numer = @FRSGID_Numer
    set @FRSGRO_Firma = @FRSGID_Firma
    set @FRSGRO_Lp  = @FRSGRO_Lp
   end
  end
  if @sCurrWezel = @sAdresWezla
  begin
   break
  end
  set @level = @level + 1
  end
  end
 end try
 begin catch
  RAISERROR ('##OPT32410##',16,1);
  return;
 end catch
 set nocount off
end
