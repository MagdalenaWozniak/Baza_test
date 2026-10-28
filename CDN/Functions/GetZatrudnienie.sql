create function [CDN].[GetZatrudnienie] (@PraId int, @Date DateTime)
returns tinyint
as
begin
 declare @ZatrOd datetime
 declare @Zatr tinyint
 set @Zatr = 0
 declare @FirstDay datetime, @LastDay datetime
 select @FirstDay = DATEADD(MM, DATEDIFF(MM, -1, @Date), -1)
 select @LastDay = DATEADD(MM, DATEDIFF(MM, 1, @Date), 0)
 select @ZatrOd = PRE_ZatrudnionyOd from cdn.PracEtaty where PRE_PraId = @PraId and ((PRE_DataOd <= @FirstDay and PRE_DataDo >= @FirstDay) or (PRE_DataOd <= @LastDay and PRE_DataDo >= @LastDay))
 if @ZatrOd is not null
  return 1
 return 0
end
