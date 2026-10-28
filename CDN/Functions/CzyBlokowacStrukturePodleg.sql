create function cdn.CzyBlokowacStrukturePodleg ()
returns tinyint
 as
 begin
   declare @val tinyint
   set @val = 0
  --MC2014.1 [167276]
  if exists (select * from sysobjects where name = 'EP_System' and xtype = 'u')
  begin
   --MC2020.3.1 [273728]
   --if (select Sys_Wartosc from cdn.EP_System where Sys_Id = 2) < '2014.1.1'
    --return 1
   exec sp_executesql N'if (select Sys_Wartosc from cdn.EP_System where Sys_Id = 2) < ''2014.1.1''
   set @test = 1
   else
   set @test = 0', N'@test tinyint', @test=@val OUTPUT
  end
  --return 0
  return @val
 end
