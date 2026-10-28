create function [CDN].[GetHistoriaAktualnaAll] (@Date DateTime)
returns @Historia table
(
 Pracownik int
)
as
begin
 insert into @Historia (Pracownik)
  select
  PRE_PraId
  from cdn.pracetaty
  where PRE_Paszport = '' and PRE_DowOsobisty = '' and PRE_Pesel = '' and (PRE_DataOd <= @Date and PRE_DataDo >= @Date)
 return
end
