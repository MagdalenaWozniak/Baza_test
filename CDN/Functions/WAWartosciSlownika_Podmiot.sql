CREATE FUNCTION CDN.WAWartosciSlownika_Podmiot(@WymiarId int)
RETURNS @Result TABLE( Id int identity(1,1), WyyId int, SlownikTyp int, SlownikId int, Value nvarchar(255), Description1 nvarchar(255), Description2 nvarchar(255), Description3 nvarchar(255))
AS
BEGIN
 Declare @SlownikID int = NULL;
 Declare @SlownikTyp int = NULL;
 Declare @rodzaj int = NULL;
 Select @SlownikID = IsNull(Wyy_SlownikId, 0), @SlownikTyp = IsNull(Wyy_SlownikTyp, 0) from CDN.Wymiary where Wyy_WyyID = @WymiarId;
 if @SlownikTyp = 3
 begin
  set @rodzaj = -3;
 end
 else if @SlownikTyp = 4
 begin
  set @SlownikTyp = 3;
  set @rodzaj = -4;
 end
 if @rodzaj is null
 begin
  if @SlownikTyp = 6 -- cdn.trwale
   if @SlownikID = 0
    insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1)
    SELECT @WymiarId as WyyId,  @SlownikTyp, Srt_SrtId, Srt_NrInwent, Srt_Nazwa
    FROM CDN.Trwale
    WHERE SrT_Stan = 0
    ORDER BY Srt_NrInwent
   else
    insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1)
    SELECT @WymiarId as WyyId,  @SlownikTyp, Srt_SrtId, Srt_NrInwent, Srt_Nazwa
    FROM CDN.Trwale
    WHERE SrT_Stan = 0 and Srt_SrtId = @SlownikID
    ORDER BY Srt_NrInwent
  else if @SlownikTyp = 7 -- cdn.towary
   if @SlownikID = 0
    insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1)
    SELECT @WymiarId as WyyId,  @SlownikTyp, Twr_TwrId, Twr_Kod, Twr_Nazwa
    FROM CDN.Towary
    WHERE Twr_NieAktywny = 0
    ORDER BY Twr_Kod
   else
    insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1)
    SELECT @WymiarId as WyyId,  @SlownikTyp, Twr_TwrId, Twr_Kod, Twr_Nazwa
    FROM CDN.Towary
    WHERE Twr_NieAktywny = 0 and Twr_TwrId = @SlownikID
    ORDER BY Twr_Kod
  else
   if @SlownikID = 0
    insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1, Description2, Description3)
    SELECT @WymiarId as WyyId,  Pod_PodmiotTyp, Pod_PodId, Pod_Kod, Pod_Nazwa1, Pod_KontoOdb, Pod_KontoDost
    FROM CDN.PodmiotyView
    WHERE Pod_NadID is Null and Pod_Nieaktywny=0 and Pod_PodmiotTyp = @SlownikTyp
    ORDER BY Pod_Kod
   else
    insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1, Description2, Description3)
    SELECT @WymiarId as WyyId,  Pod_PodmiotTyp, Pod_PodId, Pod_Kod, Pod_Nazwa1, Pod_KontoOdb, Pod_KontoDost
    FROM CDN.PodmiotyView
    WHERE Pod_NadID is Null and Pod_Nieaktywny=0 and Pod_PodmiotTyp = @SlownikTyp and Pod_PodId = @SlownikID
    ORDER BY Pod_Kod
 end
 else
 begin
  if @SlownikID = 0
   insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1, Description2, Description3)
   SELECT @WymiarId as WyyId,  Pod_PodmiotTyp, Pod_PodId, Pod_Kod, Pod_Nazwa1, Pod_KontoOdb, Pod_KontoDost
   FROM CDN.PodmiotyView
   WHERE Pod_NadID is Null and Pod_Nieaktywny=0 and Pod_PodmiotTyp = @SlownikTyp and Pod_Rodzaj = @rodzaj
   ORDER BY Pod_Kod
  else
   insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1, Description2, Description3)
   SELECT @WymiarId as WyyId,  Pod_PodmiotTyp, Pod_PodId, Pod_Kod, Pod_Nazwa1, Pod_KontoOdb, Pod_KontoDost
   FROM CDN.PodmiotyView
   WHERE Pod_NadID is Null and Pod_Nieaktywny=0 and Pod_PodmiotTyp = @SlownikTyp and Pod_PodId = @SlownikID and Pod_Rodzaj = @rodzaj
   ORDER BY Pod_Kod
 end
 return
END
