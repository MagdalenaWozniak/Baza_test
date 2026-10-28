CREATE  PROCEDURE [CDN].[Detal_EksportKonfiguracja]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
DECLARE
@DDF_NumeracjaPA         NVARCHAR(50),
@DDF_NumeracjaFS         NVARCHAR(50),
@DDF_NumeracjaPAKor      NVARCHAR(50),
@DDF_NumeracjaFSKor      NVARCHAR(50),
@SymbolPA                NVARCHAR(20),
@SymbolFS                NVARCHAR(20),
@SymbolPAKor             NVARCHAR(20),
@SymbolFSKor             NVARCHAR(20),
@DDF_NumeracjaKP         NVARCHAR(50),
@DDF_NumeracjaKW         NVARCHAR(50),
@SymbolKP                NVARCHAR(20),
@SymbolKW                NVARCHAR(20),
@DDF_NumeracjaPKA        NVARCHAR(50),
@SymbolPKA               NVARCHAR(20),
--@RokKal                INT,
@Miesiac               CHAR(2),
--@RokObr                NVARCHAR(5),
@Rejestr               NVARCHAR(20),
@Magazyn               NVARCHAR(5),
@NazwaStanowiska       NVARCHAR(50),
@Komunikat             NVARCHAR(255),
@Oddzial    TINYINT
select @Magazyn =  Mag_Rejestr,@Rejestr = DSta_Seria,
       @SymbolPA = A.DDf_Symbol, @DDF_NumeracjaPA = A.DDf_Numeracja ,
       @SymbolFS = B.DDf_Symbol, @DDF_NumeracjaFS = B.DDf_Numeracja ,
       @SymbolKP = C.DDf_Symbol, @DDF_NumeracjaKP = C.DDf_Numeracja ,
       @SymbolKW = D.DDf_Symbol , @DDF_NumeracjaKW = D.DDf_Numeracja,
       @SymbolPKA = ISNULL(E.DDf_Symbol,'') , @DDF_NumeracjaPKA = ISNULL(E.DDf_Numeracja,''),
       @SymbolPAKor = ISNULL(F.DDf_Symbol,'') , @DDF_NumeracjaPAKor = ISNULL(F.DDf_Numeracja,''),
       @SymbolFSKor = ISNULL(G.DDf_Symbol,'') , @DDF_NumeracjaFSKor = ISNULL(G.DDf_Numeracja,''),
       @NazwaStanowiska = DSta_Nazwa
 from cdn.detalstanowiska
