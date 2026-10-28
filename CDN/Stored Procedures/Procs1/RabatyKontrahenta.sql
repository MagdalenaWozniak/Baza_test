CREATE  PROCEDURE CDN.RabatyKontrahenta(@PodmiotID INT, @TwrGrupa INT, @Twr_Id INT)
AS
SET NOCOUNT ON
DECLARE @KntGrupaId INT
DECLARE @KntGrupa   NVARCHAR (100)
DECLARE @Wartosc    DECIMAL(15,2)
DECLARE @WartoscISklep    DECIMAL(15,2)
DECLARE @RabTyp     SMALLINT
DECLARE @RabId      INT
DECLARE @TwrId      INT
DECLARE @KodGrupy   NVARCHAR(100)
DECLARE @TwrKod     NVARCHAR(50)
CREATE TABLE #Cennik (KtoCo NVARCHAR(255), TypRabatu SMALLINT, Wartosc DECIMAL(15,2), TwrKod NVARCHAR(50), Poziom SMALLINT, TwrId INT, WartoscISklep DECIMAL(15,2),Rab_RabId INT PRIMARY KEY(TwrId, TwrKod, Poziom))
SELECT @KntGrupa = Knt_Grupa FROM CDN.Kontrahenci WHERE Knt_KntID = @PodmiotID
SELECT @KntGrupaID = Gru_GruID FROM CDN.Grupy WHERE Gru_Nazwa = @KntGrupa AND Gru_Typ = 31
     --Kontrahent/Towar
 IF EXISTS (SELECT Rab_RabId FROM CDN.Rabaty WHERE Rab_Typ = 6 AND Rab_PodmiotTyp = 1 AND Rab_PodmiotId = @PodmiotId)
   BEGIN
    INSERT INTO dbo.#Cennik (TwrId, TypRabatu, Wartosc, TwrKod, Poziom, KtoCo, WartoscISklep,Rab_RabId)
      SELECT Twr_Twrid, Rab_Typ, Rab_Rabat, Twr_Kod, 1, '', Rab_RabatISklep,Rab_RabId FROM CDN.Rabaty
        JOIN CDN.Towary ON Rab_TwrId = Twr_TwrId AND Rab_Typ=6
             WHERE (Twr_TwgGIDNumer = @TwrGrupa OR @TwrGrupa=-1)
                   AND Rab_PodmiotId = @PodmiotId
                   AND (Twr_TwrId = @Twr_Id OR @Twr_Id=0)
   END
         --Kontrahent/Grupa Towaru
  IF EXISTS (SELECT Rab_RabId FROM CDN.Rabaty WHERE Rab_Typ = 5 AND Rab_PodmiotTyp = 1 AND Rab_PodmiotID = @PodmiotId)
    BEGIN
      INSERT INTO dbo.#Cennik (TwrId, TypRabatu, Wartosc, TwrKod, Poziom, KtoCo, WartoscISklep,Rab_RabId)
      SELECT Twr_TwrID, Rab_Typ, Rab_Rabat, Twr_Kod, 2, TwG_Kod, Rab_RabatISklep,Rab_RabId FROM CDN.Rabaty
        JOIN CDN.Towary ON Rab_TwrId = Twr_TwGGIDNumer
        JOIN CDN.TwrGrupy ON Rab_TwrId = TwG_GIDNumer AND TwG_GIDTyp=-16
             WHERE Rab_Typ = 5 AND (Rab_TwrId = @TwrGrupa OR @TwrGrupa=-1)
                               AND Rab_PodmiotId = @PodmiotId
                               AND Twr_TwrId NOT IN (SELECT TwrId FROM dbo.#Cennik)
                               AND (Twr_TwrId = @Twr_Id OR @Twr_Id=0)
    END
         --Kontrahent/Wszystkie Towary
  IF EXISTS (SELECT Rab_RabId FROM CDN.Rabaty WHERE Rab_PodmiotId = @PodmiotId AND Rab_Typ = 2 AND Rab_PodmiotTyp = 1)
   BEGIN
     SELECT @Wartosc = Rab_Rabat, @RabTyp = Rab_Typ, @WartoscISklep = Rab_RabatISklep, @RabId =Rab_RabId FROM CDN.Rabaty
            WHERE Rab_PodmiotId = @PodmiotId AND Rab_Typ = 2
      INSERT INTO dbo.#Cennik (TwrId, TypRabatu, Wartosc, TwrKod, Poziom, KtoCo, WartoscISklep,Rab_RabId)
      SELECT Twr_TwrId,  @RabTyp, @Wartosc, Twr_Kod,3, '', @WartoscISklep,@RabId FROM CDN.Towary
        WHERE Twr_TwrId NOT IN (SELECT TwrId FROM dbo.#Cennik) AND (Twr_TwrId = @Twr_Id OR @Twr_Id = 0) AND (Twr_TwGGIDNumer = @TwrGrupa OR @TwrGrupa=-1)
   END
        --Grupa kontrahenta/jeden towar
  IF EXISTS (SELECT Rab_RabID FROM CDN.Rabaty WHERE Rab_Typ = 4 AND Rab_PodmiotId = @KntGrupaId)
    BEGIN
     INSERT INTO dbo.#Cennik (TwrId, TypRabatu, Wartosc, TwrKod, Poziom, KtoCo, WartoscISklep,Rab_RabId)
      SELECT Twr_TwrID, Rab_Typ, Rab_Rabat, Twr_Kod, 4, '', Rab_RabatISklep,Rab_RabId FROM CDN.Rabaty
       JOIN CDN.Towary ON Rab_TwrId = Twr_TwrId
        WHERE (Twr_TwGGIDNumer = @TwrGrupa OR @TwrGrupa = -1) AND Rab_Typ = 4
              AND Rab_PodmiotId = @KntGrupaId AND Twr_TwrId NOT IN (SELECT TwrId FROM dbo.#Cennik) AND
              (Twr_TwrId = @Twr_Id OR @Twr_Id=0)
    END
  --Grupa kontrahenta/Grupa towaru
  IF EXISTS (SELECT Rab_RabId FROM CDN.Rabaty WHERE Rab_Typ = 3 AND Rab_PodmiotId = @KntGrupaId AND (Rab_TwrId = @TwrGrupa OR @TwrGrupa=-1))
   BEGIN
    INSERT INTO dbo.#Cennik (TwrId, TypRabatu, Wartosc, TwrKod, Poziom, KtoCo, WartoscISklep,Rab_RabId)
     SELECT Twr_TwrId, Rab_Typ, Rab_Rabat, Twr_Kod, 5, Twg_Kod, Rab_RabatISklep,Rab_RabId FROM CDN.Rabaty
      JOIN CDN.Towary ON Rab_TwrId = Twr_TwGGIDNumer
      JOIN CDN.TwrGrupy ON Rab_TwrId = Twg_GIDNumer AND TwG_GIDTyp = -16
       WHERE Rab_Typ = 3 AND (Rab_TwrId = @TwrGrupa OR @TwrGrupa=-1)
             AND Rab_PodmiotId = @KntGrupaId
             AND Twr_TwrId NOT IN (SELECT TwrId FROM dbo.#Cennik)
             AND (Twr_TwrId = @Twr_Id OR @Twr_Id=0)
   END
 --Grupa kontrahenta/wszystkie Towary
   IF EXISTS (SELECT Rab_RabId FROM CDN.Rabaty WHERE Rab_PodmiotId = @KntGrupaId AND Rab_Typ = 1)
    BEGIN
     SELECT @Wartosc = Rab_Rabat, @RabTyp = Rab_Typ, @WartoscISklep = Rab_RabatISklep, @RabId =Rab_RabId FROM CDN.Rabaty WHERE Rab_PodmiotId = @KntGrupaId AND Rab_Typ = 1
      INSERT INTO dbo.#Cennik (TwrId, TypRabatu, Wartosc, TwrKod, Poziom, KtoCo, WartoscISklep,Rab_RabId)
        SELECT Twr_TwrId, @RabTyp, @Wartosc, Twr_Kod, 6 , '', @WartoscISklep,@RabId FROM CDN.Towary
         WHERE (Twr_TwGGIDNumer = @TwrGrupa OR @TwrGrupa=-1)
                AND Twr_TwrId NOT IN (SELECT TwrId FROM dbo.#Cennik)
                AND (Twr_TwrId = @Twr_Id OR @Twr_Id=0)
    END
 --Wszyscy kontrahenci/Towar
   IF EXISTS (SELECT Rab_RabId FROM CDN.Rabaty WHERE Rab_Typ = 8)
    BEGIN
      INSERT INTO dbo.#Cennik (TwrId, TypRabatu, Wartosc, TwrKod, Poziom, KtoCo, WartoscISklep,Rab_RabId)
      SELECT Twr_TwrID, Rab_Typ, Rab_Rabat,Twr_Kod, 7, '', Rab_RabatISklep,Rab_RabId FROM CDN.Rabaty
     JOIN CDN.Towary ON Rab_TwrId = Twr_TwrId WHERE (twr_twggidnumer = @TwrGrupa OR @twrgrupa = -1) AND rab_typ = 8 AND (twr_twrid = @Twr_Id OR @Twr_Id=0)
    END
 --Wszyscy kontrahenci/Grupa towaru
   IF EXISTS (SELECT Rab_RabId FROM CDN.Rabaty WHERE Rab_Typ = 7)-- AND Rab_TwrID = @TwrGrupa OR @TwrGrupa=-1)
    BEGIN
     INSERT INTO dbo.#Cennik (TwrId, TypRabatu, Wartosc, TwrKod, Poziom, KtoCo, WartoscISklep,Rab_RabId)
     SELECT Twr_TwrID, Rab_Typ, Rab_Rabat, Twr_Kod, 8, TwG_Kod, Rab_RabatISklep,Rab_RabId FROM CDN.Rabaty
      JOIN CDN.Towary ON Twr_TwgGIDNumer = Rab_TwrId
      JOIN CDN.TwrGrupy ON Rab_TwrId = Twg_GIDNumer AND Twg_GIDTyp =-16
        WHERE (Rab_TwrId = @TwrGrupa OR @TwrGrupa = -1)AND Rab_Typ = 7
              AND Twr_TwrId NOT IN (SELECT TwrId FROM dbo.#Cennik where Poziom = 7)
              AND (Twr_TwrId = @Twr_Id OR @Twr_Id=0)
    END
SET NOCOUNT OFF
SELECT * FROM dbo.#Cennik ORDER BY  TwrKod, Poziom DESC
