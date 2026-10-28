--/////////////////////////////////////////////////////////////////////////////////////////////////////
--procedura tworząca wypłatę stornującą dla wypłaty anulowanej
--procedura uruchamiana jest po naliczeniu wypłaty korygującej
create procedure CDN.WyplataStornujaca @AnulowanaId int, @Nr_KOREKTA int, @DDF_KOREKTA int, @NrStr_KOREKTA NVARCHAR(31), @LPL_KOREKTA int, @KorygujacaId int
as
 set nocount on
 declare @LocalError int, @LocalErrorDesc NVARCHAR(256)
 set @LocalError = 0
 begin tran T
 if not exists (select wpl_wplid from cdn.wyplaty where wpl_wplid = @AnulowanaId)
  begin
   set @LocalError = 101
   set @LocalErrorDesc = 'Nie odnaleziono wypłaty anulowanej.'--ERR_SQL_Place_WypStorn1 32450
   goto L_FINISH
  end
 --przepisanie wypłaty
 declare
  @PraId int   ,@LplId int   ,@DzlId int   ,@DdfId int   ,@Tryb int   ,@ParentId int ,
  @NumerString NVARCHAR ( 31)   ,@NumerNr int   ,@NumerPelny NVARCHAR ( 41)  ,@DataDok datetime   ,@Wartosc decimal (15,2)   ,
  @Miesiac tinyint   ,@Rok int   ,@DataOd datetime   ,@DataDo datetime   ,@Nazwa NVARCHAR ( 40)   ,@Zamknieta tinyint   ,
  @KatId int ,@KategoriaOpis NVARCHAR ( 50)   ,@KorektaPlatnosci tinyint   ,@KorektaPola int   ,@Brutto decimal (15,2)   ,
  @Korekta tinyint  ,@UmowaDodZas smallint,@OpeZalId int ,@StaZalId int ,@TS_Zal datetime ,@OpeModId int ,@StaModId int ,
  @TS_Mod datetime,
  @KorektaPola2 int, @ObnizSklPPK tinyint
 declare @OpeZalKod varchar(20), @OpeZalNazwisko nvarchar(50)
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 select
  @PraId = WPL_PraId,@LplId = WPL_LplId,@DzlId = WPL_DzlId ,@DdfId = WPL_DdfId ,@Tryb = 2 ,@ParentId = WPL_ParentId ,
  @NumerString = WPL_NumerString ,@NumerNr = WPL_NumerNr ,@NumerPelny = WPL_NumerPelny ,@DataDok = WPL_DataDok ,
  @Wartosc = WPL_Wartosc ,@Miesiac = WPL_Miesiac ,@Rok = WPL_Rok ,@DataOd = WPL_DataOd ,@DataDo = WPL_DataDo ,
  @Nazwa = WPL_Nazwa ,@Zamknieta = WPL_Zamknieta ,@KatId = WPL_KatId ,@KategoriaOpis = WPL_KategoriaOpis ,
  @KorektaPlatnosci = WPL_KorektaPlatnosci ,@KorektaPola = WPL_KorektaPola ,@Brutto = WPL_Brutto ,@Korekta = WPL_Korekta,
  @UmowaDodZas = WPL_UmowaDodZas,
  @OpeZalId = WPL_OpeZalId, @OpeZalKod = WPL_OpeZalKod, @OpeZalNazwisko = WPL_OpeZalNazwisko,
  @StaZalId = WPL_StaZalId ,@TS_Zal = WPL_TS_Zal ,@OpeModId = WPL_OpeModId, @OpeModKod = WPL_OpeModKod, @OpeModNazwisko = WPL_OpeModNazwisko ,@StaModId = WPL_StaModId ,
  @TS_Mod = WPL_TS_Mod ,
  @KorektaPola2 = WPL_KorektaPola2, @ObnizSklPPK = WPL_ObnizSklPPK
  from cdn.wyplaty
   where wpl_wplid = @AnulowanaId
 if @@ERROR <> 0
  begin
   set @LocalError = 11
   set @LocalErrorDesc = 'Nie odnaleziono wypłaty anulowanej.'--ERR_SQL_Place_WypStorn1 32450
   goto L_FINISH
  end
 insert into cdn.wyplaty
 (
  WPL_PraId,WPL_LplId,WPL_DzlId ,WPL_DdfId ,WPL_Tryb ,WPL_ParentId ,WPL_NumerString ,WPL_NumerNr ,WPL_DataDok ,WPL_Wartosc ,
  WPL_Miesiac ,WPL_Rok ,WPL_DataOd ,WPL_DataDo ,WPL_Nazwa ,WPL_Zamknieta ,WPL_KatId ,WPL_KategoriaOpis ,WPL_KorektaPlatnosci ,
  WPL_KorektaPola ,WPL_Brutto ,WPL_Korekta, WPL_UmowaDodZas, WPL_OpeZalId, WPL_OpeZalKod, WPL_OpeZalNazwisko, WPL_StaZalId ,WPL_TS_Zal ,WPL_OpeModId , WPL_OpeModKod, WPL_OpeModNazwisko, WPL_StaModId ,WPL_TS_Mod ,
  WPL_KorektaPola2, WPL_ObnizSklPPK
 )
 values
 (
  @PraId,@LPL_KOREKTA,@DzlId,@DDF_KOREKTA,@Tryb ,@AnulowanaId ,@NrStr_KOREKTA,@Nr_KOREKTA,@DataDok,- @Wartosc,@Miesiac,@Rok,
  @DataOd,@DataDo,@Nazwa ,@Zamknieta,@KatId ,@KategoriaOpis ,@KorektaPlatnosci ,@KorektaPola,- @Brutto ,
  @Korekta ,@UmowaDodZas, @OpeZalId, @OpeZalKod, @OpeZalNazwisko, @StaZalId,@TS_Zal ,@OpeModId, @OpeModKod, @OpeModNazwisko, @StaModId,@TS_Mod ,
  @KorektaPola2, @ObnizSklPPK
 )
 if @@ERROR <> 0
  begin
      set @LocalError = 12
   set @LocalErrorDesc = 'Błąd dodania wypłaty stornującej.' --ERR_SQL_Place_WypStorn2 32451
   goto L_FINISH
  end
 declare @StornujacaID int, @StornujacaNumerPelny NVARCHAR(41)
 select @StornujacaID = wpl_wplid, @StornujacaNumerPelny = wpl_numerpelny
  from cdn.wyplaty
   where wpl_ParentId = @AnulowanaId and wpl_Tryb = 2 and wpl_numernr = @Nr_KOREKTA and wpl_numerstring = @NrStr_KOREKTA
 if @StornujacaID is null
  begin
      set @LocalError = 102
   set @LocalErrorDesc = 'Błąd zapisu wypłaty stornującej.' --ERR_SQL_Place_WypStorn3 32452
   goto L_FINISH
  end
 --przepisanie elementów
 declare @ElementAnulowanyId int,
  @WplId int   ,@PraId_E int ,@TwpId int ,@Nazwa_E NVARCHAR ( 128)   ,@Wartosc_E decimal (15,2)   ,
  @Ulga decimal (15,2)   ,@Koszty decimal (15,2)   ,@ZalFis decimal (15,2)   ,@NalFis decimal (15,2)   ,
  @PodstEmer decimal (15,2)   ,@PodstRent decimal (15,2)   ,@PodstChor decimal (15,2)   ,@PodstWypad decimal (15,2) ,
  @PodstFP decimal (15,2)   ,@PodstFGSP decimal (15,2) ,@PodstZdrow decimal (15,2) ,@SklEmerPrac decimal (15,2)   ,
  @SklEmerFirma decimal (15,2)   ,@SklRentPrac decimal (15,2)   ,@SklRentFirma decimal (15,2)   ,
  @SklChorPrac decimal (15,2)   ,@SklChorFirma decimal (15,2) ,@SklWypadPrac decimal (15,2)   ,@SklWypadFirma decimal (15,2) ,
  @SklFP decimal (15,2)   ,@SklFGSP decimal (15,2)   ,@Korekta_E tinyint ,@Brutto50 decimal (15,2) ,@Koszty50 decimal (15,2) ,
  @NrZUS int ,@TyUb int   ,@SklZdrowPrac decimal (15,2)   ,@SklZdrowFirma decimal (15,2)   ,@SklZdrowSuma decimal (15,2)   ,
  @KatId_E int ,@KategoriaOpis_E NVARCHAR ( 50)   ,@Temp int   ,@PodstFEP decimal(15,2), @SklFEP decimal(15,2),@Przychod50 decimal (15,2),@OpeZalId_E int , @OpeZalKod_E varchar(20), @OpeZalNazwisko_E varchar(50),@StaZalId_E int ,
  @TS_Zal_E datetime   ,@OpeModId_E int , @OpeModKod_E varchar(20), @OpeModNazwisko_E varchar(50), @StaModId_E int , @TS_Mod_E datetime, @WartoscWal_E decimal(15,2), @Waluta_E  nvarchar(3), @Netto_E decimal(15,2),
  @NettoWal_E decimal(15,2),
  @PodstPPK decimal(15,2), @SklPPKPrac1 decimal(15,2), @SklPPKPrac2 decimal(15,2), @SklPPKFirma1 decimal(15,2), @SklPPKFirma2 decimal(15,2), @ZalFISZwol tinyint, @PodstPITZwol decimal(15,2)
 declare ELEMENTY cursor local fast_forward for
  select WPE_WpeId from cdn.wypelementy where wpe_wplid = @AnulowanaId
 declare @TAB_STORNUJACA_TEMP_WYPELEMENTY table
  (
   temp_WPEID int, temp_WplId int   ,temp_PraId_E int ,temp_TwpId int ,temp_Nazwa_E NVARCHAR ( 128)   ,temp_Wartosc_E decimal (15,2)   ,
   temp_Ulga decimal (15,2)   ,temp_Koszty decimal (15,2)   ,temp_ZalFis decimal (15,2)   ,temp_NalFis decimal (15,2)   ,
   temp_PodstEmer decimal (15,2)   ,temp_PodstRent decimal (15,2)   ,temp_PodstChor decimal (15,2)   ,temp_PodstWypad decimal (15,2) ,
   temp_PodstFP decimal (15,2)   ,temp_PodstFGSP decimal (15,2) ,temp_PodstZdrow decimal (15,2) ,temp_SklEmerPrac decimal (15,2)   ,
   temp_SklEmerFirma decimal (15,2)   ,temp_SklRentPrac decimal (15,2)   ,temp_SklRentFirma decimal (15,2)   ,
   temp_SklChorPrac decimal (15,2)   ,temp_SklChorFirma decimal (15,2) ,temp_SklWypadPrac decimal (15,2)   ,temp_SklWypadFirma decimal (15,2) ,
   temp_SklFP decimal (15,2)   ,temp_SklFGSP decimal (15,2)   ,temp_Korekta_E tinyint ,temp_Brutto50 decimal (15,2) ,temp_Koszty50 decimal (15,2) ,
   temp_NrZUS int ,temp_TyUb int   ,temp_SklZdrowPrac decimal (15,2)   ,temp_SklZdrowFirma decimal (15,2)   ,temp_SklZdrowSuma decimal (15,2)   ,
   temp_KatId_E int ,temp_KategoriaOpis_E NVARCHAR ( 50)   ,temp_Temp int   ,temp_PodstFEP decimal(15,2), temp_SklFEP decimal(15,2),temp_Przychod50 decimal (15,2) , temp_OpeZalId_E int , temp_OpeZalKod_E varchar(20), temp_OpeZalNazwisko_E varchar(50),temp_StaZalId_E int ,
   temp_TS_Zal_E datetime   ,temp_OpeModId_E int , temp_OpeModKod_E varchar(20), temp_OpeModNazwisko_E varchar(50), temp_StaModId_E int ,temp_TS_Mod_E datetime, temp_WartoscWal_E decimal(15,2), temp_Waluta  nvarchar(3), temp_Netto_E decimal(15,2), temp_NettoWal_E decimal(15,2),
    temp_PodstPPK decimal(15,2), temp_SklPPKPrac1 decimal(15,2), temp_SklPPKPrac2 decimal(15,2), temp_SklPPKFirma1 decimal(15,2), temp_SklPPKFirma2 decimal(15,2), temp_ZalFISZwol tinyint, temp_PodstPITZwol decimal(15,2)
  )
  insert into @TAB_STORNUJACA_TEMP_WYPELEMENTY
    select temp_WPEID = WPE_wpeid , temp_WplId     = WPE_wplid,temp_PraId_E   = WPE_praid,temp_TwpId   = WPE_twpid,
     temp_Nazwa_E  = WPE_nazwa,temp_Wartosc_E       = WPE_wartosc,
     temp_Ulga       = WPE_ulga,temp_Koszty       = WPE_koszty,temp_ZalFis       = WPE_zalfis,temp_NalFis       = WPE_nalfis,
     temp_PodstEmer       = WPE_podstemer,temp_PodstRent       = WPE_podstrent,temp_PodstChor       = WPE_podstchor,
     temp_PodstWypad     = WPE_podstwypad,
     temp_PodstFP       = WPE_podstfp,temp_PodstFGSP     = WPE_podstfgsp,temp_PodstZdrow     = WPE_podstzdrow,
     temp_SklEmerPrac       = WPE_sklemerprac,
     temp_SklEmerFirma       = WPE_sklemerfirma,temp_SklRentPrac       = WPE_sklrentprac,temp_SklRentFirma       = WPE_sklrentfirma,
     temp_SklChorPrac       = WPE_sklchorprac,temp_SklChorFirma     = WPE_sklchorfirma,temp_SklWypadPrac       = WPE_sklwypadprac,temp_SklWypadFirma     = WPE_sklwypadfirma,
     temp_SklFP       = WPE_sklfp,temp_SklFGSP       = WPE_sklfgsp,temp_Korekta_E = WPE_korekta ,temp_Brutto50     = WPE_brutto50,
     temp_Koszty50     = WPE_koszty50,
     temp_NrZUS = WPE_nrzus,temp_TyUb     = WPE_tyub,temp_SklZdrowPrac       = WPE_sklzdrowprac,
     temp_SklZdrowFirma       = WPE_sklzdrowfirma,temp_SklZdrowSuma       = WPE_sklzdrowsuma,
     temp_KatId_E   = WPE_katid,temp_KategoriaOpis_E = WPE_kategoriaopis,temp_Temp     = WPE_temp,temp_PodstFEP = WPE_PodstFEP, temp_SklFEP = WPE_SklFEP,
     temp_Przychod50     = WPE_Przychod50,
     temp_OpeZalId_E   = WPE_opezalid, temp_OpeZalKod_E   = WPE_opezalKod, temp_OpeZalNazwisko_E   = WPE_opezalNazwisko, temp_StaZalId_E = WPE_stazalid,
     temp_TS_Zal_E  = WPE_ts_zal,temp_OpeModId_E = WPE_opemodid, temp_OpeModKod_E = WPE_opemodKod, temp_OpeNazwiskoId_E = WPE_opemodNazwisko, temp_StaModId_E = WPE_stamodid,temp_TS_Mod_E = WPE_ts_mod,
     temp_WartoscWal_E = WPE_WartoscWal, temp_Waluta = WPE_Waluta, temp_Netto_E = WPE_Netto, temp_NettoWal_E = WPE_NettoWal,
      temp_PodstPPK = WPE_PodstPPK, temp_SklPPKPrac1 = WPE_SklPPKPrac1, temp_SklPPKPrac2 = WPE_SklPPKPrac2, temp_SklPPKFirma1 = WPE_SklPPKFirma1, temp_SklPPKFirma2 = WPE_SklPPKFirma2, temp_ZalFISZwol = WPE_ZalFISZwol, temp_PodstPITZwol = WPE_PodstPITZwol
     from cdn.wypelementy
      where wpe_wplid = @AnulowanaId
 if @@ERROR <> 0
  begin
   set @LocalError = 13
   set @LocalErrorDesc = 'Błąd tworzenia kursora elementów. Nie odnaleziono wypłaty anulowanej.'--ERR_SQL_Place_WypStorn4 32453
   goto L_FINISH
  end
 if 0 >= (select count(*) from cdn.wypelementy where wpe_wplid = @AnulowanaId)
  begin
   set @LocalError = 103
   set @LocalErrorDesc = 'Błąd tworzenia kursora elementów. Nie odnaleziono elementów wypłaty anulowanej.'--ERR_SQL_Place_WypStorn5 32454
   goto L_FINISH
  end
  open ELEMENTY
   while (1=1)
    begin
     fetch next from ELEMENTY
     into @ElementAnulowanyId
     if @@fetch_status <> 0
     break
     select
       @PraId_E = temp_PraId_E   ,@TwpId = temp_TwpId   ,@Nazwa_E = temp_Nazwa_E    ,@Wartosc_E = temp_Wartosc_E     ,
       @Ulga = temp_Ulga     ,@Koszty = temp_Koszty     ,@ZalFis = temp_ZalFis     ,@NalFis = temp_NalFis     ,
       @PodstEmer = temp_PodstEmer     ,@PodstRent = temp_PodstRent     ,@PodstChor = temp_PodstChor     ,@PodstWypad = temp_PodstWypad   ,
       @PodstFP= temp_PodstFP     ,@PodstFGSP = temp_PodstFGSP   ,@PodstZdrow = temp_PodstZdrow   ,@SklEmerPrac = temp_SklEmerPrac     ,
       @SklEmerFirma= temp_SklEmerFirma     ,@SklRentPrac = temp_SklRentPrac     ,@SklRentFirma = temp_SklRentFirma     ,
       @SklChorPrac= temp_SklChorPrac     ,@SklChorFirma = temp_SklChorFirma   ,@SklWypadPrac = temp_SklWypadPrac     ,@SklWypadFirma = temp_SklWypadFirma   ,
       @SklFP= temp_SklFP     ,@SklFGSP = temp_SklFGSP     ,@Korekta_E = temp_Korekta_E   ,@Brutto50 = temp_Brutto50,   @Koszty50 = temp_Koszty50   ,
       @NrZUS= temp_NrZUS   ,@TyUb = temp_TyUb     ,@SklZdrowPrac = temp_SklZdrowPrac,     @SklZdrowFirma = temp_SklZdrowFirma     ,@SklZdrowSuma = temp_SklZdrowSuma     ,
       @KatId_E= temp_KatId_E   ,@KategoriaOpis_E = temp_KategoriaOpis_E   ,@Temp = temp_Temp     ,@PodstFEP = temp_PodstFEP, @SklFEP = temp_SklFEP,
       @Przychod50 = temp_Przychod50   ,
       @OpeZalId_E = temp_OpeZalId_E   ,@OpeZalKod_E = temp_OpeZalKod_E , @OpeZalNazwisko_E = temp_OpeZalNazwisko_E , @StaZalId_E = temp_StaZalId_E   ,
       @TS_Zal_E= temp_TS_Zal_E     ,@OpeModId_E = temp_OpeModId_E   , @OpeModKod_E = temp_OpeModKod_E,  @OpeModNazwisko_E = temp_OpeModNazwisko_E, @StaModId_E = temp_StaModId_E   ,@TS_Mod_E = temp_TS_Mod_E,
       @WartoscWal_E = temp_WartoscWal_E, @Waluta_E = temp_Waluta, @Netto_E = temp_Netto_E, @NettoWal_E = temp_NettoWal_E,
       @PodstPPK = temp_PodstPPK, @SklPPKPrac1 = temp_SklPPKPrac1, @SklPPKPrac2 = temp_SklPPKPrac2, @SklPPKFirma1 = temp_SklPPKFirma1, @SklPPKFirma2 = temp_SklPPKFirma2, @ZalFISZwol = temp_ZalFISZwol, @PodstPITZwol = temp_PodstPITZwol
     from @TAB_STORNUJACA_TEMP_WYPELEMENTY
      where temp_WPEID = @ElementAnulowanyId
     insert into cdn.wypelementy
     (
      WPE_WplId,WPE_PraId,WPE_TwpId,WPE_Nazwa,WPE_Wartosc ,WPE_Ulga ,WPE_Koszty ,WPE_ZalFis ,WPE_NalFis ,
      WPE_PodstEmer,WPE_PodstRent,WPE_PodstChor,WPE_PodstWypad ,WPE_PodstFP ,WPE_PodstFGSP ,WPE_PodstZdrow,
      WPE_SklEmerPrac ,WPE_SklEmerFirma ,WPE_SklRentPrac ,WPE_SklRentFirma ,WPE_SklChorPrac ,WPE_SklChorFirma,
      WPE_SklWypadPrac,WPE_SklWypadFirma, WPE_SklFP , WPE_SklFGSP,WPE_Korekta,WPE_Brutto50 ,WPE_Koszty50 ,
      WPE_NrZUS ,WPE_TyUb ,WPE_SklZdrowPrac ,WPE_SklZdrowFirma,WPE_SklZdrowSuma ,WPE_KatId ,WPE_KategoriaOpis ,
      WPE_Temp ,WPE_PodstFEP, WPE_SklFEP, WPE_Przychod50 ,
      WPE_OpeZalId , WPE_OpeZalKod, WPE_OpeZalNazwisko, WPE_StaZalId, WPE_TS_Zal ,WPE_OpeModId,WPE_OpeModKod,WPE_OpeModNazwisko,WPE_StaModId ,WPE_TS_Mod,
      WPE_WartoscWal, WPE_Waluta, WPE_Netto, WPE_NettoWal,
      WPE_PodstPPK, WPE_SklPPKPrac1, WPE_SklPPKPrac2, WPE_SklPPKFirma1, WPE_SklPPKFirma2, WPE_ZalFISZwol, WPE_PodstPITZwol
     )
     values
     (
      @StornujacaID ,@PraId_E ,@TwpId ,@Nazwa_E ,- @Wartosc_E ,
      - @Ulga ,- @Koszty ,- @ZalFis ,- @NalFis ,
      - @PodstEmer ,- @PodstRent ,- @PodstChor ,- @PodstWypad ,
      - @PodstFP ,- @PodstFGSP ,- @PodstZdrow ,- @SklEmerPrac ,
      - @SklEmerFirma ,- @SklRentPrac ,- @SklRentFirma ,
      - @SklChorPrac ,- @SklChorFirma ,- @SklWypadPrac ,- @SklWypadFirma ,
      - @SklFP ,- @SklFGSP ,@Korekta_E ,- @Brutto50 ,- @Koszty50 ,
      @NrZUS ,@TyUb ,- @SklZdrowPrac ,- @SklZdrowFirma ,- @SklZdrowSuma ,
      @KatId_E ,@KategoriaOpis_E , @Temp, - @PodstFEP, - @SklFEP, -@Przychod50,
      @OpeZalId_E ,@OpeZalKod_E, @OpeZalNazwisko_E, @StaZalId_E ,
      @TS_Zal_E ,@OpeModId_E , @OpeModKod_E, @OpeModNazwisko_E, @StaModId_E ,@TS_Mod_E,
      @WartoscWal_E, @Waluta_E, @Netto_E, @NettoWal_E,
      -@PodstPPK, -@SklPPKPrac1, -@SklPPKPrac2, -@SklPPKFirma1, -@SklPPKFirma2, @ZalFISZwol, - @PodstPITZwol
     )
     if @@ERROR <> 0
      begin
       set @LocalError = 14
       set @LocalErrorDesc = 'Błąd dodawania elementu wypłaty stornującej.'--ERR_SQL_Place_WypStorn6 32455
       goto L_FINISH
      end
     declare @StornujacaElementID int
     select @StornujacaElementID = max(wpe_wpeid)
      from cdn.wypelementy
       where wpe_wplid = @StornujacaID
     if @StornujacaElementID is null
      begin
       set @LocalError = 104
       set @LocalErrorDesc = 'Błąd zapisu elementu wypłaty stornującej.'--ERR_SQL_Place_WypStorn7 32456
       goto L_FINISH
      end
     --przepisanie składników
     declare @SkladnikAnulowanyId int, @WplId_S int   ,
       @WpeId_S int   ,@PraId_S int   ,@DzlId_S int   ,@PnbId int ,@TwpId_S int   ,@RodzajZrodla int ,
       @ZrodloId int ,@Nazwa_S NVARCHAR ( 128)   ,@Wartosc_S decimal (15,2)   ,@DataDanych datetime   ,@DataOd_S datetime ,
       @DataDo_S datetime ,@Podstawa decimal (15,2) ,@OkresDni int   ,@OkresCzas datetime   ,@EkwiwalentIlosc decimal (15,2)   ,
       @Procent decimal (15,2)   ,@Wartosc1 decimal (15,2)   ,@Wartosc2 decimal (15,2)   ,@Splacono decimal (15,2)   ,
       @SplaconoAll tinyint   ,@Zaliczka int ,@DstId int ,@HrmId int ,@Godziny datetime   , @WartoscWal_S decimal(15,2),
       @OpeZalId_S int , @OpeZalKod_S varchar(20) ,@OpeZalNazwisko_S nvarchar(50) , @StaZalId_S int ,@TS_Zal_S datetime   ,@OpeModId_S int , @OpeModKod_S varchar(20) , @OpeModNazwisko_S nvarchar(50) ,@StaModId_S int ,@TS_Mod_S datetime
     declare SKLADNIKI cursor local fast_forward for
        select wps_wpsid from cdn.wypskladniki where wps_wpeid = @ElementAnulowanyId
     declare @TAB_STORNUJACA_TEMP_WYPSKLADNIKI table
      (
       temp_WPSId int, temp_WplId_S int   ,
       temp_WpeId_S int   ,temp_PraId_S int   ,temp_DzlId_S int   ,temp_PnbId int ,temp_TwpId_S int   ,temp_RodzajZrodla int ,
       temp_ZrodloId int ,temp_Nazwa_S NVARCHAR ( 128)   ,temp_Wartosc_S decimal (15,2)   ,temp_DataDanych datetime   ,temp_DataOd_S datetime ,
       temp_DataDo_S datetime ,temp_Podstawa decimal (15,2) ,temp_OkresDni int   ,temp_OkresCzas datetime   ,temp_EkwiwalentIlosc decimal (15,2)   ,
       temp_Procent decimal (15,2)   ,temp_Wartosc1 decimal (15,2)   ,temp_Wartosc2 decimal (15,2)   ,temp_Splacono decimal (15,2)   ,
       temp_SplaconoAll tinyint   ,temp_Zaliczka int ,temp_DstId int ,temp_HrmId int ,temp_Godziny datetime   , temp_WartoscWal_S decimal(15,2), temp_OpeZalId_S int , temp_OpeZalKod_S varchar(20) ,temp_OpeZalNazwisko_S nvarchar(50),
       temp_StaZalId_S int ,temp_TS_Zal_S datetime   ,temp_OpeModId_S int , temp_OpeModKod_S varchar(20) ,temp_OpeModNazwisko_S nvarchar(50), temp_StaModId_S int ,temp_TS_Mod_S datetime
      )
     insert into @TAB_STORNUJACA_TEMP_WYPSKLADNIKI
       select
       temp_WpsId = WPS_WpsId, temp_WplId_S = WPS_WplID  ,
       temp_WpeId_S = WPS_WPEID ,temp_PraId_S  = WPS_PraId,temp_DzlId_S  = WPS_DzlID,
       temp_PnbId = WPS_PnbID,temp_TwpId_S  = WPS_TWPID,temp_RodzajZrodla = WPS_RodzajZrodla,
       temp_ZrodloId  = WPS_ZrodloId,temp_Nazwa_S  = WPS_Nazwa,temp_Wartosc_S  = WPS_Wartosc,
       temp_DataDanych   = WPS_DataDanych,temp_DataOd_S  = WPS_DataOd,
       temp_DataDo_S  = WPS_DataDo,temp_Podstawa= WPS_Podstawa,temp_OkresDni  = WPS_OkresDni  ,temp_OkresCzas  = WPS_OkresCzas  ,temp_EkwiwalentIlosc = WPS_EkwiwalentIlosc,
       temp_Procent = WPS_Procent ,temp_Wartosc1  = WPS_Wartosc1,temp_Wartosc2  = WPS_Wartosc2,temp_Splacono   = WPS_Splacono,
       temp_SplaconoAll  = WPS_SplaconoAll,temp_Zaliczka = WPS_Zaliczka,temp_DstId  = WPS_DstID,temp_HrmId  = WPS_HrmID,temp_Godziny    = WPS_Godziny, temp_WartoscWal_S = WPS_WartoscWal, temp_OpeZalId_S  = WPS_OpeZalID, temp_OpeZalKod_S  = WPS_OpeZalKod, temp_OpeZalNazwisko_S  = WPS_OpeZalNazwisko,
       temp_StaZalId_S  = WPS_StaZalId, temp_TS_Zal_S  = WPS_TS_Zal,temp_OpeModId_S  = WPS_OpeModId, temp_OpeModKod_S  = WPS_OpeModKod, temp_OpeModNazwisko_S  = WPS_OpeModNazwisko, temp_StaModId_S  = WPS_StaModID,temp_TS_Mod_S = WPS_TS_Mod
        from cdn.wypskladniki
         where wps_wpeid = @ElementAnulowanyId
     if @@ERROR <> 0
      begin
       set @LocalError = 15
       set @LocalErrorDesc = 'Błąd tworzenia kursora składników. Nie odnaleziono elementu wypłaty anulowanej.'--ERR_SQL_Place_WypStorn8 32457
       goto L_FINISH
      end
     if (0 >= (select count(*) from cdn.wypskladniki where wps_wpeid = @ElementAnulowanyId))
      begin
       set @LocalError = 105
       set @LocalErrorDesc = 'Błąd tworzenia kursora składników. Nie odnaleziono składników wypłaty anulowanej.'--ERR_SQL_Place_WypStorn9 32458
       goto L_FINISH
      end
       open SKLADNIKI
        while (1=1)
         begin
          fetch next from SKLADNIKI
          into @SkladnikAnulowanyId
          if @@fetch_status <> 0
          break
          select
           @PraId_S = temp_PraID_S,@DzlId_S = temp_DzlID_S,@PnbId = temp_PnbID,
           @TwpId_S = temp_TwpID_S,@RodzajZrodla = temp_RodzajZrodla,
           @ZrodloId = temp_ZrodloID,@Nazwa_S = temp_Nazwa_S,
           @Wartosc_S = temp_Wartosc_S,@DataDanych = temp_DataDanych,@DataOd_S = temp_DataOd_S ,
           @DataDo_S = temp_DataDo_S,@Podstawa = temp_Podstawa,@OkresDni = temp_OkresDni,
           @OkresCzas = temp_OkresCzas,@EkwiwalentIlosc = temp_EkwiwalentIlosc,
           @Procent = temp_Procent,@Wartosc1 = temp_Wartosc1,@Wartosc2 = temp_Wartosc2,@Splacono = temp_Splacono,
           @SplaconoAll = temp_SplaconoAll,@Zaliczka = temp_Zaliczka,@DstId = temp_DstID,
           @HrmId = temp_HrmID,@Godziny = temp_Godziny, @WartoscWal_S = temp_WartoscWal_S, @OpeZalId_S = temp_OpeZalID_S, @OpeZalKod_S = temp_OpeZalKod_S, @OpeZalNazwisko_S = temp_OpeZalNazwisko_S,
           @StaZalId_S = temp_StaZalID_S,@TS_Zal_S = temp_TS_Zal_S,@OpeModId_S = temp_OpeModID_S, @OpeModKod_S = temp_OpeModKod_S, @OpeModNazwisko_S = temp_OpeModNazwisko_S,
           @StaModId_S = temp_StaModID_S, @TS_Mod_S = temp_TS_Mod_S
          from @TAB_STORNUJACA_TEMP_WYPSKLADNIKI
           where temp_WPSID = @SkladnikAnulowanyId
          insert into cdn.wypskladniki
          (
           WPS_WplId     ,WPS_WpeId     ,WPS_PraId     ,WPS_DzlId     ,WPS_PnbId   ,WPS_TwpId     ,
           WPS_RodzajZrodla   ,WPS_ZrodloId   ,WPS_Nazwa ,WPS_Wartosc     ,WPS_DataDanych     ,
           WPS_DataOd   ,WPS_DataDo   ,WPS_Podstawa   ,WPS_OkresDni     ,WPS_OkresCzas     ,
           WPS_EkwiwalentIlosc     ,WPS_Procent     ,WPS_Wartosc1     ,WPS_Wartosc2     ,WPS_Splacono     ,
           WPS_SplaconoAll ,WPS_Zaliczka   ,WPS_DstId   ,WPS_HrmId   ,WPS_Godziny     , WPS_WartoscWal, WPS_OpeZalId   ,WPS_OpeZalKod,WPS_OpeZalNazwisko,
           WPS_StaZalId   ,WPS_TS_Zal     ,WPS_OpeModId   , WPS_OpeModKod, WPS_OpeModNazwisko, WPS_StaModId   ,WPS_TS_Mod
          )
          values
          (
           @StornujacaID, @StornujacaElementID, @PraId_S ,@DzlId_S ,@PnbId ,@TwpId_S ,@RodzajZrodla ,
           @ZrodloId ,@Nazwa_S ,- @Wartosc_S ,@DataDanych ,@DataOd_S ,
           @DataDo_S ,- @Podstawa ,@OkresDni ,@OkresCzas ,@EkwiwalentIlosc ,
           @Procent ,- @Wartosc1 ,- @Wartosc2 ,- @Splacono ,
           @SplaconoAll ,@Zaliczka ,@DstId ,@HrmId ,@Godziny , @WartoscWal_S, @OpeZalId_S ,@OpeZalKod_S, @OpeZalNazwisko_S,
           @StaZalId_S ,@TS_Zal_S ,@OpeModId_S , @OpeModKod_S, @OpeModNazwisko_S, @StaModId_S,@TS_Mod_S
          )
          if @@ERROR <> 0
           begin
            set @LocalError = 16
            set @LocalErrorDesc = 'Błąd dodawania składnika wypłaty stornującej.'--ERR_SQL_Place_WypStorn10 32459
            goto L_FINISH
           end
          declare @StornujacaSkladnikID int
          select @StornujacaSkladnikID = max(wps_wpsid)
           from cdn.wypskladniki
            where wps_wpeid = @StornujacaElementID and wps_wplid = @StornujacaId
          if @StornujacaElementID is null
           begin
            set @LocalError = 106
            set @LocalErrorDesc = 'Błąd zapisu składnika wypłaty stornującej.'--ERR_SQL_Place_WypStorn11 32460
            goto L_FINISH
           end
         end
      close SKLADNIKI
     deallocate SKLADNIKI
     --przepisanie opisu analitycznego
     if exists (select * from cdn.opisplace where opp_wpeid = @ElementAnulowanyId)
      begin
      declare @OpisAnulowanyId int, @WpeId_O int  ,
        @PraId_O int ,@DzlId_O int ,@PrjId int ,@Procent_O decimal (15,4),@Brutto_O decimal (15,2),
        @ZUSF decimal (15,2) ,@ZUSP decimal (15,2) ,@Zdrow decimal (15,2),@ZalFIS_O decimal (15,2),
        @PPKP decimal (15,2), @PPKF decimal (15,2)
      declare OPIS cursor local fast_forward for
         select opp_oppid from cdn.opisplace where opp_wpeid = @ElementAnulowanyId
      declare @TAB_STORNUJACA_TEMP_OPISPLACE table
       (
        temp_OppId int, temp_WpeId_O int  ,
        temp_PraId_O int ,temp_DzlId_O int ,temp_PrjId int ,temp_Procent_O decimal (15,4),temp_Brutto_O decimal (15,2),
        temp_ZUSF decimal (15,2) ,temp_ZUSP decimal (15,2) ,temp_Zdrow decimal (15,2),temp_ZalFIS_O decimal (15,2),
        temp_PPKP decimal (15,2), temp_PPKF decimal (15,2)
       )
      insert into @TAB_STORNUJACA_TEMP_OPISPLACE
       select
        temp_OppId = opp_oppid, temp_WpeId_O = opp_wpeid  ,
        temp_PraId_O = opp_praid ,temp_DzlId_O = opp_dzlid ,temp_PrjId = opp_prjid ,temp_Procent_O = opp_procent,temp_Brutto_O = opp_brutto,
        temp_ZUSF = opp_zusf ,temp_ZUSP = opp_zusp,temp_Zdrow = opp_zdrow,temp_ZalFIS_O = opp_zalfis,
        temp_PPKP = opp_ppkp, temp_PPKF = opp_ppkf
        from cdn.opisplace
         where opp_wpeid = @ElementAnulowanyId
      if @@ERROR <> 0
       begin
        set @LocalError = 17
        set @LocalErrorDesc = 'Błąd tworzenia kursora opisu analitycznego. Nie odnaleziono elementu wypłaty anulowanej.'--ERR_SQL_Place_WypStorn12 32461
        goto L_FINISH
       end
      if (0 >= (select count(*) from cdn.opisplace where opp_wpeid = @ElementAnulowanyId))
       begin
        set @LocalError = 107
        set @LocalErrorDesc = 'Błąd tworzenia kursora opisu analitycznego. Nie odnaleziono opisu analitycznego wypłaty anulowanej.'--ERR_SQL_Place_WypStorn13 32462
        goto L_FINISH
       end
        open OPIS
         while (1=1)
          begin
           fetch next from OPIS
           into @OpisAnulowanyId
           if @@fetch_status <> 0
           break
           select
            @PraId_O = temp_PraId_O,@DzlId_O = temp_DzlId_O , @PrjId= temp_PrjId , @Procent_O= temp_Procent_O , @Brutto_O= temp_Brutto_O ,
             @ZUSF= temp_ZUSF ,@ZUSP = temp_ZUSP , @Zdrow= temp_Zdrow ,@ZalFIS_O = temp_ZalFIS_O,
             @PPKP = temp_PPKP, @PPKF = temp_PPKF
           from @TAB_STORNUJACA_TEMP_OPISPLACE
            where temp_OPPID = @OpisAnulowanyId
           insert into cdn.opisplace
           (
            OPP_WpeId ,OPP_PraId ,OPP_DzlId ,OPP_PrjId ,OPP_Procent ,OPP_Brutto ,OPP_ZUSF ,OPP_ZUSP ,OPP_Zdrow ,OPP_ZalFIS , OPP_PPKP, OPP_PPKF
           )
           values
           (
            @StornujacaElementID,
            @PraId_O ,@DzlId_O ,@PrjId ,isnull(-@Procent_O, 0) ,isnull(-@Brutto_O,0) ,isnull(-@ZUSF,0) ,isnull(-@ZUSP,0) ,isnull(-@Zdrow,0) ,isnull(-@ZalFIS_O,0) ,isnull(-@PPKP,0) ,isnull(-@PPKF,0)
           )
           if @@ERROR <> 0
            begin
             set @LocalError = 18
             set @LocalErrorDesc = 'Błąd zapisu opisu analitycznego wypłaty stornującej.'--ERR_SQL_Place_WypStorn14 32463
             goto L_FINISH
            end
           declare @StornujacaOpisID int
           select @StornujacaOpisID = max(opp_oppid)
            from cdn.opisplace
             where opp_wpeid = @StornujacaElementID
           if @StornujacaElementID is null
            begin
             set @LocalError = 108
             set @LocalErrorDesc = 'Błąd zapisu opisu analitycznego wypłaty stornującej.'--ERR_SQL_Place_WypStorn14 32463
             goto L_FINISH
            end
          end
       close OPIS
      deallocate OPIS
     end
    end
  close ELEMENTY
 deallocate ELEMENTY
 --przepisanie płatności
 if 0 < (select count(bzd_bzdid) from cdn.bnkzdarzenia where bzd_dokumenttyp = 8 and bzd_dokumentid = @AnulowanaId)
  begin
  declare @PlatnoscAnulowanaId int,
   @RelTyp smallint ,@RelID integer ,@PrwTyp smallint ,@PrwID integer ,@BRaID integer ,@DDfID_P integer ,@DokumentTyp smallint ,
   @DokumentID integer ,@NumerPelny_P NVARCHAR ( 30)   ,@NumerObcy NVARCHAR ( 30)   ,@Numer NVARCHAR ( 60)   ,@PodmiotTyp smallint   ,
   @PodmiotID integer   ,@PodmiotRachunekLp int   ,@BNaID integer ,@RachunekNr NVARCHAR ( 51)   ,@IBAN smallint   ,@KatID_P integer ,
   @FPlId integer ,@DataDok_P datetime   ,@Termin datetime   ,@DataReal datetime   ,@KwotaSys decimal (15,2),@KwotaRozSys decimal (15,2) ,
   @Kwota decimal (15,2) ,@KwotaRoz decimal (15,2),@Waluta NVARCHAR ( 3)   ,@WalutaDok NVARCHAR ( 3)   ,@KursNumer integer   ,
   @KursL decimal (15,4)   ,@KursM decimal ( 5,0)   ,@DataRoz datetime ,@Kierunek smallint ,@DataKur datetime   ,@Zwloka smallint   ,
   @Priorytet smallint   ,@Rozliczono smallint   ,@Rozliczono2 smallint   ,@Stan smallint   ,@ElixirO1 NVARCHAR ( 35)   ,
   @ElixirO2 NVARCHAR ( 35)   ,@ElixirO3 NVARCHAR ( 35)   ,@ElixirO4 NVARCHAR ( 35)   ,@Opis NVARCHAR ( 254)   ,@KontoPrzeciwstawne NVARCHAR ( 50)   ,
   @OpeWysId integer ,@TS_Wys datetime ,@OpePotwId integer ,@TS_Potw datetime ,@TS_Export datetime ,@ImportAppId NVARCHAR ( 5) ,
   @ImportRowId NVARCHAR ( 36) ,@IdSynchro integer ,@TypDokumentuKB smallint,@OpeZalId_P integer ,@OpeZalKod_P VARCHAR (20), @OpeZalNazwisko_P NVARCHAR (50), @StaZalId_P integer ,@TS_Zal_P datetime   ,
   @StaModId_P integer ,@OpeModId_P integer , @OpeModKod_P VARCHAR (20), @OpeModNazwisko_P NVARCHAR (50) ,@TS_Mod_P datetime, @KomornikZajecieWynagr tinyint
  declare PLATNOSCI cursor local fast_forward for
   select Bzd_BzdId from cdn.bnkzdarzenia where bzd_dokumenttyp = 8 and bzd_dokumentid = @AnulowanaId
  declare @TAB_STORNUJACA_TEMP_BNKZDARZENIA table
   (
    temp_BzdId int,temp_RelTyp smallint ,temp_RelID integer ,temp_PrwTyp smallint ,temp_PrwID integer ,temp_BRaID integer ,
    temp_DDfID_P integer ,temp_DokumentTyp smallint ,
    temp_DokumentID integer ,temp_NumerPelny_P NVARCHAR ( 30)   ,temp_NumerObcy NVARCHAR ( 30)   ,temp_Numer NVARCHAR ( 60)   ,
    temp_PodmiotTyp smallint   ,
    temp_PodmiotID integer   ,temp_PodmiotRachunekLp int   ,temp_BNaID integer ,temp_RachunekNr NVARCHAR ( 51)   ,
    temp_IBAN smallint   ,temp_KatID_P integer ,
    temp_FPlId integer ,temp_DataDok_P datetime   ,temp_Termin datetime   ,temp_DataReal datetime   ,temp_KwotaSys decimal (15,2),
    temp_KwotaRozSys decimal (15,2) ,
    temp_Kwota decimal (15,2) ,temp_KwotaRoz decimal (15,2),temp_Waluta NVARCHAR ( 3)   ,temp_WalutaDok NVARCHAR ( 3)   ,
    temp_KursNumer integer   ,
    temp_KursL decimal (15,4)   ,temp_KursM decimal ( 5,0)   ,temp_DataRoz datetime ,temp_Kierunek smallint ,temp_DataKur datetime   ,
    temp_Zwloka smallint   ,
    temp_Priorytet smallint   ,temp_Rozliczono smallint   ,temp_Rozliczono2 smallint   ,temp_Stan smallint,
    temp_ElixirO1 NVARCHAR ( 35)   ,
    temp_ElixirO2 NVARCHAR ( 35)   ,temp_ElixirO3 NVARCHAR ( 35)   ,temp_ElixirO4 NVARCHAR ( 35)   ,temp_Opis NVARCHAR ( 254)   ,
    temp_KontoPrzeciwstawne NVARCHAR ( 50)   ,
    temp_OpeWysId integer ,temp_TS_Wys datetime ,temp_OpePotwId integer ,temp_TS_Potw datetime ,temp_TS_Export datetime ,
    temp_ImportAppId NVARCHAR ( 5) ,
    temp_ImportRowId NVARCHAR ( 36) ,temp_IdSynchro integer ,temp_TypDokumentuKB smallint,temp_OpeZalId_P integer ,temp_OpeZalKod_P VARCHAR (20), temp_OpeZalNazwisko_P NVARCHAR (50),
    temp_StaZalId_P integer ,temp_TS_Zal_P datetime   ,
    temp_StaModId_P integer ,temp_OpeModId_P integer , temp_OpeModKod_P VARCHAR (20), temp_OpeModNazwisko_P NVARCHAR (50), temp_TS_Mod_P datetime, temp_KomornikZajecieWynagr tinyint
   )
  insert into @TAB_STORNUJACA_TEMP_BNKZDARZENIA
   select temp_BzdId = BZD_BzdId,
    temp_RelTyp = BZD_RelTyp,temp_RelID = BZD_RelID,temp_PrwTyp = BZD_PrwTyp,temp_PrwId = BZD_PrwId,
    temp_BraID = BZD_BraID,
    temp_DDFID_P = BZD_DDFID,temp_DokumentTyp = BZD_DokumentTyp,
    temp_DokumentId = BZD_DokumentId,temp_NumerPelny_P = BZD_NumerPelny,temp_NumerObcy = BZD_NumerObcy,
    temp_Numer = BZD_Numer,
    temp_PodmiotTyp = BZD_PodmiotTyp,
    temp_PodmiotID = BZD_PodmiotID,temp_PodmiotRachunekLp = BZD_PodmiotRachunekLp,temp_BNAID = BZD_BNAID,
    temp_RachunekNr = BZD_RachunekNr,
    temp_IBAN = BZD_IBAN,temp_KATID_P = BZD_KATID,
    temp_FPLID = BZD_FPLID,temp_DataDok_P = BZD_DataDok,temp_Termin = BZD_Termin,temp_DataReal = BZD_DataReal,
    temp_KwotaSys = BZD_KwotaSys,temp_KwotaRozSys = BZD_KwotaRozSys,
    temp_Kwota = BZD_Kwota,temp_KwotaRoz = BZD_KwotaRoz,temp_Waluta = BZD_Waluta,
    temp_WalutaDok = BZD_WalutaDok, temp_KursNumer = BZD_KursNumer, temp_KursL = BZD_KursL, temp_KursM = BZD_KursM,
    temp_DataRoz = BZD_DataRoz, temp_Kierunek = BZD_Kierunek, temp_DataKur = BZD_DataKur, temp_Zwloka = BZD_Zwloka,
    temp_Priorytet = BZD_Priorytet,
    temp_Rozliczono = BZD_Rozliczono,temp_Rozliczono2 = BZD_Rozliczono2, temp_Stan = BZD_Stan, temp_ElixirO1 = BZD_ElixirO1,
    temp_ElixirO2 = BZD_ElixirO2,temp_ElixirO3 = BZD_ElixirO3,temp_ElixirO4 = BZD_ElixirO4,temp_Opis = BZD_Opis,
    temp_KontoPrzeciwstawne = BZD_KontoPrzeciwstawne,
    temp_OpeWysId = BZD_OpeWysId,temp_TS_Wys = BZD_TS_Wys,temp_OpePotwId = BZD_OpePotwId,temp_TS_Potw = BZD_TS_Potw,
    temp_TS_Export = BZD_TS_Export,temp_ImportAppId = BZD_ImportAppId, temp_ImportRowId = BZD_ImportRowId,
    temp_IdSynchro = BZD_IdSynchro,temp_TypDokumentuKB = BZD_TypDokumentuKB, temp_OpeZalId_P = BZD_OpeZalId, temp_OpeZalKod_P = BZD_OpeZalKod, temp_OpeZalNazwisko_P = BZD_OpeZalNazwisko, temp_StaZalId_P = BZD_StaZalId,
    temp_TS_Zal_P = BZD_TS_Zal,
    temp_StaModId_P = BZD_StaModId,temp_OpeModId_P = BZD_OpeModId, temp_OpeModKod_P = BZD_OpeModKod, temp_OpeModNazwisko_P = BZD_OpeModNazwisko, temp_TS_Mod_P = BZD_TS_Mod, temp_KomornikZajecieWynagr = BZD_KomornikZajecieWynagr
    from cdn.bnkzdarzenia
     where bzd_dokumenttyp = 8 and bzd_dokumentid = @AnulowanaId
  if @@ERROR <> 0
   begin
    set @LocalError = 19
    set @LocalErrorDesc = 'Błąd tworzenia kursora płatności wypłaty. Nie odnaleziono wypłaty anulowanej.'--ERR_SQL_Place_WypStorn15 32464
    goto L_FINISH
   end
  if 0 >= (select count(*) from cdn.bnkzdarzenia where bzd_dokumenttyp = 8 and bzd_dokumentid = @AnulowanaId)
   begin
    set @LocalError = 109
    set @LocalErrorDesc = 'Błąd tworzenia kursora płatności wypłaty. Nie odnaleziono płatności wypłaty anulowanej.'--ERR_SQL_Place_WypStorn16 32465
    goto L_FINISH
   end
   open PLATNOSCI
    while (1=1)
     begin
      fetch next from PLATNOSCI
      into @PlatnoscAnulowanaId
      if @@fetch_status <> 0
      break
      select @RelTyp = temp_RelTyp,@RelID = temp_RelID,@PrwTyp = temp_PrwTyp,@PrwID = temp_PrwId,@BRaID = temp_BraID,
        @DDfID_P = temp_DDFID_P,@DokumentTyp = temp_DokumentTyp,
        @DokumentID = temp_DokumentId,@NumerPelny_P = temp_NumerPelny_P,@NumerObcy = temp_NumerObcy,@PodmiotTyp = temp_PodmiotTyp,
        @PodmiotID = temp_PodmiotID,@PodmiotRachunekLp = temp_PodmiotRachunekLp,@BNaID = temp_BNAID,@RachunekNr = temp_RachunekNr,
        @IBAN = temp_IBAN,@KatID_P = temp_KATID_P,
        @FPlId = temp_FPLID,@DataDok_P = temp_DataDok_P,@Termin = temp_Termin,@DataReal = temp_DataReal,
        @KwotaSys = temp_KwotaSys,@KwotaRozSys = temp_KwotaRozSys,
        @Kwota = temp_Kwota,@KwotaRoz = temp_KwotaRoz,@Waluta = temp_Waluta,
        @WalutaDok = temp_WalutaDok, @KursNumer = temp_KursNumer, @KursL = temp_KursL, @KursM = temp_KursM,
        @DataRoz = temp_DataRoz, @DataKur = temp_DataKur, @Zwloka = temp_Zwloka, @Priorytet = temp_Priorytet,
        @Rozliczono = temp_Rozliczono, @Rozliczono2 = temp_Rozliczono2, @ElixirO1 = temp_ElixirO1,
        @ElixirO2 = temp_ElixirO2,@ElixirO3 = temp_ElixirO3,@ElixirO4 = temp_ElixirO4,@Opis = temp_Opis,
        @KontoPrzeciwstawne = temp_KontoPrzeciwstawne,
        @OpeWysId = temp_OpeWysId,@TS_Wys = temp_TS_Wys,@OpePotwId = temp_OpePotwId,@TS_Potw = temp_TS_Potw,
        @TS_Export = temp_TS_Export,@ImportAppId = temp_ImportAppId,
        @IdSynchro = temp_IdSynchro,@OpeZalId_P = temp_OpeZalId_P, @OpeZalKod_P = temp_OpeZalKod_P, @OpeZalNazwisko_P = temp_OpeZalNazwisko_P, @StaZalId_P = temp_StaZalId_P,@TS_Zal_P = temp_TS_Zal_P,
        @StaModId_P = temp_StaModId_P,@OpeModId_P = temp_OpeModId_P, @OpeModKod_P = temp_OpeModKod_P, @OpeModNazwisko_P = temp_OpeModNazwisko_P, @TS_Mod_P = temp_TS_Mod_P, @KomornikZajecieWynagr = temp_KomornikZajecieWynagr
       from @TAB_STORNUJACA_TEMP_BNKZDARZENIA
        where temp_BzdId = @PlatnoscAnulowanaId
      insert into cdn.bnkzdarzenia
       (
       BZd_RelTyp   ,BZd_RelID   ,BZd_PrwTyp   ,BZd_PrwID   ,BZd_BRaID   ,BZd_DDfID   ,BZd_DokumentTyp   ,BZd_DokumentID   ,
       BZd_NumerPelny  ,BZd_NumerObcy       ,BZd_PodmiotTyp     ,BZd_PodmiotID     ,BZd_PodmiotRachunekLp     ,
       BZd_BNaID   ,BZd_RachunekNr  ,BZd_IBAN     ,BZd_KatID   ,BZd_FPlId   ,BZd_DataDok     ,BZd_Termin     ,BZd_DataReal     ,
       BZd_KwotaSys   ,BZd_KwotaRozSys  ,BZd_Kwota ,BZd_KwotaRoz ,BZd_Waluta      ,
       BZd_WalutaDok    ,BZd_KursNumer     ,
       BZd_KursL   ,BZd_KursM   ,BZd_DataRoz   ,BZd_Kierunek  ,BZd_DataKur     ,BZd_Zwloka     ,BZd_Priorytet     ,
       BZd_Rozliczono     ,BZd_Rozliczono2     ,BZd_Stan     ,BZd_ElixirO1 ,BZd_ElixirO2 ,BZd_ElixirO3 ,BZd_ElixirO4 ,BZd_Opis  ,
       BZd_KontoPrzeciwstawne   ,BZd_OpeWysId   ,BZd_TS_Wys   ,BZd_OpePotwId   ,BZd_TS_Potw   ,BZd_TS_Export   ,
       BZd_ImportAppId    , BZd_IdSynchro   ,BZd_OpeZalId   , BZd_OpeZalKod, BZd_OpeZalNazwisko, BZd_StaZalId   ,
       BZd_TS_Zal     ,BZd_StaModId   ,BZd_OpeModId   ,BZd_OpeModKod, BZd_OpeModNazwisko, BZd_TS_Mod,     BZD_KomornikZajecieWynagr
      )
      values
      (
       @RelTyp ,@RelID ,@PrwTyp ,@PrwID ,@BRaID ,@DDF_KOREKTA ,8 ,
       @StornujacaID ,@StornujacaNumerPelny ,@NumerObcy  ,@PodmiotTyp ,
       @PodmiotID ,@PodmiotRachunekLp ,@BNaID ,@RachunekNr ,@IBAN ,@KatID_P ,
       @FPlId ,@DataDok_P ,@Termin ,@DataReal , @KwotaSys , @KwotaRozSys ,
        @Kwota , @KwotaRoz ,@Waluta
        ,@WalutaDok ,@KursNumer ,
       @KursL ,@KursM ,@DataRoz ,1 ,@DataKur ,@Zwloka ,
       @Priorytet ,0 ,@Rozliczono2 ,1 ,@ElixirO1 ,
       @ElixirO2 ,@ElixirO3 ,@ElixirO4 ,@Opis ,@KontoPrzeciwstawne ,
       @OpeWysId ,@TS_Wys ,@OpePotwId ,@TS_Potw ,@TS_Export ,@ImportAppId ,
       @IdSynchro ,@OpeZalId_P, @OpeZalKod_P, @OpeZalNazwisko_P ,@StaZalId_P ,@TS_Zal_P ,
       @StaModId_P ,@OpeModId_P , @OpeModKod_P, @OpeModNazwisko_P, @TS_Mod_P , @KomornikZajecieWynagr
      )
      if @@ERROR <> 0
       begin
        set @LocalError = 20
        set @LocalErrorDesc = 'Błąd dodawania płatności wypłaty stornującej.'--ERR_SQL_Place_WypStorn17 32466
        goto L_FINISH
       end
      declare @StornujacaPlatnoscID int
      select @StornujacaPlatnoscID = max(bzd_bzdid)
       from cdn.bnkzdarzenia
        where bzd_dokumenttyp = 8 and bzd_dokumentid = @StornujacaID
      if @StornujacaPlatnoscID is null
       begin
        set @LocalError = 120
        set @LocalErrorDesc = 'Błąd zapisu płatności wypłaty stornującej.'--ERR_SQL_Place_WypStorn18 32467
        goto L_FINISH
       end
     end
   close PLATNOSCI
  deallocate PLATNOSCI
 end
 commit tran T
 if @@ERROR <> 0
  begin
   set @LocalError = 999
   set @LocalErrorDesc = 'Błąd zatwierdzenia transakcji.' --ERR_SQL_Place_BladZatwTransakcji 32136
   goto L_FINISH
  end
  select 0, ''
