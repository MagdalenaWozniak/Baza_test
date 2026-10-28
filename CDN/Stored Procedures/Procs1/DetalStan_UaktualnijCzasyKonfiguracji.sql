CREATE PROCEDURE [CDN].[DetalStan_UaktualnijCzasyKonfiguracji]
@type tinyint,
@posId int,
@DateTSSynchrNew datetime
AS
BEGIN
SET NOCOUNT ON
IF @type = 1
BEGIN
 UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroTwr = @DateTSSynchrNew
  WHERE DSKnf_StanDetalID = @posId
END
ELSE IF @type = 2
BEGIN
 UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroKnt = @DateTSSynchrNew
  WHERE DSKnf_StanDetalID = @posId
END
ELSE
BEGIN
 UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_Synchro = @DateTSSynchrNew
  WHERE DSKnf_StanDetalID = @posId
END
SET NOCOUNT OFF
END
