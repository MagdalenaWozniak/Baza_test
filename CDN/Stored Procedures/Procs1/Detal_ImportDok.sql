CREATE PROCEDURE [CDN].[Detal_ImportDok]
  @ID INT      -- ID Detalu
AS
SET NOCOUNT ON
DECLARE
 @StanowiskoId INT,
 @SynchroImportKnt DATETIME
BEGIN
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  SELECT DSta_DStaId FROM CDN.DetalStanowiska
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
            @StanowiskoId
          IF @@FETCH_STATUS <> 0 BREAK
          if @ID < 1
          BEGIN
     UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroOptima = GETDATE() where DSKnf_StanDetalID = @StanowiskoId
     SELECT @SynchroImportKnt= DSKnf_TS_SynchroImportKnt FROM CDN.DetalStanKonfiguracja where DSKnf_StanDetalID = @StanowiskoId
     exec CDN.DetalStan_ImportKnt @StanowiskoId, @SynchroImportKnt, 1
     exec CDN.DetalStan_ImportTraNag @StanowiskoId, 0, 1
     exec CDN.DetalStan_ImportTraElem @StanowiskoId, 0, 1
     exec CDN.DetalStan_ImportPlatnosciDokumentu @StanowiskoId, 0, 1
     exec CDN.DetalStan_ImportZapisyKB @StanowiskoId, 0, 1
          END
          else
          BEGIN
             if @ID = @StanowiskoId
             BEGIN
       UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroOptima = GETDATE() where DSKnf_StanDetalID = @StanowiskoId
                   SELECT @SynchroImportKnt= DSKnf_TS_SynchroImportKnt FROM CDN.DetalStanKonfiguracja where DSKnf_StanDetalID = @StanowiskoId
                   exec CDN.DetalStan_ImportKnt @StanowiskoId, @SynchroImportKnt, 1
                   exec CDN.DetalStan_ImportTraNag @StanowiskoId, 0, 1
                   exec CDN.DetalStan_ImportTraElem @StanowiskoId, 0, 1
                   exec CDN.DetalStan_ImportPlatnosciDokumentu @StanowiskoId, 0, 1
                   exec CDN.DetalStan_ImportZapisyKB @StanowiskoId, 0, 1
             END
          END
        END
        CLOSE Dodawane
        DEALLOCATE Dodawane
END
SET NOCOUNT OFF
