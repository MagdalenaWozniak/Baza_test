CREATE PROCEDURE cdn.CrmRenumeracjaFaCyklKnt( @FcNID INT )
AS
BEGIN
 DECLARE @LP INT, @ID INT, @TypKnt INT, @lastTypKnt INT, @PodmiotTyp INT, @PodmiotId INT
 SET @LP = 0
 SET @lastTypKnt = 0
 DECLARE lista CURSOR LOCAL FAST_FORWARD FOR
 SELECT FCK_FcKId, FCK_TypKnt, FCK_PodmiotTyp, FCK_PodmiotID FROM cdn.FaCyklKnt WHERE FCK_FcNID = @FcNID ORDER BY FCK_TypKnt, FCK_LpDlaTypKnt
 OPEN lista
 WHILE (1=1)
 BEGIN
    FETCH NEXT FROM lista INTO @ID, @TypKnt, @podmiotTyp, @PodmiotId
    IF @@fetch_status <> 0  BREAK
    IF  @TypKnt <> @lastTypKnt
   SET @LP = 1
    ELSE
   SET @LP = @LP + 1
    UPDATE cdn.FaCyklKnt SET FCK_LpDlaTypKnt = @LP WHERE FcK_FcKId = @ID
    UPDATE cdn.FaCyklTwrKnt SET FCT_KntLp = @LP WHERE FCT_FcKID = @ID
    SET @lastTypKnt = @TypKnt
 END
END
