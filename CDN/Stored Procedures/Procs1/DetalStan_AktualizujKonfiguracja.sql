CREATE PROCEDURE [CDN].[DetalStan_AktualizujKonfiguracja]
    @StanDetalID int,
    @NazwaStanowiska NVARCHAR(50),
    @NumeracjaPA NVARCHAR(50),
    @NumeracjaFS NVARCHAR(50),
    @NumeracjaKP NVARCHAR(50),
    @NumeracjaKW NVARCHAR(50),
    @NumeracjaPKA NVARCHAR(50),
    @NumeracjaPAKor NVARCHAR(50),
    @NumeracjaFSKor NVARCHAR(50),
    @Oddzial TINYINT
AS
SET NOCOUNT ON
DECLARE
  @DSKnf_DSKnfID INT
  SELECT @DSKnf_DSKnfID = DSKnf_DSKnfID
    FROM CDN.DetalStanKonfiguracja
    WHERE DSKnf_StanDetalID = @StanDetalID
  IF @DSKnf_DSKnfID IS NULL
    BEGIN
       INSERT INTO CDN.DetalStanKonfiguracja(
        [DSKnf_StanDetalID],
        [DSKnf_NazwaStanowiska],
        [DSKnf_TS_Synchro],
        [DSKnf_TS_SynchroTwr],
        [DSKnf_TS_SynchroKnt],
        [DSKnf_TS_SynchroTraNag],
        [DSKnf_TS_SynchroZapisKB],
        [DSKnf_TS_SynchroImportKnt],
        [DSKnf_TS_SynchroOpak],
        [DSKnf_NumeracjaPA],
        [DSKnf_NumeracjaFS],
        [DSKnf_NumeracjaKP],
        [DSKnf_NumeracjaKW],
        [DSKnf_NumeracjaPKA],
        [DSKnf_NumeracjaPAKor],
        [DSKnf_NumeracjaFSKor],
        [DSKnf_Oddzial]
         )
  VALUES (
         @StanDetalID,
         @NazwaStanowiska,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         @NumeracjaPA,
         @NumeracjaFS,
         @NumeracjaKP,
         @NumeracjaKW,
         @NumeracjaPKA,
         @NumeracjaPAKor,
         @NumeracjaFSKor,
         @Oddzial)
    END
  ELSE
 BEGIN
     UPDATE  CDN.DetalStanKonfiguracja
   SET
            DSKnf_NazwaStanowiska = @NazwaStanowiska
           ,DSKnf_NumeracjaPA = @NumeracjaPA
           ,DSKnf_NumeracjaFS = @NumeracjaFS
           ,DSKnf_NumeracjaKP = @NumeracjaKP
           ,DSKnf_NumeracjaKW = @NumeracjaKW
           ,DSKnf_NumeracjaPKA = @NumeracjaPKA
           ,DSKnf_NumeracjaPAKor = @NumeracjaPAKor
           ,DSKnf_NumeracjaFSKor = @NumeracjaFSKor
           ,DSKnf_Oddzial = @Oddzial
  WHERE @DSKnf_DSKnfID = DSKnf_DSKnfID
      END
  SET NOCOUNT OFF
