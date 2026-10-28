CREATE PROCEDURE CDN.BO_Init
@BONID       int,
@Bufor       int,
@ObslugaKontWalutowych   int,
@WalutaSystemowa    NVARCHAR(3),
@OpretatorID     int,
@CurrOObID      int
AS
 SET NOCOUNT ON
/*
 set @CurrOObID       = 2   -- function param
 set @BONID        = 5   -- function param
 set @Bufor        = 1   -- function param
 set @ObslugaKontWalutowych    = 1   -- function param
 set @WalutaSystemowa     = 'PLN' -- function param
 set @OpretatorID      = 1   -- function param
 set @CurrOObID       = 2   -- function param
*/
 declare @PrevOObID   int
 declare @PrevOObIDDateOd datetime
 declare @PrevOObIDDateDo datetime
 select @PrevOObID = cdn.OkresObrachunkowy(@CurrOObID, -1)
 if IsNull(@PrevOObID, 0) = 0
  exec CDN.RiseOptimaException 26107
 BEGIN TRANSACTION
 Alter Table CDN.BOElem Disable Trigger All;
 select @PrevOObIDDateOd = OOb_DataOtw,
   @PrevOObIDDateDo = OOb_DataKoncowa
 from CDN.OkresyObrach where OOb_OObID = @PrevOObID
 create table #tmp_PrevOS (  Tmp_AccId       INT,
        Tmp_NumerIdx    NVARCHAR(50),
        Tmp_BoWn        Numeric(15,2),
        Tmp_BoMa        Numeric(15,2),
        Tmp_ObrotyWn    Numeric(15,2),
        Tmp_ObrotyMa    Numeric(15,2),
        Tmp_ObrotyTotWn Numeric(15,2),
        Tmp_ObrotyTotMa Numeric(15,2),
        Tmp_SaldoWn     Numeric(15,2),
        Tmp_SaldoMa     Numeric(15,2),
        Tmp_PrstSaldaWn Numeric(15,2),
        Tmp_PrstSaldaMa Numeric(15,2),
        Tmp_Numer       NVARCHAR(50),
        Tmp_Nazwa       NVARCHAR(50),
        Tmp_Nazwa2      NVARCHAR(50),
        Tmp_Poziom      Int,
        Tmp_ParId       Int,
        Tmp_Analityka Int       )
 Insert #tmp_PrevOS exec CDN.ObrotySalda @PrevOObIDDateOd,@PrevOObIDDateDo,@Bufor,@PrevOObID,0,0,@OpretatorID,default,default,0,default,0
 Declare PrevObrotySalda Cursor Local Fast_Forward For
 SELECT
  PrevKonta.Acc_AccID,
  PrevKonta.Acc_NextAccID,
        CurrKonta.Acc_Analityka,
  IsNull(PrevKonta.Acc_Waluta, ''),
  IsNull(CurrKonta.Acc_Waluta, ''),
  #tmp_PrevOS.Tmp_SaldoWn,
  #tmp_PrevOS.Tmp_SaldoMa
 FROM
  CDN.Konta PrevKonta
  join  #tmp_PrevOS           on (PrevKonta.Acc_AccID = Tmp_AccId)
  join CDN.Konta CurrKonta    on (PrevKonta.Acc_NextAccID =CurrKonta.Acc_AccID )
 WHERE
  PrevKonta.Acc_OObID=@PrevOObID
  AND PrevKonta.Acc_NieAktywne=0
  AND PrevKonta.Acc_Analityka=1
  AND PrevKonta.Acc_TypKonta in (1,2,3,6)
  AND PrevKonta.Acc_NextAccId IS NOT NULL
  AND (#tmp_PrevOS.Tmp_SaldoWn <> 0.00 or #tmp_PrevOS.Tmp_SaldoMa <> 0.00)
  AND CDN.ZakazDoKonta(PrevKonta.Acc_NextAccId,@OpretatorID) = 0
  AND CDN.ZakazDoKonta(PrevKonta.Acc_AccId,@OpretatorID) = 0
  ORDER BY PrevKonta.Acc_NumerIdx
 Open PrevObrotySalda
 While 1 = 1
 Begin
  declare @PrevAccID    int
  declare @CurrAccID    int
        declare @CurrAnalityka          int
  declare @PrevAccWaluta      NVARCHAR(3)
  declare @CurrAccWaluta      NVARCHAR(3)
  declare @SaldoWn    decimal(20,2)
  declare @SaldoMa    decimal(20,2)
  declare @SaldoWnWal    decimal(20,2)
  declare @SaldoMaWal    decimal(20,2)
  declare @ElementWalutowy int
  Fetch Next From PrevObrotySalda InTo @PrevAccID, @CurrAccID, @CurrAnalityka, @PrevAccWaluta, @CurrAccWaluta, @SaldoWn, @SaldoMa
  If @@Fetch_Status <> 0 Break
        if @CurrAnalityka = 0
            begin
                -- docelowo do cursora z rezultatem
                continue
            end
  if @PrevAccWaluta = ''
   set @PrevAccWaluta = @WalutaSystemowa
  if @CurrAccWaluta = ''
   set @CurrAccWaluta = @WalutaSystemowa
  if @ObslugaKontWalutowych = 0
   begin
    set @ElementWalutowy = 0
    set @SaldoWnWal   = 0.00
    set @SaldoMaWal   = 0.00
   end
  else
  if @CurrAccWaluta = @WalutaSystemowa
   begin
    set @ElementWalutowy = 0
    set @SaldoWnWal   = 0.00
    set @SaldoMaWal   = 0.00
   end
  else
   if @PrevAccWaluta = @WalutaSystemowa and @CurrAccWaluta <> @WalutaSystemowa
   begin
    set @ElementWalutowy = 1
    set @SaldoWnWal   = 0.00
    set @SaldoMaWal   = 0.00
   end
  else
   if @PrevAccWaluta <> @WalutaSystemowa and @PrevAccWaluta = @CurrAccWaluta
   begin
    set @ElementWalutowy = 1
    set @SaldoWnWal   = 0.00
    set @SaldoMaWal   = 0.00
    create table #tmp_PrevOSWal(Tmp_AccId       INT,
           Tmp_NumerIdx    NVARCHAR(50),
           Tmp_BoWn        Numeric(15,2),
           Tmp_BoMa        Numeric(15,2),
           Tmp_ObrotyWn    Numeric(15,2),
           Tmp_ObrotyMa    Numeric(15,2),
           Tmp_ObrotyTotWn Numeric(15,2),
           Tmp_ObrotyTotMa Numeric(15,2),
           Tmp_SaldoWn     Numeric(15,2),
           Tmp_SaldoMa     Numeric(15,2),
           Tmp_PrstSaldaWn Numeric(15,2),
           Tmp_PrstSaldaMa Numeric(15,2),
           Tmp_Numer       NVARCHAR(50),
           Tmp_Nazwa       NVARCHAR(50),
           Tmp_Nazwa2      NVARCHAR(50),
           Tmp_Poziom      Int,
           Tmp_ParId       Int,
           Tmp_Analityka Int       )
    Insert #tmp_PrevOSWal exec CDN.ObrotySalda @PrevOObIDDateOd,
                @PrevOObIDDateDo,
                @Bufor,@PrevOObID,
                @PrevAccID,
                0,
                @OpretatorID,
                default,
                default,
                0,
                @CurrAccWaluta,
                0
    select @SaldoWnWal = Tmp_SaldoWn,
      @SaldoMaWal = Tmp_SaldoMa
    from
    #tmp_PrevOSWal
    drop table #tmp_PrevOSWal
   end
  if @ElementWalutowy = 0
            begin
       set @CurrAccWaluta = ''
                set @SaldoWnWal = @SaldoWn
                set @SaldoMaWal = @SaldoMa
            end
            /*
        else
            begin
                set @SaldoWn = @SaldoWnWal
                set @SaldoMa = @SaldoMaWal
            end
            */
  exec CDN.BO_AddBoElem @BONID,
                                    @PrevOObIDDateDo,
         @CurrAccID,
         @PrevAccID,
         @SaldoWn,
         @SaldoMa,
         @SaldoWnWal,
         @SaldoMaWal,
         @CurrAccWaluta
 End
 Close PrevObrotySalda
 Deallocate PrevObrotySalda
 drop table #tmp_PrevOS
 Alter Table CDN.BOElem Enable Trigger All;
 if @@TranCount<>0 COMMIT
 exec CDN.BO_AktualizujStanyKont @CurrOObID
 SET NOCOUNT OFF
