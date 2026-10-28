create FUNCTION cdn.IsPesel
(@PESEL varchar(255))
RETURNS int
AS
BEGIN
declare @psl varchar(255);
set @psl=0;
if @PESEL='00000000000' begin return 0 end
if @PESEL='12345678910' begin return 0 end
if @PESEL='11111111116' begin return 0 end
if @PESEL='11111111123' begin return 0 end
if SUBSTRING(@pesel,3,1) not in ('0','1','2','3') begin return 0 end
if (isnumeric(@PESEL) =1 )
begin
set @psl = cast(@PESEL as varchar(255));
end
else
begin
return 0;
end;
if (
( ( cast(substring(@psl,1,1) as bigint)*9)
+(cast(substring(@psl,2,1) as bigint)*7)
+(cast(substring(@psl,3,1) as bigint)*3)
+(cast(substring(@psl,4,1) as bigint)*1)
+(cast(substring(@psl,5,1) as bigint)*9)
+(cast(substring(@psl,6,1) as bigint)*7)
+(cast(substring(@psl,7,1) as bigint)*3)
+(cast(substring(@psl,8,1) as bigint)*1)
+(cast(substring(@psl,9,1) as bigint)*9)
+(cast(substring(@psl,10,1) as bigint)*7) ) % 10
= right(@psl,1) )
begin
return 1
end
return 0;
END
