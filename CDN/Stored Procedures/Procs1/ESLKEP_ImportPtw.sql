CREATE PROCEDURE [CDN].[ESLKEP_ImportPtw]
  @TypChr        nvarchar(3),
  @KntIDEsklepChr                 nvarchar(11),
  @KntIDOptimaChr                 nvarchar(11),
  @StatusChr       nvarchar(11),
  @OpisChr                        nvarchar(250),
  @IDEsklepChr                    nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
  @Typ         INT,
  @KntIDEsklep                    INT,
  @KntIDOptima                    INT,
  @IDEsklep                       INT,
  @ESSID                          INT
  SELECT
    @KntIDEsklep           = CONVERT(INT,@KntIDEsklepChr),
    @IDEsklep              = CONVERT(INT,@IDEsklepChr),
    @Typ         = CONVERT(INT,@TypChr),
    @KntIDOptima          = CONVERT(INT,@KntIDOptimaChr)
  select @ESSID = ESS_ESSID from cdn.eSklepStanowiska where ESS_IdISklep = @IDEsklep
 -- kontrahenci
  if @Typ = 7
        UPDATE cdn.Kontrahenci SET
        Knt_GidNumer                 = @KntIDEsklep,
        Knt_GidFirma                 = 1,
        Knt_eSklepId                 = @ESSID
  WHERE Knt_KntId = @KntIDOptima
  if @Typ = 71
        UPDATE cdn.KntESklepyPrzedstawiciele SET
        KESP_PrzedstawicieleSklepID                 = @KntIDEsklep
  WHERE KESP_KESPId = @KntIDOptima and KESP_eSklepID = @ESSID
  if @Typ = 6
  begin
        UPDATE cdn.TraNag SET
        TRN_eSklepPaczkomatKodPaczki                 = @OpisChr
        WHERE TrN_TrNID = @KntIDOptima and ISNULL(TrN_eSklepSposobDostawyTyp,0) = 2 and CONVERT(smallint,@StatusChr) = 5
        UPDATE cdn.TraNag SET
        TrN_NrListuPrzewozowegoTypKuriera  = CONVERT(smallint,@StatusChr),
        TrN_NrListuPrzewozowego                = @OpisChr
        WHERE TrN_TrNID = @KntIDOptima and (ISNULL(TrN_eSklepSposobDostawyTyp,0) != 2 or CONVERT(smallint,@StatusChr) != 5) and TrN_NrListuPrzewozowegoTypKuriera = 0
  end
  SET NOCOUNT OFF
