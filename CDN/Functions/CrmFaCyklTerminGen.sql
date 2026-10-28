CREATE FUNCTION cdn.CrmFaCyklTerminGen(
@FcNId INT,
@Termin DATETIME,
@Mode INT)
  RETURNS     DATETIME
  AS
BEGIN
 DECLARE @OkresCyklu INT
 DECLARE @dzien  INT
    DECLARE @dw   INT
    DECLARE @dataOstatniej DATETIME
    DECLARE @powtarzajCo  INT
    DECLARE @powtarzajCoData DATETIME
    DECLARE @dataNastepnejGeneracji  DATETIME
 SELECT @OkresCyklu  = IsNull(FcN_OkresCyklu, 0),
   @dataOstatniej = FcN_DataOstatniej,
   @dzien = CASE IsNull(FcN_OkresCyklu, 0)
       WHEN 0 THEN FcN_DzienTygodnia
       ELSE     FcN_DzienMiesiaca
      END,
   @powtarzajCo = IsNull(FcN_PowtarzajCo, 1),
   @powtarzajCoData= FcN_PowtarzajCoData
 FROM cdn.FaCyklNag WHERE FcN_FcNID = @FcNId
 IF @OkresCyklu = 0 -- cykl tygodniowy
 BEGIN
  SET @dw = ( (DATEPART(dw, @Termin) + @@DATEFIRST-2) % 7 + 1) -- numer dnia tygodnia
  IF @powtarzajCo = 1 -- ustal datę początkową
   SET @powtarzajCoData = DATEDIFF(d, @dw-@dzien, @Termin)
        IF @powtarzajCoData >= @Termin
        BEGIN
            SET @dataNastepnejGeneracji = @powtarzajCoData
        END
        ELSE
        BEGIN
   SET @dataNastepnejGeneracji = DATEADD(wk, @powtarzajCo, @powtarzajCoData) -- ustal datę następnej generacji
   IF @dataNastepnejGeneracji < @Termin
    SET @dataNastepnejGeneracji = @Termin
  END
  SET @dw = ( (DATEPART(dw, @dataNastepnejGeneracji) + @@DATEFIRST-2) % 7 + 1) -- numer dnia tygodnia
  IF @dw <> @dzien
   SET @dataNastepnejGeneracji = DATEADD(d, 7-(@dw-@dzien), @dataNastepnejGeneracji)
  IF @Mode = 1 -- sprawdz, czy w ustalonym dniu nie bylo generacji
      IF DATEADD(day, DATEDIFF(day, 0, @dataNastepnejGeneracji), 0) = DATEADD(day, DATEDIFF(day, 0, @dataOstatniej), 0)
   SET @dataNastepnejGeneracji = DATEADD(wk, 1, @dataNastepnejGeneracji)
 END
 IF @OkresCyklu = 1 -- cykl miesięczny
 BEGIN
  IF IsNull(@dzien, 0) > cdn.LastDayOfMonth(@Termin)
   SET @dzien = cdn.LastDayOfMonth(@Termin)
  SET @dw = DAY(@Termin) -- numer dnia miesiąca
  IF @powtarzajCo = 1  -- ustal datę początkową
   SET @powtarzajCoData = cdn.Date(Year(@Termin),Month(@Termin),@dzien)
          IF @powtarzajCoData >= @Termin
        BEGIN
            SET @dataNastepnejGeneracji = @powtarzajCoData
        END
        ELSE
        BEGIN
   SET @dataNastepnejGeneracji = DATEADD(mm, @powtarzajCo, @powtarzajCoData) -- ustal datę następnej generacji
   IF @dataNastepnejGeneracji < @Termin
    SET @dataNastepnejGeneracji = @Termin
  END
  SET @dw = DAY(@dataNastepnejGeneracji) -- numer dnia miesiąca
  IF @dw <> @dzien
   SET @dataNastepnejGeneracji = DATEADD(d, cdn.LastDayOfMonth(@Termin)-(@dw-@dzien), @dataNastepnejGeneracji)
  IF @Mode = 1 -- sprawdz, czy w ustalonym dniu nie bylo generacji
      IF DATEADD(day, DATEDIFF(day, 0, @dataNastepnejGeneracji), 0) = DATEADD(day, DATEDIFF(day, 0, @dataOstatniej), 0)
   SET @dataNastepnejGeneracji = DATEADD(mm, 1, @dataNastepnejGeneracji)
 END
    RETURN @dataNastepnejGeneracji
END
