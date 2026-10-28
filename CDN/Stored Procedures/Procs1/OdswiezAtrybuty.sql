CREATE  PROCEDURE CDN.OdswiezAtrybuty
   @TwA_DeAID1 INT,
   @DeA_Kod1 NVARCHAR(20),
   @TwA_Wartosctxt1 NVARCHAR(100),
   @TwA_DeAID2 INT,
   @DeA_Kod2 NVARCHAR(20),
   @TwA_Wartosctxt2 NVARCHAR(100),
   @TwA_DeAID3 INT,
   @DeA_Kod3 NVARCHAR(20),
   @TwA_Wartosctxt3 NVARCHAR(100),
   @TwA_DeAID4 INT,
   @DeA_Kod4 NVARCHAR(20),
   @TwA_Wartosctxt4 NVARCHAR(100),
   @TwA_DeAID5 INT,
   @DeA_Kod5 NVARCHAR(20),
   @TwA_Wartosctxt5 NVARCHAR(100),
   @PodTyp Int,
   @PodId Int,
   @TwrId Int
  AS
SET NOCOUNT ON
DECLARE
 @TwA_Zalezny INT
 SET @TwA_Zalezny=0
  IF @TwA_DeAID1=0 or @TwA_DeAID1 is null
          SELECT @TwA_DeAID1=TwA_DeAID,@DeA_Kod1=DeA_Kod, @TwA_Wartosctxt1=TKA_Wartosctxt FROM cdn.twratrybuty JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID
          WHERE TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 1 AND TwA_TwrID = @TwrId AND TKA_PodmiotTyp = @PodTyp AND TKA_PodmiotID = @PodId
            AND TwA_DeAID not in (@TwA_DeAID1,@TwA_DeAID2,@TwA_DeAID3,@TwA_DeAID4,@TwA_DeAID5)
 ELSE
        SELECT @TwA_Zalezny = TwA_Zalezny FROM cdn.twratrybuty
        WHERE  TWA_DeAId = @TwA_DeAID1 AND TWA_TwrId = @TwrId
        if @TwA_Zalezny = 1
          SELECT @DeA_Kod1=DeA_Kod, @TwA_Wartosctxt1=ISNULL(TKA_Wartosctxt,TwA_Wartosctxt) FROM cdn.twratrybuty
          JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          left JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID and TKA_PodmiotID = @PodId AND TKA_PodmiotTyp = @PodTyp
          WHERE TwA_CzyPrzenosic = 1  AND TwA_TwrID = @TwrId AND TWA_DeAId = @TwA_DeAID1
 SET @TwA_Zalezny=0
 IF @TwA_DeAID2=0 or @TwA_DeAID2 is null
            SELECT @TwA_DeAID2=TwA_DeAID,@DeA_Kod2=DeA_Kod, @TwA_Wartosctxt2=TKA_Wartosctxt FROM cdn.twratrybuty JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID
          WHERE TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 1 AND TwA_TwrID = @TwrId AND TKA_PodmiotTyp = @PodTyp AND TKA_PodmiotID = @PodId
            AND TwA_DeAID not in (@TwA_DeAID1,@TwA_DeAID2,@TwA_DeAID3,@TwA_DeAID4,@TwA_DeAID5)
 ELSE
        SELECT @TwA_Zalezny = TwA_Zalezny FROM cdn.twratrybuty
        WHERE  TWA_DeAId = @TwA_DeAID2 AND TWA_TwrId = @TwrId
        if @TwA_Zalezny = 1
          SELECT @DeA_Kod2=DeA_Kod, @TwA_Wartosctxt2=ISNULL(TKA_Wartosctxt,TwA_Wartosctxt) FROM cdn.twratrybuty
          JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          left JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID and TKA_PodmiotID = @PodId AND TKA_PodmiotTyp = @PodTyp
          WHERE TwA_CzyPrzenosic = 1  AND TwA_TwrID = @TwrId AND TWA_DeAId = @TwA_DeAID2
 SET @TwA_Zalezny=0
 IF @TwA_DeAID3=0 or @TwA_DeAID3 is null
          SELECT @TwA_DeAID3=TwA_DeAID,@DeA_Kod3=DeA_Kod, @TwA_Wartosctxt3=TKA_Wartosctxt FROM cdn.twratrybuty JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID
          WHERE TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 1 AND TwA_TwrID = @TwrId AND TKA_PodmiotTyp = @PodTyp AND TKA_PodmiotID = @PodId
            AND TwA_DeAID not in (@TwA_DeAID1,@TwA_DeAID2,@TwA_DeAID3,@TwA_DeAID4,@TwA_DeAID5)
 ELSE
        SELECT @TwA_Zalezny = TwA_Zalezny FROM cdn.twratrybuty
        WHERE  TWA_DeAId = @TwA_DeAID3 AND TWA_TwrId = @TwrId
        if @TwA_Zalezny = 1
          SELECT @DeA_Kod3=DeA_Kod, @TwA_Wartosctxt3=ISNULL(TKA_Wartosctxt,TwA_Wartosctxt) FROM cdn.twratrybuty
          JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          left JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID and TKA_PodmiotID = @PodId AND TKA_PodmiotTyp = @PodTyp
          WHERE TwA_CzyPrzenosic = 1  AND TwA_TwrID = @TwrId AND TWA_DeAId = @TwA_DeAID3
 SET @TwA_Zalezny=0
 IF @TwA_DeAID4=0 or @TwA_DeAID4 is null
          SELECT @TwA_DeAID4=TwA_DeAID,@DeA_Kod4=DeA_Kod, @TwA_Wartosctxt4=TKA_Wartosctxt FROM cdn.twratrybuty JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID
          WHERE TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 1 AND TwA_TwrID = @TwrId AND TKA_PodmiotTyp = @PodTyp AND TKA_PodmiotID = @PodId
            AND TwA_DeAID not in (@TwA_DeAID1,@TwA_DeAID2,@TwA_DeAID3,@TwA_DeAID4,@TwA_DeAID5)
 ELSE
        SELECT @TwA_Zalezny = TwA_Zalezny FROM cdn.twratrybuty
        WHERE  TWA_DeAId = @TwA_DeAID4 AND TWA_TwrId = @TwrId
        if @TwA_Zalezny = 1
          SELECT @DeA_Kod4=DeA_Kod, @TwA_Wartosctxt4=ISNULL(TKA_Wartosctxt,TwA_Wartosctxt) FROM cdn.twratrybuty
          JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          left JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID and TKA_PodmiotID = @PodId AND TKA_PodmiotTyp = @PodTyp
          WHERE TwA_CzyPrzenosic = 1  AND TwA_TwrID = @TwrId AND TWA_DeAId = @TwA_DeAID4
 SET @TwA_Zalezny=0
 IF @TwA_DeAID5=0 or @TwA_DeAID5 is null
          SELECT @TwA_DeAID5=TwA_DeAID,@DeA_Kod5=DeA_Kod, @TwA_Wartosctxt5=TKA_Wartosctxt FROM cdn.twratrybuty JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID
          WHERE TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 1 AND TwA_TwrID = @TwrId AND TKA_PodmiotTyp = @PodTyp AND TKA_PodmiotID = @PodId
            AND TwA_DeAID not in (@TwA_DeAID1,@TwA_DeAID2,@TwA_DeAID3,@TwA_DeAID4,@TwA_DeAID5)
 ELSE
        SELECT @TwA_Zalezny = TwA_Zalezny FROM cdn.twratrybuty
        WHERE  TWA_DeAId = @TwA_DeAID5 AND TWA_TwrId = @TwrId
        if @TwA_Zalezny = 1
          SELECT @DeA_Kod5=DeA_Kod, @TwA_Wartosctxt5=ISNULL(TKA_Wartosctxt,TwA_Wartosctxt) FROM cdn.twratrybuty
          JOIN cdn.defatrybuty ON TwA_DeAID = DeA_DeAID
          left JOIN cdn.twrkntatrybuty ON TKA_TwAID = TwA_TwAID and TKA_PodmiotID = @PodId AND TKA_PodmiotTyp = @PodTyp
          WHERE TwA_CzyPrzenosic = 1  AND TwA_TwrID = @TwrId AND TWA_DeAId = @TwA_DeAID5
 SET NOCOUNT OFF
 select @TwrId as TwrId,
        @TwA_DeAID1 as DeAID1,@DeA_Kod1 as Kod1,@TwA_Wartosctxt1 as Wartosc1,
        @TwA_DeAID2 as DeAID2,@DeA_Kod2 as Kod2,@TwA_Wartosctxt2 as Wartosc2,
        @TwA_DeAID3 as DeAID3,@DeA_Kod3 as Kod3,@TwA_Wartosctxt3 as Wartosc3,
        @TwA_DeAID4 as DeAID4,@DeA_Kod4 as Kod4,@TwA_Wartosctxt4 as Wartosc4,
        @TwA_DeAID5 as DeAID5,@DeA_Kod5 as Kod5,@TwA_Wartosctxt5 as Wartosc5
