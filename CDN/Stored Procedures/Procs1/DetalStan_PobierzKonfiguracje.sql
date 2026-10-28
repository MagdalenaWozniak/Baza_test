CREATE PROCEDURE [CDN].[DetalStan_PobierzKonfiguracje]
@PosId int
AS
BEGIN
SET NOCOUNT ON
SELECT DSKnf_DSKnfId
      ,DSKnf_StanDetalID
      ,DSKnf_NazwaStanowiska
      ,DSKnf_TS_Synchro
      ,DSKnf_TS_SynchroTwr
      ,DSKnf_TS_SynchroKnt
      ,DSKnf_TS_SynchroTraNag
      ,DSKnf_TS_SynchroZapisKB
      ,DSKnf_TS_SynchroImportKnt
      ,DSKnf_TS_SynchroOpak
      ,DSKnf_NumeracjaPA
      ,DSKnf_NumeracjaFS
      ,DSKnf_NumeracjaKP
      ,DSKnf_NumeracjaKW
      ,DSKnf_NumeracjaPKA
      ,DSKnf_NumeracjaFSKor
      ,DSKnf_NumeracjaPAKor,DSKnf_Oddzial FROM CDN.DetalStanKonfiguracja WHERE DSKnf_StanDetalID = @PosId
SET NOCOUNT OFF
END
