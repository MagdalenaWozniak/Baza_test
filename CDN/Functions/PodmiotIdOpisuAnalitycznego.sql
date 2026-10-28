CREATE FUNCTION CDN.PodmiotIdOpisuAnalitycznego(@guid nvarchar(255), @opis nvarchar(4000), @kodWymiaru nvarchar(4000))
RETURNS int
AS
BEGIN
 declare @Result int = 0;
 declare @WyWId int = 0;
 select @WyWId = WyW_WyWId from CDN.WymiaryWartosci where WyW_GUID = @guid and CDN.KodWymiaru(WyW_Wartosc) = @kodWymiaru
 set @Result = CDN.PodmiotIdWymiaruAnalitycznego(@WyWId, NULL);
 if @Result is null
  set @Result = 0;
 return @Result
END
