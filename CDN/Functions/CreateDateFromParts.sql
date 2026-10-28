create function cdn.CreateDateFromParts(@year int, @month int, @day int)
returns datetime
as
begin
 if @month > 12 and @month < 24
 begin
  set @month = @month - 12
  set @year = @year + 1
 end
 else if @month < 1
 begin
  set @month = 12 + @month
  set @year = @year - 1
 end
    return convert(datetime, convert(nvarchar, @year) + '-' + convert(nvarchar, @month) + '-' + convert(nvarchar, @day), 120)
end
