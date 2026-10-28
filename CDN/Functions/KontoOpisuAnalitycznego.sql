CREATE FUNCTION CDN.KontoOpisuAnalitycznego(@guid nvarchar(255), @opis nvarchar(4000), @strona int, @kodWymiaru nvarchar(4000))
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255) = null;
 declare @WyWId int = 0;
 select @WyWId = WyW_WyWId from CDN.WymiaryWartosci where WyW_GUID = @guid and CDN.KodWymiaru(WyW_Wartosc) = @kodWymiaru
 set @Result = CDN.KontoWymiaruAnalitycznego(@WyWId, @strona, NULL);
 if @Result is null
    set @Result = '';
 --if ISNULL(@Result,'') = '' and ISNULL(@opis, '') <> ''
 -- set @Result = CDN.AnalitykaOpisu(@opis, @kodWymiaru);
 return @Result
END
