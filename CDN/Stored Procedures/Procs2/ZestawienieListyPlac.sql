--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure [CDN].[ZestawienieListyPlac] @_ListaPlacId int, @_WyplataId int
as
set nocount on
declare
 @Brutto decimal(14,2),@DodNieOpod decimal(14,2),@DodOpod decimal(14,2),@Korekta decimal(14,2),@Koszty decimal(14,2),@Nadgodz100 decimal(14,2),
 @Nadgodz50 decimal(14,2),@NadgodzNocDoplata decimal(14,2),@PotrNieOpod decimal(14,2),@PotrOpod decimal(14,2),@SklZUS decimal(14,2),@SklPPK decimal(14,2),@ZalPod decimal(14,2),
    @Zasadnicze decimal(14,2),@ZasNieobNieOpod decimal(14,2),@ZasNieobOpod decimal(14,2),@ZasNieOpod decimal(14,2),@ZasOpod decimal(14,2),@SumaOpodat decimal(14,2),
    @PodstOpodat decimal(14,2),@WplywaNaGotowke decimal(14,2),
    @PodatekKosztyZUS decimal(14,2),@PodatekKoszty decimal(14,2),@PodatekUlga decimal(14,2),@PodatekKoszty50 decimal(14,2),@PodatekBrutto50 decimal(14,2),
    @PodatekNalFIS decimal(14,2),@PodatekZalFIS decimal(14,2),@PodatekSklZdrowPrac decimal(14,2),@PodatekSklZdrowSuma decimal(14,2),
 @PodatekSklZdrowPracPob decimal(14,2),@PodatekSklZdrowFirma decimal(14,2),@PodatekPodstEmer decimal(14,2),@PodatekPodstRent decimal(14,2),
    @PodatekPodstChor decimal(14,2),@PodatekPodstWypad decimal(14,2),@PodatekPodstZdrow decimal(14,2),@PodatekPodstFP decimal(14,2),@PodatekPodstFGSP decimal(14,2),
    @PodatekPodstFEP decimal(14,2), @PodatekSklEmerPrac decimal(14,2),@PodatekSklEmerFirma decimal(14,2),@PodatekSklRentPrac decimal(14,2),
 @PodatekSklRentFirma decimal(14,2),@PodatekSklChorPrac decimal(14,2),@PodatekSklChorFirma decimal(14,2),@PodatekSklWypadPrac decimal(14,2),
 @PodatekSklWypadFirma decimal(14,2),@PodatekSumaPrac decimal(14,2),@PodatekSumaFirma decimal(14,2),@PodatekSklFP decimal(14,2),@PodatekSklFGSP decimal(14,2),
    @PodatekSklFEP decimal(14,2),@PodatekPrzychod50 decimal(14,2),
 @PodatekPodstPPK decimal(14,2), @PodatekSklPPKPrac1 decimal(14,2), @PodatekSklPPKPrac2 decimal(14,2), @PodatekSklPPKFirma1 decimal(14,2), @PodatekSklPPKFirma2 decimal(14,2),
    @ROR decimal(14,2),@Gotowka decimal(14,2),@Razem decimal(14,2),@PodatekKosztyZUSOpodat decimal(14,2),@PodstZdrowOpodat decimal(14,2)
    declare @Oddelegowani int
    if(@_ListaPlacId > 0)
  select @Oddelegowani = LPL_Oddelegowani from CDN.ListyPlac where LPL_LplId = @_ListaPlacId
 else
  select @Oddelegowani = LPL_Oddelegowani from CDN.Wyplaty join cdn.ListyPlac on WPL_LplId = LPL_LplId where WPL_WplId = @_WyplataId
 set @Brutto = 0
    set @DodNieOpod = 0
    set @DodOpod = 0
    set @Korekta = 0
    set @Koszty = 0
    set @Nadgodz100 = 0
    set @Nadgodz50 = 0
    set @NadgodzNocDoplata = 0
    set @PotrNieOpod = 0
    set @PotrOpod = 0
    set @SklZUS = 0
 set @SklPPK = 0
    set @ZalPod = 0
    set @Zasadnicze = 0
    set @ZasNieobNieOpod = 0
    set @ZasNieobOpod = 0
    set @ZasNieOpod = 0
    set @ZasOpod = 0
    set @SumaOpodat = 0
    set @PodstOpodat = 0
 set @WplywaNaGotowke = 0
    set @PodatekKosztyZUS = 0
 set @PodatekKosztyZUSOpodat = 0
    set @PodatekKoszty = 0
    set @PodatekUlga = 0
    set @PodatekKoszty50 = 0
    set @PodatekBrutto50 = 0
    set @PodatekNalFIS = 0
    set @PodatekZalFIS = 0
    set @PodatekSklZdrowPrac = 0
    set @PodatekSklZdrowSuma = 0
 set @PodatekSklZdrowPracPob = 0
    set @PodatekSklZdrowFirma = 0
    set @PodatekPodstEmer = 0
    set @PodatekPodstRent = 0
    set @PodatekPodstChor = 0
    set @PodatekPodstWypad = 0
    set @PodatekPodstZdrow = 0
    set @PodatekPodstFP = 0
    set @PodatekPodstFGSP = 0
    set @PodatekPodstFEP = 0
    set @PodatekSklEmerPrac = 0
    set @PodatekSklEmerFirma = 0
    set @PodatekSklRentPrac = 0
    set @PodatekSklRentFirma = 0
    set @PodatekSklChorPrac = 0
    set @PodatekSklChorFirma = 0
    set @PodatekSklWypadPrac = 0
    set @PodatekSklWypadFirma = 0
 set @PodatekSumaPrac = 0
 set @PodatekSumaFirma = 0
    set @PodatekSklFP = 0
    set @PodatekSklFGSP = 0
    set @PodatekSklFEP = 0
 set @PodatekPrzychod50 = 0
 set @PodstZdrowOpodat = 0
 set @PodatekPodstPPK = 0
 set @PodatekSklPPKPrac1 = 0
 set @PodatekSklPPKPrac2 = 0
 set @PodatekSklPPKFirma1 = 0
 set @PodatekSklPPKFirma2 = 0
    set @ROR = 0
    set @Gotowka = 0
    set @Razem = 0
 declare @ZESTXYZ table
 (
 Brutto decimal(14,2),DodNieOpod decimal(14,2),DodOpod decimal(14,2),Korekta decimal(14,2),Koszty decimal(14,2),Nadgodz100 decimal(14,2),Nadgodz50 decimal(14,2),
    NadgodzNocDoplata decimal(14,2),PotrNieOpod decimal(14,2),PotrOpod decimal(14,2),SklZUS decimal(14,2),SklPPK decimal(14,2),ZalPod decimal(14,2),Zasadnicze decimal(14,2),
    ZasNieobNieOpod decimal(14,2),ZasNieobOpod decimal(14,2),ZasNieOpod decimal(14,2),ZasOpod decimal(14,2),SumaOpodat decimal(14,2),PodstOpodat decimal(14,2),
 WplywaNaGotowke decimal(14,2),PodatekKosztyZUS decimal(14,2),PodatekKoszty decimal(14,2),PodatekUlga decimal(14,2),PodatekKoszty50 decimal(14,2),
    PodatekBrutto50 decimal(14,2),PodatekNalFIS decimal(14,2),PodatekZalFIS decimal(14,2),PodatekSklZdrowPrac decimal(14,2),PodatekSklZdrowSuma decimal(14,2),
 PodatekSklZdrowPracPob decimal(14,2),PodatekSklZdrowFirma decimal(14,2),PodatekPodstEmer decimal(14,2),PodatekPodstRent decimal(14,2),
 PodatekPodstChor decimal(14,2),PodatekPodstWypad decimal(14,2),PodatekPodstZdrow decimal(14,2),PodatekPodstFP decimal(14,2),PodatekPodstFGSP decimal(14,2),
    PodatekPodstFEP decimal(14,2),PodatekSklEmerPrac decimal(14,2),PodatekSklEmerFirma decimal(14,2),PodatekSklRentPrac decimal(14,2),
 PodatekSklRentFirma decimal(14,2),PodatekSklChorPrac decimal(14,2),PodatekSklChorFirma decimal(14,2),PodatekSklWypadPrac decimal(14,2),
 PodatekSklWypadFirma decimal(14,2),PodatekSumaPrac decimal(14,2),PodatekSumaFirma decimal(14,2),PodatekSklFP decimal(14,2),PodatekSklFGSP decimal(14,2),
    PodatekSklFEP decimal(14,2),ROR decimal(14,2),Gotowka decimal(14,2),Razem decimal(14,2),PodatekPrzychod50 decimal(14,2),PodatekKosztyZUSOpodat decimal(14,2), PodstZdrowOpodat decimal(14, 2),
 PodatekPodstPPK decimal(14,2), PodatekSklPPKPrac1 decimal(14,2), PodatekSklPPKPrac2 decimal(14,2), PodatekSklPPKFirma1 decimal(14,2), PodatekSklPPKFirma2 decimal(14,2)
 )
