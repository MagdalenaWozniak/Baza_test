CREATE PROCEDURE CDN.GenerujPWPBraki
  @TrN_TrNId_PWP    INT
AS
SET NOCOUNT ON
 DECLARE
    @Tre_Lp   INT,
    @Tre_TwrID   INT,
    @Tre_TwrKod  NVARCHAR(50),
    @Tre_Ilosc   DECIMAL(15,4),
    @Pde_Lp   INT,
    @Pde_TwrId   INT,
    @Pde_TwrKod  NVARCHAR(50),
    @Pde_Ilosc   DECIMAL(15,4),
    @Pde_MagId   INT,
    @TwI_Data   DATETIME
   SELECT @TwI_Data = TrN_DataOpe FROM cdn.TraNag WHERE TrN_TrNId = @TrN_TrNId_PWP
   CREATE TABLE #PWPIlosci(WID INT IDENTITY(1,1) NOT FOR REPLICATION, Tre_Lp INT, Tre_TwrID INT,Tre_TwrKod NVARCHAR(50), Tre_Ilosc DECIMAL(15,4), Pde_Lp INT, Pde_TwrId INT, Pde_TwrKod NVARCHAR(50), Pde_Ilosc DECIMAL(15,4),Pde_MagId INT, Zostalo DECIMAL(15,4),Ulamek DECIMAL(15,4) )
   DECLARE E CURSOR LOCAL FAST_FORWARD FOR
    SELECT Tre_Lp, Tre_TwrID,Tre_TwrKod, Tre_IloscJM, Pde_Lp, Pde_TwrId, Pde_Ilosc,Pde_MagId FROM Cdn.ProdElem
 LEFT outer JOIN Cdn.TraElem ON Tre_TreId=Pde_TreId
 JOIN Cdn.Towary ON Pde_Twrid = Twr_Twrid AND Twr_Typ = 1
 WHERE Tre_TrnId = @TrN_TrNId_PWP
    OPEN E
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM E INTO @Tre_Lp, @Tre_TwrID,@Tre_TwrKod, @Tre_Ilosc, @Pde_Lp, @Pde_TwrId, @Pde_Ilosc,@Pde_MagId
        IF @@FETCH_STATUS <> 0 BREAK
   SELECT @Pde_TwrKod=Twr_Kod FROM Cdn.Towary WHERE Twr_twrId=@Pde_TwrId
         INSERT INTO #PWPIlosci(Tre_Lp, Tre_TwrID, Tre_TwrKod, Tre_Ilosc, Pde_Lp, Pde_TwrId,Pde_TwrKod, Pde_Ilosc,Pde_MagId)
                           VALUES (@TrE_Lp, @TrE_TwrId,@TrE_TwrKod,  @TrE_Ilosc, @PdE_Lp, @PdE_TwrId, @PdE_TwrKod, @PdE_Ilosc, @PdE_MagId )
       END
    CLOSE E
  DEALLOCATE E
  -- logika
   DECLARE @Id INT,@TwrId INT,@Ilosc DECIMAL(15,4),@MagId INT,@zostaloreszty DECIMAL(15,4),@ilosczinnych DECIMAL(15,4)
                 DECLARE RWS CURSOR LOCAL FAST_FORWARD FOR
                 SELECT WID,Pde_TwrId,Pde_Ilosc,Pde_MagId FROM #PWPIlosci
                 OPEN RWS
                 WHILE 1=1
                 BEGIN FETCH NEXT FROM RWS INTO @Id, @TwrId,@Ilosc,@MagId
                   IF @@FETCH_STATUS <> 0 BREAK
                   SET @zostaloreszty = (SELECT zostalo FROM #PWPIlosci WHERE PDE_TWRID=@TwrId and wid = (SELECT MAX(wid) FROM #PWPIlosci WHERE PDE_TWRID=@TwrId and wid < @Id)  )
                   IF  @zostaloreszty IS null
                   BEGIN
                     SET @zostaloreszty =(   SELECT isnull(B.TwI_Ilosc,0)AS TwI_Braki
                                 FROM CDN.Towary A LEFT OUTER JOIN CDN.TwrIlosci B ON A.Twr_TwrID = B.TwI_TwrID AND B.TwI_MagId=@MagId
                                 AND B.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = A.Twr_TwrId AND H.TwI_MagId=@MagId
                                 AND H.TwI_Data <= convert(datetime,@TwI_Data,120)
                                 ORDER BY H.TwI_Data DESC)
                                 LEFT OUTER JOIN CDN.Magazyny C ON  B.TwI_MagId= C.Mag_MagId
                                 LEFT OUTER JOIN CDN.TwrCeny D ON A.Twr_TwrId= D.TwC_TwrID AND A.Twr_TwCNumer = D.TwC_TwCNumer
                                 WHERE A.Twr_TwrID =@TwrId
                                 )
                   END
                   SET @zostaloreszty = @zostaloreszty - @Ilosc
                   UPDATE #PWPIlosci SET zostalo=@zostaloreszty WHERE Pde_TwrId =@TwrId and WID=@Id
                 END;CLOSE RWS; DEALLOCATE RWS;
  SET NOCOUNT OFF
  -- dla potrzeb wywolania funkcji z poziomu programu procedura musi zwrócić cokolwiek, np. 0
  SELECT * FROM #PWPIlosci
  DROP TABLE #PWPIlosci
