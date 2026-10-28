CREATE  PROCEDURE cdn.CrmKntInFaCykl
@FcNId INT
AS
 DECLARE @max INT
 SELECT @max = MAX(FCK_FcKID) FROM cdn.FaCyklKnt
 SELECT  FCK_FcKID
  ,FCK_PodmiotTyp  As 'Knt_NabywcaTyp',  FCK_PodmiotId  As 'Knt_NabywcaId'
  ,FCK_OdbiorcaTyp As 'Knt_OdbiorcaTyp', FCK_OdbiorcaId As 'Knt_OdbiorcaId'
  ,FcK_TypKnt, FCK_LpDlaTypKnt
 FROM cdn.FaCyklKnt WHERE FCK_TypKnt=2 AND FCK_FcNId=@FcNId
 UNION
 SELECT  A.FCK_FcKID As 'FCK_FcKID'
  ,Knt_PodmiotTyp As 'Knt_NabywcaTyp',  Knt_KntId As 'Knt_NabywcaId'
  ,Knt_PodmiotTyp As 'Knt_OdbiorcaTyp', Knt_KntId As 'Knt_OdbiorcaId'
  ,A.FcK_TypKnt, A.FCK_LpDlaTypKnt
 FROM cdn.FaCyklKnt A
 JOIN cdn.Grupy ON FcK_TypKnt=1 AND FCK_PodmiotTyp=0 AND FcK_PodmiotId=Gru_GruId AND FcK_FcNId=@FcNId
 JOIN cdn.Kontrahenci ON Knt_Grupa=Gru_Nazwa
 LEFT JOIN cdn.FaCyklKnt B ON B.FcK_TypKnt=2 AND B.FCK_PodmiotTyp=Knt_PodmiotTyp AND B.FcK_PodmiotId=Knt_KntId AND B.FcK_FcNId=@FcNId
 WHERE B.FcK_PodmiotId Is NULL
 ORDER BY FcK_TypKnt, FCK_LpDlaTypKnt