declare
 @WyplataId int,
 @WyplataROR decimal(14,2)
if @_WyplataId <> 0
declare WYPLATY cursor local fast_forward for
 select wpl_wplid from cdn.wyplaty where wpl_wplid = @_WyplataId and wpl_tryb <> 2 and wpl_tryb <> 1
else
declare WYPLATY cursor local fast_forward for
 select wpl_wplid from cdn.wyplaty where wpl_lplid = @_ListaPlacId and wpl_tryb <> 2 and wpl_tryb <> 1
 open WYPLATY
    while (1=1)
  begin
   fetch next from WYPLATY into @WyplataId
   if @@fetch_status <> 0 break
  select @WyplataROR = isnull(sum(bzd_kwotasys * bzd_kierunek), 0) * (-1)
   from cdn.bnkzdarzenia join cdn.formyplatnosci on bzd_fplid = fpl_fplid
   where fpl_typ = 2 and bzd_dokumenttyp = 8 and bzd_dokumentid = @WyplataId and BZd_KomornikZajecieWynagr <= 0
  set @ROR = @ROR + @WyplataROR
  declare
   @ElementId int,
   @TypSkladnikaId int,
   @ElementWartosc decimal(14,2),@ElementSklEmerPrac decimal(14,2),@ElementSklRentPrac decimal(14,2),@ElementSklChorPrac decimal(14,2),
   @ElementSklWypadPrac decimal(14,2), @ElementKoszty decimal(14,2),@ElementKoszty50 decimal(14,2),@ElementZalFIS decimal(14,2),
   @ElementSklZdrowPrac decimal(14,2), @ElementSklZdrowFirma decimal(14,2),@ElementSklZdrowSuma decimal(14,2), @ElementUlga decimal(14,2),
   @ElementBrutto50 decimal(14,2), @ElementNalFIS decimal(14,2),@ElementPodstEmer decimal(14,2),@ElementPodstRent decimal(14,2),
   @ElementPodstChor decimal(14,2),@ElementPodstWypad decimal(14,2),@ElementPodstZdrow decimal(14,2),@ElementPodstFP decimal(14,2),
   @ElementPodstFGSP decimal(14,2),@ElementPodstFEP decimal(14,2), @ElementSklEmerFirma decimal(14,2), @ElementSklRentFirma decimal(14,2),
   @ElementSklChorFirma decimal(14,2), @ElementSklWypadFirma decimal(14,2),@ElementSklFP decimal(14,2),@ElementSklFGSP decimal(14,2),
   @ElementSklFEP decimal(14,2),@ElementPrzychod50 decimal(14,2),@Przychod50 decimal(14,2),
   @ElementPodstPPK decimal(14,2), @ElementSklPPKPrac1 decimal(14,2), @ElementSklPPKPrac2 decimal(14,2), @ElementSklPPKFirma1 decimal(14,2), @ElementSklPPKFirma2 decimal(14,2)
  declare ELEMENTY cursor local fast_forward for
   select
    wpe_wpeid,
    wpe_twpid,
    isnull(wpe_wartosc, 0),isnull(wpe_sklemerprac, 0), isnull(wpe_sklrentprac, 0), isnull(wpe_sklchorprac, 0), isnull(wpe_sklwypadprac, 0),
    isnull(wpe_koszty, 0), isnull(wpe_koszty50, 0),isnull(wpe_zalfis, 0), isnull(wpe_sklzdrowprac, 0),isnull(wpe_sklzdrowfirma, 0),
    isnull(wpe_sklzdrowsuma, 0),isnull(wpe_ulga, 0),isnull(wpe_brutto50, 0),isnull(wpe_nalfis, 0),isnull(wpe_podstemer, 0),
    isnull(wpe_podstrent, 0),isnull(wpe_podstchor, 0),isnull(wpe_podstwypad, 0),isnull(wpe_podstzdrow, 0),isnull(wpe_podstfp, 0),
    isnull(wpe_podstfgsp, 0),isnull(wpe_podstfep, 0),isnull(wpe_sklemerfirma, 0),isnull(wpe_sklrentfirma, 0),isnull(wpe_sklchorfirma, 0),
    isnull(wpe_sklwypadfirma, 0),isnull(wpe_sklfp, 0),isnull(wpe_sklfgsp, 0),isnull(wpe_sklfep, 0), isnull(wpe_przychod50, 0),
    isnull(wpe_podstppk, 0), isnull(wpe_sklppkprac1, 0), isnull(wpe_sklppkprac2, 0), isnull(wpe_sklppkfirma1, 0), isnull(wpe_sklppkfirma2, 0)
   from cdn.wypelementy
   where wpe_wplid = @WyplataId
   open ELEMENTY
      while (1=1)
    begin
     fetch next from ELEMENTY into
     @ElementId, @TypSkladnikaId, @ElementWartosc,@ElementSklEmerPrac,@ElementSklRentPrac,@ElementSklChorPrac,@ElementSklWypadPrac,
     @ElementKoszty, @ElementKoszty50,@ElementZalFIS,@ElementSklZdrowPrac,@ElementSklZdrowFirma, @ElementSklZdrowSuma,@ElementUlga,
     @ElementBrutto50,@ElementNalFIS,@ElementPodstEmer,@ElementPodstRent,@ElementPodstChor,@ElementPodstWypad, @ElementPodstZdrow,
     @ElementPodstFP,@ElementPodstFGSP,@ElementPodstFEP,@ElementSklEmerFirma,@ElementSklRentFirma,@ElementSklChorFirma,
     @ElementSklWypadFirma,@ElementSklFP,@ElementSklFGSP,@ElementSklFEP,@ElementPrzychod50,
     @ElementPodstPPK, @ElementSklPPKPrac1, @ElementSklPPKPrac2, @ElementSklPPKFirma1, @ElementSklPPKFirma2
     if @@fetch_status <> 0 break
     declare
     @TypWskaznik int,
     @TypPozycjaPITId int,
     @TypPozycjaZUSId int,
     @TypWchodziDoWyplaty int,
     @TypZasadnicze int,
     @TypRodzajZrodla int,
     @TypRodzajFIS int,
     @TypZasilek int,
     @PITKod NVARCHAR(40),
     @TypStandardowy int,
     @TypWaluty int,
     @ZUSKod NVARCHAR(40)
     select
     @TypWskaznik = TWP_Wskaznik,
     @TypPozycjaPITId = TWP_PdpId,
     @TypPozycjaZUSId = TWP_PdzId,
     @TypWchodziDoWyplaty = TWP_WchodziDoWyplaty,
     @TypZasadnicze = TWP_Zasadnicze,
     @TypRodzajZrodla = TWP_RodzajZrodla,
     @TypRodzajFIS = TWP_RodzajFIS,
     @TypStandardowy = TWP_Standardowy,
     @TypWaluty = TWP_TypWaluty
     from cdn.typwyplata
     where twp_twpid = @TypSkladnikaId
     select
     @PITKod = PDP_Kod
     from cdn.pozdeklpit
     where pdp_pdpid = @TypPozycjaPITId
     select
     @ZUSKod = PDZ_Kod
     from cdn.pozdeklzus
     where pdz_pdzid = @TypPozycjaZUSId
     set @TypZasilek = 0
     if (@ZUSKod >= 10 and @ZUSKod <= 14) or (@ZUSKod >= 211 and @ZUSKod <= 216) or (@ZUSKod >= 311 and @ZUSKod <= 320)
     or @ZUSKod = 321 or @ZUSKod = 322 or @ZUSKod = 323 or @ZUSKod = 324 or @ZUSKod = 325 or @ZUSKod = 326 or @ZUSKod = 327 or @ZUSKod = 328 or @ZUSKod = 332 or @ZUSKod = 334 or @ZUSKod = 336 or @ZUSKod = 338
     set @TypZasilek = 1
     if @TypWskaznik > 0 continue
     if @TypStandardowy = 19 continue --stsDniPobytuLiczbaDiet
     declare @ElementWaluta tinyint
     set @ElementWaluta = 0
     if(@TypWaluty > 0)
     set @ElementWaluta = 1
    if(@ElementWaluta > 0  and (@TypStandardowy = 3 or @TypStandardowy = 6 or @TypStandardowy = 7 or @TypStandardowy = 8 or @TypStandardowy = 9 or @TypStandardowy = 10 or @TypStandardowy = 26 or @TypStandardowy = 27 or @TypStandardowy = 28
     or @TypStandardowy = 11 or @TypStandardowy = 12 or @TypStandardowy = 505 or @TypStandardowy = 506 or @TypStandardowy = 513 or @TypStandardowy = 514))
    begin
     if(@Oddelegowani <= 0)
      set @ElementWaluta = 0
    end
    declare @PodstawaWaluta tinyint
    set @PodstawaWaluta = 0
    if(@TypStandardowy in (15, 16, 17, 18, 20, 21, 22, 23))
     set @PodstawaWaluta = 1
    if(@PodstawaWaluta = 0)
     begin
      if @TypWchodziDoWyplaty <= 0
        set @WplywaNaGotowke = @WplywaNaGotowke + @ElementWartosc
     end
    if(@PodstawaWaluta = 0)
     set @Brutto = @Brutto + @ElementWartosc
    declare @StandardowyPodatekPPK tinyint
     set @StandardowyPodatekPPK = 0
    if(@TypStandardowy in (40, 41, 42, 43, 44))
      set @StandardowyPodatekPPK = 1
    if(@StandardowyPodatekPPK > 0)
     set @DodOpod = @DodOpod + @ElementWartosc
    set @SklZUS = @SklZUS + @ElementSklEmerPrac + @ElementSklRentPrac + @ElementSklChorPrac + @ElementSklWypadPrac
    set @Koszty = @Koszty + @ElementKoszty + @ElementKoszty50
    set @ZalPod = @ZalPod + @ElementZalFIS + @ElementSklZdrowPrac + @ElementSklZdrowSuma
    set @SklPPK = @SklPPK + @ElementSklPPKPrac1 + @ElementSklPPKPrac2
    set @Przychod50 = @ElementPrzychod50
    if(@PodstawaWaluta <= 0)
     begin
      if(@StandardowyPodatekPPK <= 0)
      begin
       if @TypZasadnicze <> 0 or @TypRodzajZrodla = 18 /*RodzajZrodlaEnum.rzAkord*/
        set @Zasadnicze = @Zasadnicze + @ElementWartosc
      end
     end
          if (@TypStandardowy = 17 or @TypStandardowy = 18)
                    set @SumaOpodat = @SumaOpodat + @ElementWartosc
    if(@StandardowyPodatekPPK > 0 and @TypStandardowy <> 44)
     set @SumaOpodat = @SumaOpodat + @ElementWartosc
    if(@PodstawaWaluta <= 0)
     begin
      if @TypRodzajFIS <> 1 /*RodzajFISEnum.rfBrak*/
       begin
        if cdn.UmowaRyczalt(@TypSkladnikaId) <= 0
         set @PodstZdrowOpodat = @PodstZdrowOpodat + @ElementPodstZdrow
        if @TypZasilek = 0
         begin
          if (@TypZasadnicze = 0)-- or @TypRodzajZrodla = 6 /*RodzajZrodlaEnum.rzRozlNieobecnosci*/) and @TypRodzajZrodla <> 18 /*RodzajZrodlaEnum.rzAkord*/
           begin
            if @ElementWartosc >= 0
             begin
              if len(@PITKod) >= 9
               set @PITKod = substring(@PITKod, 0, 10)
              if @TypRodzajZrodla = 3 /*RodzajZrodlaEnum.rzNocne*/
               set @NadgodzNocDoplata = @NadgodzNocDoplata + @ElementWartosc
              if @TypStandardowy = 6 or @TypStandardowy = 26 /*stsNadgodziny50, stsNadgodziny50S*/
               set @Nadgodz50 = @Nadgodz50 + @ElementWartosc
              if @TypStandardowy = 7 or @TypStandardowy = 8 or @TypStandardowy = 27 or @TypStandardowy = 28 /*stsNadgodziny100, stsNadgodzinySw, stsNadgodziny100S, stsNadgodzinySrednioTygodniowe*/
               set @Nadgodz100 = @Nadgodz100 + @ElementWartosc
              if @TypRodzajZrodla = 3 or @TypStandardowy = 6 or @TypStandardowy = 7 or @TypStandardowy = 8 or @TypStandardowy = 26 or @TypStandardowy = 27 or @TypStandardowy = 8 or @TypStandardowy = 28
               declare @empty int
              else
               begin
                if @PITKod = 'PIT- 4 44' or @PITKod = 'PIT- 4 45' or @PITKod = 'PIT- 4 46' or @PITKod = 'PIT- 4 47' or @PITKod = 'PIT- 4 48'
                 set @Korekta = @Korekta + @ElementWartosc
                else
                 set @DodOpod = @DodOpod + @ElementWartosc
               end
             end
           end
          if @TypZasadnicze = 0 or @TypRodzajZrodla = 6 /*RodzajZrodlaEnum.rzRozlNieobecnosci*/
           begin
            if @ElementWartosc < 0
             begin
              if len(@PITKod) > 7 and substring(@PITKod, 0, 8) = 'PIT- 4 6'
               set @Korekta = @Korekta + @ElementWartosc
              else
               set @PotrOpod = @PotrOpod + @ElementWartosc
             end
           end
         end
         if @TypZasilek <> 0
         begin
          if (@ZUSKod = '311' or @ZUSKod = '312' or @ZUSKod = '313' or @ZUSKod = '314' or @ZUSKod = '315' or @ZUSKod = '316' or @ZUSKod = '311' or @ZUSKod = '317' or @ZUSKod = '318' or @ZUSKod = '319' or @ZUSKod = '320' or @ZUSKod = '321' or @ZUSKod = '322' or @ZUSKod = '323' or @ZUSKod = '324' or @ZUSKod = '325' or @ZUSKod = '326' or @ZUSKod = '327' or @ZUSKod = '328')
           set @ZasNieobOpod = @ZasNieobOpod + @ElementWartosc
          if (@ZUSKod = '212' or @ZUSKod = '214' or @ZUSKod = '215' or @ZUSKod = '216')
           set @ZasOpod = @ZasOpod + @ElementWartosc
         end
         if(@ElementWaluta <= 0 and @StandardowyPodatekPPK <= 0)
          set @SumaOpodat = @SumaOpodat + @ElementWartosc
       end
      else if @TypRodzajFIS = 1
       begin
        if @TypStandardowy = 454
         begin
          set @ZasNieobNieOpod = @ZasNieobNieOpod + @ElementWartosc
         end
        else
        begin
         if @TypZasilek = 0
          begin
           if @TypZasadnicze = 0 or @TypRodzajZrodla = 6 /*RodzajZrodlaEnum.rzRozlNieobecnosci*/
            begin
             if(@ElementWartosc > 0)
             begin
              if(@TypStandardowy = 515)
              begin
               set @PodstZdrowOpodat = @PodstZdrowOpodat + @ElementWartosc - @ElementSklEmerPrac - @ElementSklRentPrac - @ElementSklChorPrac - @ElementSklWypadPrac
              end
             end
             declare @PIT2Kod NVARCHAR(20)
             if len(@PITKod) >= 9
              set @PIT2Kod = substring(@PITKod, 0, 10)
             if len(@PITKod) > 7 and substring(@PITKod, 0, 8) = 'PIT- 4 6'
              set @Korekta = @Korekta + @ElementWartosc
             else if @PIT2Kod = 'PIT- 4 44' or @PIT2Kod = 'PIT- 4 45' or @PIT2Kod = 'PIT- 4 46' or @PIT2Kod = 'PIT- 4 47' or @PIT2Kod = 'PIT- 4 48'
              set @Korekta = @Korekta + @ElementWartosc
             else
              begin
               if @ElementWartosc >= 0
                set @DodNieOpod = @DodNieOpod + @ElementWartosc
               else
                set @PotrNieOpod = @PotrNieOpod + @ElementWartosc
              end
             set @PIT2Kod = ''
            end
          end
         else if @TypZasilek <> 0
         begin
          if @TypRodzajZrodla = 6 /*RodzajZrodlaEnum.rzRozlNieobecnosci*/
           set @ZasNieobNieOpod = @ZasNieobNieOpod + @ElementWartosc
          else if @TypRodzajZrodla <> 6 /*RodzajZrodlaEnum.rzRozlNieobecnosci*/
           set @ZasNieOpod = @ZasNieOpod + @ElementWartosc
         end
        end
        if cdn.UmowaRyczalt(@TypSkladnikaId) <= 0
         set @PodatekKosztyZUSOpodat = @PodatekKosztyZUSOpodat + @ElementSklEmerPrac + @ElementSklRentPrac + @ElementSklChorPrac + @ElementSklWypadPrac
       end
     end
     else
     begin
      if(@TypStandardowy = 22 or @TypStandardowy = 16)
       set @PodatekKosztyZUSOpodat = @PodatekKosztyZUSOpodat + @ElementSklEmerPrac + @ElementSklRentPrac + @ElementSklChorPrac + @ElementSklWypadPrac
      if(@ElementWartosc > 0)
      begin
       if(@TypStandardowy = 20 or @TypStandardowy = 23 or @TypStandardowy = 15 or @TypStandardowy = 21)
       begin
        set @PodstZdrowOpodat = @PodstZdrowOpodat + @ElementWartosc - @ElementSklEmerPrac - @ElementSklRentPrac - @ElementSklChorPrac - @ElementSklWypadPrac
       end
      end
     end
    if cdn.UmowaRyczalt(@TypSkladnikaId) > 0
     set @PodatekKosztyZUSOpodat = @PodatekKosztyZUSOpodat + @ElementSklEmerPrac + @ElementSklRentPrac + @ElementSklChorPrac + @ElementSklWypadPrac
    set @PodatekKosztyZUS = @PodatekKosztyZUS + @ElementSklEmerPrac + @ElementSklRentPrac + @ElementSklChorPrac + @ElementSklWypadPrac
    set @PodatekKoszty = @PodatekKoszty + @ElementKoszty
    set @PodatekUlga = @PodatekUlga + @ElementUlga
    set @PodatekKoszty50 = @PodatekKoszty50 + @ElementKoszty50
    set @PodatekBrutto50 = @PodatekBrutto50 + @ElementBrutto50
    set @PodatekNalFIS = @PodatekNalFIS + @ElementNalFIS
    set @PodatekZalFIS = @PodatekZalFIS + @ElementZalFIS
    set @PodatekSklZdrowPrac = @PodatekSklZdrowPrac + @ElementSklZdrowPrac
    set @PodatekSklZdrowSuma = @PodatekSklZdrowSuma + @ElementSklZdrowSuma
    set @PodatekSklZdrowPracPob = @PodatekSklZdrowPracPob + @ElementSklZdrowPrac + @ElementSklZdrowSuma
    set @PodatekSklZdrowFirma = @PodatekSklZdrowFirma + @ElementSklZdrowFirma
    set @PodatekPodstEmer = @PodatekPodstEmer + @ElementPodstEmer
    set @PodatekPodstRent = @PodatekPodstRent + @ElementPodstRent
    set @PodatekPodstChor = @PodatekPodstChor + @ElementPodstChor
    set @PodatekPodstWypad = @PodatekPodstWypad + @ElementPodstWypad
    set @PodatekPodstZdrow = @PodatekPodstZdrow + @ElementPodstZdrow
    set @PodatekPodstFP = @PodatekPodstFP + @ElementPodstFP
    set @PodatekPodstFGSP = @PodatekPodstFGSP + @ElementPodstFGSP
    set @PodatekPodstFEP = @PodatekPodstFEP + @ElementPodstFEP
    set @PodatekSklEmerPrac = @PodatekSklEmerPrac + @ElementSklEmerPrac
    set @PodatekSklEmerFirma = @PodatekSklEmerFirma + @ElementSklEmerFirma
    set @PodatekSklRentPrac = @PodatekSklRentPrac + @ElementSklRentPrac
    set @PodatekSklRentFirma = @PodatekSklRentFirma + @ElementSklRentFirma
    set @PodatekSklChorPrac = @PodatekSklChorPrac + @ElementSklChorPrac
    set @PodatekSklChorFirma = @PodatekSklChorFirma + @ElementSklChorFirma
    set @PodatekSklWypadPrac = @PodatekSklWypadPrac + @ElementSklWypadPrac
    set @PodatekSklWypadFirma = @PodatekSklWypadFirma + @ElementSklWypadFirma
    set @PodatekSumaPrac = @PodatekSumaPrac + @ElementSklEmerPrac + @ElementSklRentPrac + @ElementSklChorPrac + @ElementSklWypadPrac
    set @PodatekSumaFirma = @PodatekSumaFirma + @ElementSklEmerFirma + @ElementSklRentFirma + @ElementSklChorFirma + @ElementSklWypadFirma
    set @PodatekSklFP = @PodatekSklFP + @ElementSklFP
    set @PodatekSklFGSP = @PodatekSklFGSP + @ElementSklFGSP
    set @PodatekSklFEP = @PodatekSklFEP + @ElementSklFEP
    set @PodatekPrzychod50 = @PodatekPrzychod50 + @ElementPrzychod50
    set @PodatekPodstPPK  = @PodatekPodstPPK + @ElementPodstPPK
    set @PodatekSklPPKPrac1 = @PodatekSklPPKPrac1 + @ElementSklPPKPrac1
    set @PodatekSklPPKPrac2 = @PodatekSklPPKPrac2 + @ElementSklPPKPrac2
    set @PodatekSklPPKFirma1 = @PodatekSklPPKFirma1 + @ElementSklPPKFirma1
    set @PodatekSklPPKFirma2 = @PodatekSklPPKFirma2 + @ElementSklPPKFirma2
   end
   close ELEMENTY
  deallocate ELEMENTY
  end
  --set @PodstOpodat = @SumaOpodat - @SklZUS - @Koszty
  set @PodatekKosztyZUSOpodat = @PodatekKosztyZUS - @PodatekKosztyZUSOpodat
  set @PodstOpodat = @SumaOpodat - @PodatekKosztyZUSOpodat - @Koszty
  set @Gotowka = @Brutto - @SklZUS - @PodatekSklZdrowPrac - @PodatekSklZdrowSuma - @ROR - @WplywaNaGotowke - @PodatekZalFIS - @SklPPK
  set @Razem = @ROR + @Gotowka
 close WYPLATY
