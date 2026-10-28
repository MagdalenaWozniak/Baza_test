


  

CREATE procedure [dbo].[ONENal_03_exec] as  

  

declare @ParamList varchar(2000) 

declare @ParamValue varchar(2000) 

declare @ExtList varchar(2000) 

declare @ExtValue varchar(2000) 
declare @subscriptionID varchar(255) = '56DABA6D-4960-454C-9C00-68E4DF8F3297'
declare cur_cursor cursor for ( 

  

SELECT    

			'podm' as ParamList 
 			, Pod_PodId as ParamValue 
 
            , 'TO|BCC|Subject|IncludeReport|RenderFormat' as ExtList 

            , Email+'|krzysztof.groszak@one-support.pl; maciej.pawelczak@one-support.pl|One Support sp. z o.o. - powiadomienie o należnościach|True|MHTML' as ExtValue 

from ( 

select distinct
	p.Pod_PodId
	, Email
from cdn.BnkZdarzenia as z
	join cdn.PodmiotyView as p on z.BZd_PodmiotID = p.Pod_PodId and z.BZd_PodmiotTyp = p.Pod_PodmiotTyp
	join One_WindykacjaPowiadomienia as w on p.Pod_PodId = w.Pod_PodId
where ((((BZd_Rozliczono<>2 AND BZd_Rozliczono<>0) AND (1=1)))) and BZd_Kierunek = 1 and datediff(day, BzD_Termin, getdate()) > 0 

	) as x

  




)    

order by Email

open cur_cursor 

Fetch Next from cur_cursor into @ParamList, @ParamValue, @ExtList, @ExtValue 

While @@fetch_status = 0 

begin 

update ReportServer.dbo.Subscriptions 
	set InactiveFlags = 0
	where SubscriptionID = @subscriptionID 

while
	(select top 1 LastStatus 
		from ReportServer.dbo.[Subscriptions] as s
		where SubscriptionID = @subscriptionID) like '%Pending%'
	and (select top 1 LastRunTime 
		from ReportServer.dbo.[Subscriptions] as s
		where SubscriptionID = @subscriptionID) > dateadd(hour,-2,getdate())
begin			
waitfor delay '00:00:05'
end

exec ONENal_03

@subscriptionID, 

@parameterNameLIST = @ParamList, 

@parameterValueLIST = @ParamValue, 

@ExtensionSettingNameLIST = @ExtList, 

@ExtensionSettingValueLIST = @ExtValue, 

@exitCode = '', 

@exitMessage = '' 

  

WAITFOR DELAY '00:00:10' 

  

Fetch Next from cur_cursor into @ParamList, @ParamValue, @ExtList, @ExtValue 

end 

close cur_cursor 

deallocate cur_cursor 

  

  

















