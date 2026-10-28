CREATE PROCEDURE [CDN].[DetalStan_ImportPlatnosciDokumentu]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
declare
    @DSPlDId int ,
 @DSTrNId int ,
 @DSFPlId int ,
 @Kwota decimal(15, 2) ,
 @KwotaZaplacona decimal(15, 2) ,
 @DataPlatnosci datetime,
    @Gotowka tinyint,
    @Termin datetime
if @CzyTaSamaBaza = 1
BEGIN
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  SELECT
 DSPlD_DSPlDId,
 DSPlD_DSTrNId,
 DSFpl_OptimaId,
 DSPlD_Kwota ,
 DSPlD_KwotaZaplacona ,
 DSPlD_DataPlatnosci,
    DSFPl_Gotowka,
    DSPlD_Termin
  FROM CDN.DetalStanPlatnosciDokumentu  join CDN.DetalStanFormyPlatnosci ON DSPlD_DSFplID = DSFpl_DSFplID
join CDN.DetalStanTraNag C ON DSPlD_DSTrNID = C.DSTrN_DSTrNID
join CDN.DetalTraNag X ON DSPlD_DSTrNId = X.DTrN_DSTrNID
left join CDN.DetalStanTraNag D ON C.DSTrN_FAID = D.DSTrN_DSTrNID
where C.DSTrN_Bufor = 0 and ISNULL(D.DSTrN_Bufor,0) = 0 and ISNULL(C.DSTrN_StanSynchronizacji,0) < 2  and C.DSTrN_StanDetalID = @ID
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
    @DSPlDId ,
 @DSTrNId ,
 @DSFPlId ,
 @Kwota ,
 @KwotaZaplacona ,
 @DataPlatnosci ,
    @Gotowka,
    @Termin
   IF @@FETCH_STATUS <> 0 BREAK
  EXEC CDN.Detal_AktualizujPlatnosciDokumentu
    @DSPlDId ,
 @DSTrNId ,
    @ID,
 @DSFPlId ,
 @Kwota ,
 @KwotaZaplacona ,
 @DataPlatnosci ,
    @Gotowka,
    @Termin
END
   -- po udanym update towarow ustawiamy date
   -- UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroKnt = @DateTSSynchrNew WHERE DSKnf_StanDetalID = @ID
   -- UPDATE CDN.DetalStanowiska SET DSta_TS_SynchroKnt = @DateTSSynchrNew WHERE DSta_DStaId = @ID
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
 SELECT
 DSPlD_DSPlDId,
 DSPlD_DSTrNId,
    @ID,
 DSFpl_OptimaId,
 DSPlD_Kwota ,
 DSPlD_KwotaZaplacona ,
 DSPlD_DataPlatnosci,
    DSFPl_Gotowka,
    DSPlD_Termin
  FROM CDN.DetalStanPlatnosciDokumentu  join CDN.DetalStanFormyPlatnosci ON DSPlD_DSFplID = DSFpl_DSFplID
join CDN.DetalStanTraNag C ON DSPlD_DSTrNID = C.DSTrN_DSTrNID
join CDN.DetalTraNag X ON DSPlD_DSTrNId = X.DTrN_DSTrNID
left join CDN.DetalStanTraNag D ON C.DSTrN_FAID = D.DSTrN_DSTrNID
where C.DSTrN_Bufor = 0 and ISNULL(D.DSTrN_Bufor,0) = 0 and ISNULL(C.DSTrN_StanSynchronizacji,0) < 2  and C.DSTrN_StanDetalID = @ID
SET NOCOUNT OFF