deallocate WYPLATY
insert into @ZESTXYZ
 (Brutto,DodNieOpod ,DodOpod ,Korekta ,Koszty ,Nadgodz100 ,Nadgodz50 ,NadgodzNocDoplata ,PotrNieOpod ,PotrOpod ,SklZUS, SklPPK ,ZalPod ,Zasadnicze ,
    ZasNieobNieOpod ,ZasNieobOpod ,ZasNieOpod ,ZasOpod ,SumaOpodat ,PodstOpodat ,WplywaNaGotowke , PodatekKosztyZUS ,PodatekKoszty ,PodatekUlga ,
    PodatekKoszty50 , PodatekBrutto50 ,PodatekNalFIS ,PodatekZalFIS ,PodatekSklZdrowPrac ,PodatekSklZdrowSuma ,PodatekSklZdrowPracPob ,PodatekSklZdrowFirma ,
    PodatekPodstEmer ,PodatekPodstRent ,PodatekPodstChor , PodatekPodstWypad ,PodatekPodstZdrow ,PodatekPodstFP ,PodatekPodstFGSP ,PodatekPodstFEP ,
    PodatekSklEmerPrac ,PodatekSklEmerFirma ,PodatekSklRentPrac ,PodatekSklRentFirma ,PodatekSklChorPrac ,PodatekSklChorFirma ,PodatekSklWypadPrac ,
    PodatekSklWypadFirma ,PodatekSumaPrac ,PodatekSumaFirma ,PodatekSklFP ,PodatekSklFGSP ,PodatekSklFEP ,ROR ,Gotowka ,Razem,PodatekPrzychod50,PodatekKosztyZUSOpodat, PodstZdrowOpodat,
 PodatekPodstPPK, PodatekSklPPKPrac1, PodatekSklPPKPrac2, PodatekSklPPKFirma1, PodatekSklPPKFirma2)
