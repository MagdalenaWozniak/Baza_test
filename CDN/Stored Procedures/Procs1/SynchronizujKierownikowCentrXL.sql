Create Procedure CDN.SynchronizujKierownikowCentrXL @CnkId int, @Operacja bit
-- @Operacja - 0 (insert,update), 1 - delete
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
 if @Operacja = 0
 begin
 declare @PrcId int
 declare @CntId int
 declare @DataOd datetime
 declare @DataDo datetime
 declare @RolId int
 declare @NieZnaleziono int
 declare @Kierownik int
 set @NieZnaleziono = 0
 declare @spr as Table (ilosc int)
 set @SqlCommand  = N'select count(*) from ['+@SerwerBazyXL+ N'].['+@BazaDanychXL+ N'].sys.procedures where name = ''ZnajdzDzialStrPodleglosciowej'' and type = ''P'''
 insert into @spr execute sp_executesql @SqlCommand
 if not exists (select * from @spr where ilosc = 1)
  return
 select @PrcId = CNK_PraId, @CntId = CNK_CntId, @DataOd = CNK_OkresOd, @DataDo = CNK_OkresDo, @RolId = CNK_Rodzaj from cdn.CentraKierownicy where CNK_CnkId = @CnkId
 set @Kierownik = case when @RolId = 1 then 0 else 1 end;
 declare @tab2 as Table (
     PrR_Id int,
     PrR_PrcTyp smallint,
           PrR_PrcFirma int,
           PrR_PrcNumer int,
           PrR_PrcLp smallint,
           PrR_FrSId int,
           PrR_RolId int,
           PrR_DataOd int,
           PrR_DataDo int,
           PrR_OptimaID int,
     Rol_Id int,
     Rol_Nazwa nvarchar(400),
     Rol_Opis nvarchar(400),
     Rol_OptimaKierownik int)
 delete @tab2
  set @SqlCommand  = @SqlCommandStart + N'UsunPrcRole @0'
  set @Params   = N'@0 Int'
  execute sp_executesql @SqlCommand, @Params, @CnkId
  set @SqlCommand  = @SqlCommandStart + N'DodajPrcRole @1, @2, @3, @4,@5,@6'
  set @Params   = N'@1 int, @2 int, @3 int, @4 datetime, @5 datetime,@6 int'
  execute sp_executesql @SqlCommand, @Params, @PrcId, @CntId,@RolId,@DataOd,@DataDo,@CnkId
 end
 else
 begin
  set @SqlCommand  = @SqlCommandStart + N'UsunPrcRole @0'
  set @Params   = N'@0 Int'
  execute sp_executesql @SqlCommand, @Params, @CnkId
 end
 end
 end try
 begin catch
  RAISERROR ('##OPT32411##',16,1);
  return;
 end catch
 set nocount off
end
--go
