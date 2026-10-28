CREATE FUNCTION CDN.PodmiotTypWymiaruAnalitycznego(@WyWId int, @Value nvarchar(1024))
RETURNS int
AS
BEGIN
 --declare @Result nvarchar(255) = @Value;
 declare @Result int = 0;
 Declare @tWymiar int = 1;
 Declare @tPodwymiar int = 2;
 Declare @tOpis int = 3;
 Declare @twOpis int = 1;
 Declare @twKategoria int = 2;
 Declare @twPlanKont int = 3;
 Declare @twSlownik int = 4;
 declare @WyyId int = 0;
 declare @Typ int = 0;
 declare @TypWymiaru int = 0;
 if @Value is not null
 begin
  select @WyyId = WyW_WyyId from CDN.WymiaryWartosci where WyW_WyWId = @WyWId and CHARINDEX(@Value, WyW_Wartosc)=1;
  if IsNUll(@WyyId, 0)=0
   return @Result;
 end
 select @WyyId = WyW_WyyId from CDN.WymiaryWartosci where WyW_WyWId = @WyWId;
 select @Typ =Wyy_Typ, @TypWymiaru = Wyy_TypWymiaru, @Result = Wyy_SlownikTyp from CDN.Wymiary where Wyy_WyyID = @WyyId;
 if @TypWymiaru <> @twSlownik
  set @Result = 0;
 if @Result = 4
  Set @Result = 3;
 return @Result
END
