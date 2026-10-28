create procedure CDN.OkresyZatrudnienieniaPracownika @PraID int
as
set nocount on
begin
  DECLARE @DOd datetime
  DECLARE @DDo datetime
  DECLARE @DOd_Temp datetime
  DECLARE @DDo_Temp datetime
  create table #Temp(DataOd datetime, DataDo datetime)
  declare CURS SCROLL cursor for
  select PRE_ZatrudnionyOd ,PRE_ZatrudnionyDo from cdn.PracEtaty where PRE_PraId = @PraID order by PRE_DataOd asc
  OPEN CURS;
  FETCH NEXT FROM CURS INTO @DOd,@DDo
  WHILE @@FETCH_STATUS=0
   BEGIN
    if @DOd_Temp is null
    begin
    set @DOd_Temp = @DOd
    set @DDo_Temp = @DDo
    end
    else
    begin
    if @DOd_Temp <> @DOd
    begin
    insert into #Temp values (@DOd_Temp, @DDo_Temp)
     set @DOd_Temp = @DOd
     set @DDo_Temp = @DDo
    end
    else
    begin
     set @DDo_Temp = @DDo
    end
    end
   FETCH NEXT FROM CURS INTO @DOd,@DDo
   END
  CLOSE CURS
  DEALLOCATE CURS
  if @DOd_Temp is not null and  @DDo_Temp is not null
   insert into #Temp values (@DOd_Temp, @DDo_Temp)
  SELECT * FROM #Temp /*where (DataOd <> convert(datetime, '18991230', 101) and DataDo <> convert(datetime, '18991230', 101)) and
         (DataOd <> convert(datetime, '29991231', 101) and DataDo <> convert(datetime, '29991231', 101)) */ order by DataOd
  DROP TABLE #Temp
end
set nocount off
