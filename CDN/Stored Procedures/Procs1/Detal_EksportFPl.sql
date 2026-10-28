CREATE PROCEDURE [CDN].[Detal_EksportFPl]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
DECLARE
   @OptimaId int
  ,@Nazwa nvarchar(20)
  ,@NieAktywny smallint
  ,@Domyslna   tinyint
  ,@Gotowka    tinyint
  ,@TypGotowka tinyint
  ,@Termin    smallint
  ,@KartyJakoGotowka smallint
  ,@BnkNazwa NVARCHAR(50)
  ,@RachunekNr NVARCHAR(51)
  ,@TerminalPlatniczy smallint
if exists (select fir_numer from cdn.firma where fir_numer =  1587 and fir_wartosc = 1) select @KartyJakoGotowka =1  else select @KartyJakoGotowka =0
select @DateTSSynchr = GetDate()
if @CzyTaSamaBaza = 1
BEGIN
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  SELECT
    DFPl_FPlId as FPl_OptimaId,
    DFPl_NazwaDetal as FPl_Nazwa,
    FPl_Nieaktywny,
    DFPl_Domyslna,
    (case when (FPl_Typ = 1 and FPl_Termin = 0) or (FPl_Typ = 3 and @KartyJakoGotowka =1 and FPl_Termin = 0)then 1 else 0 end) as DFPl_Gotowka,
     (case when FPl_Typ = 1 and FPl_Termin = 0 then 1 else 0 end )as FPl_Typ,
     FPl_Termin,
     case when Bra_typ = 2 then bna_Nazwa1 else ''end,
     case when Bra_typ = 2 then bra_RachunekNr else ''end,
  FPL_TerminalPlatniczy
   from CDN.DetalFormyPlatnosci
   left join CDN.FormyPlatnosci ON DFPl_FPlId = FPl_FPlId
   left join cdn.bnkrachunki on fpl_braid = bra_braid
   left join cdn.bnknazwy on bra_bnaid = bna_bnaid
   where Dfpl_dstaid = @ID
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
          @OptimaId
         ,@Nazwa
         ,@NieAktywny
         ,@Domyslna
         ,@Gotowka
         ,@TypGotowka
         ,@Termin
         ,@BnkNazwa
         ,@RachunekNr
   ,@TerminalPlatniczy
   IF @@FETCH_STATUS <> 0 BREAK
  exec [CDN].[DetalStan_AktualizujFormyPlatnosci]
            @OptimaId
           ,@ID
           ,@Nazwa
           ,@NieAktywny
           ,@Domyslna
           ,@Gotowka
           ,@TypGotowka
           ,@Termin
           ,@BnkNazwa
           ,@RachunekNr
     ,@TerminalPlatniczy
           ,@DateTSSynchr
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
  SELECT
    DFPl_FPlId as FPl_OptimaId,
    DFPl_NazwaDetal as FPl_Nazwa,
    FPl_Nieaktywny,
    DFPl_Domyslna,
    (case when (FPl_Typ = 1  and FPl_Termin = 0) or (FPl_Typ = 3 and @KartyJakoGotowka =1) then 1 else 0 end) as DFPl_Gotowka,
    (case when FPl_Typ = 1 then 1 else 0 end )as FPl_Typ,
    FPl_Termin,
     case when Bra_typ = 2 then bna_Nazwa1 else ''end,
     case when Bra_typ = 2 then bra_RachunekNr else ''end,
    @DateTSSynchr
   from CDN.DetalFormyPlatnosci
   left join CDN.FormyPlatnosci ON DFPl_FPlId = FPl_FPlId
   left join cdn.bnkrachunki on fpl_braid = bra_braid
   left join cdn.bnknazwy on bra_bnaid = bna_bnaid
SET NOCOUNT OFF