L_FINISH:
 if @LocalError <> 0
  begin
   --set @LocalErrorDesc = @LocalErrorDesc + ' [nr błędu: ' + cast(@LocalError as NVARCHAR(3)) + ']'
   select @LocalError, @LocalErrorDesc
   --raiserror(@LocalErrorDesc, 16, 1)
   if @LocalError = 101 or @LocalError = 11
   begin
    RAISERROR('##OPT32450##', 16, 1)
   end
   if @LocalError = 12
   begin
    RAISERROR('##OPT32451##', 16, 1)
   end
   if @LocalError = 102
   begin
    RAISERROR('##OPT32452##', 16, 1)
   end
   if @LocalError = 13
   begin
    RAISERROR('##OPT32453##', 16, 1)
   end
   if @LocalError = 103
   begin
    RAISERROR('##OPT32454##', 16, 1)
   end
   if @LocalError = 14
   begin
    RAISERROR('##OPT32455##', 16, 1)
   end
   if @LocalError = 104
   begin
    RAISERROR('##OPT32456##', 16, 1)
   end
   if @LocalError = 15
   begin
    RAISERROR('##OPT32457##', 16, 1)
   end
   if @LocalError = 105
   begin
    RAISERROR('##OPT32458##', 16, 1)
   end
   if @LocalError = 16
   begin
    RAISERROR('##OPT32459##', 16, 1)
   end
   if @LocalError = 106
   begin
    RAISERROR('##OPT32460##', 16, 1)
   end
   if @LocalError = 17
   begin
    RAISERROR('##OPT32461##', 16, 1)
   end
   if @LocalError = 107
   begin
    RAISERROR('##OPT32462##', 16, 1)
   end
   if @LocalError = 108 or @LocalError = 18
   begin
    RAISERROR('##OPT32463##', 16, 1)
   end
   rollback tran T
  end
    set nocount off
