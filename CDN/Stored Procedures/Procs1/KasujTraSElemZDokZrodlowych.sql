CREATE PROCEDURE [CDN].[KasujTraSElemZDokZrodlowych]
  @TrN_TrNId   INT,          -- Id zapisywanego dokumetnu
  @TrN_Rodzaj  INT,          -- Rodzaj zapisywanego dokumentu
  @TrR_FaId    INT           -- FaId zapisywanego dokumentu
AS
  SET NOCOUNT ON
  DECLARE
    @TrN_TrNId_Old INT,
    @TrN_TrNId_PAdoFA_Old INT,
    @TrN_NumerPelny NVARCHAR(31),
    @TrS_TrEId_K INT,
    @Komunikat NVARCHAR(255)
  DECLARE @TraSElemP TABLE ( TrS_TrSId INT )
  DECLARE @TraSElemK TABLE ( TrS_TrSId INT, TrS_TrEId  INT )
-- 9.00 w triggerze elementowym teraz jest wywołowyana procedura dla wszystkich potrzebnych rodzajów elementów
--  IF  @TrN_Rodzaj NOT IN ( 306004, 306006, /*306005, 306007, */ 307004, /*307005,*/ 306008 )
  IF  @TrN_Rodzaj NOT IN ( 306004, 306006, 306005, 306007,  307004, 307005, 306008, 306010 )
    RETURN
  -- TrN_TrNId dokumnetu pierwotnego
  SET @TrN_TrNId_Old = @TrR_FaId
  -- przypadek szczególny - FA z PA nie przechodzi przez 302006, tylko od razu dostaje 302004
  SET @TrN_TrNId_PAdoFA_Old = (
                                 SELECT
                                   ISNULL(TrR_FaId,0)
                                   FROM CDN.TraNagRelacje WHERE
                                   TrR_TrNTyp = 302 AND
                                   TrR_FATyp = 305 AND
                                   TrR_TrNId =  @TrN_TrNId_Old
                                 /*FROM CDN.TraNag FA JOIN CDN.TraNag PA ON
                                       PA.TrN_FaId  = FA.TrN_TrNId
                                   AND PA.TrN_TrNId = FA.TrN_FaId
                                   AND PA.TrN_TypDokumentu = 305
                                   AND FA.TrN_TypDokumentu = 302
                                 WHERE FA.TrN_TrNId = @TrN_TrNId_Old */
                               )
  -- TrS_TrSId subelementów do skasowania ( + optymalizacja 8.5 )
  DECLARE @TrN TABLE ( TrNId INT )
  INSERT INTO @TrN ( TrNId ) SELECT @TrN_TrNId_Old
   INSERT INTO @TrN ( TrNId ) SELECT
                                   ISNULL(TrR_FaId,0)
                                   FROM CDN.TraNagRelacje WHERE
                                   TrR_TrNTyp = 305 AND
                                   TrR_FATyp = 302 AND
                                   TrR_TrNId =  @TrN_TrNId_Old
  INSERT INTO @TrN ( TrNId ) SELECT TrN_TrNId FROM CDN.TraNag WHERE TrN_ZwrId in(SELECT
                                   ISNULL(TrR_FaId,0)
                                   FROM CDN.TraNagRelacje WHERE
                                   TrR_TrNTyp = 305 AND
                                   TrR_FATyp = 302 AND
                                   TrR_TrNId =  @TrN_TrNId_Old)
  INSERT INTO @TrN ( TrNId ) SELECT
                                   ISNULL(TrR_FaId,0)
                                   FROM CDN.TraNagRelacje WHERE
                                   TrR_TrNTyp = 302 AND
                                   TrR_FATyp = 305 AND
                                   TrR_TrNId =  @TrN_TrNId_Old
  INSERT INTO @TrN ( TrNId ) SELECT TrN_TrNId FROM CDN.TraNag WHERE TrN_ZwrId = @TrN_TrNId_Old
  INSERT INTO  @TraSElemP ( TrS_TrSId )
    SELECT TrS_TrSId
      FROM CDN.TraSElem
        JOIN CDN.TraElem ON TrS_TrEId = TrE_TrEId
        JOIN @TrN ON TrNId = TrE_TrNId
  -- TrS_TrSId subelementów korekcyjnych wskazujących na subelementy do skasowania
  IF EXISTS ( SELECT * FROM @TraSElemP )
    INSERT INTO  @TraSElemK ( TrS_TrSId, TrS_TrEId )
      SELECT K.TrS_TrSId, K.TrS_TrEId
        FROM @TraSElemP P
          JOIN CDN.TraSElem K WITH (INDEX = TrSZwrot) ON P.TrS_TrSId = K.TrS_ZwrId
        WHERE K.TrS_Rodzaj = 306072
  IF EXISTS ( SELECT * FROM @TraSElemK)
    BEGIN
      -- Jeśli WZKK jest zaksięgowane, to wycofujemy operację
      SELECT TOP 1 @TrN_NumerPelny = @TrN_NumerPelny
        FROM @TraSElemK
          JOIN CDN.TraElem ON TrE_TrEId = TrS_TrEId
          JOIN CDN.TraNag  ON TrN_TrNId = TrE_TrNId
        WHERE TrN_DekId IS NOT NULL
      IF @TrN_NumerPelny IS NOT NULL
        BEGIN
          --SET @Komunikat = 'Zapis niemożliwy ! Dokument korekcyjny WZKK (' + @TrN_NumerPelny + '), na którym musi zostać zmodyfikowany koszt jest już zaksięgowany ! '
    SET @Komunikat = '##OPT34420##%%NumerPelny%%=' + @TrN_NumerPelny+ '##'
          RAISERROR( @Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
      ELSE
        BEGIN
          -- Kasowanie korekcyjnych i poprawienie WZKK
          DECLARE SK CURSOR LOCAL FAST_FORWARD FOR
            SELECT TrS_TrEId FROM @TraSelemK GROUP BY TrS_TrEId
              OPEN SK
                WHILE 1=1
                  BEGIN
                    FETCH NEXT FROM SK INTO @TrS_TrEId_K
                    IF @@FETCH_STATUS <> 0 BREAK
                    DELETE FROM CDN.TraSElem WHERE TrS_TrEId = @TrS_TrEId_K
                    --EXEC CDN.AktualizujWZKK @TrS_TrEId_K
                  END
              CLOSE SK
          DEALLOCATE SK
        END
    END
  -- teraz kasowanie właściwych subelemntów z dokumentu pierwotnego (+ optymalizacja 8.5)
  DECLARE @TrS TABLE ( TrSId INT )
  INSERT INTO @TrS ( TrSId ) SELECT TrS_TrSId FROM @TraSElemP
  DELETE CDN.TraSElem FROM CDN.TraSElem JOIN @TrS ON TrS_TrSId = TrSId
  SET NOCOUNT OFF
