create function cdn.StopienUprawnieniaEng(@Arg varchar(32))
returns nvarchar(32)
as
begin
 declare @retval nvarchar(32)
 if(@Arg = 'słaba')
  set @retval = 'Poor'
 if(@Arg = 'dostateczna')
  set @retval = 'Fair'
 if(@Arg = 'dobra')
  set @retval = 'Good'
 if(@Arg = 'bardzo dobra')
  set @retval = 'VeryGood'
 return @retval
end
