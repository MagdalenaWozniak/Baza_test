CREATE FUNCTION cdn.CrmFaCyklDoReal(
@FcNId INT,
@Termin DATETIME,
@Mode INT)
  RETURNS     INT
  AS
BEGIN
 DECLARE @OkresCyklu INT
 DECLARE @dzien  INT
    DECLARE @dw   INT
    DECLARE @dataOstatniej DATETIME
    DECLARE @powtarzajCo  INT
    DECLARE @powtarzajCoData DATETIME
 SELECT @OkresCyklu  = IsNull(FcN_OkresCyklu, 0),
   @dataOstatniej = FcN_DataOstatniej,
   @dzien = CASE IsNull(FcN_OkresCyklu, 0)
       WHEN 0 THEN FcN_DzienTygodnia
       ELSE     FcN_DzienMiesiaca
      END,
   @powtarzajCo = IsNull(FcN_PowtarzajCo, 1),
   @powtarzajCoData= FcN_PowtarzajCoData
 FROM cdn.FaCyklNag WHERE FcN_FcNID = @FcNId AND FcN_Nieaktywny=0
 IF @OkresCyklu = 0 -- cykl tygodniowy
 BEGIN
  SELECT @dw = ( (DATEPART(dw, @Termin) + @@DATEFIRST-2) % 7 + 1)
  IF @dzien <> @dw RETURN 0
  IF @powtarzajCo > 1
   IF DATEDIFF(wk, @powtarzajCoData, @Termin) % @powtarzajCo <> 0 RETURN 0
  IF @Mode = 1 -- sprawdz, czy dzisiaj nie bylo generacji
   IF Convert(NVARCHAR(10), @Termin, 120) = Convert (NVARCHAR(10), @dataOstatniej, 120) RETURN 0
  RETURN 1
 END
 IF @OkresCyklu = 1 -- cykl miesięczny
 BEGIN
  IF IsNull(@dzien, 0) > cdn.LastDayOfMonth(@Termin)
   SET @dzien = cdn.LastDayOfMonth(@Termin)
     IF IsNull(@dzien, 0) <> IsNull(DAY(@Termin), 0) RETURN 0
  IF @powtarzajCo > 1
   IF DATEDIFF(mm, @powtarzajCoData, @Termin) % @powtarzajCo <> 0 RETURN 0
  IF @Mode = 1  -- sprawdz, czy dzisiaj nie bylo generacji
   IF Convert(NVARCHAR(10), @Termin, 120) = Convert (NVARCHAR(10), @dataOstatniej, 120) RETURN 0
  RETURN 1
 END
 RETURN 0
END
