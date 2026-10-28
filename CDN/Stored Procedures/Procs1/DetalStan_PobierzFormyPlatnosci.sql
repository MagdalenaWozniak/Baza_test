CREATE PROCEDURE [CDN].[DetalStan_PobierzFormyPlatnosci]
@PosId int,
@OnlyActive tinyint
AS
BEGIN
SET NOCOUNT ON
IF @OnlyActive = 1
BEGIN
 SELECT DSFPl_DSFPlId
      ,DSFPl_StanDetalID
      ,DSFPl_OptimaId
      ,DSFPl_Nazwa
      ,DSFPl_Nieaktywny
      ,DSFPl_Domyslna
      ,DSFPl_Gotowka
      ,DSFPl_TypGotowka
      ,DSFPl_Termin
      ,DSFPl_DFNr
      ,DSFPl_TS_Mod
      ,DSFPl_BnkNazwa
      ,DSFPl_RachunekNr
   ,DSFPl_TerminalPlatniczy FROM CDN.DetalStanFormyPlatnosci
  WHERE DSFPl_NieAktywny = 0 AND DSFPl_StanDetalID = @PosId
END
ELSE
BEGIN
 SELECT DSFPl_DSFPlId
      ,DSFPl_StanDetalID
      ,DSFPl_OptimaId
      ,DSFPl_Nazwa
      ,DSFPl_Nieaktywny
      ,DSFPl_Domyslna
      ,DSFPl_Gotowka
      ,DSFPl_TypGotowka
      ,DSFPl_Termin
      ,DSFPl_DFNr
      ,DSFPl_TS_Mod
      ,DSFPl_BnkNazwa
      ,DSFPl_RachunekNr
   ,DSFPl_TerminalPlatniczy FROM CDN.DetalStanFormyPlatnosci
  WHERE DSFPl_StanDetalID = @PosId
END
SET NOCOUNT OFF
END
