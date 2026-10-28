Create PROCEDURE [CDN].[PrzeliczIlosciPI]
 @Id          INT,
 @Status      INT
  AS
  SET NOCOUNT ON
  CREATE TABLE  #PAI(PAE_TrEId INT,PAE_TwrId INT, PAE_JM NVARCHAR(20),PAE_Ilosc DECIMAL(15,4))
  CREATE TABLE  #AI(TrE_TrEId INT,TrE_TwrId INT, TrE_JM NVARCHAR(20),TrE_Ilosc DECIMAL(15,4))
 IF @Status = 0
 BEGIN
   IF NOT EXISTS (SELECT PAI_TrNId FROM CDN.PodArkuszInwenNag WHERE PAI_TrNId=@Id)
   RETURN
   UPDATE Cdn.TraElem SET Tre_IloscJM = 0
    WHERE TrE_TrNId=@Id
   INSERT INTO  #PAI SELECT PAE_TrEId,PAE_TwrId,PAE_JM,sum(PAE_Ilosc) FROM CDN.PodArkuszInwenElem
  JoIN CDN.PodArkuszInwenNag ON PAE_PAIId=PAI_PAIId
  WHERE PAI_TrNId=@Id
  group by PAE_TrEId,PAE_TwrId,PAE_JM
   UPDATE Cdn.TraElem SET Tre_IloscJM = ISNULL(PAE_Ilosc,0),Tre_Ilosc = ISNULL(PAE_Ilosc*Tre_JMPrzelicznikL/Tre_JMPrzelicznikM,0),
                          TrE_WartoscNetto=ROUND(ROUND(TrE_CenaWWD*ISNULL(PAE_Ilosc,0),2) * TrN_KursL / TrN_KursM , 2),
                          TrE_WartoscNettoWal=ROUND(TrE_CenaWWD*ISNULL(PAE_Ilosc,0),2),
                          TrE_WartoscBrutto=ROUND(ROUND(ROUND(TrE_CenaWWD*ISNULL(PAE_Ilosc,0),2) * TrN_KursL / TrN_KursM , 2) * (100 + TrE_Stawka )/100, 2),
                          TrE_WartoscBruttoWal=ROUND(ROUND(TrE_CenaWWD*ISNULL(PAE_Ilosc,0),2) * (100 + TrE_Stawka )/100, 2)
     FROM Cdn.TraElem
     LEFT OUTER JOIN #PAI ON PAE_TrEId = TrE_TrEId AND TrE_JM = PAE_JM
     LEFT OUTER JOIN Cdn.Towary ON PAE_TwrId = Twr_TwrId
     LEFT OUTER JOIN Cdn.TraNag ON Tre_TrNId = Trn_TrNId
     WHERE TrE_TrnId=@Id
   UPDATE Cdn.TraElem SET Tre_IloscJM = Tre_IloscJM+ISNULL(iloscJM,0),
                          Tre_Ilosc = Tre_Ilosc+ISNULL(iloscJM,0),
                          TrE_WartoscNetto=ROUND(ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2) * TrN_KursL / TrN_KursM , 2),
                          TrE_WartoscNettoWal=ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2),
                          TrE_WartoscBrutto=ROUND(ROUND(ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2) * TrN_KursL / TrN_KursM , 2) * (100 + TrE_Stawka )/100, 2),
                          TrE_WartoscBruttoWal=ROUND(ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2) * (100 + TrE_Stawka )/100, 2)
     FROM Cdn.TraElem
     right OUTER JOIN (select TrE_TrEId as TrEId, SUM(ISNULL(PAE_Ilosc*TwJZ_JMPrzelicznikL/TwJZ_JMPrzelicznikM,0)) as iloscJM,SUM(ISNULL(PAE_Ilosc,0)) as ilosc
      FROM Cdn.TraElem
      LEFT OUTER JOIN #PAI ON PAE_TrEId = TrE_TrEId AND TrE_JM <> PAE_JM
      LEFT OUTER JOIN Cdn.Towary ON PAE_TwrId = Twr_TwrId
   LEFT OUTER JOIN cdn.TwrJMZ ON TwJZ_TwrId = Twr_TwrId AND TwJZ_JM = PAE_JM AND TwJZ_eSklepID = 0
      WHERE TrE_TrnId=@Id AND TrE_JM = Twr_JM
      group by TrE_TrEId
     )A on a.TrEId = TrE_TrEId
     LEFT OUTER JOIN Cdn.TraNag ON Tre_TrNId = Trn_TrNId
    UPDATE Cdn.TraElem SET Tre_IloscJM = Tre_IloscJM+ISNULL(iloscJM,0),
                          Tre_Ilosc = Tre_Ilosc+ISNULL(ilosc,0),
                          TrE_WartoscNetto=ROUND(ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2) * TrN_KursL / TrN_KursM , 2),
                          TrE_WartoscNettoWal=ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2),
                          TrE_WartoscBrutto=ROUND(ROUND(ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2) * TrN_KursL / TrN_KursM , 2) * (100 + TrE_Stawka )/100, 2),
                          TrE_WartoscBruttoWal=ROUND(ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2) * (100 + TrE_Stawka )/100, 2)
     FROM Cdn.TraElem
     right OUTER JOIN (select TrE_TrEId as TrEId, SUM(ISNULL(PAE_Ilosc*TwJZ_JMPrzelicznikM/TwJZ_JMPrzelicznikL,0)) as iloscJM,SUM(ISNULL(PAE_Ilosc,0)) as ilosc
      FROM Cdn.TraElem
      LEFT OUTER JOIN #PAI ON PAE_TrEId = TrE_TrEId AND TrE_JM <> PAE_JM
      LEFT OUTER JOIN Cdn.Towary ON PAE_TwrId = Twr_TwrId
      LEFT OUTER JOIN cdn.TwrJMZ ON TwJZ_TwrId = Twr_TwrId AND TwJZ_JM = TrE_JM AND TwJZ_eSklepID = 0
      WHERE TrE_TrnId=@Id AND TrE_JM <> Twr_JM AND PAE_JM = Twr_JM
      group by TrE_TrEId
     )A on a.TrEId = TrE_TrEId
     LEFT OUTER JOIN Cdn.TraNag ON Tre_TrNId = Trn_TrNId
     UPDATE Cdn.TraElem SET Tre_IloscJM = Tre_IloscJM+ISNULL(iloscJM,0),
                          Tre_Ilosc = Tre_Ilosc+ISNULL(ilosc,0),
                          TrE_WartoscNetto=ROUND(ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2) * TrN_KursL / TrN_KursM , 2),
                          TrE_WartoscNettoWal=ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2),
                          TrE_WartoscBrutto=ROUND(ROUND(ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2) * TrN_KursL / TrN_KursM , 2) * (100 + TrE_Stawka )/100, 2),
                          TrE_WartoscBruttoWal=ROUND(ROUND(TrE_CenaWWD*ISNULL(Tre_IloscJM+ISNULL(iloscJM,0),0),2) * (100 + TrE_Stawka )/100, 2)
     FROM Cdn.TraElem
     right OUTER JOIN (select TrE_TrEId as TrEId, SUM(ISNULL(PAE_Ilosc*(B.TwJZ_JMPrzelicznikL/B.TwJZ_JMPrzelicznikM)*(A.TwJZ_JMPrzelicznikM/A.TwJZ_JMPrzelicznikL),0)) as iloscJM,SUM(ISNULL(PAE_Ilosc*(B.TwJZ_JMPrzelicznikL/B.TwJZ_JMPrzelicznikM),0)) as ilosc
      FROM Cdn.TraElem
      LEFT OUTER JOIN #PAI ON PAE_TrEId = TrE_TrEId AND TrE_JM <> PAE_JM
      LEFT OUTER JOIN Cdn.Towary ON PAE_TwrId = Twr_TwrId
      LEFT OUTER JOIN cdn.TwrJMZ A ON A.TwJZ_TwrId = Twr_TwrId AND A.TwJZ_JM = TrE_JM AND A.TwJZ_eSklepID = 0
   LEFT OUTER JOIN cdn.TwrJMZ B ON B.TwJZ_TwrId = Twr_TwrId AND B.TwJZ_JM = PAE_JM AND B.TwJZ_eSklepID = 0
     WHERE TrE_TrnId=@Id AND TrE_JM <> Twr_JM AND PAE_JM <> Twr_JM
     group by TrE_TrEId
     )A on a.TrEId = TrE_TrEId
     LEFT OUTER JOIN Cdn.TraNag ON Tre_TrNId = Trn_TrNId
   UPDATE CDN.PodArkuszInwenNag SET PAI_STATUS = 1
     WHERE PAI_TrNId=@Id
 END
 ELSE
 BEGIN
   INSERT INTO  #PAI SELECT PAE_TrEId,PAE_TwrId,PAE_JM,sum(PAE_Ilosc) FROM CDN.PodArkuszInwenElem
  JoIN CDN.PodArkuszInwenNag ON PAE_PAIId=PAI_PAIId
  WHERE PAI_TrNId=@Id
  group by PAE_TrEId,PAE_TwrId,PAE_JM
   INSERT INTO  #AI SELECT TrE_TrEId,TrE_TwrId,TrE_JM,0 FROM CDN.TraElem
  WHERE TrE_TrnId=@Id
   UPDATE #AI SET Tre_Ilosc = ISNULL(PAE_Ilosc,0)
     FROM #AI
     LEFT OUTER JOIN #PAI ON PAE_TrEId = TrE_TrEId AND TrE_JM = PAE_JM
 UPDATE #AI SET Tre_Ilosc = Tre_Ilosc+ISNULL(suma,0)
   FROM #AI
   LEFT OUTER JOIN (select TrE_TrEId as TrEId, sum(ISNULL(PAE_Ilosc*TwJZ_JMPrzelicznikL/TwJZ_JMPrzelicznikM,0)) as suma from #AI
   LEFT OUTER JOIN #PAI ON PAE_TrEId = TrE_TrEId AND TrE_JM <> PAE_JM
   LEFT OUTER JOIN Cdn.Towary ON PAE_TwrId = Twr_TwrId AND TrE_JM = Twr_JM
   LEFT OUTER JOIN cdn.TwrJMZ ON TwJZ_TwrId = Twr_TwrId AND TwJZ_JM = PAE_JM AND TwJZ_eSklepID = 0
   group by    TrE_TrEId) A on a.TrEId = TrE_TrEId
 UPDATE #AI SET Tre_Ilosc = Tre_Ilosc+ISNULL(suma,0)
   FROM #AI
   LEFT OUTER JOIN (select TrE_TrEId as TrEId, sum(ISNULL(PAE_Ilosc*TwJZ_JMPrzelicznikM/TwJZ_JMPrzelicznikL,0)) as suma from #AI
   LEFT OUTER JOIN #PAI ON PAE_TrEId = TrE_TrEId AND TrE_JM <> PAE_JM
   LEFT OUTER JOIN Cdn.Towary ON PAE_TwrId = Twr_TwrId AND TrE_JM <> Twr_JM AND PAE_JM = Twr_JM
   LEFT OUTER JOIN cdn.TwrJMZ ON TwJZ_TwrId = Twr_TwrId AND TwJZ_JM = TrE_JM AND TwJZ_eSklepID = 0
   group by    TrE_TrEId) A on a.TrEId = TrE_TrEId
 UPDATE #AI SET Tre_Ilosc = Tre_Ilosc+ISNULL(suma,0)
   FROM #AI
   LEFT OUTER JOIN (select TrE_TrEId as TrEId, sum(ISNULL(PAE_Ilosc*(B.TwJZ_JMPrzelicznikL/B.TwJZ_JMPrzelicznikM)*(A.TwJZ_JMPrzelicznikM/A.TwJZ_JMPrzelicznikL),0)) as suma from #AI
   LEFT OUTER JOIN #PAI ON PAE_TrEId = TrE_TrEId AND TrE_JM <> PAE_JM
   LEFT OUTER JOIN Cdn.Towary ON PAE_TwrId = Twr_TwrId AND TrE_JM <> Twr_JM AND PAE_JM <> Twr_JM
   LEFT OUTER JOIN cdn.TwrJMZ A ON A.TwJZ_TwrId = Twr_TwrId AND A.TwJZ_JM = TrE_JM AND A.TwJZ_eSklepID = 0
   LEFT OUTER JOIN cdn.TwrJMZ B ON B.TwJZ_TwrId = Twr_TwrId AND B.TwJZ_JM = PAE_JM AND B.TwJZ_eSklepID = 0
   group by    TrE_TrEId) A on a.TrEId = TrE_TrEId
 END
 DROP TABLE  #PAI
SET NOCOUNT Off
IF @Status=1 SELECT * FROM #AI
