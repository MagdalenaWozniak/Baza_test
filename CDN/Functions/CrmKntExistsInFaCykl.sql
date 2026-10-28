CREATE FUNCTION cdn.CrmKntExistsInFaCykl(
@FcNId INT,
@KntTyp INT,
@KntId  INT)
  RETURNS     INT
  AS
BEGIN
 IF EXISTS( SELECT * FROM cdn.FaCyklKnt WHERE FcK_FcNId = @FcNId AND FcK_TypKnt=2 AND FcK_PodmiotTyp=@KntTyp AND FcK_PodmiotId = @KntId)
  RETURN 1
 ELSE
 BEGIN
 IF EXISTS( SELECT * FROM cdn.FaCyklKnt
    JOIN cdn.Grupy ON Gru_Typ = 31 AND Gru_GruId = FcK_PodmiotId AND FcK_TypKnt=1
    JOIN cdn.Kontrahenci ON Knt_Grupa = Gru_Nazwa AND Knt_PodmiotTyp = @KntTyp AND Knt_KntId = @KntId
    WHERE FcK_FcNId = @FcNId)
   RETURN 1
  ELSE
   RETURN 0
 END
 RETURN 0
END
