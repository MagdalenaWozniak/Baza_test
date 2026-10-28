CREATE FUNCTION [CDN].[fnTrnStatusString] (@TypDokumentu INT, @StatusInt INT)
RETURNS NVARCHAR(10)
AS
BEGIN
 DECLARE @Wynik NVARCHAR(10),
 @Wart1        INT,
 @Wart2        INT,
 @Wart3        INT,
 @Wart4        INT
if @StatusInt<> 0
begin
   SELECT   @Wart1   =  @StatusInt & 1
           ,@Wart2   = (@StatusInt & 2) / 2
           ,@Wart3   = (@StatusInt & 4) / 4
           ,@Wart4   = (@StatusInt & 8) / 8
    IF (@TypDokumentu = 301 or @TypDokumentu = 322) and @Wart1 = 1
  SET @Wynik = 'W'
    IF @Wart3 = 1
    BEGIN
     if @TypDokumentu = 305 and @Wart1 = 1
          SET @Wynik = 'X WZ'
     else
          SET @Wynik = 'WZ'
    END
    ELSE
     if @TypDokumentu = 305 and @Wart1 = 1
          SET @Wynik = 'X'
    if (@TypDokumentu = 306 or  @TypDokumentu = 302) and @Wart1 = 1
          SET @Wynik = 'PF'
    if @Wart1 = 1 and @TypDokumentu in (305,320)
  SET @Wynik = 'FS'
end
 RETURN @Wynik
END
/*
CREATE FUNCTION CDN.fn_TrnStatusString (@TrNId INT)
RETURNS NVARCHAR(10)
AS
BEGIN
 DECLARE @Wynik NVARCHAR(10)
 DECLARE @TrNTyp INT, @TrNRodzaj INT
 DECLARE SKOJARZONE CURSOR FAST_FORWARD FOR
   SELECT TrN_TypDokumentu ,TrN_Rodzaj  from cdn.tranag
   JOIN cdn.TraNagRelacje REL on TrN_TrNId = REL.TrR_TrNId
   where REL.TrR_FaID = @TrNId and TrN_Bufor <> -1
 SET @Wynik = ''
  OPEN SKOJARZONE
    WHILE 1 = 1
    BEGIN
      FETCH NEXT FROM SKOJARZONE INTO @TrNTyp, @TrNRodzaj
      IF @@FETCH_STATUS <> 0 BREAK
      IF @TrNTyp = 321 OR @TrNTyp = 322
        SET @Wynik = 'W'
      IF @TrNTyp = 345
        SET @Wynik = 'X'
      IF @TrNTyp = 306 AND @TrNRodzaj<>306071 AND @TrNRodzaj<>306072
  IF @Wynik<>'' AND @Wynik<>'WZ'
          SET @Wynik = @Wynik + ' WZ'
  ELSE
     SET @Wynik = 'WZ'
    END
    CLOSE SKOJARZONE
   SET @TrNTyp = 0
   SELECT @TrNTyp = A.Trn_TypDokumentu, @TrNRodzaj = B.Trn_Rodzaj FROM Cdn.TraNag A
          LEFT OUTER JOIN cdn.TraNagRelacje REL on A.TrN_TrNId = REL.TrR_TrNId
          LEFT OUTER JOIN Cdn.TraNag B ON B.Trn_TrNId = REL.TrR_FaId
          WHERE B.Trn_TrnId = @TrNId AND A.TrN_Bufor <> -1 AND B.TrN_Bufor <> -1 AND A.TrN_Rodzaj <> 302200
    IF @TrNTyp = 320
        SET @Wynik = 'PF'
    IF @TrNTyp = 302 AND @TrNRodzaj<>306061
        SET @Wynik = 'FS'
 RETURN @Wynik
END
*/