join cdn.dokdefinicje A on dsta_ddfIdPa= A.DDf_DDfId
join cdn.dokdefinicje B on dsta_ddfIdFS= B.DDf_DDfId
join cdn.dokdefinicje C on dsta_ddfIdKP= C.DDf_DDfId
join cdn.dokdefinicje D on dsta_ddfIdKW= D.DDf_DDfId
left join cdn.dokdefinicje E on dsta_ddfIdPKA= E.DDf_DDfId
left join cdn.dokdefinicje F on dsta_ddfIdPAKor = F.DDf_DDfId
left join cdn.dokdefinicje G on dsta_ddfIdFSKor = G.DDf_DDfId
join cdn.magazyny on DSta_MagID = Mag_MagID
where DSta_DStaId = @ID
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@symbol' , @SymbolPA  )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@symbol' , @SymbolFS  )
  SET @DDF_NumeracjaPAKor    = REPLACE ( @DDF_NumeracjaPAKor, '@symbol' , @SymbolPAKor  )
  SET @DDF_NumeracjaFSKor    = REPLACE ( @DDF_NumeracjaFSKor, '@symbol' , @SymbolFSKor  )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@rejestr', @Rejestr )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@rejestr', @Rejestr )
  SET @DDF_NumeracjaPAKor    = REPLACE ( @DDF_NumeracjaPAKor, '@rejestr', @Rejestr )
  SET @DDF_NumeracjaFSKor    = REPLACE ( @DDF_NumeracjaFSKor, '@rejestr', @Rejestr )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@brak/'  , ''       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@brak/'  , ''       )
  SET @DDF_NumeracjaPAKor    = REPLACE ( @DDF_NumeracjaPAKor, '@brak/'  , ''       )
  SET @DDF_NumeracjaFSKor    = REPLACE ( @DDF_NumeracjaFSKor, '@brak/'  , ''       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '/@brak'  , ''       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '/@brak'  , ''       )
  SET @DDF_NumeracjaPAKor    = REPLACE ( @DDF_NumeracjaPAKor, '/@brak'  , ''       )
  SET @DDF_NumeracjaFSKor    = REPLACE ( @DDF_NumeracjaFSKor, '/@brak'  , ''       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@magazyn', @Magazyn )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@magazyn', @Magazyn )
  SET @DDF_NumeracjaPAKor    = REPLACE ( @DDF_NumeracjaPAKor, '@magazyn', @Magazyn )
  SET @DDF_NumeracjaFSKor    = REPLACE ( @DDF_NumeracjaFSKor, '@magazyn', @Magazyn )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@symbol' , @SymbolKW  )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@symbol' , @SymbolKP  )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@rejestr', @Rejestr )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@rejestr', @Rejestr )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@brak/'  , ''       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@brak/'  , ''       )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '/@brak'  , ''       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '/@brak'  , ''       )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@magazyn', @Magazyn )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@magazyn', @Magazyn )
  SET @DDF_NumeracjaPKA    = REPLACE ( @DDF_NumeracjaPKA, '@symbol' , @SymbolPKA  )
  SET @DDF_NumeracjaPKA    = REPLACE ( @DDF_NumeracjaPKA, '@rejestr', @Rejestr )
  SET @DDF_NumeracjaPKA    = REPLACE ( @DDF_NumeracjaPKA, '@brak/'  , ''       )
  SET @DDF_NumeracjaPKA    = REPLACE ( @DDF_NumeracjaPKA, '/@brak'  , ''       )
  SET @DDF_NumeracjaPKA    = REPLACE ( @DDF_NumeracjaPKA, '@magazyn', @Magazyn )
  --SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rok_kal', @RokKal  )
  --SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rok_obr', @RokObr  )
  --SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@miesiac', @Miesiac )
set @Oddzial = 0
if exists (select fir_wartosc from cdn.Firma where Fir_Numer = 1470 and Fir_Wartosc = 4) select @Oddzial = 1 else select @Oddzial = 0
if not exists (select DSta_DStaId from cdn.detalstanowiska where DSta_DStaId = @ID)
begin
    SET @Komunikat = 'Nie istnieje stanowisko w konfiguracji Optimy o ID = ' + convert(NVARCHAR(16),@ID)
    RAISERROR(@Komunikat, 16, 1)
    SET NOCOUNT OFF
    RETURN
end
if @CzyTaSamaBaza = 1
 exec [CDN].[DetalStan_AktualizujKonfiguracja] @ID,@NazwaStanowiska,@DDF_NumeracjaPA,@DDF_NumeracjaFS,@DDF_NumeracjaKP,@DDF_NumeracjaKW,@DDF_NumeracjaPKA,@DDF_NumeracjaPAKor,@DDF_NumeracjaFSKor,@Oddzial
else
 select DSta_DStaId, DSta_Nazwa,  @DDF_NumeracjaPA as DSta_NumeracjaPA, @DDF_NumeracjaFS as DSta_NumeracjaFS, @DDF_NumeracjaKP as DSta_NumeracjaKP, @DDF_NumeracjaKW as DSta_NumeracjaKW,
           @DDF_NumeracjaPKA as DSta_NumeracjaPKA,@DDF_NumeracjaPAKor as DSta_NumeracjaPAKor,@DDF_NumeracjaFSKor as DSta_NumeracjaFSKor,@Oddzial as Oddzial from cdn.detalstanowiska
 where DSta_DStaId = @ID
update cdn.detalstanowiska set DSta_TS_Synchro = GETDATE() where DSta_DStaId = @ID
SET NOCOUNT OFF