values
 (isnull(@Brutto,0),isnull(@DodNieOpod ,0),isnull(@DodOpod ,0),isnull(@Korekta ,0),isnull(@Koszty ,0),isnull(@Nadgodz100 ,0),
 isnull(@Nadgodz50 ,0),isnull(@NadgodzNocDoplata ,0),isnull(@PotrNieOpod ,0),isnull(@PotrOpod ,0),isnull(@SklZUS ,0),isnull(@SklPPK ,0),isnull(@ZalPod ,0),isnull(@Zasadnicze ,0),
    isnull(@ZasNieobNieOpod ,0),isnull(@ZasNieobOpod ,0),isnull(@ZasNieOpod ,0),isnull(@ZasOpod ,0),isnull(@SumaOpodat ,0),isnull(@PodstOpodat ,0),
 isnull(@WplywaNaGotowke ,0), isnull(@PodatekKosztyZUS ,0), isnull(@PodatekKoszty ,0), isnull(@PodatekUlga ,0),
    isnull(@PodatekKoszty50 ,0),isnull(@PodatekBrutto50 ,0),isnull(@PodatekNalFIS ,0),isnull(@PodatekZalFIS ,0),isnull(@PodatekSklZdrowPrac ,0),
 isnull(@PodatekSklZdrowSuma ,0),isnull(@PodatekSklZdrowPracPob ,0), isnull(@PodatekSklZdrowFirma ,0),
    isnull(@PodatekPodstEmer ,0),isnull(@PodatekPodstRent ,0), isnull(@PodatekPodstChor ,0), isnull(@PodatekPodstWypad ,0), isnull(@PodatekPodstZdrow ,0),
 isnull(@PodatekPodstFP ,0), isnull(@PodatekPodstFGSP ,0), isnull(@PodatekPodstFEP ,0),
    isnull(@PodatekSklEmerPrac ,0),isnull(@PodatekSklEmerFirma ,0), isnull(@PodatekSklRentPrac ,0),isnull(@PodatekSklRentFirma ,0),isnull(@PodatekSklChorPrac ,0),
 isnull(@PodatekSklChorFirma ,0),isnull(@PodatekSklWypadPrac ,0),
    isnull(@PodatekSklWypadFirma ,0),isnull(@PodatekSumaPrac ,0),isnull(@PodatekSumaFirma ,0), isnull(@PodatekSklFP ,0),isnull(@PodatekSklFGSP ,0),
 isnull(@PodatekSklFEP ,0), isnull(@ROR ,0), isnull(@Gotowka ,0), isnull(@Razem,0),isnull(@PodatekPrzychod50 ,0),isnull(@PodatekKosztyZUSOpodat ,0),isnull(@PodstZdrowOpodat, 0),
 isnull(@PodatekPodstPPK, 0), isnull(@PodatekSklPPKPrac1, 0), isnull(@PodatekSklPPKPrac2, 0), isnull(@PodatekSklPPKFirma1, 0), isnull(@PodatekSklPPKFirma2, 0))
select * from  @ZESTXYZ
set nocount off
